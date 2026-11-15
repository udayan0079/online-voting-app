import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/api_client.dart';
import '../storage/storage_service.dart';
import '../../models/ai_message_model.dart';
import 'ai_trained_knowledge_engine.dart';

class AiBotService {
  /// Send query to:
  /// 1) Google Gemini Generative AI (if user configured free Gemini API key)
  /// 2) Backend AI API (/api/ai/chat)
  /// 3) Dynamic Problem-Solving Diagnostic Reasoning Engine (On-device)
  static Future<AiMessageModel> getAiResponse({
    required String query,
    String? currentOrgCode,
    String? currentOrgName,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return AiMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'অনুগ্রহ করে আপনার প্রশ্ন বা সমস্যাটি বিস্তারিত লিখুন।',
        isUser: false,
        timestamp: DateTime.now(),
      );
    }

    final geminiKey = StorageService.getGeminiApiKey();

    // 1. Google Gemini Generative AI (Live Autonomous Problem Solving)
    if (geminiKey.isNotEmpty) {
      try {
        final geminiResponse = await _callGeminiApi(
          apiKey: geminiKey,
          userPrompt: cleanQuery,
          orgCode: currentOrgCode ?? 'UDU007',
          orgName: currentOrgName ?? 'SmartVote Portal',
        );

        if (geminiResponse != null && geminiResponse.trim().isNotEmpty) {
          return AiMessageModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: geminiResponse,
            isUser: false,
            timestamp: DateTime.now(),
            category: 'Gemini Generative AI (Live Fix)',
            suggestedActions: [
              'আর কোনো সমস্যা থাকলে লিখুন',
              'কীভাবে সমাধানটি অ্যাপ্লাই করব?',
              'ব্লকচেইন অডিট কীভাবে করব?',
            ],
          );
        }
      } catch (_) {
        // Fall through to next engines if Gemini API key failed or network dropped
      }
    }

    // 2. Attempt Backend Node/Express AI API
    try {
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
      // Backend offline on mobile - fall through to intelligent on-device engine
    }

    // 3. Dynamic Problem-Solving Diagnostic Reasoning Engine
    return _diagnoseAndFixProblem(cleanQuery);
  }

  /// Calls Google Gemini API directly over HTTPS
  static Future<String?> _callGeminiApi({
    required String apiKey,
    required String userPrompt,
    required String orgCode,
    required String orgName,
  }) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    const systemContext = '''
You are SmartVote AI, an elite technical troubleshooter and AI support assistant for the SmartVote Corporate Online Voting System.
System Specifications:
- Framework: Flutter (Android/iOS) + Firebase Cloud Firestore + Node.js/MongoDB Backend + Cryptographic SHA-256 Blockchain Ledger.
- Organization Context: The user is an Admin in an isolated tenant organization portal.
- Features: Whitelist employee data entry (single & CSV bulk), Election setup (HR, CR, Director categories), Photo capture (camera, gallery, URL) and corporate symbols, Timers and auto-conclusion, Anonymous confidential ballots, Cryptographic receipts (VOTE-XXXXXXXX), Blockchain Explorer with live integrity audit.

Guidelines for Answers:
1. Understand the exact problem described by the user (even if described casually in Bengali, Banglish, or English).
2. Give clear, numbered, step-by-step practical instructions on HOW TO FIX the problem immediately.
3. If they describe a bug or error (e.g. red screen overflow, button not clicking, white screen, photo not loading, voter cannot login, server connection timeout), explain the exact root cause and the exact 3-step solution.
4. Reply in the user's language: if they ask in Bangla or Banglish, reply in clear, friendly, natural Bengali; if they ask in English, reply in crisp English.
5. Do NOT just repeat canned generic articles. Think deeply and provide a direct customized fix.
''';

    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': '$systemContext\n\nUser Question/Problem: $userPrompt'}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.4,
        'maxOutputTokens': 1024,
      }
    });

    final response = await http
        .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final candidates = json['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content?['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          return parts[0]['text']?.toString();
        }
      }
    }
    return null;
  }

  /// Dynamic Problem-Solving Diagnostic Engine (Analyzes specific error symptoms)
  static AiMessageModel _diagnoseAndFixProblem(String query) {
    final q = query.toLowerCase();
    final isBn = RegExp(r'[\u0980-\u09FF]|kivabe|ki bhabe|kibhabe|kemne|korbo|kore|hocche|korte|kono|somossha|ki|bhai|shuno|dekhao|bolo|ache|nai|lagbe|holo|hoy|fix|error|pblm|problem').hasMatch(q);

    // 1. UI Overflow / Text Cut Off / Red Screen
    if (q.contains('overflow') ||
        q.contains('cut') ||
        q.contains('kete') ||
        q.contains('red screen') ||
        q.contains('lal') ||
        q.contains('yellow') ||
        q.contains('stripe') ||
        q.contains('button') && q.contains('dekha jay na')) {
      return AiMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: 'UI & Display Fix',
        isUser: false,
        timestamp: DateTime.now(),
        text: isBn
            ? '''### 🛠️ স্ক্রিনে টেক্সট কেটে যাওয়া বা লাল/হলুদ দাগের সমাধান (UI Overflow Fix)

**সমস্যার কারণ:**
স্ক্রিনের উপাদানটির (Button বা Card) ফিক্সড উচ্চতা (Height) ভেতরে থাকা টেক্সট ও প্যাডিংয়ের চেয়ে ছোট হলে Flutter-এ `RenderFlex overflowed` এরর বা নিচে লেখা কেটে যায়।

**সরাসরি সমাধানের উপায়:**
1. **উচ্চতা বৃদ্ধি করুন:** বাটন বা কনটেইনারটির `height: 48` বা `52` এ বাড়িয়ে দিন।
2. **প্যাডিং হ্রাস করুন:** বাটনের ভেতরের `vertical padding` ১২ থেকে কমিয়ে ৮ বা ১০ পিক্সেল করুন (`padding: EdgeInsets.symmetric(vertical: 10)` )।
3. **SingleChildScrollView ব্যবহার:** পুরো স্ক্রিনের বডিকে `SingleChildScrollView` দিয়ে মুড়ে দিন, যাতে স্ক্রল করার জায়গা থাকে এবং কোনো ডিভাইসেই লেখা না কাটে।
4. **FittedBox / TextOverflow.ellipsis:** টেক্সট যাতে স্ক্রিনের বাইরে না যায় সেজন্য `overflow: TextOverflow.ellipsis` যোগ করুন।'''
            : '''### 🛠️ How to Fix UI Text Clipping and RenderFlex Overflow

**Root Cause:**
When a button or container has a constrained height that is smaller than its child text + vertical padding, Flutter triggers a RenderFlex overflow.

**Direct Fix Steps:**
1. **Increase Container Height:** Expand button height to 48px or 52px.
2. **Adjust Vertical Padding:** Lower button internal vertical padding to 10px (`EdgeInsets.symmetric(vertical: 10)`).
3. **Wrap in SingleChildScrollView:** Ensure the parent column is enclosed in a scrollable view.
4. **Text Ellipsis:** Add `overflow: TextOverflow.ellipsis` to prevent horizontal text spilling.''',
        suggestedActions: [
          'কীভাবে কোডে এই ফিক্স যুক্ত করব?',
          'ফটো আপলোড এরর ফিক্স',
          'সার্ভার কানেকশন এরর ফিক্স',
        ],
      );
    }

    // 2. White Screen / Blank Screen / Freeze
    if (q.contains('white screen') ||
        q.contains('blank') ||
        q.contains('freeze') ||
        q.contains('atke') ||
        q.contains('shada') ||
        q.contains('loading') && q.contains('hoy na')) {
      return AiMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: 'App Freeze & Crash Fix',
        isUser: false,
        timestamp: DateTime.now(),
        text: isBn
            ? '''### 🛠️ অ্যাপে সাদা স্ক্রিন বা লোডিংয়ে আটকে থাকার সমাধান (White Screen Fix)

**সমস্যার কারণ:**
স্ক্রিন লোড হওয়ার সময় কোনো অ্যাসিনক্রোনাস ডেটা (Firestore বা Storage) নাল (Null) আসলে বা ফায়ারবেস কানেকশন ইনিশিয়ালাইজেশনের আগেই UI রেন্ডার করার চেষ্টা করলে স্ক্রিন ফ্রিজ বা সাদা হয়ে থাকে।

**সরাসরি সমাধানের ৩টি ধাপ:**
1. **Safety Null Check:** কোডের যেখানে ডেটা পড়া হচ্ছে (যেমন: `org?.name` বা `user?.name`) সেখানে সরাসরি নাল-অ্যাওয়ার অপারেটর (`?? 'Default'`) ব্যবহার করুন।
2. **ConnectionState হ্যান্ডেল করা:** `FutureBuilder` বা `StreamBuilder`-এ `if (snapshot.connectionState == ConnectionState.waiting)` রিটার্নে সুন্দর একটি `CircularProgressIndicator()` রাখুন।
3. **ক্যাশে ক্লিয়ার করুন:** মোবাইলের Settings -> Apps -> SmartVote -> **Clear Cache** দিন এবং অ্যাপ রিস্টার্ট করুন।'''
            : '''### 🛠️ How to Fix White Screen / Blank Loading Freeze

**Root Cause:**
A white or frozen screen typically occurs when an asynchronous stream or future encounters an unhandled null exception before data completes loading.

**Direct Fix Steps:**
1. **Add Null-Safety Fallbacks:** Always use `?? 'N/A'` when rendering user/org fields.
2. **Handle Connection States:** In `StreamBuilder` and `FutureBuilder`, provide explicit loading widgets for `ConnectionState.waiting`.
3. **Clear Mobile App Cache:** In Android Settings -> Apps -> SmartVote -> Clear App Cache & restart.''',
        suggestedActions: [
          'ভোটার লগইন সমস্যা সমাধান',
          'সার্ভার কানেকশন এরর ফিক্স',
          'ব্লকচেইন অডিট কীভাবে করব?',
        ],
      );
    }

    // 3. Candidate Photo Upload Error / Black Screen / Crash
    if (q.contains('photo') && (q.contains('upload') || q.contains('error') || q.contains('ashe na') || q.contains('fail') || q.contains('problem') || q.contains('kore na'))) {
      return AiMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: 'Camera & Media Fix',
        isUser: false,
        timestamp: DateTime.now(),
        text: isBn
            ? '''### 🛠️ প্রার্থীর ছবি আপলোড না হওয়া বা ক্র্যাশ করার সমাধান (Photo Upload Fix)

**সমস্যার সম্ভাব্য কারণ:**
১. অ্যান্ড্রয়েড ফোনে ক্যামেরার বা স্টোরেজের পারমিশন এলাউ (Allow) করা নেই।
২. নির্বাচিত ছবির ফাইল সাইজ অতিরিক্ত বড় (যেমন: ১০-১৫ মেগাবাইটের বেশি)।
৩. ইমেজ ইউআরএল (Image URL) দিলে সেটি ব্রাউজারে সরাসরি ভিউ করা যায় না।

**সরাসরি সমাধানের উপায়:**
1. **পারমিশন চেক:** মোবাইলের Settings -> Apps -> SmartVote -> **Permissions**-এ গিয়ে **Camera** এবং **Photos/Storage** চালু আছে কিনা নিশ্চিত করুন।
2. **ইমেজ কম্প্রেশন:** ছবি তোলার সময় `imageQuality: 70` এবং `maxWidth: 600` ব্যবহার করলে ছবি দ্রুত ও হালকা সাইজে আপলোড হয়।
3. **বিকল্প সমাধান (Direct Image URL):** সরাসরি ছবি আপলোডে নেটওয়ার্ক সমস্যা হলে ছবির একটি ক্লাউড বা ড্রাইভ লিংক "Image URL" ফিল্ডে পেস্ট করে দিন—ছবি সাথে সাথে দেখা যাবে!'''
            : '''### 🛠️ How to Fix Candidate Photo Upload Failure

**Root Causes:**
1. Camera or Storage permission was denied in Android device settings.
2. High-resolution raw image (>10MB) causing out-of-memory timeout.

**Direct Fix Steps:**
1. **Verify Android Permissions:** Go to Phone Settings -> Apps -> SmartVote -> Permissions -> Grant Camera & Photos.
2. **Image Downscaling:** Compress captured images with `imageQuality: 70` and `maxWidth: 600`.
3. **Use Public Image URL:** Alternatively, paste a direct web image URL in the Candidate setup field for instant display.''',
        suggestedActions: [
          'নতুন ইলেকশন তৈরির নিয়ম',
          'ভোটার হোয়াইটলিস্ট এড করার উপায়',
          'ব্লকচেইন কীভাবে কাজ করে?',
        ],
      );
    }

    // 4. Fallback to 1,000+ Pattern Semantic Classifier with Generative AI Advice
    final matched = AiTrainedKnowledgeEngine.matchIntent(query);
    final responseText = isBn ? matched.responseBn : matched.responseEn;
    final followUps = isBn ? matched.suggestedFollowUpsBn : matched.suggestedFollowUpsEn;

    final hintText = isBn
        ? '\n\n---\n💡 **স্বয়ংক্রিয় এআই সমাধান টিপস:** আপনি যদি যেকোনো কাস্টম সমস্যায় (কোড বা স্ক্রিনের যেকোনো জটিল এরর) শতভাগ নিজস্ব চিন্তা ও সমাধান চান, উপরের 🔑 আইকনে ট্যাপ করে আপনার ফ্রি **Google Gemini API Key** বসিয়ে নিন!'
        : '\n\n---\n💡 **Autonomous AI Tip:** For custom, open-ended generative problem-solving on any unique error, tap the 🔑 icon on the top right to insert your free **Google Gemini API Key**!';

    return AiMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: matched.category,
      isUser: false,
      timestamp: DateTime.now(),
      text: '$responseText$hintText',
      suggestedActions: followUps,
    );
  }
}
