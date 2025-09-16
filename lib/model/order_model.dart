import 'package:geolocator/geolocator.dart';

enum OrderStatus {
  assigned,
  started,
  atRestaurant,
  pickedUp,
  atCustomer,
  delivered
}

class OrderModel {
  final String orderId;
  final String restaurantName;
  final Position restaurantLocation;
  final String customerName;
  final Position customerLocation;
  final double orderAmount;
  OrderStatus status;

  OrderModel({
    required this.orderId,
    required this.restaurantName,
    required this.restaurantLocation,
    required this.customerName,
    required this.customerLocation,
    required this.orderAmount,
    this.status = OrderStatus.assigned,
  });

  String getStatusText() {
    switch (status) {
      case OrderStatus.assigned:
        return 'Order Assigned';
      case OrderStatus.started:
        return 'Trip Started';
      case OrderStatus.atRestaurant:
        return 'At Restaurant';
      case OrderStatus.pickedUp:
        return 'Order Picked Up';
      case OrderStatus.atCustomer:
        return 'At Customer';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }

  String getNextActionText() {
    switch (status) {
      case OrderStatus.assigned:
        return 'Start Trip';
      case OrderStatus.started:
        return 'Arrived at Restaurant';
      case OrderStatus.atRestaurant:
        return 'Pick Up Order';
      case OrderStatus.pickedUp:
        return 'Arrived at Customer';
      case OrderStatus.atCustomer:
        return 'Mark as Delivered';
      case OrderStatus.delivered:
        return 'Completed';
    }
  }
}