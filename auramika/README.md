# AURAMIKA - Premium Gen Z Jewelry Marketplace

AURAMIKA is a modern Flutter e-commerce app designed for Gen Z jewelry lovers. It features AI-powered try-on with the Magic Mirror, express delivery, and a premium shopping experience.

## Features

- 🏠 **Home Screen**: Vibrant vibe-based product discovery
- 🪞 **Magic Mirror**: AI-powered try-on experience
- 🛒 **Shopping Cart**: Real-time cart management with Riverpod
- 💳 **Checkout**: Seamless checkout with multiple payment options
- 📱 **Express Delivery**: 2-hour delivery for eligible items
- 🎨 **Premium UI**: Beautiful animations and smooth transitions

## Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod (flutter_riverpod)
- **Navigation**: GoRouter
- **Animations**: Flutter Animate, Rive
- **Architecture**: Clean Architecture (Feature-based)

## Getting Started

### Prerequisites

- Flutter SDK 3.x+
- Dart 3.x+
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

1. **Clone the repository**
   ```bash
   cd auramika
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

#### iOS
```bash
flutter build ios --release
```

#### Android
```bash
flutter build apk --release
```

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App colors, text styles, constants
│   ├── router/         # GoRouter configuration
│   ├── theme/          # App theme
│   ├── network/        # API client
│   └── storage/        # Local storage
├── features/
│   ├── cart/           # Shopping cart feature
│   ├── home/           # Home screen
│   ├── product/        # Product detail
│   ├── profile/        # User profile
│   ├── stylist/        # Magic Mirror (AI try-on)
│   └── vendor/         # Vendor/shop feature
├── shared/
│   ├── widgets/        # Reusable widgets
│   ├── extensions/     # Extension methods
│   └── utils/         # Utility functions
└── main.dart           # App entry point
```

## Configuration

### Launcher Icons
The app uses `flutter_launcher_icons` for generating app icons. To regenerate:
```bash
dart run flutter_launcher_icons
```

### Splash Screen
The app uses `flutter_native_splash` for the splash screen. To regenerate:
```bash
dart run flutter_native_splash:create
```

## App Flow

1. **Browse Products**: Explore jewelry by vibe categories on the home screen
2. **View Details**: Tap any product to see full details
3. **Add to Cart**: Add items to your cart with real-time updates
4. **Magic Mirror**: Use the AI-powered try-on feature
5. **Shop This Look**: From Magic Mirror recommendations, directly add to cart
6. **Checkout**: Complete your purchase with real cart totals
7. **Success**: Order confirmation with delivery tracking

## Design System

### Colors
- **Primary**: Forest Green (#1A2F25)
- **Accent**: Gold (#D4AF37)
- **Background**: Alabaster (#FAFAF5)
- **Surface**: White (#FFFFFF)
- **Brass**: Brass (#B5A642)
- **Copper**: Copper (#B87333)

### Typography
Uses Google Fonts - primarily for clean, modern readability.

## License

This project is proprietary software for AURAMIKA.
