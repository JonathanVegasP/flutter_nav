import 'package:flutter/material.dart';

class WebTransitionDelegate extends TransitionDelegate<dynamic> {
  const WebTransitionDelegate();

  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord>
        locationToExitingPageRoute,
    required Map<RouteTransitionRecord?, List<RouteTransitionRecord>>
        pageRouteToPagelessRoutes,
  }) {
    final List<RouteTransitionRecord> results = <RouteTransitionRecord>[];

    void handleExitingRoute(RouteTransitionRecord? location) {
      final exitingPageRoute = locationToExitingPageRoute[location];

      if (exitingPageRoute == null) return;

      if (exitingPageRoute.isWaitingForExitingDecision) {
        final pagelessRoutes = pageRouteToPagelessRoutes[exitingPageRoute];

        exitingPageRoute.markForComplete(exitingPageRoute.route.currentResult);

        if (pagelessRoutes != null) {
          for (final RouteTransitionRecord pagelessRoute in pagelessRoutes) {
            if (pagelessRoute.isWaitingForExitingDecision) {
              pagelessRoute.markForComplete(pagelessRoute.route.currentResult);
            }
          }
        }
      }

      results.add(exitingPageRoute);

      handleExitingRoute(exitingPageRoute);
    }

    handleExitingRoute(null);

    for (final pageRoute in newPageRouteHistory) {
      if (pageRoute.isWaitingForEnteringDecision) {
        pageRoute.markForAdd();
      }
      results.add(pageRoute);

      handleExitingRoute(pageRoute);
    }
    return results;
  }
}
