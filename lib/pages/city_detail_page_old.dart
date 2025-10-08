import 'package:flutter/material.dart';

// 城市详情页面 - 基于 Nomads.com 设计
class CityDetailPage extends StatefulWidget {
  final Map<String, dynamic> cityData;

  const CityDetailPage({super.key, required this.cityData});

  @override
  State<CityDetailPage> createState() => _CityDetailPageState();
}

class _CityDetailPageState extends State<CityDetailPage> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 顶部大图 AppBar
          _buildSliverAppBar(isMobile),

          // 城市基本信息
          SliverToBoxAdapter(
            child: _buildCityHeader(isMobile),
          ),

          // 评分卡片
          SliverToBoxAdapter(
            child: _buildScoreCards(isMobile),
          ),

          // 关于城市
          SliverToBoxAdapter(
            child: _buildAboutSection(isMobile),
          ),

          // 生活成本
          SliverToBoxAdapter(
            child: _buildCostOfLiving(isMobile),
          ),

          // 天气信息
          SliverToBoxAdapter(
            child: _buildWeatherSection(isMobile),
          ),

          // 照片画廊
          SliverToBoxAdapter(
            child: _buildPhotoGallery(isMobile),
          ),

          // 底部间距
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  // 顶部大图 AppBar
  Widget _buildSliverAppBar(bool isMobile) {
    return SliverAppBar(
      expandedHeight: isMobile ? 300 : 500,
      pinned: true,
      backgroundColor: const Color(0xFF1a1a2e),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.white,
          ),
          onPressed: () => setState(() => isFavorite = !isFavorite),
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 背景图片
            Image.network(
              widget.cityData['image'],
              fit: BoxFit.cover,
            ),
            // 渐变遮罩
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // 城市名称和排名
            Positioned(
              bottom: isMobile ? 60 : 80,
              left: isMobile ? 16 : 20,
              right: isMobile ? 16 : 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 10 : 12,
                      vertical: isMobile ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '#${widget.cityData['rank']} Best Place',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 8 : 12),
                  Text(
                    widget.cityData['city'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 32 : 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.white70,
                        size: isMobile ? 18 : 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.cityData['country'],
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 城市基本信息
  Widget _buildCityHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // 温度
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF64B5F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wb_sunny_outlined,
                      color: const Color(0xFF64B5F6),
                      size: isMobile ? 18 : 20,
                    ),
                    SizedBox(width: isMobile ? 6 : 8),
                    Text(
                      '${widget.cityData['temperature']}°C',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // 网速
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF81C784).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_outlined,
                      color: const Color(0xFF81C784),
                      size: isMobile ? 18 : 20,
                    ),
                    SizedBox(width: isMobile ? 6 : 8),
                    Text(
                      '${widget.cityData['internet']} Mbps',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 20 : 24),
          // 价格信息
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${widget.cityData['price']}',
                style: TextStyle(
                  fontSize: isMobile ? 36 : 42,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1a1a2e),
                ),
              ),
              Text(
                ' / month',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            'FOR A NOMAD',
            style: TextStyle(
              color: Colors.black45,
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 评分卡片
  Widget _buildScoreCards(bool isMobile) {
    final scores = [
      {
        'label': 'Overall',
        'score': widget.cityData['overall'],
        'icon': '⭐',
        'color': const Color(0xFFFFB74D),
      },
      {
        'label': 'Cost',
        'score': widget.cityData['cost'],
        'icon': '💰',
        'color': const Color(0xFF81C784),
      },
      {
        'label': 'Internet',
        'score': widget.cityData['internetScore'],
        'icon': '📡',
        'color': const Color(0xFF64B5F6),
      },
      {
        'label': 'Liked',
        'score': widget.cityData['liked'],
        'icon': '👍',
        'color': const Color(0xFFE57373),
      },
      {
        'label': 'Safety',
        'score': widget.cityData['safety'],
        'icon': '🛡️',
        'color': const Color(0xFFBA68C8),
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scores',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 5,
              crossAxisSpacing: isMobile ? 12 : 16,
              mainAxisSpacing: isMobile ? 12 : 16,
              childAspectRatio: isMobile ? 1.3 : 1.2,
            ),
            itemCount: scores.length,
            itemBuilder: (context, index) {
              final score = scores[index];
              final scoreValue = (score['score'] as num).toDouble();
              return Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      score['icon'] as String,
                      style: TextStyle(fontSize: isMobile ? 28 : 32),
                    ),
                    SizedBox(height: isMobile ? 4 : 8),
                    Text(
                      score['label'] as String,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: isMobile ? 4 : 8),
                    Text(
                      '${(scoreValue * 10).toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        color: score['color'] as Color,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 关于城市
  Widget _buildAboutSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.cityData['city']} is a vibrant destination for digital nomads, offering a perfect blend of modern infrastructure and cultural richness. With excellent internet connectivity, affordable living costs, and a thriving expat community, it\'s an ideal base for remote workers.',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // 生活成本
  Widget _buildCostOfLiving(bool isMobile) {
    final costs = [
      {'item': 'Apartment (1br)', 'price': '\$${(widget.cityData['price'] * 0.6).toInt()}'},
      {'item': 'Coworking Space', 'price': '\$${(widget.cityData['price'] * 0.15).toInt()}'},
      {'item': 'Meal (Restaurant)', 'price': '\$${(widget.cityData['price'] * 0.02).toInt()}'},
      {'item': 'Coffee', 'price': '\$${(widget.cityData['price'] * 0.008).toInt()}'},
      {'item': 'Transport (Monthly)', 'price': '\$${(widget.cityData['price'] * 0.1).toInt()}'},
      {'item': 'Gym Membership', 'price': '\$${(widget.cityData['price'] * 0.08).toInt()}'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cost of Living',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: costs.map((cost) {
                final isLast = cost == costs.last;
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 20,
                    vertical: isMobile ? 12 : 16,
                  ),
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : Border(
                            bottom: BorderSide(
                              color: Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          cost['item']!,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        cost['price']!,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 天气信息
  Widget _buildWeatherSection(bool isMobile) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weather',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: isMobile ? 180 : 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: months.map((month) {
                // 模拟温度数据
                final temp = 15 + (months.indexOf(month) % 6) * 5;
                final maxHeight = isMobile ? 80.0 : 100.0;
                final barHeight = (temp / 35) * maxHeight;
                
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${temp}°',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: isMobile ? 8 : 16,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFF64B5F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        month,
                        style: TextStyle(
                          fontSize: isMobile ? 8 : 10,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 照片画廊
  Widget _buildPhotoGallery(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photos',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.grey[200],
                  child: Image.network(
                    widget.cityData['image'],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
