import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/screenplay_draft.dart';
import '../widgets/scene_review_card.dart';
import '../widgets/character_sheet_card.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';

/// 剧本确认页面
/// 用户在此页面查看、编辑剧本，确认后进入图片/视频生成阶段
class ScreenplayReviewScreen extends StatefulWidget {
  final ScreenplayDraft draft;
  final Function(ScreenplayDraft) onConfirm;
  final Function(String? feedback)? onRegenerate;
  final Function()? onRegenerateCharacterSheets; // 新增：重新生成角色设定回调

  const ScreenplayReviewScreen({
    super.key,
    required this.draft,
    required this.onConfirm,
    this.onRegenerate,
    this.onRegenerateCharacterSheets,
  });

  @override
  State<ScreenplayReviewScreen> createState() => _ScreenplayReviewScreenState();
}

class _ScreenplayReviewScreenState extends State<ScreenplayReviewScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isRegenerating = false;

  /// 从 Provider 获取最新的草稿
  ScreenplayDraft _getCurrentDraft() {
    final provider = context.read<ChatProvider>();
    return provider.currentDraft ?? widget.draft;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final tokens = context.themeTokens;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '剧本确认',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface.withOpacity(0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          // 重新生成按钮
          if (widget.onRegenerate != null)
            TextButton.icon(
              onPressed: _isRegenerating ? null : _handleRegenerate,
              icon: _isRegenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, size: 20),
              label: const Text(
                '重新生成',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          // 直接使用 provider.currentDraft，因为它会与 draftController 同步
          final currentDraft = provider.currentDraft ?? widget.draft;

          return Container(
            decoration: BoxDecoration(gradient: tokens.appBackgroundGradient),
            child: Column(
              children: [
                // 可滚动内容区域
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildDraftInfo(context, currentDraft)),
                      SliverToBoxAdapter(
                        child: Divider(height: 1, thickness: 1, color: tokens.borderSubtle),
                      ),
                      SliverToBoxAdapter(child: _buildCharacterSheetsSection(context, currentDraft)),
                      SliverToBoxAdapter(
                        child: Divider(height: 1, thickness: 1, color: tokens.borderSubtle),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final scene = currentDraft.scenes[index];
                            return SceneReviewCard(
                              scene: scene,
                              totalScenes: currentDraft.scenes.length,
                              onNarrationChanged: (newNarration) {
                                final provider = context.read<ChatProvider>();
                                provider.draftController.updateSceneNarration(scene.sceneId, newNarration);
                              },
                              onEmotionalHookChanged: (newHook) {
                                final provider = context.read<ChatProvider>();
                                provider.draftController.updateSceneEmotionalHook(scene.sceneId, newHook);
                              },
                              onCharacterDescriptionChanged: (newDesc) {
                                final provider = context.read<ChatProvider>();
                                provider.draftController.updateSceneCharacterDescription(scene.sceneId, newDesc);
                              },
                              onImagePromptChanged: (newPrompt) {
                                final provider = context.read<ChatProvider>();
                                provider.draftController.updateSceneImagePrompt(scene.sceneId, newPrompt);
                              },
                              onVideoPromptChanged: (newPrompt) {
                                final provider = context.read<ChatProvider>();
                                provider.draftController.updateSceneVideoPrompt(scene.sceneId, newPrompt);
                              },
                              onRegenerate: widget.onRegenerate != null
                                  ? () => _handleRegenerateScene(scene.sceneId)
                                  : null,
                            );
                          },
                          childCount: currentDraft.scenes.length,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    ],
                  ),
                ),
                _buildBottomActions(context),
              ],
            ),
          );
        },
      ),
    );
  }


  /// 构建剧本信息区域
  Widget _buildDraftInfo(BuildContext context, ScreenplayDraft currentDraft) {
    final colorScheme = context.colors;
    final tokens = context.themeTokens;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tokens.borderSubtle, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(context.isDarkMode ? 0.24 : 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Icon(Icons.movie_creation, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  currentDraft.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 信息行 + 情绪弧线 - 药丸标签
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _InfoPill(icon: Icons.category, label: currentDraft.genre),
              _InfoPill(icon: Icons.schedule, label: '${currentDraft.estimatedDurationSeconds}秒'),
              _InfoPill(icon: Icons.view_carousel, label: '${currentDraft.sceneCount}个场景'),
              if (currentDraft.emotionalArc.isNotEmpty)
                _InfoPill(icon: Icons.trending_up, label: currentDraft.emotionalArc.join('→')),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建角色设定区域
  Widget _buildCharacterSheetsSection(BuildContext context, ScreenplayDraft currentDraft) {
    // 如果有角色设定表，显示角色列表
    // 如果没有，显示一个提示区域
    final hasCharacterSheets = currentDraft.hasCharacterSheets;

    if (!hasCharacterSheets) {
      final tokens = context.themeTokens;

      // 显示提示信息
      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: tokens.inputSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tokens.borderSubtle),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: context.colors.secondary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '确认剧本后将自动生成主要角色的三视图',
                style: TextStyle(
                  fontSize: 13,
                  color: tokens.textMuted,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 显示角色设定列表
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: context.themeTokens.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.themeTokens.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(context.isDarkMode ? 0.24 : 0.08),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: CharacterSheetsList(
        sheets: currentDraft.characterSheets,
        onRegenerateAll: widget.onRegenerateCharacterSheets,
      ),
    );
  }

  /// 构建底部操作区域
  Widget _buildBottomActions(BuildContext context) {
    final colorScheme = context.colors;
    final tokens = context.themeTokens;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: tokens.surfaceElevated.withOpacity(context.isDarkMode ? 0.96 : 0.95),
        border: Border(
          top: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(context.isDarkMode ? 0.24 : 0.04),
            offset: const Offset(0, -2),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 反馈输入框 - 现代简约风格
            Container(
              decoration: BoxDecoration(
                color: tokens.inputSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tokens.borderSubtle, width: 1),
              ),
              child: TextField(
                controller: _feedbackController,
                maxLines: 1,
                style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: '输入修改建议（可选）...',
                  hintStyle: TextStyle(fontSize: 14, color: tokens.textMuted),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 确认按钮 - 渐变风格
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _handleConfirm,
                icon: const Icon(Icons.check_circle, size: 20, color: Colors.white),
                label: const Text(
                  '确认并继续生成',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 处理确认
  void _handleConfirm() {
    final currentDraft = _getCurrentDraft();
    widget.onConfirm(currentDraft);
  }

  /// 处理重新生成
  void _handleRegenerate() {
    if (widget.onRegenerate == null) return;

    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) {
      // 显示提示对话框
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('重新生成剧本'),
          content: const Text('是否要重新生成整个剧本？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startRegeneration(null);
              },
              child: const Text('确定'),
            ),
          ],
        ),
      );
    } else {
      _startRegeneration(feedback);
    }
  }

  /// 处理重新生成单个场景
  void _handleRegenerateScene(int sceneId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重新生成场景'),
        content: Text('是否要重新生成场景 $sceneId？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startRegeneration('请重新生成场景 $sceneId');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 开始重新生成
  void _startRegeneration(String? feedback) {
    setState(() {
      _isRegenerating = true;
    });

    widget.onRegenerate!(feedback).then((newDraft) {
      if (mounted) {
        setState(() {
          _isRegenerating = false;
          _feedbackController.clear();
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isRegenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('重新生成失败: $error')),
        );
      }
    });
  }
}

/// 信息标签芯片
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final tokens = context.themeTokens;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(context.isDarkMode ? 0.22 : 0.14),
            colorScheme.secondary.withOpacity(context.isDarkMode ? 0.18 : 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(context.isDarkMode ? 0.18 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: tokens.brandGradient,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 10, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
