# Articles HUB– Flutter Firebase App

 Articles Hub  is a Flutter-based mobile application that allows users to:

 Register/Login with Firebase Authentication

Create, edit, and delete articles

 Sync articles with Cloud Firestore and SQLite (local cache)

 Receive push notifications (FCM) when a new article is posted (except for the author)

View personal posting frequency with a contribution heatmap

 Work in both online/offline modes (local caching with sync)

 Tech Stack

Flutter (Dart)

Provider for state management

Firebase Authentication for user management

Cloud Firestore for storing articles and user data

Firebase Cloud Messaging (FCM) for push notifications

SQLite (via DBHelper) for offline caching

MVVM Architecture (Model-View-ViewModel)

 Features Implemented

- User Registration & Login
- Article CRUD (Create, Read, Update, Delete)
- Push Notifications using Firebase Cloud Messaging (API V1)
- Offline caching with SQLite
- Contribution heatmap (posting frequency tracker)
- Clean business-formal MVVM structure
