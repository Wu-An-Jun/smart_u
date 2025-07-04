import 'package:flutter/foundation.dart';

/// 用户状态管理类
/// 负责管理用户的基本信息、登录状态等跨组件共享的状态
class UserState extends ChangeNotifier {
  static final UserState _instance = UserState._internal();
  factory UserState() => _instance;
  UserState._internal();

  // 用户基本信息
  Map<String, dynamic> _userInfo = {
    'name': ' Blue',
    'avatar': '',
    'phone': '18866669999',
    'email': 'user@example.com',
    'level': 'VIP',
    'joinDate': '2024-01-15',
  };

  // 登录状态
  bool _isLoggedIn = false;
  
  // 加载状态
  bool _isLoading = false;

  // Getters
  Map<String, dynamic> get userInfo => Map.from(_userInfo);
  String get userName => _userInfo['name'] ?? '';
  String get userAvatar => _userInfo['avatar'] ?? '';
  String get userPhone => _userInfo['phone'] ?? '';
  String get userEmail => _userInfo['email'] ?? '';
  String get userLevel => _userInfo['level'] ?? '';
  String get joinDate => _userInfo['joinDate'] ?? '';
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  /// 更新用户信息
  void updateUserInfo(Map<String, dynamic> newInfo) {
    _userInfo = {..._userInfo, ...newInfo};
    notifyListeners();
  }

  /// 更新用户头像
  void updateAvatar(String avatarPath) {
    _userInfo['avatar'] = avatarPath;
    notifyListeners();
  }

  /// 更新用户昵称
  void updateUserName(String name) {
    _userInfo['name'] = name;
    notifyListeners();
  }

  /// 设置登录状态
  void setLoginStatus(bool status) {
    _isLoggedIn = status;
    notifyListeners();
  }

  /// 设置加载状态
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 用户登录
  Future<bool> login(String phone, String code) async {
    setLoading(true);
    try {
      // TODO: 实际的登录API调用
      await Future.delayed(const Duration(seconds: 1));
      
      setLoginStatus(true);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      return false;
    }
  }

  /// 用户登出
  void logout() {
    setLoginStatus(false);
    // 清除用户信息
    _userInfo = {
      'name': '',
      'avatar': '',
      'phone': '',
      'email': '',
      'level': '',
      'joinDate': '',
    };
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    _userInfo = {
      'name': ' Blue',
      'avatar': '',
      'phone': '18866669999',
      'email': 'user@example.com',
      'level': 'VIP',
      'joinDate': '2024-01-15',
    };
    _isLoggedIn = false;
    _isLoading = false;
    notifyListeners();
  }
} 