import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xff7b580d),
      surfaceTint: Color(0xff7b580d),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffdeaa),
      onPrimaryContainer: Color(0xff271900),
      secondary: Color(0xff815512),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffddb6),
      onSecondaryContainer: Color(0xff2a1800),
      tertiary: Color(0xff7d570e),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffdead),
      onTertiaryContainer: Color(0xff281900),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff410002),
      background: Color(0xfffff8f3),
      onBackground: Color(0xff201b13),
      surface: Color(0xfffff8f3),
      onSurface: Color(0xff201b13),
      surfaceVariant: Color(0xffeee0cf),
      onSurfaceVariant: Color(0xff4e4639),
      outline: Color(0xff807667),
      outlineVariant: Color(0xffd2c5b4),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff353027),
      inverseOnSurface: Color(0xfffaefe2),
      inversePrimary: Color(0xffeebf6d),
      primaryFixed: Color(0xffffdeaa),
      onPrimaryFixed: Color(0xff271900),
      primaryFixedDim: Color(0xffeebf6d),
      onPrimaryFixedVariant: Color(0xff5f4100),
      secondaryFixed: Color(0xffffddb6),
      onSecondaryFixed: Color(0xff2a1800),
      secondaryFixedDim: Color(0xfff7bc70),
      onSecondaryFixedVariant: Color(0xff643f00),
      tertiaryFixed: Color(0xffffdead),
      onTertiaryFixed: Color(0xff281900),
      tertiaryFixedDim: Color(0xfff0be6d),
      onTertiaryFixedVariant: Color(0xff604100),
      surfaceDim: Color(0xffe3d8cc),
      surfaceBright: Color(0xfffff8f3),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffdf2e5),
      surfaceContainer: Color(0xfff8ecdf),
      surfaceContainerHigh: Color(0xfff2e6d9),
      surfaceContainerHighest: Color(0xffece1d4),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xff5a3e00),
      surfaceTint: Color(0xff7b580d),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff946e24),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff5f3b00),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff9b6b28),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff5b3d00),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff966d24),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff8c0009),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffda342e),
      onErrorContainer: Color(0xffffffff),
      background: Color(0xfffff8f3),
      onBackground: Color(0xff201b13),
      surface: Color(0xfffff8f3),
      onSurface: Color(0xff201b13),
      surfaceVariant: Color(0xffeee0cf),
      onSurfaceVariant: Color(0xff4a4235),
      outline: Color(0xff675e50),
      outlineVariant: Color(0xff84796b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff353027),
      inverseOnSurface: Color(0xfffaefe2),
      inversePrimary: Color(0xffeebf6d),
      primaryFixed: Color(0xff946e24),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff79560a),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff9b6b28),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff7e530f),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff966d24),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff7a550b),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffe3d8cc),
      surfaceBright: Color(0xfffff8f3),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffdf2e5),
      surfaceContainer: Color(0xfff8ecdf),
      surfaceContainerHigh: Color(0xfff2e6d9),
      surfaceContainerHighest: Color(0xffece1d4),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xff301f00),
      surfaceTint: Color(0xff7b580d),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff5a3e00),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff331e00),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5f3b00),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff301f00),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff5b3d00),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff4e0002),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff8c0009),
      onErrorContainer: Color(0xffffffff),
      background: Color(0xfffff8f3),
      onBackground: Color(0xff201b13),
      surface: Color(0xfffff8f3),
      onSurface: Color(0xff000000),
      surfaceVariant: Color(0xffeee0cf),
      onSurfaceVariant: Color(0xff2a2318),
      outline: Color(0xff4a4235),
      outlineVariant: Color(0xff4a4235),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff353027),
      inverseOnSurface: Color(0xffffffff),
      inversePrimary: Color(0xffffe9ca),
      primaryFixed: Color(0xff5a3e00),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff3d2900),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff5f3b00),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff412700),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff5b3d00),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff3e2900),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffe3d8cc),
      surfaceBright: Color(0xfffff8f3),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffdf2e5),
      surfaceContainer: Color(0xfff8ecdf),
      surfaceContainerHigh: Color(0xfff2e6d9),
      surfaceContainerHighest: Color(0xffece1d4),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xffeebf6d),
      surfaceTint: Color(0xffeebf6d),
      onPrimary: Color(0xff422c00),
      primaryContainer: Color(0xff5f4100),
      onPrimaryContainer: Color(0xffffdeaa),
      secondary: Color(0xfff7bc70),
      onSecondary: Color(0xff462a00),
      secondaryContainer: Color(0xff643f00),
      onSecondaryContainer: Color(0xffffddb6),
      tertiary: Color(0xfff0be6d),
      onTertiary: Color(0xff432c00),
      tertiaryContainer: Color(0xff604100),
      onTertiaryContainer: Color(0xffffdead),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      background: Color(0xff17130b),
      onBackground: Color(0xffece1d4),
      surface: Color(0xff17130b),
      onSurface: Color(0xffece1d4),
      surfaceVariant: Color(0xff4e4639),
      onSurfaceVariant: Color(0xffd2c5b4),
      outline: Color(0xff9a8f80),
      outlineVariant: Color(0xff4e4639),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffece1d4),
      inverseOnSurface: Color(0xff353027),
      inversePrimary: Color(0xff7b580d),
      primaryFixed: Color(0xffffdeaa),
      onPrimaryFixed: Color(0xff271900),
      primaryFixedDim: Color(0xffeebf6d),
      onPrimaryFixedVariant: Color(0xff5f4100),
      secondaryFixed: Color(0xffffddb6),
      onSecondaryFixed: Color(0xff2a1800),
      secondaryFixedDim: Color(0xfff7bc70),
      onSecondaryFixedVariant: Color(0xff643f00),
      tertiaryFixed: Color(0xffffdead),
      onTertiaryFixed: Color(0xff281900),
      tertiaryFixedDim: Color(0xfff0be6d),
      onTertiaryFixedVariant: Color(0xff604100),
      surfaceDim: Color(0xff17130b),
      surfaceBright: Color(0xff3e382f),
      surfaceContainerLowest: Color(0xff120e07),
      surfaceContainerLow: Color(0xff201b13),
      surfaceContainer: Color(0xff241f17),
      surfaceContainerHigh: Color(0xff2f2921),
      surfaceContainerHighest: Color(0xff3a342b),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff3c370),
      surfaceTint: Color(0xffeebf6d),
      onPrimary: Color(0xff201400),
      primaryContainer: Color(0xffb48a3d),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfffbc074),
      onSecondary: Color(0xff231300),
      secondaryContainer: Color(0xffbb8741),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfff5c371),
      onTertiary: Color(0xff211400),
      tertiaryContainer: Color(0xffb5893e),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffbab1),
      onError: Color(0xff370001),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      background: Color(0xff17130b),
      onBackground: Color(0xffece1d4),
      surface: Color(0xff17130b),
      onSurface: Color(0xfffffaf7),
      surfaceVariant: Color(0xff4e4639),
      onSurfaceVariant: Color(0xffd6c9b8),
      outline: Color(0xffada191),
      outlineVariant: Color(0xff8c8273),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffece1d4),
      inverseOnSurface: Color(0xff2f2921),
      inversePrimary: Color(0xff604200),
      primaryFixed: Color(0xffffdeaa),
      onPrimaryFixed: Color(0xff1a0f00),
      primaryFixedDim: Color(0xffeebf6d),
      onPrimaryFixedVariant: Color(0xff493200),
      secondaryFixed: Color(0xffffddb6),
      onSecondaryFixed: Color(0xff1c0e00),
      secondaryFixedDim: Color(0xfff7bc70),
      onSecondaryFixedVariant: Color(0xff4e3000),
      tertiaryFixed: Color(0xffffdead),
      onTertiaryFixed: Color(0xff1a0f00),
      tertiaryFixedDim: Color(0xfff0be6d),
      onTertiaryFixedVariant: Color(0xff4a3100),
      surfaceDim: Color(0xff17130b),
      surfaceBright: Color(0xff3e382f),
      surfaceContainerLowest: Color(0xff120e07),
      surfaceContainerLow: Color(0xff201b13),
      surfaceContainer: Color(0xff241f17),
      surfaceContainerHigh: Color(0xff2f2921),
      surfaceContainerHighest: Color(0xff3a342b),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xfffffaf7),
      surfaceTint: Color(0xffeebf6d),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xfff3c370),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfffffaf7),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xfffbc074),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfffffaf7),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xfff5c371),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xfffff9f9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffbab1),
      onErrorContainer: Color(0xff000000),
      background: Color(0xff17130b),
      onBackground: Color(0xffece1d4),
      surface: Color(0xff17130b),
      onSurface: Color(0xffffffff),
      surfaceVariant: Color(0xff4e4639),
      onSurfaceVariant: Color(0xfffffaf7),
      outline: Color(0xffd6c9b8),
      outlineVariant: Color(0xffd6c9b8),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffece1d4),
      inverseOnSurface: Color(0xff000000),
      inversePrimary: Color(0xff3a2600),
      primaryFixed: Color(0xffffe3b8),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xfff3c370),
      onPrimaryFixedVariant: Color(0xff201400),
      secondaryFixed: Color(0xffffe2c3),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xfffbc074),
      onSecondaryFixedVariant: Color(0xff231300),
      tertiaryFixed: Color(0xffffe3bb),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xfff5c371),
      onTertiaryFixedVariant: Color(0xff211400),
      surfaceDim: Color(0xff17130b),
      surfaceBright: Color(0xff3e382f),
      surfaceContainerLowest: Color(0xff120e07),
      surfaceContainerLow: Color(0xff201b13),
      surfaceContainer: Color(0xff241f17),
      surfaceContainerHigh: Color(0xff2f2921),
      surfaceContainerHighest: Color(0xff3a342b),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme().toColorScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
      );

  /// Custom Color
  static const customColor = ExtendedColor(
    seed: Color(0xffffd700),
    value: Color(0xffffd700),
    light: ColorFamily(
      color: Color(0xff6f5d0e),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xfffae287),
      onColorContainer: Color(0xff221b00),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff6f5d0e),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xfffae287),
      onColorContainer: Color(0xff221b00),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff6f5d0e),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xfffae287),
      onColorContainer: Color(0xff221b00),
    ),
    dark: ColorFamily(
      color: Color(0xffddc66e),
      onColor: Color(0xff3a3000),
      colorContainer: Color(0xff544600),
      onColorContainer: Color(0xfffae287),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffddc66e),
      onColor: Color(0xff3a3000),
      colorContainer: Color(0xff544600),
      onColorContainer: Color(0xfffae287),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffddc66e),
      onColor: Color(0xff3a3000),
      colorContainer: Color(0xff544600),
      onColorContainer: Color(0xfffae287),
    ),
  );

  /// Custom Color 1
  static const customColor1 = ExtendedColor(
    seed: Color(0xff681b98),
    value: Color(0xff681b98),
    light: ColorFamily(
      color: Color(0xff725187),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xfff4daff),
      onColorContainer: Color(0xff2b0b3f),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff725187),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xfff4daff),
      onColorContainer: Color(0xff2b0b3f),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff725187),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xfff4daff),
      onColorContainer: Color(0xff2b0b3f),
    ),
    dark: ColorFamily(
      color: Color(0xffe0b8f6),
      onColor: Color(0xff412356),
      colorContainer: Color(0xff59396e),
      onColorContainer: Color(0xfff4daff),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffe0b8f6),
      onColor: Color(0xff412356),
      colorContainer: Color(0xff59396e),
      onColorContainer: Color(0xfff4daff),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffe0b8f6),
      onColor: Color(0xff412356),
      colorContainer: Color(0xff59396e),
      onColorContainer: Color(0xfff4daff),
    ),
  );

  /// Custom Color 2
  static const customColor2 = ExtendedColor(
    seed: Color(0xffe0651d),
    value: Color(0xffe0651d),
    light: ColorFamily(
      color: Color(0xff8d4d2d),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdbcc),
      onColorContainer: Color(0xff351000),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff8d4d2d),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdbcc),
      onColorContainer: Color(0xff351000),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff8d4d2d),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdbcc),
      onColorContainer: Color(0xff351000),
    ),
    dark: ColorFamily(
      color: Color(0xffffb694),
      onColor: Color(0xff542104),
      colorContainer: Color(0xff703718),
      onColorContainer: Color(0xffffdbcc),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffffb694),
      onColor: Color(0xff542104),
      colorContainer: Color(0xff703718),
      onColorContainer: Color(0xffffdbcc),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffffb694),
      onColor: Color(0xff542104),
      colorContainer: Color(0xff703718),
      onColorContainer: Color(0xffffdbcc),
    ),
  );

  List<ExtendedColor> get extendedColors => [
        customColor,
        customColor1,
        customColor2,
      ];
}

class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary,
    required this.surfaceTint,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.inversePrimary,
    required this.primaryFixed,
    required this.onPrimaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixedVariant,
    required this.secondaryFixed,
    required this.onSecondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixedVariant,
    required this.tertiaryFixed,
    required this.onTertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixedVariant,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
}

extension MaterialSchemeUtils on MaterialScheme {
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    );
  }
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
