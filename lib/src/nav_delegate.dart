import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'nav.dart';
import 'nav_page.dart';
import 'nav_provider.dart';
import 'web_transition_delegate.dart';

class NavDelegate extends RouterDelegate<List<NavPage>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  late List<NavPage> _pages;
  final List<NavigatorObserver> _observers;
  final Nav _nav;
  @override
  final GlobalKey<NavigatorState> navigatorKey;
  NestedNavPage? nestedPages;

  NavDelegate(this.navigatorKey, this._observers, this._nav);

  bool _onPopPage(Route route, result) {
    if (!route.didPop(result)) return false;

    _pages.removeLast();

    nestedPages?.pages.removeLast();

    notifyListeners();

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return NavProvider(
      nav: _nav,
      child: Navigator(
        key: navigatorKey,
        restorationScopeId: 'nav',
        transitionDelegate: switch (kIsWeb) {
          true => const WebTransitionDelegate(),
          _ => const DefaultTransitionDelegate(),
        },
        observers: _observers,
        pages: List.unmodifiable(_pages),
        onPopPage: _onPopPage,
      ),
    );
  }

  @override
  List<NavPage> get currentConfiguration {
    return nestedPages?.pages ?? _pages;
  }

  @override
  Future<void> setInitialRoutePath(List<NavPage> configuration) {
    nestedPages = null;

    _pages = configuration;

    return SynchronousFuture(null);
  }

  @override
  Future<void> setRestoredRoutePath(List<NavPage> configuration) {
    nestedPages = null;

    _pages = configuration;

    return SynchronousFuture(null);
  }

  @override
  Future<void> setNewRoutePath(List<NavPage> configuration) {
    nestedPages = null;

    _pages = configuration;

    notifyListeners();

    return SynchronousFuture(null);
  }
}

extension NavDelegateMethods on NavDelegate {
  void notifyNestedNavigator() {
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    notifyListeners();
  }
}
