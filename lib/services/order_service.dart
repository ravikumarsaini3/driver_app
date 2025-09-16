import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../model/order_model.dart';


class OrderService extends ChangeNotifier {
  OrderModel? _currentOrder;
  List<OrderModel> _orderHistory = [];

  OrderModel? get currentOrder => _currentOrder;
  List<OrderModel> get orderHistory => _orderHistory;

  /// Initialize with a mock order
  void initializeMockOrder() {
    _currentOrder = OrderModel(
      orderId: 'ORD-123455',
      restaurantName: 'Pizza Palace 2',
      restaurantLocation: Position(
        latitude:28.4443803473562, // Delhi coordinates (adjust for your testing)
        longitude: 77.8520229955407,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 1,
        speedAccuracy: 0, altitudeAccuracy:0, headingAccuracy: 0,
      ),
      customerName: 'John Doe',
      customerLocation: Position(
        latitude:29.44438034735623, // Delhi coordinates (adjust for your testing)
        longitude: 77.8520229955408,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy:0 ,
        headingAccuracy: 0,
      ),
      orderAmount: 599.99,
    );
    notifyListeners();
  }

  /// Update order status
  bool updateOrderStatus(OrderStatus newStatus) {
    if (_currentOrder != null) {
      _currentOrder!.status = newStatus;

      // If order is completed, move to history
      if (newStatus == OrderStatus.delivered) {
        _orderHistory.add(_currentOrder!);
        _currentOrder = null;
      }

      notifyListeners();
      return true;
    }
    return false;
  }


  bool canProceedToNextStatus(OrderStatus currentStatus, bool isAtRestaurant, bool isAtCustomer) {
    switch (currentStatus) {
      case OrderStatus.assigned:
      case OrderStatus.atRestaurant:
        return true; // These don't require geofence check
      case OrderStatus.started:
        return isAtRestaurant; // Need to be at restaurant
      case OrderStatus.pickedUp:
        return isAtCustomer; // Need to be at customer
      case OrderStatus.atCustomer:
        return true; // Can always mark as delivered when at customer
      case OrderStatus.delivered:
        return false; // Order is complete
    }
  }

  /// Get next order status
  OrderStatus? getNextStatus(OrderStatus currentStatus) {
    switch (currentStatus) {
      case OrderStatus.assigned:
        return OrderStatus.started;
      case OrderStatus.started:
        return OrderStatus.atRestaurant;
      case OrderStatus.atRestaurant:
        return OrderStatus.pickedUp;
      case OrderStatus.pickedUp:
        return OrderStatus.atCustomer;
      case OrderStatus.atCustomer:
        return OrderStatus.delivered;
      case OrderStatus.delivered:
        return null;
    }
  }
}