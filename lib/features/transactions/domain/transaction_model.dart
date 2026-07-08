import 'dart:convert';

class TransactionModel {
  final String id;
  final String reference;
  final String title;
  final double amount;
  final double fee;
  final TransactionType type;
  final TransactionStatus status;
  final TransactionDirection direction;
  final String description;
  final DateTime date;
  final bool hasActiveReport;

  TransactionModel({
    required this.id,
    required this.reference,
    required this.title,
    required this.amount,
    required this.fee,
    required this.type,
    required this.status,
    required this.direction,
    required this.description,
    required this.date,
    required this.hasActiveReport,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reference': reference,
      'title': title,
      'amount': amount,
      'fee': fee,
      'type': type.name,
      'status': status.name,
      'direction': direction.name,
      'description': description,
      'date': date.toIso8601String(),
      'has_active_report': hasActiveReport,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      reference: map['reference'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      fee: (map['fee'] as num?)?.toDouble() ?? 0.0,
      type: TransactionType.fromString(map['type'] ?? ''),
      status: TransactionStatus.fromString(map['status'] ?? ''),
      direction: TransactionDirection.fromString(map['direction'] ?? ''),
      description: map['description'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(), 
      hasActiveReport: map['has_active_report'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionModel.fromJson(String source) => 
      TransactionModel.fromMap(json.decode(source));
}


enum TransactionType { 
  walletFunding, 
  withdrawal, 
  giftCardTrade, 
  cryptoTrade,
  unknown;

  static TransactionType fromString(String value) {
    switch (value) {
      case 'wallet_funding': return TransactionType.walletFunding;
      case 'withdrawal': return TransactionType.withdrawal;
      case 'gift_card_trade': return TransactionType.giftCardTrade;
      case 'crypto_trade': return TransactionType.cryptoTrade;
      default: return TransactionType.unknown;
    }
  }
}

enum TransactionStatus { 
  successful, 
  pending, 
  failed,
  unknown;

  static TransactionStatus fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.name == value, 
      orElse: () => TransactionStatus.unknown,
    );
  }
}

enum TransactionDirection { 
  debit, 
  credit,
  unknown;

  static TransactionDirection fromString(String value) {
    return TransactionDirection.values.firstWhere(
      (e) => e.name == value, 
      orElse: () => TransactionDirection.unknown,
    );
  }
}