import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../common/Global.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();

  // 模拟用户数据
  final Map<String, dynamic> _userInfo = {
    'name': ' Blue',
    'avatar': '', // 存储选择的头像路径
    'phone': '18866669999',
    'email': 'user@example.com',
    'level': 'VIP',
    'joinDate': '2024-01-15',
  };

  // 预设头像选项
  final List<Map<String, dynamic>> _presetAvatars = [
    {'type': 'icon', 'data': Icons.person, 'color': Colors.blue},
    {'type': 'icon', 'data': Icons.face, 'color': Colors.green},
    {
      'type': 'icon',
      'data': Icons.sentiment_very_satisfied,
      'color': Colors.orange,
    },
    {'type': 'icon', 'data': Icons.pets, 'color': Colors.purple},
    {'type': 'icon', 'data': Icons.favorite, 'color': Colors.red},
    {'type': 'icon', 'data': Icons.star, 'color': Colors.amber},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Global.currentTheme.backgroundColor,
      body: Column(
        children: [
          // 顶部用户信息区域
          _buildUserInfoSection(),
          // 中间服务区域
          Expanded(child: _buildServicesSection()),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Global.currentTheme.primaryColor,
            Global.currentTheme.primaryColor.shade300,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
          child: Column(
            children: [
              // 标题
              const Text(
                '我的页面',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              // 用户信息卡片
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 头像
                    GestureDetector(
                      onTap: _showAvatarOptions,
                      child: _buildAvatarWidget(),
                    ),
                    const SizedBox(width: 16),
                    // 用户信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userInfo['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '手机：${_userInfo['phone']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarWidget() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: ClipOval(
        child:
            _userInfo['avatar'] != null && _userInfo['avatar'].isNotEmpty
                ? _buildSelectedAvatar()
                : const Icon(Icons.person, color: Colors.grey, size: 30),
      ),
    );
  }

  Widget _buildSelectedAvatar() {
    final avatar = _userInfo['avatar'];

    if (avatar.startsWith('preset_')) {
      // 预设头像
      final index = int.parse(avatar.split('_')[1]);
      if (index < _presetAvatars.length) {
        final preset = _presetAvatars[index];
        return Container(
          color: preset['color'].withOpacity(0.1),
          child: Icon(preset['data'], color: preset['color'], size: 30),
        );
      }
    } else if (avatar.startsWith('/')) {
      // 从相册选择的图片
      return Image.file(
        File(avatar),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error, color: Colors.red, size: 30);
        },
      );
    }

    return const Icon(Icons.person, color: Colors.grey, size: 30);
  }

  Widget _buildServicesSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 我的服务
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Global.currentTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '我的服务',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _buildServiceItem(
                  icon: Icons.person,
                  title: '个人账号',
                  onTap: _showPersonalAccountPage,
                ),
                const SizedBox(height: 16),
                _buildServiceItem(
                  icon: Icons.palette,
                  title: '主题设置',
                  onTap: _showThemeSettings,
                ),
                const SizedBox(height: 16),
                _buildServiceItem(
                  icon: Icons.settings,
                  title: '帮助中心',
                  onTap: _showHelpCenter,
                ),
              ],
            ),
          ),
          const Spacer(),
          // 退出登录按钮
          Container(
            width: double.infinity,
            height: 50,
            margin: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: _showLogoutDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Global.currentTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                '退出登录',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Global.currentTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  // 显示个人账号页面
  void _showPersonalAccountPage() {
    Get.to(() => PersonalAccountPage(userInfo: _userInfo));
  }

  // 显示主题设置页面
  void _showThemeSettings() {
    Get.bottomSheet(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '主题设置',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 主题色选择
                const Text(
                  '选择主题色',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),

                // 主题色网格
                Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  children:
                      Global.availableThemes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final theme = entry.value;
                        final isSelected = Global.currentThemeIndex == index;

                        return GestureDetector(
                          onTap: () {
                            Global.setTheme(index);
                            setModalState(() {}); // 更新modal内部状态
                            setState(() {}); // 更新主页面状态
                            Get.snackbar(
                              '主题已更新',
                              '已切换到${theme.displayName}主题',
                              backgroundColor: theme.primaryColor.withOpacity(
                                0.1,
                              ),
                              colorText: theme.primaryColor,
                            );
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? theme.primaryColor
                                        : Colors.grey.shade300,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child:
                                      isSelected
                                          ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 18,
                                          )
                                          : null,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  theme.displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color:
                                        isSelected
                                            ? theme.primaryColor
                                            : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),

                const SizedBox(height: 30),

                // 暗色模式切换
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '暗色模式',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Switch(
                      value: Global.isDarkMode,
                      onChanged: (value) {
                        Global.appState.toggleThemeMode();
                        setModalState(() {});
                        setState(() {});
                      },
                      activeColor: Global.currentTheme.primaryColor,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAvatarOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择头像',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 功能选项
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAvatarOption(
                  '拍照',
                  Icons.camera_alt,
                  _pickImageFromCamera,
                ),
                _buildAvatarOption(
                  '相册',
                  Icons.photo_library,
                  _pickImageFromGallery,
                ),
                _buildAvatarOption('删除', Icons.delete, _removeAvatar),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // 预设头像
            const Text(
              '预设头像',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            Wrap(
              spacing: 15,
              runSpacing: 15,
              children:
                  _presetAvatars.asMap().entries.map((entry) {
                    final index = entry.key;
                    final preset = entry.value;
                    return GestureDetector(
                      onTap: () => _selectPresetAvatar(index),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: preset['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: preset['color'], width: 2),
                        ),
                        child: Icon(
                          preset['data'],
                          color: preset['color'],
                          size: 25,
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF6B4DFF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF6B4DFF), size: 30),
          ),
          const SizedBox(height: 8),
          Text(title),
        ],
      ),
    );
  }

  // 从相机拍照
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _userInfo['avatar'] = image.path;
        });
        Get.back();
        Get.snackbar('成功', '头像已更新');
      }
    } catch (e) {
      Get.snackbar('错误', '拍照失败：$e');
    }
  }

  // 从相册选择
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _userInfo['avatar'] = image.path;
        });
        Get.back();
        Get.snackbar('成功', '头像已更新');
      }
    } catch (e) {
      Get.snackbar('错误', '选择图片失败：$e');
    }
  }

  // 选择预设头像
  void _selectPresetAvatar(int index) {
    setState(() {
      _userInfo['avatar'] = 'preset_$index';
    });
    Get.back();
    Get.snackbar('成功', '头像已更新');
  }

  // 删除头像
  void _removeAvatar() {
    setState(() {
      _userInfo['avatar'] = '';
    });
    Get.back();
    Get.snackbar('成功', '头像已删除');
  }

  void _showHelpCenter() {
    Get.snackbar('提示', '帮助中心功能开发中...');
  }

  void _showLogoutDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, size: 64, color: Color(0xFF6B4DFF)),
              const SizedBox(height: 16),
              const Text(
                '确认退出',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '确定要退出当前账号吗？',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.offAllNamed('/login'); // 退出到登录页
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B4DFF),
                      ),
                      child: const Text(
                        '确定',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 个人账号页面
class PersonalAccountPage extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  const PersonalAccountPage({super.key, required this.userInfo});

  @override
  State<PersonalAccountPage> createState() => _PersonalAccountPageState();
}

class _PersonalAccountPageState extends State<PersonalAccountPage> {
  late Map<String, dynamic> _userInfo;

  @override
  void initState() {
    super.initState();
    _userInfo = Map.from(widget.userInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B4DFF),
        title: const Text('个人信息', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6B4DFF), Color(0xFFF5F5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoItem(
                        title: '头像',
                        content: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(child: _buildAvatarInAccountPage()),
                        ),
                        onTap: () {
                          Get.snackbar('提示', '请返回上一页修改头像');
                        },
                      ),
                      const Divider(),
                      _buildInfoItem(
                        title: '昵称',
                        content: Text(
                          _userInfo['name'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        onTap: _editUserName,
                      ),
                      const Divider(),
                      _buildInfoItem(
                        title: '手机',
                        content: Text(
                          _userInfo['phone'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        onTap: () {
                          Get.snackbar('提示', '手机号修改功能开发中...');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarInAccountPage() {
    final avatar = _userInfo['avatar'];

    if (avatar != null && avatar.isNotEmpty) {
      if (avatar.startsWith('preset_')) {
        // 预设头像
        final index = int.parse(avatar.split('_')[1]);
        final presetAvatars = [
          {'data': Icons.person, 'color': Colors.blue},
          {'data': Icons.face, 'color': Colors.green},
          {'data': Icons.sentiment_very_satisfied, 'color': Colors.orange},
          {'data': Icons.pets, 'color': Colors.purple},
          {'data': Icons.favorite, 'color': Colors.red},
          {'data': Icons.star, 'color': Colors.amber},
        ];

        if (index < presetAvatars.length) {
          final preset = presetAvatars[index];
          final color = preset['color'] as Color?;
          final iconData = preset['data'] as IconData?;

          if (color != null && iconData != null) {
            return Container(
              color: color.withOpacity(0.1),
              child: Icon(iconData, color: color, size: 20),
            );
          }
        }
      } else if (avatar.startsWith('/')) {
        // 从相册选择的图片
        return Image.file(
          File(avatar),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, color: Colors.red, size: 20);
          },
        );
      }
    }

    return const Icon(Icons.person, color: Colors.grey, size: 20);
  }

  Widget _buildInfoItem({
    required String title,
    required Widget content,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            Expanded(child: content),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  void _editUserName() {
    final controller = TextEditingController(text: _userInfo['name']);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '修改昵称',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: '请输入新的昵称',
                  border: OutlineInputBorder(),
                ),
                maxLength: 20,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final newName = controller.text.trim();
                        if (newName.isNotEmpty) {
                          setState(() {
                            _userInfo['name'] = newName;
                          });
                          Get.back();
                          Get.snackbar('成功', '昵称修改成功');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B4DFF),
                      ),
                      child: const Text(
                        '确定',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
