import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class EditEventPage extends StatefulWidget {
  final int id;

  EditEventPage({Key? key, required this.id}) : super(key: key);

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _allDay = false;
  String? _selectedClass;
  String? _selectedNotification;
  Future<Meeting> fetchEvent() async {
    var eventsUri = Uri(
      scheme: 'http',
      host: '10.0.2.2',
      port: 3000,
      path: 'api/events/${widget.id}',
    );
    var response = await http.get(eventsUri);
    var data = json.decode(response.body);
    var classUri = Uri(
      scheme: 'http',
      host: '10.0.2.2',
      port: 3000,
      path: 'api/classes/${data['class_id']}',
    );
    var responseclass = await http.get(classUri);
    var data1 = json.decode(responseclass.body);
    Meeting event = Meeting(
      eventName: data['name'],
      from: DateTime.parse(data['start_date']).toLocal(),
      to: DateTime.parse(data['end_date']).toLocal(),
      allDay: data['all_day'],
      classId: data1['name'],
      description: data['description'],
    );
    return event;
  }

  @override
  void initState() {
    super.initState();
    fetchEvent().then((event) {
      setState(() {
        _titleController.text = event.eventName;
        _descriptionController.text = event.description;
        _startDate = event.from;
        _endDate = event.to;
        _allDay = event.allDay;
        _selectedClass = event.classId.toString();
        _selectedNotification = 'none';
      });
    });
  }

  void _saveEvent() async {
    var sd = _startDate?.toLocal();
    var ed = _endDate?.toLocal();
    final Map<String, String> eventData = {
      'id' : "${widget.id}",
      'name': _titleController.text,
      'description': _descriptionController.text,
      'start_date': "$sd",
      'user_id': "1",
      'end_date': "$ed",
      'all_day': "${_allDay}",
      'class_id': "1",
    };
    
    var eventsUri = Uri(
      scheme: 'http',
      host: '10.0.2.2',
      port: 3000,
      path: 'api/events/${widget.id}',
    );
    String jsonEvent = json.encode(eventData);
    print(eventsUri);
    final response  = await http.put(eventsUri,
     body: jsonEvent, 
    headers: {'Content-Type': 'application/json' });
   if (response.statusCode == 201) {
    print('Data sent successfully.');
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
        actions: [
          IconButton(onPressed: () {
            _saveEvent();
Navigator.of(context).pop();
            }, icon: Icon(Icons.save_as_rounded)),
        ],
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Event Title'),
              validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;}
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;}
            ),
            SizedBox(height: 8),
            ListTile(
              title: Text('Start Date & Time'),
              subtitle: Text('${_startDate?.toString() ?? ''}'),
              onTap: () async {
                 DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(pickedDate),
      );
      if (time != null) {
        setState(() {
          _startDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            time.hour,
            time.minute);}
            );}
  }}),
            ListTile(
              title: Text('End Date & Time'),
              subtitle: Text('${_endDate?.toString() ?? ''}'),
              onTap: () async {
                 DateTime? pickedDate1 = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate1 != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(pickedDate1),
      );
      if (time != null) {
        setState(() {
          _endDate = DateTime(
            pickedDate1.year,
            pickedDate1.month,
            pickedDate1.day,
            time.hour,
            time.minute);}
            );}}}
            ),
            SizedBox(height: 8),
            SwitchListTile(

              title: Text('All Day'),
              value: _allDay,
              onChanged: (bool value) {
                setState(() {
                  _allDay = value;
                });
              },),
               Column(
                 children: [
                  Text('Select notification'),
                   DropdownButton<String>(
                                 
                                 value: _selectedNotification,
                                 onChanged: (String? newValue) {
                    setState(() {
                      _selectedNotification = newValue;
                    });
                                 },
                                 items: <String>['none','10 min before', '1 hour before', '1 day before'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                                 }).toList(),
                               ),
                 ],
               ),
            Column(
              children: [
                Text('Select class'),
                DropdownButton<String>(
                  
                  value: _selectedClass,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedClass = newValue;
                    });
                  },
                  items: <String>['home', 'job'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Meeting {
  final String eventName;
  final DateTime from;
  final DateTime to;
  final bool allDay;
  final String classId;
  final String description;

  Meeting({
    required this.eventName,
    required this.from,
    required this.to,
    required this.allDay,
    required this.classId,
    required this.description,
  });
}