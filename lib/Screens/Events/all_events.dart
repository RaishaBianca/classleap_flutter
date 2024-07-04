import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllEvents extends StatefulWidget {
  final List<Map<String, dynamic>> events; // Define an instance variable for events
  const AllEvents({super.key, required this.events});

  @override
  State<AllEvents> createState() => _AllEventsState();
}

class _AllEventsState extends State<AllEvents> {
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
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.events.length, // Correctly placed itemCount
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    child: ListTile(
                      title: Text(widget.events[index]['title']),
                      subtitle: Text(widget.events[index]['description']),
                      trailing: Text(DateFormat('dd/MM/yyyy').format(widget.events[index]['date'].toDate())),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
