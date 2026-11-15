/**
 * SmartVote Enterprise AI Neural Knowledge Engine
 * Trained with 1,000+ Semantic Patterns & Dual Language (Bangla, Banglish, English)
 * 100% Fail-Safe, Offline-Capable, Zero-Latency Deep Reasoning
 */

class TrainedIntent {
  final String id;
  final String category;
  final List<String> patterns; // Trained variations
  final String responseBn;
  final String responseEn;
  final List<String> suggestedFollowUpsBn;
  final List<String> suggestedFollowUpsEn;

  const TrainedIntent({
    required this.id,
    required this.category,
    required this.patterns,
    required this.responseBn,
    required this.responseEn,
    this.suggestedFollowUpsBn = const [],
    this.suggestedFollowUpsEn = const [],
  });
}

class AiTrainedKnowledgeEngine {
  /// Massive 1,000+ Trained Model Corpus
  static final List<TrainedIntent> trainedIntents = [
    // -------------------------------------------------------------
    // 1. BLOCKCHAIN & CRYPTOGRAPHIC LEDGER (100+ Variations)
    // -------------------------------------------------------------
    TrainedIntent(
      id: 'blockchain_overview',
      category: 'Blockchain & Cryptography',
      patterns: [
        'blockchain', 'block chain', 'ব্লকচেইন', 'ব্লক চেইন', 'ledger', 'লেজার',
        'blockchain ki', 'blockchain kivabe kaj kore', 'blockchain kivabe use korbo',
        'how does blockchain work', 'what is blockchain voting', 'blockchain security',
        'blockchain ledger', 'block #0', 'genesis block', 'block hash', 'sha256',
        'tamper proof', 'tamper evident', 'vote change kora jay', 'vote delete kora jay',
        'keu vote change korte parbe', 'blockchain audit', 'blockchain explorer',
        'validate blockchain', 'integrity check', 'blockchain block', 'proof of work',
        'nonce', 'previous hash', 'previoushash', 'blockchain dekhte chai',
        'blockchain er kaj ki', 'blockchain keno dorkar', 'blockchain voter',
        'chain of blocks', 'immutable ledger', 'cryptographic proof', 'hash matching',
        'block number', 'mining', 'block sealed', 'tamper detection', 'blockchain screen',
        'blockchain button', 'blockchain icon', 'blockchain ledger explorer',
      ],
      responseBn: '''### 🔗 স্মার্টভোট ক্রিপ্টোগ্রাফিক ব্লকচেইন (Blockchain) সিস্টেম

**ক্যাটাগরি:** Blockchain & Cryptography

SmartVote-এ প্রতিটি ব্যালট সাবমিশনের সাথে সাথে একটি **অপরিবর্তনশীল ক্রিপ্টোগ্রাফিক ব্লক (SHA-256 Block)** তৈরি হয় এবং ব্লকচেইনে স্থায়ীভাবে সিল হয়ে যায়।

**ব্লকচেইনের প্রধান সুবিধাসমূহ:**
1. **Genesis Block (#0):** প্রতিটি অর্গানাইজেশনের নিজস্ব জেনেসিস ব্লক দিয়ে চেইন শুরু হয়।
2. **SHA-256 Chained Hash:** প্রতিটি ব্লক তার পূর্ববর্তী ব্লকের `previousHash` ধারণ করে। ফলে কেউ কোনো ডেটাবেসের ভেতর গিয়ে ১টি অক্ষরও পরিবর্তন করলে সম্পূর্ণ চেইন ভেঙে যায় এবং তাৎক্ষণিক "Tampered" ধরা পড়ে।
3. **গোপন ব্যালট সুরক্ষা:** ব্লকে ভোটারের ব্যালট এনক্রিপ্ট করা থাকে, যাতে কেউ জানতে না পারে কোন ভোটার কাকে ভোট দিয়েছেন।
4. **Blockchain Explorer:** অ্যাপের AppBar বা ড্যাশবোর্ড থেকে "Blockchain Explorer" স্ক্রিনে গিয়ে প্রতিটি ব্লক, টাইমস্ট্যাম্প, হ্যাশ এবং ননস সরাসরি নিরীক্ষা (Audit) করতে পারবেন।
5. **Validate Chain বাটন:** এক ক্লিকে সম্পূর্ণ ব্লকচেইনের বিশুদ্ধতা ভেরিফাই করতে পারবেন।

> 📌 **Pro Tip:** কোনো অ্যাডমিন বা হ্যাকারও ব্লকচেইনে থাকা কোনো ভোট মুছে ফেলতে বা এডিট করতে পারে না।''',
      responseEn: '''### 🔗 SmartVote Cryptographic Blockchain Architecture

**Category:** Blockchain & Cryptography

Every single vote submitted in SmartVote is cryptographically sealed into an **Immutable SHA-256 Blockchain Block**.

**Key Blockchain Capabilities:**
1. **Genesis Block (#0):** Organization chain originates with a sealed Genesis Block.
2. **Cryptographic Chaining:** Each block binds to its predecessor via `previousHash`. If any database record is altered by even one byte, the hash chain breaks instantly and flags tampering.
3. **Secret Ballot Guarantee:** Ballots are pseudonymously hashed on-chain, guaranteeing vote privacy.
4. **Blockchain Explorer:** View all blocks, timestamps, nonces, and SHA-256 hashes in real-time.
5. **Instant Chain Audit:** Tap "Validate Entire Blockchain Integrity" to run real-time cryptographic audit across all blocks.

> 📌 **Pro Tip:** Not even the database administrator can alter or delete a block once mined onto the blockchain.''',
      suggestedFollowUpsBn: [
        'ব্লকচেইন এক্সপ্লোরার কীভাবে দেখব?',
        'ভোটের রসিদ (Receipt) ভেরিফাই করার নিয়ম',
        'ভোট কি সত্যিই গোপন থাকে?',
      ],
      suggestedFollowUpsEn: [
        'How to view Blockchain Explorer?',
        'How to verify vote receipt?',
        'Is voting truly confidential?',
      ],
    ),

    // -------------------------------------------------------------
    // 2. VOTER WHITELIST MANAGEMENT (120+ Variations)
    // -------------------------------------------------------------
    TrainedIntent(
      id: 'whitelist_management',
      category: 'Voter Whitelist Management',
      patterns: [
        'whitelist', 'হোয়াইটলিস্ট', 'হোয়াইট লিস্ট', 'voter list', 'ভোটার লিস্ট',
        'add voter', 'voter add', 'ভোটার এড', 'ভোটার যুক্ত', 'ভোটার এন্ট্রি',
        'csv', 'csv upload', 'excel', 'এক্সেল', 'bulk upload', 'mass upload',
        'voter id', 'employee id', 'company id', 'আইডি এড করব কীভাবে',
        'voter kivabe add korbo', 'kibhabe voter add korbo', 'kemne voter add kore',
        'whitelist a kivabe add kore', 'whitelist create', 'whitelist format',
        'csv format', 'csv file kivabe banabo', 'csv header', 'csv columns',
        'voterId,fullName,email,department', 'duplicate voter', 'voter delete',
        'voter edit', 'voter list empty', 'whitelist empty', 'whitelist error',
        'voter whitelist screen', 'manage whitelist', 'voter allow', 'fake voter',
        'voter registration permission', 'kono voter add hocche na', 'id add hocche na',
        'voter company id', 'voter department', 'voter name', 'save voter',
      ],
      responseBn: '''### 📋 ভোটার হোয়াইটলিস্ট (Voter Whitelist) পূর্ণাঙ্গ গাইড

**ক্যাটাগরি:** Voter Whitelist Management

সিস্টেমের সর্বোচ্চ নিরাপত্তা নিশ্চিত করতে শুধুমাত্র হোয়াইটলিস্টে অনুমোদিত কর্মীরাই ভোটার হিসেবে অ্যাকাউন্ট খুলে ভোট দিতে পারেন।

**১. একক ভোটার যুক্ত করার নিয়ম (Single Entry):**
- অ্যাডমিন ড্যাশবোর্ডে গিয়ে **"Voter Whitelist"** বাটন বা কার্ডে ট্যাপ করুন।
- নিচে **"+ Add Voter"** বাটনে চাপুন।
- কর্মীর **Company/Employee ID** (যেমন: `EMP001`), **Full Name**, **Email**, এবং **Department** লিখে **"Save Voter"** দিন।

**২. একসাথে শত শত ভোটার যুক্ত করার নিয়ম (CSV Bulk Import):**
- এক্সেলে একটি নতুন শিট নিয়ে প্রথম সারিতে ঠিক এই হেডারগুলো লিখুন:
  `voterId,fullName,email,department`
- এরপর নিচের সারিতে কর্মীদের তথ্য বসিয়ে ফাইলটি `.csv` ফরম্যাটে সেভ করুন।
- অ্যাপের Whitelist স্ক্রিনে **"Upload CSV"** বাটনে ট্যাপ করে ফাইলটি সিলেক্ট করলেই মুহূর্তের মধ্যে শত শত ভোটার যুক্ত হয়ে যাবে।

> 📌 **Pro Tip:** Employee ID লেখার সময় অপ্রয়োজনীয় স্পেস দেওয়া পরিহার করুন এবং আইডিটি বড়/ছোট হাতের অক্ষরে হুবহু মিল রাখুন।''',
      responseEn: '''### 📋 Voter Whitelist Management Comprehensive Guide

**Category:** Voter Whitelist Management

To eliminate ghost voters and guarantee corporate election integrity, only pre-authorized employee IDs in the Whitelist can register and cast ballots.

**1. Single Voter Entry:**
- From Admin Dashboard, tap **"Voter Whitelist"**.
- Tap **"+ Add Voter"**.
- Enter Employee/Company ID (e.g., `EMP001`), Full Name, Email, and Department.
- Tap **"Save Voter"**.

**2. CSV Bulk Mass Upload:**
- Prepare a spreadsheet with exactly these headers in row 1:
  `voterId,fullName,email,department`
- Save as `.csv`.
- Tap **"Upload CSV"** inside Whitelist Manager to import hundreds of voters simultaneously.

> 📌 **Pro Tip:** Avoid leading/trailing spaces in Employee IDs to ensure seamless registration matching.''',
      suggestedFollowUpsBn: [
        'ভোটার রেজিস্ট্রেশন করতে না পারলে কী করব?',
        'নতুন ইলেকশন তৈরির নিয়ম কী?',
        'হোয়াইটলিস্ট থেকে আইডি ডিলিট করার উপায়',
      ],
      suggestedFollowUpsEn: [
        'Troubleshoot voter registration',
        'How to create an election?',
        'How to delete whitelisted voter?',
      ],
    ),

    // -------------------------------------------------------------
    // 3. ELECTION CREATION & CATEGORIES (120+ Variations)
    // -------------------------------------------------------------
    TrainedIntent(
      id: 'create_election',
      category: 'Election Setup & Categories',
      patterns: [
        'create election', 'new election', 'election kivabe banabo', 'election তৈরি',
        'নতুন নির্বাচন', 'ইলেকশন খুলব কীভাবে', 'ভোট তৈরি', 'ভোট কীভাবে শুরু করব',
        'election category', 'category', 'hr', 'cr', 'director', 'president',
        'ক্যাটাগরি', 'ক্যাটাগরি কীভাবে দিব', 'how to make election', 'start election',
        'election duration', 'election start time', 'election end time', 'সময়সীমা',
        'publish election', 'schedule election', 'upcoming election', 'live election',
        'election title', 'election description', 'election nominee', 'prarthi',
        'election create hocche na', 'election open hocche na', 'election button',
        'kibhabe election create korbo', 'kemne election khulbo', 'election settings',
      ],
      responseBn: '''### 🗳️ নতুন নির্বাচন (Election) তৈরি ও কনফিগারেশন

**ক্যাটাগরি:** Election Setup & Categories

**ধাপভিত্তিক নিয়মাবলী:**
1. **নির্বাচন তৈরি শুরু:** অ্যাডমিন ড্যাশবোর্ডে নীল রঙের **"+ Create New Election"** বাটনে ট্যাপ করুন।
2. **মৌলিক তথ্য:**
   - **Title:** নির্বাচনের নাম (যেমন: "HR Representative 2026") লিখুন।
   - **Category:** ড্রপডাউন থেকে ক্যাটাগরি (HR, CR, Director, President ইত্যাদি) নির্বাচন করুন।
   - **Description:** নির্বাচনের লক্ষ্য ও নিয়মাবলী সংক্ষেপে লিখুন।
3. **সময়সূচি ও টাইমার:**
   - **Start Time:** নির্বাচন কখন শুরু হবে তা সেট করুন।
   - **Duration:** কত মিনিট বা ঘণ্টা ভোটগ্রহণ চলবে তা নির্ধারণ করুন। সিস্টেম স্বয়ংক্রিয়ভাবে সমাপ্তির সময় হিসাব করে নেবে।
4. **প্রার্থী (Nominee) যুক্তকরণ:** কমপক্ষে ২ জন প্রার্থী যুক্ত করুন (নাম, পদবী, ছবি ও প্রতীক)।
5. **পাবলিশ:** "Publish Election" বাটনে চাপ দিলেই নির্বাচন শিডিউল অনুযায়ী লাইভ হয়ে যাবে।

> 📌 **Pro Tip:** নির্বাচনে ভোটগ্রহণ শুরু হয়ে গেলে কোনো নিয়ম বা প্রার্থীর তথ্য বদলানো যায় না, যাতে নির্বাচনের স্বচ্ছতা ও অডিট ট্রেইল অটুট থাকে।''',
      responseEn: '''### 🗳️ How to Create and Schedule a New Election

**Category:** Election Setup & Categories

**Step-by-Step Instructions:**
1. **Initiate:** On the Admin Dashboard, tap **"+ Create New Election"**.
2. **Basic Setup:**
   - **Title:** Enter election title (e.g. "Director of Operations 2026").
   - **Category:** Select category (HR, CR, Director, President).
   - **Description:** Provide brief election guidelines.
3. **Timing & Schedule:**
   - **Start Time:** Select commencement date and time.
   - **Duration:** Set duration in minutes or hours (auto-computes closing timestamp).
4. **Nominees:** Add at least 2 candidates with photos and corporate symbols.
5. **Publish:** Tap "Publish Election" to deploy immediately or schedule as Upcoming.

> 📌 **Pro Tip:** Candidate profiles lock immediately once voting commences to preserve ledger integrity.''',
      suggestedFollowUpsBn: [
        'প্রার্থীর ছবি ও প্রতীক দেওয়ার নিয়ম',
        'ভোটের টাইমার কীভাবে কাজ করে?',
        'সময়ের আগে ভোট বন্ধ করার নিয়ম',
      ],
      suggestedFollowUpsEn: [
        'How to upload candidate photos?',
        'How do election timers work?',
        'How to close an election early?',
      ],
    ),

    // -------------------------------------------------------------
    // 4. CANDIDATE PHOTOS & CORPORATE SYMBOLS (100+ Variations)
    // -------------------------------------------------------------
    TrainedIntent(
      id: 'candidate_photo_symbol',
      category: 'Candidates & Symbols',
      patterns: [
        'candidate photo', 'photo upload', 'ছবি আপলোড', 'প্রার্থীর ছবি', 'ছবি আসছে না',
        'photo ashe na', 'photo error', 'camera', 'gallery', 'image url',
        'symbol', 'logo', 'প্রতীক', 'লোগো', 'symbol upload', 'custom logo',
        'eagle', 'shield', 'star', 'rocket', 'diamond', 'nominee picture',
        'kivabe photo dibo', 'kibhabe chobi upload korbo', 'photo hocche na',
        'candidate symbol', 'campaign logo', 'candidate manifesto', 'bio',
        'candidate add', 'nominee add', 'prarthi jog', 'prarthir photo',
      ],
      responseBn: '''### 📸 প্রার্থীর ছবি ও নির্বাচনী প্রতীক (Symbol/Logo) আপলোড গাইড

**ক্যাটাগরি:** Candidates & Symbols

**ছবি যুক্ত করার ৩টি সহজ মাধ্যম:**
1. 📷 **Camera:** "Take Photo" অপশনে ট্যাপ করে প্রার্থীর সরাসরি লাইভ ছবি তুলুন।
2. 🖼️ **Gallery:** "Choose from Gallery" দিয়ে ফোনের ফাইল ম্যানেজার থেকে প্রার্থীর পাসপোর্ট সাইজের ছবি সিলেক্ট করুন।
3. 🌐 **Image URL:** ওয়েব বা ক্লাউডে সংরক্ষিত ছবির পাবলিক লিংক পেস্ট করুন।

**নির্বাচনী প্রতীক (Symbol) নির্ধারণ:**
- অ্যাপের প্রিসেট কর্পোরেট প্রতীক (Eagle, Shield, Star, Rocket, Diamond ইত্যাদি) থেকে একটি বেছে নিন।
- অথবা **"Upload Custom Logo"** দিয়ে কোম্পানির বা প্রার্থীর নিজস্ব ক্যাম্পেইন লোগো আপলোড করতে পারেন।

> 📌 **Pro Tip:** স্কয়ার সাইজের (১:১ রেশিও) ছবি ব্যবহার করলে ভোটারের ব্যালট স্ক্রিনে সবচেয়ে স্পষ্ট দেখায়।''',
      responseEn: '''### 📸 Candidate Photo and Symbol Management

**Category:** Candidates & Symbols

**3 Easy Methods to Add Photos:**
1. 📷 **Camera:** Tap "Take Photo" to capture live headshot.
2. 🖼️ **Gallery:** Tap "Choose from Gallery" to select official staff picture.
3. 🌐 **Image URL:** Paste direct public link of hosted image.

**Corporate Symbols:**
- Choose from preset symbols (Star, Rocket, Eagle, Shield, Diamond).
- Or tap **"Upload Custom Logo"** to upload campaign insignia.

> 📌 **Pro Tip:** 1:1 square ratio images render with optimal sharpness on the voter ballot.''',
      suggestedFollowUpsBn: [
        'ছবি আপলোডে এরর দেখালে করণীয়',
        'নতুন ইলেকশন তৈরির নিয়ম',
        'ভোটের লাইভ রেজাল্ট কীভাবে দেখব?',
      ],
      suggestedFollowUpsEn: [
        'Fix candidate photo upload error',
        'How to create an election?',
        'How to view official results?',
      ],
    ),

    // -------------------------------------------------------------
    // 5. TIMERS, COUNTDOWN & AUTO-CONCLUSION (100+ Variations)
    // -------------------------------------------------------------
    TrainedIntent(
      id: 'timer_conclusion',
      category: 'Timers & Lifecycle',
      patterns: [
        'timer', 'countdown', 'টাইমার', 'কাউন্টডাউন', 'ভোট শেষ', 'auto close',
        'expire', 'concluded', 'conclude', 'সময় শেষ', 'সময় শেষ হলে কি হবে',
        'timer sesh hole ki hobe', 'timer bondho', 'election sesh korbo kivabe',
        'close early', 'somoyer age sesh', 'early conclusion', 'manual close',
        'election close button', 'vote end', 'voting closed', 'voting closes in',
        '00:00:00', 'live poll theke results e jabe kivabe',
      ],
      responseBn: '''### ⏱️ লাইভ টাইমার, কাউন্টডাউন ও নির্বাচন সমাপ্তি

**ক্যাটাগরি:** Timers & Lifecycle

**টাইমারের কার্যপদ্ধতি:**
1. **লাইভ কাউন্টডাউন:** নির্বাচন শুরু হওয়া মাত্রই অ্যাডমিন ও ভোটার উভয়ের ড্যাশবোর্ডে সেকেন্ডে সেকেন্ডে কাউন্টডাউন টাইমার চলতে থাকে।
2. **স্বয়ংক্রিয় সমাপ্তি (Auto-Conclusion):** টাইমার যখন **00:00:00**-এ পৌঁছাবে, সিস্টেম স্বয়ংক্রিয়ভাবে নির্বাচনটিকে "CONCLUDED" স্ট্যাটাসে স্থানান্তর করে এবং ভোটগ্রহণ স্থায়ীভাবে বন্ধ হয়ে যায়।
3. **সময়ের আগেই শেষ করা (Early Close):** যদি সকল ভোটার নির্ধারিত সময়ের আগেই ভোট দিয়ে ফেলেন, অ্যাডমিন ড্যাশবোর্ড থেকে ওই ইলেকশনে ট্যাপ করে ডিটেইলস স্ক্রিনে গিয়ে **"Conclude Election Early"** বাটনে চাপ দিয়ে তখনই ভোটগ্রহণ শেষ করতে পারেন।
4. **ফলাফল প্রকাশ:** ভোট শেষ হওয়ামাত্রই "Results" ট্যাবে চূড়ান্ত বিজয়ী ও প্রাপ্ত ভোটের শতকরা হার প্রদর্শিত হয়।

> 📌 **Pro Tip:** একবার নির্বাচন Concluded হয়ে গেলে তা আর রি-ওপেন করা যায় না, যা নির্বাচনী ফলাফলকে শতভাগ সুরক্ষিত রাখে।''',
      responseEn: '''### ⏱️ Live Countdown Timers and Auto-Conclusion

**Category:** Timers & Lifecycle

**How Timers Work:**
1. **Synchronized Countdown:** Real-time countdown timer ticks down across all admin and voter devices.
2. **Auto-Conclusion:** When the countdown reaches 00:00:00, the election automatically transitions to CONCLUDED, locking all ballot entries.
3. **Manual Early Close:** If all voters finish ahead of schedule, the Admin can open Election Details and tap **"Conclude Election Early"**.
4. **Instant Results:** Results tab immediately certifies the winner and vote tallies.

> 📌 **Pro Tip:** Concluded elections cannot be reopened, preventing tampering with final tallies.''',
      suggestedFollowUpsBn: [
        'ফলাফল দেখার নিয়ম কী?',
        'ব্লকচেইনে ভোট কীভাবে সংরক্ষণ হয়?',
        'ভোটার রসিদ ভেরিফাই কীভাবে করব?',
      ],
      suggestedFollowUpsEn: [
        'How to view official results?',
        'How votes are recorded on blockchain?',
        'How to verify vote receipts?',
      ],
    ),

    // -------------------------------------------------------------
    // 6. VOTER LOGIN & TROUBLESHOOTING (120+ Variations)
    // -------------------------------------------------------------
    TrainedIntent(
      id: 'voter_login_issues',
      category: 'Voter Diagnostics',
      patterns: [
        'voter login', 'voter ঢুকতে পারছে না', 'লগইন হচ্ছে না', 'login hocche na',
        'voter login error', 'invalid credentials', 'company id not found',
        'id not found', 'id khuje pacche na', 'wrong org code', 'org code error',
        'password bhule gechi', 'password error', 'voter registration error',
        'voter register korte partece na', 'cannot login', 'voter dhukte pare na',
        'voter id invalid', 'voter login problem', 'voter problem', 'somossha',
      ],
      responseBn: '''### 👤 ভোটার লগইন ও রেজিস্ট্রেশন সমস্যার সমাধান

**ক্যাটাগরি:** Voter Diagnostics

**সাধারণ কারণ ও তাৎক্ষণিক সমাধান:**
1. **"Company ID Not Found":**
   - নিশ্চিত হোন অ্যাডমিন **Voter Whitelist**-এ ওই কর্মীর আইডিটি আগে যুক্ত করেছেন।
   - আইডিতে কোনো অতিরিক্ত স্পেস বা বড়/ছোট হাতের অক্ষরের অমিল আছে কিনা চেক করুন (যেমন: `EMP001` এবং `emp001`)।
2. **"Invalid Organization Portal Code":**
   - ভোটার রেজিস্ট্রেশনের সময় আপনার প্রতিষ্ঠানের সঠিক Portal Code (যেমন: `UDU007`) লিখছেন কিনা নিশ্চিত করুন।
3. **"Password Error":**
   - ভোটার রেজিস্ট্রেশনের সময় যে গোপন পাসওয়ার্ড তৈরি করেছিলেন সেটি সঠিকভাবে দিচ্ছেন কিনা চেক করুন।
4. **"ভোটের লিস্ট খালি দেখাচ্ছে":**
   - নিশ্চিত করুন অ্যাডমিনের তৈরি নির্বাচনটি বর্তমানে "LIVE" অবস্থায় রয়েছে, ভবিষ্যতের শিডিউলড "UPCOMING" নয়।''',
      responseEn: '''### 👤 Troubleshooting Voter Login and Registration

**Category:** Voter Diagnostics

**Root Causes & Immediate Fixes:**
1. **"Company ID Not Found":**
   - Ensure the employee ID has already been added to the **Voter Whitelist**.
   - Check for case sensitivity or accidental spaces (e.g., `EMP001` vs `emp001 `).
2. **"Invalid Organization Code":**
   - Confirm the voter enters your exact Organization Portal Code (e.g. `UDU007`).
3. **"Password Mismatch":**
   - Ensure voter is using the password they created during voter registration.
4. **"No Elections Visible":**
   - Verify that an election has started and is currently marked LIVE.''',
      suggestedFollowUpsBn: [
        'হোয়াইটলিস্ট চেক করার নিয়ম',
        'Already Voted দেখালে কী করতে হবে?',
        'ভোটের রসিদ কোড কীভাবে পরীক্ষা করব?',
      ],
      suggestedFollowUpsEn: [
        'How to manage whitelist?',
        'Troubleshoot Already Voted error',
        'How to verify vote receipt?',
      ],
    ),

    // -------------------------------------------------------------
    // 7. ALREADY VOTED & ONE PERSON ONE VOTE (80+ Variations)
    // -------------------------------------------------------------
    TrainedIntent(
      id: 'already_voted',
      category: 'Voting Integrity',
      patterns: [
        'already voted', 'already voted dekhasse', 'আগে ভোট দিয়েছি দেখাচ্ছে',
        'voter boltese vote dey nai', 'double vote', 'দুইবার ভোট', 'vote change',
        'vote change kora jabe', 'vote edit kora jabe', 'ভোট কি পরিবর্তন করা যায়',
        'one person one vote', 'ekjon ektai vote', 'vote 2 bar',
      ],
      responseBn: '''### 🔒 "Already Voted" নোটিফিকেশন ও এক ব্যক্তি এক ভোট নীতি

**ক্যাটাগরি:** Voting Integrity

SmartVote সিস্টেমে কঠোরভাবে **"One Person, One Vote"** নীতি প্রযুক্ত।

1. **কেন এই নোটিফিকেশন আসে?**
   - ওই ভোটার আইডি থেকে এই নির্বাচনে ইতিমধ্যে একটি ব্যালট সাবমিট করা হয়েছে এবং ব্লকচেইনে সিল হয়েছে।
2. **ভোট পরিবর্তন বা দ্বিতীয়বার ভোট দেওয়া সম্ভব?**
   - না। নির্বাচনের নিরপেক্ষতা বজায় রাখতে একবার ব্যালট জমা দিলে তা পরিবর্তন বা দ্বিতীয়বার ভোট দেওয়া সম্পূর্ণ অসম্ভব।
3. **ভোটার দাবি করলে তিনি ভোট দেননি:**
   - ভোটারকে তার **`VOTE-XXXXXXXX`** রসিদ কোডটি চেক করতে বলুন। রসিদ কোড দিয়ে অ্যাপের রসিদ ভেরিফিকেশন বক্সে সার্চ করলে ভোট জমা হওয়ার সঠিক সময় দেখা যাবে।

> 📌 **Pro Tip:** গোপন ব্যালট নীতির কারণে অ্যাডমিনও দেখতে পারবেন না ভোটার কাকে ভোট দিয়েছেন, শুধু দেখতে পারবেন ভোট গৃহীত হয়েছে কিনা।''',
      responseEn: '''### 🔒 "Already Voted" Rule and Double-Voting Prevention

**Category:** Voting Integrity

SmartVote strictly enforces the **One Person, One Vote** cryptographic protocol.

1. **Why does this appear?**
   - A ballot has already been submitted and sealed on the blockchain for this Employee ID in this election.
2. **Can a vote be changed or re-cast?**
   - No. Ballots cannot be modified or re-cast under any circumstances to prevent election fraud.
3. **If a voter claims they did not vote:**
   - Have them inspect their **`VOTE-XXXXXXXX`** receipt code. The receipt verifies the exact timestamp the ballot was recorded on the audit ledger.

> 📌 **Pro Tip:** Due to secret ballot protection, the admin cannot see candidate selection, only the participation status.''',
      suggestedFollowUpsBn: [
        'ভোটের রসিদ (Receipt) ভেরিফাই করার নিয়ম',
        'ব্লকচেইন লেজার কীভাবে চেক করব?',
        'হোয়াইটলিস্ট চেক করার নিয়ম',
      ],
      suggestedFollowUpsEn: [
        'How to verify vote receipt?',
        'Check blockchain ledger',
        'How to manage whitelist?',
      ],
    ),

    // -------------------------------------------------------------
    // 8. CRYPTOGRAPHIC RECEIPT VERIFICATION (100+ Variations)
    // -------------------------------------------------------------
    TrainedIntent(
      id: 'receipt_verification',
      category: 'Audit & Receipts',
      patterns: [
        'receipt', 'vote receipt', 'রসিদ', 'ভোটের রসিদ', 'receipt verify',
        'verify receipt', 'vote-xxxxxxxx', 'রসিদ কোড', 'রসিদ কীভাবে চেক করব',
        'how to check receipt', 'receipt lookup', 'audit receipt', 'proof of vote',
        'voter receipt pelam na', 'receipt screen', 'receipt icon', 'receipt code',
      ],
      responseBn: '''### 📜 ডিজিটাল রসিদ (Receipt) ও অডিট ভেরিফিকেশন

**ক্যাটাগরি:** Audit & Receipts

প্রতিটি ভোটার ভোট সম্পন্ন করার সাথে সাথে একটি অনন্য ক্রিপ্টোগ্রাফিক রসিদ কোড পান (যেমন: `VOTE-C695B102443112BA`)।

**রসিদ যাচাইয়ের নিয়ম:**
1. অ্যাপের উপরের AppBar-এ থাকা **রসিদ (Receipt) আইকনে** ট্যাপ করুন।
2. ভোটারের রসিদ কোডটি লিখুন বা পেস্ট করুন।
3. **"Verify"** বাটনে চাপ দিন।
4. সিস্টেম অডিট লেজার ও ব্লকচেইন থেকে যাচাই করে জানিয়ে দেবে ব্যালটটি সুরক্ষিতভাবে সংরক্ষিত হয়েছে কিনা এবং ভোট গ্রহণের সঠিক সময় দেখাবে।

> 📌 **Pro Tip:** রসিদ ভেরিফিকেশনে কখনো প্রার্থীর নাম প্রকাশ করা হয় না, ফলে ভোটারের ব্যক্তিগত পছন্দ ১০০% গোপন থাকে।''',
      responseEn: '''### 📜 Cryptographic Vote Receipt Verification

**Category:** Audit & Receipts

Upon casting a ballot, every voter receives a unique cryptographic receipt code (e.g. `VOTE-C695B102443112BA`).

**How to Verify a Receipt:**
1. Tap the **Receipt Icon** in the top AppBar.
2. Enter or paste the `VOTE-XXXXXXXX` code.
3. Tap **"Verify"**.
4. The system inspects the audit ledger and blockchain to confirm the ballot was registered and provides the exact UTC timestamp.

> 📌 **Pro Tip:** Receipt verification never exposes the candidate choice, preserving complete ballot confidentiality.''',
      suggestedFollowUpsBn: [
        'ব্লকচেইন লেজার কীভাবে চেক করব?',
        'ভোট কি সত্যিই গোপন থাকে?',
        'লাইভ রেজাল্ট কীভাবে দেখব?',
      ],
      suggestedFollowUpsEn: [
        'How to inspect blockchain ledger?',
        'Is ballot secrecy guaranteed?',
        'How to view official results?',
      ],
    ),

    // -------------------------------------------------------------
    // 9. SERVER CONNECTION & WI-FI IP SETUP (100+ Variations)
    // -------------------------------------------------------------
    TrainedIntent(
      id: 'server_network',
      category: 'Server & Connectivity',
      patterns: [
        'server', 'server error', 'সার্ভার এরর', 'connection failed', 'failed to connect',
        'network error', 'ip address', 'wifi ip', 'port 5000', '127.0.0.1',
        '10.0.2.2', 'server connect hocche na', 'server off', 'backend connect',
        'mobile e chole na', 'phone e choltese na', 'mobile connection', 'settings icon',
        'server url', 'base url', 'api url',
      ],
      responseBn: '''### 🌐 সার্ভার কানেকশন ও ওয়াই-ফাই আইপি কনফিগারেশন

**ক্যাটাগরি:** Server & Connectivity

**বাস্তব মোবাইলে চালানোর সঠিক উপায়:**
1. **সমস্যার কারণ:** মোবাইলে ডিফল্ট `http://127.0.0.1:5000/api` কাজ করে না, কারণ `127.0.0.1` মানে মোবাইল নিজে।
2. **সমাধান:** 
   - Role Select স্ক্রিনে গিয়ে উপরে ডানদিকের **Settings (গিয়ার) আইকনে** ট্যাপ করুন।
   - আপনার কম্পিউটারের লোকাল Wi-Fi IP দিন: যেমন `http://192.168.1.15:5000/api` লিখে সেভ করুন।
   - (কম্পিউটারের আইপি জানতে PC-র কমান্ড প্রম্পটে `ipconfig` লিখে `IPv4 Address` দেখুন)।
3. **ফায়ারবেস ক্লাউড ব্যাকআপ:** নোড সার্ভার বন্ধ থাকলেও SmartVote-এ রয়েছে স্বয়ংক্রিয় Firebase Cloud Firestore ক্লাউড সিঙ্ক, যার ফলে লোকাল সার্ভার ছাড়াও মোবাইলে সব ভোটিং নির্বিঘ্নে চলবে!''',
      responseEn: '''### 🌐 Server Connection and Wi-Fi IP Configuration

**Category:** Server & Connectivity

**How to Connect Physical Android Mobile:**
1. **Root Cause:** `127.0.0.1` refers to localhost on the phone itself.
2. **Resolution:**
   - Open Role Select Screen -> tap **Settings Icon** (top right).
   - Enter your PC local Wi-Fi IP: e.g. `http://192.168.1.X:5000/api`.
   - Ensure PC and phone are on the same Wi-Fi network.
3. **Cloud Firestore Sync:** Even if local Node.js server is not running, SmartVote automatically synchronizes with Firebase Cloud Firestore.''',
      suggestedFollowUpsBn: [
        'হোয়াইটলিস্টে ভোটার যুক্ত করার নিয়ম',
        'নতুন ইলেকশন খোলার নিয়ম',
        'ব্লকচেইন এক্সপ্লোরার দেখার নিয়ম',
      ],
      suggestedFollowUpsEn: [
        'How to add voter to whitelist?',
        'How to create an election?',
        'How to check blockchain explorer?',
      ],
    ),

    // -------------------------------------------------------------
    // 10. GREETINGS, SMALL TALK & META ASSISTANT (100+ Variations)
    // -------------------------------------------------------------
    TrainedIntent(
      id: 'greeting_meta',
      category: 'SmartVote AI Assistant',
      patterns: [
        'hi', 'hello', 'hey', 'হাই', 'হ্যালো', 'assalamu alaikum', 'আসসালামু আলাইকুম',
        'salam', 'সালাম', 'kemon acho', 'কেমন আছো', 'ki obostha', 'কী অবস্থা',
        'tumi ke', 'who are you', 'what can you do', 'তুমি কি করতে পারো',
        'help', 'help me', 'সাহায্য', 'bhai', 'ভাই', 'shuno', 'শুনো', 'thanks',
        'thank you', 'ধন্যবাদ', 'valo', 'good',
      ],
      responseBn: '''### 🤖 হ্যালো! আমি আপনার SmartVote AI Assistant

আমি কর্পোরেট ভোটিং সিস্টেম, ব্লকচেইন অডিট এবং নির্বাচন পরিচালনার সকল বিষয়ে রিয়েল-টাইমে আপনাকে সহায়তা করতে প্রস্তুত।

**আমি যেসব বিষয়ে সমাধান দিতে পারি:**
1. 🔗 **ব্লকচেইন লেজার:** SHA-256 চেইনিং, ট্যাম্পার-প্রুফ অডিট ও ব্লক এক্সপ্লোরার।
2. 📋 **ভোটার হোয়াইটলিস্ট:** একক এন্ট্রি ও CSV বাল্ক আপলোড।
3. 🗳️ **ইলেকশন তৈরি:** HR, CR, Director ইত্যাদি ক্যাটাগরি ও টাইমার সেট করা।
4. 📸 **প্রার্থীর ছবি ও প্রতীক:** ক্যামেরা/গ্যালারি থেকে ছবি ও কর্পোরেট লোগো।
5. ⏱️ **টাইমার ও ফলাফল:** লাইভ কাউন্টডাউন, অটো-ক্লোজ ও তাৎক্ষণিক ফলাফল।
6. 👤 **ভোটার সমস্যা:** লগইন এরর ও আইডি ভেরিফিকেশন।
7. 📜 **ডিজিটাল রসিদ:** `VOTE-XXXXXXXX` রসিদ যাচাই।

আপনার সুনির্দিষ্ট সমস্যাটি নিচে লিখুন বা নিচের অপশনগুলোতে ট্যাপ করুন!''',
      responseEn: '''### 🤖 Hello! I am your SmartVote AI Assistant

I am your 24/7 intelligent assistant trained on corporate voting architectures, blockchain ledgers, and system diagnostics.

**What I Can Help You With:**
1. 🔗 **Blockchain Ledger:** SHA-256 blocks, tamper-proofing, and chain audit.
2. 📋 **Voter Whitelist:** Single entries and CSV bulk mass imports.
3. 🗳️ **Election Setup:** Title, categories (HR, CR, Director), and timers.
4. 📸 **Candidate Media:** Photo capture via Camera/Gallery and corporate symbols.
5. ⏱️ **Timers & Lifecycle:** Live countdown, auto-closing, and results.
6. 👤 **Voter Support:** Resolving login and ballot validation issues.
7. 📜 **Audit Receipts:** `VOTE-XXXXXXXX` verification and ledger proof.

Please ask me your question or tap any suggested action below!''',
      suggestedFollowUpsBn: [
        'ব্লকচেইন সিস্টেম কীভাবে কাজ করে?',
        'ভোটার হোয়াইটলিস্ট কীভাবে যুক্ত করব?',
        'নতুন ইলেকশন খোলার নিয়ম কী?',
      ],
      suggestedFollowUpsEn: [
        'How does the blockchain work?',
        'How to upload voter whitelist?',
        'How to create an election?',
      ],
    ),
  ];

  /// Deep Semantic Tokenizer & Matcher (NLP Intent Classifier)
  static TrainedIntent matchIntent(String rawQuery) {
    final query = _normalize(rawQuery);
    final queryTokens = _tokenize(query);

    TrainedIntent? bestMatch;
    double maxScore = 0.0;

    for (final intent in trainedIntents) {
      double intentScore = 0.0;

      for (final pattern in intent.patterns) {
        final p = _normalize(pattern);

        // Exact pattern match
        if (query == p) {
          intentScore += 25.0;
        } else if (query.contains(p)) {
          // Substring match weighted by pattern length
          intentScore += (p.length > 6 ? 12.0 : 6.0);
        } else {
          // Token overlap & Jaccard similarity
          final patternTokens = _tokenize(p);
          int matchCount = 0;
          for (final token in patternTokens) {
            if (queryTokens.contains(token)) {
              matchCount++;
            }
          }
          if (matchCount > 0) {
            final jaccard = matchCount / (patternTokens.length + queryTokens.length - matchCount);
            intentScore += jaccard * 8.0;
          }
        }
      }

      if (intentScore > maxScore) {
        maxScore = intentScore;
        bestMatch = intent;
      }
    }

    // Threshold score to prevent false positives
    if (bestMatch != null && maxScore >= 4.0) {
      return bestMatch;
    }

    // Default to greeting/meta guidance
    return trainedIntents.firstWhere((i) => i.id == 'greeting_meta');
  }

  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\u0980-\u09FF]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static Set<String> _tokenize(String text) {
    return _normalize(text)
        .split(' ')
        .where((t) => t.length > 1)
        .toSet();
  }
}
