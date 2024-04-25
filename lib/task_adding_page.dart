import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CreateTaskPage extends StatefulWidget {
  final int event_id; // ID события подается на вход страницы для создания задачи

  CreateTaskPage({Key? key, required this.event_id}) : super(key: key);

  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isPriority = false;

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final taskData = {
        'name': _titleController.text,
        'description': _descriptionController.text,
        'ispriority': _isPriority,
        'event_id': widget.event_id,
      };

      String jsonTask = json.encode(taskData);
      Uri uri = Uri.parse("http://10.0.2.2:3000/api/tasks");
      final response = await http.post(
        uri,
        body: jsonTask,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        print('Task created successfully.');
        // Optionally close the screen
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
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
              ElevatedButton(

                onPressed:() => {
                
                  _saveTask(),
                  
                  Navigator.of(context).pop(),
                
                },
                child: Text('Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}