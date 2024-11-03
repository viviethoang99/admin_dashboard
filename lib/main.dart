import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

import 'services/routes.dart';
import 'services/storage/secure_storage.dart';
import 'utils/provider_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Highlighter.initialize(['dart']);

  runApp(ProviderScope(
    observers: [AppProviderObserver()],
    child: const MyApp(),
  ));
}

class _EagerInitialization extends ConsumerWidget {
  const _EagerInitialization({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final values = [
      ref.watch(secureStorageProvider),
    ];

    if (values.every((value) => value.hasValue)) {
      return child;
    }

    return const SizedBox();
  }
}

class MyApp extends StatefulHookConsumerWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return _EagerInitialization(
      child: MaterialApp.router(
        title: 'Irohasu Admin',
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        routerConfig: router,
      ),
    );
  }
}
