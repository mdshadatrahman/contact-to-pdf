import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer show log;

class HomeController with ChangeNotifier {
  Iterable<Contact> contacts = [];

  //Get permission to access contacts
  Future<bool> getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission.isGranted) {
      return true;
    } else if (permission.isDenied) {
      final PermissionStatus permissionStatus = await Permission.contacts.request();
      if (permissionStatus.isGranted) {
        return true;
      } else {
        return false;
      }
    } else if (permission.isPermanentlyDenied) {
      openAppSettings();
      return false;
    } else {
      return false;
    }
  }

  getContacts() async {
    if (await getPermission()) {
      contacts = await ContactsService.getContacts();
      notifyListeners();
    }
  }
}
