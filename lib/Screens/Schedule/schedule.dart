import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../Models/schedule.dart';
import '../../Models/user.dart';
import '../To Do List/Loading.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, DailySchedule> weeklySchedule = {};
  String? uid;
  String? nim;
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    initializeAsyncData();
  }

  Future<void> initializeAsyncData() async {
    setState(() {
      _isLoading = true; // Set loading to true before fetching data
    });
    final user = Provider.of<User?>(context, listen: false);
    if (user != null) {
      uid = user.uid;
      print(uid);
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      print(doc.data());
      if (doc.exists) {
        setState(() {
          nim = doc.data()?['nim'] ?? '';
        });
      }
    }
    fetchSchedule(nim!).then((fetchedSchedule) {
      setState(() {
        weeklySchedule = fetchedSchedule.schedule.map((day, items) =>
            MapEntry(day, DailySchedule(items: items)));
            _isLoading = false;
      });
    });
  }
  
Future<WeeklySchedule> fetchSchedule(String userNim) async {
  final response = await http.get(Uri.parse('https://classleap.free.beeceptor.com/data'));
  if (response.statusCode == 200) {
    final jsonString = response.body;
    List<WeeklySchedule> filteredSchedules = ScheduleUtils.filterSchedulesFromJsonString(jsonString, userNim);
    if (filteredSchedules.isNotEmpty) {
      return filteredSchedules.first;
    } else {
      throw Exception('No matching schedule found');
    }
  } else {
    throw Exception('Failed to load schedule');
  }
}

Widget buildScheduleCards(String day) {
  if (!weeklySchedule.containsKey(day) || weeklySchedule[day]!.items.isEmpty) {
    return Center(child: Text('No classes scheduled for $day'));
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
    child: ListView.builder(
      itemCount: weeklySchedule[day]!.items.length,
      itemBuilder: (context, index) {
        final scheduleItem = weeklySchedule[day]!.items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Card(
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                child: Text(scheduleItem.course,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: RichText(
                            text: TextSpan(
                            style: TextStyle(
                fontSize: 14.0,
                color: Colors.black,
                            ), // Default text style
                            children: <TextSpan>[
                TextSpan(text: '${scheduleItem.time} ', style: TextStyle(color: Colors.deepOrangeAccent, fontSize: 14.0)), // Style for time
                TextSpan(text: 'at ${scheduleItem.location}', style: TextStyle(color: Colors.black, fontSize: 14.0)), // Default style for location
                            ],
                          ),
                        ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return _isLoading ? Loading() : Scaffold(
      appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0
            ),
            child: Text(
              'Class Leap',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: Colors.blueAccent,
          elevation: 20.0,
        bottom: TabBar(
          isScrollable: true,
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(text: 'Monday'),
            Tab(text: 'Tuesday'),
            Tab(text: 'Wednesday'),
            Tab(text: 'Thursday'),
            Tab(text: 'Friday'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
              buildScheduleCards('Monday'),
              buildScheduleCards('Tuesday'),
              buildScheduleCards('Wednesday'),
              buildScheduleCards('Thursday'),
              buildScheduleCards('Friday'),
        ],
      ),
    );
  }
}