# CampusComfort

A Flutter mobile app where students report campus incidents and authorized staff
review the reports and update their status.

Built with Flutter, Firebase (Authentication and Cloud Firestore) and Provider.

## Features

- Email/password authentication with student self sign-up.
- Two roles: students submit reports; staff review reports and update status.
- Submit a report with category, title, description, location and an optional
  photo preview.
- Browse your own reports with search, status and category filters.
- Staff view of all reports with status summary cards, search and filters.
- Status timeline (Submitted to In Progress to Resolved) with full history.
- Live updates from Firestore streams plus pull-to-refresh.

## Tech stack

- Flutter 3.47.x, Dart 3.13.7
- firebase_core, firebase_auth, cloud_firestore
- provider (ChangeNotifier) for state management
- google_fonts (Poppins), intl, image_picker

## Prerequisites

You only need the following to run this project:

- Flutter SDK 3.47.x (it bundles Dart 3.13.7). Check with `flutter --version`.
- Android Studio with the Android SDK, and one of:
  - an Android emulator (AVD), or
  - a physical Android device with USB debugging enabled.
- An internet connection. Firebase and the Poppins font are fetched over the
  network.

Run `flutter doctor` and make sure the Flutter and Android toolchain checks are
green before continuing.

Note: this project is set up for Android. iOS is not configured (there is no
`GoogleService-Info.plist`). To run on iOS you would need macOS with Xcode and
CocoaPods, plus Firebase configuration for iOS.

## Getting started

1. Clone the repository:

   ```bash
   git clone https://github.com/Angebright/campus_incident_reporter.git
   cd campus_incident_reporter
   ```

2. Fetch dependencies:

   ```bash
   flutter pub get
   ```

3. Start an Android emulator or connect a device:

   ```bash
   flutter devices
   flutter emulators
   flutter emulators --launch <emulator_id>
   ```

4. Run the app:

   ```bash
   flutter run
   ```

Important: run the app on Android, not the web. `flutter run -d chrome` will not
work because Firebase web is not configured, and this is a mobile project.

## Demo accounts

The Firebase backend is already set up and includes two demo accounts:

| Role | Email | Password |
| --- | --- | --- |
| Staff | bernard@alueducation.com | Campus123 |
| Student | d.student@alustudent.com | Campus123 |

Only ALU emails are accepted: students use `@alustudent.com` (in the form
`a.lastname@alustudent.com`) and staff use `@alueducation.com`.

You can also create a new student account from the Sign up screen.

## Firebase

No Firebase setup is required. The repository already includes:

- `lib/firebase_options.dart` and `android/app/google-services.json` for the
  shared Firebase project `campus-incident-reporter-1a4fb`.
- `firestore.rules` and `firestore.indexes.json` (already deployed).

You do not need to run `flutterfire configure` or use the Firebase console.

## Verifying the project

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Project structure

```
lib/
  main.dart               App entry point and provider wiring
  firebase_options.dart   Firebase configuration (generated)
  models/                 Incident, AppUser, enums, status history
  services/               AuthService and IncidentService interfaces and Firebase implementations
  providers/              AuthProvider, IncidentProvider, StaffProvider, NavigationProvider
  screens/                auth, student, staff and shared screens
  widgets/                Reusable UI components
  theme/                  Colors, theme and status styling
  utils/                  Validators, date formatting, filters, error messages
test/                     Unit, provider and widget tests
```

## Known limitations

- Incident photos are picked and previewed but not uploaded. `imageUrl` is
  stored as null because enabling Firebase Storage required billing. The upload
  flow can be added later.
- iOS is not configured. Use an Android emulator or device.
