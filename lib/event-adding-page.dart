import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:successapp/task_adding_page.dart';
class EventAddPage extends StatefulWidget {
  @override
  _EventAddPageState createState() => _EventAddPageState();
  
}

class _EventAddPageState extends State<EventAddPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(hours: 1));
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(hour: TimeOfDay.now().hour+1, minute: TimeOfDay.now().minute);
  bool _allDay = false;
  String? _selectedClass;
  String? _selectedRepeat;
  String? _selectedNotification;

List<String> eventClasses = ['home','job'];
List<String> eventRepeat = ['none','every day', 'every week'];
List<String> eventNotification = ['none','10 min before', '1 hour before', '1 day before'];

  void _saveEvent() async {
    DateTime sd = DateTime(_startDate.year,_startDate.month,_startDate.day, _startTime.hour,_startTime.minute ).toLocal();

    var ed = DateTime(_endDate.year,_endDate.month,_endDate.day, _endTime.hour,_endTime.minute ).toLocal();
    final Map<String, dynamic> eventData = {
      'name': _titleController.text,
      'description': _descriptionController.text,
      'start_date': "$sd",
      'user_id': 1,
      'end_date': "$ed",
      'all_day': _allDay,
      'class_id':1,
    };
    print(eventData['start_date']);
    
    String jsonEvent = json.encode(eventData);
    final response  = await http.post(
      Uri.parse("http://10.0.2.2:3000/api/events"),
    body: jsonEvent,
     headers: {'Content-Type': 'application/json'}
    );
   if (response.statusCode == 201) {
    print('Data sent successfully.');
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
  }

  void _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (newTime != null) {
      setState(() {
        if (isStartTime) {

          _startTime = newTime;
          double st = newTime.hour + newTime.minute/60.0;
          double et = _endTime.hour + _endTime.minute/60.0;
          if (_startDate == _endDate && st > et) {
            _endTime = newTime;
          }
        } else {
          double st = newTime.hour + newTime.minute/60.0;
          double et = _startTime.hour + _startTime.minute/60.0;
          if (_startDate == _endDate && st < et) {
            _endTime = _startTime;
          } else {
            _endTime = newTime;
          }
        }
      });
    }
  }

  void _selectDate(BuildContext context, bool isStart) async {
    var initialDate = isStart ? _startDate : _endDate;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: 300,
            height: 360,
            child: CalendarDatePicker(
              initialDate: initialDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              onDateChanged: (newDate) {
                setState(() {
                  if (isStart) {
                    _startDate = newDate;
                    if (newDate.isAfter(_endDate)) {
                      _endDate = newDate;
                      _endTime = _startTime;
                    }
                  } else {
                    double st = _startTime.hour + _startTime.minute/60.0;
                    double et = _endTime.hour + _endTime.minute/60.0;
                    if (newDate.isBefore(_startDate) || (newDate == _startDate && et < st)) {
                      _endDate = _startDate;
                      _endTime = _startTime;
                    } else {
                      _endDate = newDate;
                    }
                  }
                });
              },
            ),
          ),
        );
      }
    );
  }

Future<List<String>> classLoad() async{
     var data = await http.get(Uri.parse("http://10.0.2.2:3000/api/classes"));
     var jsonData = json.decode(data.body);
     final List<String> classes = [];

     print(jsonData);
     for (var data1 in jsonData) {
      classes.add(data1['name']);
    }

    return classes;
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),

            onPressed: () => {_saveEvent(), Navigator.of(context).pop() }
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Event Title',
                counterText: '',
              ),
              maxLength: 6,
            ),
            SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            SizedBox(height: 8),
            ListTile(
              title: Text('Start Date & Time'),
              subtitle: Text('${_startDate.toString().split(" ")[0]} ${_startTime.format(context)}'),
              onTap: () {
                _selectDate(context, true);
                _selectTime(context, true);
              },
            ),
            ListTile(
              title: Text('End Date & Time'),
              subtitle: Text('${_endDate.toString().split(" ")[0]} ${_endTime.format(context)}'),
              onTap: () {
                _selectDate(context, false);
                _selectTime(context, false);
              },
            ),
            SizedBox(height: 8),
            SwitchListTile(
              title: Text('All Day'),
              value: _allDay,
              onChanged: (bool value) {
                setState(() {
                  _allDay = value;
                });
                
              },
            ),
             DropdownButton<String>(
              hint: Text("Select Notification"),
              value: _selectedNotification,
              onTap: () => {
                setState(() {
                })
              },
              onChanged: (String? newValue) {
                setState(() {
                 _selectedNotification = newValue;
                });
              },
              items: eventNotification.map((String classType) {
                
                return DropdownMenuItem<String>(
                  value: classType,
                  child: Text(classType),
                );
              }).toList(),
            ),
             DropdownButton<String>(
              hint: Text("Select Repeat"),
              value: _selectedRepeat,
              onTap: () => {
                setState(() {
                })
              },
              onChanged: (String? newValue) {
                setState(() {
                 _selectedRepeat = newValue;
                });
              },
              items: eventRepeat.map((String classType) {
                
                return DropdownMenuItem<String>(
                  value: classType,
                  child: Text(classType),
                );
              }).toList(),
            ),
        
            DropdownButton<String>(
              hint: Text("Select Event Class"),
              value: _selectedClass,
              onTap: () => {
                setState(() {
                  classLoad();
                })
              },
              onChanged: (String? newValue) {
                setState(() {
                  _selectedClass = newValue;
                });
              },
              items: eventClasses.map((String classType) {
                
                return DropdownMenuItem<String>(
                  value: classType,
                  child: Text(classType),
                );
              }).toList(),
            ),
            
             
          ],
        ),
      
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: EventAddPage()
));