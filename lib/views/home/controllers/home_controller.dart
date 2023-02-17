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

  writeOnPdf() {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        orientation: pw.PageOrientation.portrait,
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text('Contact to PDF'),
                ],
              ),
            ),
            pw.Paragraph(
              text: 'This is a simple PDF file generated using the contact_to_pdf package.',
            ),
            // pw.Table.fromTextArray(
            //   context: context,
            //   data: <List<String>>[
            //     <String>['Name', 'Phone Number'],
            //     ...contacts.map(
            //       (contact) => <String>[
            //         for (final contact in contacts) contact.displayName ?? '',
            //       ],
            //     ),
            //   ],
            // ),
          ];
        },
      ),
    );
  }

  savePdf() async {
    try {
      final permission = await getPermission();
      if (permission) {
        final dir = await path_provider.getApplicationDocumentsDirectory();
        final file = File('${dir.path}/contacts.pdf');

        await file.writeAsBytes(await pdf.save()).then((value) {
          developer.log('PDF saved at ${value.path}');
          openPdf();
        });
      }
    } catch (e) {
      developer.log(e.toString());
    }
  }

  openPdf() async {
    try {
      final dir = await path_provider.getApplicationDocumentsDirectory();
      await OpenFilePlus.open("${dir.path}/contacts.pdf");
    } catch (e) {
      developer.log(e.toString());
    }
  }

  generatePdf() async {
    pdf = pw.Document();
    await getContacts();
    await writeOnPdf();
    await savePdf();
  }
}
