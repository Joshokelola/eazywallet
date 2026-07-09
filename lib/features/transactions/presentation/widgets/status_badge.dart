import 'package:eazywallet/features/transactions/domain/transaction_model.dart';
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final TransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TransactionStatus.successful => Colors.green,
      TransactionStatus.pending => Colors.orange,
      TransactionStatus.failed => Colors.red,
      TransactionStatus.reversed => Colors.red,
      TransactionStatus.unknown => Colors.grey,
    };

    final label = switch (status) {
      TransactionStatus.successful => 'Successful',
      TransactionStatus.pending => 'Pending',
      TransactionStatus.failed => 'Failed',
      TransactionStatus.reversed => 'Reversed',
      TransactionStatus.unknown => 'Unknown',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 9),
      ),
    );
  }
}
