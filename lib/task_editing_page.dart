import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Модель задачи
class Task {
   int id;
   String name;
   String description;
   bool ispriority;
   int eventId;
   DateTime deadline;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.ispriority,
    required this.eventId,
    required this.deadline
  });


  
}

// Страница редактирования задачи
class EditTaskPage extends StatefulWidget {
  final int taskId;

  EditTaskPage({Key? key, required this.taskId}) : super(key: key);

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
late Future<Task> task;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isPriority = true;
  int eventid = 0;
  int id = 0;
   DateTime  dead_line =  new DateTime.now();
  DateTime _convertDateFromString(String date) {
    return DateTime.parse(date);
  }

  @override
  void initState() {
    super.initState();
    task = fetchTask();
  }

  Future<Task> fetchTask() async {
    var data = await http.get(Uri.parse("http://10.0.2.2:3000/api/tasks/${widget.taskId}"));
    print("http://10.0.2.2:3000/api/tasks/${widget.taskId}");
    var jsonData = json.decode(data.body);
    print(jsonData);
   int id = jsonData['event_id'];
  var events_uri = Uri(
          scheme: 'http',
          host: '10.0.2.2',
          port: 3000,
          path: 'api/events/${id}');
      
  var response = await http.get(events_uri);
  var evJsonData = json.decode(response.body);
      Task taskdata = Task(
        id: jsonData['id'],
        name: jsonData['name'],
        description: jsonData['description'],
        ispriority: jsonData['ispriority'],
        eventId: jsonData['event_id'],
        deadline: _convertDateFromString(evJsonData['start_date']));
      return taskdata;
    }

  void _saveTask() async {
    Map<String, String> updatedTask = {
      'id': "$id",
      'name': _nameController.text,
      'description': _descriptionController.text,
      'ispriority': "${_isPriority}",
      'event_id': "${eventid}",
    };

    var response = await http.put(
      Uri.parse("http://10.0.2.2:3000/api/tasks/${widget.taskId}"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedTask),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Task saved successfully")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save task")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: FutureBuilder<Task>(
        future: task,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              _nameController.text = snapshot.data!.name;
              _descriptionController.text = snapshot.data!.description;
              //_isPriority = snapshot.data!.ispriority;
              eventid = snapshot.data!.eventId;
              id = snapshot.data!.id;
              return SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration:InputDecoration(labelText: 'Description'),
                    ),
                    CheckboxListTile(
                title: Text('Priority'),
                value: _isPriority,
                onChanged: (bool? value) {
                  setState(() {
                    _isPriority = value!;
                  });
                
                },
              ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}