import 'package:flutter/widgets.dart';

import 'utils/match.dart';
import 'utils/path.dart';

abstract class Nav {
  final GlobalKey<NavigatorState>? key;
  final String pattern;
  final String? name;
  final List<Nav> children;
  final _params = <String>[];
  late final RegExp _regexp;

  Nav({
    this.key,
    required this.pattern,
    this.name,
    this.children = const <Nav>[],
  })  : assert(pattern == '/' ||
            (pattern.startsWith('/') && !pattern.endsWith('/'))),
        assert(
            children
                        .where((element) => element.name != null)
                        .map((e) => e.name)
                        .toList()
                        .length ==
                    children
                        .where((element) => element.name != null)
                        .map((e) => e.name)
                        .toSet()
                        .length &&
                children.map((e) => e.pattern).toList().length ==
                    children.map((e) => e.pattern).toSet().length,
            'Cannot create pages on Nav.children where pattern == $pattern with the same pattern or name') {
    _regexp = pattern.toRegExp(_params);
  }
}

extension NavMethods<T extends Nav> on T {
  Map<String, String>? hasMatch(String location) {
    final match = _regexp.matchAsPrefix(location);

    if (match == null) return null;

    return match.toParams(_params);
  }

  String getRawPath(Map<String, String> params) => pattern.toPath(params);
}
