import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../app/app.locator.dart';
import '../../../models/device.dart';
import '../../../services/database_service.dart';
import '../../../services/firestore_service.dart';

class ChildActivityViewModel  extends ReactiveViewModel {

final _databaseService = locator<DatabaseService>();
final _firestoreServce = locator<FirestoreService>();

DeviceReading? get node => _databaseService.node;

@override
List<ListenableServiceMixin> get listenableServices =>
    [_databaseService];

String get childActivity => _databaseService.childActivity;


  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      _selectedDate = picked;
      notifyListeners();
    }
  }
}
