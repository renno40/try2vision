import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemePreference();
    notifyListeners();
  }

  void _saveThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Settings App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF2196F3),
          secondary: const Color(0xFF64B5F6),
          background: Colors.white,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF64B5F6),
          foregroundColor: Colors.white,
        ),
        cardColor: const Color(0xFF1E1E1E),
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool receiveAppUpdates = true;
  bool receiveNewsletter = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 240,
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF64B5F6), Color(0xFF1E88E5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: -40,
                child: _buildGradientBubble(160, [Color(0xFF42A5F5), Color(0xFF64B5F6)]),
              ),
              Positioned(
                top: 20,
                right: -30,
                child: _buildGradientBubble(160, [Color(0xFF1E88E5), Color(0xFF64B5F6)]),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 120),
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: size.height * 0.02),
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 24),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage('https://placehold.co/100x100'),
                radius: size.width * 0.1,
              ),
              title: Text(
                'Sarah Abs',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.width * 0.06),
              ),
              subtitle: Text(
                '+1 90211 44 44',
                style: TextStyle(fontSize: size.width * 0.045),
              ),
              trailing: Icon(Icons.chevron_right, size: size.width * 0.08),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountDetailsScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                width: size.width * 0.18,
                height: size.width * 0.18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(Icons.dark_mode, color: Colors.white, size: size.width * 0.09),
              ),
              title: Text('Dark Mode', style: TextStyle(fontSize: size.width * 0.055)),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
                activeColor: const Color(0xFF2196F3),
              ),
            ),
            ListTile(
              leading: Icon(Icons.language, color: Theme.of(context).primaryColor),
              title: Text('Language', style: TextStyle(fontSize: size.width * 0.055)),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.06, bottom: size.height * 0.015),
              child: Text(
                'GENERAL',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: size.width * 0.05),
              ),
            ),
            _buildSettingTile(
              context,
              icon: Icons.notifications,
              color: Colors.orange,
              title: 'Notifications',
              subtitle: 'Newsletter, App Updates',
              onTap: () => _showNotificationDialog(),
            ),
            _buildSettingTile(
              context,
              icon: Icons.logout,
              color: Colors.blue,
              title: 'Logout',
              onTap: () => _showLogoutConfirmationDialog(context),
            ),
            _buildSettingTile(
              context,
              icon: Icons.delete,
              color: Colors.red,
              title: 'Delete Account',
              onTap: () => _showDeleteAccountDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBubble(double size, List<Color> colors) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.4),
            blurRadius: 12,
            offset: Offset(4, 4),
          )
        ],
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, {required IconData icon, required Color color, required String title, String? subtitle, required VoidCallback onTap}) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.012),
      child: ListTile(
        leading: Container(
          width: size.width * 0.18,
          height: size.width * 0.18,
          decoration: BoxDecoration(
            color: color.withAlpha(50),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(icon, color: color, size: size.width * 0.09),
        ),
        title: Text(title, style: TextStyle(fontSize: size.width * 0.055)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: size.width * 0.045)) : null,
        trailing: Icon(Icons.chevron_right, size: size.width * 0.08),
        onTap: onTap,
        tileColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Notification Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('App Updates'),
                    value: receiveAppUpdates,
                    onChanged: (bool value) => setState(() => receiveAppUpdates = value),
                  ),
                  SwitchListTile(
                    title: const Text('Newsletter'),
                    value: receiveNewsletter,
                    onChanged: (bool value) => setState(() => receiveNewsletter = value),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Save')),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({Key? key}) : super(key: key);

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  bool _obscurePassword = true;

  void _authenticateBeforeChange(String action) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController passwordController = TextEditingController();
        return AlertDialog(
          title: Text('Authenticate to $action'),
          content: TextField(
            controller: passwordController,
            decoration: InputDecoration(labelText: 'Enter your current password'),
            obscureText: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$action successful')),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text("Account Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailField(context, 'Email', 'sarah@example.com', showChange: true),
            _buildDetailField(context, 'Phone Number', '+1 90211 44 44', showChange: true),
            _buildDetailField(context, 'Password', _obscurePassword ? '••••••••' : 'mypassword123', showEye: true, showChange: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(BuildContext context, String label, String value, {bool showEye = false, bool showChange = false}) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: size.width * 0.045, color: Colors.grey)),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: TextStyle(fontSize: size.width * 0.055, fontWeight: FontWeight.bold)),
              if (showEye)
                IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
            ],
          ),
          if (showChange)
            TextButton(
              onPressed: () => _authenticateBeforeChange('Change $label'),
              child: Text('Change ${label.toLowerCase()}', style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );
  }
}
