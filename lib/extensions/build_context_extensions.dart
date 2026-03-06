import 'package:flutter/cupertino.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

extension BuildContextExtensions on BuildContext {
  ShadThemeData get theme => ShadTheme.of(this);

  ShadTextTheme get textTheme => theme.textTheme;

  ShadColorScheme get colorScheme => theme.colorScheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);
}
