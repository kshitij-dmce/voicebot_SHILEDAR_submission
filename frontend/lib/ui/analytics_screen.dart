import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final List<String> _timeRanges = ['Last 7 Days', 'Last 30 Days', 'Last 3 Months', 'This Year'];
  String _selectedTimeRange = 'Last 7 Days';
  
  // Mock data for charts
  final List<Map<String, dynamic>> _queryCategories = [
    {'name': 'Banking', 'count': 35, 'color': const Color(0xFF4CAF50)},
    {'name': 'Insurance', 'count': 25, 'color': const Color(0xFF2196F3)},
    {'name': 'Loans', 'count': 20, 'color': const Color(0xFFFF9800)},
    {'name': 'Accounts', 'count': 15, 'color': const Color(0xFF9C27B0)},
    {'name': 'Others', 'count': 5, 'color': const Color(0xFF607D8B)},
  ];
  
  final Map<String, List<double>> _dailyQueries = {
    'Last 7 Days': [4, 6, 8, 5, 9, 7, 8],
    'Last 30 Days': [6, 5, 8, 9, 7, 6, 8, 10, 9, 7, 8, 6, 5, 7, 9, 8, 7, 6, 5, 8, 9, 7, 6, 8, 9, 10, 8, 7, 6, 9],
    'Last 3 Months': [18, 22, 25, 20, 24, 21, 26, 28, 24, 22, 25, 27],
    'This Year': [45, 52, 60, 58, 64, 58, 70, 75, 68, 72, 75],
  };
  
  final Map<String, List<String>> _recentQueries = {
    'Last 7 Days': [
      'How do I apply for a home loan?',
      'What are the current interest rates?',
      'How to reset my net banking password?',
      'What is the premium for term insurance?',
      'How to update KYC details?'
    ],
    'Last 30 Days': [
      'How do I apply for a home loan?',
      'What are the current interest rates?',
      'How to reset my net banking password?',
      'What is the premium for term insurance?',
      'How to update KYC details?',
      'What documents are needed for account opening?',
      'How to check my account balance?'
    ],
    'Last 3 Months': [
      'How do I apply for a home loan?',
      'What are the current interest rates?',
      'How to reset my net banking password?',
      'What is the premium for term insurance?',
      'How to update KYC details?',
      'What documents are needed for account opening?',
      'How to check my account balance?',
      'What is the loan processing fee?',
      'How to transfer money using NEFT?'
    ],
    'This Year': [
      'How do I apply for a home loan?',
      'What are the current interest rates?',
      'How to reset my net banking password?',
      'What is the premium for term insurance?',
      'How to update KYC details?',
      'What documents are needed for account opening?',
      'How to check my account balance?',
      'What is the loan processing fee?',
      'How to transfer money using NEFT?',
      'How to report lost debit card?',
      'What are the mutual fund options available?'
    ]
  };
  
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: AppBar(
              backgroundColor: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.2),
              elevation: 0,
              centerTitle: true,
              title: Text(
                'Analytics',
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
                    Icons.refresh_rounded,
                    color: isDark ? Colors.white70 : AppTheme.primaryColor,
                    size: 22.sp,
                  ),
                  onPressed: () {
                    // Refresh analytics data
                    setState(() {});
                  },
                  tooltip: 'Refresh data',
                ),
              ],
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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time range selector
                _buildSectionHeader('Time Range', Icons.date_range_rounded)
                    .animate().slideY(
                      begin: -0.2, 
                      end: 0, 
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutQuint,
                    ),
                SizedBox(height: 12.h),
                _buildTimeRangeSelector(isDark),
                SizedBox(height: 24.h),
                
                // Usage overview
                _buildSectionHeader('Usage Overview', Icons.bar_chart_rounded)
                    .animate().slideY(
                      begin: -0.2, 
                      end: 0,
                      delay: const Duration(milliseconds: 100), 
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutQuint,
                    ),
                SizedBox(height: 12.h),
                _buildUsageOverview(isDark),
                SizedBox(height: 24.h),
                
                // Query distribution
                _buildSectionHeader('Query Categories', Icons.pie_chart_rounded)
                    .animate().slideY(
                      begin: -0.2, 
                      end: 0,
                      delay: const Duration(milliseconds: 200), 
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutQuint,
                    ),
                SizedBox(height: 12.h),
                _buildQueryDistribution(isDark),
                SizedBox(height: 24.h),
                
                // Daily activity
                _buildSectionHeader('Daily Activity', Icons.trending_up_rounded)
                    .animate().slideY(
                      begin: -0.2, 
                      end: 0,
                      delay: const Duration(milliseconds: 300), 
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutQuint,
                    ),
                SizedBox(height: 12.h),
                _buildDailyActivity(isDark),
                SizedBox(height: 24.h),
                
                // Recent queries
                _buildSectionHeader('Recent Queries', Icons.history_rounded)
                    .animate().slideY(
                      begin: -0.2, 
                      end: 0,
                      delay: const Duration(milliseconds: 400), 
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutQuint,
                    ),
                SizedBox(height: 12.h),
                _buildRecentQueries(isDark),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
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
    );
  }

  Widget _buildTimeRangeSelector(bool isDark) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _timeRanges.length,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemBuilder: (context, index) {
          final bool isSelected = _selectedTimeRange == _timeRanges[index];
          
          return Animate(
            effects: [
              FadeEffect(
                delay: Duration(milliseconds: index * 100),
                duration: const Duration(milliseconds: 400),
              ),
            ],
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimeRange = _timeRanges[index];
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppTheme.primaryColor : AppTheme.primaryColor)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  _timeRanges[index],
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1.0, 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
    );
  }

  Widget _buildUsageOverview(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  icon: Icons.question_answer_rounded,
                  title: 'Total Queries',
                  value: _selectedTimeRange == 'Last 7 Days'
                      ? '48'
                      : _selectedTimeRange == 'Last 30 Days'
                          ? '187'
                          : _selectedTimeRange == 'Last 3 Months'
                              ? '512'
                              : '1,248',
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Resolution Rate',
                  value: '98%',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  icon: Icons.timer_outlined,
                  title: 'Avg. Response Time',
                  value: '1.4s',
                  color: AppTheme.accentColor,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  icon: Icons.thumb_up_alt_outlined,
                  title: 'Satisfaction',
                  value: '96%',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1.0, 1.0),
      delay: const Duration(milliseconds: 100),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18.sp,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_upward_rounded,
                color: Colors.green,
                size: 14.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                '${Random().nextInt(8) + 2}%',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueryDistribution(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 160.w,
                height: 160.w,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex =
                              pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 30.r,
                    sections: _showingPieSections(),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _queryCategories.length,
                    (index) => _buildCategoryIndicator(
                      isDark: isDark,
                      color: _queryCategories[index]['color'],
                      label: _queryCategories[index]['name'],
                      percentage: (_queryCategories[index]['count'] / 100 * 100).toInt(),
                      isSelected: touchedIndex == index,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1.0, 1.0),
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
    );
  }

  Widget _buildCategoryIndicator({
    required bool isDark,
    required Color color,
    required String label,
    required int percentage,
    required bool isSelected,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: isDark ? Colors.white : Colors.black,
                      width: 2,
                    )
                  : null,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            '$percentage%',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? color : color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingPieSections() {
    return List.generate(_queryCategories.length, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 20.sp : 16.sp;
      final double radius = isTouched ? 60.r : 50.r;
      
      return PieChartSectionData(
        color: _queryCategories[i]['color'],
        value: _queryCategories[i]['count'].toDouble(),
        title: '',
        radius: radius,
        titleStyle: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildDailyActivity(bool isDark) {
    final List<double> data = _dailyQueries[_selectedTimeRange] ?? [];
    double maxValue = data.isNotEmpty ? data.reduce(max) : 10;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 180.h,
            padding: EdgeInsets.only(top: 16.h, right: 16.w, bottom: 16.h),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                maxY: maxValue * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: isDark ? Colors.white : Colors.black87,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: EdgeInsets.all(8.r),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} queries',
                        GoogleFonts.poppins(
                          color: isDark ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Only show some of the labels to avoid crowding
                        if (_selectedTimeRange == 'Last 30 Days' && value % 5 != 0) {
                          return const SizedBox();
                        }
                        if (_selectedTimeRange == 'Last 3 Months' && value % 2 != 0) {
                          return const SizedBox();
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            _getLabelForIndex(value.toInt()),
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 10.sp,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            value.toInt().toString(),
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 10.sp,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: isDark ? AppTheme.accentColor : AppTheme.primaryColor,
                        width: _getBarWidth(),
                        borderRadius: BorderRadius.circular(4.r),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxValue * 1.2,
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14.sp,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              SizedBox(width: 4.w),
              Text(
                'Daily query volume over time',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1.0, 1.0),
      delay: const Duration(milliseconds: 300),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
    );
  }
  
  double _getBarWidth() {
    switch (_selectedTimeRange) {
      case 'Last 7 Days':
        return 20.w;
      case 'Last 30 Days':
        return 6.w;
      case 'Last 3 Months':
        return 12.w;
      case 'This Year':
        return 14.w;
      default:
        return 10.w;
    }
  }
  
  String _getLabelForIndex(int index) {
    switch (_selectedTimeRange) {
      case 'Last 7 Days':
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[index % days.length];
      case 'Last 30 Days':
        return (index + 1).toString();
      case 'Last 3 Months':
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return months[index % months.length];
      case 'This Year':
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return months[index % months.length];
      default:
        return index.toString();
    }
  }

  Widget _buildRecentQueries(bool isDark) {
    final queries = _recentQueries[_selectedTimeRange] ?? [];
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ...queries.asMap().entries.map((entry) {
            final index = entry.key;
            final query = entry.value;
            return Animate(
              effects: [
                FadeEffect(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: 400 + index * 50),
                ),
                SlideEffect(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                  duration: const Duration(milliseconds: 500),
                  delay: Duration(milliseconds: 400 + index * 50),
                ),
              ],
              child: _buildQueryItem(query, isDark),
            );
          }).toList(),
          
          if (queries.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text(
                  'No recent queries',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
            ),
          
          SizedBox(height: 8.h),
          TextButton(
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View all queries',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18.sp,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1.0, 1.0),
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
    );
  }

  Widget _buildQueryItem(String query, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
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
            child: Center(
              child: Icon(
                Icons.search_rounded,
                color: isDark ? AppTheme.accentColor : AppTheme.primaryColor,
                size: 18.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  query,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${Random().nextInt(23) + 1}h ago',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.white38 : Colors.black38,
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}