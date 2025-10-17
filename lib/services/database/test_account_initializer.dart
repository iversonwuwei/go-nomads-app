import 'dart:convert';

import 'account_dao.dart';

/// 测试账户初始化器
/// 创建测试账户和对应的用户Profile数据
class TestAccountInitializer {
  final AccountDao _accountDao = AccountDao();

  /// 初始化测试账户
  Future<void> initializeTestAccounts() async {
    print('👥 开始创建测试账户...');

    // 确保表存在
    await _accountDao.createAccountTables();

    // 检查是否已有账户数据
    final existingAccounts = await _accountDao.getAllAccounts();
    if (existingAccounts.isNotEmpty) {
      print('✅ 已存在 ${existingAccounts.length} 个测试账户');
      return;
    }

    final now = DateTime.now().toIso8601String();

    // 创建3个测试账户
    final testAccounts = [
      {
        'account': {
          'email': 'sarah.chen@nomads.com',
          'username': 'sarah_chen',
          'password': '123456',
          'created_at': now,
          'updated_at': now,
        },
        'profile': {
          'name': 'Sarah Chen',
          'bio':
              'Digital nomad and remote work advocate. I love exploring new cities and meeting fellow travelers. Currently working on building a global community of remote workers.',
          'avatar_url': 'https://i.pravatar.cc/300?img=1',
          'current_city': 'Bangkok',
          'current_country': 'Thailand',
          'skills': jsonEncode([
            'Project Management',
            'Content Creation',
            'Community Building',
            'Social Media Marketing',
            'Event Planning'
          ]),
          'interests': jsonEncode([
            'Travel',
            'Photography',
            'Food',
            'Yoga',
            'Sustainable Living',
            'Digital Marketing'
          ]),
          'social_links': jsonEncode({
            'instagram': '@sarahchen_travels',
            'twitter': '@sarahchen',
            'linkedin': 'linkedin.com/in/sarah-chen',
            'website': 'sarahchen.blog'
          }),
          'badges': jsonEncode([
            {
              'id': 'badge_1',
              'name': 'Early Adopter',
              'icon': '🌟',
              'description': 'One of the first members to join the community',
              'earnedDate': DateTime.now()
                  .subtract(const Duration(days: 365))
                  .toIso8601String(),
            },
            {
              'id': 'badge_2',
              'name': 'Super Connector',
              'icon': '🤝',
              'description': 'Organized 10+ meetups',
              'earnedDate': DateTime.now()
                  .subtract(const Duration(days: 180))
                  .toIso8601String(),
            },
            {
              'id': 'badge_3',
              'name': 'Globe Trotter',
              'icon': '🌍',
              'description': 'Visited 20+ countries',
              'earnedDate': DateTime.now()
                  .subtract(const Duration(days: 90))
                  .toIso8601String(),
            }
          ]),
          'countries_visited': 23,
          'cities_lived': 12,
          'days_nomading': 856,
          'meetups_attended': 45,
          'trips_completed': 15,
          'travel_history': jsonEncode([
            {
              'city': 'Bangkok',
              'country': 'Thailand',
              'startDate': '2023-01-15T00:00:00.000Z',
              'endDate': '2023-06-30T00:00:00.000Z',
              'review':
                  'Amazing coworking scene and incredible street food. Made so many friends here!',
              'rating': 5.0,
            },
            {
              'city': 'Chiang Mai',
              'country': 'Thailand',
              'startDate': '2023-07-01T00:00:00.000Z',
              'endDate': '2023-09-30T00:00:00.000Z',
              'review':
                  'Perfect for digital nomads. Affordable, great internet, and beautiful nature.',
              'rating': 4.8,
            },
            {
              'city': 'Bali',
              'country': 'Indonesia',
              'startDate': '2023-10-01T00:00:00.000Z',
              'endDate': null,
              'review':
                  'Currently loving the surf, yoga, and digital nomad community in Canggu.',
              'rating': 4.9,
            }
          ]),
          'joined_date': DateTime.now()
              .subtract(const Duration(days: 365))
              .toIso8601String(),
          'is_verified': 1,
          'created_at': now,
          'updated_at': now,
        }
      },
      {
        'account': {
          'email': 'alex.wong@nomads.com',
          'username': 'alex_wong',
          'password': '123456',
          'created_at': now,
          'updated_at': now,
        },
        'profile': {
          'name': 'Alex Wong',
          'bio':
              'Software engineer turned entrepreneur. Building SaaS products while traveling the world. Love connecting with other tech enthusiasts and startup founders.',
          'avatar_url': 'https://i.pravatar.cc/300?img=12',
          'current_city': 'Lisbon',
          'current_country': 'Portugal',
          'skills': jsonEncode([
            'Full Stack Development',
            'React',
            'Node.js',
            'Python',
            'AWS',
            'Product Management',
            'Startup Strategy'
          ]),
          'interests': jsonEncode([
            'Tech',
            'Entrepreneurship',
            'Blockchain',
            'Hiking',
            'Coffee',
            'Books',
            'Minimalism'
          ]),
          'social_links': jsonEncode({
            'github': 'github.com/alexwong',
            'twitter': '@alexwong_dev',
            'linkedin': 'linkedin.com/in/alex-wong',
            'medium': '@alexwong'
          }),
          'badges': jsonEncode([
            {
              'id': 'badge_4',
              'name': 'Tech Guru',
              'icon': '💻',
              'description': 'Helped 50+ nomads with tech issues',
              'earnedDate': DateTime.now()
                  .subtract(const Duration(days: 200))
                  .toIso8601String(),
            },
            {
              'id': 'badge_5',
              'name': 'Coffee Connoisseur',
              'icon': '☕',
              'description': 'Reviewed 30+ coworking spaces',
              'earnedDate': DateTime.now()
                  .subtract(const Duration(days: 150))
                  .toIso8601String(),
            }
          ]),
          'countries_visited': 18,
          'cities_lived': 9,
          'days_nomading': 612,
          'meetups_attended': 32,
          'trips_completed': 11,
          'travel_history': jsonEncode([
            {
              'city': 'Singapore',
              'country': 'Singapore',
              'startDate': '2023-01-01T00:00:00.000Z',
              'endDate': '2023-03-31T00:00:00.000Z',
              'review':
                  'Great tech scene but expensive. Perfect for a short stay.',
              'rating': 4.2,
            },
            {
              'city': 'Tokyo',
              'country': 'Japan',
              'startDate': '2023-04-01T00:00:00.000Z',
              'endDate': '2023-07-31T00:00:00.000Z',
              'review':
                  'Incredible blend of tradition and technology. Amazing food and culture.',
              'rating': 4.9,
            },
            {
              'city': 'Lisbon',
              'country': 'Portugal',
              'startDate': '2023-08-01T00:00:00.000Z',
              'endDate': null,
              'review':
                  'Perfect European base. Great weather, friendly people, and growing tech scene.',
              'rating': 4.7,
            }
          ]),
          'joined_date': DateTime.now()
              .subtract(const Duration(days: 280))
              .toIso8601String(),
          'is_verified': 1,
          'created_at': now,
          'updated_at': now,
        }
      },
      {
        'account': {
          'email': 'emma.silva@nomads.com',
          'username': 'emma_silva',
          'password': '123456',
          'created_at': now,
          'updated_at': now,
        },
        'profile': {
          'name': 'Emma Silva',
          'bio':
              'Content creator and travel blogger. Sharing my journey of living and working remotely around the world. Passionate about sustainable travel and local experiences.',
          'avatar_url': 'https://i.pravatar.cc/300?img=5',
          'current_city': 'Mexico City',
          'current_country': 'Mexico',
          'skills': jsonEncode([
            'Content Writing',
            'Video Editing',
            'Photography',
            'Instagram Marketing',
            'SEO',
            'Spanish',
            'English'
          ]),
          'interests': jsonEncode([
            'Travel Blogging',
            'Food',
            'Culture',
            'Language Learning',
            'Sustainable Living',
            'Vlogging',
            'Street Art'
          ]),
          'social_links': jsonEncode({
            'instagram': '@emmasilva_travels',
            'youtube': 'EmmaAroundTheWorld',
            'tiktok': '@emmasilva',
            'blog': 'emmasilva.world'
          }),
          'badges': jsonEncode([
            {
              'id': 'badge_6',
              'name': 'Content Creator',
              'icon': '📸',
              'description': 'Shared 100+ travel stories',
              'earnedDate': DateTime.now()
                  .subtract(const Duration(days: 120))
                  .toIso8601String(),
            },
            {
              'id': 'badge_7',
              'name': 'Local Expert',
              'icon': '🗺️',
              'description': 'Created 15+ city guides',
              'earnedDate': DateTime.now()
                  .subtract(const Duration(days: 60))
                  .toIso8601String(),
            },
            {
              'id': 'badge_8',
              'name': 'Community Star',
              'icon': '⭐',
              'description': 'Top contributor this month',
              'earnedDate': DateTime.now()
                  .subtract(const Duration(days: 15))
                  .toIso8601String(),
            }
          ]),
          'countries_visited': 15,
          'cities_lived': 8,
          'days_nomading': 420,
          'meetups_attended': 28,
          'trips_completed': 9,
          'travel_history': jsonEncode([
            {
              'city': 'Barcelona',
              'country': 'Spain',
              'startDate': '2023-03-01T00:00:00.000Z',
              'endDate': '2023-05-31T00:00:00.000Z',
              'review':
                  'Vibrant city with amazing architecture and food scene. A bit touristy.',
              'rating': 4.5,
            },
            {
              'city': 'Medellín',
              'country': 'Colombia',
              'startDate': '2023-06-01T00:00:00.000Z',
              'endDate': '2023-08-31T00:00:00.000Z',
              'review':
                  'Friendly people, perfect weather, and affordable. Great for digital nomads.',
              'rating': 4.8,
            },
            {
              'city': 'Mexico City',
              'country': 'Mexico',
              'startDate': '2023-09-01T00:00:00.000Z',
              'endDate': null,
              'review':
                  'Incredible food, rich culture, and vibrant art scene. Loving it here!',
              'rating': 4.9,
            }
          ]),
          'joined_date': DateTime.now()
              .subtract(const Duration(days: 200))
              .toIso8601String(),
          'is_verified': 1,
          'created_at': now,
          'updated_at': now,
        }
      },
    ];

    // 插入账户和profile
    int successCount = 0;
    for (var data in testAccounts) {
      try {
        // 插入账户
        final accountId = await _accountDao
            .insertAccount(data['account'] as Map<String, dynamic>);
        print('✅ 创建账户: ${data['account']!['username']} (ID: $accountId)');

        // 插入profile
        final profileData = data['profile'] as Map<String, dynamic>;
        profileData['account_id'] = accountId;
        await _accountDao.insertProfile(profileData);
        print('   ✅ 创建Profile: ${profileData['name']}');

        successCount++;
      } catch (e) {
        print('   ❌ 创建账户失败 ${data['account']!['username']}: $e');
      }
    }

    print('✅ 成功创建 $successCount 个测试账户');
    print('\n📋 测试账户列表:');
    print('   1. Email: sarah.chen@nomads.com, Password: 123456');
    print('   2. Email: alex.wong@nomads.com, Password: 123456');
    print('   3. Email: emma.silva@nomads.com, Password: 123456');
  }

  /// 显示所有测试账户
  Future<void> printAllAccounts() async {
    final accounts = await _accountDao.getAllAccountsWithProfiles();
    print('\n👥 当前测试账户列表 (${accounts.length}个):');
    for (var account in accounts) {
      print('   - ${account['username']} (${account['email']})');
      print('     Name: ${account['name']}');
      print(
          '     Current: ${account['current_city']}, ${account['current_country']}');
      print(
          '     Stats: ${account['countries_visited']} countries, ${account['days_nomading']} days nomading');
      print('');
    }
  }
}
