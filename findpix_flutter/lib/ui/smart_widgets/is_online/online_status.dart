import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'online_status_viewmodel.dart';

class IsOnlineWidget extends StatelessWidget {
  const IsOnlineWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      onModelReady: (model) => model.setTimer(),
      builder: (context, model, child) {
        if (model.isOnline) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Text(
                  'Online',
                  style: TextStyle(color: Colors.black),
                ),
                Icon(
                  Icons.circle,
                  color: Colors.green,
                  size: 16,
                )
              ],
            ),
          ));
        } else {
          return Center(
              child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              model.lastSeen(),
              style: const TextStyle(color: Colors.black),
            ),
          ));
        }
      },
      viewModelBuilder: () => HomeViewModel(),
    );
  }
}
