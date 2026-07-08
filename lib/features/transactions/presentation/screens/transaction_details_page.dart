import 'package:eazywallet/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransactionDetailsPage extends StatelessWidget {
  const TransactionDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text('Transaction details'),
          ),
           TextButton(
            onPressed: () {
              context.push('${AppRoutes.dashboard}${AppRoutes.transactionDetails}${AppRoutes.reportTransaction}');
            },
            child: Text('Go'),
          ),
        ],
      ),
    );
  }
}