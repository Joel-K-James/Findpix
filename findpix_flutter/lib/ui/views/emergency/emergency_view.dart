import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

import 'emergency_viewmodel.dart';

class EmergencyView extends StackedView<EmergencyViewModel> {
  const EmergencyView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    EmergencyViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMERGENCY CONTACTS'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            height: 700,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Emergency contacts',
                        style: TextStyle(fontSize: 25, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildEmergencyNumberTile('National Emergency Number', '112'),
                        _buildEmergencyNumberTile('Police', '100'),
                        _buildEmergencyNumberTile('Fire', '101'),
                        _buildEmergencyNumberTile('Ambulance', '102'),
                        _buildEmergencyNumberTile('Disaster Management Services', '0471-2730045'),
                        _buildEmergencyNumberTile('Women Helpline', '1091'),
                        _buildEmergencyNumberTile('Women Helpline (Domestic Abuse)', '181'),
                        _buildEmergencyNumberTile('Child Helpline', '1098'),
                        _buildEmergencyNumberTile('Aids Helpline', '1097'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyNumberTile(String title, String number) {
    return ListTile(
      leading: Icon(Icons.phone, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        number,
        style: TextStyle(color: Colors.white),
      ),
      onTap: () async {
        final url = 'tel:$number';
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      },
    );
  }

  @override
  EmergencyViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      EmergencyViewModel();
}


