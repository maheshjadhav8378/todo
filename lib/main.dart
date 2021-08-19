import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:todo_app/providers/todo_list_provider.dart';
import 'package:todo_app/screens/add_todo_screen.dart';
import 'package:todo_app/screens/todo_list_screen.dart';

Future selectNotification(String? payload) async {
  // if (payload != null) {
  //   debugPrint('notification payload: $payload');
  // }
  // await Navigator.push(
  //   context,
  //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
  // );
}

Future onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  // display a dialog with the notification details, tap ok to go to another page
  // showDialog(
  //   context: context,
  //   builder: (BuildContext context) => CupertinoAlertDialog(
  //     title: Text(title),
  //     content: Text(body),
  //     actions: [
  //       CupertinoDialogAction(
  //         isDefaultAction: true,
  //         child: Text('Ok'),
  //         onPressed: () async {
  //           Navigator.of(context, rootNavigator: true).pop();
  //           await Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => SecondScreen(payload),
  //             ),
  //           );
  //         },
  //       )
  //     ],
  //   ),
  // );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  final MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
  runApp(HomePage());
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TodoListProvider>(
      create: (ctx) => TodoListProvider(),
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          accentColor: Colors.amber,
        ),
        home: TodoListScreen(),
        routes: {
          AddTodoScreen.routeName: (ctx) => AddTodoScreen(),
        },
      ),
    );
  }
}
