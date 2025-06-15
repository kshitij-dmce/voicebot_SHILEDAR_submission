// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../core/theme/app_theme.dart';
// import '../services/tts_service.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool _darkMode = false;
//   bool _textToSpeechEnabled = true;
//   double _speechRate = 0.5;
//   double _speechPitch = 1.0;
//   String _selectedLanguage = 'English';
//   String _selectedVoice = 'Default';
//   String _appVersion = '1.0.0';
//   bool _isTesting = false;
//   bool _saveHistory = true;
  
//   final List<String> _availableVoices = ['Default', 'Male', 'Female', 'Premium'];
//   final List<String> _languages = ['English', 'हिंदी (Hindi)', 'मराठी (Marathi)'];
  
//   @override
//   void initState() {
//     super.initState();
//     _loadSettings();
//     _loadAppInfo();
//   }

//   Future<void> _loadAppInfo() async {
//     try {
//       final packageInfo = await PackageInfo.fromPlatform();
//       setState(() {
//         _appVersion = packageInfo.version;
//       });
//     } catch (e) {
//       // Fallback to default version
//     }
//   }

//   Future<void> _loadSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _darkMode = prefs.getBool('darkMode') ?? false;
//       _speechRate = prefs.getDouble('speechRate') ?? 0.5;
//       _speechPitch = prefs.getDouble('speechPitch') ?? 1.0;
//       _selectedVoice = prefs.getString('selectedVoice') ?? 'Default';
//       _textToSpeechEnabled = prefs.getBool('textToSpeechEnabled') ?? true;
//       _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
//       _saveHistory = prefs.getBool('saveHistory') ?? true;
//     });
//   }

//   Future<void> _saveSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('darkMode', _darkMode);
//     await prefs.setDouble('speechRate', _speechRate);
//     await prefs.setDouble('speechPitch', _speechPitch);
//     await prefs.setString('selectedVoice', _selectedVoice);
//     await prefs.setBool('textToSpeechEnabled', _textToSpeechEnabled);
//     await prefs.setString('selectedLanguage', _selectedLanguage);
//     await prefs.setBool('saveHistory', _saveHistory);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ttsService = Provider.of<TTSService>(context, listen: false);
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
    
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(60.h),
//         child: ClipRRect(
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//             child: AppBar(
//               backgroundColor: isDark 
//                   ? Colors.black.withOpacity(0.2) 
//                   : Colors.white.withOpacity(0.2),
//               elevation: 0,
//               centerTitle: true,
//               title: Text(
//                 'Settings',
//                 style: GoogleFonts.poppins(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.w600,
//                   color: isDark ? Colors.white : AppTheme.primaryColor,
//                 ),
//               ),
//               leading: IconButton(
//                 icon: Icon(
//                   Icons.arrow_back_ios_rounded,
//                   size: 20.sp,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: isDark
//                 ? [
//                   const Color(0xFF121212),
//                   const Color(0xFF1E1E3A),
//                   const Color(0xFF262650),
//                 ]
//                 : [
//                   const Color(0xFFF0F4FF),
//                   const Color(0xFFE6EDFF),
//                   const Color(0xFFD8E5FF),
//                 ],
//           ),
//         ),
//         child: SafeArea(
//           child: ListView(
//             padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
//             children: [
//               // General Settings Section
//               _buildSectionHeader('General Settings', Icons.settings_outlined),
//               SizedBox(height: 12.h),
//               _buildSettingsCard(
//                 child: Column(
//                   children: [
//                     _buildSwitchTile(
//                       title: 'Dark Mode',
//                       subtitle: 'Use dark theme',
//                       value: _darkMode,
//                       onChanged: (value) {
//                         setState(() {
//                           _darkMode = value;
//                         });
//                         _saveSettings();
//                       },
//                       icon: Icons.dark_mode_outlined,
//                     ),
//                     _buildDivider(),
//                     _buildDropdownTile(
//                       title: 'Language',
//                       value: _selectedLanguage,
//                       items: _languages,
//                       icon: Icons.language,
//                       onChanged: (value) {
//                         if (value != null) {
//                           setState(() {
//                             _selectedLanguage = value;
//                           });
//                           _saveSettings();
//                         }
//                       },
//                     ),
//                     _buildDivider(),
//                     _buildSwitchTile(
//                       title: 'Save Conversation History',
//                       subtitle: 'Store past conversations',
//                       value: _saveHistory,
//                       onChanged: (value) {
//                         setState(() {
//                           _saveHistory = value;
//                         });
//                         _saveSettings();
//                       },
//                       icon: Icons.history,
//                     ),
//                   ],
//                 ),
//               ),
              
//               SizedBox(height: 24.h),
              
//               // Voice Settings Section
//               _buildSectionHeader('Voice Settings', Icons.record_voice_over_outlined),
//               SizedBox(height: 12.h),
//               _buildSettingsCard(
//                 child: Column(
//                   children: [
//                     _buildSwitchTile(
//                       title: 'Text-to-Speech',
//                       subtitle: 'Read responses aloud',
//                       value: _textToSpeechEnabled,
//                       onChanged: (value) {
//                         setState(() {
//                           _textToSpeechEnabled = value;
//                         });
//                         _saveSettings();
//                       },
//                       icon: Icons.volume_up_outlined,
//                     ),
//                     _buildDivider(),
//                     _buildDropdownTile(
//                       title: 'Voice Type',
//                       value: _selectedVoice,
//                       items: _availableVoices,
//                       icon: Icons.record_voice_over_outlined,
//                       onChanged: _textToSpeechEnabled ? (value) {
//                         if (value != null) {
//                           setState(() {
//                             _selectedVoice = value;
//                           });
//                           ttsService.setVoice(_selectedVoice.toLowerCase());
//                           _saveSettings();
//                         }
//                       } : null,
//                     ),
//                     _buildDivider(),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.speed,
//                                 color: _textToSpeechEnabled
//                                   ? (isDark ? Colors.white70 : AppTheme.primaryColor)
//                                   : Colors.grey,
//                                 size: 20.sp,
//                               ),
//                               SizedBox(width: 12.w),
//                               Text(
//                                 'Speech Rate',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 16.sp,
//                                   color: _textToSpeechEnabled
//                                     ? (isDark ? Colors.white : Colors.black87)
//                                     : Colors.grey,
//                                 ),
//                               ),
//                               const Spacer(),
//                               Text(
//                                 _speechRate.toStringAsFixed(1),
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14.sp,
//                                   color: _textToSpeechEnabled
//                                     ? (isDark ? Colors.white70 : AppTheme.primaryColor)
//                                     : Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 8.h),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.slow_motion_video_rounded,
//                                 color: isDark ? Colors.white30 : Colors.black26,
//                                 size: 16.sp,
//                               ),
//                               SizedBox(width: 8.w),
//                               Expanded(
//                                 child: SliderTheme(
//                                   data: SliderThemeData(
//                                     trackHeight: 4.h,
//                                     activeTrackColor: _textToSpeechEnabled
//                                       ? AppTheme.primaryColor
//                                       : Colors.grey,
//                                     inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
//                                     thumbColor: _textToSpeechEnabled
//                                       ? AppTheme.primaryColor
//                                       : Colors.grey,
//                                     thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
//                                     overlayColor: AppTheme.primaryColor.withOpacity(0.2),
//                                     overlayShape: RoundSliderOverlayShape(overlayRadius: 16.r),
//                                   ),
//                                   child: Slider(
//                                     value: _speechRate,
//                                     min: 0.0,
//                                     max: 1.0,
//                                     divisions: 10,
//                                     onChanged: _textToSpeechEnabled
//                                       ? (value) {
//                                           setState(() {
//                                             _speechRate = value;
//                                           });
//                                           ttsService.setRate(_speechRate);
//                                           _saveSettings();
//                                         }
//                                       : null,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 8.w),
//                               Icon(
//                                 Icons.fast_forward_rounded,
//                                 color: isDark ? Colors.white30 : Colors.black26,
//                                 size: 16.sp,
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     _buildDivider(),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.graphic_eq_rounded,
//                                 color: _textToSpeechEnabled
//                                   ? (isDark ? Colors.white70 : AppTheme.primaryColor)
//                                   : Colors.grey,
//                                 size: 20.sp,
//                               ),
//                               SizedBox(width: 12.w),
//                               Text(
//                                 'Speech Pitch',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 16.sp,
//                                   color: _textToSpeechEnabled
//                                     ? (isDark ? Colors.white : Colors.black87)
//                                     : Colors.grey,
//                                 ),
//                               ),
//                               const Spacer(),
//                               Text(
//                                 _speechPitch.toStringAsFixed(1),
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14.sp,
//                                   color: _textToSpeechEnabled
//                                     ? (isDark ? Colors.white70 : AppTheme.primaryColor)
//                                     : Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 8.h),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.arrow_downward_rounded,
//                                 color: isDark ? Colors.white30 : Colors.black26,
//                                 size: 16.sp,
//                               ),
//                               SizedBox(width: 8.w),
//                               Expanded(
//                                 child: SliderTheme(
//                                   data: SliderThemeData(
//                                     trackHeight: 4.h,
//                                     activeTrackColor: _textToSpeechEnabled
//                                       ? AppTheme.accentColor
//                                       : Colors.grey,
//                                     inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
//                                     thumbColor: _textToSpeechEnabled
//                                       ? AppTheme.accentColor
//                                       : Colors.grey,
//                                     thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
//                                     overlayColor: AppTheme.accentColor.withOpacity(0.2),
//                                     overlayShape: RoundSliderOverlayShape(overlayRadius: 16.r),
//                                   ),
//                                   child: Slider(
//                                     value: _speechPitch,
//                                     min: 0.5,
//                                     max: 2.0,
//                                     divisions: 15,
//                                     onChanged: _textToSpeechEnabled
//                                       ? (value) {
//                                           setState(() {
//                                             _speechPitch = value;
//                                           });
//                                           ttsService.setPitch(_speechPitch);
//                                           _saveSettings();
//                                         }
//                                       : null,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 8.w),
//                               Icon(
//                                 Icons.arrow_upward_rounded,
//                                 color: isDark ? Colors.white30 : Colors.black26,
//                                 size: 16.sp,
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 8.h),
//                     Center(
//                       child: ElevatedButton.icon(
//                         onPressed: _textToSpeechEnabled
//                           ? () {
//                               setState(() {
//                                 _isTesting = true;
//                               });
//                               ttsService.speak('This is a test of the speech settings with VoxGenie.')
//                                 .then((_) {
//                                   setState(() {
//                                     _isTesting = false;
//                                   });
//                                 });
//                             }
//                           : null,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.primaryColor,
//                           foregroundColor: Colors.white,
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 20.w,
//                             vertical: 10.h,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                           ),
//                           disabledBackgroundColor: Colors.grey.withOpacity(0.3),
//                           disabledForegroundColor: Colors.white70,
//                         ),
//                         icon: _isTesting
//                           ? SizedBox(
//                               width: 18.sp,
//                               height: 18.sp,
//                               child: CircularProgressIndicator(
//                                 valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
//                                 strokeWidth: 2.w,
//                               ),
//                             )
//                           : Icon(
//                               Icons.play_circle_outline_rounded,
//                               size: 18.sp,
//                             ),
//                         label: Text(
//                           _isTesting ? 'Speaking...' : 'Test Speech',
//                           style: GoogleFonts.poppins(
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 8.h),
//                   ],
//                 ),
//               ),
              
//               SizedBox(height: 24.h),
              
//               // About Section
//               _buildSectionHeader('About', Icons.info_outline_rounded),
//               SizedBox(height: 12.h),
//               _buildSettingsCard(
//                 child: Column(
//                   children: [
//                     _buildInfoTile(
//                       title: 'Version',
//                       value: _appVersion,
//                       icon: Icons.android_rounded,
//                     ),
//                     _buildDivider(),
//                     _buildActionTile(
//                       title: 'Privacy Policy',
//                       icon: Icons.privacy_tip_outlined,
//                       onTap: () => _launchUrl('https://voxgenie.com/privacy'),
//                     ),
//                     _buildDivider(),
//                     _buildActionTile(
//                       title: 'Terms of Service',
//                       icon: Icons.description_outlined,
//                       onTap: () => _launchUrl('https://voxgenie.com/terms'),
//                     ),
//                     _buildDivider(),
//                     _buildActionTile(
//                       title: 'Contact Support',
//                       icon: Icons.support_agent_rounded,
//                       onTap: () => _launchUrl('mailto:support@voxgenie.com'),
//                     ),
//                     _buildDivider(),
//                     _buildActionTile(
//                       title: 'Rate App',
//                       icon: Icons.star_outline_rounded,
//                       onTap: () => _launchUrl('https://play.google.com/store/apps/details?id=com.voxgenie.app'),
//                     ),
//                     _buildDivider(),
//                     Padding(
//                       padding: EdgeInsets.all(16.r),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             padding: EdgeInsets.all(8.r),
//                             decoration: BoxDecoration(
//                               color: isDark 
//                                   ? AppTheme.primaryColor.withOpacity(0.2)
//                                   : AppTheme.primaryColor.withOpacity(0.1),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               Icons.mic,
//                               color: AppTheme.primaryColor,
//                               size: 20.sp,
//                             ),
//                           ),
//                           SizedBox(width: 8.w),
//                           Text(
//                             'VoxGenie',
//                             style: GoogleFonts.poppins(
//                               fontSize: 16.sp,
//                               fontWeight: FontWeight.w600,
//                               color: isDark ? Colors.white70 : AppTheme.primaryColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Text(
//                       'Created by Kshitij | © ${DateTime.now().year} VoxGenie Inc.',
//                       style: GoogleFonts.poppins(
//                         fontSize: 12.sp,
//                         color: isDark ? Colors.white38 : Colors.black45,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 16.h),
//                   ],
//                 ),
//               ),
              
//               SizedBox(height: 30.h),
//             ],
//           ).animate().fadeIn(duration: const Duration(milliseconds: 500)),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildSectionHeader(String title, IconData icon) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     return Row(
//       children: [
//         Icon(
//           icon,
//           color: isDark ? AppTheme.accentColor : AppTheme.primaryColor,
//           size: 20.sp,
//         ),
//         SizedBox(width: 10.w),
//         Text(
//           title,
//           style: GoogleFonts.poppins(
//             fontSize: 18.sp,
//             fontWeight: FontWeight.w600,
//             color: isDark ? Colors.white : AppTheme.primaryColor,
//           ),
//         ),
//       ],
//     ).animate()
//       .slideX(begin: -0.1, end: 0, duration: const Duration(milliseconds: 500), curve: Curves.easeOutQuint)
//       .fadeIn(duration: const Duration(milliseconds: 400));
//   }
  
//   Widget _buildSettingsCard({required Widget child}) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     return Container(
//       decoration: BoxDecoration(
//         color: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(
//           color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
//           width: 1,
//         ),
//         boxShadow: isDark 
//             ? null 
//             : [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//       ),
//       child: child,
//     ).animate()
//       .scale(
//         begin: const Offset(0.98, 0.98),
//         end: const Offset(1.0, 1.0),
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeOutQuint,
//       )
//       .fadeIn(duration: const Duration(milliseconds: 400));
//   }
  
//   Widget _buildSwitchTile({
//     required String title,
//     required String subtitle,
//     required bool value,
//     required Function(bool) onChanged,
//     required IconData icon,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(10.r),
//             decoration: BoxDecoration(
//               color: isDark
//                   ? Colors.white.withOpacity(0.05)
//                   : AppTheme.primaryColor.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//             child: Icon(
//               icon,
//               color: isDark ? Colors.white70 : AppTheme.primaryColor,
//               size: 20.sp,
//             ),
//           ),
//           SizedBox(width: 16.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16.sp,
//                     color: isDark ? Colors.white : Colors.black87,
//                   ),
//                 ),
//                 Text(
//                   subtitle,
//                   style: GoogleFonts.poppins(
//                     fontSize: 12.sp,
//                     color: isDark ? Colors.white54 : Colors.black54,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Switch(
//             value: value,
//             onChanged: onChanged,
//             activeColor: AppTheme.primaryColor,
//             activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
//             inactiveThumbColor: isDark ? Colors.white60 : Colors.grey,
//             inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildDropdownTile({
//     required String title,
//     required String value,
//     required List<String> items,
//     required IconData icon,
//     required ValueChanged<String?>? onChanged,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(10.r),
//             decoration: BoxDecoration(
//               color: isDark
//                   ? Colors.white.withOpacity(0.05)
//                   : AppTheme.primaryColor.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//             child: Icon(
//               icon,
//               color: isDark ? Colors.white70 : AppTheme.primaryColor,
//               size: 20.sp,
//             ),
//           ),
//           SizedBox(width: 16.w),
//           Expanded(
//             child: Text(
//               title,
//               style: GoogleFonts.poppins(
//                 fontSize: 16.sp,
//                 color: isDark ? Colors.white : Colors.black87,
//               ),
//             ),
//           ),
//           DropdownButton<String>(
//             value: value,
//             onChanged: onChanged,
//             underline: const SizedBox(),
//             icon: Icon(
//               Icons.arrow_drop_down,
//               color: onChanged != null
//                 ? (isDark ? Colors.white70 : Colors.black54)
//                 : Colors.grey,
//             ),
//             dropdownColor: isDark ? const Color(0xFF1E1E3A) : Colors.white,
//             borderRadius: BorderRadius.circular(12.r),
//             items: items.map((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(
//                   value,
//                   style: GoogleFonts.poppins(
//                     color: isDark ? Colors.white : Colors.black87,
//                   ),
//                 ),
//               );
//             }).toList(),
//             style: GoogleFonts.poppins(
//               fontSize: 14.sp,
//               color: isDark ? Colors.white70 : Colors.black87,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildInfoTile({
//     required String title,
//     required String value,
//     required IconData icon,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(10.r),
//             decoration: BoxDecoration(
//               color: isDark
//                   ? Colors.white.withOpacity(0.05)
//                   : AppTheme.primaryColor.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//             child: Icon(
//               icon,
//               color: isDark ? Colors.white70 : AppTheme.primaryColor,
//               size: 20.sp,
//             ),
//           ),
//           SizedBox(width: 16.w),
//           Expanded(
//             child: Text(
//               title,
//               style: GoogleFonts.poppins(
//                 fontSize: 16.sp,
//                 color: isDark ? Colors.white : Colors.black87,
//               ),
//             ),
//           ),
//           Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w500,
//               color: isDark ? Colors.white60 : Colors.black54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildActionTile({
//     required String title,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(10.r),
//               decoration: BoxDecoration(
//                 color: isDark
//                     ? Colors.white.withOpacity(0.05)
//                     : AppTheme.primaryColor.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Icon(
//                 icon,
//                 color: isDark ? Colors.white70 : AppTheme.primaryColor,
//                 size: 20.sp,
//               ),
//             ),
//             SizedBox(width: 16.w),
//             Expanded(
//               child: Text(
//                 title,
//                 style: GoogleFonts.poppins(
//                   fontSize: 16.sp,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               color: isDark ? Colors.white38 : Colors.black38,
//               size: 16.sp,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildDivider() {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     return Divider(
//       color: isDark ? Colors.white12 : Colors.black12,
//       height: 1,
//       indent: 16.w,
//       endIndent: 16.w,
//     );
//   }
  
//   Future<void> _launchUrl(String url) async {
//     try {
//       await launchUrl(Uri.parse(url));
//     } catch (e) {
//       // Handle error
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Could not launch $url')),
//         );
//       }
//     }
//   }
// }



import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_theme.dart';
import '../services/tts_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _textToSpeechEnabled = true;
  double _speechRate = 0.5;
  double _speechPitch = 1.0;
  String _selectedLanguage = 'English';
  String _selectedVoice = 'Default';
  String _appVersion = '1.0.0';
  bool _isTesting = false;
  bool _saveHistory = true;
  
  final List<String> _availableVoices = ['Default', 'Male', 'Female', 'Premium'];
  final List<String> _languages = ['English', 'हिंदी (Hindi)', 'मराठी (Marathi)'];
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
        });
      }
    } catch (e) {
      debugPrint('Error loading package info: $e');
      // Fallback to default version
    }
  }

  Future<void> _loadSettings() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _speechRate = prefs.getDouble('speechRate') ?? 0.5;
      _speechPitch = prefs.getDouble('speechPitch') ?? 1.0;
      _selectedVoice = prefs.getString('selectedVoice') ?? 'Default';
      _textToSpeechEnabled = prefs.getBool('textToSpeechEnabled') ?? true;
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
      _saveHistory = prefs.getBool('saveHistory') ?? true;
    });
    
    // Apply TTS settings
    final ttsService = Provider.of<TTSService>(context, listen: false);
    ttsService.setEnabled(_textToSpeechEnabled);
    ttsService.setRate(_speechRate);
    ttsService.setPitch(_speechPitch);
    ttsService.setVoice(_selectedVoice.toLowerCase());
    ttsService.setLanguage(_getLanguageCode(_selectedLanguage));
    
    // Apply theme settings if available
    try {
      final themeProvider = Provider.of<AppTheme>(context, listen: false);
      themeProvider.setDarkMode(_darkMode);
    } catch (e) {
      debugPrint('Unable to apply theme settings: $e');
    }
  } catch (e) {
    debugPrint('Error loading settings: $e');
  }
}


  String _getLanguageCode(String language) {
    switch (language) {
      case 'हिंदी (Hindi)':
        return 'hi-IN';
      case 'मराठी (Marathi)':
        return 'mr-IN';
      case 'English':
      default:
        return 'en-US';
    }
  }

  Future<void> _saveSettings() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setDouble('speechRate', _speechRate);
    await prefs.setDouble('speechPitch', _speechPitch);
    await prefs.setString('selectedVoice', _selectedVoice);
    await prefs.setBool('textToSpeechEnabled', _textToSpeechEnabled);
    await prefs.setString('selectedLanguage', _selectedLanguage);
    await prefs.setBool('saveHistory', _saveHistory);
    
    // Apply theme settings if available
    try {
      final themeProvider = Provider.of<AppTheme>(context, listen: false);
      themeProvider.setDarkMode(_darkMode);
    } catch (e) {
      debugPrint('Unable to apply theme settings: $e');
    }
    
    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  } catch (e) {
    debugPrint('Error saving settings: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save settings: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

  @override
Widget build(BuildContext context) {
  final ttsService = Provider.of<TTSService>(context, listen: false);
  // Handle potential AppTheme provider not found
  AppTheme? themeProvider;
  bool isDark = false;
  
  try {
    themeProvider = Provider.of<AppTheme>(context);
    isDark = themeProvider.isDarkMode;
  } catch (e) {
    debugPrint('AppTheme provider not found, using system theme');
    // Fallback to system theme
    isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
  }
  
  final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: AppBar(
              backgroundColor: isDark 
                  ? Colors.black.withOpacity(0.2) 
                  : Colors.white.withOpacity(0.2),
              elevation: 0,
              centerTitle: true,
              title: Text(
                'Settings',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.primaryColor,
                ),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 20.sp,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                  const Color(0xFF121212),
                  const Color(0xFF1E1E3A),
                  const Color(0xFF262650),
                ]
                : [
                  const Color(0xFFF0F4FF),
                  const Color(0xFFE6EDFF),
                  const Color(0xFFD8E5FF),
                ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            children: [
              // General Settings Section
              _buildSectionHeader('General Settings', Icons.settings_outlined),
              SizedBox(height: 12.h),
              _buildSettingsCard(
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title: 'Dark Mode',
                      subtitle: 'Use dark theme',
                      value: _darkMode,
                      onChanged: (value) {
                        setState(() {
                          _darkMode = value;
                        });
                        _saveSettings();
                      },
                      icon: Icons.dark_mode_outlined,
                    ),
                    _buildDivider(),
                    _buildDropdownTile(
                      title: 'Language',
                      value: _selectedLanguage,
                      items: _languages,
                      icon: Icons.language,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedLanguage = value;
                          });
                          final ttsService = Provider.of<TTSService>(context, listen: false);
                          ttsService.setLanguage(_getLanguageCode(_selectedLanguage));
                          _saveSettings();
                        }
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      title: 'Save Conversation History',
                      subtitle: 'Store past conversations',
                      value: _saveHistory,
                      onChanged: (value) {
                        setState(() {
                          _saveHistory = value;
                        });
                        _saveSettings();
                        
                        // If turning off history, offer to clear existing history
                        if (!value) {
                          _showClearHistoryDialog();
                        }
                      },
                      icon: Icons.history,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Voice Settings Section
              _buildSectionHeader('Voice Settings', Icons.record_voice_over_outlined),
              SizedBox(height: 12.h),
              _buildSettingsCard(
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title: 'Text-to-Speech',
                      subtitle: 'Read responses aloud',
                      value: _textToSpeechEnabled,
                      onChanged: (value) {
                        setState(() {
                          _textToSpeechEnabled = value;
                        });
                        ttsService.setEnabled(value);
                        _saveSettings();
                      },
                      icon: Icons.volume_up_outlined,
                    ),
                    _buildDivider(),
                    _buildDropdownTile(
                      title: 'Voice Type',
                      value: _selectedVoice,
                      items: _availableVoices,
                      icon: Icons.record_voice_over_outlined,
                      onChanged: _textToSpeechEnabled ? (value) {
                        if (value != null) {
                          setState(() {
                            _selectedVoice = value;
                          });
                          ttsService.setVoice(_selectedVoice.toLowerCase());
                          _saveSettings();
                        }
                      } : null,
                    ),
                    _buildDivider(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.speed,
                                color: _textToSpeechEnabled
                                  ? (isDark ? Colors.white70 : AppTheme.primaryColor)
                                  : Colors.grey,
                                size: 20.sp,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Speech Rate',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  color: _textToSpeechEnabled
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _speechRate.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: _textToSpeechEnabled
                                    ? (isDark ? Colors.white70 : AppTheme.primaryColor)
                                    : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(
                                Icons.slow_motion_video_rounded,
                                color: isDark ? Colors.white30 : Colors.black26,
                                size: 16.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 4.h,
                                    activeTrackColor: _textToSpeechEnabled
                                      ? AppTheme.primaryColor
                                      : Colors.grey,
                                    inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
                                    thumbColor: _textToSpeechEnabled
                                      ? AppTheme.primaryColor
                                      : Colors.grey,
                                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
                                    overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                                    overlayShape: RoundSliderOverlayShape(overlayRadius: 16.r),
                                  ),
                                  child: Slider(
                                    value: _speechRate,
                                    min: 0.0,
                                    max: 1.0,
                                    divisions: 10,
                                    onChanged: _textToSpeechEnabled
                                      ? (value) {
                                          setState(() {
                                            _speechRate = value;
                                          });
                                          ttsService.setRate(_speechRate);
                                        }
                                      : null,
                                    onChangeEnd: _textToSpeechEnabled
                                      ? (value) {
                                          _saveSettings();
                                        }
                                      : null,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.fast_forward_rounded,
                                color: isDark ? Colors.white30 : Colors.black26,
                                size: 16.sp,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.graphic_eq_rounded,
                                color: _textToSpeechEnabled
                                  ? (isDark ? Colors.white70 : AppTheme.primaryColor)
                                  : Colors.grey,
                                size: 20.sp,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Speech Pitch',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  color: _textToSpeechEnabled
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _speechPitch.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: _textToSpeechEnabled
                                    ? (isDark ? Colors.white70 : AppTheme.primaryColor)
                                    : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_downward_rounded,
                                color: isDark ? Colors.white30 : Colors.black26,
                                size: 16.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 4.h,
                                    activeTrackColor: _textToSpeechEnabled
                                      ? AppTheme.accentColor
                                      : Colors.grey,
                                    inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
                                    thumbColor: _textToSpeechEnabled
                                      ? AppTheme.accentColor
                                      : Colors.grey,
                                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
                                    overlayColor: AppTheme.accentColor.withOpacity(0.2),
                                    overlayShape: RoundSliderOverlayShape(overlayRadius: 16.r),
                                  ),
                                  child: Slider(
                                    value: _speechPitch,
                                    min: 0.5,
                                    max: 2.0,
                                    divisions: 15,
                                    onChanged: _textToSpeechEnabled
                                      ? (value) {
                                          setState(() {
                                            _speechPitch = value;
                                          });
                                          ttsService.setPitch(_speechPitch);
                                        }
                                      : null,
                                    onChangeEnd: _textToSpeechEnabled
                                      ? (value) {
                                          _saveSettings();
                                        }
                                      : null,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.arrow_upward_rounded,
                                color: isDark ? Colors.white30 : Colors.black26,
                                size: 16.sp,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _textToSpeechEnabled
                          ? () {
                              if (_isTesting) {
                                // Stop the speech if it's already playing
                                ttsService.stop();
                                setState(() {
                                  _isTesting = false;
                                });
                              } else {
                                setState(() {
                                  _isTesting = true;
                                });
                                
                                // Generate test message based on selected language
                                String testMessage;
                                switch (_selectedLanguage) {
                                  case 'हिंदी (Hindi)':
                                    testMessage = 'यह वॉक्सजीनी से वाणी सेटिंग का एक परीक्षण है।';
                                    break;
                                  case 'मराठी (Marathi)':
                                    testMessage = 'हे व्हॉक्सजीनीसह व्हॉइस सेटिंग्जची चाचणी आहे.';
                                    break;
                                  case 'English':
                                  default:
                                    testMessage = 'This is a test of the speech settings with VoxGenie.';
                                    break;
                                }
                                
                                ttsService.speak(testMessage)
                                  .then((_) {
                                    if (mounted) {
                                      setState(() {
                                        _isTesting = false;
                                      });
                                    }
                                  })
                                  .catchError((error) {
                                    debugPrint('TTS error: $error');
                                    if (mounted) {
                                      setState(() {
                                        _isTesting = false;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Speech test failed: ${error.toString()}')),
                                      );
                                    }
                                  });
                              }
                            }
                          : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isTesting ? Colors.red : AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                          disabledForegroundColor: Colors.white70,
                        ),
                        icon: _isTesting
                          ? SizedBox(
                              width: 18.sp,
                              height: 18.sp,
                              child: CircularProgressIndicator(
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2.w,
                              ),
                            )
                          : Icon(
                              _isTesting ? Icons.stop : Icons.play_circle_outline_rounded,
                              size: 18.sp,
                            ),
                        label: Text(
                          _isTesting ? 'Stop' : 'Test Speech',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // About Section
              _buildSectionHeader('About', Icons.info_outline_rounded),
              SizedBox(height: 12.h),
              _buildSettingsCard(
                child: Column(
                  children: [
                    _buildInfoTile(
                      title: 'Version',
                      value: _appVersion,
                      icon: Icons.android_rounded,
                    ),
                    _buildDivider(),
                    _buildActionTile(
                      title: 'Privacy Policy',
                      icon: Icons.privacy_tip_outlined,
                      onTap: () => _launchUrl('https://voxgenie.com/privacy'),
                    ),
                    _buildDivider(),
                    _buildActionTile(
                      title: 'Terms of Service',
                      icon: Icons.description_outlined,
                      onTap: () => _launchUrl('https://voxgenie.com/terms'),
                    ),
                    _buildDivider(),
                    _buildActionTile(
                      title: 'Contact Support',
                      icon: Icons.support_agent_rounded,
                      onTap: () => _launchUrl('mailto:support@voxgenie.com'),
                    ),
                    _buildDivider(),
                    _buildActionTile(
                      title: 'Rate App',
                      icon: Icons.star_outline_rounded,
                      onTap: () => _launchUrl('https://play.google.com/store/apps/details?id=com.voxgenie.app'),
                    ),
                    _buildDivider(),
                    _buildActionTile(
                      title: 'Reset All Settings',
                      icon: Icons.restart_alt_rounded,
                      onTap: _showResetSettingsDialog,
                    ),
                    _buildDivider(),
                    Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? AppTheme.primaryColor.withOpacity(0.2)
                                  : AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.mic,
                              color: AppTheme.primaryColor,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'VoxGenie',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Created by Kshitij | © ${DateTime.now().year} VoxGenie Inc.',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
              
              SizedBox(height: 30.h),
            ],
          ).animate().fadeIn(duration: const Duration(milliseconds: 500)),
        ),
      ),
    );
  }

  void _showClearHistoryDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E3A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Clear Conversation History?',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'You\'ve disabled conversation history. Would you like to delete all existing conversations from your device?',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.white60 : Colors.black54,
              ),
              child: Text(
                'No, keep them',
                style: GoogleFonts.poppins(),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Clear conversation history
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('conversation_history');
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Conversation history cleared'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('Error clearing history: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Yes, clear all',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showResetSettingsDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E3A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Reset All Settings?',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'This will restore all settings to their default values. This action cannot be undone.',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.white60 : Colors.black54,
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Reset all settings to defaults
                setState(() {
                  _darkMode = false;
                  _textToSpeechEnabled = true;
                  _speechRate = 0.5;
                  _speechPitch = 1.0;
                  _selectedVoice = 'Default';
                  _selectedLanguage = 'English';
                  _saveHistory = true;
                });
                
                // Apply settings
                await _saveSettings();
                final ttsService = Provider.of<TTSService>(context, listen: false);
                ttsService.setEnabled(_textToSpeechEnabled);
                ttsService.setRate(_speechRate);
                ttsService.setPitch(_speechPitch);
                ttsService.setVoice(_selectedVoice.toLowerCase());
                ttsService.setLanguage(_getLanguageCode(_selectedLanguage));
                
                // Close dialog
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All settings have been reset to defaults'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Reset',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Icon(
          icon,
          color: isDark ? AppTheme.accentColor : AppTheme.primaryColor,
          size: 20.sp,
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.primaryColor,
          ),
        ),
      ],
    ).animate()
      .slideX(begin: -0.1, end: 0, duration: const Duration(milliseconds: 500), curve: Curves.easeOutQuint)
      .fadeIn(duration: const Duration(milliseconds: 400));
  }
  
  Widget _buildSettingsCard({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: isDark 
            ? null 
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    ).animate()
      .scale(
        begin: const Offset(0.98, 0.98),
        end: const Offset(1.0, 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuint,
      )
      .fadeIn(duration: const Duration(milliseconds: 400));
  }
  
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white70 : AppTheme.primaryColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
            activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
            inactiveThumbColor: isDark ? Colors.white60 : Colors.grey,
            inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?>? onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white70 : AppTheme.primaryColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            underline: const SizedBox(),
            icon: Icon(
              Icons.arrow_drop_down,
              color: onChanged != null
                ? (isDark ? Colors.white70 : Colors.black54)
                : Colors.grey,
            ),
            dropdownColor: isDark ? const Color(0xFF1E1E3A) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              );
            }).toList(),
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: isDark ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white70 : AppTheme.primaryColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      splashColor: isDark
          ? AppTheme.primaryColor.withOpacity(0.1)
          : AppTheme.primaryColor.withOpacity(0.05),
      highlightColor: isDark
          ? AppTheme.primaryColor.withOpacity(0.05)
          : AppTheme.primaryColor.withOpacity(0.03),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: title == 'Reset All Settings' 
                    ? Colors.redAccent 
                    : (isDark ? Colors.white70 : AppTheme.primaryColor),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: title == 'Reset All Settings'
                      ? Colors.redAccent
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDark ? Colors.white38 : Colors.black38,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Divider(
      color: isDark ? Colors.white12 : Colors.black12,
      height: 1,
      indent: 16.w,
      endIndent: 16.w,
    );
  }
  
  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('URL launch error: $e');
      // Handle error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}