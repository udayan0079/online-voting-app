import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../providers/whitelist_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/empty_state.dart';

class ManageWhitelistScreen extends StatefulWidget {
  const ManageWhitelistScreen({super.key});

  @override
  State<ManageWhitelistScreen> createState() => _ManageWhitelistScreenState();
}

class _ManageWhitelistScreenState extends State<ManageWhitelistScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WhitelistProvider>(context, listen: false).fetchWhitelist();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddSingleDialog() {
    final idController = TextEditingController();
    final nameController = TextEditingController();
    final deptController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Authorize Single Voter ID', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: idController,
                label: 'Company / Employee ID',
                hint: 'e.g. EMP-205',
                isUppercase: true,
                validator: (v) => v == null || v.trim().isEmpty ? 'Company ID is required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: nameController,
                label: 'Employee Name (Optional)',
                hint: 'e.g. Farhana Yasmin',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: deptController,
                label: 'Department (Optional)',
                hint: 'e.g. Human Resources',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final provider = Provider.of<WhitelistProvider>(context, listen: false);
              final success = await provider.addSingleId(
                companyId: idController.text.trim(),
                name: nameController.text.trim(),
                department: deptController.text.trim(),
              );

              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'ID ${idController.text.trim().toUpperCase()} authorized!'
                          : provider.errorMessage ?? 'Failed to authorize ID',
                    ),
                    backgroundColor: success ? AppTheme.success : AppTheme.danger,
                  ),
                );
              }
            },
            child: const Text('Add to Whitelist'),
          ),
        ],
      ),
    );
  }

  void _showBulkAddDialog() {
    final bulkController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bulk Authorize Voter IDs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste employee/student IDs separated by commas or new lines. Example:\nEMP-101, EMP-102, EMP-103',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: bulkController,
              maxLines: 5,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'EMP-101\nEMP-102\nEMP-103',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (bulkController.text.trim().isEmpty) return;
              final provider = Provider.of<WhitelistProvider>(context, listen: false);
              final success = await provider.addBulkIds(bulkController.text.trim());

              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Bulk IDs imported successfully!' : provider.errorMessage ?? 'Failed to import IDs',
                    ),
                    backgroundColor: success ? AppTheme.success : AppTheme.danger,
                  ),
                );
              }
            },
            child: const Text('Import All IDs'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WhitelistProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Authorized Voter Whitelist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Bulk Import IDs',
            onPressed: _showBulkAddDialog,
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Single ID',
            onPressed: _showAddSingleDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatPill('Total Authorized', provider.totalAuthorized.toString(), AppTheme.primary),
                _buildStatPill('Registered', provider.registeredVoters.toString(), AppTheme.success),
                _buildStatPill('Pending', provider.pendingRegistration.toString(), AppTheme.warning),
              ],
            ),
          ),
          const Divider(height: 1),

          // Search and Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Company ID, Name, or Dept...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              provider.fetchWhitelist(status: _selectedFilter);
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (val) {
                    provider.fetchWhitelist(search: val, status: _selectedFilter);
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildFilterChoice('all', 'All IDs'),
                    const SizedBox(width: 8),
                    _buildFilterChoice('registered', 'Registered Voters'),
                    const SizedBox(width: 8),
                    _buildFilterChoice('pending', 'Pending Sign-up'),
                  ],
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.whitelist.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.shield_outlined,
                        title: 'No Authorized IDs Found',
                        subtitle: 'Add company employee IDs so that only authorized personnel can register and vote.',
                        buttonText: 'Add First ID',
                        onButtonPressed: _showAddSingleDialog,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.whitelist.length,
                        itemBuilder: (ctx, index) {
                          final item = provider.whitelist[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: item.isRegistered
                                      ? AppTheme.success.withOpacity(0.1)
                                      : AppTheme.warning.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item.isRegistered ? Icons.check_circle : Icons.pending_outlined,
                                  color: item.isRegistered ? AppTheme.success : AppTheme.warning,
                                  size: 22,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    item.companyId,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: item.isRegistered
                                          ? const Color(0xFFDCFCE7)
                                          : const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.isRegistered ? 'REGISTERED' : 'PENDING',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: item.isRegistered
                                            ? const Color(0xFF15803D)
                                            : const Color(0xFFB45309),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                item.name.isNotEmpty
                                    ? '${item.name} • ${item.department.isNotEmpty ? item.department : "General"}'
                                    : (item.department.isNotEmpty ? item.department : 'Awaiting voter registration'),
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                              trailing: !item.isRegistered
                                  ? IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
                                      tooltip: 'Remove ID',
                                      onPressed: () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (dCtx) => AlertDialog(
                                            title: const Text('Remove Authorized ID?'),
                                            content: Text('Are you sure you want to remove ${item.companyId}?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancel')),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                                                onPressed: () => Navigator.pop(dCtx, true),
                                                child: const Text('Remove'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmed == true) {
                                          await provider.deleteId(item.id);
                                        }
                                      },
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Bulk Import IDs',
                icon: Icons.upload_file,
                isOutlined: true,
                onPressed: _showBulkAddDialog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Add Single ID',
                icon: Icons.add,
                onPressed: _showAddSingleDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildFilterChoice(String key, String label) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppTheme.textMain,
      ),
      selectedColor: AppTheme.primary,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (_) {
        setState(() {
          _selectedFilter = key;
        });
        Provider.of<WhitelistProvider>(context, listen: false).fetchWhitelist(
          search: _searchController.text,
          status: key,
        );
      },
    );
  }
}
