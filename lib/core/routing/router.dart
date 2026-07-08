import 'package:eazywallet/core/routing/routes.dart';
import 'package:eazywallet/features/home/presentation/screens/dashboard_page.dart';
import 'package:eazywallet/features/transactions/presentation/screens/transaction_details_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.dashboard,
  routes: [
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) {
        return DashboardPage();
      },
      routes: [
        GoRoute(
          path: AppRoutes.transactionDetails,
          builder: (context, state) {
            return TransactionDetailsPage();
          },
        ),
      ],
    ),
  ],
);
