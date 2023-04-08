import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'nav.dart';
import 'nav_data.dart';
import 'nav_delegate.dart';
import 'nav_information_parser.dart';
import 'nav_page.dart';
import 'nav_provider.dart';
import 'utils/unknown_page.dart';

class NavSettings implements RouterConfig<List<Page<void>>> {
  NavSettings({
    GlobalKey<NavigatorState>? key,
    String initialPath = Navigator.defaultRouteName,
    Object? initialState,
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
    required List<Nav> pages,
    NavPage? unknownPage,
    bool usePathUrl = true,
  }) {
    assert(
        pages
                    .where((element) => element.name != null)
                    .map((e) => e.name)
                    .toList()
                    .length ==
                pages
                    .where((element) => element.name != null)
                    .map((e) => e.name)
                    .toSet()
                    .length &&
            pages.map((e) => e.pattern).toList().length ==
                pages.map((e) => e.pattern).toSet().length,
        'Cannot create pages on NavSettings.pages with the same pattern or name');

    final binding = WidgetsFlutterBinding.ensureInitialized();

    if (usePathUrl) {
      usePathUrlStrategy();
    }

    key ??= GlobalKey<NavigatorState>();

    routeInformationParser = NavInformationParser(
      key,
      pages,
      unknownPage ?? UnknownPage(),
    );

    routerDelegate = NavDelegate(
      key,
      observers,
      this,
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

  factory NavSettings.of(BuildContext context) => NavProvider.of(context);

  @override
  final BackButtonDispatcher backButtonDispatcher = RootBackButtonDispatcher();

  @override
  late final NavInformationParser routeInformationParser;

  @override
  late final RouteInformationProvider routeInformationProvider;

  @override
  late final NavDelegate routerDelegate;
}

extension NavSettingsMethods<T extends NavSettings> on T {
  void navigate({required String location, Object? extra}) {
    routerDelegate.setNewRoutePath(routeInformationParser.getPagesByLocation(
      location,
      extra,
    ));
  }

  void popNestedNavigator() {
    final data = routerDelegate.currentConfiguration.last.arguments as NavData;

    data.children.removeAt(0);

    routerDelegate.setNewRoutePath(routerDelegate.currentConfiguration);
  }
}
