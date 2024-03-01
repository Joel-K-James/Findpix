import 'package:findpix_flutter/ui/smart_widgets/custom_bottom_navbar/bottom_navbar_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'notification_viewmodel.dart';

class NotificationView extends StackedView<NotificationViewModel> {
  const NotificationView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    NotificationViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notification'),
        ),
        bottomNavigationBar: const CustomBottomNavBar(index: 1),
        backgroundColor: Theme.of(context).colorScheme.background,
      body: viewModel.data !=null  ? ListView.builder(
        itemCount: viewModel.data!.length,
        itemBuilder: (context, index) {
          final notification = viewModel.data![index];
          return
            ListItemChat(onDelete: (){
              viewModel.deleteNotification(notification);
            },text: notification.title, subtitle: notification.description, time: notification.time.toString(),);

        },
      ) : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  NotificationViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      NotificationViewModel();
}

class ListItemChat extends StatelessWidget {
  final String text;
  final String subtitle;
  final String time;
  final VoidCallback onDelete;

  const ListItemChat({super.key, required this.text, required this.subtitle, required this.time, required this.onDelete,});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: const Icon(Icons.message), // Icon on the left side
        title: Text(text), // Adjust the chat text
        subtitle: Text(subtitle), // Adjust the last message text
        trailing: IconButton(onPressed: onDelete, icon: const Icon(Icons.delete)),
        onTap: () {

        },
      ),
    );
  }
}
