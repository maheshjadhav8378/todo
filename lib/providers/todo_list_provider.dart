import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_app/models/todo.dart';

class TodoListProvider extends ChangeNotifier {
  List<Todo> _todos = [];

  List<Todo> get todos {
    return [..._todos];
  }

  void addTodo(String title, String description, DateTime deadline) async {
    int randomNumber = Random().nextInt(99999999);
    final newTodo = Todo(randomNumber, title, description, deadline, false);
    _todos.add(newTodo);
    print(_todos.length);
    notifyListeners();
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    final filePath = '${appDocumentDirectory.path}/todo-list.txt';
    print(filePath);
    final file = File(filePath);
    await file.writeAsString(newTodo.toString(), mode: FileMode.append);
    await FlutterLocalNotificationsPlugin().zonedSchedule(
        randomNumber,
        title,
        description + '\n' + DateFormat.yMEd().add_jms().format(deadline),
        tz.TZDateTime.now(tz.local).add(
            Duration(seconds: deadline.difference(DateTime.now()).inSeconds)),
        const NotificationDetails(
            android: AndroidNotificationDetails('your_channel_id',
                'your_channel_name', 'your_channel_description')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Todo findById(int id) {
    return _todos.firstWhere((todo) => todo.id == id);
  }

  Future<void> fetchTodosFromFile() async {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    print(appDocumentDirectory);
    final filePath = '${appDocumentDirectory.path}/todo-list.txt';
    print(filePath);
    final file = File(filePath);
    List<Todo> newtodos = [];

    try {
      Stream<String> lines = file
          .openRead()
          .transform(utf8.decoder) // Decode bytes to UTF-8.
          .transform(LineSplitter()); // Convert stream to individual lines.
      await for (var line in lines) {
        print(line);
        var arr = line.split(',');
        var newTodo = Todo(
          int.parse(arr[0]),
          arr[1],
          arr[2],
          DateTime.parse(arr[3]),
          arr[4] == "true",
        );
        newtodos.add(newTodo);
      }
      _todos = newtodos;
      notifyListeners();
      print('File is now closed.');
    } catch (e) {
      print('Error: $e');
      _todos = [];
    }
  }

  Future<void> editTodo(
    int id,
    String title,
    String description,
    DateTime deadline,
  ) async {
    var todo = _todos.firstWhere((todo) => todo.id == id);

    todo.title = title;
    todo.description = description;
    todo.deadline = deadline;
    notifyListeners();
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    final filePath = '${appDocumentDirectory.path}/todo-list.txt';
    final file = File(filePath);
    var lines = await file.readAsLines();
    for (var line in lines) {
      var arr = line.split(',');
      if (int.parse(arr[0]) == id) {
        lines.remove(line);
        break;
      }
    }
    if (lines.length == 0) {
      await file.writeAsString(lines.join('\n') + todo.toString());
    } else {
      await file.writeAsString(lines.join('\n') + '\n' + todo.toString());
    }
    await FlutterLocalNotificationsPlugin().zonedSchedule(
        id,
        title,
        description + '\n' + DateFormat.yMEd().add_jms().format(deadline),
        tz.TZDateTime.now(tz.local).add(
            Duration(seconds: deadline.difference(DateTime.now()).inSeconds)),
        const NotificationDetails(
            android: AndroidNotificationDetails('your_channel_id',
                'your_channel_name', 'your_channel_description')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> deleteTodos(Set<int> selectedItemsIds) async {
    for (var id in selectedItemsIds) {
      _todos.removeWhere((todo) => todo.id == id);
    }
    notifyListeners();
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    print(appDocumentDirectory);
    final filePath = '${appDocumentDirectory.path}/todo-list.txt';
    print(filePath);
    final file = File(filePath);
    var lines = await file.readAsLines();
    for (var id in selectedItemsIds) {
      await FlutterLocalNotificationsPlugin().cancel(id);
      for (var line in lines) {
        print('LINE : ' + line);
        var arr = line.split(',');
        if (int.parse(arr[0]) == id) {
          lines.remove(line);
          break;
        }
      }
    }

    if (lines.length == 0) {
      await file.writeAsString(lines.join('\n'));
    } else {
      await file.writeAsString(lines.join('\n') + '\n');
    }
  }

  Future<void> completeTodos(Set<int> selectedItemsIds) async {
    for (var id in selectedItemsIds) {
      _todos.forEach((todo) {
        if (todo.id == id) {
          todo.isComplete = true;
        }
      });
    }
    notifyListeners();
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    final filePath = '${appDocumentDirectory.path}/todo-list.txt';
    final file = File(filePath);
    var lines = await file.readAsLines();
    for (var id in selectedItemsIds) {
      await FlutterLocalNotificationsPlugin().cancel(id);
      for (int index = 0; index < lines.length; index++) {
        var arr = lines[index].split(',');
        if (int.parse(arr[0]) == id) {
          arr[4] = "true";
          lines[index] = arr.join(',');
        }
      }
    }
    await file.writeAsString(lines.join('\n') + '\n');
  }
}
