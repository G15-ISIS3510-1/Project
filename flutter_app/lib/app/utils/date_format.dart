String formatDateTime(DateTime dt) {
  final months = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];

  final day = dt.day.toString().padLeft(2, '0');
  final month = months[dt.month - 1];
  final year = dt.year;
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');

  return '$day $month $year, $hour:$minute';
}
