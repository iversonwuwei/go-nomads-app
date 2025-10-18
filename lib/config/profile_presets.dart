/// 用户个人资料的预设选项
class ProfilePresets {
  // 预设技能列表
  static const List<String> skills = [
    // 编程语言
    'Flutter',
    'Dart',
    'JavaScript',
    'TypeScript',
    'Python',
    'Java',
    'Kotlin',
    'Swift',
    'Go',
    'Rust',
    'C++',
    'PHP',
    'Ruby',
    
    // 前端框架
    'React',
    'Vue.js',
    'Angular',
    'Next.js',
    'Svelte',
    
    // 后端框架
    'Node.js',
    'Django',
    'Spring Boot',
    'Laravel',
    'Express',
    'FastAPI',
    
    // 移动开发
    'React Native',
    'iOS Development',
    'Android Development',
    
    // 数据库
    'SQL',
    'PostgreSQL',
    'MySQL',
    'MongoDB',
    'Redis',
    'Firebase',
    
    // DevOps & 工具
    'Docker',
    'Kubernetes',
    'AWS',
    'Azure',
    'Google Cloud',
    'CI/CD',
    'Git',
    
    // 设计
    'UI/UX Design',
    'Figma',
    'Adobe XD',
    'Sketch',
    'Photoshop',
    'Illustrator',
    'Graphic Design',
    'Web Design',
    
    // 数据科学
    'Machine Learning',
    'Data Analysis',
    'Deep Learning',
    'TensorFlow',
    'PyTorch',
    'Data Visualization',
    
    // 软技能
    'Project Management',
    'Agile',
    'Scrum',
    'Product Management',
    'Team Leadership',
    'Communication',
    'Public Speaking',
    'Technical Writing',
    'Content Writing',
    'Copywriting',
    
    // 营销
    'Digital Marketing',
    'SEO',
    'Social Media Marketing',
    'Content Marketing',
    'Email Marketing',
    
    // 其他
    'Video Editing',
    'Animation',
    '3D Modeling',
    'Game Development',
    'Blockchain',
    'Cybersecurity',
  ];

  // 预设兴趣爱好列表
  static const List<String> interests = [
    // 旅行相关
    'Remote Work',
    'Digital Nomad',
    'Travel',
    'Backpacking',
    'Road Trips',
    'City Exploring',
    'Beach Life',
    'Mountain Hiking',
    'Camping',
    'Adventure Travel',
    
    // 文化交流
    'Language Learning',
    'Cultural Exchange',
    'Meeting Locals',
    'International Friends',
    'Expat Life',
    
    // 创业商业
    'Startup',
    'Entrepreneurship',
    'Business',
    'Investing',
    'Cryptocurrency',
    'Side Projects',
    'Freelancing',
    
    // 技术
    'Technology',
    'Coding',
    'Open Source',
    'AI & ML',
    'Web3',
    'Gadgets',
    
    // 运动健身
    'Fitness',
    'Yoga',
    'Running',
    'Cycling',
    'Swimming',
    'Surfing',
    'Skateboarding',
    'Rock Climbing',
    'Martial Arts',
    'CrossFit',
    'Gym',
    
    // 创意艺术
    'Photography',
    'Videography',
    'Music',
    'Playing Instruments',
    'Singing',
    'Drawing',
    'Painting',
    'Writing',
    'Poetry',
    'Blogging',
    'Vlogging',
    
    // 饮食
    'Cooking',
    'Baking',
    'Food',
    'Coffee',
    'Wine Tasting',
    'Street Food',
    'Vegetarian',
    'Vegan',
    
    // 自然户外
    'Nature',
    'Wildlife',
    'Bird Watching',
    'Gardening',
    'Sustainability',
    'Eco-Friendly',
    
    // 娱乐休闲
    'Reading',
    'Books',
    'Movies',
    'TV Shows',
    'Gaming',
    'Board Games',
    'Podcasts',
    'Anime',
    'Comics',
    
    // 个人成长
    'Meditation',
    'Mindfulness',
    'Self-Improvement',
    'Philosophy',
    'Psychology',
    'Personal Development',
    
    // 社交活动
    'Networking',
    'Meetups',
    'Coworking',
    'Community Building',
    'Volunteering',
    'Teaching',
    'Mentoring',
    
    // 时尚生活
    'Fashion',
    'Interior Design',
    'Minimalism',
    'Lifestyle',
    
    // 探索学习
    'History',
    'Science',
    'Astronomy',
    'Archaeology',
    'Museums',
    'Architecture',
  ];

  // 获取技能分类
  static Map<String, List<String>> getSkillsByCategory() {
    return {
      '编程语言': [
        'Flutter', 'Dart', 'JavaScript', 'TypeScript', 'Python', 'Java',
        'Kotlin', 'Swift', 'Go', 'Rust', 'C++', 'PHP', 'Ruby',
      ],
      '前端开发': [
        'React', 'Vue.js', 'Angular', 'Next.js', 'Svelte',
      ],
      '后端开发': [
        'Node.js', 'Django', 'Spring Boot', 'Laravel', 'Express', 'FastAPI',
      ],
      '移动开发': [
        'React Native', 'iOS Development', 'Android Development',
      ],
      '数据库': [
        'SQL', 'PostgreSQL', 'MySQL', 'MongoDB', 'Redis', 'Firebase',
      ],
      'DevOps': [
        'Docker', 'Kubernetes', 'AWS', 'Azure', 'Google Cloud', 'CI/CD', 'Git',
      ],
      '设计': [
        'UI/UX Design', 'Figma', 'Adobe XD', 'Sketch', 'Photoshop',
        'Illustrator', 'Graphic Design', 'Web Design',
      ],
      '数据科学': [
        'Machine Learning', 'Data Analysis', 'Deep Learning',
        'TensorFlow', 'PyTorch', 'Data Visualization',
      ],
      '管理与营销': [
        'Project Management', 'Agile', 'Scrum', 'Product Management',
        'Digital Marketing', 'SEO', 'Social Media Marketing',
      ],
      '其他': [
        'Video Editing', 'Animation', '3D Modeling', 'Game Development',
        'Blockchain', 'Cybersecurity', 'Technical Writing', 'Content Writing',
      ],
    };
  }

  // 获取兴趣分类
  static Map<String, List<String>> getInterestsByCategory() {
    return {
      '旅行探险': [
        'Remote Work', 'Digital Nomad', 'Travel', 'Backpacking', 'Road Trips',
        'City Exploring', 'Beach Life', 'Mountain Hiking', 'Camping', 'Adventure Travel',
      ],
      '创业商业': [
        'Startup', 'Entrepreneurship', 'Business', 'Investing',
        'Cryptocurrency', 'Side Projects', 'Freelancing',
      ],
      '运动健身': [
        'Fitness', 'Yoga', 'Running', 'Cycling', 'Swimming', 'Surfing',
        'Skateboarding', 'Rock Climbing', 'Martial Arts', 'CrossFit', 'Gym',
      ],
      '创意艺术': [
        'Photography', 'Videography', 'Music', 'Drawing', 'Painting',
        'Writing', 'Blogging', 'Vlogging',
      ],
      '饮食烹饪': [
        'Cooking', 'Baking', 'Food', 'Coffee', 'Wine Tasting',
        'Street Food', 'Vegetarian', 'Vegan',
      ],
      '文化学习': [
        'Language Learning', 'Cultural Exchange', 'Reading', 'Books',
        'History', 'Philosophy', 'Museums',
      ],
      '技术科技': [
        'Technology', 'Coding', 'Open Source', 'AI & ML', 'Web3', 'Gadgets',
      ],
      '娱乐休闲': [
        'Movies', 'TV Shows', 'Gaming', 'Board Games', 'Podcasts', 'Anime',
      ],
      '个人成长': [
        'Meditation', 'Mindfulness', 'Self-Improvement', 'Personal Development',
      ],
      '社交活动': [
        'Networking', 'Meetups', 'Coworking', 'Community Building',
        'Volunteering', 'Teaching', 'Mentoring',
      ],
      '自然环保': [
        'Nature', 'Wildlife', 'Gardening', 'Sustainability', 'Eco-Friendly',
      ],
    };
  }
}
