import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'nav.dart';
import 'nav_data.dart';
import 'nav_delegate.dart';
import 'nav_page.dart';
import 'utils/match.dart';
import 'utils/path.dart';
import 'web_transition_delegate.dart';

sealed class INavRoute {
  final GlobalKey<NavigatorState>? key;
  final String pattern;
  final String? name;
  final List<INavRoute> children;
  final _params = <String>[];
  late final RegExp _regExp;

  INavRoute({
    this.key,
    required this.pattern,
    this.name,
    this.children = const [],
  }) {
    _regExp = pattern.toRegExp(_params);
  }
}

// ignore: library_private_types_in_public_api
extension NavRoutePresenterMethods<T extends INavRoute> on T {
  Map<String, String>? hasMatch(String location) {
    final match = _regExp.matchAsPrefix(location);

    if (match == null) return null;

    return match.toParams(_params);
  }

  String getRawPath(Map<String, String> params) => pattern.toPath(params);
}

typedef NavRouteBuilder = Widget Function();
typedef NavShellBuilder = Widget Function(Widget child);

class NavRoute extends INavRoute {
  final NavRouteBuilder builder;

  NavRoute({
    super.key,
    required super.pattern,
    super.name,
    required this.builder,
    super.children,
  });
}

extension NavRouteMethods on NavRoute {
  NavPage<T> toPage<T>(
      {required NavData data, required NavShellBuilder? builder}) {
    var child = this.builder();

    if (builder != null) {
      child = builder(child);
    }

    return NavPage(
      key: ValueKey(pattern),
      restorationId: 'page: $pattern',
      name: name,
      arguments: data,
      child: child,
    );
  }
}

enum ShellType {
  static,
  factory;
}

class NavShell extends INavRoute {
  final ShellType type;
  final NavShellBuilder builder;

  NavShell({
    GlobalKey<NavigatorState>? key,
    this.type = ShellType.static,
    required super.pattern,
    super.name,
    required this.builder,
    required List<NavRoute> super.children,
  })  : assert(children
            .every((element) => element.key == null || element.key == key)),
        super(key: key ?? GlobalKey());
}

extension NavShellMethods on NavShell {
  NavPage<T> toPage<T>({
    required NavData data,
    required List<NavPage> pages,
    required List<NavPage> parentPages,
    required List<NavigatorObserver> observers,
  }) {
    Widget child = Builder(
      builder: (context) {
        final delegate = context.nav.routerDelegate;

        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) {
            switch (delegate.nestedPages) {
              case null:
                delegate.nestedPages = (
                  pages: [...pages, ...parentPages],
                  navigatorKeys: [key!],
                );
              default:
                final NestedNavPage(pages: nestedPages, :navigatorKeys) =
                    delegate.nestedPages!;

                nestedPages.addAll([...pages, ...parentPages]);
                navigatorKeys.add(key!);
            }

            delegate.notifyNestedNavigator();
          },
        );

        return Navigator(
          key: key,
          restorationScopeId: 'nav: $pattern',
          transitionDelegate: switch (kIsWeb) {
            true => const WebTransitionDelegate(),
            _ => const DefaultTransitionDelegate()
          },
          observers: observers,
          pages: List.unmodifiable(pages),
          onPopPage: (route, result) {
            if (!route.didPop(result)) return false;

            final NestedNavPage(pages: nestedPages, :navigatorKeys) =
                delegate.nestedPages!;

            switch (pages.length) {
              case 1:
                switch (nestedPages.length != pages.length) {
                  case true:
                    nestedPages.removeLast();
                    navigatorKeys.removeLast();
                  default:
                    delegate.nestedPages = null;
                }

                delegate.notifyNestedNavigator();

                Navigator.pop(context);
              default:
                if (nestedPages.length != pages.length) {
                  nestedPages.removeLast();
                }

                pages.removeLast();
                delegate.notifyNestedNavigator();
            }

            return true;
          },
        );
      },
    );

    if (type == ShellType.static) {
      child = builder(child);
    }

    child = WillPopScope(
      onWillPop: () async => !(await key!.currentState!.maybePop()),
      child: child,
    );

    return NavPage(
      key: ValueKey(pattern),
      restorationId: 'shell $pattern',
      arguments: data,
      child: child,
    );
  }
}
