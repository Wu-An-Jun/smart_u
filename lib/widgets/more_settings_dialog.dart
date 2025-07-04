import 'package:flutter/material.dart';

/// 更多设置弹窗组件
class MoreSettingsDialog extends StatelessWidget {
  final VoidCallback? onOneKeyRestart;
  final VoidCallback? onRemoteWakeup;
  final VoidCallback? onFactoryReset;

  const MoreSettingsDialog({
    super.key,
    this.onOneKeyRestart,
    this.onRemoteWakeup,
    this.onFactoryReset,
  });

  /// 显示更多设置弹窗的静态方法
  static void show(
    BuildContext context, {
    VoidCallback? onOneKeyRestart,
    VoidCallback? onRemoteWakeup,
    VoidCallback? onFactoryReset,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return MoreSettingsDialog(
          onOneKeyRestart: onOneKeyRestart,
          onRemoteWakeup: onRemoteWakeup,
          onFactoryReset: onFactoryReset,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              _buildHeader(context),

              // 内容区域
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: _buildActionButtons(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建标题栏
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '更多设置',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                // 黑色
                color: Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮区域
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context: context,
          icon: Icons.restart_alt,
          label: '一键重启',
          backgroundColor: Colors.grey.shade800,
          iconColor: Colors.white,
          onTap: () {
            Navigator.of(context).pop();
            onOneKeyRestart?.call();
          },
        ),
        _buildActionButton(
          context: context,
          icon: Icons.notifications,
          label: '远程唤醒',
          backgroundColor: Colors.red.shade500,
          iconColor: Colors.white,
          onTap: () {
            Navigator.of(context).pop();
            onRemoteWakeup?.call();
          },
        ),
        _buildActionButton(
          context: context,
          icon: Icons.refresh,
          label: '恢复出厂设置',
          backgroundColor: Colors.blue.shade100,
          iconColor: Colors.blue.shade500,
          onTap: () {
            Navigator.of(context).pop();
            _showFactoryResetConfirm(context);
          },
        ),
      ],
    );
  }

  /// 构建单个操作按钮
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 32, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 显示恢复出厂设置确认对话框
  void _showFactoryResetConfirm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade500, size: 24),
              const SizedBox(width: 8),
              const Text(
                '警告',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            '恢复出厂设置将清除所有用户数据和设置，此操作不可撤销。确定要继续吗？',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '取消',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onFactoryReset?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '确定恢复',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }
}
