import 'package:flutter/material.dart';
import 'category_route.dart';

void main() {
  runApp(UnitConverterApp());
}

class UnitConverterApp extends StatelessWidget {
  final _appTitle = "Unit Converter";

  ThemeData _buildAppTheme(BuildContext context) {
    return ThemeData(
      fontFamily: "Raleway",
      textTheme: Theme.of(context).textTheme.apply(
            bodyColor: Colors.black,
            displayColor: Colors.grey[600],
          ),
      // This colors the [InputOutlineBorder] when it is selected
      primaryColor: Colors.grey[500],
      textSelectionHandleColor: Colors.green[500],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _appTitle,
      theme: _buildAppTheme(context),
      home: CategoryRoute(),
    );
  }
}
