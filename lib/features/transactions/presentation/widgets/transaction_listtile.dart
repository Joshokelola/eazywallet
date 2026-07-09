import 'package:eazywallet/core/utils/formatter.dart';
import 'package:eazywallet/features/transactions/domain/transaction_model.dart';
import 'package:eazywallet/features/transactions/presentation/widgets/status_badge.dart';
import 'package:flutter/material.dart';

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({super.key, required this.transaction, required this.onTap});

  final TransactionModel transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.direction == TransactionDirection.credit;
    final amountColor = isCredit ? Colors.green : Colors.red;
    final amountPrefix = isCredit ? '+' : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        title: Text(transaction.title),
        subtitle: Text('${formatDate(transaction.date)} · ${transaction.reference}'),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$amountPrefix${formatAmount(transaction.amount)}',
              style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            StatusBadge(status: transaction.status),
          ],
        ),
      ),
    );
  }
}
