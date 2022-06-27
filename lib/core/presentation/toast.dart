import 'package:flash/flash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> showNoConnectionToast(String message, BuildContext context) async {
  await showFlash(
      context: context,
      duration: const Duration(seconds: 4),
      builder: (context, controller) {
        return Flash.dialog(
          margin: const EdgeInsets.all(8.0),
            borderRadius: BorderRadius.circular(8),
            controller: controller,
            backgroundColor: Colors.black.withOpacity(0.7),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ));
      });
}
