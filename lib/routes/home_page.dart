import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../common/Global.dart';
import '../common/dify_ai_service.dart';
import '../common/page_navigator.dart';
import '../widgets/geofence_map_card.dart';
import 'app_routes.dart';
import 'geofence_demo_page.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final AINavigationResponse? navigationInfo;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.navigationInfo,
  }) : timestamp = timestamp ?? DateTime.now();
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // 添加Scaffold key
  final ScrollController _chatScrollController = ScrollController(); // 聊天专用
  final ScrollController _scrollController = ScrollController(); // 页面主滚动
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<ChatMessage> _messages = []; // 聊天消息列表（微信样式）
  final DifyAiService _aiService = DifyAiService();
  bool _isTyping = false;
  bool _autoScrollEnabled = true; // 自动滚动启用状态

  // 设备展示状态
  bool _showDeviceSection = false;

  // 服务展开状态 - 用于控制快速服务项的展开/收起
  final Map<String, bool> _serviceExpandedStates = {
    '我的设备': false,
    '智能生活': false,
    '服务': false,
  };

  // 模拟设备数据，默认为空显示无设备状态
  List<Map<String, dynamic>> _mockDevices = [];

  @override
  void initState() {
    super.initState();

    // 打印调试信息
    print('=== 主页初始化，检查资产配置 ===');

    // 设置系统UI样式 - 完整的全面屏适配
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chatScrollController.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // 添加key
      backgroundColor: Global.currentTheme.backgroundColor,
      resizeToAvoidBottomInset: true,
      // 使用普通的AppBar替代SliverAppBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: _buildFixedAppBar(),
      ),
      drawer: _buildDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 横轴靠左
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0), // 左边留16像素间距
            child: Text(
              '您可以问我',
              style: TextStyle(
                fontSize: 16,
                color: Global.currentTextColor,
                fontWeight: FontWeight.bold, // 加粗
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildQuickServices(),
                  // 展开服务内容区域（在快速服务容器外面）
                  _buildExpandedServicesSection(),
                  const SizedBox(height: 12),
                  if (_showDeviceSection) ...[
                    // _buildDeviceSection(),
                    // 添加地理围栏状态卡片
                    _buildGeofenceStatusCard(),
                    const SizedBox(height: 12),
                  ],

                  const SizedBox(height: 12),
                  _buildChatInquiry(),
                  const SizedBox(height: 12),
                  _buildChatSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildBottomInputBar(),
        ],
      ),
    );
  }

  /// 构建侧边栏导航
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Global.currentTheme.primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Global.currentTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '主人',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('首页'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.devices),
                  title: const Text('我的设备'),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleDeviceSection();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.home_filled),
                  title: const Text('智能生活'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/smart-life');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.room_service),
                  title: const Text('服务'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/service');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.map),
                  title: const Text('地图'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.map);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('地理围栏演示'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GeofenceDemoPage(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.science),
                  title: const Text('智能管家测试'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.aiAssistantTest);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.devices),
                  title: const Text('设备管理演示'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.deviceManagementDemo);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('设置'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.snackbar('提示', '设置功能开发中');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('帮助'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.snackbar('提示', '帮助功能开发中');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建简洁的导航栏
  Widget _buildFixedAppBar() {
    return Container(
      decoration: BoxDecoration(color: Global.currentTheme.backgroundColor),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Global.currentTextColor,
                  size: 24,
                ),
                onPressed: () {
                  // 打开侧边栏导航
                  print('菜单按钮被点击'); // 添加调试信息
                  try {
                    _scaffoldKey.currentState?.openDrawer();
                  } catch (e) {
                    print('打开抽屉失败: $e');
                    // 备用方案
                    Scaffold.of(context).openDrawer();
                  }
                },
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Hi，',
                          style: TextStyle(
                            color: Global.currentTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: '主人',
                          style: const TextStyle(
                            color: Colors.blue, // 光"主人"两个字蓝色
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: '，请问有什么可以帮您的？',
                          style: TextStyle(
                            color: Global.currentTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Global.currentTextColor,
                    size: 20,
                  ),
                  onPressed: () {
                    // 跳转到添加设备页面
                    Get.toNamed(AppRoutes.addDevice);
                  },
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 快速服务
  Widget _buildQuickServices() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(left: 10, top: 12, right: 10),
      height: _showDeviceSection ? 80 : 118, // 当设备区域显示时缩小高度
      decoration: BoxDecoration(
        color: Global.currentTheme.surfaceColor,
        borderRadius: BorderRadius.circular(5), // 对应CSS的border-radius: 5pt
      ),
      padding: EdgeInsets.all(_showDeviceSection ? 8 : 12), // 设备区域显示时减少内边距
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: _showDeviceSection ? 15 : 20, // 设备区域显示时减少间距
        children: [
          _buildQuickServiceItem(
            imagePath: 'imgs/mydevices_icon.png',
            label: '我的设备',
            color: Global.currentTheme.primaryColor,
            isCompact: _showDeviceSection,
          ),
          _buildQuickServiceItem(
            imagePath: 'imgs/mysmartlive_icon.png',
            label: '智能生活',
            color: Global.currentTheme.accentColor,
            isCompact: _showDeviceSection,
          ),
          _buildQuickServiceItem(
            imagePath: 'imgs/myservice_icon.png',
            label: '服务',
            color: Global.currentTheme.primaryColor.shade700,
            isCompact: _showDeviceSection,
          ),
        ],
      ),
    );
  }

  /// 构建展开服务区域（在快速服务容器外面）
  Widget _buildExpandedServicesSection() {
    // 找到当前展开的服务项
    String? expandedService;
    for (String service in _serviceExpandedStates.keys) {
      if (_serviceExpandedStates[service] == true) {
        expandedService = service;
        break;
      }
    }
    
    // 如果没有展开的服务，返回空
    if (expandedService == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 8),
      child: _buildExpandedServiceCard(expandedService),
    );
  }

  Widget _buildQuickServiceItem({
    required String imagePath,
    required String label,
    required Color color,
    bool isCompact = false,
  }) {
    final isExpanded = _serviceExpandedStates[label] ?? false;
    
    return GestureDetector(
              onTap: () {
          setState(() {
            final isCurrentlyExpanded = _serviceExpandedStates[label] ?? false;
            
            // 关闭所有展开状态
            _serviceExpandedStates.updateAll((key, value) => false);
            
            // 如果当前项目没有展开，则展开它（否则保持关闭状态）
            if (!isCurrentlyExpanded) {
              _serviceExpandedStates[label] = true;
            }
          });
          
          // 如果是我的设备，同时触发设备区域显示
          if (label == '我的设备') {
            _toggleDeviceSection();
          }
        },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        width: isCompact ? 65.0 : 75.0, // 紧凑模式下宽度缩小
        height: isCompact ? 70.0 : 90.0, // 紧凑模式下高度缩小
        padding: EdgeInsets.all(isCompact ? 6 : 10), // 紧凑模式下内边距缩小
        decoration: BoxDecoration(
          color: Global.currentTheme.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isExpanded 
              ? Global.currentTheme.primaryColor.withValues(alpha: 0.8)
              : Colors.blue.withValues(alpha: 0.6), // 展开时显示主题色边框
            width: isExpanded ? 2.0 : 1.5,
          ),
          boxShadow: isExpanded ? [
            BoxShadow(
              color: Global.currentTheme.primaryColor.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                imagePath,
                width: isCompact ? 30 : 40, // 紧凑模式下图标缩小
                height: isCompact ? 30 : 40,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: isCompact ? 2 : 4), // 紧凑模式下间距缩小
            Text(
              label,
              style: TextStyle(
                fontSize: isCompact ? 9 : 11, // 紧凑模式下字体更小
                fontWeight: isExpanded ? FontWeight.w600 : FontWeight.w500,
                color: isExpanded 
                  ? Global.currentTheme.primaryColor 
                  : Global.currentTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建展开的服务卡片
  Widget _buildExpandedServiceCard(String serviceLabel) {
    // 计算三角形指针的位置，根据展开的服务项调整
    double triangleLeftPosition = 37.5 - 6; // 默认居中
    
    // 根据展开的服务项调整三角形位置
    if (_serviceExpandedStates['我的设备'] == true) {
      triangleLeftPosition = (_showDeviceSection ? 65.0 : 75.0) / 2 - 6; // 第一个按钮的中心
    } else if (_serviceExpandedStates['智能生活'] == true) {
      final buttonWidth = _showDeviceSection ? 65.0 : 75.0;
      final spacing = _showDeviceSection ? 15.0 : 20.0;
      triangleLeftPosition = buttonWidth + spacing + buttonWidth / 2 - 6; // 第二个按钮的中心
    } else if (_serviceExpandedStates['服务'] == true) {
      final buttonWidth = _showDeviceSection ? 65.0 : 75.0;
      final spacing = _showDeviceSection ? 15.0 : 20.0;
      triangleLeftPosition = (buttonWidth + spacing) * 2 + buttonWidth / 2 - 6; // 第三个按钮的中心
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(top: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 三角形指针
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            top: -6,
            left: triangleLeftPosition,
            child: CustomPaint(
              size: const Size(12, 6),
              painter: TrianglePainter(
                color: Global.currentTheme.surfaceColor,
                borderColor: Global.currentTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
          ),
          // 主卡片内容
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Global.currentTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Global.currentTheme.primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildServiceOptions(serviceLabel),
          ),
        ],
      ),
    );
  }

  /// 构建服务选项内容
  Widget _buildServiceOptions(String serviceLabel) {
    switch (serviceLabel) {
      case '我的设备':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildServiceOption(
                icon: Icons.settings_applications,
                label: '设备管理',
                onTap: () => Get.toNamed('/device-management'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildServiceOption(
                icon: Icons.add_circle_outline,
                label: '添加设备',
                onTap: () => Get.toNamed('/add-device'),
              ),
            ),
          ],
        );
      case '智能生活':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildServiceOption(
                icon: Icons.auto_awesome,
                label: '自动化服务',
                onTap: () => Get.toNamed('/smart-home-automation'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildServiceOption(
                icon: Icons.settings,
                label: '功能设置',
                onTap: () => Get.toNamed('/smart-life'),
              ),
            ),
          ],
        );
      case '服务':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildServiceOption(
                icon: Icons.support_agent,
                label: '客服支持',
                onTap: () => Get.toNamed('/service'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildServiceOption(
                icon: Icons.help_outline,
                label: '帮助中心',
                onTap: () => Get.toNamed('/service'),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// 构建单个服务选项
  Widget _buildServiceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Global.currentTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Global.currentTheme.primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: Global.currentTheme.primaryColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Global.currentTextColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建地理围栏状态卡片
  Widget _buildGeofenceStatusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: GeofenceMapCard(
        cardConfig: GeofenceCardConfig(
          title: '地理围栏状态',
          subtitle: '实时位置监控',
          icon: Icons.location_on,
          backgroundColor:
              Global.currentTheme.primaryColor[1] ??
              Global.currentTheme.surfaceColor,
          height: 350,
          showControls: true,
          compactMode: false,
        ),
        onTap: () {
          // 点击卡片时直接跳转到设备管理页面的猫咪定位器界面
          Get.toNamed('/device-management', arguments: {'showCatLocator': true});
        },
      ),
    );
  }

  Widget _buildChatInquiry() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              '猜你想问',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Global.currentTextColor,
              ),
            ),
          ),
          _buildQuestionItem('怎么看电？有哪些小技巧？'),
          const SizedBox(height: 16),
          _buildQuestionItem('工作日每天9-18点未明摄像头'),
          const SizedBox(height: 16),
          _buildQuestionItem('怎么使用智能管家？'),
          // const SizedBox(height: 16),
          // // 临时添加地理围栏测试按钮
          // _buildGeofenceTestButton(),
          // const SizedBox(height: 16),
          // // 添加API配置检查按钮
          // _buildApiConfigTestButton(),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(String question) {
    return GestureDetector(
      onTap: () {
        _sendMessage(question);
        // 滚动到聊天区域
        Future.delayed(const Duration(milliseconds: 500), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Global.currentTheme.surfaceColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          // border: Border.all(
          //   color:
          //       Global.currentTheme.isDark
          //           ? Colors.grey.shade600
          //           : Colors.grey.shade200,
          // ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                question,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      Global.currentTheme.isDark
                          ? Colors.grey.shade300
                          : Colors.grey.shade700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SvgPicture.asset(
              'imgs/fire_icon.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                Global.currentTheme.primaryColor[1000] ??
                    Global.currentTheme.primaryColor,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建地理围栏测试按钮
  Widget _buildGeofenceTestButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GeofenceDemoPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Global.currentTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Global.currentTheme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: Global.currentTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '🗺️ 测试地理围栏功能 (点击进入)',
                style: TextStyle(
                  fontSize: 14,
                  color: Global.currentTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Global.currentTheme.primaryColor,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建API配置测试按钮
  Widget _buildApiConfigTestButton() {
    return GestureDetector(
      onTap: () {
        // 显示API配置信息对话框
        _showApiConfigDialog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.settings, color: Colors.orange, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '🔑 检查高德地图API配置',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.orange, size: 14),
          ],
        ),
      ),
    );
  }

  /// 显示API配置对话框
  void _showApiConfigDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('高德地图API配置'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildConfigRow('配置状态', '✅ 已配置'),
                const SizedBox(height: 8),
                _buildConfigRow(
                  'Web API Key',
                  '1ee749041c32e1fe06f61caa9c2e9381',
                ),
                const SizedBox(height: 8),
                _buildConfigRow(
                  'Mobile API Key',
                  '1ee749041c32e1fe06f61caa9c2e9381',
                ),
                const SizedBox(height: 16),
                const Text(
                  '注意事项：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• 请确保API Key在高德开放平台已正确配置\n'
                  '• Web服务需要配置域名白名单\n'
                  '• 移动端需要配置应用包名和SHA1\n'
                  '• 如果地图无法显示，请检查网络连接',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  /// 构建配置行
  Widget _buildConfigRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }

  Widget _buildChatSection() {
    return Column(
      children: [
        // 如果有消息则显示聊天标题和清空按钮
        if (_messages.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.only(
              left: 8,
              right: 4,
              top: 8,
              bottom: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AI助手',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _messages.clear();
                    });
                  },
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('清空'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        // 聊天消息区域直接展示到页面中
        ...(_messages
            .map(
              (message) => Container(
                margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: _buildWeChatMessage(message),
              ),
            )
            .toList()),

        // 显示正在输入状态
        if (_isTyping)
          Container(
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: _buildWeChatTypingIndicator(),
          ),

        // 快速回复按钮区域
        if (_messages.isNotEmpty && _messages.last.isUser == false) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickReplyButton('继续'),
                _buildQuickReplyButton('详细说明'),
                _buildQuickReplyButton('举个例子'),
                _buildQuickReplyButton('相关问题'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  /// 构建AI消息内容，支持导航按钮
  Widget _buildAIMessageContent(ChatMessage message) {
    // 如果消息包含导航信息，显示跳转按钮
    if (message.navigationInfo != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 显示AI回复文本（如果有）
          if (message.text.isNotEmpty) ...[
            MarkdownBody(
              data: message.text,
              styleSheet: _getMarkdownStyleSheet(),
            ),
            const SizedBox(height: 12),
          ],
          // 显示跳转按钮
          PageNavigator.createNavigationButton(
            message.navigationInfo!.pageCode,
            buttonText: '打开${message.navigationInfo!.pageName}',
          ),
        ],
      );
    }

    // 普通AI消息，显示Markdown内容
    return MarkdownBody(
      data: message.text,
      styleSheet: _getMarkdownStyleSheet(),
    );
  }

  /// 获取Markdown样式表
  MarkdownStyleSheet _getMarkdownStyleSheet() {
    return MarkdownStyleSheet(
      p: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
      h1: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      h2: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      h3: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      em: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
      code: const TextStyle(
        fontFamily: 'Courier',
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.2),
        color: Colors.white,
        fontSize: 14,
      ),
      codeblockDecoration: const BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.1),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      codeblockPadding: const EdgeInsets.all(12),
      blockquote: const TextStyle(
        color: Colors.white70,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: const BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.05),
        border: Border(left: BorderSide(color: Colors.white30, width: 4)),
      ),
      blockquotePadding: const EdgeInsets.all(8),
      listBullet: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// 构建微信样式的消息气泡
  Widget _buildWeChatMessage(ChatMessage message) {
    final bool isUser = message.isUser;
    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 消息气泡
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color:
                  isUser
                      ? const Color.fromRGBO(55, 65, 81, 1) // 用户对话背景色
                      : const Color.fromRGBO(17, 38, 85, 1), // AI对话背景色
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft:
                    isUser
                        ? const Radius.circular(20)
                        : const Radius.circular(4),
                bottomRight:
                    isUser
                        ? const Radius.circular(4)
                        : const Radius.circular(20),
              ),
            ),
            child:
                isUser
                    ? Text(
                      message.text,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    )
                    : _buildAIMessageContent(message),
          ),
        ),
      ],
    );
  }

  /// 切换设备区域显示状态
  void _toggleDeviceSection() {
    setState(() {
      _showDeviceSection = !_showDeviceSection;
    });
  }

  /// 切换设备状态（测试用）
  void _toggleDeviceState() {
    setState(() {
      if (_mockDevices.isEmpty) {
        // 添加模拟设备
        _mockDevices = [
          {
            'name': '客厅灯',
            'type': 'light',
            'status': '开启',
            'icon': Icons.lightbulb,
            'color': Colors.amber,
          },
          {
            'name': '空调',
            'type': 'air_conditioner',
            'status': '关闭',
            'icon': Icons.ac_unit,
            'color': Colors.blue,
          },
          {
            'name': '智能音箱',
            'type': 'speaker',
            'status': '播放中',
            'icon': Icons.speaker,
            'color': Colors.green,
          },
        ];
      } else {
        // 清空设备列表
        _mockDevices.clear();
      }
    });
  }

  /// 构建设备区域
  Widget _buildDeviceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '我的设备',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _toggleDeviceSection,
                child: const Text('收起'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 设备网格或空状态
          if (_mockDevices.isEmpty)
            _buildNoDeviceState()
          else
            _buildDeviceGrid(),
        ],
      ),
    );
  }

  /// 构建设备网格
  Widget _buildDeviceGrid() {
    final deviceCount = _mockDevices.length;
    final totalSlots = ((deviceCount / 3).ceil() * 3); // 计算总槽位数

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: totalSlots + 1, // +1 为添加按钮预留位置
      itemBuilder: (context, index) {
        if (index < deviceCount) {
          // 显示设备
          final device = _mockDevices[index];
          return _buildDeviceCard(device);
        } else if (index == totalSlots && totalSlots % 3 != 0) {
          // 在最后一行的剩余位置显示添加按钮
          return _buildAddDeviceCard();
        } else if (index == deviceCount && deviceCount % 3 == 0) {
          // 如果设备数量是3的倍数，在新行第一个位置显示添加按钮
          return _buildAddDeviceCard();
        } else {
          // 空槽位
          return const SizedBox.shrink();
        }
      },
    );
  }

  /// 构建设备卡片
  Widget _buildDeviceCard(Map<String, dynamic> device) {
    return GestureDetector(
      onTap: () {
        Get.snackbar('设备控制', '控制${device['name']}功能开发中');
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(device['icon'], color: device['color'], size: 24),
            const SizedBox(height: 4),
            Text(
              device['name'],
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              device['status'],
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建添加设备卡片
  Widget _buildAddDeviceCard() {
    return GestureDetector(
      onTap: () {
        Get.snackbar('提示', '添加设备功能开发中');
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.grey.shade600, size: 20),
            const SizedBox(height: 4),
            Text(
              '添加设备',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建无设备状态
  Widget _buildNoDeviceState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.devices_other, color: Colors.grey.shade400, size: 32),
          const SizedBox(height: 8),
          const Text(
            '还没有绑定设备',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '点击按钮开始添加您的智能设备',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // 紧凑的添加按钮
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.snackbar('提示', '绑定设备功能开发中');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Global.currentTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    '添加设备',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 测试按钮（仅用于演示）
              ElevatedButton(
                onPressed: _toggleDeviceState,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  '测试',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建微信样式的打字指示器
  Widget _buildWeChatTypingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 打字指示器气泡
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color.fromRGBO(17, 38, 85, 1), // AI对话背景色
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI正在思考...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInputBar() {
    return Container(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF343541), // 深色背景
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.snackbar('提示', '语音功能开发中');
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SvgPicture.asset(
                      'imgs/mike_icon.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      // 如果SVG加载失败，使用备用图标
                      // ignore: deprecated_member_use
                      placeholderBuilder:
                          (context) => const Icon(
                            Icons.mic,
                            color: Colors.white,
                            size: 24,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: '请输入消息...',
                      hintStyle: TextStyle(
                        color: Color(0xFF6B7280), // zinc-500
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF18181B), // zinc-900
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      // 添加用户消息到列表
      _messages.add(ChatMessage(text: text.trim(), isUser: true));
      _messageController.clear();
      _isTyping = true;
      // 新消息时重新启用自动滚动
      _autoScrollEnabled = true;
    });

    // 滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottomSmooth();
    });

    // 模拟AI回复
    _simulateAIResponse(text.trim());
  }

  void _simulateAIResponse(String userMessage) {
    // 添加一个空的AI消息，用于逐步更新
    final aiMessageIndex = _messages.length;
    setState(() {
      _messages.add(ChatMessage(text: '', isUser: false));
    });

    // 使用流式AI服务
    _aiService
        .sendMessageStream(userMessage)
        .listen(
          (fullText) {
            if (mounted) {
              setState(() {
                _isTyping = false;

                // 尝试解析AI返回的导航JSON
                AINavigationResponse? navigationInfo = _parseNavigationResponse(
                  fullText,
                );

                // 更新AI消息的内容
                if (aiMessageIndex < _messages.length) {
                  _messages[aiMessageIndex] = ChatMessage(
                    text:
                        navigationInfo != null
                            ? _extractTextFromResponse(fullText, navigationInfo)
                            : fullText,
                    isUser: false,
                    navigationInfo: navigationInfo,
                  );
                }
              });

              // 只在启用自动滚动且用户未手动滚动时才滚动到底部
              if (_autoScrollEnabled) {
                _scrollToBottomSmooth();
              }
            }
          },
          onError: (error) {
            // 如果流式AI服务失败，显示错误信息
            if (mounted) {
              setState(() {
                _isTyping = false;
                if (aiMessageIndex < _messages.length) {
                  _messages[aiMessageIndex] = ChatMessage(
                    text: '抱歉，AI服务暂时不可用：${error.toString()}',
                    isUser: false,
                  );
                }
              });
            }
          },
          onDone: () {
            // 流式输出完成
            if (mounted) {
              setState(() {
                _isTyping = false;
              });

              // 最后滚动到底部（如果启用）
              if (_autoScrollEnabled) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
              }
            }
          },
        );
  }

  /// 构建快速回复按钮
  Widget _buildQuickReplyButton(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                Global.currentTheme.isDark
                    ? Colors.grey.shade600
                    : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(16),
          color: Global.currentTheme.surfaceColor.withOpacity(0.8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color:
                Global.currentTheme.isDark
                    ? Colors.grey[400]
                    : Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _scrollToBottomSmooth() {
    if (!_chatScrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients && mounted) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 解析AI返回的导航响应
  AINavigationResponse? _parseNavigationResponse(String response) {
    try {
      // 尝试在响应中查找JSON块
      final jsonRegex = RegExp(r'\{[^{}]*"action"\s*:\s*"navigate"[^{}]*\}');
      final match = jsonRegex.firstMatch(response);

      if (match != null) {
        final jsonString = match.group(0)!;
        final Map<String, dynamic> jsonData = jsonDecode(jsonString);

        // 验证必要字段
        if (jsonData['action'] == 'navigate' &&
            jsonData['page_code'] != null &&
            jsonData['page_name'] != null) {
          return AINavigationResponse.fromJson(jsonData);
        }
      }
    } catch (e) {
      print('解析导航响应失败: $e');
    }
    return null;
  }

  /// 从AI响应中提取文本内容（去除JSON部分）
  String _extractTextFromResponse(
    String response,
    AINavigationResponse navigationInfo,
  ) {
    try {
      // 移除JSON部分，只保留文本描述
      final jsonRegex = RegExp(r'\{[^{}]*"action"\s*:\s*"navigate"[^{}]*\}');
      String cleanText = response.replaceAll(jsonRegex, '').trim();

      // 如果清理后没有文本，使用导航信息生成友好的消息
      if (cleanText.isEmpty) {
        return '我来帮您打开${navigationInfo.pageName}页面。${navigationInfo.reason}';
      }

      return cleanText;
    } catch (e) {
      return '我来帮您打开${navigationInfo.pageName}页面。';
    }
  }
}

/// 三角形指针绘制器
class TrianglePainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;

  TrianglePainter({
    required this.color,
    required this.borderColor,
    this.borderWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path();
    
    // 绘制向上的三角形
    path.moveTo(size.width / 2, 0); // 顶点
    path.lineTo(0, size.height); // 左下角
    path.lineTo(size.width, size.height); // 右下角
    path.close();

    // 填充三角形
    canvas.drawPath(path, paint);
    // 绘制边框
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}
