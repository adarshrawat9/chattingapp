💬 Secure Chat App

A real-time end-to-end encrypted chat application for Android and iOS built with Flutter. All messages are AES encrypted before leaving the device — meaning even if the data is intercepted, it's unreadable.


Features


🔐 End-to-end AES encryption on all message payloads
💬 Real-time messaging powered by Firebase Firestore
🔑 Secure authentication via Firebase Auth
👥 Contact and chat room management
📱 Cross-platform — works on both Android and iOS
🧱 Clean Architecture for a fully decoupled, testable codebase



Tech Stack

LayerTechnologyFrameworkFlutter (Dart)State ManagementBLoC (Cubit)Backend / DatabaseFirebase FirestoreAuthenticationFirebase AuthEncryptionAES (via encrypt package)Service LocatorGetItArchitectureClean Architecture


Project Structure

lib/
├── config/
│   └── theme/              # App theme
├── core/
│   ├── common/             # Reusable widgets (buttons, text fields)
│   └── utils/              # Encryption helper, storage helper, UI utils
├── data/
│   ├── models/             # Chat, room, and user models
│   ├── repositories/       # Auth, chat, and contact repositories
│   └── services/           # Base repository, service locator
├── logic/
│   └── cubits/
│       ├── auth/           # Auth cubit + state
│       ├── chat/           # Chat cubit + state
│       └── observer/       # App lifecycle observer
└── presentation/           # UI screens and widgets


Getting Started

Prerequisites


Flutter SDK installed
A Firebase project set up
Android Studio or VS Code


Setup


Clone the repo


bashgit clone https://github.com/adarshrawat9/chattingapp.git
cd chattingapp


Install dependencies


bashflutter pub get


Connect Firebase

Go to Firebase Console
Create a new project and add Android + iOS apps
Download google-services.json (Android) and GoogleService-Info.plist (iOS)
Place them in the correct platform folders
Replace firebase_options.dart with your generated config



Run the app


bashflutter run


How Encryption Works

Every message is encrypted on the sender's device using AES before being written to Firestore. The encrypted payload is what gets stored and transmitted — the decryption happens locally on the receiver's device. This means the message content is never exposed in plain text at the storage or transport layer.


Architecture

This project follows Clean Architecture principles:


Data layer — models, repositories, and Firebase services
Logic layer — BLoC cubits managing auth and chat state
Presentation layer — UI screens consuming cubit states


Dependencies flow inward. The UI knows nothing about Firebase directly — it only talks to cubits, which talk to repositories.


License

MIT