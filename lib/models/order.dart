import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final List<OrderItem> items;
  final int totalAmount;
  final DateTime timestamp;
  final String dateLabel;
  final String type;
  final String entryType;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final double? lat;
  final double? lng;
  final int deliveryFee;
  final double totalDistance;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final String? checkoutSessionId;
  final String? paymongoPaymentId;

  OrderModel({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.timestamp,
    required this.dateLabel,
    required this.type,
    required this.entryType,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    this.lat,
    this.lng,
    this.deliveryFee = 0,
    this.totalDistance = 0.0,
    this.paymentMethod = 'Cash',
    this.paymentStatus = 'NOT PAID',
    this.status = 'Pending',
    this.checkoutSessionId,
    this.paymongoPaymentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'items': items.map((i) => i.toJson()).toList(),
      'totalAmount': totalAmount,
      'timestamp': Timestamp.fromDate(timestamp),
      'dateLabel': dateLabel,
      'type': type,
      'entryType': entryType,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'lat': lat,
      'lng': lng,
      'deliveryFee': deliveryFee,
      'totalDistance': totalDistance,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'status': status,
      'checkoutSessionId': checkoutSessionId,
      'paymongoPaymentId': paymongoPaymentId,
    };
  }
}


class OrderItem {
  final String name;
  final String variant;
  final int price;
  final int quantity;

  OrderItem({
    required this.name,
    required this.variant,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'variant': variant,
      'price': price,
      'quantity': quantity,
      'total': price * quantity,
    };
  }
}
