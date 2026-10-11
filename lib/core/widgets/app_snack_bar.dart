import 'package:flutter/material.dart';

import '../theme.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = true,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppTheme.error : AppTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
}
