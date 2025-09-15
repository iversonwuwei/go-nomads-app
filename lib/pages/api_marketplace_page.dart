import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/shopping_controller.dart';
import '../models/api_interface_model.dart';

class ApiMarketplacePage extends StatefulWidget {
  const ApiMarketplacePage({super.key});

  @override
  State<ApiMarketplacePage> createState() => _ApiMarketplacePageState();
}

class _ApiMarketplacePageState extends State<ApiMarketplacePage> {
  final TextEditingController _searchController = TextEditingController();
  final ShoppingController _shoppingController = Get.find<ShoppingController>();
  
  String _selectedCategory = 'All';
  String _selectedPricing = 'All';
  String _sortBy = 'popularity';
  
  final List<String> _categories = [
    'All', 'Data Analytics', 'Payment', 'AI/ML', 'Weather', 
    'Location', 'Social Media', 'E-commerce', 'Security'
  ];
  
  final List<String> _pricingOptions = ['All', 'Free', 'Freemium', 'Paid'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          _buildCategoryTabs(),
          Expanded(
            child: Obx(() => _buildApiGrid()),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'API Marketplace',
        style: TextStyle(
          color: Color(0xFF1F2937),
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_border, color: Color(0xFF6B7280)),
          onPressed: () => _showBookmarks(),
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF6B7280)),
          onPressed: () => _showCart(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search APIs, providers, or keywords...',
                hintStyle: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 14.sp),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
              onChanged: (value) => _filterApis(),
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Filter Row
          Row(
            children: [
              Expanded(child: _buildFilterChip('Category', _selectedCategory, _categories)),
              SizedBox(width: 8.w),
              Expanded(child: _buildFilterChip('Pricing', _selectedPricing, _pricingOptions)),
              SizedBox(width: 8.w),
              Expanded(child: _buildSortChip()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, List<String> options) {
    return GestureDetector(
      onTap: () => _showFilterDialog(label, options),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF374151),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 14.sp, color: const Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip() {
    return GestureDetector(
      onTap: () => _showSortDialog(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.sort, size: 14.sp, color: const Color(0xFF6B7280)),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                _sortBy.capitalize!,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF374151),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 44.h,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              margin: EdgeInsets.only(right: 8.w, top: 6.h, bottom: 6.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12.sp,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildApiGrid() {
    final filteredApis = _getFilteredApis();
    
    if (filteredApis.isEmpty) {
      return _buildEmptyState();
    }
    
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85, // 调整比例，减少卡片高度
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: filteredApis.length,
      itemBuilder: (context, index) => _buildApiCard(filteredApis[index]),
    );
  }

  Widget _buildApiCard(ApiInterfaceModel api) {
    // 为每个API定义鲜艳的渐变色彩
    final List<List<Color>> gradientColors = [
      [const Color(0xFF6366F1), const Color(0xFF8B5CF6)], // 紫蓝渐变
      [const Color(0xFF06B6D4), const Color(0xFF3B82F6)], // 蓝青渐变
      [const Color(0xFF10B981), const Color(0xFF059669)], // 绿色渐变
      [const Color(0xFFF59E0B), const Color(0xFFEF4444)], // 橙红渐变
      [const Color(0xFFEC4899), const Color(0xBE185D)], // 粉红渐变
      [const Color(0xFF8B5CF6), const Color(0xBB7C2E)], // 紫橙渐变
    ];
    
    final gradientIndex = api.name.hashCode.abs() % gradientColors.length;
    final currentGradient = gradientColors[gradientIndex];
    
    return GestureDetector(
      onTap: () => _showApiDetails(api),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: currentGradient,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: currentGradient[0].withOpacity(0.3),
              blurRadius: 12.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            // 添加一个微妙的白色遮罩让内容更清晰
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon and tags
              Flexible(
                flex: 4, // 增加顶部内容区域
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36.w,
                            height: 36.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              api.icon,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ),
                          const Spacer(),
                          if (api.isFree)
                            _buildModernTag('FREE', Colors.white, currentGradient[1])
                          else if (api.isHot)
                            _buildModernTag('HOT', Colors.white, const Color(0xFFFF6B6B)),
                        ],
                      ),
                      
                      SizedBox(height: 8.h),
                      
                      // API Name
                      Text(
                        api.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: 3.h),
                      
                      // Category
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          api.category,
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 6.h),
                      
                      // Description
                      Expanded(
                        child: Text(
                          api.description,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom stats section
              Flexible(
                flex: 1, // 减少底部区域，只占1/5空间
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h), // 减少垂直内边距
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 左侧：可靠性和响应时间
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 10.sp,
                                color: const Color(0xFF10B981),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                '${api.reliability.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${api.responseTime}ms',
                            style: TextStyle(
                              fontSize: 7.sp,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      // 右侧：价格标签
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          api.isFree ? 'FREE' : '\$${api.price}',
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w700,
                            color: currentGradient[0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTag(String text, Color textColor, Color backgroundColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: backgroundColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 8.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }



  

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 12.h),
          Text(
            'No APIs found',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  List<ApiInterfaceModel> _getFilteredApis() {
    // For demo purposes, returning the hot APIs from the controller
    // In a real app, this would filter based on search and filter criteria
    return _shoppingController.hotApiInterfaces;
  }

  void _filterApis() {
    // Implement filtering logic based on search text and filters
    setState(() {});
  }

  void _showFilterDialog(String title, List<String> options) {
    // Show filter selection dialog
    Get.snackbar('Filter', '$title filter options would be shown here');
  }

  void _showSortDialog() {
    // Show sort options dialog
    Get.snackbar('Sort', 'Sort options would be shown here');
  }

  void _showApiDetails(ApiInterfaceModel api) {
    // Navigate to API details page
    Get.snackbar('API Details', 'Showing details for ${api.name}');
  }

  void _showBookmarks() {
    Get.snackbar('Bookmarks', 'Bookmarked APIs would be shown here');
  }

  void _showCart() {
    Get.snackbar('Cart', 'API cart would be shown here');
  }
}