import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'nav_provider.dart';
import 'nav_settings.dart';
import 'web_transition_delegate.dart';

class NavDelegate extends RouterDelegate<List<Page<void>>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  @override
  final GlobalKey<NavigatorState> navigatorKey;
  final List<NavigatorObserver> _observers;
  final NavSettings _settings;
  late List<Page<void>> _pages;

  NavDelegate(this.navigatorKey, this._observers, this._settings);

  @override
  Widget build(BuildContext context) {
    return NavProvider(
      settings: _settings,
      child: Navigator(
        key: navigatorKey,
        observers: _observers,
        transitionDelegate: kIsWeb
            ? const WebTransitionDelegate()
            : const DefaultTransitionDelegate<dynamic>(),
        pages: List.unmodifiable(_pages),
        onPopPage: _onPopPage,
      ),
    );
  }

  bool _onPopPage(Route route, result) {
    if (!route.didPop(result)) return false;

    _pages.removeLast();

    notifyListeners();

    return true;
  }

  @override
  List<Page<void>> get currentConfiguration => _pages;

  @override
  Future<void> setInitialRoutePath(List<Page<void>> configuration) {
    _pages = configuration;

    return SynchronousFuture(null);
  }

  @override
  Future<void> setRestoredRoutePath(List<Page<void>> configuration) {
    return setInitialRoutePath(configuration);
  }

  @override
  Future<void> setNewRoutePath(List<Page<void>> configuration) {
    _pages = configuration;

    notifyListeners();

    return SynchronousFuture(null);
  }
}
