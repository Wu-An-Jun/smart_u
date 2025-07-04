/// 设备类型枚举
enum DeviceType {
  camera('camera', '摄像头'),
  map('map', '地图设备'),
  petTracker('pet_tracker', '宠物定位器'),
  smartSwitch('smart_switch', '智能开关'),
  router('router', '路由器'),
  light('light', '灯光');

  const DeviceType(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 设备类别枚举
enum DeviceCategory {
  pet('pet', '宠物类家居'),
  living('living', '生活类家居'),
  security('security', '安全监控'),
  navigation('navigation', '导航定位');

  const DeviceCategory(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 设备信息模型
class DeviceModel {
  final String id;
  final String name;
  final DeviceType type;
  final DeviceCategory category;
  final bool isOnline;
  final DateTime lastSeen;
  final String? description;
  final String? imageUrl;
  final String? videoUrl;
  final Map<String, dynamic>? properties;

  DeviceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.isOnline,
    required this.lastSeen,
    this.description,
    this.imageUrl,
    this.videoUrl,
    this.properties,
  });

  DeviceModel copyWith({
    String? id,
    String? name,
    DeviceType? type,
    DeviceCategory? category,
    bool? isOnline,
    DateTime? lastSeen,
    String? description,
    String? imageUrl,
    String? videoUrl,
    Map<String, dynamic>? properties,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      properties: properties ?? this.properties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'category': category.value,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'properties': properties,
    };
  }

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'],
      name: json['name'],
      type: DeviceType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => DeviceType.camera,
      ),
      category: DeviceCategory.values.firstWhere(
        (e) => e.value == json['category'],
        orElse: () => DeviceCategory.living,
      ),
      isOnline: json['isOnline'],
      lastSeen: DateTime.parse(json['lastSeen']),
      description: json['description'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      properties: json['properties'],
    );
  }
} 