import 'package:e_commerce_app/core/network/notification_service.dart';
import 'package:e_commerce_app/features/admin/data/repositories/category_repository.dart';
import 'package:e_commerce_app/features/admin/data/repositories/product_repository.dart'
    as admin_repo;
import 'package:e_commerce_app/features/admin/data/repositories/user_repository.dart';
import 'package:e_commerce_app/features/admin/presentation/bloc/admin_category_bloc.dart';
import 'package:e_commerce_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:e_commerce_app/features/auth/data/repositories/user_repository.dart';
import 'package:e_commerce_app/features/home/presentation/screens/cart_screen.dart';
import 'package:e_commerce_app/features/home/presentation/screens/notification_screen.dart';
import 'package:e_commerce_app/features/home/presentation/screens/wishlist_screen.dart';
import 'package:e_commerce_app/features/notification/data/notification_repository.dart';
import 'package:e_commerce_app/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:e_commerce_app/features/notification/presentation/bloc/notification_event.dart';
import 'package:e_commerce_app/features/order/presentation/screens/order_history_screen.dart';
import 'package:e_commerce_app/features/product/presentation/bloc/product_detail_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/network/dio_client.dart';
import 'core/constants/api_constants.dart';

import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';

import 'features/product/data/repositories/product_repository.dart'
    as user_repo;
import 'features/product/presentation/bloc/product_bloc.dart';

import 'features/cart/data/repositories/cart_repository.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';

import 'features/wishlist/data/repositories/wishlist_repository.dart';
import 'features/wishlist/presentation/bloc/wishlist_bloc.dart';

import 'features/order/data/repositories/order_repository.dart';
import 'features/order/presentation/bloc/order_bloc.dart';

import 'features/settings/presentation/bloc/theme_bloc.dart';
import 'features/settings/presentation/bloc/theme_event.dart';
import 'features/settings/presentation/bloc/theme_state.dart';

import 'features/admin/presentation/bloc/admin_bloc.dart';
import 'features/admin/data/repositories/order_repository.dart';
import 'features/admin/presentation/screens/admin_login_screen.dart';

import 'features/home/presentation/screens/main_screen.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final prefs = await SharedPreferences.getInstance();
  final dioClient = DioClient(prefs);

  FlutterNativeSplash.remove();

  runApp(ECommerceApp(prefs: prefs, dioClient: dioClient));
}

class ECommerceApp extends StatefulWidget {
  final SharedPreferences prefs;
  final DioClient dioClient;

  const ECommerceApp({
    super.key,
    required this.prefs,
    required this.dioClient,
  });

  @override
  State<ECommerceApp> createState() => _ECommerceAppState();
}

class _ECommerceAppState extends State<ECommerceApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.init(navigatorKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- REPOSITORIES INITIALIZATION ---
    final authRepository = AuthRepository(widget.dioClient, widget.prefs);
    final userRepository = UserRepository(widget.dioClient);
    final adminUserRepository =
        AdminUserRepository(widget.dioClient); // ✅ Added
    final categoryRepository = AdminCategoryRepository(widget.dioClient);
    final productRepository = user_repo.ProductRepository(widget.dioClient);
    final adminProductRepository =
        admin_repo.AdminProductRepository(widget.dioClient);
    final adminOrderRepository = AdminOrderRepository(widget.dioClient);
    final cartRepository = CartRepository(widget.dioClient);
    final wishlistRepository = WishlistRepository(widget.dioClient);
    final orderRepository = OrderRepository(widget.dioClient);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(create: (_) => userRepository),
        RepositoryProvider<AdminUserRepository>(
            create: (_) => adminUserRepository), // ✅ Added
        RepositoryProvider<user_repo.ProductRepository>(
            create: (_) => productRepository),
        RepositoryProvider<OrderRepository>(create: (_) => orderRepository),
        RepositoryProvider<AdminCategoryRepository>(
            create: (_) => categoryRepository), // ✅ Added
      ],
      child: MultiBlocProvider(
        providers: [
          // ✅ Theme & Auth
          BlocProvider(
              create: (_) =>
                  ThemeBloc(widget.prefs)..add(ThemeLoadRequested())),
          BlocProvider(
              create: (_) =>
                  AuthBloc(authRepository)..add(AuthCheckRequested())),

          // ✅ Notifications
          BlocProvider(
            create: (_) =>
                NotificationBloc(NotificationRepository(widget.dioClient)),
          ),

          // ✅ User Side Features
          BlocProvider(create: (_) => ProductBloc(productRepository)),
          BlocProvider(create: (_) => CartBloc(cartRepository)),
          BlocProvider(create: (_) => WishlistBloc(wishlistRepository)),
          BlocProvider(create: (_) => OrderBloc(orderRepository)),

          // ✅ Admin Side Features (Modular)
          // 1. AdminCategoryBloc: Ab saara category ka load ispe hai
          BlocProvider(
            create: (_) => AdminCategoryBloc(repository: categoryRepository),
          ),

          // 2. AdminBloc: Ab ye Login, Users aur Dashboard handle karega
          BlocProvider(
            create: (_) => AdminBloc(
              adminUserRepository,
              adminProductRepository,
              widget.dioClient,
              widget.prefs,
              orderRepository: adminOrderRepository,
            ),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            final isDark = themeState.isDarkMode;

            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'E-Commerce Admin',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              routes: {
                '/login': (_) => const LoginScreen(),
                '/register': (_) => const RegisterScreen(),
                '/admin': (_) => const AdminLoginScreen(),
                '/notifications': (_) => const NotificationScreen(),
                '/orders': (_) => const OrderHistoryScreen(),
                '/cart': (_) => const CartScreen(),
                '/wishlist': (_) => const WishlistScreen(),
                // Yahan aap AdminUserScreen ka route bhi add kar sakte hain
              },
              home: BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthAuthenticated) {
                    context.read<NotificationBloc>().add(LoadNotifications());
                    NotificationService.saveFcmToken(widget.dioClient);
                    NotificationService.consumePendingMessage();
                  }
                },
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthInitial || state is AuthLoading) {
                      return const Scaffold(
                          body: Center(child: CircularProgressIndicator()));
                    }
                    if (state is AuthAuthenticated) {
                      return state.role == 'admin'
                          ? const AdminDashboardScreen()
                          : const MainScreen();
                    }
                    return const LoginScreen();
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
