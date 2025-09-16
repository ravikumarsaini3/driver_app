import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/order_model.dart';

import '../services/location_services.dart';
import '../services/order_service.dart';

import 'order_history_screen.dart';

class AssignedOrderScreen extends StatefulWidget {
  @override
  _AssignedOrderScreenState createState() => _AssignedOrderScreenState();
}

class _AssignedOrderScreenState extends State<AssignedOrderScreen> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    final orderService = Provider.of<OrderService>(context, listen: false);

    // Initialize location service
    bool locationInitialized = await locationService.initialize();
    if (!locationInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permission required for this app to work'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // Initialize mock order
    orderService.initializeMockOrder();
  }

  Future<void> _launchMaps( double lat, double lng, String label) async {
    final Uri googleMapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$label',
    );

    final bool launched = await launchUrl(
      googleMapsUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      // Fallback: try opening in browser instead of failing silently
      final bool fallbackLaunched = await launchUrl(
        googleMapsUri,
        mode: LaunchMode.platformDefault,
      );

      if (!fallbackLaunched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  void _nextAction() {
    final orderService = Provider.of<OrderService>(context, listen: false);
    final locationService = Provider.of<LocationService>(context, listen: false);
    final order = orderService.currentOrder!;

    bool isAtRestaurant = locationService.isWithinRadius(order.restaurantLocation, 100);
    bool isAtCustomer = locationService.isWithinRadius(order.customerLocation, 100);

    if (!orderService.canProceedToNextStatus(order.status, isAtRestaurant, isAtCustomer)) {
      String message = '';
      if (order.status == OrderStatus.started && !isAtRestaurant) {
        message = 'You need to be within 50m of the restaurant';
      } else if (order.status == OrderStatus.pickedUp && !isAtCustomer) {
        message = 'You need to be within 50m of the customer';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      return;
    }

    OrderStatus? nextStatus = orderService.getNextStatus(order.status);
    if (nextStatus != null) {
      orderService.updateOrderStatus(nextStatus);

      if (nextStatus == OrderStatus.delivered) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order delivered successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Order'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer2<LocationService, OrderService>(
        builder: (context, locationService, orderService, child) {
          final order = orderService.currentOrder;
          final currentPos = locationService.currentPosition;

          if (order == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 100, color: Colors.green),
                  SizedBox(height: 16),
                  Text('No active orders', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      orderService.initializeMockOrder();
                    },
                    child: Text('Get New Order'),
                  ),
                ],
              ),
            );
          }

          bool isAtRestaurant = currentPos != null &&
              locationService!.isWithinRadius(order.restaurantLocation, 50);
          bool isAtCustomer = currentPos != null &&
              locationService!.isWithinRadius(order.customerLocation, 50);

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Current Location Card
                Card(
                  child: ListTile(
                    leading: Icon(Icons.my_location, color: Colors.blue),
                    title: Text('Current Location'),
                    subtitle: currentPos != null
                        ? Text('${currentPos.latitude.toStringAsFixed(4)}, ${currentPos.longitude.toStringAsFixed(4)}')
                        : Text('Getting location...'),
                    trailing: currentPos != null
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : CircularProgressIndicator(),
                  ),
                ),
                SizedBox(height: 16),

                // Order Info Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.receipt, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Order Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Divider(),
                        Text('Order ID: ${order.orderId}'),
                        Text('Amount: ₹${order.orderAmount}'),
                        Text('Status: ${order.getStatusText()}'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Restaurant Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.restaurant, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Restaurant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Divider(),
                        Text(order.restaurantName),
                        if (currentPos != null)
                          Text(locationService.getDistanceText(order.restaurantLocation)),
                        if (isAtRestaurant)
                          Chip(
                            label: Text('Within Range ✓'),
                            backgroundColor: Colors.green.shade100,
                          ),
                        SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _launchMaps(
                            order.restaurantLocation.latitude,
                            order.restaurantLocation.longitude,
                            order.restaurantName,
                          ),
                          icon: Icon(Icons.navigation),
                          label: Text('Navigate'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Customer Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Customer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Divider(),
                        Text(order.customerName),
                        if (currentPos != null)
                          Text(locationService.getDistanceText(order.customerLocation)),
                        if (isAtCustomer)
                          Chip(
                            label: Text('Within Range ✓'),
                            backgroundColor: Colors.green.shade100,
                          ),
                        SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _launchMaps(
                            order.customerLocation.latitude,
                            order.customerLocation.longitude,
                            order.customerName,
                          ),
                          icon: Icon(Icons.navigation),
                          label: Text('Navigate'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Action Button
                if (order.status != OrderStatus.delivered)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _nextAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        order.getNextActionText(),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}