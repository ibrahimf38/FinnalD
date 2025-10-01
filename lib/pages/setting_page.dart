// import 'package:flutter/material.dart';

// class SettingsPage extends StatefulWidget {
//   const SettingsPage({super.key});

//   @override
//   State<SettingsPage> createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<SettingsPage> {
//   bool _darkMode = false;
//   String _selectedLanguage = 'Français';
//   final List<String> _languages = ['Français', 'English', 'Bambara'];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Paramètres"),
//         backgroundColor: Colors.green.shade700,
//         elevation: 0,
//         centerTitle: true,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
//         ),
//       ),
//       body: Column(
//         children: [
//           // Header avec illustration
//           Container(
//             height: 150,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(30),
//                 bottomRight: Radius.circular(30),
//               ),
//             ),
//             child: Center(
//               child: Image.asset(
//                 'assets/images/images.png',
//                 height: 120,
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),

//           Expanded(
//             child: ListView(
//               physics: const BouncingScrollPhysics(),
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               children: [
//                 // Section Apparence
//                 _buildSectionHeader("Apparence"),
//                 _buildSettingItem(
//                   icon: Icons.dark_mode,
//                   title: "Mode sombre",
//                   trailing: Switch.adaptive(
//                     value: _darkMode,
//                     activeColor: Colors.green.shade700,
//                     onChanged: (value) {
//                       setState(() {
//                         _darkMode = value;
//                         // Ici vous pourriez implémenter le changement de thème
//                       });
//                       _showSnackbar(
//                         "Mode sombre ${value ? 'activé' : 'désactivé'}",
//                         Colors.green.shade700,
//                       );
//                     },
//                   ),
//                 ),
//                 const Divider(height: 1),

//                 // Section Langue
//                 _buildSectionHeader("Langue"),
//                 _buildSettingItem(
//                   icon: Icons.language,
//                   title: "Langue",
//                   subtitle: _selectedLanguage,
//                   trailing: const Icon(Icons.chevron_right),
//                   onTap: () => _showLanguageDialog(context),
//                 ),
//                 const Divider(height: 1),

//                 // Section A propos
//                 _buildSectionHeader("Aide & informations"),
//                 _buildSettingItem(
//                   icon: Icons.info_outline,
//                   title: "À propos",
//                   onTap: () => _showAboutDialog(context),
//                 ),
//                 const Divider(height: 1),
//                 _buildSettingItem(
//                   icon: Icons.help_outline,
//                   title: "Aide & support",
//                   onTap: () {},
//                 ),
//                 const Divider(height: 1),
//                 _buildSettingItem(
//                   icon: Icons.star_outline,
//                   title: "Noter l'application",
//                   onTap: () {},
//                 ),

//                 // Bouton de déconnexion
//                 const SizedBox(height: 40),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 40),
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.exit_to_app),
//                     label: const Text("Déconnexion"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red.shade50,
//                       foregroundColor: Colors.red,
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                         side: BorderSide(color: Colors.red.shade200),
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                     ),
//                     onPressed: () {
//                       // Implémentez la déconnexion ici
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 25, bottom: 10, left: 5),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: Colors.grey.shade600,
//         ),
//       ),
//     );
//   }

//   Widget _buildSettingItem({
//     required IconData icon,
//     required String title,
//     String? subtitle,
//     Widget? trailing,
//     VoidCallback? onTap,
//   }) {
//     return ListTile(
//       leading: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: Colors.green.shade100,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Icon(icon, color: Colors.green.shade700),
//       ),
//       title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
//       subtitle: subtitle != null ? Text(subtitle) : null,
//       trailing: trailing,
//       onTap: onTap,
//       contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//       minVerticalPadding: 0,
//     );
//   }

//   void _showAboutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text("À propos"),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "MaliDiscover\nVersion 1.0.0",
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   "Découvrez les merveilles du Mali avec notre application.sentez le Mali comme jamais auparavant !MaliDiscover est une application conçue pour les voyageurs, les curieux et les amoureux de la culture malienne. Que vous soyez un touriste en quête d’aventures ou un local désireux de (re)découvrir votre pays, MaliDiscover vous guide à travers les trésors cachés et les incontournables du Mali.",
//                   style: TextStyle(color: Colors.grey.shade600),
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text("Fermer"),
//               ),
//             ],
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//           ),
//     );
//   }

//   void _showLanguageDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text("Choisir la langue"),
//             content: SizedBox(
//               width: double.maxFinite,
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _languages.length,
//                 itemBuilder: (context, index) {
//                   final language = _languages[index];
//                   return RadioListTile(
//                     title: Text(language),
//                     value: language,
//                     groupValue: _selectedLanguage,
//                     onChanged: (value) {
//                       setState(() => _selectedLanguage = value.toString());
//                       Navigator.pop(context);
//                       _showSnackbar(
//                         "Langue changée: $value",
//                         Colors.green.shade700,
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//           ),
//     );
//   }

//   void _showSnackbar(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  String _selectedLanguage = 'Français';
  final List<String> _languages = ['Français', 'English', 'Bambara'];

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _changeTheme(bool darkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', darkMode);
    setState(() {
      _darkMode = darkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: Column(
        children: [
          // Header avec illustration
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/images.png',
                height: 120,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Section Apparence
                _buildSectionHeader("Apparence", theme),
                _buildSettingItem(
                  icon: Icons.dark_mode,
                  title: "Mode sombre",
                  trailing: Switch.adaptive(
                    value: _darkMode,
                    activeColor: Colors.green.shade700,
                    onChanged: (value) {
                      _changeTheme(value);
                      _showSnackbar(
                        "Mode sombre ${value ? 'activé' : 'désactivé'}",
                        Colors.green.shade700,
                      );
                    },
                  ),
                  theme: theme,
                ),
                const Divider(height: 1),

                // Section Langue
                _buildSectionHeader("Langue", theme),
                _buildSettingItem(
                  icon: Icons.language,
                  title: "Langue",
                  subtitle: _selectedLanguage,
                  trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color),
                  onTap: () => _showLanguageDialog(context),
                  theme: theme,
                ),
                const Divider(height: 1),

                // Section A propos
                _buildSectionHeader("Aide & informations", theme),
                _buildSettingItem(
                  icon: Icons.info_outline,
                  title: "À propos",
                  onTap: () => _showAboutDialog(context),
                  theme: theme,
                ),
                const Divider(height: 1),
                _buildSettingItem(
                  icon: Icons.help_outline,
                  title: "Aide & support",
                  onTap: () {},
                  theme: theme,
                ),
                const Divider(height: 1),
                _buildSettingItem(
                  icon: Icons.star_outline,
                  title: "Noter l'application",
                  onTap: () {},
                  theme: theme,
                ),

                // Bouton de déconnexion
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text("Déconnexion"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: theme.colorScheme.error),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      // Implémentez la déconnexion ici
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 10, left: 5),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    required ThemeData theme,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(title, style: theme.textTheme.bodyMedium),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      minVerticalPadding: 0,
    );
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("À propos"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "MaliDiscover\nVersion 1.0.0",
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Text(
              "Découvrez les merveilles du Mali avec notre application. "
              "MaliDiscover est une application conçue pour les voyageurs, "
              "les curieux et les amoureux de la culture malienne.",
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: theme.dialogBackgroundColor,
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choisir la langue"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final language = _languages[index];
              return RadioListTile(
                title: Text(language),
                value: language,
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() => _selectedLanguage = value.toString());
                  Navigator.pop(context);
                  _showSnackbar(
                    "Langue changée: $value",
                    Colors.green.shade700,
                  );
                },
              );
            },
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: theme.dialogBackgroundColor,
      ),
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}