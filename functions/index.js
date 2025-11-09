/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const {onDocumentCreated, onDocumentUpdated} =
    require("firebase-functions/v2/firestore");
const {onCall} =
    require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

// Initialize the Firebase Admin SDK
admin.initializeApp();

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({maxInstances: 10});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// HTTP function for health check
exports.helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Shopping Swipe App!");
});

// Callable function to get personalized product recommendations
exports.getRecommendations = onCall(async (request) => {
  // Verify user authentication
  if (!request.auth) {
    throw new Error("Authentication required");
  }

  const userId = request.auth.uid;
  logger.info(`Getting recommendations for user: ${userId}`);

  try {
    // Get user's preferences and interaction history
    const userRef = admin.firestore().collection("users").doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      throw new Error("User not found");
    }

    const userData = userDoc.data();
    const likedProductIds = userData.likedProducts || [];
    const dislikedProductIds = userData.dislikedProducts || [];
    const categoryPreferences = userData.categoryPreferences || {};
    const brandPreferences = userData.brandPreferences || {};

    // Build query for products based on user preferences
    let productsQuery = admin.firestore().collection("products");

    // If user has category preferences, prioritize those
    if (Object.keys(categoryPreferences).length > 0) {
      const preferredCategories = Object.entries(categoryPreferences)
          .sort((a, b) => b[1] - a[1]) // Sort by preference value descending
          .slice(0, 3) // Take top 3 categories
          .map((entry) => entry[0]);

      if (preferredCategories.length > 0) {
        productsQuery = productsQuery.where(
            "category",
            "in",
            preferredCategories,
        );
      }
    }

    // Get products that haven't been interacted with yet
    const excludedIds = [...likedProductIds, ...dislikedProductIds];
    if (excludedIds.length > 0) {
      // Limit to avoid query limits
      productsQuery = productsQuery.where(
          "id",
          "not-in",
          excludedIds.slice(0, 30),
      );
    }

    // Limit results
    productsQuery = productsQuery.limit(20);

    const productsSnapshot = await productsQuery.get();
    const products = [];
    productsSnapshot.forEach((doc) => {
      products.push({
        id: doc.id,
        ...doc.data(),
      });
    });

    // Sort by user preferences and other factors
    const sortedProducts = products.sort((a, b) => {
      let scoreA = 0;
      let scoreB = 0;

      // Boost score for preferred categories
      if (categoryPreferences[a.category]) {
        scoreA += categoryPreferences[a.category] * 2;
      }
      if (categoryPreferences[b.category]) {
        scoreB += categoryPreferences[b.category] * 2;
      }

      // Boost score for preferred brands
      if (brandPreferences[a.brand]) {
        scoreA += brandPreferences[a.brand];
      }
      if (brandPreferences[b.brand]) {
        scoreB += brandPreferences[b.brand];
      }

      // Boost score for higher ratings
      scoreA += a.rating || 0;
      scoreB += b.rating || 0;

      return scoreB - scoreA; // Higher score first
    });

    return {products: sortedProducts.slice(0, 10)};
  } catch (error) {
    logger.error("Error getting recommendations:", error);
    throw new Error(`Error getting recommendations: ${error.message}`);
  }
});

// Function triggered when a user likes/dislikes a product
exports.updateUserPreference = onDocumentUpdated({
  document: "user_preferences/{userId}",
}, async (event) => {
  const userId = event.params.userId;
  const change = event.data;

  if (!change) return null;

  const beforeData = change.before.data();
  const afterData = change.after.data();

  // Check if user's preferences have changed
  if (JSON.stringify(beforeData) !== JSON.stringify(afterData)) {
    logger.info(`User preferences updated for user: ${userId}`);

    // Update user's main document with latest preferences
    const userRef = admin.firestore().collection("users").doc(userId);
    await userRef.update({
      categoryPreferences: afterData.categoryPreferences || {},
      brandPreferences: afterData.brandPreferences || {},
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  return null;
});

// Function to update product swipe counts
exports.updateProductStats = onDocumentUpdated({
  document: "users/{userId}",
}, async (event) => {
  const change = event.data;

  if (!change) return null;

  const beforeData = change.before.data();
  const afterData = change.after.data();

  // Check if liked or disliked products have changed
  const beforeLiked = beforeData.likedProducts || [];
  const afterLiked = afterData.likedProducts || [];
  const beforeDisliked = beforeData.dislikedProducts || [];
  const afterDisliked = afterData.dislikedProducts || [];

  // Find new likes and dislikes
  const newLiked = afterLiked.filter((id) => !beforeLiked.includes(id));
  const newDisliked = afterDisliked.filter(
      (id) => !beforeDisliked.includes(id));

  // Update product statistics
  for (const productId of newLiked) {
    const productRef = admin.firestore().collection("products").doc(productId);
    await productRef.update({
      likeCount: admin.firestore.FieldValue.increment(1),
      totalSwipes: admin.firestore.FieldValue.increment(1),
      popularityScore: admin.firestore.FieldValue.increment(1),
    });
  }

  for (const productId of newDisliked) {
    const productRef = admin.firestore().collection("products").doc(productId);
    await productRef.update({
      dislikeCount: admin.firestore.FieldValue.increment(1),
      totalSwipes: admin.firestore.FieldValue.increment(1),
    });
  }

  return null;
});

// Function to send notification when new products are added
// SCALABILITY FIX: Use batched processing to handle large user bases
exports.notifyNewProducts = onDocumentCreated({
  document: "products/{productId}",
}, async (event) => {
  const productData = event.data.data();
  const productId = event.params.productId;

  logger.info(`New product added: ${productData.name}`);

  try {
    // SCALABILITY: Process users in batches of 500 to avoid memory issues
    const BATCH_SIZE = 500;
    let lastDoc = null;
    let processedCount = 0;

    while (true) {
      // Query users in batches
      let query = admin.firestore()
          .collection("users")
          .limit(BATCH_SIZE);

      if (lastDoc) {
        query = query.startAfter(lastDoc);
      }

      const usersSnapshot = await query.get();

      if (usersSnapshot.empty) {
        break; // No more users to process
      }

      // Create notifications for this batch
      const batch = admin.firestore().batch();

      usersSnapshot.forEach((userDoc) => {
        const notificationRef = admin.firestore()
            .collection("notifications").doc();
        batch.set(notificationRef, {
          userId: userDoc.id,
          title: "New Product Available!",
          body: `Check out ${productData.name} - now available in our store!`,
          productId: productId,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          read: false,
        });
      });

      // Commit this batch
      await batch.commit();

      processedCount += usersSnapshot.size;
      lastDoc = usersSnapshot.docs[usersSnapshot.docs.length - 1];

      logger.info(
          `Processed ${processedCount} notifications for ${productData.name}`,
      );

      // If we got fewer docs than BATCH_SIZE, we're done
      if (usersSnapshot.size < BATCH_SIZE) {
        break;
      }
    }

    logger.info(
        `Total ${processedCount} notifications sent for: ${productData.name}`,
    );
  } catch (error) {
    logger.error("Error sending notifications:", error);
    // Don't throw - allow product creation to succeed even if notifications fail
  }

  return null;
});

// Callable function to process orders
exports.processOrder = onCall(async (request) => {
  // Verify user authentication
  if (!request.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required",
    );
  }

  const userId = request.auth.uid;
  const {products, totalAmount, shippingAddress} = request.data;

  logger.info(`Processing order for user: ${userId}`);

  try {
    // SECURITY: Validate input data
    if (!products || !Array.isArray(products) || products.length === 0) {
      throw new functions.https.HttpsError(
          "invalid-argument",
          "Products array is required and must not be empty",
      );
    }

    if (!totalAmount || typeof totalAmount !== "number" || totalAmount <= 0) {
      throw new functions.https.HttpsError(
          "invalid-argument",
          "Valid total amount is required",
      );
    }

    if (!shippingAddress || typeof shippingAddress !== "object") {
      throw new functions.https.HttpsError(
          "invalid-argument",
          "Valid shipping address is required",
      );
    }

    // SECURITY: Validate each product exists and recalculate total
    let calculatedTotal = 0;
    const validatedProducts = [];

    for (const item of products) {
      // Validate product item structure
      if (!item.id || !item.quantity || typeof item.quantity !== "number") {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Each product must have id and quantity",
        );
      }

      if (item.quantity <= 0 || item.quantity > 100) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Product quantity must be between 1 and 100",
        );
      }

      // Fetch product from database to verify price
      const productDoc = await admin.firestore()
          .collection("products").doc(item.id).get();

      if (!productDoc.exists) {
        throw new functions.https.HttpsError(
            "not-found",
            `Product ${item.id} not found`,
        );
      }

      const productData = productDoc.data();

      // SECURITY: Check inventory availability
      const currentInventory = productData.inventory || 0;
      if (currentInventory < item.quantity) {
        throw new functions.https.HttpsError(
            "failed-precondition",
            `Insufficient inventory for product ${productData.name}`,
        );
      }

      // Calculate total based on database prices (not client prices)
      calculatedTotal += productData.price * item.quantity;

      validatedProducts.push({
        id: item.id,
        name: productData.name,
        price: productData.price,
        quantity: item.quantity,
      });
    }

    // SECURITY: Verify submitted total matches calculated total
    if (Math.abs(calculatedTotal - totalAmount) > 0.01) {
      throw new functions.https.HttpsError(
          "invalid-argument",
          `Total amount mismatch. Expected: ${calculatedTotal}, Got: ${totalAmount}`,
      );
    }

    // Create order document
    const orderData = {
      userId: userId,
      products: validatedProducts,
      totalAmount: calculatedTotal,
      shippingAddress: shippingAddress,
      status: "pending",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const orderRef = await admin.firestore()
        .collection("orders").add(orderData);

    // Update user's order history
    await admin.firestore().collection("users").doc(userId).update({
      orderHistory: admin.firestore.FieldValue.arrayUnion(orderRef.id),
      lastOrderAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Update product inventory using batch operations
    const batch = admin.firestore().batch();
    for (const product of validatedProducts) {
      const productRef = admin.firestore()
          .collection("products").doc(product.id);
      batch.update(productRef, {
        inventory: admin.firestore.FieldValue.increment(-product.quantity),
        salesCount: admin.firestore.FieldValue.increment(product.quantity),
      });
    }
    await batch.commit();

    // Clear user's cart
    await admin.firestore().collection("carts").doc(userId)
        .delete().catch(() => {
          // If cart doesn't exist, ignore the error
        });

    return {orderId: orderRef.id, status: "success"};
  } catch (error) {
    logger.error("Error processing order:", error);

    // Re-throw HttpsError as-is, wrap other errors
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError(
        "internal",
        `Error processing order: ${error.message}`,
    );
  }
});
