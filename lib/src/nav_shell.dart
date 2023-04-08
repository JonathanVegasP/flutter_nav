import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nav/src/web_transition_delegate.dart';

import 'enums/shell_type.dart';
import 'nav.dart';
import 'nav_data.dart';
import 'nav_settings.dart';

typedef NavShellBuilder = Widget Function(Widget child);

class NavShell extends Nav {
  final ShellType type;
  final NavShellBuilder builder;

  NavShell({
    GlobalKey<NavigatorState>? key,
    this.type = ShellType.factory,
    required super.pattern,
    super.name,
    required this.builder,
    required super.children,
  })  : assert(children
            .every((element) => element.key == null || element.key == key)),
        super(key: key ?? GlobalKey<NavigatorState>());
}

extension NavShellMethods on NavShell {
  MaterialPage<void> toPage({
    required NavData data,
    required List<Page<void>> pages,
  }) {
    Widget child = WillPopScope(
      onWillPop: () async {
        return !(await key!.currentState!.maybePop());
      },
      child: Builder(
        builder: (context) {
          return Navigator(
            key: key,
            restorationScopeId: 'nav: $pattern',
            transitionDelegate: kIsWeb
                ? const WebTransitionDelegate()
                : const DefaultTransitionDelegate<dynamic>(),
            pages: List.unmodifiable(pages),
            onPopPage: (route, result) {
              if (!route.didPop(result)) return false;

              if (pages.length == 1) {
                final settings = NavSettings.of(context);

                settings.popNestedNavigator();

                Navigator.pop(context);
              } else {
                pages.removeLast();
              }

              return true;
            },
          );
        },
      ),
    );

    if (type.isStatic) {
      child = builder(child);
    }

    return MaterialPage(
      key: ValueKey(pattern),
      restorationId: 'shell: $pattern',
      name: name,
      arguments: data,
      child: child,
    );
  }
}
