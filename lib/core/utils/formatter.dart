String formatAmount(double amount) {
  final isNegative = amount < 0;
  final value = amount.abs();
  final wholePart = value.truncate();
  final decimalPart = ((value - wholePart) * 100).round().toString().padLeft(2, '0');
  final wholeString = wholePart.toString();
  final buffer = StringBuffer();

  for (var i = 0; i < wholeString.length; i++) {
    if (i > 0 && (wholeString.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(wholeString[i]);
  }

  return '${isNegative ? '-' : ''}₦$buffer.$decimalPart';
}

String formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final local = date.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '${months[local.month - 1]} ${local.day}, ${local.year} · $hour:$minute $period';
}
