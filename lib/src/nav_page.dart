import 'package:flutter/material.dart';

import 'nav_data.dart';

typedef NestedNavPage<T> = ({
  List<GlobalKey<NavigatorState>> navigatorKeys,
  List<NavPage<T>> pages,
});

class NavPage<T> extends Page<T> {
  const NavPage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.allowSnapshotting = true,
    super.arguments,
    super.key,
    super.name,
    super.restorationId,
  });

  final Widget child;

  final bool maintainState;

  final bool fullscreenDialog;

  final bool allowSnapshotting;

  @override
  NavData get arguments => super.arguments as NavData;

  @override
  Route<T> createRoute([BuildContext? context]) {
    return _NavPageRoute<T>(page: this, allowSnapshotting: allowSnapshotting);
  }
}

class _NavPageRoute<T> extends PageRoute<T> {
  _NavPageRoute({
    required NavPage page,
    super.allowSnapshotting,
  }) : super(settings: page) {
    assert(opaque);
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return (nextRoute is _NavPageRoute && !nextRoute.fullscreenDialog);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget result = _page.child;
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final PageTransitionsTheme theme = Theme.of(context).pageTransitionsTheme;
    return theme.buildTransitions<void>(
      this,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }

  NavPage get _page => settings as NavPage;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}
