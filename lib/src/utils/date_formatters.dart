import 'package:intl/intl.dart';

final _dateFormatter = DateFormat('EEE, MMM d');
final _dateTimeFormatter = DateFormat('EEE, MMM d • h:mm a');

String formatDate(DateTime date) => _dateFormatter.format(date);
String formatDateTime(DateTime date) => _dateTimeFormatter.format(date);
