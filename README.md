# SilentGuard 🛡️

**SilentGuard** is a mobile application built with Flutter and Firebase, developed in partnership with **Renel Ghana** to support Gender-Based Violence (GBV) survivors. It provides a safe, discreet platform for victims to seek help, report incidents, and communicate with trained support staff in real time.

---

## 📱 Features

### User (Victim) Side
- **SOS Emergency Button** — Long-press to trigger an SOS alert that shares live GPS location with the nearest Renel Ghana staff member.
- **Live Map Tracking** — After triggering SOS, the victim can monitor the status of their request and see when help is on the way.
- **Case Reporting (GBV Intake Form)** — Submit a detailed incident report including personal information, incident type, description, immediate needs, and supporting evidence.
- **Case History** — View all submitted cases with live status updates (status and officer assignment reflect changes made by admin in real time).
- **Case Chat** — Chat directly with an assigned officer within a case; messages are delivered to both sides in real time.
- **Evidence Management** — Upload, record, and archive photo, video, audio, and document evidence.
- **Call Support** — One-tap call to Renel Ghana or emergency services.
- **Messaging** — WhatsApp-style contact interface with pre-loaded Renel Ghana contact.
- **Profile** — Manage personal information.

### Admin (Renel Ghana Staff) Side
- **Staff Portal Dashboard** — Role-based dashboard automatically shown to staff accounts after login.
- **Live SOS Monitoring** — Real-time list of active SOS alerts pulled from Firestore. Clicking "Track User Location" opens a dedicated **admin map view** that shows the *victim's* live GPS location (not the admin's own location).
- **Case Management** — Admin can open any reported case and:
  - Update the **case status** (Open → In Progress → Pending → Resolved → Closed)
  - **Assign an officer** by name/badge
  - Add **internal notes** that are logged with date and author
  - Send **direct messages** to the victim within the case chat thread
- **Live Stats** — Dashboard summary cards (Active SOS, Open Cases, Resolved Cases) are live-streaming from Firestore.
- **Proper Logout** — Sign-out correctly invokes Firebase Auth `signOut()`.

---

## 🔑 Role-Based Access

| Role      | Login         | Redirected To  |
|-----------|---------------|----------------|
| `victim`  | Normal signup | `HomeScreen`   |
| `rep`     | Manual setup  | `RepDashboard` |

Roles are stored in the Firestore `users` collection under the `role` field. To create a staff account, set `role: "rep"` in Firestore after signup.

---

## 🗄️ Firestore Data Structure

```
/users/{uid}
  - fullName, email, phoneNumber, role, createdAt

/cases/{caseId}
  - incident_number, status, priority_level, officer
  - victim_name, victim_dob, victim_gender, victim_phone, location
  - case_type, incident_date, description, immediate_needs
  - updates: [ { date, message, author } ]
  - media: [ { type, label, size, path } ]
  - created_at, updated_at

/cases/{caseId}/messages/{msgId}
  - text, imageUrl, senderRole ('victim' | 'staff'), timestamp

/tracking/{requestId}
  - user: { lat, lng }
  - helper: { lat, lng }
  - status: 'emergency' | 'help_on_the_way' | 'resolved' | 'cancelled'
  - eta, userId, timestamp
```

---

## 🔄 Real-Time Flow

```
Victim triggers SOS
    → Firestore /tracking doc created (status: 'emergency')
Admin opens "Track User Location"
    → AdminMapTrackingScreen subscribes to doc
    → Renders victim's GPS coords on map (NOT admin's location)
Admin clicks "Dispatch Response"
    → Updates helper coords + status: 'help_on_the_way'
Victim's MapTrackingScreen updates automatically via Firestore stream
Admin clicks "Mark Resolved"
    → Status → 'resolved' → victim sees dialog: "Help Arrived"
```

---

## 🛠️ Tech Stack

- **Flutter** (cross-platform mobile)
- **Firebase Auth** — Authentication & role management
- **Firebase Firestore** — Real-time database for cases, tracking, messages
- **Firebase Storage** — Evidence file uploads
- **flutter_map + OpenStreetMap** — Map rendering (no API key required)
- **geolocator** — GPS access
- **file_picker** — Evidence file selection

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Firebase project with Firestore, Auth, and Storage enabled
- Android emulator or physical device

### Setup
```bash
# Clone the repo
git clone <repo_url>
cd SilentGuard

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Firebase Configuration
Place your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in the appropriate platform directories.

---

## 📁 Project Structure

```
lib/
├── main.dart                         # App entry & role-based routing
├── screens/
│   ├── landing_page.dart             # Welcome screen
│   ├── login_page.dart               # Login
│   ├── sign_up_page.dart             # Registration
│   ├── home_screen.dart              # Victim home (SOS, quick actions)
│   ├── map_tracking_screen.dart      # Victim's SOS tracking view
│   ├── case_history.dart             # Victim's case list + details (live)
│   ├── case_screens.dart             # Case chat, message bubbles
│   ├── archive_screen.dart           # Evidence archive
│   ├── upload_evidence_screen.dart   # Upload evidence
│   ├── record_evidence_screen.dart   # Record audio/video evidence
│   ├── call_screen.dart              # Emergency call
│   ├── contacts_screen.dart          # Message contacts
│   ├── chat_provider_screen.dart     # Provider chat
│   ├── profile.dart                  # User profile
│   ├── rep_dashboard.dart            # Admin dashboard (Renel Ghana staff)
│   ├── admin_map_tracking_screen.dart # Admin live SOS map (USER's location)
│   └── admin_case_detail_screen.dart  # Admin case management panel
├── services/
│   ├── auth_service.dart             # Firebase Auth helpers
│   ├── case_history.dart             # Case models + Firestore CRUD
│   ├── tracking_service.dart         # SOS/GPS Firestore operations
│   ├── archive_service.dart          # Evidence archive service
│   └── notification_service.dart     # Push notifications
├── widgets/
│   └── custom_bottom_nav_bar.dart    # Shared navigation bar
└── utils/
    └── ui_utils.dart                 # Shared UI helpers
```

---

## ⚠️ Known Limitations

- Map tiles rely on OpenStreetMap public tile servers (rate-limited for high usage).
- Firebase Storage requires a paid Blaze plan for production uploads; local path fallback is implemented.
- Staff accounts must be manually assigned the `rep` role in Firestore.

---

## 🤝 Partners

Built with love in Partnership with **Renel Ghana** — an NGO dedicated to combating gender-based violence in Ghana.

---

*© 2026 SilentGuard × Renel Ghana. All rights reserved.*
