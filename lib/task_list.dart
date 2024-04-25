import 'package:flutter/material.dart';
import 'dart:async'; // Импорт для работы с асинхронными операциями
import 'dart:convert'; // Для работы с JSON
import 'package:http/http.dart' as http;
import 'package:successapp/event_editing_page.dart';
import 'package:successapp/task_editing_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task List',
      home: TaskListPage(),
    );
  }
}

class Task {
  final int id;
  final String name;
  final String description;
  final bool ispriority;
  final int event_id;
  final DateTime? deadline;
  bool isDone;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.ispriority,
    required this.event_id,
    required this.deadline,
    this.isDone = false,
  });
}

class TaskListPage extends StatefulWidget {
  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  DateTime _convertDateFromString(String date) {
    return DateTime.parse(date);
  }

   String DateView(DateTime date) {
   String month =  date.month.toString().length < 2 ? '0' + date.month.toString() : date.month.toString();
   String day =  date.day.toString().length < 2 ? '0' + date.day.toString() : date.day.toString();
   
   return "${date.year.toString()}.${month}.${day}";
  }

  Future<List<Task>> fetchTasks() async {
    var data = await http.get(Uri.parse("http://10.0.2.2:3000/api/tasks"));
    var jsonData = json.decode(data.body);
    List<Task> tasks = [];
    for (var data1 in jsonData) {
      int id = data1['event_id'];
      var events_uri = Uri(
          scheme: 'http',
          host: '10.0.2.2',
          port: 3000,
          path: 'api/events/$id');
      var response = await http.get(events_uri);
      var evJsonData = json.decode(response.body);
      Task taskdata = Task(
        id: data1['id'],
        name: data1['name'],
        description: data1['description'],
        ispriority: data1['ispriority'],
        event_id: data1['event_id'],
        deadline: _convertDateFromString(evJsonData['start_date']),
      );
      tasks.add(taskdata);
    }
    tasks.sort((a, b) {
      if (a.ispriority && !b.ispriority) {
        return -1;
      } else if (!a.ispriority && b.ispriority) {
        return 1;
      } else {
        return a.deadline!.compareTo(b.deadline!);
      }
    });

    return tasks;
  }

   Future<void> deleteTask(int id) async {
      var events_uri = Uri(
          scheme: 'http',
          host: '10.0.2.2',
          port: 3000,
          path: 'api/tasks/$id');
      var response = await http.delete(events_uri);
    }
   

 @override
  void initState() {
    super.initState();
    fetchTasks();
  }


  void updateData() {
    setState(() {
      fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
      ),
      body: FutureBuilder<List<Task>>(
        future: fetchTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Ошибка: ${snapshot.error}"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Task task = snapshot.data![index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    onLongPress: () {
                      Navigator.push(context, MaterialPageRoute(
            builder: (context) => EditTaskPage(taskId: snapshot.data![index].id),
            ),
            )..then((_) => updateData());
                    },
                    leading: task.ispriority ? Icon(Icons.star, color: Colors.red) : null,
                    title: Text(task.name),
                    subtitle: Text("Deadline: ${DateView(task.deadline!)}\n${task.description}", style: TextStyle(fontSize: 12)),
                    trailing: Checkbox(
                      value: task.isDone,
                      onChanged: (bool? newValue) {
                        if (newValue == true) {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: const Text('Do you want to delete this task?'),
                              actions: <Widget>[
                                TextButton(onPressed: () => Navigator.pop(context, 'Cancel'),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      deleteTask(task.id);
                                    });
                                    Navigator.pop(context, 'OK');
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
