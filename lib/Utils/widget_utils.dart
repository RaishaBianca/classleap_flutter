import 'package:flutter/material.dart';

InputDecoration textInputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.grey , fontSize: 12),
    fillColor: Colors.white,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 2.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2.0),
    ),
  );
}

Widget textStyleTemplate(String textValue) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.symmetric(horizontal: 40.0, vertical: 5.0),
    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0), // Adjust padding as needed
    decoration: BoxDecoration(
      color: Colors.grey[50],
      border: Border.all(color: Colors.white!, width: 2.0), // Adjust border color and width
      borderRadius: BorderRadius.circular(5.0),
    ),
    child: Text(
      textValue,
      textAlign: TextAlign.start,
      style: TextStyle(
        fontSize: 14.0, // Adjust the font size as needed
        fontWeight: FontWeight.bold, // Optional: for bold text
        color: Colors.grey[700], // Adjust the color as needed
        // Add more styling as needed
      ),
    ),
  );
}