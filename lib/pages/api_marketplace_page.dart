import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
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
  final String _selectedPricing = 'All';
  final String _sortBy = 'popularity';
  
  final List<String> _categories = [
    'All', 'Data Analytics', 'Payment', 'AI/ML', 'Weather', 
    'Location', 'Social Media', 'E-commerce', 'Security'
  ];
  
  final List<String> _pricingOptions = ['All', 'Free', 'Freemium', 'Paid'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'API MARKETPLACE',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w300,
          fontSize: 16,
          letterSpacing: 2,
        ),
      ),
      actions: [
        IconButton(
          icon:
              const Icon(Icons.bookmark_border, color: AppColors.textTertiary),
          onPressed: () => _showBookmarks(),
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined,
              color: AppColors.textTertiary),
          onPressed: () => _showCart(),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.borderLight,
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.textTertiary, width: 1),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                hintText: 'SEARCH',
                hintStyle: TextStyle(
                  color: AppColors.iconLight,
                  fontSize: 12.sp,
                  letterSpacing: 2,
                ),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textTertiary, size: 20),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              ),
              onChanged: (value) => _filterApis(),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Filter Row - Minimalist
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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down,
                size: 14.sp, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip() {
    return GestureDetector(
      onTap: () => _showSortDialog(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.sort, size: 14.sp, color: AppColors.textTertiary),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                _sortBy.toUpperCase(),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
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
      height: 48.h,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color:
                        isSelected ? AppColors.textPrimary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                category.toUpperCase(),
                style: TextStyle(
                  color:
                      isSelected ? AppColors.textPrimary : AppColors.iconLight,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
                  fontSize: 11.sp,
                  letterSpacing: 1.5,
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
    // 为每个API定义简洁的单色方案 - 性冷淡风格(浅色系)
    final colorIndex = api.name.hashCode.abs() % AppColors.apiCardColors.length;
    final cardColor = AppColors.apiCardColors[colorIndex];
    
    return GestureDetector(
      onTap: () => _showApiDetails(api),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header区域
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon和Tag
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            api.icon,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                        ),
                        const Spacer(),
                        if (api.isFree)
                          _buildMinimalTag('FREE', Colors.white)
                        else if (api.isHot)
                          _buildMinimalTag('HOT', Colors.white),
                      ],
                    ),
                    
                    SizedBox(height: 16.h),

                    // API Name
                    Text(
                      api.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 6.h),

                    // Category
                    Text(
                      api.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.5,
                      ),
                    ),
                    
                    SizedBox(height: 12.h),

                    // Description
                    Expanded(
                      child: Text(
                        api.description,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.4,
                          fontWeight: FontWeight.w300,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom stats section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 可靠性
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 6.sp,
                        color: const Color(0xFF10B981),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${api.reliability.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  
                  // 响应时间
                  Text(
                    '${api.responseTime}MS',
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                    ),
                  ),
                  
                  // 价格
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Text(
                      api.isFree ? 'FREE' : '\$${api.price}',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        color: cardColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalTag(String text, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: textColor.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 7.sp,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.5,
        ),
      ),
    );
  }



  

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.border,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.search_off,
              size: 36.sp,
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'NO RESULTS',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              letterSpacing: 3,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try different keywords',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
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