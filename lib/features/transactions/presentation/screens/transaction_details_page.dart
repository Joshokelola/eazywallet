import 'package:eazywallet/core/routing/routes.dart';
import 'package:eazywallet/core/utils/formatter.dart';
import 'package:eazywallet/features/transactions/application/transaction_details_store.dart';
import 'package:eazywallet/features/transactions/data/mock_wallet_repo.dart';
import 'package:eazywallet/features/transactions/domain/wallet_repo.dart';
import 'package:eazywallet/features/transactions/presentation/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

class TransactionDetailsPage extends StatefulWidget {
  const TransactionDetailsPage({super.key, required this.transactionId});

  final String transactionId;

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  final WalletRepository walletRepository = MockWalletRepository();
  late final TransactionDetailsStore store = TransactionDetailsStore(
    walletRepository,
    widget.transactionId,
  );

  @override
  void initState() {
    super.initState();
    store.load();
  }

  Future<void> handleReport() async {
    final reported = await context.push<bool>(
      '${AppRoutes.dashboard}${AppRoutes.transactionDetails}${AppRoutes.reportTransaction}',
      extra: widget.transactionId,
    );

    if (reported == true) {
      store.markReported();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );
      }
    }
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
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
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(store.errorMessage.value!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: store.load, child: const Text('Try again')),
                  ],
                ),
              ),
            );
          }

          final transaction = store.transaction.value;
          if (transaction == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(transaction.title, style: Theme.of(context).textTheme.headlineSmall),
                    ),
                    StatusBadge(status: transaction.status),
                  ],
                ),
                const SizedBox(height: 24),
                detailRow('Reference', transaction.reference),
                detailRow('Amount', formatAmount(transaction.amount)),
                detailRow('Fee', formatAmount(transaction.fee)),
                detailRow('Type', transaction.type.name),
                detailRow('Direction', transaction.direction.name),
                detailRow('Date', formatDate(transaction.date)),
                detailRow('Description', transaction.description),
                detailRow('Report Status', transaction.hasActiveReport ? 'Reported' : 'Not reported'),
                const SizedBox(height: 32),
                if (store.canReport.value)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: handleReport,
                      child: const Text('Report Transaction'),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(store.ineligibleReason.value ?? ''),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
