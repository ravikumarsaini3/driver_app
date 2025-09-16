import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/order_service.dart';

class OrderHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<OrderService>(
        builder: (context, orderService, child) {
          final history = orderService.orderHistory;

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No completed orders yet', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final order = history[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text(order.orderId),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.restaurantName),
                      Text('₹${order.orderAmount}'),
                    ],
                  ),
                  trailing: Text('Delivered'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}