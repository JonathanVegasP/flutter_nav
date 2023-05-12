import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'nav_data.dart';
import 'nav_page.dart';
import 'nav_route.dart';
import 'utils/path.dart';
import 'utils/unknown_page.dart';

class NavInformationParser extends RouteInformationParser<List<NavPage>> {
  final GlobalKey<NavigatorState> _key;
  final List<NavigatorObserver> _observers;
  final List<INavRoute> _routes;

  NavInformationParser(
    this._key,
    this._observers,
    this._routes,
  );

  @override
  Future<List<NavPage>> parseRouteInformation(
      RouteInformation routeInformation) {
    final RouteInformation(:location!, state: extra) = routeInformation;
    return SynchronousFuture(getPages(
      location: location.canonicalPath(),
      extra: extra,
    ));
  }

  @override
  RouteInformation? restoreRouteInformation(List<NavPage> configuration) {
    final NavData(:extra, :url) = configuration.last.arguments;

    return RouteInformation(location: url, state: extra);
  }
}

extension NavInformationParserMethods on NavInformationParser {
  List<NavPage<T>> getPages<T>({required String location, Object? extra}) {
    final pages = _getPages<T>(
      key: _key,
      uri: Uri.parse(location),
      observers: _observers,
      pages: _routes,
      params: {},
      extra: extra,
    );

    if (pages.isEmpty) return [UnknownPage()];

    return pages;
  }
}

List<NavPage<T>> _getPages<T>({
  required final GlobalKey<NavigatorState> key,
  required final Uri uri,
  required final List<NavigatorObserver> observers,
  required final List<INavRoute> pages,
  required final Map<String, String> params,
  required final Object? extra,
  final String parentLocation = '/',
  final List<NavPage<T>>? parentPages,
  final NavShellBuilder? builder,
}) {
  final path = uri.path.toLowerCase();

  for (final page in pages) {
    final pageParams = page.hasMatch(path);

    if (pageParams == null) continue;

    final pagePath = page.getRawPath(params);

    final String currentLocation = switch (parentLocation) {
      '/' => pagePath,
      _ => '$parentLocation$pagePath'
    };

    final currentUri = uri.replace(path: currentLocation);

    switch (page) {
      case NavRoute(key: final pageKey) when pagePath == path:
        params.addAll(pageParams);

        NavShellBuilder? shellBuilder;

        if (pageKey != key) shellBuilder = builder;

        final data = navData(
          uri: currentUri,
          pathParams: params,
          extra: extra,
        );

        final result = page.toPage<T>(data: data, builder: shellBuilder);

        if (parentPages != null && pageKey == key) {
          parentPages.add(result);

          break;
        }

        return [result];
      case INavRoute(children: final pageChildren) when pageChildren.isNotEmpty:
        final Uri nextLocation = switch (pagePath) {
          '/' => uri,
          _ => uri.replace(path: path.replaceFirst(pagePath, ''))
        };

        switch (page) {
          case NavShell(builder: final pageBuilder):
            final List<NavPage<T>> currentPages = [];
            final List<NavPage<T>> currentParentPages = switch (parentPages) {
              null => currentPages,
              _ => parentPages,
            };
            final NavShellBuilder? shellBuilder = switch (page.type) {
              ShellType.factory => pageBuilder,
              _ => null
            };

            final results = _getPages(
              key: key,
              uri: nextLocation,
              observers: observers,
              pages: pageChildren,
              params: params,
              extra: extra,
              parentLocation: currentLocation,
              builder: shellBuilder,
              parentPages: currentParentPages,
            );

            if (results.isEmpty) continue;

            params.addAll(pageParams);

            return [
              page.toPage<T>(
                data: navData(
                  uri: currentUri,
                  pathParams: params,
                  extra: extra,
                ),
                observers: observers,
                pages: results,
                parentPages: currentParentPages,
              ),
              ...currentPages
            ];
          case NavRoute(key: final pageKey, children: final pageChildren):
            final List<NavPage<T>>? currentParentPages;
            final NavShellBuilder? shellBuilder;

            switch (pageKey == key) {
              case true:
                currentParentPages = null;
                shellBuilder = null;
              default:
                currentParentPages = parentPages;
                shellBuilder = builder;
            }

            final results = _getPages<T>(
              key: key,
              uri: nextLocation,
              observers: observers,
              pages: pageChildren,
              params: params,
              extra: extra,
              parentLocation: currentLocation,
              parentPages: currentParentPages,
              builder: shellBuilder,
            );

            if (results.isEmpty &&
                (parentPages == null || parentPages.isEmpty)) {
              continue;
            }

            params.addAll(pageParams);

            final data = navData(
              uri: currentUri,
              pathParams: params,
              extra: extra,
            );

            final result = page.toPage<T>(
              data: data,
              builder: shellBuilder,
            );

            if (parentPages != null && pageKey == key) {
              parentPages.add(result);
              parentPages.addAll(results);

              break;
            }

            return [result, ...results];
        }
      default:
    }
  }

  return [];
}
