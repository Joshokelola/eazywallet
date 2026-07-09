import 'package:eazywallet/core/routing/routes.dart';
import 'package:eazywallet/core/utils/formatter.dart';
import 'package:eazywallet/features/home/application/dashboard_store.dart';
import 'package:eazywallet/features/transactions/data/mock_wallet_repo.dart';
import 'package:eazywallet/features/transactions/domain/wallet_repo.dart';
import 'package:eazywallet/features/transactions/presentation/widgets/transaction_listtile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final WalletRepository walletRepository = MockWalletRepository();
  late final DashboardStore store = DashboardStore(walletRepository);

  @override
  void initState() {
    super.initState();
    store.load();
  }

  Future<void> openTransaction(String transactionId) async {
    await context.push(
      '${AppRoutes.dashboard}${AppRoutes.transactionDetails}',
      extra: transactionId,
    );
    store.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EazyWallet'),
        actions: [
          IconButton(onPressed: store.refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Observer(
        builder: (context) {
          if (store.isLoading.value && store.user.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (store.errorMessage.value != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(store.errorMessage.value!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: store.refresh, child: const Text('Try again')),
                  ],
                ),
              ),
            );
          }

          final user = store.user.value;

          return RefreshIndicator(
            onRefresh: store.refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (user != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back,', style: Theme.of(context).textTheme.bodyMedium),
                          Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 16),
                          Text('Wallet Balance', style: Theme.of(context).textTheme.bodySmall),
                          Text(
                            formatAmount(user.walletBalance),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Chip(label: Text(user.kycLevel)),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Text('Recent Transactions', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                if (store.isEmpty.value)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: Text('No transactions yet')),
                  )
                else
                  ...store.transactions.map(
                    (transaction) => TransactionListTile(
                      transaction: transaction,
                      onTap: () => openTransaction(transaction.id),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
