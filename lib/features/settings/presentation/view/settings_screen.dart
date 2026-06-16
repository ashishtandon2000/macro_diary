import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/widgets/ui_util.dart';
import 'package:macro_diary/features/backup/data/services/backup_file_service.dart';
import 'package:macro_diary/features/backup/data/services/backup_service.dart';
import 'package:macro_diary/features/dashboard/presentation/view_model/dashboard_viewmodel.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Set<BackupSection> _exportSections = BackupSection.values.toSet();
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    final isBusy = _isExporting || _isImporting;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Text(
            "Backup",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            "Export a JSON backup file or import data from an older backup.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text(
            "Export Backup",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...BackupSection.values.map(_exportSectionTile),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed:
                  isBusy || _exportSections.isEmpty ? null : _exportBackup,
              icon: _isExporting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_download_outlined),
              label: const Text("Export Backup"),
            ),
          ),
          const Divider(height: 40),
          Text(
            "Import Backup",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Import merges data from a backup file. Matching existing records are skipped.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: isBusy ? null : _importBackup,
              icon: _isImporting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_upload_outlined),
              label: const Text("Import Backup"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _exportSectionTile(BackupSection section) {
    final selected = _exportSections.contains(section);
    final enabled = section != BackupSection.meals ||
        _exportSections.contains(BackupSection.foods);

    return CheckboxListTile(
      value: selected && enabled,
      enabled: enabled,
      contentPadding: EdgeInsets.zero,
      title: Text(section.label),
      subtitle: Text(_sectionDescription(section)),
      onChanged: (value) {
        setState(() {
          final nextSections = {..._exportSections};
          if (value == true) {
            nextSections.add(section);
            if (section == BackupSection.meals) {
              nextSections.add(BackupSection.foods);
            }
          } else {
            nextSections.remove(section);
            if (section == BackupSection.foods) {
              nextSections.remove(BackupSection.meals);
            }
          }
          _exportSections = nextSections;
        });
      },
    );
  }

  Future<void> _exportBackup() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final backupJson = await ref
          .read(backupServiceProvider)
          .createBackupJson(_exportSections);
      final savedLocation =
          await ref.read(backupFileServiceProvider).exportBackup(
                fileName: _backupFileName(),
                contents: backupJson,
              );

      if (!mounted) return;
      if (savedLocation == null) {
        _showMessage("Backup export cancelled.");
      } else {
        _showMessage("Backup exported.");
      }
    } catch (error) {
      if (!mounted) return;
      _showMessage("Failed to export backup: $error");
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _importBackup() async {
    try {
      final backupJson =
          await ref.read(backupFileServiceProvider).importBackup();
      if (backupJson == null) {
        if (!mounted) return;
        _showMessage("Backup import cancelled.");
        return;
      }

      final preview = ref.read(backupServiceProvider).previewBackup(backupJson);
      if (!mounted) return;
      if (preview.availableSections.isEmpty) {
        _showMessage("This backup does not contain importable data.");
        return;
      }

      final selectedSections = await showDialog<Set<BackupSection>>(
        context: context,
        builder: (context) => _ImportBackupDialog(preview: preview),
      );
      if (selectedSections == null || selectedSections.isEmpty) return;

      setState(() {
        _isImporting = true;
      });

      final result = await ref
          .read(backupServiceProvider)
          .importBackupJson(backupJson, selectedSections);
      await ref.read(dashboardProvider.notifier).refresh();

      if (!mounted) return;
      _showMessage(_importResultMessage(result, selectedSections));
    } catch (error) {
      if (!mounted) return;
      _showMessage("Failed to import backup: $error");
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  String _sectionDescription(BackupSection section) {
    switch (section) {
      case BackupSection.foods:
        return "Saved food names, units, macros, and USDA references.";
      case BackupSection.meals:
        return "Requires food items because meals reference saved foods.";
      case BackupSection.diary:
        return "Daily summary entries with their saved macro snapshots.";
      case BackupSection.userData:
        return "Profile, goals, and target macro values.";
    }
  }

  String _importResultMessage(
    BackupImportResult result,
    Set<BackupSection> sections,
  ) {
    final imported = sections.fold<int>(
      0,
      (total, section) => total + result.importedFor(section),
    );
    final skipped = sections.fold<int>(
      0,
      (total, section) => total + result.skippedFor(section),
    );

    if (skipped == 0) {
      return "Imported $imported backup records.";
    }
    return "Imported $imported backup records. Skipped $skipped existing or incomplete records.";
  }

  String _backupFileName() {
    final now = DateTime.now();
    return "macro_diary_backup_"
        "${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_"
        "${_twoDigits(now.hour)}${_twoDigits(now.minute)}.json";
  }

  String _twoDigits(int value) => value.toString().padLeft(2, "0");

  void _showMessage(String message) {
    UIUtil.bottomNotifier(context: context, message: message);
  }
}

class _ImportBackupDialog extends StatefulWidget {
  final BackupPreview preview;

  const _ImportBackupDialog({required this.preview});

  @override
  State<_ImportBackupDialog> createState() => _ImportBackupDialogState();
}

class _ImportBackupDialogState extends State<_ImportBackupDialog> {
  late Set<BackupSection> _selectedSections;

  @override
  void initState() {
    super.initState();
    _selectedSections = {...widget.preview.availableSections};
    if (_selectedSections.contains(BackupSection.meals)) {
      _selectedSections.add(BackupSection.foods);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exportedAt = widget.preview.exportedAt;

    return AlertDialog(
      title: const Text("Import Backup"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (exportedAt != null) ...[
              Text("Created: ${_formatDate(exportedAt)}"),
              const SizedBox(height: 12),
            ],
            Text(
              "Choose what to import. Meals require food items.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ...BackupSection.values
                .where(widget.preview.availableSections.contains)
                .map(_sectionTile),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: _selectedSections.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selectedSections),
          child: const Text("Import"),
        ),
      ],
    );
  }

  Widget _sectionTile(BackupSection section) {
    final selected = _selectedSections.contains(section);
    final enabled = section != BackupSection.meals ||
        _selectedSections.contains(BackupSection.foods);

    return CheckboxListTile(
      value: selected && enabled,
      enabled: enabled,
      contentPadding: EdgeInsets.zero,
      title: Text(section.label),
      subtitle: Text("${widget.preview.countFor(section)} records"),
      onChanged: (value) {
        setState(() {
          final nextSections = {..._selectedSections};
          if (value == true) {
            nextSections.add(section);
            if (section == BackupSection.meals) {
              nextSections.add(BackupSection.foods);
            }
          } else {
            nextSections.remove(section);
            if (section == BackupSection.foods) {
              nextSections.remove(BackupSection.meals);
            }
          }
          _selectedSections = nextSections;
        });
      },
    );
  }

  String _formatDate(DateTime value) {
    return "${value.year}-${_twoDigits(value.month)}-${_twoDigits(value.day)} "
        "${_twoDigits(value.hour)}:${_twoDigits(value.minute)}";
  }

  String _twoDigits(int value) => value.toString().padLeft(2, "0");
}
