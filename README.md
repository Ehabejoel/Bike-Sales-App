# Bike Sales App

A Flutter-based marketplace application for buying and selling bikes in Cameroon.

## Features

- **User Authentication**: Secure login and signup functionality using Firebase Auth
- **Bike Listings**: Browse, search, and filter available bikes
- **Categories**: Filter bikes by categories (Mountain, Road, Electric, BMX)
- **Grid/List View**: Toggle between different viewing layouts
- **Real-time Updates**: Live updates using Firebase Realtime Database
- **Price Filtering**: Filter bikes by price range
- **Profile Management**: User profile and listings management
- **Order Tracking**: Track bike purchase orders
- **Image Upload**: Upload and manage bike images

## Getting Started

### Prerequisites

- Flutter SDK (2.0 or higher)
- Firebase account
- Android Studio or VS Code
- Git

### Installation

1. Clone the repository:

### Setting up Firebase

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your Android/iOS app:
   - Android: Use package name `com.example.bikesalesapp`
   - iOS: Use bundle ID `com.example.bikesalesapp`
3. Download and add the configuration files:
   - Android: `google-services.json` to `android/app/`
   - iOS: `GoogleService-Info.plist` to `ios/Runner/`

### Environment Variables

Create a `.env` file in the project root:
