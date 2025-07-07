import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/device_controller.dart';
import '../models/device_model.dart';
import 'app_routes.dart';

/// 添加设备页面
class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final DeviceController controller = Get.find<DeviceController>();
  bool isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // bg-gray-100
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildScanSection(),
                    const SizedBox(height: 16),
                    _buildActionGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: const Text(
                '添加设备',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40), // 用于平衡布局
        ],
      ),
    );
  }

  /// 构建扫描区域
  Widget _buildScanSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '扫描附近设备',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 160,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() {
                    final isCurrentlyScanning = controller.isScanning;
                    return Icon(
                      isCurrentlyScanning
                          ? Icons.shield
                          : Icons.desktop_access_disabled,
                      size: 63,
                      color: Colors.grey[400],
                    );
                  }),
                  const SizedBox(height: 16),
                  Obx(() {
                    final isCurrentlyScanning = controller.isScanning;
                    return Text(
                      isCurrentlyScanning ? '正在扫描中' : '未检测到设备',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    );
                  }),
                  if (!controller.isScanning) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _startScanning,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('开始扫描'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作网格
  Widget _buildActionGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.qr_code,
            title: '扫码添加',
            onTap: _onQrCodeAdd,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            icon: Icons.settings,
            title: '手动添加',
            onTap: _onManualAdd,
          ),
        ),
      ],
    );
  }

  /// 构建操作卡片
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 开始扫描
  void _startScanning() {
    controller.startScanning();
  }

  /// 扫码添加
  void _onQrCodeAdd() async {
    final result = await Get.toNamed(AppRoutes.qrCodeScanner);
    
    if (result != null && result is String && result.isNotEmpty) {
      // 处理扫描结果
      _processQrCodeResult(result);
    }
  }

  /// 处理二维码扫描结果
  void _processQrCodeResult(String qrData) {
    try {
      // 尝试解析二维码数据
      // 这里假设二维码包含设备信息的JSON字符串
      // 实际应用中可能需要根据您的业务逻辑进行调整
      
      // 示例：创建一个新设备
      final newDevice = DeviceModel(
        id: 'qr_${DateTime.now().millisecondsSinceEpoch}',
        name: '扫码添加设备',
        type: DeviceType.smartSwitch, // 默认类型
        category: DeviceCategory.living, // 默认类别
        isOnline: true,
        lastSeen: DateTime.now(),
        description: '通过扫描二维码添加的设备\n二维码内容: $qrData',
      );
      
      // 添加设备
      controller.addDevice(newDevice);
      
      // 显示成功提示
      Get.snackbar(
        '添加成功',
        '已成功添加设备: ${newDevice.name}',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
      
      // 返回设备列表页面
      Get.back();
    } catch (e) {
      // 显示错误提示
      Get.snackbar(
        '添加失败',
        '无法解析二维码数据: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// 手动添加
  void _onManualAdd() {
    Get.snackbar(
      '功能开发中',
      '手动添加功能正在开发中...',
      backgroundColor: const Color(0xFF8B5CF6),
      colorText: Colors.white,
    );
  }
}
