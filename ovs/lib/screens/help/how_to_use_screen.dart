import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/storage/storage_service.dart';
import '../../data/how_to_use_data.dart';

class HowToUseScreen extends StatefulWidget {
  const HowToUseScreen({super.key});

  @override
  State<HowToUseScreen> createState() => _HowToUseScreenState();
}

class _HowToUseScreenState extends State<HowToUseScreen> {
  late String _selectedLangCode;
  late GuideContent _guideContent;
  String _selectedCategory = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLangCode = StorageService.getGuideLanguage();
    _guideContent = HowToUseData.getGuide(_selectedLangCode);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onLanguageSelected(String langCode) async {
    await StorageService.saveGuideLanguage(langCode);
    setState(() {
      _selectedLangCode = langCode;
      _guideContent = HowToUseData.getGuide(langCode);
    });
  }

  void _showLanguagePicker() {
    final searchCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final query = searchCtrl.text.trim().toLowerCase();
          final filteredLangs = HowToUseData.languages.where((l) {
            return l.name.toLowerCase().contains(query) ||
                l.nativeName.toLowerCase().contains(query) ||
                l.code.toLowerCase().contains(query);
          }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.78,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Drag handle
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),

                // Modal Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.language, color: AppTheme.primary, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Language (50 Languages)',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textMain),
                            ),
                            Text(
                              'Sorted Alphabetically (A to Z)',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Search Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search language (e.g. English, Bengali, Spanish)...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),

                // Language List (Alphabetical)
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredLangs.length,
                    separatorBuilder: (_, __) => Divider(height: 1, indent: 64, color: Colors.grey.shade200),
                    itemBuilder: (c, idx) {
                      final item = filteredLangs[idx];
                      final isSelected = item.code == _selectedLangCode;

                      return ListTile(
                        leading: Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary.withOpacity(0.1) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.flagEmoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? AppTheme.primary : AppTheme.textMain,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.code.toUpperCase(),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          item.nativeName,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: AppTheme.primary, size: 22)
                            : null,
                        onTap: () {
                          Navigator.pop(ctx);
                          _onLanguageSelected(item.code);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter sections based on category and search query
    final filteredSections = _guideContent.sections.where((sec) {
      final matchesCategory = _selectedCategory == 'ALL' || sec.category == _selectedCategory;
      if (!matchesCategory) return false;

      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return sec.title.toLowerCase().contains(q) ||
          sec.subtitle.toLowerCase().contains(q) ||
          sec.steps.any((s) => s.toLowerCase().contains(q)) ||
          sec.tip.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(_guideContent.screenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: AppTheme.primary),
            tooltip: _guideContent.changeLang,
            onPressed: _showLanguagePicker,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Language Selector Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: InkWell(
                onTap: _showLanguagePicker,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _guideContent.language.flagEmoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_guideContent.language.name} • ${_guideContent.language.nativeName}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                            Text(
                              _guideContent.changeLang,
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.swap_vert, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'A-Z (50)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: _guideContent.searchHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                ),
              ),
            ),

            // Category Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: _guideContent.categories.entries.map((entry) {
                  final isSelected = _selectedCategory == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(entry.value),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppTheme.textMain,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: AppTheme.primary,
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? AppTheme.primary : AppTheme.border,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = entry.key;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // Guide Sections List
            Expanded(
              child: filteredSections.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 54, color: AppTheme.textMuted),
                          const SizedBox(height: 12),
                          const Text(
                            'No matching guide topics found',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textMain),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try clearing your search query or switching categories.',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                      itemCount: filteredSections.length,
                      itemBuilder: (ctx, index) {
                        final sec = filteredSections[index];
                        return _buildSectionCard(sec);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(GuideSection sec) {
    Color categoryColor;
    switch (sec.category) {
      case 'ADMIN':
        categoryColor = AppTheme.primary;
        break;
      case 'VOTER':
        categoryColor = const Color(0xFF15803D);
        break;
      case 'SECURITY':
        categoryColor = const Color(0xFF7C3AED);
        break;
      case 'OVERVIEW':
      default:
        categoryColor = const Color(0xFF2563EB);
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border, width: 1.2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: sec.id == 'overview' || sec.id == 'whitelist',
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(sec.icon, color: categoryColor, size: 24),
          ),
          title: Text(
            sec.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textMain),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              sec.subtitle,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ),
          children: [
            const Divider(height: 1, color: AppTheme.border),
            const SizedBox(height: 14),

            // Step by Step List
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sec.steps.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final text = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$idx',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: categoryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF334155),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            // Pro Tip Box
            if (sec.tip.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 18, color: Color(0xFFB45309)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sec.tip,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
