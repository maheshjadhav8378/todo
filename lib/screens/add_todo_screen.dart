import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/providers/todo_list_provider.dart';

class AddTodoScreen extends StatefulWidget {
  static final routeName = '/add-todo';
  final int? id;
  final Key? key;

  AddTodoScreen({this.id, this.key});

  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  // var selectedDate;
  Todo? newTodo = Todo(null, '', '', null, false);
  var _formKey = GlobalKey<FormState>();
  var isBorn = true;

  DateTime? selectedDate1;

  TimeOfDay selectedTime1 = TimeOfDay(
    hour: 0,
    minute: 0,
  );

  @override
  void initState() {
    super.initState();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        selectedDate1 = picked;
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isBorn) {
      if (widget.id != null) {
        final todo = Provider.of<TodoListProvider>(context, listen: false)
            .findById(widget.id!);
        newTodo = todo;
        selectedDate1 = newTodo!.deadline;
        selectedTime1 = TimeOfDay(
          hour: todo.deadline!.hour,
          minute: todo.deadline!.minute,
        );
      }
      isBorn = false;
    }
  }

  void onSubmit() {
    if (selectedDate1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select date'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }
    if (DateTime(
      selectedDate1!.year,
      selectedDate1!.month,
      selectedDate1!.day,
      selectedTime1.hour,
      selectedTime1.minute,
    ).isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select future date'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (newTodo != null) {
        print('added');
        Provider.of<TodoListProvider>(context, listen: false).addTodo(
          newTodo!.title,
          newTodo!.description,
          DateTime(
            selectedDate1!.year,
            selectedDate1!.month,
            selectedDate1!.day,
            selectedTime1.hour,
            selectedTime1.minute,
          ),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Todo added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      // return;
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void onEdit() async {
    if (selectedDate1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select date'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }
    if (DateTime(
      selectedDate1!.year,
      selectedDate1!.month,
      selectedDate1!.day,
      selectedTime1.hour,
      selectedTime1.minute,
    ).isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select future date'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (newTodo != null) {
        await Provider.of<TodoListProvider>(context, listen: false).editTodo(
          newTodo!.id!,
          newTodo!.title,
          newTodo!.description,
          DateTime(
            selectedDate1!.year,
            selectedDate1!.month,
            selectedDate1!.day,
            selectedTime1.hour,
            selectedTime1.minute,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Todo edited successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime1,
    );
    if (picked != null)
      setState(() {
        selectedTime1 = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(
        title: Text(newTodo!.id == null ? 'Add Todo' : 'Edit Todo'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                    height: 320,
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
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Title is required!";
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Description',
                              ),
                              onSaved: (value) {
                                newTodo?.description = value!;
                              },
                              initialValue: newTodo!.description,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Description is required!";
                                }
                                return null;
                              },
                            ),
                            Row(
                              children: [
                                Text(
                                  selectedDate1 == null
                                      ? 'No Date Chosen'
                                      : '${DateFormat.yMd().format(selectedDate1!)} MM/DD/YYYY',
                                ),
                                Spacer(),
                                TextButton(
                                  onPressed: () => _selectDate(context),
                                  child: Text(
                                    'Choose Date',
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  (selectedTime1.hour < 10
                                          ? '0${selectedTime1.hour}'
                                          : '${selectedTime1.hour}') +
                                      ':' +
                                      (selectedTime1.minute < 10
                                          ? '0${selectedTime1.minute}'
                                          : '${selectedTime1.minute}') +
                                      ' HH:MM',
                                ),
                                Spacer(),
                                TextButton(
                                  onPressed: () => _selectTime(context),
                                  child: Text(
                                    'Choose Time',
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed:
                                  newTodo!.id == null ? onSubmit : onEdit,
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
      ),
    );
  }
}
