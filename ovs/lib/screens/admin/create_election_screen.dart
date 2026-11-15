import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_theme.dart';
import '../../providers/election_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateElectionScreen extends StatefulWidget {
  const CreateElectionScreen({super.key});

  @override
  State<CreateElectionScreen> createState() => _CreateElectionScreenState();
}

class _CreateElectionScreenState extends State<CreateElectionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 4));

  final List<Map<String, dynamic>> _candidates = [];

  @override
  void initState() {
    super.initState();
    // Default 2 blank candidates
    _candidates.add({
      'name': '',
      'companyId': '',
      'symbolName': '',
      'photoUrl': '',
      'logoUrl': '',
      'bio': '',
    });
    _candidates.add({
      'name': '',
      'companyId': '',
      'symbolName': '',
      'photoUrl': '',
      'logoUrl': '',
      'bio': '',
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final initialDate = isStart ? _startTime : _endTime;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null || !mounted) return;

    final newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isStart) {
        _startTime = newDateTime;
        if (_endTime.isBefore(_startTime)) {
          _endTime = _startTime.add(const Duration(hours: 2));
        }
      } else {
        _endTime = newDateTime;
      }
    });
  }

  Future<String?> _pickImageAsBase64(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 360,
        maxHeight: 360,
        imageQuality: 70,
      );
      if (picked == null) return null;
      final bytes = await picked.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: AppTheme.danger),
        );
      }
      return null;
    }
  }

  Widget _buildImageThumb(String src, double size, {bool isCircle = false}) {
    if (src.isEmpty) {
      return Icon(isCircle ? Icons.person : Icons.stars, size: size * 0.55, color: AppTheme.primary);
    }
    try {
      Widget img;
      if (src.startsWith('data:image') || src.contains(';base64,')) {
        final b64 = src.contains(';base64,') ? src.split(';base64,').last : src;
        img = Image.memory(base64Decode(b64), width: size, height: size, fit: BoxFit.cover);
      } else if (src.startsWith('http')) {
        img = Image.network(src, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.broken_image, size: size * 0.5));
      } else {
        img = Image.memory(base64Decode(src), width: size, height: size, fit: BoxFit.cover);
      }
      return isCircle ? ClipOval(child: img) : ClipRRect(borderRadius: BorderRadius.circular(8), child: img);
    } catch (_) {
      return Icon(isCircle ? Icons.person : Icons.stars, size: size * 0.55, color: AppTheme.primary);
    }
  }

  void _showAddCandidateDialog([int? editIndex]) {
    final isEditing = editIndex != null;
    final existing = isEditing ? _candidates[editIndex] : null;

    final nameController = TextEditingController(text: existing?['name'] ?? '');
    final idController = TextEditingController(text: existing?['companyId'] ?? '');
    final symbolController = TextEditingController(text: existing?['symbolName'] ?? '');
    final bioController = TextEditingController(text: existing?['bio'] ?? '');
    String photoUrl = existing?['photoUrl'] ?? '';
    String logoUrl = existing?['logoUrl'] ?? '';
    final cFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pickPhoto() async {
            final choice = await showModalBottomSheet<String>(
              context: context,
              builder: (bCtx) => SafeArea(
                child: Wrap(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt_outlined, color: AppTheme.primary),
                      title: const Text('Take Photo (Camera)'),
                      onTap: () => Navigator.pop(bCtx, 'camera'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library_outlined, color: AppTheme.primary),
                      title: const Text('Choose from Gallery'),
                      onTap: () => Navigator.pop(bCtx, 'gallery'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.link, color: AppTheme.primary),
                      title: const Text('Paste Photo Web URL'),
                      onTap: () => Navigator.pop(bCtx, 'url'),
                    ),
                    if (photoUrl.isNotEmpty)
                      ListTile(
                        leading: const Icon(Icons.delete_outline, color: AppTheme.danger),
                        title: const Text('Remove Photo', style: TextStyle(color: AppTheme.danger)),
                        onTap: () => Navigator.pop(bCtx, 'remove'),
                      ),
                  ],
                ),
              ),
            );

            if (choice == 'camera') {
              final img = await _pickImageAsBase64(ImageSource.camera);
              if (img != null) setDialogState(() => photoUrl = img);
            } else if (choice == 'gallery') {
              final img = await _pickImageAsBase64(ImageSource.gallery);
              if (img != null) setDialogState(() => photoUrl = img);
            } else if (choice == 'url') {
              final urlController = TextEditingController();
              if (context.mounted) {
                final enteredUrl = await showDialog<String>(
                  context: context,
                  builder: (dCtx) => AlertDialog(
                    title: const Text('Enter Image URL', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    content: TextField(
                      controller: urlController,
                      decoration: const InputDecoration(hintText: 'https://example.com/photo.jpg'),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Cancel')),
                      ElevatedButton(onPressed: () => Navigator.pop(dCtx, urlController.text.trim()), child: const Text('Use URL')),
                    ],
                  ),
                );
                if (enteredUrl != null && enteredUrl.isNotEmpty) {
                  setDialogState(() => photoUrl = enteredUrl);
                }
              }
            } else if (choice == 'remove') {
              setDialogState(() => photoUrl = '');
            }
          }

          Future<void> pickLogo() async {
            final choice = await showModalBottomSheet<String>(
              context: context,
              builder: (bCtx) => SafeArea(
                child: Wrap(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_library_outlined, color: AppTheme.primary),
                      title: const Text('Upload Symbol Image (Gallery / Camera)'),
                      onTap: () => Navigator.pop(bCtx, 'gallery'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.emoji_events_outlined, color: AppTheme.primary),
                      title: const Text('Pick Quick Corporate Symbol Preset'),
                      onTap: () => Navigator.pop(bCtx, 'preset'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.link, color: AppTheme.primary),
                      title: const Text('Paste Logo Web URL'),
                      onTap: () => Navigator.pop(bCtx, 'url'),
                    ),
                    if (logoUrl.isNotEmpty)
                      ListTile(
                        leading: const Icon(Icons.delete_outline, color: AppTheme.danger),
                        title: const Text('Remove Logo', style: TextStyle(color: AppTheme.danger)),
                        onTap: () => Navigator.pop(bCtx, 'remove'),
                      ),
                  ],
                ),
              ),
            );

            if (choice == 'gallery') {
              final img = await _pickImageAsBase64(ImageSource.gallery);
              if (img != null) setDialogState(() => logoUrl = img);
            } else if (choice == 'preset') {
              final presets = [
                {'name': 'Eagle of Vision 🦅', 'symbol': 'Eagle 🦅'},
                {'name': 'Lion of Courage 🦁', 'symbol': 'Lion 🦁'},
                {'name': 'Star of Excellence 🌟', 'symbol': 'Star 🌟'},
                {'name': 'Scale of Justice ⚖️', 'symbol': 'Scale ⚖️'},
                {'name': 'Shield of Integrity 🛡️', 'symbol': 'Shield 🛡️'},
                {'name': 'Rising Sun of Hope ☀️', 'symbol': 'Rising Sun ☀️'},
                {'name': 'Rocket of Progress 🚀', 'symbol': 'Rocket 🚀'},
                {'name': 'Bulb of Innovation 💡', 'symbol': 'Innovation 💡'},
                {'name': 'Tree of Sustainability 🌳', 'symbol': 'Green Tree 🌳'},
                {'name': 'Global Horizon 🌐', 'symbol': 'Global 🌐'},
              ];

              if (context.mounted) {
                final selected = await showModalBottomSheet<Map<String, String>>(
                  context: context,
                  builder: (pCtx) => SafeArea(
                    child: ListView.builder(
                      itemCount: presets.length,
                      itemBuilder: (ctx, idx) => ListTile(
                        title: Text(presets[idx]['name']!),
                        onTap: () => Navigator.pop(pCtx, presets[idx]),
                      ),
                    ),
                  ),
                );

                if (selected != null) {
                  setDialogState(() {
                    symbolController.text = selected['name']!;
                  });
                }
              }
            } else if (choice == 'url') {
              final urlController = TextEditingController();
              if (context.mounted) {
                final enteredUrl = await showDialog<String>(
                  context: context,
                  builder: (dCtx) => AlertDialog(
                    title: const Text('Enter Logo URL', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    content: TextField(
                      controller: urlController,
                      decoration: const InputDecoration(hintText: 'https://example.com/logo.png'),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Cancel')),
                      ElevatedButton(onPressed: () => Navigator.pop(dCtx, urlController.text.trim()), child: const Text('Use URL')),
                    ],
                  ),
                );
                if (enteredUrl != null && enteredUrl.isNotEmpty) {
                  setDialogState(() => logoUrl = enteredUrl);
                }
              }
            } else if (choice == 'remove') {
              setDialogState(() => logoUrl = '');
            }
          }

          return AlertDialog(
            title: Text(isEditing ? 'Edit Candidate Info' : 'Add Candidate to Ballot', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(
              child: Form(
                key: cFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Candidate Photo Picker Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primary.withOpacity(0.1),
                              border: Border.all(color: AppTheme.primary, width: 1.5),
                            ),
                            child: _buildImageThumb(photoUrl, 58, isCircle: true),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Candidate Photo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(
                                  photoUrl.isNotEmpty ? '✓ Photo selected' : 'No photo uploaded yet',
                                  style: TextStyle(fontSize: 11, color: photoUrl.isNotEmpty ? AppTheme.success : AppTheme.textMuted),
                                ),
                                const SizedBox(height: 6),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  ),
                                  icon: const Icon(Icons.camera_alt, size: 14),
                                  label: Text(photoUrl.isNotEmpty ? 'Change Photo' : 'Upload Photo', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                  onPressed: pickPhoto,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Symbol / Logo Picker Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppTheme.accent.withOpacity(0.1),
                              border: Border.all(color: AppTheme.accent, width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: _buildImageThumb(logoUrl, 50),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Campaign Symbol / Logo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(
                                  logoUrl.isNotEmpty ? '✓ Logo graphic attached' : 'Upload or pick symbol below',
                                  style: TextStyle(fontSize: 11, color: logoUrl.isNotEmpty ? AppTheme.success : AppTheme.textMuted),
                                ),
                                const SizedBox(height: 6),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  ),
                                  icon: const Icon(Icons.stars, size: 14),
                                  label: Text(logoUrl.isNotEmpty ? 'Change Logo' : 'Upload Logo / Symbol', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                  onPressed: pickLogo,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    CustomTextField(
                      controller: nameController,
                      label: 'Candidate Full Name',
                      hint: 'e.g. Nusrat Jahan',
                      validator: (v) => v == null || v.trim().isEmpty ? 'Candidate name is required' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: idController,
                      label: 'Candidate Company ID',
                      hint: 'e.g. HR-01 or EMP-105',
                      isUppercase: true,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Company ID is required' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: symbolController,
                      label: 'Symbol / Campaign Logo Name',
                      hint: 'e.g. Eagle of Growth or Rising Sun ☀️',
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: bioController,
                      label: 'Manifesto / Bio / Key Agenda',
                      hint: 'Summary of goals and vision...',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (!cFormKey.currentState!.validate()) return;
                  final candidateData = {
                    'name': nameController.text.trim(),
                    'companyId': idController.text.trim().toUpperCase(),
                    'symbolName': symbolController.text.trim(),
                    'photoUrl': photoUrl.trim(),
                    'logoUrl': logoUrl.trim(),
                    'bio': bioController.text.trim(),
                  };

                  setState(() {
                    if (isEditing) {
                      _candidates[editIndex] = candidateData;
                    } else {
                      _candidates.add(candidateData);
                    }
                  });

                  Navigator.pop(ctx);
                },
                child: Text(isEditing ? 'Update' : 'Add Candidate'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitElection() async {
    if (!_formKey.currentState!.validate()) return;

    if (_endTime.isBefore(_startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Election end time must be after start time.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    // Filter valid candidates
    final validCandidates = _candidates
        .where((c) => (c['name'] ?? '').toString().trim().isNotEmpty && (c['companyId'] ?? '').toString().trim().isNotEmpty)
        .toList();

    if (validCandidates.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least 2 valid candidates with Name and Company ID.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    final provider = Provider.of<ElectionProvider>(context, listen: false);
    final success = await provider.createElection(
      title: _titleController.text.trim(),
      category: _categoryController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: _startTime,
      endTime: _endTime,
      candidates: validCandidates,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voting portal successfully created & scheduled!'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to create election'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ElectionProvider>(context);
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Voting Portal'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Election & Position Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textMain),
              ),
              const SizedBox(height: 4),
              const Text(
                'Configure the position, schedule, and candidate nominations.',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 20),

              // Title
              CustomTextField(
                controller: _titleController,
                label: 'Election Title',
                hint: 'e.g. Annual HR Representative Election 2026',
                prefixIcon: Icons.how_to_vote,
                validator: (v) => v == null || v.trim().isEmpty ? 'Election title is required' : null,
              ),
              const SizedBox(height: 16),

              // Category / Subject
              CustomTextField(
                controller: _categoryController,
                label: 'Position / Category / Subject (Type or Pick below)',
                hint: 'e.g. HR, CR, President, Prime Minister, MP',
                prefixIcon: Icons.badge_outlined,
                validator: (v) => v == null || v.trim().isEmpty ? 'Position/category is required' : null,
              ),
              const SizedBox(height: 8),

              // Quick Pick Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: AppConstants.popularCategories.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(cat, style: const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppTheme.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        onPressed: () {
                          setState(() {
                            _categoryController.text = cat;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _descriptionController,
                label: 'Description & Voting Rules (Optional)',
                hint: 'Guidelines, criteria, voting rules...',
                prefixIcon: Icons.description_outlined,
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // Schedule Section
              const Text(
                'VOTING TIMELINE',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: 0.5),
              ),
              const Divider(height: 16),

              // Start Time
              Card(
                child: ListTile(
                  leading: const Icon(Icons.play_circle_outline, color: AppTheme.success),
                  title: const Text('Voting Starts At', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(dateFormat.format(_startTime), style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textMain)),
                  trailing: const Icon(Icons.edit_calendar, size: 20, color: AppTheme.primary),
                  onTap: () => _pickDateTime(isStart: true),
                ),
              ),

              // End Time
              Card(
                child: ListTile(
                  leading: const Icon(Icons.stop_circle_outlined, color: AppTheme.danger),
                  title: const Text('Voting Ends At (Auto-Result Publish)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(dateFormat.format(_endTime), style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textMain)),
                  trailing: const Icon(Icons.edit_calendar, size: 20, color: AppTheme.primary),
                  onTap: () => _pickDateTime(isStart: false),
                ),
              ),

              const SizedBox(height: 28),

              // Candidates Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CANDIDATES & BALLOT NOMINEES',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: 0.5),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    icon: const Icon(Icons.person_add, size: 16),
                    label: const Text('Add Nominee', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    onPressed: () => _showAddCandidateDialog(),
                  ),
                ],
              ),
              const Divider(height: 14),

              // Candidates List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _candidates.length,
                itemBuilder: (ctx, index) {
                  final cand = _candidates[index];
                  final hasName = (cand['name'] ?? '').toString().isNotEmpty;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.border, width: 1.5),
                            ),
                            clipBehavior: Clip.antiAlias,
                            alignment: Alignment.center,
                            child: (cand['photoUrl'] ?? '').toString().isNotEmpty
                                ? _buildImageThumb(cand['photoUrl'], 46, isCircle: true)
                                : Text(
                                    hasName ? cand['name'][0].toUpperCase() : '${index + 1}',
                                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary, fontSize: 16),
                                  ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: hasName
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cand['name'],
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            'ID: ${cand['companyId']}',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                                          ),
                                          if ((cand['symbolName'] ?? '').toString().isNotEmpty || (cand['logoUrl'] ?? '').toString().isNotEmpty) ...[
                                            const SizedBox(width: 6),
                                            const Text('•', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                            const SizedBox(width: 6),
                                            if ((cand['logoUrl'] ?? '').toString().isNotEmpty) ...[
                                              Container(
                                                width: 16,
                                                height: 16,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(3),
                                                  border: Border.all(color: AppTheme.border, width: 0.5),
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: _buildImageThumb(cand['logoUrl'], 16),
                                              ),
                                              const SizedBox(width: 4),
                                            ],
                                            Expanded(
                                              child: Text(
                                                cand['symbolName'].toString().isNotEmpty ? cand['symbolName'] : 'Logo Attached',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.accent),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  )
                                : Text(
                                    'Nominee #${index + 1} (Tap to fill details & photo)',
                                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                                  ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primary),
                            onPressed: () => _showAddCandidateDialog(index),
                          ),
                          if (_candidates.length > 2)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.danger),
                              onPressed: () {
                                setState(() {
                                  _candidates.removeAt(index);
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              CustomButton(
                text: 'Launch & Schedule Voting Portal',
                isLoading: provider.isLoading,
                icon: Icons.rocket_launch_outlined,
                onPressed: _submitElection,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
