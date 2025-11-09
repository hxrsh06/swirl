# Installing Flutter

## Windows Installation

### 1. Download Flutter SDK
1. Go to https://docs.flutter.dev/get-started/install
2. Download the Flutter SDK for Windows
3. Extract the archive to a desired location (e.g., `C:\src\flutter`)

### 2. Update PATH Environment Variable
1. Open System Properties → Advanced → Environment Variables
2. Under "User variables", find and select "Path", then click "Edit"
3. Click "New" and add the path to `flutter\bin` (e.g., `C:\src\flutter\bin`)
4. Click "OK" to close all dialogs

### 3. Verify Installation
Open a new Command Prompt or PowerShell window and run:
```bash
flutter --version
```

### 4. Run Flutter Doctor
```bash
flutter doctor
```
This will show any remaining setup steps needed for your development environment.

### 5. Install Android Studio (for Android development)
1. Download Android Studio from https://developer.android.com/studio
2. Install and open Android Studio
3. Go to SDK Manager and install:
   - Android SDK
   - Android SDK Platform 33 (or latest)
   - Android SDK Build-Tools
   - Android SDK Platform-Tools
4. Go to AVD Manager and create a virtual device

### 6. Accept Android licenses
```bash
flutter doctor --android-licenses
```

## macOS Installation

### 1. Install Flutter using Homebrew
```bash
brew install --cask flutter
```

### 2. Or download Flutter SDK manually
1. Go to https://docs.flutter.dev/get-started/install
2. Download the Flutter SDK for macOS
3. Extract to desired location (e.g., `~/development/flutter`)

### 3. Update PATH
Add this line to your `~/.bashrc` or `~/.zshrc`:
```bash
export PATH="$PATH:~/development/flutter/bin"
```

### 4. Reload terminal
```bash
source ~/.bashrc  # or source ~/.zshrc
```

## Linux Installation

### 1. Install dependencies
```bash
sudo apt-get update
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

### 2. Download Flutter SDK
1. Go to https://docs.flutter.dev/get-started/install
2. Download the Flutter SDK for Linux
3. Extract to desired location:
```bash
cd ~/development
unzip flutter_linux_x.x-stable.zip
```

### 3. Update PATH
Add this line to your `~/.bashrc`:
```bash
export PATH="$PATH:~/development/flutter/bin"
```

### 4. Reload terminal
```bash
source ~/.bashrc
```

## Verify Installation

After installation, run these commands to verify Flutter is properly installed:

```bash
flutter --version
flutter doctor
```

The `flutter doctor` command will show you any additional tools that need to be installed for your development environment.

## Running Your App

Once Flutter is installed:

1. Navigate to your project directory:
```bash
cd shopping_swipe_app
```

2. Get project dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

For more detailed instructions, refer to the official Flutter documentation: https://docs.flutter.dev/get-started/install