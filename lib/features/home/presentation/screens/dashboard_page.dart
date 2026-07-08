import 'package:eazywallet/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text('Dashboard')),
          TextButton(
            onPressed: () {
              context.push('${AppRoutes.dashboard}${AppRoutes.transactionDetails}');
            },
            child: Text('Go'),
          ),
        ],
      ),
    );
  }
}
