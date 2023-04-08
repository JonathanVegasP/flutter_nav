import 'package:flutter/widgets.dart';

import 'nav_settings.dart';

class NavProvider extends InheritedWidget {
  const NavProvider({
    super.key,
    required this.settings,
    required super.child,
  });

  final NavSettings settings;

  static NavSettings of(BuildContext context) {
    final NavProvider? result = context
        .getElementForInheritedWidgetOfExactType<NavProvider>()
        ?.widget as NavProvider?;
    assert(result != null, 'No NavProvider found in context');
    return result!.settings;
  }

  @override
  bool updateShouldNotify(NavProvider oldWidget) => false;
}
