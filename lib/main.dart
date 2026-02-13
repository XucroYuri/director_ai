import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_logger.dart';
import 'providers/chat_provider.dart';
import 'providers/conversation_provider.dart';
import 'providers/video_merge_provider.dart';
import 'providers/theme_provider.dart';
import 'models/screenplay_draft.dart';
import 'screens/chat_screen.dart';
import 'screens/screenplay_review_screen.dart';
import 'screens/log_viewer_screen.dart';
import 'screens/settings_screen.dart';
import 'services/api_config_service.dart';
import 'theme/app_theme.dart';

void main() async {
  // 确保 Flutter 绑定初始化（必须在所有插件操作之前）
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日志系统
  await AppLogger.initialize();

  // 初始化 API 配置服务
  await ApiConfigService.initialize();

  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  runApp(DirectorAIApp(themeProvider: themeProvider));

  // 监听应用生命周期
  WidgetsBinding.instance.addObserver(AppLifecycleObserver(
    onDetached: () async {
      await AppLogger.dispose();
    },
  ));
}

/// 应用生命周期观察者
class AppLifecycleObserver with WidgetsBindingObserver {
  final VoidCallback onDetached;

  AppLifecycleObserver({required this.onDetached});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      onDetached();
    }
  }
}

class DirectorAIApp extends StatelessWidget {
  final ThemeProvider themeProvider;

  const DirectorAIApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ConversationProvider()),
        ChangeNotifierProvider(create: (_) => VideoMergeProvider()),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'AI漫导',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: provider.themeMode,
            home: const ChatScreen(),
            routes: {
              '/settings': (context) => const SettingsScreen(),
              '/screenplay-review': (context) {
                // 从路由参数获取剧本草稿
                final args = ModalRoute.of(context)?.settings.arguments;
                if (args is ScreenplayReviewScreenArgs) {
                  return ScreenplayReviewScreen(
                    draft: args.draft,
                    onConfirm: args.onConfirm,
                    onRegenerate: args.onRegenerate,
                    onRegenerateCharacterSheets: args.onRegenerateCharacterSheets,
                  );
                }
                // 兼容旧版本，从 Provider 获取
                final chatProvider = context.read<ChatProvider>();
                if (chatProvider.currentDraft != null) {
                  return ScreenplayReviewScreen(
                    draft: chatProvider.currentDraft!,
                    onConfirm: (draft) async {
                      await chatProvider.confirmDraft();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    onRegenerate: (feedback) async {
                      return await chatProvider.regenerateDraft(feedback);
                    },
                    onRegenerateCharacterSheets: () async {
                      await chatProvider.regenerateCharacterSheets();
                    },
                  );
                }
                return const Scaffold(body: Center(child: Text('没有找到剧本')));
              },
              '/logs': (context) => const LogViewerScreen(),
            },
          );
        },
      ),
    );
  }
}

/// 剧本确认页面的路由参数
class ScreenplayReviewScreenArgs {
  final ScreenplayDraft draft;
  final Function(ScreenplayDraft) onConfirm;
  final Future<ScreenplayDraft> Function(String? feedback)? onRegenerate;
  final Future<void> Function()? onRegenerateCharacterSheets; // 新增

  ScreenplayReviewScreenArgs({
    required this.draft,
    required this.onConfirm,
    this.onRegenerate,
    this.onRegenerateCharacterSheets,
  });
}
