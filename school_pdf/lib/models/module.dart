import 'package:cloud_firestore/cloud_firestore.dart';

class Module {
  final String id;
  final String name;
  final String medium;
  final String description;
  final String icon;
  // final String color;
  // final String backgroundColor;
  final bool isActive;
  final int order;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Module({
    required this.id,
    required this.name,
    required this.medium,
    required this.description,
    required this.icon,
    // required this.color,
    // required this.backgroundColor,
    required this.isActive,
    required this.order,
    this.createdAt,
    this.updatedAt,
  });

  // Create Module from Firestore document
  factory Module.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Module(
      id: doc.id,
      name: data['name'] ?? '',
      medium: data['medium'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? 'folder',
      // color: data['color'] ?? 'primary',
      // backgroundColor: data['backgroundColor'] ?? 'primaryShade50',
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  // Convert Module to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'medium': medium,
      'description': description,
      'icon': icon,
      // 'color': color,
      // 'backgroundColor': backgroundColor,
      'isActive': isActive,
      'order': order,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create a copy of Module with updated fields
  Module copyWith({
    String? id,
    String? name,
    String? medium,
    String? description,
    String? icon,
    String? color,
    String? backgroundColor,
    bool? isActive,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Module(
      id: id ?? this.id,
      name: name ?? this.name,
      medium: medium ?? this.medium,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      // color: color ?? this.color,
      // backgroundColor: backgroundColor ?? this.backgroundColor,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Module(id: $id, name: $name, medium: $medium, isActive: $isActive, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Module && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 