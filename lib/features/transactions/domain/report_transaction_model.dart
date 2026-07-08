class ReportTransactionModel {
  final String id;
  final String transactionId;
  final ReportReason reason;
  final String description;
  final DateTime createdAt;

  const ReportTransactionModel({
    required this.id,
    required this.transactionId,
    required this.reason,
    required this.description,
    required this.createdAt,
  });
}

enum ReportReason {
  erroneousTransfer,
  suspectedFraud,
  wrongAmount,
  duplicateTransaction,
  other;

  String get label {
    switch (this) {
      case ReportReason.erroneousTransfer:
        return 'Erroneous transfer';
      case ReportReason.suspectedFraud:
        return 'Suspected fraud';
      case ReportReason.wrongAmount:
        return 'Wrong amount';
      case ReportReason.duplicateTransaction:
        return 'Duplicate transaction';
      case ReportReason.other:
        return 'Other';
    }
  }
}
