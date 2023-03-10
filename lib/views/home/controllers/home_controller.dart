import 'dart:io';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:open_file_safe_plus/open_file_safe_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:developer' as developer show log;

class HomeController with ChangeNotifier {
  Iterable<Contact> contacts = [];
  var pdf = pw.Document();
  bool isLoading = false;

  //Get permission to access contacts
  Future<bool> getPermission() async {
    isLoading = true;
    notifyListeners();
    final PermissionStatus contactPermission = await Permission.contacts.status;
    final PermissionStatus storagePermission = await Permission.storage.status;
    final PermissionStatus manageExternalStoragePermission = await Permission.manageExternalStorage.status;
    if (contactPermission.isGranted && storagePermission.isGranted && manageExternalStoragePermission.isGranted) {
      return true;
    } else if (contactPermission.isDenied && storagePermission.isDenied && manageExternalStoragePermission.isDenied) {
      final PermissionStatus contactPermission = await Permission.contacts.request();
      final PermissionStatus storagePermission = await Permission.storage.request();
      final PermissionStatus manageExternalStoragePermission = await Permission.manageExternalStorage.request();
      if (contactPermission.isGranted && storagePermission.isGranted && manageExternalStoragePermission.isGranted) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        isLoading = false;
        notifyListeners();
        return false;
      }
    } else if (contactPermission.isPermanentlyDenied &&
        storagePermission.isPermanentlyDenied &&
        manageExternalStoragePermission.isPermanentlyDenied) {
      isLoading = false;
      notifyListeners();
      openAppSettings();
      return false;
    } else {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  getContacts() async {
    isLoading = true;
    notifyListeners();
    if (await getPermission()) {
      contacts = await ContactsService.getContacts();
      isLoading = false;
      notifyListeners();
    }
  }

  writeOnPdf() async {
    isLoading = true;
    notifyListeners();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text("Hello World"),
          ); // Center
        },
      ),
    );

    notifyListeners();
    isLoading = false;
    notifyListeners();
  }

  savePdf() async {
    isLoading = true;
    notifyListeners();
    pdf = pw.Document();
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final permission = await getPermission();

      if (permission) {
        final dir = await path_provider.getApplicationDocumentsDirectory();
        final file = File('${dir.path}/contacts.pdf');
        await file.writeAsBytes(await pdf.save()).then((value) {
          developer.log(value.path);
          openPdf();
        });
      }
    } catch (e) {
      developer.log(e.toString());
    }
    isLoading = false;
    notifyListeners();
  }

  openPdf() async {
    isLoading = true;
    notifyListeners();
    try {
      final dir = await path_provider.getApplicationDocumentsDirectory();
      await OpenFilePlus.open("${dir.path}/contacts.pdf").then((value) {
        developer.log(value.message);
        developer.log(value.type.toString());
      });
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      developer.log(e.toString());
    }
    isLoading = false;
    notifyListeners();
  }

  generatePdf() async {
    isLoading = true;
    notifyListeners();
    pdf = pw.Document();
    await Future.delayed(const Duration(milliseconds: 600));

    await getContacts();
    await writeOnPdf();
    await savePdf();
    isLoading = false;
    notifyListeners();
  }
}
