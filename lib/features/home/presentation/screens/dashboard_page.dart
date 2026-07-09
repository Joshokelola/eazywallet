import 'package:eazywallet/core/routing/routes.dart';
import 'package:eazywallet/core/utils/formatter.dart';
import 'package:eazywallet/core/services/wallet_repository_provider.dart';
import 'package:eazywallet/features/home/application/dashboard_store.dart';
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
  final WalletRepository walletRepository = sharedWalletRepository;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('EazyWallet')),
      body: Observer(
        builder: (context) {
          if (store.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (store.errorMessage.value != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      store.errorMessage.value!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: store.refresh,
                      child: const Text('Try again'),
                    ),
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
                    elevation: 0,
                    color: colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          Text(
                            user.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Wallet Balance',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          Text(
                            formatAmount(user.walletBalance),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Theme(
                            data: theme.copyWith(
                              canvasColor: Colors.transparent,
                            ),
                            child: RawChip(
                              label: Text(user.kycLevel),
                              labelStyle: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: colorScheme.secondaryContainer,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  'Recent Transactions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
