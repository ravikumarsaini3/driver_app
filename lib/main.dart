import 'package:driver_app/screen/login_screen.dart';
import 'package:driver_app/services/location_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/order_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => OrderService()),
      ],
      child: MaterialApp(
        title: 'Driver App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}