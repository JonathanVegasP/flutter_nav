import 'package:flutter/material.dart';

import 'nav.dart';
import 'nav_data.dart';
import 'nav_shell.dart';

class NavPage extends Nav {
  final ValueGetter<Widget> builder;

  NavPage({
    super.key,
    required super.pattern,
    super.name,
    required this.builder,
    super.children,
  });
}

extension NavPageMethods on NavPage {
  MaterialPage<void> toPage({required NavData data, NavShellBuilder? builder}) {
    var child = this.builder();

    if (builder != null) {
      child = builder(child);
    }

    return MaterialPage(
      key: ValueKey(pattern),
      restorationId: 'page: $pattern',
      arguments: data,
      name: name,
      child: child,
    );
  }
}
