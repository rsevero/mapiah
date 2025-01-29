import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4287450667),
      surfaceTint: Color(4287450667),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4294958027),
      onPrimaryContainer: Color(4281602304),
      secondary: Color(4285945929),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4294958027),
      onSecondaryContainer: Color(4281079307),
      tertiary: Color(4284833841),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4293715114),
      onTertiaryContainer: Color(4280228864),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      background: Color(4294965494),
      onBackground: Color(4280424982),
      surface: Color(4294965494),
      onSurface: Color(4280424982),
      surfaceVariant: Color(4294237909),
      onSurfaceVariant: Color(4283581501),
      outline: Color(4286935916),
      outlineVariant: Color(4292330169),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281871914),
      inverseOnSurface: Color(4294962662),
      inversePrimary: Color(4294948498),
      primaryFixed: Color(4294958027),
      onPrimaryFixed: Color(4281602304),
      primaryFixedDim: Color(4294948498),
      onPrimaryFixedVariant: Color(4285544214),
      secondaryFixed: Color(4294958027),
      onSecondaryFixed: Color(4281079307),
      secondaryFixedDim: Color(4293312172),
      onSecondaryFixedVariant: Color(4284235827),
      tertiaryFixed: Color(4293715114),
      onTertiaryFixed: Color(4280228864),
      tertiaryFixedDim: Color(4291807376),
      onTertiaryFixedVariant: Color(4283189276),
      surfaceDim: Color(4293449680),
      surfaceBright: Color(4294965494),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294963691),
      surfaceContainer: Color(4294765283),
      surfaceContainerHigh: Color(4294370781),
      surfaceContainerHighest: Color(4293976024),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4285215507),
      surfaceTint: Color(4287450667),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4289225535),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4283972911),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4287524190),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4282926104),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4286281285),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      background: Color(4294965494),
      onBackground: Color(4280424982),
      surface: Color(4294965494),
      onSurface: Color(4280424982),
      surfaceVariant: Color(4294237909),
      onSurfaceVariant: Color(4283318329),
      outline: Color(4285291604),
      outlineVariant: Color(4287199087),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281871914),
      inverseOnSurface: Color(4294962662),
      inversePrimary: Color(4294948498),
      primaryFixed: Color(4289225535),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4287253289),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4287524190),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4285814086),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4286281285),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4284636463),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4293449680),
      surfaceBright: Color(4294965494),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294963691),
      surfaceContainer: Color(4294765283),
      surfaceContainerHigh: Color(4294370781),
      surfaceContainerHighest: Color(4293976024),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4282324480),
      surfaceTint: Color(4287450667),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4285215507),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4281539857),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4283972911),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4280689408),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4282926104),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      background: Color(4294965494),
      onBackground: Color(4280424982),
      surface: Color(4294965494),
      onSurface: Color(4278190080),
      surfaceVariant: Color(4294237909),
      onSurfaceVariant: Color(4281147675),
      outline: Color(4283318329),
      outlineVariant: Color(4283318329),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281871914),
      inverseOnSurface: Color(4294967295),
      inversePrimary: Color(4294961117),
      primaryFixed: Color(4285215507),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4283375105),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4283972911),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4282328858),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4282926104),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4281412868),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4293449680),
      surfaceBright: Color(4294965494),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294963691),
      surfaceContainer: Color(4294765283),
      surfaceContainerHigh: Color(4294370781),
      surfaceContainerHighest: Color(4293976024),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294948498),
      surfaceTint: Color(4294948498),
      onPrimary: Color(4283703555),
      primaryContainer: Color(4285544214),
      onPrimaryContainer: Color(4294958027),
      secondary: Color(4293312172),
      onSecondary: Color(4282591774),
      secondaryContainer: Color(4284235827),
      onSecondaryContainer: Color(4294958027),
      tertiary: Color(4291807376),
      onTertiary: Color(4281676039),
      tertiaryContainer: Color(4283189276),
      onTertiaryContainer: Color(4293715114),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      background: Color(4279898638),
      onBackground: Color(4293976024),
      surface: Color(4279898638),
      onSurface: Color(4293976024),
      surfaceVariant: Color(4283581501),
      onSurfaceVariant: Color(4292330169),
      outline: Color(4288712069),
      outlineVariant: Color(4283581501),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293976024),
      inverseOnSurface: Color(4281871914),
      inversePrimary: Color(4287450667),
      primaryFixed: Color(4294958027),
      onPrimaryFixed: Color(4281602304),
      primaryFixedDim: Color(4294948498),
      onPrimaryFixedVariant: Color(4285544214),
      secondaryFixed: Color(4294958027),
      onSecondaryFixed: Color(4281079307),
      secondaryFixedDim: Color(4293312172),
      onSecondaryFixedVariant: Color(4284235827),
      tertiaryFixed: Color(4293715114),
      onTertiaryFixed: Color(4280228864),
      tertiaryFixedDim: Color(4291807376),
      onTertiaryFixedVariant: Color(4283189276),
      surfaceDim: Color(4279898638),
      surfaceBright: Color(4282529586),
      surfaceContainerLowest: Color(4279503881),
      surfaceContainerLow: Color(4280424982),
      surfaceContainer: Color(4280753689),
      surfaceContainerHigh: Color(4281477155),
      surfaceContainerHighest: Color(4282200878),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294950043),
      surfaceTint: Color(4294948498),
      onPrimary: Color(4281076992),
      primaryContainer: Color(4291395160),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4293640880),
      onSecondary: Color(4280619270),
      secondaryContainer: Color(4289563000),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4292136084),
      onTertiary: Color(4279834368),
      tertiaryContainer: Color(4288189023),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      background: Color(4279898638),
      onBackground: Color(4293976024),
      surface: Color(4279898638),
      onSurface: Color(4294965752),
      surfaceVariant: Color(4283581501),
      onSurfaceVariant: Color(4292658877),
      outline: Color(4289896342),
      outlineVariant: Color(4287725431),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293976024),
      inverseOnSurface: Color(4281477155),
      inversePrimary: Color(4285675543),
      primaryFixed: Color(4294958027),
      onPrimaryFixed: Color(4280551680),
      primaryFixedDim: Color(4294948498),
      onPrimaryFixedVariant: Color(4284163847),
      secondaryFixed: Color(4294958027),
      onSecondaryFixed: Color(4280224771),
      secondaryFixedDim: Color(4293312172),
      onSecondaryFixedVariant: Color(4283052067),
      tertiaryFixed: Color(4293715114),
      onTertiaryFixed: Color(4279505408),
      tertiaryFixedDim: Color(4291807376),
      onTertiaryFixedVariant: Color(4282070797),
      surfaceDim: Color(4279898638),
      surfaceBright: Color(4282529586),
      surfaceContainerLowest: Color(4279503881),
      surfaceContainerLow: Color(4280424982),
      surfaceContainer: Color(4280753689),
      surfaceContainerHigh: Color(4281477155),
      surfaceContainerHighest: Color(4282200878),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294965752),
      surfaceTint: Color(4294948498),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4294950043),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294965752),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4293640880),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294966001),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4292136084),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      background: Color(4279898638),
      onBackground: Color(4293976024),
      surface: Color(4279898638),
      onSurface: Color(4294967295),
      surfaceVariant: Color(4283581501),
      onSurfaceVariant: Color(4294965752),
      outline: Color(4292658877),
      outlineVariant: Color(4292658877),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293976024),
      inverseOnSurface: Color(4278190080),
      inversePrimary: Color(4283112192),
      primaryFixed: Color(4294959571),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4294950043),
      onPrimaryFixedVariant: Color(4281076992),
      secondaryFixed: Color(4294959571),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4293640880),
      onSecondaryFixedVariant: Color(4280619270),
      tertiaryFixed: Color(4294043822),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4292136084),
      onTertiaryFixedVariant: Color(4279834368),
      surfaceDim: Color(4279898638),
      surfaceBright: Color(4282529586),
      surfaceContainerLowest: Color(4279503881),
      surfaceContainerLow: Color(4280424982),
      surfaceContainer: Color(4280753689),
      surfaceContainerHigh: Color(4281477155),
      surfaceContainerHighest: Color(4282200878),
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
    seed: Color(4282351303),
    value: Color(4282351303),
    light: ColorFamily(
      color: Color(4282015887),
      onColor: Color(4294967295),
      colorContainer: Color(4292076543),
      onColorContainer: Color(4278197305),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(4282015887),
      onColor: Color(4294967295),
      colorContainer: Color(4292076543),
      onColorContainer: Color(4278197305),
    ),
    lightHighContrast: ColorFamily(
      color: Color(4282015887),
      onColor: Color(4294967295),
      colorContainer: Color(4292076543),
      onColorContainer: Color(4278197305),
    ),
    dark: ColorFamily(
      color: Color(4288989694),
      onColor: Color(4278202717),
      colorContainer: Color(4280305782),
      onColorContainer: Color(4292076543),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(4288989694),
      onColor: Color(4278202717),
      colorContainer: Color(4280305782),
      onColorContainer: Color(4292076543),
    ),
    darkHighContrast: ColorFamily(
      color: Color(4288989694),
      onColor: Color(4278202717),
      colorContainer: Color(4280305782),
      onColorContainer: Color(4292076543),
    ),
  );

  List<ExtendedColor> get extendedColors => [
        customColor,
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
      surfaceContainerHighest: surfaceVariant,
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
