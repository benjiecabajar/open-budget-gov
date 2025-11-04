import 'package:budget_gov/pages/home.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MaterialApp(  
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Poppins', // Set the default font family here
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: const HomeScreen(),
  ));
}
