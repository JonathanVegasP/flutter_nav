import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'nav_data.dart';
import 'nav_delegate.dart';
import 'nav_information_parser.dart';
import 'nav_page.dart';
import 'nav_provider.dart';
import 'nav_route.dart';
import 'utils/unknown_page.dart';

class Nav implements RouterConfig<List<NavPage>> {
  Nav({
    GlobalKey<NavigatorState>? key,
    String initialPath = Navigator.defaultRouteName,
    Object? initialState,
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
    required List<INavRoute> routes,
    bool usePathUrl = true,
  }) {
    final binding = WidgetsFlutterBinding.ensureInitialized();

    if (usePathUrl) {
      usePathUrlStrategy();
    }

    key ??= GlobalKey<NavigatorState>();

    routerDelegate = NavDelegate(
      key,
      observers,
      this,
    );

    routeInformationParser = NavInformationParser(
      key,
      observers,
      routes,
    );

    var path = binding.platformDispatcher.defaultRouteName;

    if (path == Navigator.defaultRouteName) {
      path = initialPath;
    }

    routeInformationProvider = PlatformRouteInformationProvider(
        initialRouteInformation: RouteInformation(
      location: path,
      state: initialState,
    ));
  }

  @override
  final BackButtonDispatcher backButtonDispatcher = RootBackButtonDispatcher();

  @override
  late final NavInformationParser routeInformationParser;

  @override
  late final RouteInformationProvider? routeInformationProvider;

  @override
  late final NavDelegate routerDelegate;
}

extension NavMethods on Nav {
  void navigate({required String location, Object? extra}) {
    final pages = routeInformationParser.getPages(
      location: location,
      extra: extra,
    );

    routerDelegate.setNewRoutePath(pages);
  }

  Future<T?> push<T>({required String location, Object? extra}) {
    final page = routeInformationParser
        .getPages<T>(
          location: location,
          extra: extra,
        )
        .last;

    if (page is UnknownPage<T>) {
      return SynchronousFuture(null);
    }

    return routerDelegate.navigatorKey.currentState!.push(page.createRoute());
  }

  void pop<T>([T? result]) {
    final key = routerDelegate.nestedPages?.navigatorKeys.last ??
        routerDelegate.navigatorKey;

    key.currentState!.pop<T>(result);
  }
}

extension NavBuildContext on BuildContext {
  Nav get nav => NavProvider.of(this);

  NavData get navData => (ModalRoute.of(this)!.settings as NavPage).arguments;

  void navigate({required String location, Object? extra}) {
    nav.navigate(location: location, extra: extra);
  }

  Future<T?> push<T>({required String location, Object? extra}) {
    return nav.push(location: location, extra: extra);
  }

  void pop<T>([T? result]) => Navigator.pop<T>(this, result);
}
