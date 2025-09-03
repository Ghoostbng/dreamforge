import 'package:permission_handler/permission_handler.dart' as ph;

class PermissionService {
  static Future<ph.PermissionStatus> checkPermission(ph.Permission permission) async {
    return await permission.status;
  }

  static Future<ph.PermissionStatus> requestPermission(ph.Permission permission) async {
    return await permission.request();
  }

  static Future<bool> checkAndRequestPermission(ph.Permission permission) async {
    var status = await permission.status;
    
    if (status.isDenied || status.isRestricted) {
      status = await permission.request();
    }
    
    return status.isGranted;
  }

  static Future<bool> hasStoragePermission() async {
    final status = await ph.Permission.storage.status;
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    final status = await ph.Permission.storage.request();
    return status.isGranted;
  }
  
  static Future<bool> hasCameraPermission() async {
    final status = await ph.Permission.camera.status;
    return status.isGranted;
  }

  static Future<bool> requestCameraPermission() async {
    final status = await ph.Permission.camera.request();
    return status.isGranted;
  }
  
  static Future<bool> hasMicrophonePermission() async {
    final status = await ph.Permission.microphone.status;
    return status.isGranted;
  }

  static Future<bool> requestMicrophonePermission() async {
    final status = await ph.Permission.microphone.request();
    return status.isGranted;
  }
  
  static Future<Map<ph.Permission, ph.PermissionStatus>> requestMultiplePermissions() async {
    return await [
      ph.Permission.storage,
      ph.Permission.camera,
      ph.Permission.microphone,
    ].request();
  }

  static Future<bool> checkAllPermissions() async {
    final statuses = await Future.wait([
      ph.Permission.storage.status,
      ph.Permission.camera.status,
      ph.Permission.microphone.status,
    ]);
    
    return statuses.every((status) => status.isGranted);
  }

  static Future<bool> checkAndRequestAllPermissions() async {
    final permissions = [ph.Permission.storage, ph.Permission.camera, ph.Permission.microphone];
    final results = await Future.wait(permissions.map((p) => checkAndRequestPermission(p)));
    return results.every((result) => result);
  }

  static Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }
}