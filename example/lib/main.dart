import 'package:flutter/material.dart';
import 'package:nav/nav.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final parentKey = GlobalKey<NavigatorState>();

  NavSettings get _nav => nav;

  late final nav = NavSettings(
    key: parentKey,
    initialPath: '/page-one',
    pages: [
      NavPage(
        pattern: '/page-one',
        name: 'Page One',
        builder: () {
          return Scaffold(
            backgroundColor: Colors.blue,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Page One', textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        _nav.navigate(location: '/page-one/page-two'),
                    child: const Text('Go To Page Two'),
                  ),
                ],
              ),
            ),
          );
        },
        children: [
          NavPage(
            pattern: '/page-two',
            name: 'Page Two',
            builder: () => Scaffold(
              backgroundColor: Colors.red,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Page Two', textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () =>
                          _nav.navigate(location: '/shell/page-three'),
                      child: const Text('Go To Page Three With Shell Factory'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () =>
                          _nav.navigate(location: '/shell/page-three'),
                      child: const Text('Go To Page Three With Shell Static'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _nav.navigate(location: '/page-one'),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          NavPage(
            pattern: '/page-two',
            name: 'Page Two',
            builder: () => Scaffold(
              backgroundColor: Colors.red,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Page Two', textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () =>
                          _nav.navigate(location: '/shell/page-three'),
                      child: const Text('Go To Page Three With Shell Factory'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () =>
                          _nav.navigate(location: '/shell/page-three'),
                      child: const Text('Go To Page Three With Shell Static'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _nav.navigate(location: '/page-one'),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      NavShell(
        pattern: '/shell',
        name: 'Shell Type Factory',
        builder: (child) => Scaffold(
          appBar: AppBar(
            title: const Text('Using Shell Type Factory'),
            centerTitle: true,
          ),
          body: Center(
            child: child,
          ),
        ),
        children: [
          NavPage(
            pattern: '/page-three',
            name: 'Page Three With Shell',
            builder: () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Page Three', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () =>
                      _nav.navigate(location: '/shell/page-three/page-four'),
                  child: const Text('Go To Page Four'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () =>
                      _nav.navigate(location: '/page-one/page-two'),
                  child: const Text('Go Back'),
                )
              ],
            ),
            children: [
              NavPage(
                /// removes relation with shell
                key: parentKey,
                pattern: '/page-four',
                name: 'Page Four Without Shell',
                builder: () => Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Page Four', textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => _nav.navigate(
                              location:
                                  '/shell/page-three/nested-shell/page-five'),
                          child: const Text('Go To Page Five'),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () =>
                              _nav.navigate(location: '/shell/page-three'),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              NavShell(
                pattern: '/nested-shell',
                name: 'Nested Shell Type Factory',
                builder: (child) => Scaffold(
                  body: Center(
                    child: child,
                  ),
                  bottomNavigationBar: BottomAppBar(
                    height: 32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Icon(Icons.home),
                        Icon(Icons.person),
                        Icon(Icons.settings),
                      ],
                    ),
                  ),
                ),
                children: [
                  NavPage(
                    pattern: '/page-five',
                    name: 'Page Five With Nested Shell',
                    builder: () => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Page Five', textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => _nav.navigate(
                              location: '/shell/page-three/page-four'),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      NavShell(
        pattern: '/shell-static',
        type: ShellType.static,
        name: 'Shell Type Static',
        builder: (child) => Scaffold(
          appBar: AppBar(
            title: const Text('Using Shell Type Static'),
            centerTitle: true,
          ),
          body: Center(
            child: child,
          ),
        ),
        children: [
          NavPage(
            pattern: '/page-three',
            name: 'Page Three With Shell',
            builder: () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Page Three', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _nav.navigate(
                      location: '/shell-static/page-three/page-four'),
                  child: const Text('Go To Page Four'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () =>
                      _nav.navigate(location: '/page-one/page-two'),
                  child: const Text('Go Back'),
                )
              ],
            ),
            children: [
              NavPage(
                /// removes relation with shell
                key: parentKey,
                pattern: '/page-four',
                name: 'Page Four Without Shell',
                builder: () => Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Page Four', textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => _nav.navigate(
                              location:
                                  '/shell-static/page-three/nested-shell/page-five'),
                          child: const Text('Go To Page Five'),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => _nav.navigate(
                              location: '/shell-static/page-three'),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              NavShell(
                pattern: '/nested-shell',
                type: ShellType.static,
                name: 'Nested Shell Type Static',
                builder: (child) => Scaffold(
                  body: Center(
                    child: child,
                  ),
                  bottomNavigationBar: BottomAppBar(
                    height: 32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Icon(Icons.home),
                        Icon(Icons.person),
                        Icon(Icons.settings),
                      ],
                    ),
                  ),
                ),
                children: [
                  NavPage(
                    pattern: '/page-five',
                    name: 'Page Five With Nested Shell',
                    builder: () => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Page Five', textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => _nav.navigate(
                              location: '/shell-static/page-three/page-four'),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      restorationScopeId: 'app',
      routerConfig: nav,
      title: 'Flutter Demo',
    );
  }
}
