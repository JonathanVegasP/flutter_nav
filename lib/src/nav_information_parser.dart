import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'enums/shell_type.dart';
import 'nav.dart';
import 'nav_data.dart';
import 'nav_page.dart';
import 'nav_shell.dart';

class NavInformationParser extends RouteInformationParser<List<Page<void>>> {
  final GlobalKey<NavigatorState> _key;
  final List<Nav> _pages;
  final NavPage _unknownPage;

  NavInformationParser(this._key, this._pages, this._unknownPage);

  @override
  Future<List<Page<void>>> parseRouteInformation(
      RouteInformation routeInformation) {
    return SynchronousFuture(getPagesByLocation(
      _canonicalLocation(routeInformation.location!),
      routeInformation.state,
    ));
  }

  @override
  RouteInformation? restoreRouteInformation(List<Page<void>> configuration) {
    var data = configuration.last.arguments as NavData;

    if (data.children.isNotEmpty) {
      data = data.children.first;
    }

    return RouteInformation(location: data.url, state: data.extra);
  }
}

extension NavInformationParserMethods on NavInformationParser {
  List<Page<void>> getPagesByLocation(String location, Object? extra) {
    final loc = Uri.parse(location);

    var pages = _getPagesByLocation(
      key: _key,
      location: loc,
      pages: _pages,
      params: {},
      extra: extra,
    );

    if (pages.isEmpty) {
      pages = [
        _unknownPage.toPage(
          data: NavData(uri: loc, pathParams: const {}, extra: extra),
        )
      ];
    }

    return pages;
  }

  String _canonicalLocation(String location) {
    if (location.endsWith('?')) {
      location = location.substring(0, location.length - 1);
    }

    if (location != '/' && !location.contains('?') && location.endsWith('/')) {
      location = location.substring(0, location.length - 1);
    }

    return location.replaceFirst('/?', '?', 1);
  }
}

List<Page<void>> _getPagesByLocation({
  required GlobalKey<NavigatorState> key,
  required Uri location,
  required List<Nav> pages,
  required Map<String, String> params,
  required Object? extra,
  String parentLocation = '/',
  List<Page<void>>? rootPages,
  NavShellBuilder? builder,
  List<NavData>? childPages,
}) {
  final url = location.path.toLowerCase();

  for (final page in pages) {
    final pageParams = page.hasMatch(url);

    if (pageParams == null) continue;

    final path = page.getRawPath(pageParams);

    String currentLocation;

    Uri currentLocationUri;

    if (parentLocation == '/') {
      currentLocation = path;
    } else if (path == '/') {
      currentLocation = parentLocation;
    } else {
      currentLocation = '$parentLocation$path';
    }

    currentLocationUri = location.replace(path: currentLocation);

    if (path == url && page is NavPage) {
      params.addAll(params);

      if (page.key == key) builder = null;

      final data = NavData(
        uri: currentLocationUri,
        pathParams: params,
        extra: extra,
      );

      final result = page.toPage(
        data: data,
        builder: builder,
      );

      if (rootPages != null && page.key == key) {
        rootPages.add(result);

        break;
      }

      childPages?.add(data);

      return [result];
    } else if (page.children.isNotEmpty) {
      Uri nextLocation;

      if (path == '/') {
        nextLocation = location;
      } else {
        nextLocation = location.replace(path: url.replaceFirst(path, ''));
      }

      if (page is NavShell) {
        final List<Page<void>> currentRootPages = [];
        final List<Page<void>> nextRootPages;
        final List<NavData> currentChildPages;

        if (childPages == null) {
          currentChildPages = [];
        } else {
          currentChildPages = childPages;
        }

        if (rootPages == null) {
          nextRootPages = currentRootPages;
        } else {
          nextRootPages = rootPages;
        }

        final NavShellBuilder? shellBuilder;

        if (page.type.isFactory) {
          if (builder == null) {
            shellBuilder = page.builder;
          } else {
            shellBuilder = (child) => builder!(page.builder(child));
          }
        } else {
          shellBuilder = null;
        }

        final results = _getPagesByLocation(
          key: key,
          location: nextLocation,
          pages: page.children,
          params: params,
          extra: extra,
          parentLocation: currentLocation,
          builder: shellBuilder,
          rootPages: nextRootPages,
          childPages: currentChildPages,
        );

        if (results.isEmpty) continue;

        params.addAll(pageParams);

        return [
          page.toPage(
            data: NavData(
              uri: currentLocationUri,
              pathParams: params,
              extra: extra,
            )..children.addAll(currentChildPages),
            pages: results,
          ),
          ...currentRootPages
        ];
      } else if (page is NavPage) {
        final List<Page<void>>? currentRootPages;
        final NavShellBuilder? shellBuilder;

        if (page.key == key) {
          currentRootPages = null;
          shellBuilder = null;
          childPages = null;
        } else {
          currentRootPages = rootPages;
          shellBuilder = builder;
        }

        final results = _getPagesByLocation(
          key: key,
          location: nextLocation,
          pages: page.children,
          params: params,
          extra: extra,
          parentLocation: currentLocation,
          rootPages: currentRootPages,
          builder: shellBuilder,
          childPages: childPages,
        );

        if (results.isEmpty && (rootPages == null || rootPages.isEmpty)) {
          continue;
        }

        params.addAll(pageParams);

        final data = NavData(
          uri: currentLocationUri,
          pathParams: params,
          extra: extra,
        );

        final result = page.toPage(
          data: data,
          builder: builder,
        );

        if (rootPages != null && page.key == key) {
          rootPages.add(result);
          rootPages.addAll(results);

          break;
        }

        childPages?.add(data);

        return [result, ...results];
      }
    }
  }

  return [];
}
