import 'package:flutter/material.dart';

class UIUtils {
  static void showCustomPopup(
    BuildContext context, {
    required String title,
    required String message,
    required bool isSuccess,
    VoidCallback? onOkay,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: _buildDialogContent(context, title, message, isSuccess, onOkay),
        );
      },
    );
  }

  static Widget _buildDialogContent(
      BuildContext context, String title, String message, bool isSuccess, VoidCallback? onOkay) {
    Color primaryColor = isSuccess ? const Color(0xFFCD7F32) : const Color(0xFFA0522D); // Deep bronze/copper for error instead of bright red
    IconData icon = isSuccess ? Icons.check_circle_outline : Icons.error_outline;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark background for the popup instead of white
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 60,
            color: primaryColor,
          ),
          const SizedBox(height: 16.0),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24.0),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onOkay != null) {
                    onOkay();
                  }
                },
                child: const Text(
                  'Okay',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
