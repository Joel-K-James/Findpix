import 'package:findpix_flutter/models/boundary.dart';
import 'package:findpix_flutter/services/firestore_service.dart';
import 'package:stacked/stacked.dart';

import '../../../app/app.locator.dart';
import '../../../models/device.dart';
import '../../../services/database_service.dart';

class RealTimeViewModel extends ReactiveViewModel {

  final _databaseService = locator<DatabaseService>();
  final _firestoreServce = locator<FirestoreService>();

  DeviceReading? get node => _databaseService.node;
  Boundary? get boundary => _firestoreServce.boundary;

  @override
  List<ListenableServiceMixin> get listenableServices =>
      [_databaseService, _firestoreServce];

 void updateBoundary(Boundary boundaryin){
   _firestoreServce.addBoundaryToFirestore(boundaryin);
 }
}
