import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

showSnackBar(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}

String dateConverter(millisecondsSinceEpoch){
  // Convert milliseconds to DateTime
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

  // Format DateTime to desired format
  String formattedDateTime = DateFormat('MM/dd/yyyy hh:mm:ss a').format(dateTime);
  return formattedDateTime;
}