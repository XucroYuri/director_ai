import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color _brandBlue = Color(0xFF1A73E8);
  static const Color _brandAqua = Color(0xFF00BFA5);
  static const Color _brandViolet = Color(0xFF6C63FF);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: _brandBlue,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? const Color(0xFF8AB4F8) : _brandBlue,
      onPrimary: Colors.white,
      secondary: isDark ? const Color(0xFF80CBC4) : _brandAqua,
      tertiary: isDark ? const Color(0xFFB0A6FF) : _brandViolet,
      error: isDark ? const Color(0xFFF28B82) : const Color(0xFFD93025),
      surface: isDark ? const Color(0xFF12161E) : const Color(0xFFF7FAFE),
      onSurface: isDark ? const Color(0xFFE9EEF6) : const Color(0xFF1F2937),
      outline: isDark ? const Color(0xFF304159) : const Color(0xFFD3DEE9),
    );

    final AppThemeTokens tokens = isDark
        ? AppThemeTokens.dark(colorScheme)
        : AppThemeTokens.light(colorScheme);

    final TextTheme base = ThemeData(brightness: brightness).textTheme;
    final TextTheme textTheme = base.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ).copyWith(
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.4),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[tokens],
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface.withOpacity(isDark ? 0.92 : 0.88),
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: colorScheme.primary),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: tokens.surfaceElevated,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: tokens.borderSubtle),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: tokens.borderSubtle),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.surfaceElevated,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.borderSubtle,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.inputSurface,
        hintStyle: TextStyle(
          color: tokens.textMuted,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      iconTheme: IconThemeData(
        color: colorScheme.primary,
        size: 22,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.primary.withOpacity(0.45);
            }
            return colorScheme.primary;
          }),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textStyle: WidgetStatePropertyAll(
            textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.primary,
        textColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(color: tokens.textMuted),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: tokens.surfaceElevated,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: tokens.borderSubtle),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
      ),
    );
  }
}

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  final Gradient appBackgroundGradient;
  final Gradient drawerBackgroundGradient;
  final Gradient brandGradient;
  final Gradient highlightGradient;
  final Color surfaceElevated;
  final Color surfaceGlass;
  final Color inputSurface;
  final Color borderSubtle;
  final Color borderStrong;
  final Color textMuted;
  final Color success;
  final Color warning;
  final Color danger;

  const AppThemeTokens({
    required this.appBackgroundGradient,
    required this.drawerBackgroundGradient,
    required this.brandGradient,
    required this.highlightGradient,
    required this.surfaceElevated,
    required this.surfaceGlass,
    required this.inputSurface,
    required this.borderSubtle,
    required this.borderStrong,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.danger,
  });

  factory AppThemeTokens.light(ColorScheme colors) {
    return const AppThemeTokens(
      appBackgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF7FAFE), Color(0xFFEFF4FB)],
      ),
      drawerBackgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEEF3FF), Color(0xFFE0ECFF)],
      ),
      brandGradient: LinearGradient(
        colors: [Color(0xFF1A73E8), Color(0xFF33B4FF)],
      ),
      highlightGradient: LinearGradient(
        colors: [Color(0xFF6C63FF), Color(0xFF00BFA5)],
      ),
      surfaceElevated: Color(0xFFFFFFFF),
      surfaceGlass: Color(0xFFF8FBFF),
      inputSurface: Color(0xFFF0F4FA),
      borderSubtle: Color(0xFFDCE5F0),
      borderStrong: Color(0xFFB7C8DF),
      textMuted: Color(0xFF607086),
      success: Color(0xFF1E8E3E),
      warning: Color(0xFFE37400),
      danger: Color(0xFFD93025),
    );
  }

  factory AppThemeTokens.dark(ColorScheme colors) {
    return const AppThemeTokens(
      appBackgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0E131B), Color(0xFF111927)],
      ),
      drawerBackgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF101724), Color(0xFF131E31)],
      ),
      brandGradient: LinearGradient(
        colors: [Color(0xFF8AB4F8), Color(0xFF33B4FF)],
      ),
      highlightGradient: LinearGradient(
        colors: [Color(0xFFB0A6FF), Color(0xFF80CBC4)],
      ),
      surfaceElevated: Color(0xFF172233),
      surfaceGlass: Color(0xFF1C2A40),
      inputSurface: Color(0xFF1A2535),
      borderSubtle: Color(0xFF2C3F5A),
      borderStrong: Color(0xFF416083),
      textMuted: Color(0xFF99AEC8),
      success: Color(0xFF81C995),
      warning: Color(0xFFFBCB65),
      danger: Color(0xFFF28B82),
    );
  }

  @override
  AppThemeTokens copyWith({
    Gradient? appBackgroundGradient,
    Gradient? drawerBackgroundGradient,
    Gradient? brandGradient,
    Gradient? highlightGradient,
    Color? surfaceElevated,
    Color? surfaceGlass,
    Color? inputSurface,
    Color? borderSubtle,
    Color? borderStrong,
    Color? textMuted,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return AppThemeTokens(
      appBackgroundGradient: appBackgroundGradient ?? this.appBackgroundGradient,
      drawerBackgroundGradient: drawerBackgroundGradient ?? this.drawerBackgroundGradient,
      brandGradient: brandGradient ?? this.brandGradient,
      highlightGradient: highlightGradient ?? this.highlightGradient,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceGlass: surfaceGlass ?? this.surfaceGlass,
      inputSurface: inputSurface ?? this.inputSurface,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppThemeTokens lerp(
    covariant AppThemeTokens? other,
    double t,
  ) {
    if (other == null) return this;
    return AppThemeTokens(
      appBackgroundGradient:
          Gradient.lerp(appBackgroundGradient, other.appBackgroundGradient, t) ??
              appBackgroundGradient,
      drawerBackgroundGradient:
          Gradient.lerp(drawerBackgroundGradient, other.drawerBackgroundGradient, t) ??
              drawerBackgroundGradient,
      brandGradient: Gradient.lerp(brandGradient, other.brandGradient, t) ??
          brandGradient,
      highlightGradient:
          Gradient.lerp(highlightGradient, other.highlightGradient, t) ??
              highlightGradient,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t) ??
          surfaceElevated,
      surfaceGlass: Color.lerp(surfaceGlass, other.surfaceGlass, t) ?? surfaceGlass,
      inputSurface: Color.lerp(inputSurface, other.inputSurface, t) ?? inputSurface,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t) ?? borderSubtle,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t) ?? borderStrong,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
    );
  }
}

extension AppThemeContext on BuildContext {
  ThemeData get appTheme => Theme.of(this);

  ColorScheme get colors => appTheme.colorScheme;

  AppThemeTokens get themeTokens =>
      appTheme.extension<AppThemeTokens>() ??
      (appTheme.brightness == Brightness.dark
          ? AppThemeTokens.dark(appTheme.colorScheme)
          : AppThemeTokens.light(appTheme.colorScheme));

  bool get isDarkMode => appTheme.brightness == Brightness.dark;
}
