import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/providers/todo_list_provider.dart';

class AddTodoScreen extends StatefulWidget {
  static final routeName = '/add-todo';

  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  var selectedDate;
  Todo? newTodo = Todo(null, '', '', null, false);
  var _formKey = GlobalKey<FormState>();
  var isBorn = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isBorn) {
      final id = ModalRoute.of(context)?.settings.arguments as int?;
      if (id != null) {
        final todo =
            Provider.of<TodoListProvider>(context, listen: false).findById(id);
        newTodo = todo;
        selectedDate = newTodo!.deadline;
      }
      isBorn = false;
    }
  }

  void onSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (newTodo != null) {
        print('added');
        Provider.of<TodoListProvider>(context, listen: false).addTodo(
          newTodo!.title,
          newTodo!.description,
          selectedDate,
        );
      }
      Navigator.of(context).pop();
    }
  }

  void onEdit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (newTodo != null) {
        await Provider.of<TodoListProvider>(context, listen: false).editTodo(
          newTodo!.id!,
          newTodo!.title,
          newTodo!.description,
          selectedDate,
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(newTodo!.id == null ? 'Add Todo' : 'Edit Todo'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Container(
              margin: EdgeInsets.all(20),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                child: Container(
                  height: 250,
                  padding: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Title',
                            ),
                            onSaved: (value) {
                              newTodo?.title = value!;
                            },
                            initialValue: newTodo!.title,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Description',
                            ),
                            onSaved: (value) {
                              newTodo?.description = value!;
                            },
                            initialValue: newTodo!.description,
                          ),
                          Row(
                            children: [
                              Text(
                                selectedDate == null
                                    ? 'No Date Chosen'
                                    : DateFormat.yMEd()
                                        .add_jms()
                                        .format(selectedDate),
                              ),
                              Spacer(),
                              TextButton(
                                onPressed: () {
                                  DatePicker.showDateTimePicker(
                                    context,
                                    showTitleActions: true,
                                    minTime: DateTime.now(),
                                    maxTime:
                                        DateTime.now().add(Duration(days: 7)),
                                    onConfirm: (date) {
                                      setState(() {
                                        selectedDate = date;
                                      });
                                    },
                                    onCancel: () {},
                                  );
                                },
                                child: Text(
                                  'Choose Date',
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: newTodo!.id == null ? onSubmit : onEdit,
                            child: Text(
                                newTodo!.id == null ? 'Add Todo' : 'Submit'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
