import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../models/boundary.dart';
import 'real_time_viewmodel.dart';

class RealTimeView extends StackedView<RealTimeViewModel> {
  const RealTimeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    RealTimeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const TextField(
          decoration: InputDecoration(
              hintText: 'search', prefixIcon: Icon(Icons.search)),
        ),
      ),
      body: viewModel.node!=null && viewModel.boundary !=null ?  GoogleMap(
        onMapCreated: (controller) {},
        onTap: (LatLng location) {},
        initialCameraPosition: CameraPosition(
          target:
          LatLng(viewModel.node!.lat, viewModel.node!.long),
          // Default map position
          zoom: 15.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("picked_location"),
            position:
            LatLng(viewModel.node!.lat, viewModel.node!.long),
            infoWindow: const InfoWindow(
              title: "Current location",
            ),
          ),
        },
        circles: {
          Circle(
            circleId: const CircleId('bound'),
            center: LatLng(viewModel.boundary!.currentLat, viewModel.boundary!.currentLong),
            radius: viewModel.boundary!.boundaryMeters,
            fillColor: const Color.fromRGBO(0, 0, 255, 0.2),
            strokeWidth: 2,
            strokeColor: Colors.blue,
          )
        },

      ) : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Recent',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // Add onTap functionality for "Add" here
          if(viewModel.node!=null) {
            showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return BoundaryInputBottomSheet(
                            onSubmit: (Boundary boundary) {
                              // Handle the submitted boundary object here
                              viewModel.updateBoundary(boundary);
                              // You can do anything with the boundary object, such as sending it to Firestore
                            }, latlng: LatLng(viewModel.node!.lat, viewModel.node!.long),
                          );
                        },
                      );
          }



          } else if (index == 1) {
            // Add onTap functionality for "Recent" here
            // For now, just print a message
            print('Recent tapped');
          }
        },
        // Add additional properties as needed
      ),
    );
  }

  @override
  RealTimeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      RealTimeViewModel();
}



class BoundaryInputBottomSheet extends StatefulWidget {
  final LatLng latlng;
  final Function(Boundary boundary) onSubmit;

  const BoundaryInputBottomSheet({Key? key, required this.onSubmit, required this.latlng}) : super(key: key);

  @override
  _BoundaryInputBottomSheetState createState() => _BoundaryInputBottomSheetState();
}

class _BoundaryInputBottomSheetState extends State<BoundaryInputBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _kilometerController;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _kilometerController = TextEditingController();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(Duration(days: 7));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _kilometerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _kilometerController,
            decoration: const InputDecoration(labelText: 'Boundary radius in meters'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          ListTile(
            title: Text('Start Date & Time'),
            subtitle: Text('${_startDate.toString()}'),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime.now(),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    _startDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                  });
                }
              }
            },
          ),
          ListTile(
            title: Text('End Date & Time'),
            subtitle: Text('${_endDate.toString()}'),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _endDate,
                firstDate: DateTime.now(),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    _endDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                  });
                }
              }
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              String name = _nameController.text.trim();
              double boundaryMeters = double.tryParse(_kilometerController.text) ?? 0.0;
              if (name.isNotEmpty && boundaryMeters > 0) {


                // Navigate to the MapSelectionPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapSelectionPage(
                      initialLatitude: widget.latlng.latitude, // Initial latitude
                      initialLongitude: widget.latlng.longitude, // Initial longitude
                      boundaryRadius: boundaryMeters, // Boundary radius in meters
                    ),
                  ),
                ).then((selectedLocation) {
                  // Handle returned data
                  if (selectedLocation != null) {
                    // Do something with the selectedLocation
                    print('Selected Location: $selectedLocation');


                  widget.onSubmit(Boundary(
                    id: 'boundary',
                    name: name,
                    startDateTime: _startDate,
                    endDateTime: _endDate,
                    boundaryMeters: boundaryMeters,
                    currentLat: selectedLocation.latitude,
                    currentLong: selectedLocation.longitude,
                  ));
                  Navigator.of(context).pop();
                }
                });



              } else {
                // Show error message or handle invalid input
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}


class MapSelectionPage extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final double boundaryRadius;

  MapSelectionPage({
    required this.initialLatitude,
    required this.initialLongitude,
    required this.boundaryRadius,
  });

  @override
  _MapSelectionPageState createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  late GoogleMapController mapController;
  late LatLng selectedLocation;

  Set<Marker> markers = {};
  Set<Circle> circles = {};

  @override
  void initState() {
    super.initState();
    selectedLocation = LatLng(widget.initialLatitude, widget.initialLongitude);
    _addMarker(selectedLocation);
    _addCircle(selectedLocation);
  }

  void _addMarker(LatLng position) {
    final markerId = MarkerId('selected_location');
    final marker = Marker(
      markerId: markerId,
      position: position,
      icon: BitmapDescriptor.defaultMarker,
    );

    setState(() {
      markers.add(marker);
    });
  }

  void _addCircle(LatLng center) {
    final circleId = CircleId('boundary_circle');
    final circle = Circle(
      circleId: circleId,
      center: center,
      radius: widget.boundaryRadius,
      fillColor: Color.fromRGBO(255, 0, 0, 0.2),
      strokeWidth: 2,
      strokeColor: Colors.red,
    );

    setState(() {
      circles.add(circle);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.initialLatitude, widget.initialLongitude),
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            onTap: (LatLng latLng) {
              setState(() {
                selectedLocation = latLng;
                markers.clear();
                circles.clear();
                _addMarker(selectedLocation);
                _addCircle(selectedLocation);
              });
            },
            markers: markers,
            circles: circles,
          ),

          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Location:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Latitude: ${selectedLocation.latitude}'),
                  Text('Longitude: ${selectedLocation.longitude}'),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(selectedLocation);
              },
              child: Text('Save'),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Boundary Radius:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${widget.boundaryRadius} meters'),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              width: 200,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Tap on the map to select a location.'),
                  Text('Tap "Save" to return the selected location.'),
                ],
              ),
            ),
          ),

          // Add other widgets as needed
        ],
      ),
    );
  }
}
