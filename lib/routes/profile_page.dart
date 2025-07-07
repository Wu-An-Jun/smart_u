import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    'name': '武安',
    'avatar': '', // 存储选择的头像路径
    'phone': '18899996666',
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

  // 新增：帮助中心状态
  bool _showHelpFaq = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Global.currentTheme.backgroundColor,
      body:
          _showHelpFaq
              ? _buildHelpFaqWidget()
              : Column(
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
    // 顶部用户信息区域，完全还原设计稿
    return Container(
      width: double.infinity,
      color: const Color(0xFF0A0C1E),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 0),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // 顶部标题栏
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D35),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 头像
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('imgs/user_avatar.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 用户信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 28,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '武安',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '手机: 18866669999',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontFamily: 'Noto Sans',
                              fontSize: 14,
                              height: 1.43,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
    );
  }

  Widget _buildServicesSection() {
    // 服务区域，完全还原设计稿
    return Container(
      color: const Color(0xFF0A0C1E),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 0),
      child: Column(
        children: [
          // 服务卡片
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D35),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '服务',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // 流量充值服务
                Row(
                  children: [
                    Container(
                      width: 81,
                      height: 73,
                      padding: const EdgeInsets.fromLTRB(18, 10, 15, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.transparent,
                      ),
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            'imgs/service_recharge.svg',
                            width: 30,
                            height: 30,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '流量充值',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Inter',
                              fontSize: 12,
                              height: 1.66,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 个人信息卡片
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D35),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 8, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '个人信息',
                  style: TextStyle(
                    color: Color(0xFFEDEEF0),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                // 个人账号
                GestureDetector(
                  onTap: _showPersonalAccountPage,
                  child: Container(
                    padding: const EdgeInsets.only(top: 12, bottom: 13),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0x4DF3F3F6), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0x4D3B82F6),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'imgs/account_icon.svg',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '个人账号',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '管理您的个人资料和隐私设置',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                  height: 1.33,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SvgPicture.asset(
                          'imgs/arrow_right_1.svg',
                          width: 20,
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                // 帮助中心
                GestureDetector(
                  onTap: _showHelpCenter,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0x4D22C55E),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'imgs/help_center_icon.svg',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '帮助中心',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '常见问题解答和客户支持',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                                height: 1.33,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SvgPicture.asset(
                        'imgs/arrow_right_2.svg',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // 退出登录按钮
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20, top: 36),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF1A73E8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _showLogoutDialog,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 13),
                  child: Center(
                    child: Text(
                      '退出登录',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 显示个人账号页面
  void _showPersonalAccountPage() {
    Get.to(() => PersonalAccountPage(userInfo: _userInfo));
  }

  void _showHelpCenter() {
    setState(() {
      _showHelpFaq = true;
    });
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

  // 帮助中心FAQ Widget
  Widget _buildHelpFaqWidget() {
    return Container(
      color: const Color(0xFF0A101E),
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _showHelpFaq = false),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '常见问题',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // FAQ 列表
          _buildFaqItem('无法添加设备，怎么办？', 'imgs/faq_arrow1.svg'),
          const SizedBox(height: 12),
          _buildFaqItem('不小心删除了设备应该怎么添加回来？', 'imgs/faq_arrow2.svg'),
          const SizedBox(height: 12),
          _buildFaqItem('wifi无法连接成功是什么原因？', 'imgs/faq_arrow3.svg'),
          const SizedBox(height: 12),
          _buildFaqItem('如何更新设备固件？', 'imgs/faq_arrow4.svg'),
          const SizedBox(height: 12),
          _buildFaqItem('设备定位不准确怎么解决？', 'imgs/faq_arrow5.svg'),
          const Spacer(),
          // 人工客服按钮
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 32),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      '人工客服',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String title, String iconPath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                height: 1.43,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ),
          SvgPicture.asset(iconPath, width: 16, height: 16),
        ],
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
