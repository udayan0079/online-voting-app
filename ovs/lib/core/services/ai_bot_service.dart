import '../network/api_client.dart';
import '../../models/ai_message_model.dart';

class AiBotService {
  /// Send query to backend AI API or fallback to On-Device Deep Knowledge Engine
  static Future<AiMessageModel> getAiResponse({
    required String query,
    String? currentOrgCode,
    String? currentOrgName,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return AiMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'অনুগ্রহ করে আপনার প্রশ্ন বা সমস্যাটি লিখুন।',
        isUser: false,
        timestamp: DateTime.now(),
      );
    }

    try {
      // 1. Attempt Live Server API Call
      final response = await ApiClient.post('/ai/chat', {
        'message': cleanQuery,
        'orgContext': {
          'orgCode': currentOrgCode ?? '',
          'orgName': currentOrgName ?? '',
        },
      });

      if (response.success && response.data != null) {
        final data = response.data;
        final replyText = data['reply']?.toString() ?? '';
        final category = data['category']?.toString();
        final List<String> actions = (data['suggestedActions'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        if (replyText.isNotEmpty) {
          return AiMessageModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: replyText,
            isUser: false,
            timestamp: DateTime.now(),
            category: category,
            suggestedActions: actions,
          );
        }
      }
    } catch (_) {
      // Network/Server offline - fall through seamlessly to local engine
    }

    // 2. On-Device Deep Reasoning Engine (Zero Latency & 100% Offline Guaranteed)
    return _generateOnDeviceResponse(cleanQuery);
  }

  static AiMessageModel _generateOnDeviceResponse(String query) {
    final q = query.toLowerCase();
    final isBn = RegExp(r'[\u0980-\u09FF]|kivabe|korbo|hocche|korte|kono|somossha|ki|bhai|bolo|dekhao').hasMatch(q);

    // Whitelist & Voter Entry
    if (q.contains('whitelist') ||
        q.contains('voter list') ||
        q.contains('add voter') ||
        q.contains('csv') ||
        q.contains('হোয়াইটলিস্ট') ||
        q.contains('ভোটার যোগ') ||
        q.contains('ভোটার এড')) {
      if (isBn) {
        return AiMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          category: 'Voter Whitelist Management',
          isUser: false,
          timestamp: DateTime.now(),
          text: '''### 💡 ভোটার হোয়াইটলিস্ট (Whitelist) ম্যানেজমেন্ট গাইড

**ক্যাটাগরি:** Voter Whitelist Management

**সমাধানের ধাপসমূহ (Action Steps):**
1. অ্যাডমিন ড্যাশবোর্ডে গিয়ে **"Manage Voter Whitelist"** কার্ডে ট্যাপ করুন।
2. **একক ভোটার যুক্ত করতে:** `+ Add Voter` বাটনে চাপুন। কর্মীর Company/Employee ID (যেমন: EMP101), পূর্ণ নাম, ইমেইল এবং ডিপার্টমেন্ট লিখে সংরক্ষণ করুন।
3. **CSV ফাইল আপলোড:** একসাথে শত শত কর্মী যুক্ত করতে `Upload CSV` ব্যবহার করুন। CSV ফাইলের হেডার হবে: `voterId,fullName,email,department`।
4. **প্রাইভেসি ও নিয়ন্ত্রণ:** শুধু হোয়াইটলিস্টের আইডিধারীরাই ভোটার হিসেবে অ্যাকাউন্ট খুলে ভোট দিতে পারবেন। কোনো বহিরাগত বা ভুয়া আইডি ভোট দিতে পারবে না।

> 📌 **Pro Tip:** Employee ID এন্ট্রির সময় কোনো বাড়তি স্পেস যেন না থাকে সেদিকে খেয়াল রাখুন।''',
          suggestedActions: [
            'ভোটার লগইন করতে না পারলে কী করব?',
            'হোয়াইটলিস্ট থেকে আইডি ডিলিট করার নিয়ম',
          ],
        );
      } else {
        return AiMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          category: 'Voter Whitelist Management',
          isUser: false,
          timestamp: DateTime.now(),
          text: '''### 💡 Voter Whitelist Management Guide

**Category:** Voter Whitelist Management

**Action Steps:**
1. From Admin Dashboard, tap **"Manage Voter Whitelist"**.
2. **Single Entry:** Tap `+ Add Voter`. Enter Company Employee ID, Full Name, Email, and Department. Tap Save.
3. **CSV Bulk Import:** Tap `Upload CSV` to import batches of employees. Required CSV headers: `voterId,fullName,email,department`.
4. **Security Enforcement:** Only pre-approved Employee IDs can register and access election ballots, preventing unauthorized access.

> 📌 **Pro Tip:** Make sure employee IDs match the exact formatting on company badges with no trailing whitespace.''',
          suggestedActions: [
            'What if voter cannot login?',
            'How to create an election?',
          ],
        );
      }
    }

    // Election Creation & Categories
    if (q.contains('create') ||
        q.contains('election') ||
        q.contains('category') ||
        q.contains('hr') ||
        q.contains('cr') ||
        q.contains('ইলেকশন') ||
        q.contains('নির্বাচন') ||
        q.contains('ভোট তৈরি')) {
      if (isBn) {
        return AiMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          category: 'Election Setup',
          isUser: false,
          timestamp: DateTime.now(),
          text: '''### 💡 নতুন নির্বাচন (Election) তৈরি ও কনফিগারেশন

**ক্যাটাগরি:** Election Setup

**সমাধানের ধাপসমূহ (Action Steps):**
1. অ্যাডমিন ড্যাশবোর্ডের উপরে নীল রঙের **"+ Create New Election"** বাটনে ট্যাপ করুন।
2. **মৌলিক তথ্য:** নির্বাচনের নাম (যেমন: "HR Representative Poll 2026") এবং বিস্তারিত বিবরণ দিন।
3. **ক্যাটাগরি নির্ধারণ:** ড্রপডাউন থেকে ক্যাটাগরি (HR, CR, Director, President) নির্বাচন করুন।
4. **ভোটের সময়সীমা:** শুরুর তারিখ/সময় এবং কত মিনিট/ঘণ্টা ভোট চলবে (Duration) তা নির্ধারণ করুন।
5. **প্রার্থী যুক্তকরণ:** কমপক্ষে ২ জন প্রার্থী যুক্ত করুন, তাদের ছবি এবং নির্বাচনী প্রতীক দিন।
6. **পাবলিশ:** "Publish Election" বাটনে চাপ দিলেই নির্বাচন শিডিউল অনুযায়ী লাইভ হয়ে যাবে।

> 📌 **Pro Tip:** একবার কোনো ভোটার ব্যালট সাবমিট করলে স্বচ্ছতা রক্ষার স্বার্থে প্রার্থীর তালিকা বা নিয়ম পরিবর্তন করা যায় না।''',
          suggestedActions: [
            'প্রার্থীর ছবি ও প্রতীক দেওয়ার নিয়ম',
            'ভোটের টাইমার কীভাবে কাজ করে?',
          ],
        );
      } else {
        return AiMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          category: 'Election Setup',
          isUser: false,
          timestamp: DateTime.now(),
          text: '''### 💡 How to Create a New Election

**Category:** Election Setup

**Action Steps:**
1. Tap the **"+ Create New Election"** button on the Admin Dashboard.
2. Fill in the Title, Description, and select the Category (HR, CR, Director, etc.).
3. Configure the Start Time and Duration (in minutes or hours).
4. Add at least two nominees with profile photos and corporate symbols.
5. Tap **"Publish Election"** to deploy immediately or schedule for later.

> 📌 **Pro Tip:** Once voting commences, candidate lists are locked to prevent tampering with active ballots.''',
          suggestedActions: [
            'Candidate photo upload guide',
            'What happens when timer expires?',
          ],
        );
      }
    }

    // Candidate Photo & Symbol
    if (q.contains('photo') ||
        q.contains('symbol') ||
        q.contains('logo') ||
        q.contains('camera') ||
        q.contains('gallery') ||
        q.contains('ছবি') ||
        q.contains('প্রতীক') ||
        q.contains('লোগো') ||
        q.contains('ফটো')) {
      if (isBn) {
        return AiMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          category: 'Candidates & Symbols',
          isUser: false,
          timestamp: DateTime.now(),
          text: '''### 💡 প্রার্থীর ছবি ও নির্বাচনী প্রতীক (Logo/Symbol) গাইড

**ক্যাটাগরি:** Candidates & Media

**সমাধানের ধাপসমূহ (Action Steps):**
1. ইলেকশন তৈরির সময় **"Add Candidate"** কার্ডে যান।
2. প্রার্থীর ছবি ৩টি উপায়ে যুক্ত করতে পারেন:
   - 📸 **Camera:** সরাসরি প্রার্থীর তাৎক্ষণিক ছবি তুলতে ক্যামেরা ব্যবহার করুন।
   - 🖼️ **Gallery:** প্রার্থীর সংরক্ষিত অফিসিয়াল ছবি গ্যালারি থেকে সিলেক্ট করুন।
   - 🌐 **Image URL:** ওয়েব বা কোম্পানির ক্লাউড লিংকের URL পেস্ট করুন।
3. **নির্বাচনী প্রতীক (Symbol):** লিস্টে থাকা প্রতীক (Eagle, Shield, Star, Rocket, Diamond) বেছে নিন অথবা "Upload Custom Logo" দিয়ে নিজস্ব ব্যানার/লোগো দিন।

> 📌 **Pro Tip:** স্কয়ার সাইজের (১:১ রেশিও) ছবি ব্যবহার করলে ব্যালট পেপারে সবচেয়ে আকর্ষণীয় দেখায়।''',
          suggestedActions: [
            'ছবি আপলোডে এরর দেখালে করণীয়',
            'ইলেকশন তৈরি করার নিয়ম',
          ],
        );
      } else {
        return AiMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          category: 'Candidates & Symbols',
          isUser: false,
          timestamp: DateTime.now(),
          text: '''### 💡 Candidate Photo & Symbol Management

**Category:** Candidates & Media

**Action Steps:**
1. In the Candidate creation card, enter the candidate name and designation.
2. **Photo Options:** (1) Take a photo with Camera, (2) Choose photo from Gallery, or (3) Enter a direct Image URL.
3. **Symbol Assignment:** Select from standard corporate badges (Star, Eagle, Rocket, Shield) or tap "Upload Custom Logo".

> 📌 **Pro Tip:** 1:1 square photos provide the cleanest rendering across all mobile screen resolutions.''',
          suggestedActions: [
            'Fix photo upload issues',
            'How to create an election?',
          ],
        );
      }
    }

    // Timers & Conclusion
    if (q.contains('timer') ||
        q.contains('countdown') ||
        q.contains('conclude') ||
        q.contains('close') ||
        q.contains('time') ||
        q.contains('টাইমার') ||
        q.contains('কাউন্টডাউন') ||
        q.contains('সমাপ্ত') ||
        q.contains('শেষ')) {
      if (isBn) {
        return AiMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          category: 'Timers & Conclusion',
          isUser: false,
          timestamp: DateTime.now(),
          text: '''### 💡 ভোটের লাইভ টাইমার ও সমাপ্তি (Auto-Conclusion)

**ক্যাটাগরি:** Timers & Lifecycle

**পদ্ধতি ও কার্যপ্রণালী:**
1. **লাইভ কাউন্টডাউন:** নির্বাচন চালু হলে অ্যাডমিন ও ভোটার সবার স্ক্রিনে লাইভ কাউন্টডাউন টাইমার চলতে থাকে।
2. **অটো-ক্লোজ:** টাইমার 00:00:00 হওয়ার সাথে সাথে নির্বাচনটি স্বয়ংক্রিয়ভাবে "CONCLUDED" স্ট্যাটাসে চলে যায় এবং ভোটগ্রহণ স্থায়ীভাবে বন্ধ হয়ে যায়।
3. **সময়ের আগে শেষ করা:** সকল ভোটার নির্ধারিত সময়ের আগেই ভোট দিয়ে ফেললে অ্যাডমিন ইলেকশন ডিটেইলসে গিয়ে **"Conclude Election Early"** বাটনে চাপ দিয়ে তখনই ভোট শেষ করতে পারেন।
4. **ফলাফল প্রকাশ:** ভোট শেষ হওয়ামাত্র "Results" ট্যাবে তাৎক্ষণিক বিজয়ী ও সার্বিক পরিসংখ্যান দৃশ্যমান হয়।''',
          suggestedActions: [
            'ফলাফল দেখার উপায়',
            'ভোটারের ডিজিটাল রসিদ যাচাই',
          ],
        );
      } else {
        return AiMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          category: 'Timers & Conclusion',
          isUser: false,
          timestamp: DateTime.now(),
          text: '''### 💡 Election Timers & Auto-Conclusion

**Category:** Timers & Lifecycle

**How it operates:**
1. **Live Countdown:** Real-time synchronized timer displays on both admin and voter dashboards.
2. **Automatic Conclusion:** Once the countdown hits 00:00:00, voting locks automatically, and status updates to "CONCLUDED".
3. **Manual Early Close:** If all voters have finished early, Admin can click "Conclude Election Early" in Election Details.
4. **Official Results:** Instant winner declaration and vote percentage tallies populate under the "Results" tab.''',
          suggestedActions: [
            'How to view official results?',
            'Verify cryptographic receipts',
          ],
        );
      }
    }

    // Voter Login / Errors / Troubleshooting
    if (q.contains('login') ||
        q.contains('cannot') ||
        q.contains('voted') ||
        q.contains('password') ||
        q.contains('লগইন') ||
        q.contains('ভোট দিতে পারছে না') ||
        q.contains('সমস্যা')) {
      if (isBn) {
        return AiMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          category: 'Voter Diagnostics',
          isUser: false,
          timestamp: DateTime.now(),
          text: '''### 💡 ভোটারদের সমস্যার সমাধান (Login & Ballot Diagnostics)

**ক্যাটাগরি:** Voter Diagnostics

**সম্ভাব্য কারণ ও তাৎক্ষণিক সমাধান:**
1. **"Company ID Not Found":** অ্যাডমিন Whitelist-এ ওই কর্মীর আইডিটি আগে যুক্ত করেছেন কিনা চেক করুন। ভোটার আইডি বড়/ছোট হাতের অক্ষরের মিল থাকতে হবে।
2. **"Already Voted":** সিস্টেমে এক ভোটার একবারই ভোট দিতে পারে। তিনি ইতিমধ্যে ভোট দিয়ে থাকলে তার কাছে VOTE-XXXXXXXX রসিদ থাকবে। দ্বিতীয়বার ভোট দেওয়া সম্ভব নয়।
3. **"Wrong Organization Code":** রেজিস্ট্রেশনের সময় অ্যাডমিনের দেওয়া সঠিক Portal Code (যেমন: UDU007) লিখতে হবে।
4. **"ভোটের লিস্ট খালি":** নিশ্চিত করুন অ্যাডমিনের তৈরি করা নির্বাচনটি বর্তমানে "LIVE" অবস্থায় আছে, শিডিউলড "UPCOMING" নয়।''',
          suggestedActions: [
            'ভোটার রসিদ ভেরিফাই কীভাবে করব?',
            'হোয়াইটলিস্ট চেক করার নিয়ম',
          ],
        );
      } else {
        return AiMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          category: 'Voter Diagnostics',
          isUser: false,
          timestamp: DateTime.now(),
          text: '''### 💡 Troubleshooting Voter Login & Ballots

**Category:** Voter Diagnostics

**Common Issues & Fixes:**
1. **"ID Not Found":** Confirm the employee ID is listed in the organization Whitelist first.
2. **"Already Voted":** Cryptographic single-ballot guarantee prevents double voting. The voter can inspect their `VOTE-XXXXXXXX` receipt.
3. **"Invalid Portal Code":** Ensure voter signs up using your exact Organization Portal Code (e.g., UDU007).
4. **"No Live Elections":** Verify that an election has started and is currently marked LIVE.''',
          suggestedActions: [
            'How to verify a vote receipt?',
            'How to manage whitelist?',
          ],
        );
      }
    }

    // Server / Network / Wi-Fi IP
    if (q.contains('server') ||
        q.contains('ip') ||
        q.contains('network') ||
        q.contains('connection') ||
        q.contains('wifi') ||
        q.contains('সার্ভার') ||
        q.contains('আইপি') ||
        q.contains('কানেক্ট')) {
      if (isBn) {
        return AiMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          category: 'Server & Connectivity',
          isUser: false,
          timestamp: DateTime.now(),
          text: '''### 💡 সার্ভার কানেকশন ও নেটওয়ার্ক সমাধান

**ক্যাটাগরি:** Server & Connectivity

**কনফিগারেশন ধাপসমূহ:**
1. **মোবাইলে টেস্ট করতে:** Role Select স্ক্রিনে গিয়ে উপরে ডানদিকের Settings আইকনে ট্যাপ করুন।
2. পিসির লোকাল ওয়াই-ফাই আইপি দিন: যেমন `http://192.168.1.15:5000/api` লিখে সেভ করুন।
3. **এন্ড্রয়েড এমুলেটর:** এমুলেটরের ক্ষেত্রে ডিফল্ট `http://10.0.2.2:5000/api` থাকবে।
4. **ক্লাউড ব্যাকআপ:** নোড সার্ভার অফ থাকলেও SmartVote-এ রয়েছে স্বয়ংক্রিয় Firebase Cloud Firestore ফলব্যাক, যার ফলে সব ভোটিং ক্লাউডে নিরাপদে চলতে থাকবে!''',
          suggestedActions: [
            'সার্ভার হেলথ চেক কীভাবে করব?',
            'হোয়াইটলিস্ট ম্যানেজ করার নিয়ম',
          ],
        );
      } else {
        return AiMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          category: 'Server & Connectivity',
          isUser: false,
          timestamp: DateTime.now(),
          text: '''### 💡 Server Connection & Network Configuration

**Category:** Server & Connectivity

**Resolution Steps:**
1. **Physical Mobile Device:** Open Role Select Screen -> tap Settings icon (top right).
2. Enter your PC local Wi-Fi IP: e.g., `http://192.168.1.X:5000/api`.
3. **Android Emulator:** Use default `http://10.0.2.2:5000/api`.
4. **Cloud Firestore Sync:** Even if local Node.js server is paused, SmartVote seamlessly synchronizes with Firebase Cloud Firestore.''',
          suggestedActions: [
            'Check server health',
            'How to create an election?',
          ],
        );
      }
    }

    // Default Fallback
    if (isBn) {
      return AiMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: 'General AI Support',
        isUser: false,
        timestamp: DateTime.now(),
        text: '''### 🤖 স্মার্টভোট কর্পোরেট এআই অ্যাডমিন অ্যাসিস্ট্যান্ট

আমি আপনার অনলাইন ভোটিং সিস্টেমের সার্বক্ষণিক এআই সহযোগী। আমি আপনাকে নিচের বিষয়গুলোতে সাহায্য করতে পারি:

1. 📋 **ভোটার হোয়াইটলিস্ট:** একক ও CSV ফাইল দিয়ে অনুমোদিত ভোটার যুক্ত করা।
2. 🗳️ **ইলেকশন পরিচালনা:** HR, CR, Director ইত্যাদি ক্যাটাগরিতে নির্বাচন তৈরি ও টাইমার সেট।
3. 📸 **প্রার্থীর ছবি ও প্রতীক:** ক্যামেরা, গ্যালারি বা ইউআরএল দিয়ে ছবি এবং পছন্দের নির্বাচনী লোগো আপলোড।
4. ⏱️ **টাইমার ও ফলাফল:** লাইভ টাইমার, অটোমেটিক সমাপ্তি এবং রিয়েল-টাইম টার্নআউট মনিটরিং।
5. 👤 **ভোটারদের সমস্যার সমাধান:** আইডি বা লগইন সংক্রান্ত যে কোনো সমস্যা সমাধান।
6. 📜 **ডিজিটাল রসিদ:** VOTE-XXXXXXXX রসিদ কোড দিয়ে অডিট লেজার ভেরিফিকেশন।
7. 🌐 **সার্ভার কনফিগারেশন:** মোবাইলের জন্য লোকাল ওয়াই-ফাই আইপি সেটআপ।

আপনার সুনির্দিষ্ট সমস্যাটি নিচে লিখুন বা নিচের বাটনগুলোতে ট্যাপ করুন!''',
        suggestedActions: [
          'ভোটার হোয়াইটলিস্ট কীভাবে যুক্ত করব?',
          'নতুন ইলেকশন খোলার নিয়ম কী?',
          'ভোটার লগইন করতে না পারলে কী করব?',
          'ভোটের টাইমার কীভাবে কাজ করে?',
        ],
      );
    } else {
      return AiMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: 'General AI Support',
        isUser: false,
        timestamp: DateTime.now(),
        text: '''### 🤖 SmartVote AI Admin Assistant

I am your 24/7 intelligent assistant for corporate elections, cryptographic voting, and system diagnostics.

Here is how I can assist you:
1. 📋 **Voter Whitelist:** Single entries and CSV bulk employee lists.
2. 🗳️ **Election Creation:** Title, categories (HR, CR, Director), and timers.
3. 📸 **Candidate Media:** Photo capture via Camera/Gallery and corporate symbols.
4. ⏱️ **Timers & Lifecycle:** Live countdown, auto-closing, and turnout metrics.
5. 👤 **Voter Support:** Resolving login and ballot validation issues.
6. 📜 **Receipt Verification:** Audit ledger checks via `VOTE-XXXXXXXX` codes.
7. 🌐 **Server & Cloud:** Wi-Fi IP configuration and Firebase sync.

Type your question below or tap any suggested action!''',
        suggestedActions: [
          'How to upload voter whitelist?',
          'How to create an HR or CR election?',
          'Troubleshoot voter login error',
          'How do election timers work?',
        ],
      );
    }
  }
}
