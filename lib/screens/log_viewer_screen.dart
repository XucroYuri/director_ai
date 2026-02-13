import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_logger.dart';
import '../theme/app_theme.dart';

/// 日志查看页面
class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  List<File> _logFiles = [];
  bool _isLoading = true;
  File? _selectedFile;
  String? _selectedContent;

  @override
  void initState() {
    super.initState();
    _loadLogFiles();
  }

  Future<void> _loadLogFiles() async {
    setState(() => _isLoading = true);
    final files = await AppLogger.getLogFiles();
    setState(() {
      _logFiles = files;
      _isLoading = false;
      if (files.isNotEmpty) {
        _selectedFile = files.first;
        _loadLogContent(files.first);
      }
    });
  }

  Future<void> _loadLogContent(File file) async {
    final content = await AppLogger.readLogFile(file);
    setState(() => _selectedContent = content);
  }

  Future<void> _deleteLog(File file) async {
    final colorScheme = context.colors;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除日志文件 ${file.path.split('/').last} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AppLogger.deleteLogFile(file);
      await _loadLogFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('日志文件已删除')),
        );
      }
    }
  }

  Future<void> _clearAllLogs() async {
    final colorScheme = context.colors;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有日志文件吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: const Text('清空'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AppLogger.clearAllLogs();
      await _loadLogFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('所有日志已清空')),
        );
      }
    }
  }

  Future<void> _shareLog() async {
    if (_selectedContent == null) return;

    await Clipboard.setData(ClipboardData(text: _selectedContent!));
    if (mounted) {
      final tokens = context.themeTokens;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('日志已复制到剪贴板'),
          backgroundColor: tokens.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.themeTokens;

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text('日志查看'),
        actions: [
          if (_logFiles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareLog,
              tooltip: '分享/复制',
            ),
          if (_logFiles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllLogs,
              tooltip: '清空所有',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogFiles,
            tooltip: '刷新',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logFiles.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // 文件选择器
                    _buildFileSelector(),
                    Divider(height: 1, color: tokens.borderSubtle),
                    // 日志内容
                    Expanded(
                      child: _selectedContent == null
                          ? const Center(child: Text('加载中...'))
                          : _buildLogContent(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    final tokens = context.themeTokens;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: tokens.textMuted.withOpacity(0.45)),
          const SizedBox(height: 16),
          Text(
            '暂无日志文件',
            style: TextStyle(fontSize: 16, color: tokens.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSelector() {
    final colorScheme = context.colors;
    final tokens = context.themeTokens;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: tokens.inputSurface,
        border: Border(bottom: BorderSide(color: tokens.borderSubtle)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _logFiles.length,
        itemBuilder: (context, index) {
          final file = _logFiles[index];
          final isSelected = file == _selectedFile;
          final fileName = file.path.split('/').last;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFile = file;
                });
                _loadLogContent(file);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : tokens.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? colorScheme.primary : tokens.borderSubtle,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fileName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : colorScheme.onSurface,
                        fontSize: 12,
                      ),
                    ),
                    if (file != _selectedFile) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _deleteLog(file),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogContent() {
    // 解析日志内容，高亮显示不同级别的日志
    final lines = _selectedContent!.split('\n');

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final line = lines[index];
        final color = _getLogColor(context, line);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText(
            line,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: color,
            ),
          ),
        );
      },
    );
  }

  Color _getLogColor(BuildContext context, String line) {
    final colorScheme = context.colors;
    final tokens = context.themeTokens;
    if (line.contains('❌')) return colorScheme.error;
    if (line.contains('✅')) return tokens.success;
    if (line.contains('⚠️')) return tokens.warning;
    if (line.contains('🌐') || line.contains('📥')) return colorScheme.primary;
    if (line.contains('📦') || line.contains('⚡')) return colorScheme.tertiary;
    return colorScheme.onSurface.withOpacity(0.9);
  }
}
