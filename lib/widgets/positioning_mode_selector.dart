import 'package:flutter/material.dart';

import '../common/Global.dart';

/// 定位模式类型
enum PositioningMode { normal, powerSaving, superPowerSaving }

/// 定位模式选项
class ModeOption {
  final PositioningMode id;
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String description;

  const ModeOption({
    required this.id,
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.description,
  });
}

/// 定位模式选择器组件
class PositioningModeSelector extends StatefulWidget {
  final PositioningMode initialMode;
  final Function(PositioningMode)? onModeChanged;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const PositioningModeSelector({
    super.key,
    this.initialMode = PositioningMode.normal,
    this.onModeChanged,
    this.onCancel,
    this.onConfirm,
  });

  @override
  State<PositioningModeSelector> createState() =>
      _PositioningModeSelectorState();
}

class _PositioningModeSelectorState extends State<PositioningModeSelector> {
  late PositioningMode _selectedMode;

  /// 定位模式选项列表
  static const List<ModeOption> _modes = [
    ModeOption(
      id: PositioningMode.normal,
      icon: Icons.grid_3x3,
      iconBgColor: Color(0xFF22C55E), // green-500
      title: '常用模式',
      description: '经常使用',
    ),
    ModeOption(
      id: PositioningMode.powerSaving,
      icon: Icons.add_box_outlined,
      iconBgColor: Color(0xFF3B82F6), // blue-500
      title: '省电模式',
      description: '省电省电省电',
    ),
    ModeOption(
      id: PositioningMode.superPowerSaving,
      icon: Icons.battery_charging_full,
      iconBgColor: Color(0xFFEF4444), // red-500
      title: '超级省电模式',
      description: '待机待机待机',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Global.currentTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 模式选择列表
            _buildModeList(),

            // 按钮区域
            _buildButtonRow(),
          ],
        ),
      ),
    );
  }

  /// 构建模式选择列表
  Widget _buildModeList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children:
            _modes.asMap().entries.map((entry) {
              final index = entry.key;
              final mode = entry.value;
              final isLast = index == _modes.length - 1;

              return Column(
                children: [
                  _buildModeItem(mode),
                  if (!isLast)
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: const Color(0xFFF1F5F9), // slate-100
                    ),
                ],
              );
            }).toList(),
      ),
    );
  }

  /// 构建单个模式选项
  Widget _buildModeItem(ModeOption mode) {
    final isSelected = _selectedMode == mode.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode.id;
        });
        widget.onModeChanged?.call(mode.id);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color:
              isSelected
                  ? Global.currentTheme.primaryColor.withOpacity(0.05)
                  : Colors.transparent,
        ),
        child: Row(
          children: [
            // 图标容器
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: mode.iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(mode.icon, size: 28, color: Colors.white),
            ),

            const SizedBox(width: 16),

            // 文本信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Global.currentTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Global.currentTextColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // 选择指示器
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected
                          ? Global.currentTheme.primaryColor
                          : Colors.grey.shade300,
                  width: 2,
                ),
                color:
                    isSelected
                        ? Global.currentTheme.primaryColor
                        : Colors.transparent,
              ),
              child:
                  isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建按钮行
  Widget _buildButtonRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Spacer(),

          // 取消按钮
          TextButton(
            onPressed: widget.onCancel,
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '取消',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),

          const SizedBox(width: 12),

          // 确定按钮
          ElevatedButton(
            onPressed: widget.onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Global.currentTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              '确定',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
