import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      background: Color(4294965494),
      error: Color(4290386458),
      errorContainer: Color(4294957782),
      inverseOnSurface: Color(4294962661),
      inversePrimary: Color(4294948493),
      inverseSurface: Color(4282002984),
      onBackground: Color(4280490260),
      onError: Color(4294967295),
      onErrorContainer: Color(4282449922),
      onPrimary: Color(4294967295),
      onPrimaryContainer: Color(4294967295),
      onPrimaryFixed: Color(4281471488),
      onPrimaryFixedVariant: Color(4285936640),
      onSecondary: Color(4294967295),
      onSecondaryContainer: Color(4284297493),
      onSecondaryFixed: Color(4281471488),
      onSecondaryFixedVariant: Color(4285086494),
      onSurface: Color(4280490260),
      onSurfaceVariant: Color(4283843384),
      onTertiary: Color(4294967295),
      onTertiaryContainer: Color(4294967295),
      onTertiaryFixed: Color(4280032512),
      onTertiaryFixedVariant: Color(4282927616),
      outline: Color(4287263334),
      outlineVariant: Color(4292723123),
      primary: Color(4286855936),
      primaryContainer: Color(4290467848),
      primaryFixed: Color(4294958025),
      primaryFixedDim: Color(4294948493),
      scrim: Color(4278190080),
      secondary: Color(4286927411),
      secondaryContainer: Color(4294951842),
      secondaryFixed: Color(4294958025),
      secondaryFixedDim: Color(4294686866),
      shadow: Color(4278190080),
      surface: Color(4294965494),
      surfaceBright: Color(4294965494),
      surfaceContainer: Color(4294896352),
      surfaceContainerHigh: Color(4294501595),
      surfaceContainerHighest: Color(4294107093),
      surfaceContainerLow: Color(4294963691),
      surfaceContainerLowest: Color(4294967295),
      surfaceDim: Color(4293580493),
      surfaceTint: Color(4288300544),
      surfaceVariant: Color(4294630862),
      tertiary: Color(4283519744),
      tertiaryContainer: Color(4285954304),
      tertiaryFixed: Color(4293257828),
      tertiaryFixedDim: Color(4291415371),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4285477120),
      surfaceTint: Color(4288300544),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4290467848),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4284757787),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4288571463),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4282664448),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4285954304),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      background: Color(4294965494),
      onBackground: Color(4280490260),
      surface: Color(4294965494),
      onSurface: Color(4280490260),
      surfaceVariant: Color(4294630862),
      onSurfaceVariant: Color(4283580212),
      outline: Color(4285553487),
      outlineVariant: Color(4287460970),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4282002984),
      inverseOnSurface: Color(4294962661),
      inversePrimary: Color(4294948493),
      primaryFixed: Color(4290467848),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4288103424),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4288571463),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4286730289),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4285954304),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4284309504),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4293580493),
      surfaceBright: Color(4294965494),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294963691),
      surfaceContainer: Color(4294896352),
      surfaceContainerHigh: Color(4294501595),
      surfaceContainerHighest: Color(4294107093),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4282193664),
      surfaceTint: Color(4288300544),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4285477120),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4282128385),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4284757787),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4280493056),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4282664448),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      background: Color(4294965494),
      onBackground: Color(4280490260),
      surface: Color(4294965494),
      onSurface: Color(4278190080),
      surfaceVariant: Color(4294630862),
      onSurfaceVariant: Color(4281344023),
      outline: Color(4283580212),
      outlineVariant: Color(4283580212),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4282002984),
      inverseOnSurface: Color(4294967295),
      inversePrimary: Color(4294961116),
      primaryFixed: Color(4285477120),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4283244288),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4284757787),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4282982919),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4282664448),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4281151232),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4293580493),
      surfaceBright: Color(4294965494),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294963691),
      surfaceContainer: Color(4294896352),
      surfaceContainerHigh: Color(4294501595),
      surfaceContainerHighest: Color(4294107093),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294948493),
      surfaceTint: Color(4294948493),
      onPrimary: Color(4283638272),
      primaryContainer: Color(4290467848),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4294686866),
      onSecondary: Color(4283311370),
      secondaryContainer: Color(4284363286),
      onSecondaryContainer: Color(4294952357),
      tertiary: Color(4291415371),
      onTertiary: Color(4281414400),
      tertiaryContainer: Color(4285954304),
      onTertiaryContainer: Color(4294967295),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      background: Color(4279963916),
      onBackground: Color(4294107093),
      surface: Color(4279963916),
      onSurface: Color(4294107093),
      surfaceVariant: Color(4283843384),
      onSurfaceVariant: Color(4292723123),
      outline: Color(4289039487),
      outlineVariant: Color(4283843384),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4294107093),
      inverseOnSurface: Color(4282002984),
      inversePrimary: Color(4288300544),
      primaryFixed: Color(4294958025),
      onPrimaryFixed: Color(4281471488),
      primaryFixedDim: Color(4294948493),
      onPrimaryFixedVariant: Color(4285936640),
      secondaryFixed: Color(4294958025),
      onSecondaryFixed: Color(4281471488),
      secondaryFixedDim: Color(4294686866),
      onSecondaryFixedVariant: Color(4285086494),
      tertiaryFixed: Color(4293257828),
      onTertiaryFixed: Color(4280032512),
      tertiaryFixedDim: Color(4291415371),
      onTertiaryFixedVariant: Color(4282927616),
      surfaceDim: Color(4279963916),
      surfaceBright: Color(4282595120),
      surfaceContainerLowest: Color(4279569415),
      surfaceContainerLow: Color(4280490260),
      surfaceContainer: Color(4280818968),
      surfaceContainerHigh: Color(4281542690),
      surfaceContainerHighest: Color(4282266156),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      background: Color(4279963916),
      error: Color(4294949553),
      errorContainer: Color(4294923337),
      inverseOnSurface: Color(4281542690),
      inversePrimary: Color(4286002176),
      inverseSurface: Color(4294107093),
      onBackground: Color(4294107093),
      onError: Color(4281794561),
      onErrorContainer: Color(4278190080),
      onPrimary: Color(4280946176),
      onPrimaryContainer: Color(4278190080),
      onPrimaryFixed: Color(4280420864),
      onPrimaryFixedVariant: Color(4284229376),
      onSecondary: Color(4280946176),
      onSecondaryContainer: Color(4278190080),
      onSecondaryFixed: Color(4280420864),
      onSecondaryFixedVariant: Color(4283771664),
      onSurface: Color(4294966008),
      onSurfaceVariant: Color(4292986295),
      onTertiary: Color(4279703552),
      onTertiaryContainer: Color(4278190080),
      onTertiaryFixed: Color(4279308800),
      onTertiaryFixedVariant: Color(4281809152),
      outline: Color(4290289296),
      outlineVariant: Color(4288052850),
      primary: Color(4294950038),
      primaryContainer: Color(4292834088),
      primaryFixed: Color(4294958025),
      primaryFixedDim: Color(4294948493),
      scrim: Color(4278190080),
      secondary: Color(4294950038),
      secondaryContainer: Color(4290675553),
      secondaryFixed: Color(4294958025),
      secondaryFixedDim: Color(4294686866),
      shadow: Color(4278190080),
      surface: Color(4279963916),
      surfaceBright: Color(4282595120),
      surfaceContainer: Color(4280818968),
      surfaceContainerHigh: Color(4281542690),
      surfaceContainerHighest: Color(4282266156),
      surfaceContainerLow: Color(4280490260),
      surfaceContainerLowest: Color(4279569415),
      surfaceDim: Color(4279963916),
      surfaceTint: Color(4294948493),
      surfaceVariant: Color(4283843384),
      tertiary: Color(4291678799),
      tertiaryContainer: Color(4287796754),
      tertiaryFixed: Color(4293257828),
      tertiaryFixedDim: Color(4291415371),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294966008),
      surfaceTint: Color(4294948493),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4294950038),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294966008),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4294950038),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294901689),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4291678799),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      background: Color(4279963916),
      onBackground: Color(4294107093),
      surface: Color(4279963916),
      onSurface: Color(4294967295),
      surfaceVariant: Color(4283843384),
      onSurfaceVariant: Color(4294966008),
      outline: Color(4292986295),
      outlineVariant: Color(4292986295),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4294107093),
      inverseOnSurface: Color(4278190080),
      inversePrimary: Color(4282981632),
      primaryFixed: Color(4294959570),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4294950038),
      onPrimaryFixedVariant: Color(4280946176),
      secondaryFixed: Color(4294959570),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4294950038),
      onSecondaryFixedVariant: Color(4280946176),
      tertiaryFixed: Color(4293586536),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4291678799),
      onTertiaryFixedVariant: Color(4279703552),
      surfaceDim: Color(4279963916),
      surfaceBright: Color(4282595120),
      surfaceContainerLowest: Color(4279569415),
      surfaceContainerLow: Color(4280490260),
      surfaceContainer: Color(4280818968),
      surfaceContainerHigh: Color(4281542690),
      surfaceContainerHighest: Color(4282266156),
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
    seed: Color(4294956800),
    value: Color(4294956800),
    light: ColorFamily(
      color: Color(4285553920),
      onColor: Color(4294967295),
      colorContainer: Color(4294958416),
      onColorContainer: Color(4283647232),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(4285553920),
      onColor: Color(4294967295),
      colorContainer: Color(4294958416),
      onColorContainer: Color(4283647232),
    ),
    lightHighContrast: ColorFamily(
      color: Color(4285553920),
      onColor: Color(4294967295),
      colorContainer: Color(4294958416),
      onColorContainer: Color(4283647232),
    ),
    dark: ColorFamily(
      color: Color(4294967295),
      onColor: Color(4282003456),
      colorContainer: Color(4294562304),
      onColorContainer: Color(4283186688),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(4294967295),
      onColor: Color(4282003456),
      colorContainer: Color(4294562304),
      onColorContainer: Color(4283186688),
    ),
    darkHighContrast: ColorFamily(
      color: Color(4294967295),
      onColor: Color(4282003456),
      colorContainer: Color(4294562304),
      onColorContainer: Color(4283186688),
    ),
  );

  /// Custom Color 1
  static const customColor1 = ExtendedColor(
    seed: Color(4285012888),
    value: Color(4285012888),
    light: ColorFamily(
      color: Color(4283433084),
      onColor: Color(4294967295),
      colorContainer: Color(4286066600),
      onColorContainer: Color(4294964479),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(4283433084),
      onColor: Color(4294967295),
      colorContainer: Color(4286066600),
      onColorContainer: Color(4294964479),
    ),
    lightHighContrast: ColorFamily(
      color: Color(4283433084),
      onColor: Color(4294967295),
      colorContainer: Color(4286066600),
      onColorContainer: Color(4294964479),
    ),
    dark: ColorFamily(
      color: Color(4293178879),
      onColor: Color(4283302009),
      colorContainer: Color(4284353423),
      onColorContainer: Color(4293509887),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(4293178879),
      onColor: Color(4283302009),
      colorContainer: Color(4284353423),
      onColorContainer: Color(4293509887),
    ),
    darkHighContrast: ColorFamily(
      color: Color(4293178879),
      onColor: Color(4283302009),
      colorContainer: Color(4284353423),
      onColorContainer: Color(4293509887),
    ),
  );

  /// Custom Color 2
  static const customColor2 = ExtendedColor(
    seed: Color(4294930224),
    value: Color(4294930224),
    light: ColorFamily(
      color: Color(4289149440),
      onColor: Color(4294967295),
      colorContainer: Color(4294935376),
      onColorContainer: Color(4281797888),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(4289149440),
      onColor: Color(4294967295),
      colorContainer: Color(4294935376),
      onColorContainer: Color(4281797888),
    ),
    lightHighContrast: ColorFamily(
      color: Color(4289149440),
      onColor: Color(4294967295),
      colorContainer: Color(4294935376),
      onColorContainer: Color(4281797888),
    ),
    dark: ColorFamily(
      color: Color(4294948249),
      onColor: Color(4284095488),
      colorContainer: Color(4294273065),
      onColorContainer: Color(4278190080),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(4294948249),
      onColor: Color(4284095488),
      colorContainer: Color(4294273065),
      onColorContainer: Color(4278190080),
    ),
    darkHighContrast: ColorFamily(
      color: Color(4294948249),
      onColor: Color(4284095488),
      colorContainer: Color(4294273065),
      onColorContainer: Color(4278190080),
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
