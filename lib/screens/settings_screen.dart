import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/conversation_provider.dart';
import '../providers/video_merge_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../models/screenplay.dart';
import '../models/script.dart';
import '../services/video_merger_service.dart';
import '../services/api_config_service.dart';
import '../theme/app_theme.dart';

/// 设置页面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '设置',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface.withOpacity(0.88),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer2<ConversationProvider, VideoMergeProvider>(
        builder: (context, convProvider, mergeProvider, child) {
          return Container(
            decoration: BoxDecoration(gradient: context.themeTokens.appBackgroundGradient),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildThemeModeCard(context),
                const SizedBox(height: 24),
                _buildApiConfigCard(context),
                const SizedBox(height: 24),
                _buildCacheManagementCard(context, convProvider),
                const SizedBox(height: 24),
                _buildDatabaseCard(context),
                const SizedBox(height: 24),
                _buildVideoMergeCard(context, mergeProvider),
                const SizedBox(height: 24),
                _buildAboutCard(context),
              ],
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _buildSectionDecoration(BuildContext context) {
    final tokens = context.themeTokens;
    return BoxDecoration(
      color: tokens.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: tokens.borderSubtle),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(context.isDarkMode ? 0.28 : 0.06),
          blurRadius: context.isDarkMode ? 20 : 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  TextStyle _sectionTitleStyle(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: context.colors.onSurface,
    );
  }

  TextStyle _sectionSubtitleStyle(BuildContext context) {
    return TextStyle(
      fontSize: 13,
      color: context.themeTokens.textMuted,
    );
  }

  Widget _buildThemeModeCard(BuildContext context) {
    final ThemeProvider provider = context.watch<ThemeProvider>();
    final tokens = context.themeTokens;

    return Container(
      decoration: _buildSectionDecoration(context),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: tokens.brandGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.palette_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('主题模式', style: _sectionTitleStyle(context)),
                    const SizedBox(height: 2),
                    Text('切换系统 / 浅色 / 深色', style: _sectionSubtitleStyle(context)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: const <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto_outlined),
                label: Text('系统'),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_outlined),
                label: Text('浅色'),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_outlined),
                label: Text('深色'),
              ),
            ],
            selected: <ThemeMode>{provider.themeMode},
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) {
                context.read<ThemeProvider>().setThemeMode(selection.first);
              }
            },
          ),
          const SizedBox(height: 8),
          Text(
            '当前：${provider.themeModeLabel}',
            style: TextStyle(
              fontSize: 12,
              color: tokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// API 配置卡片
  Widget _buildApiConfigCard(BuildContext context) {
    final tokens = context.themeTokens;

    return Container(
      decoration: _buildSectionDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.api_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'API 配置',
                        style: _sectionTitleStyle(context),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '配置各服务的 API Key',
                        style: _sectionSubtitleStyle(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // API Key 列表
          // 智谱 GLM 配置
          _buildApiKeyRow(
            context,
            '智谱 GLM-4.7',
            ApiConfigService.maskApiKey(ApiConfigService.getZhipuApiKey()),
            Icons.psychology_outlined,
            const Color(0xFF8B5CF6),
            () => _showApiKeyEditDialog(
              context,
              '智谱 GLM API Key',
              ApiConfigService.getZhipuApiKey(),
              (key) => ApiConfigService.setZhipuApiKey(key),
            ),
          ),
          // 智谱推广信息
          _buildPromoRow(
            context,
            '🚀 智谱 GLM Coding 超值订阅',
            '20+ 编程工具无缝支持，限时惊喜价！',
            const Color(0xFF8B5CF6),
            'https://www.bigmodel.cn/glm-coding?ic=BUXAZXR3YZ',
          ),
          const Divider(height: 1),

          // 视频生成配置
          _buildApiKeyRow(
            context,
            '视频生成 (苍何 API)',
            ApiConfigService.maskApiKey(ApiConfigService.getVideoApiKey()),
            Icons.videocam_outlined,
            const Color(0xFFEC4899),
            () => _showApiKeyEditDialog(
              context,
              '视频生成 API Key',
              ApiConfigService.getVideoApiKey(),
              (key) => ApiConfigService.setVideoApiKey(key),
            ),
          ),
          const Divider(height: 1),

          // 图像生成配置
          _buildApiKeyRow(
            context,
            '图像生成 (苍何 API)',
            ApiConfigService.maskApiKey(ApiConfigService.getImageApiKey()),
            Icons.image_outlined,
            const Color(0xFFF59E0B),
            () => _showApiKeyEditDialog(
              context,
              '图像生成 API Key',
              ApiConfigService.getImageApiKey(),
              (key) => ApiConfigService.setImageApiKey(key),
            ),
          ),
          // 苍何 API 推广信息
          _buildPromoRow(
            context,
            '🎁 推荐苍何 API',
            '稳定、高性能的 AI 服务接口',
            const Color(0xFFEC4899),
            'https://api.canghe.ai/',
          ),
          const Divider(height: 1),

          _buildApiKeyRow(
            context,
            '豆包 ARK (图片识别)',
            ApiConfigService.maskApiKey(ApiConfigService.getDoubaoApiKey()),
            Icons.visibility_outlined,
            const Color(0xFF10B981),
            () => _showApiKeyEditDialog(
              context,
              '豆包 API Key',
              ApiConfigService.getDoubaoApiKey(),
              (key) => ApiConfigService.setDoubaoApiKey(key),
            ),
          ),

          // 提示信息
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              '提示：API Key 将保存在本地，仅用于此设备。',
              style: TextStyle(
                fontSize: 12,
                color: tokens.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 推广信息行
  Widget _buildPromoRow(
    BuildContext context,
    String title,
    String description,
    Color color,
    String url,
  ) {
    final tokens = context.themeTokens;

    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.08),
              color.withOpacity(0.03),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.card_giftcard_outlined,
                size: 16,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: tokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '查看',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: color.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  /// 打开链接
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  /// API Key 行
  Widget _buildApiKeyRow(
    BuildContext context,
    String label,
    String maskedKey,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final colorScheme = context.colors;
    final tokens = context.themeTokens;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    maskedKey,
                    style: TextStyle(
                      fontSize: 12,
                      color: tokens.textMuted,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: tokens.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  /// 显示 API Key 编辑对话框
  Future<void> _showApiKeyEditDialog(
    BuildContext context,
    String title,
    String currentValue,
    Future<void> Function(String) onSave,
  ) async {
    final controller = TextEditingController(text: currentValue);
    bool isVisible = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                obscureText: !isVisible,
                maxLines: isVisible ? null : 1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: '请输入 API Key',
                  suffixIcon: IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        isVisible = !isVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '提示：API Key 将保存在本地，仅用于此设备。',
                style: TextStyle(
                  fontSize: 12,
                  color: context.themeTokens.textMuted,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('API Key 不能为空'),
                      backgroundColor: Color(0xFFF87171),
                    ),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
              ),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );

    if (result == true && context.mounted) {
      try {
        await onSave(controller.text.trim());
        if (context.mounted) {
          setState(() {}); // 刷新界面
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('API Key 已保存'),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('保存失败: $e'),
              backgroundColor: const Color(0xFFF87171),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Widget _buildCacheManagementCard(BuildContext context, ConversationProvider provider) {
    final colorScheme = context.colors;

    return Container(
      decoration: _buildSectionDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.storage_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '缓存管理',
                        style: _sectionTitleStyle(context),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '自动清理 2 天未访问的缓存',
                        style: _sectionSubtitleStyle(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 缓存统计
          FutureBuilder<CacheStats>(
            future: provider.getCacheStats(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final stats = snapshot.data!;
              return Column(
                children: [
                  _buildStatRow(context, '总缓存大小', stats.totalSizeFormatted, Icons.sd_storage_outlined),
                  const Divider(height: 1),
                  _buildStatRow(context, '缓存文件数', '${stats.fileCount} 个', Icons.insert_drive_file_outlined),
                  const Divider(height: 1),
                  _buildStatRow(context, '图片数量', '${stats.imageCount} 张', Icons.image_outlined),
                  const Divider(height: 1),
                  _buildStatRow(context, '视频数量', '${stats.videoCount} 个', Icons.videocam_outlined),
                ],
              );
            },
          ),

          // 操作按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _clearExpiredCache(context, provider),
                    icon: const Icon(Icons.cleaning_services_outlined, size: 20),
                    label: const Text('清理过期缓存'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _clearAllCache(context, provider),
                    icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                    label: const Text('清空所有缓存'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF87171),
                      side: BorderSide(color: colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, IconData icon) {
    final colorScheme = context.colors;
    final tokens = context.themeTokens;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: tokens.textMuted,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoMergeCard(BuildContext context, VideoMergeProvider provider) {
    final colorScheme = context.colors;
    final tokens = context.themeTokens;

    return Container(
      decoration: _buildSectionDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.video_library_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '视频合并',
                        style: _sectionTitleStyle(context),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '将场景视频合并为完整视频',
                        style: _sectionSubtitleStyle(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 统计信息
          _buildStatRow(context, '已合并视频', '${provider.mergedVideosCount} 个', Icons.video_collection_outlined),
          const Divider(height: 1),
          _buildStatRow(context, '占用空间', provider.mergedVideosSizeFormatted, Icons.sd_storage_outlined),

          // 测试按钮
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: OutlinedButton.icon(
              onPressed: () => _testMergeWithMockVideos(context, provider),
              icon: const Icon(Icons.science, size: 18),
              label: const Text('🧪 测试7场景合并'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8B5CF6),
                side: const BorderSide(color: Color(0xFF8B5CF6)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Mock 模式提示
          if (VideoMergerService.useMockMode)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.14),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.primary.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.science, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mock 模式：模拟合并流程，实际下载第一个视频',
                      style: TextStyle(color: colorScheme.primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          // 操作按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: provider.isMerging ? null : () => _showMergeDialog(context, provider),
                    icon: provider.isMerging
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.merge_type_outlined, size: 20),
                    label: Text(provider.isMerging ? provider.statusMessage : '合并场景视频'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFEC4899),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (provider.isMerging)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator(
                      value: provider.progress,
                      backgroundColor: tokens.inputSurface,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseCard(BuildContext context) {
    return Container(
      decoration: _buildSectionDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.storage,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '数据库查看',
                        style: _sectionTitleStyle(context),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '查看会话和消息数据',
                        style: _sectionSubtitleStyle(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 数据库统计
          Consumer<ConversationProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  _buildStatRow(context, '会话数量', '${provider.conversations.length} 个', Icons.folder_outlined),
                  const Divider(height: 1),
                  if (provider.currentConversation != null)
                    _buildStatRow(context, '当前会话消息', '${provider.currentMessages.length} 条', Icons.message_outlined),
                  if (provider.currentConversation != null) const Divider(height: 1),
                  _buildStatRow(context, '数据库路径', 'hive_db/', Icons.folder_open_outlined),
                ],
              );
            },
          ),

          // 操作按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _showDatabaseViewer(context),
                    icon: const Icon(Icons.table_view_outlined, size: 20),
                    label: const Text('查看数据详情'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _exportDatabase(context),
                    icon: const Icon(Icons.download_outlined, size: 20),
                    label: const Text('导出数据 (JSON)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8B5CF6),
                      side: const BorderSide(color: Color(0xFF8B5CF6)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Container(
      decoration: _buildSectionDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '关于',
                        style: _sectionTitleStyle(context),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'AI 漫导 - 将创意转化为动漫视频',
                        style: _sectionSubtitleStyle(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAboutRow(context, '版本', '1.0.0'),
                const SizedBox(height: 12),
                _buildAboutRow(context, '数据库', 'Hive (轻量级 NoSQL)'),
                const SizedBox(height: 12),
                _buildAboutRow(context, '缓存策略', '2 天未访问自动清理'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutRow(BuildContext context, String label, String value) {
    final colorScheme = context.colors;
    final tokens = context.themeTokens;

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: tokens.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _clearExpiredCache(BuildContext context, ConversationProvider provider) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final result = await provider.clearAllCache();

      if (context.mounted) {
        Navigator.pop(context); // 关闭 loading

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('清理完成：删除 ${result.removedCount} 个文件，释放 ${result.freedSpaceFormatted}'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // 关闭 loading

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('清理失败: $e'),
            backgroundColor: const Color(0xFFF87171),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _clearAllCache(BuildContext context, ConversationProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('清空所有缓存'),
        content: const Text('确定要清空所有缓存吗？这将释放所有缓存空间，但不会删除对话记录。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF87171),
            ),
            child: const Text('清空'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        await provider.clearAllCacheForce();

        if (context.mounted) {
          Navigator.pop(context); // 关闭 loading

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已清空所有缓存'),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // 关闭 loading

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('清空失败: $e'),
              backgroundColor: const Color(0xFFF87171),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// 显示视频合并对话框
  Future<void> _showMergeDialog(BuildContext context, VideoMergeProvider provider) async {
    // 获取当前对话中的剧本
    final chatProvider = context.read<ChatProvider>();
    final currentScreenplay = chatProvider.screenplayController.currentScreenplay;

    if (currentScreenplay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('当前没有可合并的剧本，请先完成视频生成'),
          backgroundColor: Color(0xFFF87171),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 检查是否有足够的场景视频
    final scenesWithVideo = currentScreenplay.scenes.where((s) => s.videoUrl != null).length;
    if (scenesWithVideo == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('当前剧本没有已生成的视频'),
          backgroundColor: Color(0xFFF87171),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('合并场景视频'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('剧本: ${currentScreenplay.scriptTitle}'),
            const SizedBox(height: 8),
            Text('场景数: ${currentScreenplay.scenes.length}'),
            const SizedBox(height: 8),
            Text('已生成视频: $scenesWithVideo 个'),
            const SizedBox(height: 16),
            const Text(
              '是否将这些场景视频合并为完整视频？',
              style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEC4899),
            ),
            child: const Text('开始合并'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // 显示合并进度对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _MergeProgressDialog(screenplay: currentScreenplay),
      );

      // 开始合并
      provider.mergeVideos(currentScreenplay);
    }
  }

  /// 使用 Mock 数据测试合并功能
  Future<void> _testMergeWithMockVideos(BuildContext context, VideoMergeProvider provider) async {
    // 创建 Mock 剧本，使用真实生成的7个视频链接进行测试
    final mockScreenplay = Screenplay(
      taskId: 'test_${DateTime.now().millisecondsSinceEpoch}',
      scriptTitle: '🧪 7场景视频合并测试',
      scenes: [
        Scene(
          sceneId: 1,
          narration: '测试场景 1',
          imagePrompt: 'Scene 1 for testing video merge',
          videoPrompt: 'Camera panning scene',
          characterDescription: 'Test',
          videoUrl: 'https://filesystem.site/cdn/20260104/2e0938b114576d0217175cfa925e2a.mp4',
          status: SceneStatus.completed,
        ),
        Scene(
          sceneId: 2,
          narration: '测试场景 2',
          imagePrompt: 'Scene 2 for testing video merge',
          videoPrompt: 'Camera zooming scene',
          characterDescription: 'Test',
          videoUrl: 'https://filesystem.site/cdn/20260104/6035dcf051bf3bf69dde8fec7c873c.mp4',
          status: SceneStatus.completed,
        ),
        Scene(
          sceneId: 3,
          narration: '测试场景 3',
          imagePrompt: 'Scene 3 for testing video merge',
          videoPrompt: 'Camera tracking scene',
          characterDescription: 'Test',
          videoUrl: 'https://filesystem.site/cdn/20260104/a2a3187da7a7b2edaee219ccf38c53.mp4',
          status: SceneStatus.completed,
        ),
        Scene(
          sceneId: 4,
          narration: '测试场景 4',
          imagePrompt: 'Scene 4 for testing video merge',
          videoPrompt: 'Camera rotating scene',
          characterDescription: 'Test',
          videoUrl: 'https://filesystem.site/cdn/20260104/19bea6cc8e95b5865fae775424c521.mp4',
          status: SceneStatus.completed,
        ),
        Scene(
          sceneId: 5,
          narration: '测试场景 5',
          imagePrompt: 'Scene 5 for testing video merge',
          videoPrompt: 'Camera dollying scene',
          characterDescription: 'Test',
          videoUrl: 'https://filesystem.site/cdn/20260104/8b9e9d86218d8eeb26caddb2e921e6.mp4',
          status: SceneStatus.completed,
        ),
        Scene(
          sceneId: 6,
          narration: '测试场景 6',
          imagePrompt: 'Scene 6 for testing video merge',
          videoPrompt: 'Camera crane shot',
          characterDescription: 'Test',
          videoUrl: 'https://filesystem.site/cdn/20260104/3f071fce050dbeac6298af16a5d31a.mp4',
          status: SceneStatus.completed,
        ),
        Scene(
          sceneId: 7,
          narration: '测试场景 7',
          imagePrompt: 'Scene 7 for testing video merge',
          videoPrompt: 'Camera tracking final',
          characterDescription: 'Test',
          videoUrl: 'https://filesystem.site/cdn/20260104/8481a78572cecac738b1703924ae10.mp4',
          status: SceneStatus.completed,
        ),
      ],
      status: ScreenplayStatus.completed,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.science, color: Color(0xFF8B5CF6)),
            SizedBox(width: 8),
            Text('Mock 测试'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('将使用以下测试视频进行合并流程演示：'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📹 视频 1: c855cd6...mp4', style: TextStyle(fontSize: 13)),
                  SizedBox(height: 4),
                  Text('📹 视频 2: fc5a598...mp4', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '注：Mock 模式下实际只下载第一个视频作为"合并结果"',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
            child: const Text('开始测试'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // 显示合并进度对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _MergeProgressDialog(screenplay: mockScreenplay),
      );

      // 开始合并
      provider.mergeVideos(mockScreenplay);
    }
  }

  /// 清空合并的视频
  Future<void> _clearMergedVideos(BuildContext context, VideoMergeProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('清空合并视频'),
        content: const Text('确定要清空所有已合并的视频吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF87171),
            ),
            child: const Text('清空'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.clearAllMergedVideos();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已清空所有合并视频'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// 显示数据库查看对话框
  void _showDatabaseViewer(BuildContext context) {
    final provider = context.read<ConversationProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('数据库内容'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '会话总数: ${provider.conversations.length}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (provider.conversations.isEmpty)
                  const Text('暂无会话数据', style: TextStyle(color: Color(0xFF8E8E93)))
                else
                  ...provider.conversations.take(5).map((conv) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              conv.title,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '消息: ${conv.messageCount} | ${conv.updatedAt.toString().substring(0, 19)}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                            ),
                          ],
                        ),
                      )),
                if (provider.conversations.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '还有 ${provider.conversations.length - 5} 个会话...',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 导出数据库为 JSON
  Future<void> _exportDatabase(BuildContext context) async {
    final provider = context.read<ConversationProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 准备导出数据
      final exportData = {
        'conversations': provider.conversations.map((conv) => {
          'id': conv.id,
          'title': conv.title,
          'createdAt': conv.createdAt.toIso8601String(),
          'updatedAt': conv.updatedAt.toIso8601String(),
          'messageCount': conv.messageCount,
          'isPinned': conv.isPinned,
        }).toList(),
        'exportTime': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

      // 转换为 JSON 字符串
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      if (context.mounted) {
        Navigator.pop(context); // 关闭 loading

        // 显示结果
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('导出成功'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('已导出 ${provider.conversations.length} 个会话'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    jsonString.substring(0, jsonString.length > 500 ? 500 : jsonString.length) +
                        (jsonString.length > 500 ? '\n\n... (已截断)' : ''),
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '提示: 长按文本可复制全部内容',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // 关闭 loading

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: const Color(0xFFF87171),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

/// 视频合并进度对话框
class _MergeProgressDialog extends StatelessWidget {
  final Screenplay screenplay;

  const _MergeProgressDialog({required this.screenplay});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('正在合并视频'),
      content: Consumer<VideoMergeProvider>(
        builder: (context, provider, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.statusMessage,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: provider.progress,
                backgroundColor: const Color(0xFFF3F4F6),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEC4899)),
              ),
              const SizedBox(height: 8),
              Text(
                '${(provider.progress * 100).toInt()}%',
                style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
              ),
              if (provider.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage!,
                  style: const TextStyle(fontSize: 12, color: Color(0xFFF87171)),
                ),
              ],
            ],
          );
        },
      ),
      actions: [
        Consumer<VideoMergeProvider>(
          builder: (context, provider, child) {
            if (provider.hasError) {
              return FilledButton(
                onPressed: () {
                  provider.reset();
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF87171),
                ),
                child: const Text('关闭'),
              );
            }
            if (provider.isCompleted) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 播放视频按钮
                  if (provider.mergedVideoFile != null)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // 打开视频播放器
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => _MergedVideoPlayerScreen(
                              videoFile: provider.mergedVideoFile!,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_circle_outline),
                      label: const Text('播放视频'),
                    ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      provider.reset();
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                    ),
                    child: const Text('完成'),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

/// 合并视频播放页面
class _MergedVideoPlayerScreen extends StatefulWidget {
  final File videoFile;

  const _MergedVideoPlayerScreen({required this.videoFile});

  @override
  State<_MergedVideoPlayerScreen> createState() => _MergedVideoPlayerScreenState();
}

class _MergedVideoPlayerScreenState extends State<_MergedVideoPlayerScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoController = VideoPlayerController.file(widget.videoFile);
      await _videoController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoController.value.aspectRatio,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              '播放失败: $errorMessage',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '初始化播放器失败: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('合并视频预览'),
        actions: [
          // 显示文件路径
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('视频文件'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('文件路径:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SelectableText(
                        widget.videoFile.path,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.info_outline),
            tooltip: '文件信息',
          ),
        ],
      ),
      body: Center(
        child: _error != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : !_isInitialized
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        '加载视频中...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )
                : Chewie(controller: _chewieController!),
      ),
    );
  }
}
