/**
 * SmartVote Corporate AI Assistant Controller
 * Deep Domain Reasoning & Multi-Language Real-Time Troubleshooting for Admins
 */

// Intent knowledge graph and diagnostic rules
const KNOWLEDGE_BASE = [
  {
    id: 'whitelist_guide',
    keywords: ['whitelist', 'voter list', 'add voter', 'voter entry', 'csv', 'হোয়াইটলিস্ট', 'ভোটার যোগ', 'ভোটার লিস্ট', 'ভোটার এড'],
    category: 'Voter Whitelist Management',
    en: {
      title: 'How to Manage Voter Whitelist (Single & CSV Bulk Upload)',
      steps: [
        'Navigate to Admin Dashboard and tap "Manage Voter Whitelist".',
        'Single Entry: Tap "+ Add Voter", enter Company Employee ID (e.g., EMP001), Full Name, Email, and Department. Tap "Save Voter".',
        'CSV Bulk Upload: Prepare a CSV file with columns: `voterId,fullName,email,department`. Tap "Upload CSV" to import hundreds of voters at once.',
        'Verification: Only whitelisted Employee IDs can register and cast ballots in your organization portal. This prevents fake accounts.'
      ],
      tips: 'Ensure Employee IDs contain no trailing spaces and are consistent with official company badges.',
      suggestedFollowUps: ['What if voter says ID is invalid?', 'How to delete or edit a whitelisted voter?']
    },
    bn: {
      title: 'ভোটার হোয়াইটলিস্ট তৈরি ও ডেটা এন্ট্রি করার নিয়ম (Single ও CSV)',
      steps: [
        'অ্যাডমিন ড্যাশবোর্ড থেকে "Manage Voter Whitelist" অপশনে যান।',
        'সিঙ্গেল এন্ট্রি: "+ Add Voter" বাটনে চাপুন। এরপর কর্মীর Company/Employee ID (যেমন: EMP-101), পূর্ণ নাম, ইমেইল এবং ডিপার্টমেন্ট লিখে "Save Voter" দিন।',
        'CSV বাল্ক আপলোড: এক্সেল বা টেক্সট এডিটরে `voterId,fullName,email,department` হেডার দিয়ে ফাইলটি .csv ফরম্যাটে সেভ করে "Upload CSV" বাটনে চাপ দিয়ে আপলোড করুন। একসাথে শত শত কর্মী যুক্ত হবে।',
        'নিরাপত্তা: শুধুমাত্র হোয়াইটলিস্টে থাকা আইডিগুলোই ভোটার হিসেবে রেজিস্ট্রেশন করতে পারবে। কোনো বাইরের বা ফেক আইডি সিস্টেমে ঢুকতে পারবে না।'
      ],
      tips: 'ভোটার আইডিতে অপ্রয়োজনীয় স্পেস দেওয়া থেকে বিরত থাকুন এবং আইডি বড় হাতের/ছোট হাতের অক্ষর হুবহু মিল রাখুন।',
      suggestedFollowUps: ['ভোটার লগইন করতে না পারলে কী করব?', 'হোয়াইটলিস্টের আইডি ডিলিট করার নিয়ম']
    }
  },
  {
    id: 'create_election',
    keywords: ['create election', 'new election', 'election category', 'hr', 'cr', 'ইলেকশন তৈরি', 'নতুন নির্বাচন', 'ভোট তৈরি', 'ক্যাটাগরি'],
    category: 'Election Creation & Setup',
    en: {
      title: 'How to Create and Configure a New Election',
      steps: [
        'On Admin Dashboard, tap the blue "+ Create New Election" button.',
        'Basic Details: Enter Election Title (e.g., "HR Representative 2026") and Description.',
        'Category: Select predefined category (HR, CR, Director, President) or create a custom category.',
        'Timing & Scheduling: Set start date/time and duration in minutes or hours. The system computes the closing timestamp.',
        'Add Candidates: Add at least 2 nominees with photos and corporate symbols.',
        'Launch: Tap "Publish Election". It immediately goes Live or schedules as Upcoming based on your start timer.'
      ],
      tips: 'Once voters begin submitting ballots, election rules and nominee lists cannot be altered to preserve audit ledger integrity.',
      suggestedFollowUps: ['How to upload candidate photos?', 'What happens when election timer expires?']
    },
    bn: {
      title: 'নতুন নির্বাচন (Election) তৈরি ও কনফিগার করার নিয়ম',
      steps: [
        'অ্যাডমিন ড্যাশবোর্ডে গিয়ে নীল রঙের "+ Create New Election" বাটনে ট্যাপ করুন।',
        'মৌলিক তথ্য: নির্বাচনের শিরোনাম (Title যেমন: "HR Election 2026") এবং বিস্তারিত বিবরণ লিখুন।',
        'ক্যাটাগরি নির্ধারণ: ড্রপডাউন থেকে ক্যাটাগরি (HR, CR, Director, ইত্যাদি) নির্বাচন করুন।',
        'টাইমার ও সময়সীমা: নির্বাচন শুরুর সময় এবং কত ঘণ্টা/মিনিট চলবে (Duration) তা সেট করুন। সিস্টেম স্বয়ংক্রিয়ভাবে সমাপ্তির সময় হিসাব করে নেবে।',
        'প্রার্থী যুক্তকরণ: কমপক্ষে ২ জন প্রার্থী যুক্ত করুন, তাদের ছবি এবং নির্বাচনী প্রতীক দিন।',
        'পাবলিশ: "Publish Election" বাটনে চাপ দিলেই নির্বাচন লাইভ হয়ে যাবে অথবা নির্ধারিত সময়ে স্বয়ংক্রিয়ভাবে চালু হবে।'
      ],
      tips: 'একবার ভোট গ্রহণ শুরু হয়ে গেলে কোনো নিয়ম বা প্রার্থী পরিবর্তন করা যায় না, যাতে নির্বাচনের স্বচ্ছতা ও অডিট লেজার সুরক্ষিত থাকে।',
      suggestedFollowUps: ['প্রার্থীর ছবি আপলোড করার উপায়', 'ভোটের টাইমার শেষ হলে কী হবে?']
    }
  },
  {
    id: 'candidate_photo_symbol',
    keywords: ['candidate photo', 'nominee', 'symbol', 'logo', 'camera', 'gallery', 'ছবি আপলোড', 'প্রতীকের লোগো', 'প্রার্থী', 'ফটো'],
    category: 'Candidates & Symbols',
    en: {
      title: 'Candidate Photo & Corporate Symbol Management',
      steps: [
        'Inside Election Creation: Tap "Add Candidate".',
        'Enter Candidate Full Name, Department, and Election Manifesto/Slogan.',
        'Nominee Photo: You have 3 convenient ways: (1) Camera to take an instant headshot, (2) Gallery to pick an official company photo, or (3) Image URL for remote hosting.',
        'Corporate Symbol: Choose from standard corporate badges (Eagle, Shield, Star, Rocket, Diamond) or tap "Upload Custom Logo" to use your own corporate mark.',
        'Review and repeat for all competing nominees before saving the election.'
      ],
      tips: 'Square photos (1:1 ratio) with good lighting give candidates the most professional appearance on the voter ballot.',
      suggestedFollowUps: ['Candidate photo not uploading fix', 'How to create an election?']
    },
    bn: {
      title: 'প্রার্থীর ছবি এবং নির্বাচনী প্রতীক (Symbol/Logo) সেট করার নিয়ম',
      steps: [
        'নির্বাচন তৈরির স্ক্রিনে "Add Candidate" বাটনে ক্লিক করুন।',
        'প্রার্থীর নাম, ডিপার্টমেন্ট এবং নির্বাচনী ইশতেহার/স্লোগান লিখুন।',
        'প্রার্থীর ছবি: ৩টি উপায়ে ছবি দেওয়া যায়— (১) Camera দিয়ে সরাসরি লাইভ ছবি তোলা, (২) মোবাইল Gallery থেকে ছবি সিলেক্ট করা, অথবা (৩) ছবির Image URL দেওয়া।',
        'নির্বাচনী প্রতীক (Symbol): লিস্টে থাকা প্রতীক (যেমন: ঈগল, স্টার, শিল্ড, রকেট) নির্বাচন করতে পারেন অথবা "Upload Custom Logo" দিয়ে নিজস্ব ব্যানার/লোগো ব্যবহার করতে পারেন।',
        'সব প্রার্থীদের এন্ট্রি সম্পন্ন করে ইলেকশন সেভ করুন।'
      ],
      tips: 'স্কয়ার সাইজের (১:১) পরিষ্কার ছবি ব্যবহার করলে ভোটারের ব্যালট পেপারে সবচেয়ে স্পষ্ট ও আকর্ষণীয় দেখাবে।',
      suggestedFollowUps: ['ছবি আপলোডে এরর দেখালে কী করব?', 'ইলেকশন কীভাবে শুরু করব?']
    }
  },
  {
    id: 'timer_and_conclusion',
    keywords: ['timer', 'countdown', 'concluded', 'close election', 'expire', 'auto close', 'টাইমার', 'কাউন্টডাউন', 'ভোট শেষ', 'সমাপ্তি'],
    category: 'Timers & Automatic Conclusion',
    en: {
      title: 'Election Timers, Live Countdown & Auto-Conclusion',
      steps: [
        'How it works: When an election is Live, a synchronized countdown timer ticks down across all admin and voter devices.',
        'Auto-Conclusion: Once the countdown reaches 00:00:00, the system automatically marks the election as CONCLUDED.',
        'Voting Lock: Immediately upon conclusion, no voter can submit new ballots. All pending votes are sealed.',
        'Manual Early Close: If all whitelisted voters have finished voting before timer expiry, the Admin can tap the election, go to Details, and tap "Conclude Election Early".',
        'Results Publishing: The official winner, vote tallies, and percentage breakdown instantly appear in the "Results" tab.'
      ],
      tips: 'Elections cannot be reopened once concluded to prevent ballot stuffing.',
      suggestedFollowUps: ['How to view official results?', 'Can voters verify their receipts?']
    },
    bn: {
      title: 'ভোটের টাইমার, লাইভ কাউন্টডাউন ও স্বয়ংক্রিয় সমাপ্তি',
      steps: [
        'কাজের পদ্ধতি: ইলেকশন লাইভ হওয়া মাত্রই রিয়েল-টাইম টাইমার শুরু হয় যা অ্যাডমিন এবং ভোটার সবার স্ক্রিনে সেকেন্ডে সেকেন্ডে কমতে থাকে।',
        'অটোমেটিক সমাপ্তি: টাইমার যখন 00:00:00 এ পৌঁছায়, ব্যাকএন্ড ও ফায়ারস্টোর স্বয়ংক্রিয়ভাবে নির্বাচনটি "CONCLUDED" ঘোষণা করে।',
        'ভোটগ্রহণ লক: সমাপ্ত হওয়ার সাথে সাথে কোনো ভোটার আর ব্যালট সাবমিট করতে পারে না। ব্যালট বক্স ক্রিপ্টোগ্রাফিকভাবে সিল হয়ে যায়।',
        'সময়ের আগেই সমাপ্তি: যদি নির্ধারিত সময়ের আগেই সকল কর্মী ভোট দিয়ে দেন, অ্যাডমিন ইলেকশন ডিটেইলস স্ক্রিনে গিয়ে "Conclude Election Early" বাটনে চাপ দিয়ে ভোট শেষ করতে পারেন।',
        'ফলাফল প্রকাশ: ভোট শেষ হওয়া মাত্রই "Results" ট্যাবে বিজয়ী প্রার্থী এবং প্রত্যেকের প্রাপ্ত ভোট ও শতাংশ স্বয়ংক্রিয়ভাবে প্রকাশ পায়।'
      ],
      tips: 'একবার ভোট শেষ (Concluded) হলে তা আর রি-ওপেন করা যায় না, যা নির্বাচনী জালিয়াতি প্রতিরোধ করে।',
      suggestedFollowUps: ['ফলাফল কীভাবে চেক করব?', 'ভোটাররা রসিদ কীভাবে মেলাবে?']
    }
  },
  {
    id: 'voter_troubleshooting',
    keywords: ['voter login', 'cannot login', 'already voted', 'voter error', 'password reset', 'লগইন হচ্ছে না', 'ভোট দিতে পারছে না', 'ভোটার সমস্যা'],
    category: 'Voter Troubleshooting Guide',
    en: {
      title: 'Troubleshooting Voter Issues (Login & Ballot Submissions)',
      steps: [
        'Issue 1: "Company ID not recognized during registration": Ensure Admin has added the exact ID to the Whitelist first. Verify Organization Portal Code (e.g. UDU007).',
        'Issue 2: "User sees Already Voted": Our cryptographic ledger enforces strictly 1 vote per employee. If the voter previously submitted a ballot, they cannot vote twice. Ask them for their VOTE-XXXXXXXX receipt code.',
        'Issue 3: "Invalid Credentials": Confirm the voter registered using their exact Employee ID and created their own secure password.',
        'Issue 4: "Election not visible": Make sure the election status is currently "LIVE" and not still in "UPCOMING" scheduled status.'
      ],
      tips: 'Admins can verify voter participation without seeing who they voted for, preserving absolute voter secrecy.',
      suggestedFollowUps: ['How to check vote receipt code?', 'How to manage whitelist?']
    },
    bn: {
      title: 'ভোটারদের সমস্যার সমাধান (লগইন ও ভোট প্রদান)',
      steps: [
        'সমস্যা ১: "Company ID Not Found": নিশ্চিত হোন অ্যাডমিন Whitelist-এ ওই কর্মীর আইডিটি আগে যুক্ত করেছেন কিনা। রেজিস্ট্রেশনের সময় সঠিক Organization Code দিতে হবে।',
        'সমস্যা ২: "Already Voted দেখাচ্ছে": আমাদের সিস্টেমে একজন ভোটার একটি নির্বাচনে মাত্র একবারই ভোট দিতে পারে। তিনি ইতিমধ্যে ভোট দিয়ে থাকলে তার কাছে VOTE-XXXXXXXX রসিদ থাকবে। দ্বিতীয়বার ভোট দেওয়া সম্ভব নয়।',
        'সমস্যা ৩: "Invalid Credentials": ভোটার রেজিস্ট্রেশন করার সময় যে পাসওয়ার্ড দিয়েছিলেন তা ঠিকভাবে দিচ্ছেন কিনা নিশ্চিত করুন।',
        'সমস্যা ৪: "ইলেকশন দেখা যাচ্ছে না": নিশ্চিত হোন নির্বাচনটি বর্তমানে "LIVE" অবস্থায় আছে, "UPCOMING" বা ভবিষ্যতের শিডিউলে নয়।'
      ],
      tips: 'অ্যাডমিন ভোটাররা ভোট দিয়েছে কিনা দেখতে পারবেন, কিন্তু কে কাকে ভোট দিয়েছে তা দেখতে পারবেন না (সম্পূর্ণ গোপন ব্যালট)।',
      suggestedFollowUps: ['ভোটের রসিদ কোড কীভাবে পরীক্ষা করব?', 'হোয়াইটলিস্ট ম্যানেজ করার নিয়ম']
    }
  },
  {
    id: 'receipt_and_ledger',
    keywords: ['receipt', 'verify receipt', 'ledger', 'hash', 'cryptographic', 'audit', 'রসিদ', 'ভেরিফাই', 'লেজার', 'রিসিট', 'সিকিউরিটি'],
    category: 'Cryptographic Receipts & Audit Ledger',
    en: {
      title: 'Vote Receipt Verification & Tamper-Evident Ledger',
      steps: [
        'Every voter receives a unique cryptographic receipt code (format: `VOTE-XXXXXXXX`) upon submitting their secret ballot.',
        'Verification: Anyone (Admin or Voter) can tap the Receipt icon in the top AppBar, enter the receipt code, and verify that the ballot was recorded in the company ledger.',
        'Privacy: The verification confirms the ballot timestamp and cryptographic hash without ever revealing which candidate was selected.',
        'Audit Integrity: If any unauthorized modification is attempted in the database, the cryptographic hash will fail verification.'
      ],
      tips: 'Encourage all voters to take a screenshot or copy their receipt code for personal proof.',
      suggestedFollowUps: ['How does vote secrecy work?', 'How to see live analytics?']
    },
    bn: {
      title: 'ভোটের ডিজিটাল রসিদ (Receipt) ও অডিট লেজার ভেরিফিকেশন',
      steps: [
        'প্রতিটি ভোটার ভোট সম্পন্ন করার সাথে সাথে একটি অনন্য ক্রিপ্টোগ্রাফিক রসিদ কোড (যেমন: `VOTE-C695B102443112BA`) পান।',
        'রসিদ যাচাইয়ের উপায়: অ্যাপের উপরের AppBar-এ রসিদ (Receipt) আইকনে চাপ দিয়ে কোডটি পেস্ট করে "Verify" দিলেই অডিট লেজার থেকে নিশ্চিত হওয়া যাবে যে ব্যালটটি সংরক্ষিত আছে।',
        'গোপনীয়তা সুরক্ষা: এই ভেরিফিকেশনে ভোট গৃহীত হওয়ার প্রমাণ ও সময় দেখানো হয়, কিন্তু ভোটার কাকে ভোট দিয়েছেন তা কাউকেই জানানো হয় না।',
        'ট্যাম্পার-প্রুফ: ডেটাবেসে কেউ কোনো কারচুপি করার চেষ্টা করলে ক্রিপ্টোগ্রাফিক হ্যাশ অকার্যকর হয়ে যাবে।'
      ],
      tips: 'ভোট দেওয়ার পর প্রত্যেক ভোটারকে তাদের রসিদ কোড বা স্ক্রিনশট সংরক্ষণ করার পরামর্শ দিন।',
      suggestedFollowUps: ['মাল্টি-টেন্যান্ট সিকিউরিটি কী?', 'লাইভ টার্নআউট মনিটরিং']
    }
  },
  {
    id: 'server_and_network',
    keywords: ['server', 'ip', 'connection', 'network error', 'port 5000', 'wi-fi', 'সার্ভার', 'কানেকশন এরর', 'নেটওয়ার্ক', 'আইপি'],
    category: 'Server Connection & Network Setup',
    en: {
      title: 'Server Connection & Wi-Fi IP Configuration',
      steps: [
        'If testing on Android Physical Device: Open Role Select Screen -> tap Settings icon (top right).',
        'Change `http://127.0.0.1:5000/api` to your computer local Wi-Fi IP: e.g. `http://192.168.1.5:5000/api`.',
        'If testing on Android Emulator: Use default `http://10.0.2.2:5000/api`.',
        'Cloud / Firebase Fallback: SmartVote is equipped with automatic Firebase Cloud Firestore sync, ensuring elections and ballots work even if the local Node.js server is offline!'
      ],
      tips: 'Ensure both your phone and PC are connected to the same Wi-Fi network and port 5000 is allowed through Windows Firewall.',
      suggestedFollowUps: ['How to check server health?', 'How to create election?']
    },
    bn: {
      title: 'সার্ভার কানেকশন ও ওয়াই-ফাই আইপি কনফিগারেশন এরর সমাধান',
      steps: [
        'বাস্তব মোবাইলে টেস্ট করার নিয়ম: Role Select স্ক্রিনে গিয়ে উপরে ডানদিকের Settings আইকনে ট্যাপ করুন।',
        'কম্পিউটারের লোকাল ওয়াই-ফাই আইপি দিন: `http://127.0.0.1:5000/api` এর বদলে পিসির আইপি যেমন `http://192.168.1.X:5000/api` লিখে সেভ করুন।',
        'এন্ড্রয়েড এমুলেটর: এমুলেটরের জন্য ডিফল্ট `http://10.0.2.2:5000/api` কাজ করবে।',
        'ফায়ারবেস ক্লাউড ব্যাকআপ: অ্যাপে স্বয়ংক্রিয় Firebase Cloud Firestore সিঙ্ক রয়েছে, তাই লোকাল নোড সার্ভার অফ থাকলেও ক্লাউড থেকে সব ডেটা ও ভোটিং নির্বিঘ্নে চলবে!'
      ],
      tips: 'মোবাইল ও কম্পিউটার একই ওয়াই-ফাই নেটওয়ার্কে যুক্ত থাকতে হবে এবং উইন্ডোজ ফায়ারওয়ালে পোর্ট ৫০০০ এলাউ থাকতে হবে।',
      suggestedFollowUps: ['সার্ভার হেলথ কীভাবে চেক করব?', 'হোয়াইটলিস্ট এড করার উপায়']
    }
  }
];

// Fallback general guidance when query is open-ended
const GENERAL_HELP = {
  en: {
    title: 'SmartVote Corporate AI Admin Assistant',
    content: `Hello! I am your SmartVote AI Assistant, trained on corporate voting systems, cryptographic ledgers, and organization management. 

Here is what I can help you with in real time:
1. 📋 **Voter Whitelist:** Adding single voters, CSV mass imports, duplicate ID checks.
2. 🗳️ **Election Setup:** Title, categories (HR, CR, Director), candidates, corporate symbols, countdown timers.
3. 📸 **Candidate Media:** Photo uploads via Camera, Gallery, or URL, custom logo selection.
4. ⏱️ **Election Timers:** Live countdowns, auto-conclusion, and manual early closing.
5. 👤 **Voter Support:** Resolving login failures, ID verification, "already voted" inquiries.
6. 📜 **Audit & Receipts:** Cryptographic VOTE-XXXXXXXX receipts and tamper-evident ledger proofs.
7. 🌐 **Server & Cloud:** Wi-Fi IP configuration, Node.js API, and Firebase Firestore cloud sync.

Please ask me your specific question or describe any problem you are experiencing!`,
    suggestedFollowUps: [
      'How to upload voter whitelist?',
      'How to create an HR or CR election?',
      'Voter cannot login fix',
      'What happens when timer expires?'
    ]
  },
  bn: {
    title: 'স্মার্টভোট কর্পোরেট এআই অ্যাডমিন অ্যাসিস্ট্যান্ট',
    content: `আসসালামু আলাইকুম / নমস্কার! আমি আপনার স্মার্টভোট এআই অ্যাসিস্ট্যান্ট। কর্পোরেট ভোটিং সিস্টেম, ক্রিপ্টোগ্রাফিক লেজার এবং নির্বাচন পরিচালনার সকল বিষয়ে আমি আপনাকে রিয়েল-টাইম সমাধান দিতে প্রস্তুত।

আমি আপনাকে যেসব বিষয়ে সরাসরি সহায়তা করতে পারি:
১. 📋 **ভোটার হোয়াইটলিস্ট:** একক ভোটার এন্ট্রি, এক্সেল/CSV বাল্ক আপলোড, ভুয়া ভোটার প্রতিরোধ।
২. 🗳️ **ইলেকশন তৈরি ও নিয়ম:** ক্যাটাগরি (HR, CR, Director), সময়সীমা, প্রার্থী যোগ এবং রুলস সেট করা।
৩. 📸 **প্রার্থীর ছবি ও প্রতীক:** ক্যামেরা, গ্যালারি বা ইউআরএল দিয়ে ছবি এবং পছন্দের কর্পোরেট লোগো দেওয়া।
৪. ⏱️ **টাইমার ও নির্বাচন সমাপ্তি:** লাইভ কাউন্টডাউন, অটো-ক্লোজ এবং নির্ধারিত সময়ের আগে ভোট শেষ করা।
৫. 👤 **ভোটারদের সমস্যার সমাধান:** লগইন সমস্যা, আইডি ভেরিফিকেশন, পাসওয়ার্ড সংক্রান্ত সমাধান।
৬. 📜 **ডিজিটাল রসিদ ও লেজার:** VOTE-XXXXXXXX ক্রিপ্টোগ্রাফিক রসিদ যাচাই ও অডিট লেজার।
৭. 🌐 **সার্ভার ও ক্লাউড সিঙ্ক:** ওয়াই-ফাই আইপি সেটআপ এবং ফায়ারবেস ক্লাউড কানেকশন।

আপনার কী সমস্যা হচ্ছে তা বিস্তারিত লিখুন, আমি এখনই সমাধান বলে দিচ্ছি!`,
    suggestedFollowUps: [
      'ভোটার হোয়াইটলিস্ট কীভাবে যুক্ত করব?',
      'নতুন ইলেকশন খোলার নিয়ম কী?',
      'ভোটার লগইন করতে না পারলে কী করব?',
      'ভোটের টাইমার কীভাবে কাজ করে?'
    ]
  }
};

/**
 * Intelligent AI Chat Response Generator
 */
exports.chatWithAi = async (req, res) => {
  try {
    const { message, language = 'auto', orgContext } = req.body;

    if (!message || typeof message !== 'string' || message.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'A valid text query is required.',
      });
    }

    const cleanQuery = message.trim().toLowerCase();

    // Detect language: Bengali vs English
    const isBengaliQuery = /[\u0980-\u09FF]|kivabe|korbo|hocche|korte|kono|somossha|ki|bhai|bolo|dekhao/i.test(cleanQuery);
    const targetLang = (language === 'bn' || isBengaliQuery) ? 'bn' : 'en';

    // Semantic Intent Matching across knowledge base
    let bestMatch = null;
    let maxScore = 0;

    for (const item of KNOWLEDGE_BASE) {
      let score = 0;
      for (const kw of item.keywords) {
        if (cleanQuery.includes(kw.toLowerCase())) {
          score += (kw.length > 5 ? 3 : 2);
        }
      }
      if (score > maxScore) {
        maxScore = score;
        bestMatch = item;
      }
    }

    if (bestMatch && maxScore >= 2) {
      const localized = targetLang === 'bn' ? bestMatch.bn : bestMatch.en;

      // Construct rich structured resolution
      const stepList = localized.steps.map((s, idx) => `${idx + 1}. ${s}`).join('\n');
      const formattedReply = `### 💡 ${localized.title}\n\n**ক্যাটাগরি / Category:** ${bestMatch.category}\n\n**সমাধানের ধাপসমূহ (Action Steps):**\n${stepList}\n\n> 📌 **Pro Tip:** ${localized.tips}\n\nআপনার কি এই বিষয়ে আরও কোনো প্রশ্ন বা সহায়তা প্রয়োজন?`;

      return res.status(200).json({
        success: true,
        intent: bestMatch.id,
        category: bestMatch.category,
        language: targetLang,
        reply: formattedReply,
        suggestedActions: localized.suggestedFollowUps || [],
        timestamp: new Date().toISOString()
      });
    }

    // Default smart reasoning fallback
    const fallback = targetLang === 'bn' ? GENERAL_HELP.bn : GENERAL_HELP.en;
    return res.status(200).json({
      success: true,
      intent: 'general_assistance',
      category: 'General Guidance',
      language: targetLang,
      reply: fallback.content,
      suggestedActions: fallback.suggestedFollowUps,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('AI Chatbot Controller Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to process AI chat request: ' + error.message,
    });
  }
};
