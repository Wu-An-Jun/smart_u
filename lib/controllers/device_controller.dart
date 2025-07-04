import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/device_model.dart';

/// 设备管理控制器
class DeviceController extends GetxController {
  // 响应式变量
  final RxList<DeviceModel> _devices = <DeviceModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _isScanning = false.obs;
  final RxBool _isBluetoothScanning = false.obs;

  // Getters
  List<DeviceModel> get devices => _devices.toList();
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get hasError => _error.value.isNotEmpty;
  int get deviceCount => _devices.length;
  int get onlineDeviceCount => _devices.where((d) => d.isOnline).length;
  bool get isScanning => _isScanning.value;
  bool get isBluetoothScanning => _isBluetoothScanning.value;

  @override
  void onInit() {
    super.onInit();
    _initializeDevices();
  }

  /// 初始化设备数据
  Future<void> _initializeDevices() async {
    // 默认加载3个设备
    await _loadThreeDevices();
  }

  /// 加载3个默认设备
  Future<void> _loadThreeDevices() async {
    try {
      _setLoading(true);
      _clearError();

      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 0));

      _devices.assignAll([
        // 智能灯光
        DeviceModel(
          id: 'smart_light_001',
          name: '客厅智能灯',
          type: DeviceType.light,
          category: DeviceCategory.living,
          isOnline: true,
          lastSeen: DateTime.now().subtract(const Duration(minutes: 2)),
          description: '客厅照明',
        ),
        // 智能开关
        DeviceModel(
          id: 'smart_switch_001',
          name: '卧室智能开关',
          type: DeviceType.smartSwitch,
          category: DeviceCategory.living,
          isOnline: true,
          lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
          description: '卧室开关控制',
        ),
        // 宠物定位器
        DeviceModel(
          id: 'pet_tracker_001',
          name: '猫咪定位器',
          type: DeviceType.petTracker,
          category: DeviceCategory.pet,
          isOnline: true,
          lastSeen: DateTime.now().subtract(const Duration(minutes: 1)),
          description: '宠物定位',
        ),
      ]);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 加载模拟设备数据
  Future<void> loadMockDevices() async {
    try {
      _setLoading(true);
      _clearError();

      // 创建模拟设备数据
      final mockDevices = [
        // 宠物类设备
        DeviceModel(
          id: 'pet_tracker_001',
          name: '猫咪定位器',
          type: DeviceType.petTracker,
          category: DeviceCategory.pet,
          isOnline: true,
          lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
          description: '深圳市万象城',
        ),
        DeviceModel(
          id: 'pet_tracker_002',
          name: '狗狗定位器',
          type: DeviceType.petTracker,
          category: DeviceCategory.pet,
          isOnline: true,
          lastSeen: DateTime.now().subtract(const Duration(minutes: 2)),
          description: '深圳市万象城',
        ),

        // 生活类设备
        DeviceModel(
          id: 'smart_switch_001',
          name: '路由器开关',
          type: DeviceType.smartSwitch,
          category: DeviceCategory.living,
          isOnline: true,
          lastSeen: DateTime.now().subtract(const Duration(minutes: 1)),
          description: '智能插座',
        ),
        // 地图设备
        DeviceModel(
          id: 'map_001',
          name: '家庭地图',
          type: DeviceType.map,
          category: DeviceCategory.navigation,
          isOnline: true,
          lastSeen: DateTime.now(),
          description: '智能地图',
        ),
      ];

      _devices.value = mockDevices;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 加载设备列表
  Future<void> loadDevices() async {
    await loadMockDevices();
  }

  /// 添加设备
  Future<void> addDevice(DeviceModel device) async {
    try {
      _setLoading(true);
      _clearError();

      // 检查设备是否已存在
      if (_devices.any((d) => d.id == device.id)) {
        throw Exception('设备已存在');
      }

      _devices.add(device);

      // 模拟网络同步
      await Future.delayed(const Duration(milliseconds: 500));

      Get.snackbar(
        '成功',
        '设备添加成功',
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      _setError(e.toString());
      Get.snackbar(
        '错误',
        e.toString(),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// 更新设备信息
  Future<void> updateDevice(String deviceId, DeviceModel updatedDevice) async {
    try {
      _setLoading(true);
      _clearError();

      final index = _devices.indexWhere((d) => d.id == deviceId);
      if (index == -1) {
        throw Exception('设备不存在');
      }

      _devices[index] = updatedDevice;

      // 模拟网络同步
      await Future.delayed(const Duration(milliseconds: 500));

      Get.snackbar(
        '成功',
        '设备信息已更新',
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      _setError(e.toString());
      Get.snackbar(
        '错误',
        e.toString(),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// 删除设备
  Future<void> removeDevice(String deviceId) async {
    try {
      _setLoading(true);
      _clearError();

      _devices.removeWhere((d) => d.id == deviceId);

      // 模拟网络同步
      await Future.delayed(const Duration(milliseconds: 500));

      Get.snackbar(
        '成功',
        '设备已删除',
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      _setError(e.toString());
      Get.snackbar(
        '错误',
        e.toString(),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// 清空所有设备
  void clearAllDevices() {
    _devices.clear();
  }

  /// 更新设备在线状态
  void updateDeviceStatus(String deviceId, bool isOnline) {
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index != -1) {
      _devices[index] = _devices[index].copyWith(
        isOnline: isOnline,
        lastSeen: DateTime.now(),
      );
    }
  }

  /// 获取特定类型的设备
  List<DeviceModel> getDevicesByType(DeviceType type) {
    return _devices.where((d) => d.type == type).toList();
  }

  /// 获取特定分类的设备
  List<DeviceModel> getDevicesByCategory(DeviceCategory category) {
    return _devices.where((d) => d.category == category).toList();
  }

  /// 获取在线设备
  List<DeviceModel> getOnlineDevices() {
    return _devices.where((d) => d.isOnline).toList();
  }

  /// 刷新设备列表
  Future<void> refreshDevices() async {
    await loadMockDevices();
  }

  /// 开始扫描设备
  Future<void> startScanning() async {
    try {
      _setScanning(true);
      _clearError();

      // 模拟扫描过程
      await Future.delayed(const Duration(seconds: 3));

      // 模拟发现新设备
      final discoveredDevice = DeviceModel(
        id: 'discovered_${DateTime.now().millisecondsSinceEpoch}',
        name: '发现的设备',
        type: DeviceType.smartSwitch,
        category: DeviceCategory.living,
        isOnline: true,
        lastSeen: DateTime.now(),
        description: '扫描发现的设备',
      );

      _devices.add(discoveredDevice);

      Get.snackbar(
        '发现设备',
        '找到新设备：${discoveredDevice.name}',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setScanning(false);
    }
  }

  /// 清除错误
  void clearError() {
    _clearError();
  }

  // 私有方法
  void _setLoading(bool loading) {
    if (_isLoading.value != loading) {
      _isLoading.value = loading;
    }
  }

  void _setScanning(bool scanning) {
    if (_isScanning.value != scanning) {
      _isScanning.value = scanning;
    }
  }

  void _setError(String error) {
    _error.value = error;
  }

  void _clearError() {
    if (_error.value.isNotEmpty) {
      _error.value = '';
    }
  }
}
