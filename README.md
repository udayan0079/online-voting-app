# SmartVote Corporate — Enterprise Multi-Tenant Online Voting System

A fully-featured, secure, and production-ready Corporate Online Voting Mobile App with a strong Node.js + Express + MongoDB backend and Flutter frontend.

---

## 🌟 Key Architecture & Business Features

### 1. Multi-Tenant Data Isolation (Dhaka vs Jamalpur Isolation)
* Every organization registers with its own unique `Organization Code` (e.g. `DHAKA-CORP`, `JAMALPUR-01`).
* **Zero Data Leakage:** Database models for Whitelist, Elections, Ballots, and Audited Votes are strictly indexed and partitioned by `orgId`.
* An admin or voter in Dhaka can never view, access, or interfere with election data in Jamalpur or any other company.
* Data is stored persistently for a lifetime until the organization admin explicitly chooses to delete it.

### 2. Strict Whitelisting & Fraud Prevention (No Outsiders Allowed)
* **Pre-Authorization Requirement:** Before anyone can register as a voter, the organization admin must whitelist their Company/Employee ID (e.g. `EMP-101`, `EMP-102`, `CR-2024`).
* **Two-Step Onboarding:**
  1. Voter enters Organization Code + Company ID and taps **Verify My ID**.
  2. If the ID is not in the organization's whitelist, registration is **immediately rejected**.
  3. If already registered, duplicate registration is blocked.
  4. Only pre-authorized IDs can create an account and vote.

### 3. Dynamic Election Positions & Customization
* Admin can create elections for **any category or designation**:
  * Corporate: `HR Representative`, `Department Head`, `Board of Directors`
  * Academic: `Class Representative (CR)`, `Batch Coordinator`
  * Public/Civic: `President`, `Prime Minister`, `Member of Parliament (MP)`, `Club Leader`
* Candidates include:
  * Full Name & Company/Employee ID
  * Symbol / Campaign Logo Name (e.g., *Eagle of Growth*, *Rising Sun*)
  * Biography & Manifesto / Key Agenda
* Editable later by the organization administrator.

### 4. Real-Time Vote Counting & Auto-Result Publishing
* **One Vote per Voter:** MongoDB unique compound index (`electionId` + `voterId`) guarantees voters can cast only 1 vote per election.
* **Audit Receipt Hash:** Every vote generates a tamper-evident cryptographic hash (e.g., `VOTE-E75BFA1B3E7CD8CB`) that voters can verify anytime.
* **Live Countdown Clock:** Displayed on voter and admin screens.
* **Auto-Result Publication:** Once the timer expires (`currentTime >= endTime`), the election status automatically shifts to `COMPLETED`, winner is determined, and final vote percentages are published to the portal.

---

## 🏗️ Clean Layered Architecture

### Backend (`/backend`)
```
backend/
├── config/
│   └── db.js                 # MongoDB connection handler
├── models/
│   ├── Organization.js       # Multi-tenant tenant partition
│   ├── User.js               # Admin & Voter users with bcrypt password hashing
│   ├── Whitelist.js          # Authorized employee IDs pre-registered by Admin
│   ├── Election.js           # Poll metadata, candidates, dynamic posts, schedule
│   └── Vote.js               # Immutable vote ledger with audit receipts
├── controllers/
│   ├── authController.js     # Admin & Voter auth + whitelist verification
│   ├── whitelistController.js# Single & Bulk ID import, search & deletion
│   ├── electionController.js # Create, Edit, Conclude & Delete elections
│   ├── voteController.js     # Cast ballot, receipt check, history
│   └── analyticsController.js# Turnout rate, vote counts, dashboard metrics
├── middlewares/
│   ├── authMiddleware.js     # JWT bearer token verification
│   ├── roleMiddleware.js     # Admin & Voter privilege guards
│   └── errorMiddleware.js    # Centralized JSON error handler
├── routes/                   # Clean RESTful API routing
├── test_integration.js       # 10/10 automated end-to-end integration tests
└── server.js                 # Server entry point (Port 5000)
```

### Mobile App (`/ovs`)
```
ovs/lib/
├── core/
│   ├── constants/            # Colors, App theme, API endpoints
│   ├── network/              # ApiClient with JWT injection
│   └── storage/              # SharedPreferences session manager
├── models/                   # UserModel, ElectionModel, CandidateModel, WhitelistModel
├── providers/                # AuthProvider, ElectionProvider, WhitelistProvider, VotingProvider
├── widgets/                  # CandidateTile, CountdownTimer, StatusBadge, CustomTextField, Buttons
└── screens/
    ├── splash_screen.dart
    ├── auth/                 # RoleSelectScreen, AdminLogin, AdminRegister, VoterLogin, VoterRegister
    ├── admin/                # AdminDashboard, ManageWhitelist, CreateElection, AdminElectionDetail
    └── voter/                # VoterDashboard, VoterBallotScreen, VotingSuccessScreen, ElectionResults
```

---

## 🚀 How to Run

### 1. Start the Backend
Make sure MongoDB is running on your machine (default port `27017`):
```bash
cd backend
npm install
node server.js
```
The server will start on `http://localhost:5000` with the health check available at `http://localhost:5000/api/health`.

### 2. Run Backend Integration Tests
To test all 10 corporate workflows (Tenant isolation, Whitelist check, Ballot casting, Duplicate prevention):
```bash
node backend/test_integration.js
```

### 3. Run the Mobile App (Flutter)
```bash
cd ovs
flutter pub get
# Run on Chrome Web:
flutter run -d chrome

# Or run on Android Emulator / Physical Device:
flutter run
```
*Tip: On the app's welcome screen, click the **Settings (⚙️)** icon in the top right to customize your server IP if testing over a local Wi-Fi network.*
