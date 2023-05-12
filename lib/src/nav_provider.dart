import 'package:flutter/material.dart';

import 'nav.dart';

class NavProvider extends InheritedWidget {
  const NavProvider({
    super.key,
    required this.nav,
    required super.child,
  });

  final Nav nav;

  static Nav of(BuildContext context) {
    final NavProvider? result =
        context.dependOnInheritedWidgetOfExactType<NavProvider>();
    assert(result != null, 'No Nav found in context');
    return result!.nav;
  }

  @override
  bool updateShouldNotify(NavProvider oldWidget) {
    return nav != oldWidget.nav;
  }
}
