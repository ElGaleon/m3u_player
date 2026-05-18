import 'dart:ui';

import 'package:shadcn_ui/shadcn_ui.dart';

final lightThemeData = ShadThemeData(
  brightness: Brightness.light,
  colorScheme: const ShadSlateColorScheme.light(),
  textTheme: ShadTextTheme(),
);

final darkThemeData = ShadThemeData(
  brightness: Brightness.dark,
  colorScheme: const ShadSlateColorScheme.dark(),
);
