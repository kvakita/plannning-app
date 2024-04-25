import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:successapp/event-adding-page.dart';
import 'package:successapp/event_showing_page.dart';
import 'package:successapp/task_adding_page.dart';
import 'package:successapp/task_list.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:connectivity/connectivity.dart';

void main() => runApp(new JsonData());

class JsonData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnlineJsonData(),
    );
  }
}

class OnlineJsonData extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CalendarExample();
}

class CalendarExample extends State<OnlineJsonData> {
   late Future<List<Meeting>> _futureMeetings;

  @override
  void initState() {
    super.initState();
    _futureMeetings = getDataFromWeb();
  }

  void updateData() {
    setState(() {
      _futureMeetings = getDataFromWeb();
    });
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        title: new Center(child: new Text("Weekly plan", textAlign: TextAlign.center)),
        actions: [
        new TextButton(
          onPressed: () => {
            Navigator.push(context, MaterialPageRoute(
            builder: (context) => TaskListPage()
            ),).then((_) => updateData()),
          },
          child: Text("To-do list")
          ),
           new IconButton(
          icon: new Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
            builder: (context) => EventAddPage(),
            ),
            ).then((_) => updateData());
          },
        ),

      ],
      ),
      body: Container(
        child: FutureBuilder(
          future: getDataFromWeb(),
          builder: (BuildContext context, AsyncSnapshot<List<Meeting>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: const CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Ошибка: ${snapshot.error}"));
            }
            return SafeArea(
              child: SfCalendar(
                view: CalendarView.week,
                initialDisplayDate: DateTime.now(),
                dataSource: MeetingDataSource(snapshot.data ?? []),
                onTap: (details) {
                  if (details.appointments != null && details.appointments!.isNotEmpty) {
                    final int eventId = (details.appointments!.first as Meeting).id!;
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => EventDetailPage(id: eventId),
                    )).then((_) => updateData());
                  }
                },
                onLongPress: (details) {
                  if (details.appointments != null && details.appointments!.isNotEmpty) {
                    final int eventId = (details.appointments!.first as Meeting).id!;
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => CreateTaskPage(event_id: eventId),
                    )).then((_) => updateData());
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

   Future<List<Meeting>> getDataFromWeb() async {
    var data = await http.get(Uri.parse("http://10.0.2.2:3000/api/events"));
    var jsonData = json.decode(data.body);
    List<Meeting> appointmentData = [];
    for (var data1 in jsonData) {
      Meeting meetingData = Meeting(
        id: data1['id'],
        eventName: data1['name'],
        from: _convertDateFromString(data1['start_date']),
        to: _convertDateFromString(data1['end_date']),
        allDay: data1['all_day'],
        classId: data1['class_id'],
        description: data1['description']);
      appointmentData.add(meetingData);
    }
    return appointmentData;
  }

  DateTime _convertDateFromString(String date) {
    return DateTime.parse(date).toLocal();
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }


  @override
  bool isAllDay(int index) {
    return appointments![index].allDay;
  }
}

class Meeting {

  Meeting (
      {
        this.id,
        this.eventName,
        this.from,
        this.to,
        this.allDay,
        this.classId,
        this.description,
      }
);
  int? id;
  String? eventName;
  DateTime? from;
  DateTime? to;
  bool? allDay;
  int? classId;
  String? description;
} 