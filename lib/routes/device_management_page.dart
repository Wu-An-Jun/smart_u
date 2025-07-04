import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common/Global.dart';
import '../controllers/device_controller.dart';
import '../models/device_model.dart';
import '../widgets/center_popup.dart';
import '../widgets/geofence_map_widget.dart';
import '../widgets/more_settings_dialog.dart';
import '../widgets/positioning_mode_selector.dart';
import '../widgets/toggle_button.dart';
import 'geofence_management_page.dart';

class DeviceManagementPage extends StatefulWidget {
  const DeviceManagementPage({super.key});

  @override
  State<DeviceManagementPage> createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends State<DeviceManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final DeviceController controller = Get.find<DeviceController>();

  // 控制是否显示猫咪定位器界面
  final RxBool _showCatLocatorView = false.obs;

  // 控制是否显示定位模式选择器
  final RxBool _showPositioningModeSelector = false.obs;

  // 远程开关状态
  final RxBool _remoteSwitch = false.obs;

  // 猫咪定位器的任务列表
  final RxList<String> _tasks = <String>["宠物离开小区时给我发消息", "每天10点以后关闭定位"].obs;

  @override
  void initState() {
    super.initState();
    controller.loadMockDevices();
    
    // 检查是否需要直接显示猫咪定位器界面
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['showCatLocator'] == true) {
      // 延迟一帧执行，确保widget构建完成
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCatLocator();
      });
    }
  }

  /// 切换到猫咪定位器界面
  void _showCatLocator() {
    _showCatLocatorView.value = true;
    _showPositioningModeSelector.value = false;
  }

  /// 切换到定位模式选择器界面
  void _showPositioningMode() {
    _showPositioningModeSelector.value = true;
    _showCatLocatorView.value = false;
  }

  /// 返回原界面
  void _backToDeviceList() {
    print('返回原界面被调用'); // 调试信息
    _showCatLocatorView.value = false;
    _showPositioningModeSelector.value = false;
  }

  /// 切换远程开关状态
  void _toggleRemoteSwitch() {
    _remoteSwitch.value = !_remoteSwitch.value;
    Get.snackbar(
      '远程开关',
      _remoteSwitch.value ? '设备已开启' : '设备已关闭',
      backgroundColor: Global.currentTheme.primaryColor.withOpacity(0.1),
      colorText: Global.currentTheme.primaryColor,
      duration: const Duration(seconds: 2),
    );
  }

  /// 移除任务
  void _removeTask(String task) {
    _tasks.remove(task);
  }

  /// 显示更多设置弹窗
  void _showMoreSettingsDialog() {
    MoreSettingsDialog.show(
      context,
      onOneKeyRestart: () => _handleOneKeyRestart(),
      onRemoteWakeup: () => _handleRemoteWakeup(),
      onFactoryReset: () => _handleFactoryReset(),
    );
  }

  /// 处理一键重启
  void _handleOneKeyRestart() {
    CenterPopup.show(
      context,
      '正在重启设备...',
      duration: const Duration(seconds: 3),
    );

    // 模拟重启过程
    Future.delayed(const Duration(seconds: 3), () {
      CenterPopup.show(
        context,
        '设备重启成功！',
        duration: const Duration(seconds: 2),
      );
    });
  }

  /// 处理远程唤醒
  void _handleRemoteWakeup() {
    CenterPopup.show(
      context,
      '正在唤醒设备...',
      duration: const Duration(seconds: 2),
    );

    // 模拟唤醒过程
    Future.delayed(const Duration(seconds: 2), () {
      CenterPopup.show(
        context,
        '设备已成功唤醒！',
        duration: const Duration(seconds: 2),
      );
    });
  }

  /// 处理恢复出厂设置
  void _handleFactoryReset() {
    CenterPopup.show(
      context,
      '正在恢复出厂设置...',
      duration: const Duration(seconds: 4),
    );

    // 模拟恢复过程
    Future.delayed(const Duration(seconds: 4), () {
      CenterPopup.show(
        context,
        '出厂设置恢复完成！',
        duration: const Duration(seconds: 2),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Global.currentTheme.backgroundColor, // 使用全局主题背景色
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Obx(() {
                final hasDevices = controller.devices.isNotEmpty;

                if (controller.isLoading) {
                  return _buildLoadingState();
                }

                // 根据当前状态显示不同的界面
                if (_showPositioningModeSelector.value) {
                  return _buildPositioningModeSelectorView();
                } else if (_showCatLocatorView.value) {
                  return _buildCatLocatorView();
                } else {
                  return Container(
                    margin: const EdgeInsets.all(16),
                    child:
                        hasDevices
                            ? _buildDeviceListState()
                            : _buildEmptyState(),
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶部应用栏
  Widget _buildAppBar() {
    return Obx(() {
      final hasDevices = controller.devices.isNotEmpty;
      final title = hasDevices ? '我的设备' : '设备管理';

      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Global.currentTheme.backgroundColor, // 使用全局主题背景色
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Global.currentTextColor,
              ),
            ),
            const Spacer(),
            // 添加按钮
            GestureDetector(
              onTap: () => Get.toNamed('/add-device'),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Global.currentTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            // 更多选项按钮
            GestureDetector(
              onTap: () => _showMoreOptions(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Global.currentTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 无设备空状态界面
  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 20), // 距离顶部20像素
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200], // 灰色背景
            borderRadius: BorderRadius.circular(16), // 圆边处理
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Text(
                '我的设备',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),

              // 空状态提示
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '暂无设备，请先绑定设备！',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // 绑定按钮
              GestureDetector(
                onTap: () => Get.toNamed('/add-device'),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Global.currentTheme.primaryColor, // 使用主题主色
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '绑定',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.add, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(), // 剩余空间
      ],
    );
  }

  /// 有设备时的列表状态
  Widget _buildDeviceListState() {
    return Column(
      children: [
        // 设备列表
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [_buildDeviceGrid(), const SizedBox(height: 20)],
            ),
          ),
        ),
      ],
    );
  }

  /// 设备网格布局
  Widget _buildDeviceGrid() {
    return Obx(() {
      final devices = controller.devices;

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: devices.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildDeviceItem(devices[index]);
        },
      );
    });
  }

  /// 设备项
  Widget _buildDeviceItem(DeviceModel device) {
    return GestureDetector(
      onTap: () => _handleDeviceItemTap(device),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Global.currentTheme.surfaceColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 设备图标
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB366), // 橙色图标背景
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getDeviceIcon(device.type),
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // 设备信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device.description ?? '深圳市万象城',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // 连接状态图标
            Icon(
              device.isOnline ? Icons.wifi : Icons.wifi_off,
              color: device.isOnline ? Colors.green : Colors.grey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// 获取设备图标
  IconData _getDeviceIcon(DeviceType type) {
    switch (type) {
      case DeviceType.camera:
        return Icons.videocam;
      case DeviceType.map:
        return Icons.map;
      case DeviceType.petTracker:
        return Icons.location_on;
      case DeviceType.smartSwitch:
        return Icons.toggle_on;
      case DeviceType.light:
        return Icons.lightbulb;
      case DeviceType.router:
        return Icons.router;
    }
  }

  /// 加载状态
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
          ),
          SizedBox(height: 16),
          Text('加载设备中...', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  /// 处理设备项点击
  void _handleDeviceItemTap(DeviceModel device) {
    // 如果是宠物定位器，显示猫咪定位器界面
    if (device.type == DeviceType.petTracker) {
      _showCatLocator();
    } else if (device.type == DeviceType.map) {
      // 如果是地图设备，跳转到地理围栏管理页面
      _handleGeofenceCardTap();
    } else {
      // 其他设备类型可以在这里添加对应的处理逻辑
      // 暂时显示提示信息
      Get.snackbar(
        '设备详情',
        '${device.name} 功能开发中',
        backgroundColor: Global.currentTheme.primaryColor.withOpacity(0.1),
        colorText: Global.currentTheme.primaryColor,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// 处理地理围栏卡片点击
  void _handleGeofenceCardTap() {
    // 跳转到地理围栏管理页面
    Get.to(() => const GeofenceManagementPage());
  }

  /// 显示更多选项
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('刷新设备'),
                  onTap: () {
                    Navigator.pop(context);
                    controller.loadMockDevices();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('设备设置'),
                  onTap: () {
                    Navigator.pop(context);
                    // 跳转到设备设置页面
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.clear_all),
                  title: const Text('清空所有设备'),
                  onTap: () {
                    Navigator.pop(context);
                    _clearAllDevices();
                  },
                ),
              ],
            ),
          ),
    );
  }

  /// 清空所有设备（用于演示状态切换）
  void _clearAllDevices() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('清空设备'),
        content: const Text('确定要清空所有设备吗？这仅用于演示状态切换。'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              controller.clearAllDevices();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('清空', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 构建猫咪定位器界面
  Widget _buildCatLocatorView() {
    return Container(
      decoration: BoxDecoration(color: Global.currentTheme.backgroundColor),
      child: Column(
        children: [
          // 标题栏
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Global.currentTheme.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Global.currentTheme.backgroundColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // 返回按钮
                GestureDetector(
                  onTap: () {
                    print('返回按钮被点击'); // 调试信息
                    _backToDeviceList();
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),

                // 标题
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      '猫咪定位器',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // 右侧占位，保持标题居中
                const SizedBox(width: 48),
              ],
            ),
          ),

          // 主要内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 地图区域
                  _buildMapSection(),

                  const SizedBox(height: 24),

                  // 功能列表
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildFunctionList(),
                  ),

                  const SizedBox(height: 24),

                  // 智能管家
                  Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16, right: 80),
                    child: _buildSmartButler(),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建地图区域
  Widget _buildMapSection() {
    return Container(
      height: 300, // 增加地图高度
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GeofenceMapWidget(
          config: const GeofenceMapConfig(
            title: '',
            showLegend: false,
            show3D: false,
            enableTestFences: true,
            height: 300,
            showStatus: false,
            showEvents: false,
          ),
          onStatusChanged: (status) {
            // 可以在这里处理地图状态变化
            print('地图状态: $status');
          },
        ),
      ),
    );
  }

  /// 构建功能列表
  Widget _buildFunctionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '功能列表',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Global.currentTextColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Global.currentTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(
                () => _buildToggleButton(
                  iconOn: Icons.toggle_on,
                  iconOff: Icons.toggle_off_outlined,
                  label: '远程开关',
                  isOn: _remoteSwitch.value,
                  onTap: _toggleRemoteSwitch,
                ),
              ),
              _buildFunctionButton(
                icon: Icons.fence_outlined,
                label: '电子围栏',
                onTap: () {
                  // 获取当前的宠物定位器设备
                  final petTracker = controller.devices.firstWhere(
                    (device) => device.type == DeviceType.petTracker,
                    orElse:
                        () => DeviceModel(
                          id: 'pet_tracker_default',
                          name: '猫咪定位器',
                          type: DeviceType.petTracker,
                          category: DeviceCategory.pet,
                          isOnline: true,
                          lastSeen: DateTime.now(),
                        ),
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => GeofenceManagementPage(
                            deviceId: petTracker.id,
                            deviceName: petTracker.name,
                          ),
                    ),
                  );
                },
              ),
              _buildFunctionButton(
                icon: Icons.location_on_outlined,
                label: '定位模式',
                onTap: _showPositioningMode,
              ),
              _buildFunctionButton(
                icon: Icons.settings_outlined,
                label: '更多设置',
                onTap: () => _showMoreSettingsDialog(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建功能按钮
  Widget _buildFunctionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Global.currentTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Global.currentTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Global.currentTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建切换按钮（与功能按钮布局一致）
  Widget _buildToggleButton({
    required IconData iconOn,
    required IconData iconOff,
    required String label,
    required bool isOn,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isOn
                    ? Global.currentTheme.primaryColor.withOpacity(0.2)
                    : Global.currentTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isOn
                      ? Global.currentTheme.primaryColor
                      : Global.currentTheme.primaryColor.withOpacity(0.3),
                  width: isOn ? 2 : 1,
                ),
                boxShadow: isOn
                    ? [
                        BoxShadow(
                          color: Global.currentTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isOn ? iconOn : iconOff,
                  key: ValueKey(isOn),
                  size: 20,
                  color: isOn
                      ? Global.currentTheme.primaryColor
                      : Global.currentTheme.primaryColor.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isOn ? FontWeight.w600 : FontWeight.w500,
                color: isOn
                    ? Global.currentTextColor
                    : Global.currentTextColor.withOpacity(0.8),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
              ),
            ),
            // 状态指示器
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isOn
                    ? Global.currentTheme.primaryColor
                    : Colors.grey.shade400,
                shape: BoxShape.circle,
                boxShadow: isOn
                    ? [
                        BoxShadow(
                          color: Global.currentTheme.primaryColor.withOpacity(0.5),
                          blurRadius: 3,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建智能管家
  Widget _buildSmartButler() {
    return SizedBox(
      width: MediaQuery.of(Get.context!).size.width * 0.7, // 限制宽度为屏幕的70%
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '智能管家',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Global.currentTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Global.currentTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Obx(
              () => Wrap(
                alignment: WrapAlignment.start, // 确保Wrap内容靠左对齐
                spacing: 12,
                runSpacing: 12,
                children: _tasks.map((task) => _buildTaskChip(task)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建任务芯片
  Widget _buildTaskChip(String task) {
    return Container(
      decoration: BoxDecoration(
        color: Global.currentTheme.surfaceColor,
        border: Border.all(
          color: Global.currentTheme.primaryColor.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6, bottom: 6),
            child: Text(
              task,
              style: TextStyle(fontSize: 14, color: Global.currentTextColor),
            ),
          ),
          GestureDetector(
            onTap: () => _removeTask(task),
            child: Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Global.currentTheme.primaryColor.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建定位模式选择器视图
  Widget _buildPositioningModeSelectorView() {
    return Container(
      color: Global.currentTheme.backgroundColor, // 浅灰色背景
      child: Column(
        children: [
          // 头部区域
          _buildHeader(),
          // 定位模式选择器内容
          Expanded(
            child: PositioningModeSelector(
              initialMode: PositioningMode.normal,
              onModeChanged: (mode) {
                // 处理模式变更
                print('选择了定位模式: $mode');
              },
              onCancel: () {
                _backToDeviceList();
              },
              onConfirm: () {
                Get.snackbar(
                  '设置成功',
                  '定位模式已更新',
                  backgroundColor: Global.currentTheme.primaryColor.withOpacity(
                    0.1,
                  ),
                  colorText: Global.currentTheme.primaryColor,
                  duration: const Duration(seconds: 2),
                );
                _backToDeviceList();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建头部区域
  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Global.currentTheme.backgroundColor),
      child: Row(
        children: [
          GestureDetector(
            onTap: _backToDeviceList,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Global.currentTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: Global.currentTheme.primaryColor,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '定位模式设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Global.currentTextColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
