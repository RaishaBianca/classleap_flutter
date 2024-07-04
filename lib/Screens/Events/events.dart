import 'package:class_leap_flutter/Screens/Events/all_events.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../Models/user.dart';
import '../../Services/database.dart';
import '../../Utils/widget_utils.dart';

class Events extends StatefulWidget {
  const Events({Key? key}) : super(key: key);

  @override
  _Events createState() => _Events();
}

class _Events extends State<Events> {
  late CalendarFormat _calendarFormat;
  String eventName = '';
  String description = '';
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  TextEditingController _eventNameController = TextEditingController();
  DatabaseService? dbService; 
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    final user = Provider.of<User?>(context, listen: false);
    if (user != null) {
      dbService = DatabaseService.create(uid: user.uid);
    }
    _fetchEvents();
  }
  

  Future<void> _fetchAllEvents() async {
    final events = await dbService?.fetchEvents();
    if (events != null) {
      setState(() {
        _events = events;
      });
    }
  }

  Future<void> _fetchEvents() async {
    final events = await dbService?.fetchEvents();
    if (events != null) {
      // Convert Timestamp to DateTime and sort events from latest to oldest
      events.sort((a, b) {
        DateTime dateA = (a['date'] as Timestamp).toDate(); // Convert Timestamp to DateTime
        DateTime dateB = (b['date'] as Timestamp).toDate(); // Convert Timestamp to DateTime
        return dateB.compareTo(dateA);
      });
  
      // Get the start and end of the month based on _focusedDay
      DateTime startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
      DateTime endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
  
      // Filter events to only include those within the current month
      List<Map<String, dynamic>> filteredEvents = events.where((event) {
        DateTime eventDate = (event['date'] as Timestamp).toDate(); // Convert Timestamp to DateTime
        return eventDate.isAfter(startOfMonth.subtract(Duration(days: 1))) && eventDate.isBefore(endOfMonth.add(Duration(days: 1)));
      }).toList();
  
      setState(() {
        _events = filteredEvents;
      });
    }
  }

    void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.white70, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            dialogBackgroundColor: Colors.white, // Background color
          ),
          child: AlertDialog(
            title: Text('Add Event'),
            content: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextFormField(
                              decoration: textInputDecoration('Event Name'),
                              onChanged: (val) {
                                setState(() => eventName = val);
                              },
                            ),
                            SizedBox(height: 20.0),
                            TextFormField(
                              decoration: textInputDecoration('Description'),
                              onChanged: (val) {
                                setState(() => description = val);
                              },
                            ),
                            SizedBox(height: 20.0),
                          ],
                        ),
                      ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                  style: TextStyle(
                    color: Colors.deepOrangeAccent,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && description.isNotEmpty && eventName.isNotEmpty) {
                    // Assuming your DatabaseService has a method addEvent
                    await dbService?.addEvents(eventName, _selectedDay, description);
                    print('Event added successfully!');
                    _eventNameController.clear();
                    eventName = '';
                    description = '';
                    _formKey.currentState?.reset();
                    _selectedDay = DateTime.now();
                    _fetchEvents();
                    Navigator.pop(context);
                  }
                },
                child: Text('Add',
                  style: TextStyle(
                    color: Colors.deepOrangeAccent,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Class Leap',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 20.0,
        actions: [
          TextButton.icon(
            onPressed: () async {
              await _fetchAllEvents();
              // In your Events screen, where you navigate to AllEvents
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllEvents(
                    events: _events,
                  ),
                ),
              ).then((_) {
                // This callback is called when you pop back to the Events screen
                _fetchEvents(); // Call _fetchEvents to refresh and sort the events
              });
            },
            icon: Icon(
              Icons.event,
              color: Colors.white,
            ),
            label: Text(
              'All Events',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                _showAddEventDialog();
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
               calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    // Check if the day has any events
                    var formattedDate = DateFormat('yyyy-MM-dd').format(day);
                    bool hasEvents = _events.any((event) =>
                      DateFormat('yyyy-MM-dd').format((event['date'] as Timestamp).toDate()) == formattedDate);

                    if (hasEvents) {
                      // If the day has events, return a widget with a grey background
                      return SizedBox(
                        width: 47, // Set your desired width
                        height: 47, // Set your desired height
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300], // Grey background
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 12, 
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      );
                    }
                    // Return null to use the default appearance
                    return null;
                  },
                ),
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _fetchEvents();
              },
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(fontSize: 12), // Decrease font size for calendar numbers
                todayTextStyle: TextStyle(fontSize: 12, color: Colors.white),
                todayDecoration: BoxDecoration(
                  color: Colors.deepOrangeAccent,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(fontSize: 12, color: Colors.white),
                selectedDecoration: BoxDecoration(
                  color: Colors.deepOrange,
                  shape: BoxShape.circle,
                ),
                 cellMargin: EdgeInsets.all(4),
                 cellPadding: EdgeInsets.all(6),
              ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false, // Hide format button to save space
                  titleCentered: true, // Center the header title
                  // Adjust header text style
                  titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  // Adjust day of the week style
                  leftChevronIcon: Icon(Icons.chevron_left, size: 24),
                  rightChevronIcon: Icon(Icons.chevron_right, size: 24),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  // Adjust days of the week text style to ensure visibility
                  weekdayStyle: TextStyle(fontSize: 12),
                  weekendStyle: TextStyle(fontSize: 12, color: Colors.red),
                ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Theme(
                data: ThemeData.light(),
                child: ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black12, // Set border color
                            width: 1.0, // Set border width
                          ),
                          borderRadius: BorderRadius.circular(10.0), // Set border radius if you need it
                        ),
                        child: ListTile(
                          title: Text(_events[index]['title'],
                            style: TextStyle(
                              color: DateFormat('yyyy-MM-dd').format(_events[index]['date'].toDate()) == DateFormat('yyyy-MM-dd').format(DateTime.now()) ? Colors.deepOrangeAccent : Colors.black87,
                            ),),
                          subtitle: Text(
                            _events[index]['description'],
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          trailing: Text(
                            DateFormat('dd/MM/yyyy').format(_events[index]['date'].toDate()),
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                          leading: Transform.scale(
                            scale: 0.7, // Adjust the scale to decrease the size of the PopupMenuButton
                            child: PopupMenuButton(
                              onSelected: (value) {
                                switch (value) {
                                  case 'delete':
                                      if (dbService != null) {
                                        dbService?.deleteEvents(_events[index]['id']);
                                        _fetchEvents();
                                      }
                                      eventName = '';
                                      description = '';
                                      _formKey.currentState?.reset();
                                      _selectedDay = DateTime.now();
                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                              icon: Padding(
                                padding: EdgeInsets.all(0), // Adjust padding around the icon if needed
                                child: const Icon(Icons.more_horiz),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ),
          ),
        ],
      ),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      //   child: FloatingActionButton(
      //     onPressed: () {
      //       showDialog(
      //         context: context,
      //         builder: (context) {
      //           return AlertDialog(
      //             title: Text('Add Event'),
      //             content: TextField(
      //               controller: _eventNameController,
      //               decoration: InputDecoration(
      //                 hintText: 'Event Name',
      //               ),
      //             ),
      //             actions: <Widget>[
      //               TextButton(
      //                 onPressed: () {
      //                   Navigator.pop(context);
      //                 },
      //                 child: Text('Cancel'),
      //               ),
      //               TextButton(
      //                 onPressed: () {
      //                   Navigator.pop(context);
      //                 },
      //                 child: Text('Add'),
      //               ),
      //             ],
      //           );
      //         },
      //       );
      //     },
      //     child: Icon(Icons.add),
      //   ),
      // ),
    );
  }
  @override
  void dispose() {
    _eventNameController.dispose();
    super.dispose();
  }
}