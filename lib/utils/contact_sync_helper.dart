import 'package:flutter_contacts/flutter_contacts.dart';

import '../api/profile_api.dart';

class ContactSyncHelper {
  ContactSyncHelper._();

  static Future<void> syncPhoneContacts() async {
    final status = await FlutterContacts.permissions.request(
      PermissionType.read,
    );

    if (status != PermissionStatus.granted) {
      return;
    }

    final contacts = await FlutterContacts.getAll(
      properties: ContactProperties.all,
    );

    final phoneNumbers = contacts
        .expand((contact) => contact.phones)
        .map((phone) => phone.number)
        .where((number) => number.trim().isNotEmpty)
        .map(_cleanPhoneNumber)
        .where((number) => number.length == 11)
        .toSet()
        .toList();

    if (phoneNumbers.isEmpty) {
      return;
    }

    await ProfileApi.syncContacts(phoneNumbers);
  }

  static String _cleanPhoneNumber(String number) {
    var value = number.replaceAll(RegExp(r'[^0-9+]'), '');

    if (value.startsWith('+92')) {
      value = '0${value.substring(3)}';
    } else if (value.startsWith('92') && value.length == 12) {
      value = '0${value.substring(2)}';
    } else if (value.length == 10 && value.startsWith('3')) {
      value = '0$value';
    }

    return value;
  }
}
