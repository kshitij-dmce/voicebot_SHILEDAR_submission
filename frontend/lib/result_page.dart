import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class ResultPage extends StatefulWidget {
  final Map<String, dynamic> response;
  
  const ResultPage({
    Key? key,
    required this.response,
  }) : super(key: key);
  
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _isCopied = false;
  bool _isLiked = false;
  bool _isDisliked = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Extract relevant information from the response
    final String question = widget.response['query'] ?? '';
    final String answer = widget.response['answer'] ?? '';
    final String category = widget.response['category'] ?? '';
    final String language = widget.response['language'] ?? 'en';
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Response',
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.copy_rounded,
              color: _isCopied 
                ? AppTheme.accentColor
                : isDark ? Colors.white70 : Colors.black54,
              size: 22.sp,
            ),
            onPressed: () => _copyToClipboard(context, answer),
            tooltip: 'Copy answer',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Question',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      question,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    if (category.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          category,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // Answer section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCardColor : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: isDark 
                    ? [] 
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lightbulb_outline_rounded,
                            color: AppTheme.accentColor,
                            size: 16.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Answer',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.green.withOpacity(0.2)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.green,
                                size: 14.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Verified',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      answer,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        height: 1.6,
                        color: isDark ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.8),
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Answer metadata
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isDark 
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Generated on:',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '2025-06-14 06:30:49',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: _getLanguageColor(language).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              _getLanguageText(language),
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: _getLanguageColor(language),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Feedback section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Was this answer helpful?',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFeedbackButton(
                          context, 
                          'Yes',
                          Icons.thumb_up_alt_rounded,
                          true,
                        ),
                        SizedBox(width: 16.w),
                        _buildFeedbackButton(
                          context, 
                          'No',
                          Icons.thumb_down_alt_rounded,
                          false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Source references
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCardColor.withOpacity(0.5) : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sources',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildSourceItem(
                      context,
                      'VoxGenie Knowledge Base',
                      'Updated June 2025',
                      Icons.auto_stories_rounded,
                    ),
                    SizedBox(height: 8.h),
                    _buildSourceItem(
                      context,
                      'Official Documentation',
                      'voxgenie.com/docs',
                      Icons.description_rounded,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 100.h), // Extra space for bottom bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardColor : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              context,
              'Ask Again',
              Icons.mic_rounded,
              AppTheme.primaryColor,
              () => Navigator.pop(context),
            ),
            _buildActionButton(
              context,
              'Share',
              Icons.share_rounded,
              AppTheme.accentColor,
              () => _shareAnswer(context, question, answer),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeedbackButton(
    BuildContext context,
    String label,
    IconData icon,
    bool helpful,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Check if this button is selected
    final bool isSelected = helpful ? _isLiked : _isDisliked;
    
    return OutlinedButton.icon(
      onPressed: () => _submitFeedback(context, helpful),
      icon: Icon(
        icon, 
        size: 18.sp,
        color: isSelected
            ? helpful ? Colors.green : Colors.red
            : isDark ? Colors.white70 : Colors.black87,
      ),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSelected
              ? helpful ? Colors.green : Colors.red
              : isDark ? Colors.white70 : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isSelected
              ? helpful ? Colors.green : Colors.red
              : isDark ? Colors.white30 : Colors.grey.shade300,
          width: 1.5,
        ),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        backgroundColor: isSelected
            ? (helpful ? Colors.green : Colors.red).withOpacity(0.1)
            : Colors.transparent,
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: isDark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSourceItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: isDark 
                  ? AppTheme.primaryColor.withOpacity(0.2)
                  : AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.open_in_new_rounded,
            color: isDark ? Colors.white60 : Colors.black54,
            size: 18.sp,
          ),
        ],
      ),
    );
  }
  
  void _submitFeedback(BuildContext context, bool helpful) {
    setState(() {
      if (helpful) {
        _isLiked = !_isLiked;
        if (_isLiked) _isDisliked = false;
      } else {
        _isDisliked = !_isDisliked;
        if (_isDisliked) _isLiked = false;
      }
    });
    
    // Here you would call your API service to submit feedback
    final String feedbackMessage = helpful 
        ? _isLiked ? 'Thanks for your positive feedback!' : 'Feedback removed.'
        : _isDisliked ? 'We\'ll work on improving our answers.' : 'Feedback removed.';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(feedbackMessage),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
  
  void _shareAnswer(BuildContext context, String question, String answer) async {
    final String shareText = 'Question: $question\n\nAnswer: $answer\n\nShared from VoxGenie App';
    
    try {
      await Share.share(shareText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to share content: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    
    setState(() {
      _isCopied = true;
    });
    
    // Reset icon after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Answer copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.accentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
  
  Color _getLanguageColor(String language) {
    switch (language.toLowerCase()) {
      case 'en':
        return Colors.blue;
      case 'hi':
        return Colors.orange;
      case 'mr':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
  
  String _getLanguageText(String language) {
    switch (language.toLowerCase()) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी';
      case 'mr':
        return 'मराठी';
      default:
        return 'English';
    }
  }
}