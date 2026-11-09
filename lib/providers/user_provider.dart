import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider extends InheritedWidget {
  final User user;
  final Function(User) updateUser;
  final VoidCallback logout;
  final bool isLoading;
  
  // Latihan 1: Dark Mode
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  // Latihan 2: Counter Kunjungan
  final int visitCount;

  // Latihan 3: Daftar Favorit
  final List<String> favorites;
  final Function(String) addFavorite;
  final Function(int) removeFavorite;

  const UserProvider({
    super.key,
    required this.user,
    required this.updateUser,
    required this.logout,
    required this.isLoading,
    required this.isDarkMode,
    required this.toggleTheme,
    required this.visitCount,
    required this.favorites,
    required this.addFavorite,
    required this.removeFavorite,
    required super.child,
  });

  static UserProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<UserProvider>();
    assert(provider != null, 'UserProvider tidak ditemukan di context');
    return provider!;
  }

  @override
  bool updateShouldNotify(UserProvider oldWidget) {
    return oldWidget.user != user ||
        oldWidget.isLoading != isLoading ||
        oldWidget.isDarkMode != isDarkMode ||
        oldWidget.visitCount != visitCount ||
        oldWidget.favorites != favorites;
  }
}

class UserProviderWrapper extends StatefulWidget {
  final Widget child;
  const UserProviderWrapper({super.key, required this.child});

  @override
  State<UserProviderWrapper> createState() => _UserProviderWrapperState();
}

class _UserProviderWrapperState extends State<UserProviderWrapper> {
  User _user = User(name: '', email: '');
  bool _isLoading = true;
  bool _isDarkMode = false;
  int _visitCount = 0;
  List<String> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    final email = prefs.getString('user_email') ?? '';
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    // Latihan 1: Load Dark Mode
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;

    // Latihan 2: Counter Kunjungan
    int visits = prefs.getInt('visit_count') ?? 0;
    visits++;
    await prefs.setInt('visit_count', visits);
    _visitCount = visits;

    // Latihan 3: Load List Favorit
    _favorites = prefs.getStringList('favorites') ?? [];

    setState(() {
      _user = User(name: name, email: email, isLoggedIn: isLoggedIn);
      _isLoading = false;
    });
  }

  Future<void> _updateUser(User newUser) async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newUser.name);
    await prefs.setString('user_email', newUser.email);
    await prefs.setBool('is_logged_in', newUser.isLoggedIn);
    setState(() {
      _user = newUser;
      _isLoading = false;
    });
  }

  // Latihan 1: Toggle Tema
  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('is_dark_mode', _isDarkMode);
  }

  // Latihan 3: Tambah Favorit
  Future<void> _addFavorite(String hobby) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites.add(hobby);
    });
    await prefs.setStringList('favorites', _favorites);
  }

  // Latihan 3: Hapus Favorit
  Future<void> _removeFavorite(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites.removeAt(index);
    });
    await prefs.setStringList('favorites', _favorites);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.setBool('is_logged_in', false);
    setState(() {
      _user = _user.copyWith(name: '', isLoggedIn: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return UserProvider(
      user: _user,
      updateUser: _updateUser,
      logout: _logout,
      isLoading: _isLoading,
      isDarkMode: _isDarkMode,
      toggleTheme: _toggleTheme,
      visitCount: _visitCount,
      favorites: _favorites,
      addFavorite: _addFavorite,
      removeFavorite: _removeFavorite,
      child: widget.child,
    );
  }
}