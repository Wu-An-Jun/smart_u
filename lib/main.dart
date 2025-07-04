import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_rec/routes/app_pages.dart';
import 'package:test_rec/routes/app_routes.dart';
import 'package:test_rec/controllers/device_controller.dart';
import 'package:test_rec/common/Global.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化全局状态
  await Global.initialize();
  
  // 注册依赖
  _initDependencies();
  
  runApp(const MyApp());
}

/// 初始化依赖
void _initDependencies() {
  // 注册设备控制器
  Get.lazyPut<DeviceController>(() => DeviceController());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Global.appState,
      builder: (context, child) {
        return GetMaterialApp(
          title: '智能管家',
          initialRoute: AppRoutes.login,
          getPages: AppPages.routes,
          theme: Global.currentThemeData,
          darkTheme: Global.currentThemeData,
          themeMode: Global.appState.themeMode,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
