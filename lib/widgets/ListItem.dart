import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/todo.dart';

class ListItem extends StatefulWidget {
  ListItem(this.todo, this.selectTodo, {Key? key}) : super(key: key);

  final Todo todo;
  final Function selectTodo;

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  var isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isSelected ? Colors.amber[100] : Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          onTap: () {
            isSelected = !isSelected;
            widget.selectTodo(widget.todo.id, isSelected);
          },
          leading: Container(
            padding: EdgeInsets.all(10),
            color: Theme.of(context).primaryColor,
            width: 80,
            child: FittedBox(
              child: Text(
                widget.todo.title,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          title: Text(
            DateFormat.yMEd().add_jms().format(widget.todo.deadline!),
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          subtitle: Text(
            widget.todo.description,
          ),
          trailing: !isSelected
              ? Icon(Icons.check_circle_outline_outlined)
              : Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                ),
          // Container(
          //   width: 100,
          //   child: Row(
          //     children: [
          //       IconButton(
          //         padding: EdgeInsets.all(0),
          //         onPressed: () async {
          //           await Provider.of<TodoListProvider>(
          //                   context,
          //                   listen: false)
          //               .deleteTodo(
          //                   filteredTodos[index].id!);
          //         },
          //         icon: Icon(
          //           Icons.delete,
          //           color: Theme.of(context).errorColor,
          //         ),
          //       ),
          //       IconButton(
          //         onPressed: () {
          //           Navigator.of(context).pushNamed(
          //             AddTodoScreen.routeName,
          //             arguments:
          //                 filteredTodos[index].id,
          //           );
          //         },
          //         icon: Icon(
          //           Icons.edit,
          //           color:
          //               Theme.of(context).primaryColor,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ),
      ),
    );
    ;
  }
}
