import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../core/services/ai_bot_service.dart';
import '../../models/ai_message_model.dart';
import '../../providers/auth_provider.dart';

class AdminAiChatbotScreen extends StatefulWidget {
  const AdminAiChatbotScreen({super.key});

  @override
  State<AdminAiChatbotScreen> createState() => _AdminAiChatbotScreenState();
}

class _AdminAiChatbotScreenState extends State<AdminAiChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AiMessageModel> _messages = [];
  bool _isTyping = false;

  final List<String> _quickPrompts = [
    '🔗 ব্লকচেইন কীভাবে কাজ করে?',
    '📋 Whitelist কীভাবে যুক্ত করব?',
    '🗳️ নতুন Election তৈরির নিয়ম',
    '⏱️ টাইমার শেষ হলে কী হবে?',
    '📸 প্রার্থীর ছবি আপলোড হচ্ছে না',
    '👤 ভোটার লগইন করতে পারছে না',
    '🌐 Server Connection Error সমাধান',
    '📜 VOTE রসিদ ভেরিফাই কীভাবে করে?',
    '🔒 ভোট কি সত্যিই গোপন থাকে?',
  ];

  @override
  void initState() {
    super.initState();
    _addInitialWelcomeMessage();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addInitialWelcomeMessage() {
    _messages.add(
      AiMessageModel(
        id: 'welcome',
        isUser: false,
        timestamp: DateTime.now(),
        category: 'AI Assistant Ready (1,000+ Trained Patterns)',
        text: '''আসসালামু আলাইকুম ও শুভেচ্ছা! 🤖

আমি আপনার **SmartVote AI Assistant**। ১,০০০+ প্যাটার্ন ও ক্রিপ্টোগ্রাফিক ব্লকচেইন নলেজ দিয়ে আমাকে ট্রেইন করা হয়েছে। 

অ্যাডমিন ড্যাশবোর্ড, ব্লকচেইন অডিট, ভোটার হোয়াইটলিস্ট, নির্বাচন তৈরি, প্রার্থীর ছবি/প্রতীক, টাইমার বা সার্ভার সংক্রান্ত যেকোনো সমস্যায় রিয়েল-টাইমে সমাধান দিতে আমি প্রস্তুত।

নিচের যেকোনো প্রশ্নে ট্যাপ করতে পারেন অথবা আপনার সমস্যাটি বাংলায়, বাংলিশে বা ইংরেজিতে লিখুন!''',
        suggestedActions: [
          '🔗 ব্লকচেইন কীভাবে কাজ করে?',
          '📋 Whitelist কীভাবে যুক্ত করব?',
          '🗳️ নতুন Election তৈরির নিয়ম',
          '👤 ভোটার লগইন করতে পারছে না',
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage([String? predefinedText]) async {
    final text = predefinedText ?? _textController.text.trim();
    if (text.isEmpty) return;

    if (predefinedText == null) {
      _textController.clear();
    }

    final userMessage = AiMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });
    _scrollToBottom();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final org = auth.currentOrg;

    // Simulate smart thinking transition for realistic feel
    await Future.delayed(const Duration(milliseconds: 350));

    final aiResponse = await AiBotService.getAiResponse(
      query: text,
      currentOrgCode: org?.orgCode,
      currentOrgName: org?.name,
    );

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(aiResponse);
      });
      _scrollToBottom();
    }
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Chat History?'),
        content: const Text('Are you sure you want to clear your current conversation with the AI assistant?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _messages.clear();
                _addInitialWelcomeMessage();
              });
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(Icons.smart_toy_rounded, color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SmartVote AI Assistant',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppTheme.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Live & Deep Reasoning Ready',
                        style: TextStyle(fontSize: 11, color: AppTheme.success, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear Chat',
            onPressed: _clearChat,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Quick Action Prompt Bar
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: _quickPrompts.length,
                itemBuilder: (ctx, idx) {
                  final prompt = _quickPrompts[idx];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => _handleSendMessage(prompt),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                        ),
                        child: Text(
                          prompt,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Messages View
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (ctx, idx) {
                  final msg = _messages[idx];
                  return _buildMessageTile(msg);
                },
              ),
            ),

            // Animated Typing Indicator
            if (_isTyping)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AI is analyzing your problem...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Chat Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _textController,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Ask AI a question (বাংলা বা English)...',
                          hintStyle: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        ),
                        onSubmitted: (_) => _handleSendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => _handleSendMessage(),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageTile(AiMessageModel msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, Color(0xFF1E40AF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            msg.text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Badge & Category
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: AppTheme.primary, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  msg.category ?? 'AI Assistant',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 16, color: AppTheme.textMuted),
                  tooltip: 'Copy Answer',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: msg.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied AI resolution to clipboard!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),

            // AI Content Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SelectableText(
                msg.text,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppTheme.textMain,
                  height: 1.5,
                ),
              ),
            ),

            // Suggested Follow-up Actions
            if (msg.suggestedActions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: msg.suggestedActions.map((action) {
                  return ActionChip(
                    label: Text(
                      action,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary),
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    onPressed: () => _handleSendMessage(action),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
