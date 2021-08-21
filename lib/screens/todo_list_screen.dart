import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/todo_list_provider.dart';
import 'package:todo_app/screens/add_todo_screen.dart';
import 'package:todo_app/widgets/ListItem.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({Key? key}) : super(key: key);
  static final routeName = '/todo-list';

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

enum Category {
  Pending,
  Overdue,
  Completed,
}

class _TodoListScreenState extends State<TodoListScreen> {
  Future<void>? _future;
  var todos = [];
  var category = Category.Pending;
  Set<int> selectedTodos = {};

  @override
  void initState() {
    super.initState();
    print('in init state');
    _future = Provider.of<TodoListProvider>(
      context,
      listen: false,
    ).fetchTodosFromFile();
  }

  void selectTodo(int id, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedTodos.add(id);
      } else {
        selectedTodos.remove(id);
      }
    });
    print(selectedTodos.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Todos'),
        actions: [
          if (selectedTodos.length == 1 && category != Category.Completed)
            IconButton(
              onPressed: () async {
                await Navigator.of(context).pushNamed(
                  AddTodoScreen.routeName,
                  arguments: selectedTodos.first,
                );
                setState(() {
                  selectedTodos = {};
                });
              },
              icon: Icon(
                Icons.edit,
              ),
            ),
          if (selectedTodos.length > 0)
            IconButton(
              onPressed: () async {
                await Provider.of<TodoListProvider>(context, listen: false)
                    .deleteTodos(selectedTodos);
                setState(() {
                  selectedTodos = {};
                });
              },
              icon: Icon(Icons.delete),
              color: Colors.red,
            ),
          if (selectedTodos.length > 0 && category != Category.Completed)
            IconButton(
              onPressed: () async {
                await Provider.of<TodoListProvider>(context, listen: false)
                    .completeTodos(selectedTodos);
                setState(() {
                  selectedTodos = {};
                });
              },
              icon: Icon(
                Icons.check_circle,
                color: Theme.of(context).accentColor,
              ),
            ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AddTodoScreen.routeName);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 10,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      category = Category.Pending;
                      selectedTodos = {};
                    });
                  },
                  child: Text(
                    'Pending',
                    style: TextStyle(fontSize: 20),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).accentColor,
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      category = Category.Overdue;
                      selectedTodos = {};
                    });
                  },
                  child: Text(
                    'Overdue',
                    style: TextStyle(fontSize: 20),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).accentColor,
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      category = Category.Completed;
                      selectedTodos = {};
                    });
                  },
                  child: Text(
                    'Completed',
                    style: TextStyle(fontSize: 20),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).accentColor,
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  child: Text(''),
                ),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder(
              future: _future,
              builder: (ctx, AsyncSnapshot<dynamic> futureSnapShot) {
                if (futureSnapShot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (futureSnapShot.error != null) {
                  print(futureSnapShot.error);
                  return Center(
                    child: Text(
                      'Error: ${futureSnapShot.error}',
                    ),
                  );
                } else {
                  return Consumer<TodoListProvider>(
                    builder: (ctx, data, ch) {
                      final todos = data.todos;
                      var filteredTodos = [];
                      if (category == Category.Pending) {
                        filteredTodos = todos
                            .where((todo) =>
                                !todo.isComplete &&
                                todo.deadline!.isAfter(DateTime.now()))
                            .toList();
                      } else if (category == Category.Overdue) {
                        filteredTodos = todos
                            .where((todo) =>
                                !todo.isComplete &&
                                todo.deadline!.isBefore(DateTime.now()))
                            .toList();
                      } else if (category == Category.Completed) {
                        filteredTodos =
                            todos.where((todo) => todo.isComplete).toList();
                      }
                      filteredTodos
                          .sort((a, b) => a.deadline!.compareTo(b.deadline!));
                      return filteredTodos.length == 0
                          ? Center(
                              child: Text(
                                'No Todos in this Category! Try adding some...',
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredTodos.length,
                              itemBuilder: (ctx, index) {
                                print('in builder');
                                return ListItem(
                                  filteredTodos[index],
                                  selectTodo,
                                  key: ValueKey(filteredTodos[index].id),
                                );
                              },
                            );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
