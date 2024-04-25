import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:successapp/event-adding-page.dart';
import 'package:successapp/event_editing_page.dart';

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

class EventDetailPage extends StatefulWidget {
  final int id;
  EventDetailPage({required this.id});

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  Future<Meeting>? _meeting;

  @override
  void initState() {
    super.initState();
    _meeting = fetchEvent();
  }


  void updateData() {
    setState(() {
      _meeting = fetchEvent();
    });
  }
  DateTime _convertDateFromString(String date) {
    return DateTime.parse(date);
  }

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
      from: _convertDateFromString(data['start_date']),
      to: _convertDateFromString(data['end_date']),
      allDay: data['all_day'],
      classId: data1['name'],
      description: data['description'],
    );
    return event;
  }

  void _deleteEvent() async {
    var deleteUri = Uri(
      scheme: 'http',
      host: '10.0.2.2',
      port: 3000,
      path: 'api/events/${widget.id}',
    );
    var response = await http.delete(deleteUri);
    if (response.statusCode == 204) {
       // Go back to the previous screen
    } else {
      print('Failed to delete the event with status: ${response.statusCode}');
    }
  }

  void _editEvent() {
    // Redirect to Edit Event Page
  }
String DateView(DateTime date) {
   String month =  date.month.toString().length < 2 ? '0' + date.month.toString() : date.month.toString();
   String day =  date.day.toString().length < 2 ? '0' + date.day.toString() : date.day.toString();
   String hour =  date.hour.toString().length < 2 ? '0' + date.hour.toString() : date.hour.toString();
   String minute =  date.minute.toString().length < 2 ? '0' + date.minute.toString() : date.minute.toString();
   return "${date.year.toString()}.${month}.${day} ${hour}:${minute}";
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed:() { Navigator.push(context, MaterialPageRoute(
            builder: (context) => EditEventPage(id: widget.id))
            ).then((_) => updateData());
            }

          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () =>{
            
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
                          _deleteEvent();
                        });
                        Navigator.pop(context, 'OK');
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
              
              }
            
            
          ),
        ],
      ),
      body: FutureBuilder<Meeting>(
      future: _meeting,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                textWithRoundedCorners('Event: ${snapshot.data!.eventName}', 24),
                textWithRoundedCorners('From: ${snapshot.data!.from.toLocal()}', 18),
                textWithRoundedCorners('To: ${snapshot.data!.to.toLocal()}', 18),
                textWithRoundedCorners('All Day: ${snapshot.data!.allDay}', 18),
                textWithRoundedCorners('Description: ${snapshot.data!.description}', 18),
                textWithRoundedCorners('Class: ${snapshot.data!.classId}', 18),
                textWithRoundedCorners('Notification: none', 18),
              ],
            ),
          );
        } else {
          return Text("No data available");
        }
      },
    ));
  }
  
  
  Widget textWithRoundedCorners(String text, double fontSize) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.only(bottom: 8), // Spacing between items
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        border: Border.all(color: Color.fromARGB(171, 0, 0, 0), width: 1), // Border color and width
        borderRadius: BorderRadius.circular(10), // Rounded corner radius
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
        ),
      ),
    );
      
  } }