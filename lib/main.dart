import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'application/providers/auth_provider.dart';
import 'domain/models/onu_model.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/onu_list_screen.dart';
import 'presentation/screens/onu_form_screen.dart';
import 'presentation/screens/admin_panel_screen.dart';
import 'presentation/screens/catalog_management_screen.dart';
import 'presentation/screens/logs_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase Initialization Error: $e');
  }

  // Normalización única de localidades (idempotente) - ya ejecutada, marcador eliminado

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _authRefresh = ValueNotifier<bool?>(null);

  late final _router = GoRouter(
    refreshListenable: _authRefresh,
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = _authRefresh.value;
      final isLogin = state.matchedLocation == '/';

      if (loggedIn == false && !isLogin) return '/';
      if (loggedIn == true && isLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/onus',
        builder: (context, state) => const OnuListScreen(),
      ),
      GoRoute(
        path: '/onu/new',
        builder: (context, state) => const OnuFormScreen(),
      ),
      GoRoute(
        path: '/onu/edit/:id',
        builder: (context, state) {
          final onu = state.extra as OnuModel?;
          return OnuFormScreen(onu: onu);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminPanelScreen(),
      ),
      GoRoute(
        path: '/admin/catalogs',
        builder: (context, state) => const CatalogManagementScreen(),
      ),
      GoRoute(
        path: '/admin/logs',
        builder: (context, state) => const LogsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    ref.listen(currentUserProvider, (prev, next) {
      final oldVal = prev?.value != null;
      final newVal = next.value != null;
      if (oldVal != newVal) {
        _authRefresh.value = newVal;
      }
    });

    return MaterialApp.router(
      title: 'Registro de ONTs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      routerConfig: _router,
    );
  }
}
