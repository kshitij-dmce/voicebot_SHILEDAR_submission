import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_theme.dart';

class ErrorHandler {
  // Show a snackbar with an error message
  static void showSnackbar(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    // Close any open snackbars
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: isDark ? Colors.white70 : AppTheme.errorColor,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      elevation: 4,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      duration: duration,
      action: action,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  // Show a dialog with an error message
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String buttonText = 'OK',
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              buttonText,
              style: TextStyle(
                color: isDark ? AppTheme.accentColor : AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Log errors to your analytics service
  static void logError(dynamic error, {StackTrace? stackTrace}) {
    debugPrint('ERROR: $error');
    if (stackTrace != null) {
      debugPrint('STACK TRACE: $stackTrace');
    }
    
    // TODO: Implement logging to your analytics service
  }
  
  // Handle specific API errors
  static void handleApiError(BuildContext context, dynamic error) {
    String errorMessage = 'Something went wrong. Please try again.';
    
    if (error.toString().contains('connection')) {
      errorMessage = AppConstants.networkErrorMessage;
    } else if (error.toString().contains('timeout')) {
      errorMessage = 'Request timed out. Please try again.';
    }
    
    showSnackbar(
      context, 
      errorMessage,
      icon: Icons.error_outline_rounded,
    );
    
    logError(error);
  }
}

// Constants used by ErrorHandler
class AppConstants {
  static const String networkErrorMessage = 'Unable to connect. Please check your internet connection and try again.';
}