import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestActivityPermission() async {
    var status = await Permission.activityRecognition.status;
    debugPrint("Before request: $status");

    if (status.isGranted) {
      return true;
    }

    status = await Permission.activityRecognition.request();
    debugPrint("After request: $status");

    if (status.isPermanentlyDenied) {
      debugPrint("Permission permanently denied");
      await openAppSettings();
    }

    return status.isGranted;
  }
}