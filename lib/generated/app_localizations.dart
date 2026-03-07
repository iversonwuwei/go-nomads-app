import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// 应用标题
  ///
  /// In zh, this message translates to:
  /// **'行途'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get profile;

  /// No description provided for @dataService.
  ///
  /// In zh, this message translates to:
  /// **'数据服务'**
  String get dataService;

  /// No description provided for @apiMarketplace.
  ///
  /// In zh, this message translates to:
  /// **'API市场'**
  String get apiMarketplace;

  /// No description provided for @community.
  ///
  /// In zh, this message translates to:
  /// **'社区'**
  String get community;

  /// No description provided for @chat.
  ///
  /// In zh, this message translates to:
  /// **'聊天'**
  String get chat;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @login.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In zh, this message translates to:
  /// **'注册'**
  String get register;

  /// No description provided for @email.
  ///
  /// In zh, this message translates to:
  /// **'邮件'**
  String get email;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In zh, this message translates to:
  /// **'邮箱格式不正确'**
  String get invalidEmailFormat;

  /// No description provided for @emailAlreadyExists.
  ///
  /// In zh, this message translates to:
  /// **'该邮箱已被使用'**
  String get emailAlreadyExists;

  /// No description provided for @password.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In zh, this message translates to:
  /// **'确认密码'**
  String get confirmPassword;

  /// No description provided for @username.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get username;

  /// No description provided for @forgotPassword.
  ///
  /// In zh, this message translates to:
  /// **'忘记密码?'**
  String get forgotPassword;

  /// No description provided for @welcome.
  ///
  /// In zh, this message translates to:
  /// **'欢迎'**
  String get welcome;

  /// No description provided for @search.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In zh, this message translates to:
  /// **'筛选'**
  String get filter;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get add;

  /// No description provided for @share.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get share;

  /// No description provided for @loading.
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get noData;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @success.
  ///
  /// In zh, this message translates to:
  /// **'成功'**
  String get success;

  /// No description provided for @error.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get error;

  /// No description provided for @city.
  ///
  /// In zh, this message translates to:
  /// **'城市'**
  String get city;

  /// No description provided for @citiesList.
  ///
  /// In zh, this message translates to:
  /// **'城市列表'**
  String get citiesList;

  /// No description provided for @cityDetail.
  ///
  /// In zh, this message translates to:
  /// **'城市详情'**
  String get cityDetail;

  /// No description provided for @cityCompare.
  ///
  /// In zh, this message translates to:
  /// **'城市对比'**
  String get cityCompare;

  /// No description provided for @weather.
  ///
  /// In zh, this message translates to:
  /// **'天气'**
  String get weather;

  /// No description provided for @temperature.
  ///
  /// In zh, this message translates to:
  /// **'温度'**
  String get temperature;

  /// No description provided for @coworking.
  ///
  /// In zh, this message translates to:
  /// **'共享办公'**
  String get coworking;

  /// No description provided for @coworkingSpaces.
  ///
  /// In zh, this message translates to:
  /// **'共享办公空间'**
  String get coworkingSpaces;

  /// No description provided for @venue.
  ///
  /// In zh, this message translates to:
  /// **'场地'**
  String get venue;

  /// No description provided for @member.
  ///
  /// In zh, this message translates to:
  /// **'成员'**
  String get member;

  /// No description provided for @members.
  ///
  /// In zh, this message translates to:
  /// **'成员'**
  String get members;

  /// No description provided for @meetup.
  ///
  /// In zh, this message translates to:
  /// **'聚会'**
  String get meetup;

  /// No description provided for @createMeetup.
  ///
  /// In zh, this message translates to:
  /// **'创建聚会'**
  String get createMeetup;

  /// No description provided for @editMeetup.
  ///
  /// In zh, this message translates to:
  /// **'编辑聚会'**
  String get editMeetup;

  /// No description provided for @invite.
  ///
  /// In zh, this message translates to:
  /// **'邀请'**
  String get invite;

  /// No description provided for @inviteToMeetup.
  ///
  /// In zh, this message translates to:
  /// **'邀请参加聚会'**
  String get inviteToMeetup;

  /// No description provided for @selectMeetup.
  ///
  /// In zh, this message translates to:
  /// **'选择聚会'**
  String get selectMeetup;

  /// No description provided for @sendInvitation.
  ///
  /// In zh, this message translates to:
  /// **'发送邀请'**
  String get sendInvitation;

  /// No description provided for @userIsOrganizer.
  ///
  /// In zh, this message translates to:
  /// **'用户是活动创建者'**
  String get userIsOrganizer;

  /// No description provided for @userAlreadyJoined.
  ///
  /// In zh, this message translates to:
  /// **'用户已加入'**
  String get userAlreadyJoined;

  /// No description provided for @date.
  ///
  /// In zh, this message translates to:
  /// **'日期'**
  String get date;

  /// No description provided for @time.
  ///
  /// In zh, this message translates to:
  /// **'时间'**
  String get time;

  /// No description provided for @location.
  ///
  /// In zh, this message translates to:
  /// **'位置'**
  String get location;

  /// No description provided for @description.
  ///
  /// In zh, this message translates to:
  /// **'描述'**
  String get description;

  /// No description provided for @participants.
  ///
  /// In zh, this message translates to:
  /// **'参与者'**
  String get participants;

  /// No description provided for @favorites.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get favorites;

  /// No description provided for @addToFavorites.
  ///
  /// In zh, this message translates to:
  /// **'添加到收藏'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In zh, this message translates to:
  /// **'从收藏移除'**
  String get removeFromFavorites;

  /// No description provided for @cost.
  ///
  /// In zh, this message translates to:
  /// **'费用'**
  String get cost;

  /// No description provided for @addCost.
  ///
  /// In zh, this message translates to:
  /// **'添加费用'**
  String get addCost;

  /// No description provided for @category.
  ///
  /// In zh, this message translates to:
  /// **'分类'**
  String get category;

  /// No description provided for @amount.
  ///
  /// In zh, this message translates to:
  /// **'金额'**
  String get amount;

  /// No description provided for @currency.
  ///
  /// In zh, this message translates to:
  /// **'货币'**
  String get currency;

  /// No description provided for @food.
  ///
  /// In zh, this message translates to:
  /// **'饮食'**
  String get food;

  /// No description provided for @transport.
  ///
  /// In zh, this message translates to:
  /// **'交通'**
  String get transport;

  /// No description provided for @accommodation.
  ///
  /// In zh, this message translates to:
  /// **'住宿'**
  String get accommodation;

  /// No description provided for @shopping.
  ///
  /// In zh, this message translates to:
  /// **'购物'**
  String get shopping;

  /// No description provided for @entertainment.
  ///
  /// In zh, this message translates to:
  /// **'娱乐'**
  String get entertainment;

  /// No description provided for @other.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get other;

  /// No description provided for @total.
  ///
  /// In zh, this message translates to:
  /// **'总计'**
  String get total;

  /// No description provided for @analytics.
  ///
  /// In zh, this message translates to:
  /// **'分析'**
  String get analytics;

  /// No description provided for @statistics.
  ///
  /// In zh, this message translates to:
  /// **'统计'**
  String get statistics;

  /// No description provided for @chart.
  ///
  /// In zh, this message translates to:
  /// **'图表'**
  String get chart;

  /// No description provided for @aiChat.
  ///
  /// In zh, this message translates to:
  /// **'AI聊天'**
  String get aiChat;

  /// No description provided for @askAI.
  ///
  /// In zh, this message translates to:
  /// **'询问AI'**
  String get askAI;

  /// No description provided for @sendMessage.
  ///
  /// In zh, this message translates to:
  /// **'发送消息'**
  String get sendMessage;

  /// No description provided for @map.
  ///
  /// In zh, this message translates to:
  /// **'地图'**
  String get map;

  /// No description provided for @selectLocation.
  ///
  /// In zh, this message translates to:
  /// **'选择位置'**
  String get selectLocation;

  /// No description provided for @currentLocation.
  ///
  /// In zh, this message translates to:
  /// **'当前位置'**
  String get currentLocation;

  /// No description provided for @region.
  ///
  /// In zh, this message translates to:
  /// **'地区'**
  String get region;

  /// No description provided for @ranking.
  ///
  /// In zh, this message translates to:
  /// **'排名'**
  String get ranking;

  /// No description provided for @review.
  ///
  /// In zh, this message translates to:
  /// **'评价'**
  String get review;

  /// No description provided for @addReview.
  ///
  /// In zh, this message translates to:
  /// **'添加评价'**
  String get addReview;

  /// No description provided for @rating.
  ///
  /// In zh, this message translates to:
  /// **'评分'**
  String get rating;

  /// No description provided for @travelPlan.
  ///
  /// In zh, this message translates to:
  /// **'旅行计划'**
  String get travelPlan;

  /// No description provided for @createPlan.
  ///
  /// In zh, this message translates to:
  /// **'创建计划'**
  String get createPlan;

  /// No description provided for @viewPlan.
  ///
  /// In zh, this message translates to:
  /// **'查看计划'**
  String get viewPlan;

  /// No description provided for @monday.
  ///
  /// In zh, this message translates to:
  /// **'周一'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In zh, this message translates to:
  /// **'周二'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In zh, this message translates to:
  /// **'周三'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In zh, this message translates to:
  /// **'周四'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In zh, this message translates to:
  /// **'周五'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In zh, this message translates to:
  /// **'周六'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In zh, this message translates to:
  /// **'周日'**
  String get sunday;

  /// No description provided for @january.
  ///
  /// In zh, this message translates to:
  /// **'一月'**
  String get january;

  /// No description provided for @february.
  ///
  /// In zh, this message translates to:
  /// **'二月'**
  String get february;

  /// No description provided for @march.
  ///
  /// In zh, this message translates to:
  /// **'三月'**
  String get march;

  /// No description provided for @april.
  ///
  /// In zh, this message translates to:
  /// **'四月'**
  String get april;

  /// No description provided for @may.
  ///
  /// In zh, this message translates to:
  /// **'五月'**
  String get may;

  /// No description provided for @june.
  ///
  /// In zh, this message translates to:
  /// **'六月'**
  String get june;

  /// No description provided for @july.
  ///
  /// In zh, this message translates to:
  /// **'七月'**
  String get july;

  /// No description provided for @august.
  ///
  /// In zh, this message translates to:
  /// **'八月'**
  String get august;

  /// No description provided for @september.
  ///
  /// In zh, this message translates to:
  /// **'九月'**
  String get september;

  /// No description provided for @october.
  ///
  /// In zh, this message translates to:
  /// **'十月'**
  String get october;

  /// No description provided for @november.
  ///
  /// In zh, this message translates to:
  /// **'十一月'**
  String get november;

  /// No description provided for @december.
  ///
  /// In zh, this message translates to:
  /// **'十二月'**
  String get december;

  /// No description provided for @today.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In zh, this message translates to:
  /// **'昨天'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In zh, this message translates to:
  /// **'明天'**
  String get tomorrow;

  /// No description provided for @thisWeek.
  ///
  /// In zh, this message translates to:
  /// **'本周'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In zh, this message translates to:
  /// **'本月'**
  String get thisMonth;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @back.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get back;

  /// No description provided for @next.
  ///
  /// In zh, this message translates to:
  /// **'下一步'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In zh, this message translates to:
  /// **'上一步'**
  String get previous;

  /// No description provided for @refresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get refresh;

  /// No description provided for @more.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get more;

  /// No description provided for @less.
  ///
  /// In zh, this message translates to:
  /// **'收起'**
  String get less;

  /// No description provided for @all.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get all;

  /// No description provided for @selectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In zh, this message translates to:
  /// **'取消全选'**
  String get deselectAll;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// 语言选择项：中文
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get languageOptionChinese;

  /// 语言选择项：英文
  ///
  /// In zh, this message translates to:
  /// **'英文'**
  String get languageOptionEnglish;

  /// No description provided for @theme.
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In zh, this message translates to:
  /// **'浅色模式'**
  String get lightMode;

  /// No description provided for @notifications.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In zh, this message translates to:
  /// **'隐私'**
  String get privacy;

  /// No description provided for @termsOfService.
  ///
  /// In zh, this message translates to:
  /// **'服务条款'**
  String get termsOfService;

  /// No description provided for @about.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// No description provided for @createdBy.
  ///
  /// In zh, this message translates to:
  /// **'创建者'**
  String get createdBy;

  /// No description provided for @version.
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get version;

  /// No description provided for @help.
  ///
  /// In zh, this message translates to:
  /// **'帮助'**
  String get help;

  /// No description provided for @contact.
  ///
  /// In zh, this message translates to:
  /// **'联系人'**
  String get contact;

  /// No description provided for @feedback.
  ///
  /// In zh, this message translates to:
  /// **'反馈'**
  String get feedback;

  /// No description provided for @userNotFound.
  ///
  /// In zh, this message translates to:
  /// **'用户未找到'**
  String get userNotFound;

  /// No description provided for @editProfile.
  ///
  /// In zh, this message translates to:
  /// **'编辑资料'**
  String get editProfile;

  /// No description provided for @profileEditingComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'资料编辑功能即将推出'**
  String get profileEditingComingSoon;

  /// No description provided for @editModeEnabled.
  ///
  /// In zh, this message translates to:
  /// **'编辑模式已启用，您可以添加或删除技能和兴趣爱好'**
  String get editModeEnabled;

  /// No description provided for @editModeSaved.
  ///
  /// In zh, this message translates to:
  /// **'更改已保存'**
  String get editModeSaved;

  /// No description provided for @addSkill.
  ///
  /// In zh, this message translates to:
  /// **'添加技能'**
  String get addSkill;

  /// No description provided for @addInterest.
  ///
  /// In zh, this message translates to:
  /// **'添加兴趣'**
  String get addInterest;

  /// No description provided for @enterSkillName.
  ///
  /// In zh, this message translates to:
  /// **'输入技能名称'**
  String get enterSkillName;

  /// No description provided for @enterInterestName.
  ///
  /// In zh, this message translates to:
  /// **'输入兴趣名称'**
  String get enterInterestName;

  /// No description provided for @myTravelPlans.
  ///
  /// In zh, this message translates to:
  /// **'我的旅行计划'**
  String get myTravelPlans;

  /// No description provided for @aiGenerated.
  ///
  /// In zh, this message translates to:
  /// **'AI 生成'**
  String get aiGenerated;

  /// No description provided for @stats.
  ///
  /// In zh, this message translates to:
  /// **'统计'**
  String get stats;

  /// No description provided for @badges.
  ///
  /// In zh, this message translates to:
  /// **'徽章'**
  String get badges;

  /// No description provided for @skills.
  ///
  /// In zh, this message translates to:
  /// **'技能'**
  String get skills;

  /// No description provided for @interests.
  ///
  /// In zh, this message translates to:
  /// **'兴趣爱好'**
  String get interests;

  /// No description provided for @selectSkills.
  ///
  /// In zh, this message translates to:
  /// **'选择技能'**
  String get selectSkills;

  /// No description provided for @selectInterests.
  ///
  /// In zh, this message translates to:
  /// **'选择您的兴趣(最多5个)'**
  String get selectInterests;

  /// No description provided for @searchSkillsHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索技能...'**
  String get searchSkillsHint;

  /// No description provided for @searchInterestsHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索兴趣...'**
  String get searchInterestsHint;

  /// No description provided for @noSkills.
  ///
  /// In zh, this message translates to:
  /// **'暂无技能'**
  String get noSkills;

  /// No description provided for @noMatchingSkills.
  ///
  /// In zh, this message translates to:
  /// **'未找到匹配的技能'**
  String get noMatchingSkills;

  /// No description provided for @noInterests.
  ///
  /// In zh, this message translates to:
  /// **'暂无兴趣'**
  String get noInterests;

  /// No description provided for @noMatchingInterests.
  ///
  /// In zh, this message translates to:
  /// **'未找到匹配的兴趣'**
  String get noMatchingInterests;

  /// No description provided for @failedToLoadSkillsList.
  ///
  /// In zh, this message translates to:
  /// **'无法加载技能列表'**
  String get failedToLoadSkillsList;

  /// No description provided for @failedToLoadInterestsList.
  ///
  /// In zh, this message translates to:
  /// **'无法加载兴趣列表'**
  String get failedToLoadInterestsList;

  /// No description provided for @itemUnit.
  ///
  /// In zh, this message translates to:
  /// **'项'**
  String get itemUnit;

  /// No description provided for @yearsAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count}年前'**
  String yearsAgo(int count);

  /// No description provided for @profileNotificationPermissionTitle.
  ///
  /// In zh, this message translates to:
  /// **'需要通知权限'**
  String get profileNotificationPermissionTitle;

  /// No description provided for @profileNotificationPermissionMessage.
  ///
  /// In zh, this message translates to:
  /// **'请在系统设置中开启通知权限，以便接收重要消息提醒。'**
  String get profileNotificationPermissionMessage;

  /// No description provided for @profileGoToSettings.
  ///
  /// In zh, this message translates to:
  /// **'去设置'**
  String get profileGoToSettings;

  /// No description provided for @profileRolesManagement.
  ///
  /// In zh, this message translates to:
  /// **'🔐 管理员权限管理'**
  String get profileRolesManagement;

  /// No description provided for @profileSelectedUsers.
  ///
  /// In zh, this message translates to:
  /// **'已选择 {count} 人'**
  String profileSelectedUsers(int count);

  /// No description provided for @profileRolesNotLoadedWarning.
  ///
  /// In zh, this message translates to:
  /// **'⚠️ 角色数据未加载，批量操作功能受限\n请确认后端 /api/v1/roles 接口已正确配置'**
  String get profileRolesNotLoadedWarning;

  /// No description provided for @profileSetAsAdmin.
  ///
  /// In zh, this message translates to:
  /// **'设为管理员'**
  String get profileSetAsAdmin;

  /// No description provided for @profileSetAsNormalUser.
  ///
  /// In zh, this message translates to:
  /// **'设为普通用户'**
  String get profileSetAsNormalUser;

  /// No description provided for @profileToggleSelectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选/取消全选'**
  String get profileToggleSelectAll;

  /// No description provided for @profileNoUsers.
  ///
  /// In zh, this message translates to:
  /// **'暂无用户'**
  String get profileNoUsers;

  /// No description provided for @profileJoinedAt.
  ///
  /// In zh, this message translates to:
  /// **'加入于 {time}'**
  String profileJoinedAt(String time);

  /// No description provided for @profileRoleAdmin.
  ///
  /// In zh, this message translates to:
  /// **'管理员'**
  String get profileRoleAdmin;

  /// No description provided for @profileRoleModerator.
  ///
  /// In zh, this message translates to:
  /// **'版主'**
  String get profileRoleModerator;

  /// No description provided for @profileRoleUser.
  ///
  /// In zh, this message translates to:
  /// **'用户'**
  String get profileRoleUser;

  /// No description provided for @profileSelectUsersFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先选择要设置的用户'**
  String get profileSelectUsersFirst;

  /// No description provided for @profileBatchSetAdminSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已成功将 {count} 个用户设为管理员'**
  String profileBatchSetAdminSuccess(int count);

  /// No description provided for @profileBatchSetAdminFailed.
  ///
  /// In zh, this message translates to:
  /// **'批量设置管理员失败'**
  String get profileBatchSetAdminFailed;

  /// No description provided for @profileBatchSetUserSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已成功将 {count} 个用户设为普通用户'**
  String profileBatchSetUserSuccess(int count);

  /// No description provided for @profileBatchSetUserFailed.
  ///
  /// In zh, this message translates to:
  /// **'批量设置用户失败'**
  String get profileBatchSetUserFailed;

  /// No description provided for @profileAddedCount.
  ///
  /// In zh, this message translates to:
  /// **'添加 {count} 个'**
  String profileAddedCount(int count);

  /// No description provided for @profileRemovedCount.
  ///
  /// In zh, this message translates to:
  /// **'移除 {count} 个'**
  String profileRemovedCount(int count);

  /// No description provided for @profileSupabaseNotConfigured.
  ///
  /// In zh, this message translates to:
  /// **'Supabase 未配置，请联系管理员'**
  String get profileSupabaseNotConfigured;

  /// No description provided for @profileAvatarUploadFailed.
  ///
  /// In zh, this message translates to:
  /// **'头像上传失败: {error}'**
  String profileAvatarUploadFailed(String error);

  /// No description provided for @manageCityRatingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'{cityName} - 评分数据'**
  String manageCityRatingsTitle(String cityName);

  /// No description provided for @manageCityRatingsAddItem.
  ///
  /// In zh, this message translates to:
  /// **'添加评分项'**
  String get manageCityRatingsAddItem;

  /// No description provided for @manageCityRatingsNameZh.
  ///
  /// In zh, this message translates to:
  /// **'评分项名称（中文）'**
  String get manageCityRatingsNameZh;

  /// No description provided for @manageCityRatingsNameZhHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：美食'**
  String get manageCityRatingsNameZhHint;

  /// No description provided for @manageCityRatingsNameEn.
  ///
  /// In zh, this message translates to:
  /// **'评分项名称（英文）'**
  String get manageCityRatingsNameEn;

  /// No description provided for @manageCityRatingsNameEnHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：Food'**
  String get manageCityRatingsNameEnHint;

  /// No description provided for @manageCityRatingsDescriptionOptional.
  ///
  /// In zh, this message translates to:
  /// **'描述（可选）'**
  String get manageCityRatingsDescriptionOptional;

  /// No description provided for @manageCityRatingsDescriptionHint.
  ///
  /// In zh, this message translates to:
  /// **'简短描述'**
  String get manageCityRatingsDescriptionHint;

  /// No description provided for @manageCityRatingsIcon.
  ///
  /// In zh, this message translates to:
  /// **'图标'**
  String get manageCityRatingsIcon;

  /// No description provided for @manageCityRatingsIconStar.
  ///
  /// In zh, this message translates to:
  /// **'星星'**
  String get manageCityRatingsIconStar;

  /// No description provided for @manageCityRatingsIconRestaurant.
  ///
  /// In zh, this message translates to:
  /// **'餐厅'**
  String get manageCityRatingsIconRestaurant;

  /// No description provided for @manageCityRatingsIconNetwork.
  ///
  /// In zh, this message translates to:
  /// **'网络'**
  String get manageCityRatingsIconNetwork;

  /// No description provided for @manageCityRatingsIconSafety.
  ///
  /// In zh, this message translates to:
  /// **'安全'**
  String get manageCityRatingsIconSafety;

  /// No description provided for @manageCityRatingsIconTransport.
  ///
  /// In zh, this message translates to:
  /// **'交通'**
  String get manageCityRatingsIconTransport;

  /// No description provided for @manageCityRatingsIconHealthcare.
  ///
  /// In zh, this message translates to:
  /// **'医疗'**
  String get manageCityRatingsIconHealthcare;

  /// No description provided for @manageCityRatingsIconWeather.
  ///
  /// In zh, this message translates to:
  /// **'天气'**
  String get manageCityRatingsIconWeather;

  /// No description provided for @manageCityRatingsIconCost.
  ///
  /// In zh, this message translates to:
  /// **'成本'**
  String get manageCityRatingsIconCost;

  /// No description provided for @manageCityRatingsIconPeople.
  ///
  /// In zh, this message translates to:
  /// **'人群'**
  String get manageCityRatingsIconPeople;

  /// No description provided for @manageCityRatingsIconLanguage.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get manageCityRatingsIconLanguage;

  /// No description provided for @manageCityRatingsDeleteItem.
  ///
  /// In zh, this message translates to:
  /// **'删除评分项'**
  String get manageCityRatingsDeleteItem;

  /// No description provided for @manageCityRatingsDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除“{name}”吗？'**
  String manageCityRatingsDeleteConfirm(String name);

  /// No description provided for @manageCityRatingsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'{nameEn} • 评分: {average} ({count}人)'**
  String manageCityRatingsSubtitle(String nameEn, String average, int count);

  /// No description provided for @defaultStatus.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get defaultStatus;

  /// No description provided for @manageCityRatingsEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'暂无评分项'**
  String get manageCityRatingsEmptyTitle;

  /// No description provided for @manageCityRatingsEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'点击右上角加号，添加第一个评分项'**
  String get manageCityRatingsEmptyHint;

  /// No description provided for @editBasicInfoTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑基本信息'**
  String get editBasicInfoTitle;

  /// No description provided for @editBasicInfoGender.
  ///
  /// In zh, this message translates to:
  /// **'性别'**
  String get editBasicInfoGender;

  /// No description provided for @editBasicInfoGenderMale.
  ///
  /// In zh, this message translates to:
  /// **'男'**
  String get editBasicInfoGenderMale;

  /// No description provided for @editBasicInfoGenderFemale.
  ///
  /// In zh, this message translates to:
  /// **'女'**
  String get editBasicInfoGenderFemale;

  /// No description provided for @editBasicInfoGenderPreferNotToSay.
  ///
  /// In zh, this message translates to:
  /// **'不愿透露'**
  String get editBasicInfoGenderPreferNotToSay;

  /// No description provided for @editBasicInfoCurrentCity.
  ///
  /// In zh, this message translates to:
  /// **'当前城市'**
  String get editBasicInfoCurrentCity;

  /// No description provided for @editBasicInfoCityHint.
  ///
  /// In zh, this message translates to:
  /// **'例如: Bangkok'**
  String get editBasicInfoCityHint;

  /// No description provided for @editBasicInfoCurrentCountry.
  ///
  /// In zh, this message translates to:
  /// **'当前国家'**
  String get editBasicInfoCurrentCountry;

  /// No description provided for @editBasicInfoCountryHint.
  ///
  /// In zh, this message translates to:
  /// **'例如: Thailand'**
  String get editBasicInfoCountryHint;

  /// No description provided for @editBasicInfoOccupation.
  ///
  /// In zh, this message translates to:
  /// **'职业'**
  String get editBasicInfoOccupation;

  /// No description provided for @editBasicInfoOccupationHint.
  ///
  /// In zh, this message translates to:
  /// **'例如: Software Engineer'**
  String get editBasicInfoOccupationHint;

  /// No description provided for @editBasicInfoCompany.
  ///
  /// In zh, this message translates to:
  /// **'公司'**
  String get editBasicInfoCompany;

  /// No description provided for @editBasicInfoCompanyHint.
  ///
  /// In zh, this message translates to:
  /// **'例如: Google'**
  String get editBasicInfoCompanyHint;

  /// No description provided for @editBasicInfoWebsite.
  ///
  /// In zh, this message translates to:
  /// **'个人网站'**
  String get editBasicInfoWebsite;

  /// No description provided for @editBasicInfoWebsiteHint.
  ///
  /// In zh, this message translates to:
  /// **'https://yourwebsite.com'**
  String get editBasicInfoWebsiteHint;

  /// No description provided for @modularProfileTitle.
  ///
  /// In zh, this message translates to:
  /// **'用户资料'**
  String get modularProfileTitle;

  /// No description provided for @modularProfileNameUnset.
  ///
  /// In zh, this message translates to:
  /// **'未设置姓名'**
  String get modularProfileNameUnset;

  /// No description provided for @modularProfileOccupationUnset.
  ///
  /// In zh, this message translates to:
  /// **'未设置职业'**
  String get modularProfileOccupationUnset;

  /// No description provided for @modularProfileStatsTitle.
  ///
  /// In zh, this message translates to:
  /// **'Nomad 统计'**
  String get modularProfileStatsTitle;

  /// No description provided for @modularProfileStatCountries.
  ///
  /// In zh, this message translates to:
  /// **'国家'**
  String get modularProfileStatCountries;

  /// No description provided for @modularProfileStatCities.
  ///
  /// In zh, this message translates to:
  /// **'城市'**
  String get modularProfileStatCities;

  /// No description provided for @modularProfileStatDays.
  ///
  /// In zh, this message translates to:
  /// **'旅行天数'**
  String get modularProfileStatDays;

  /// No description provided for @modularProfileStatMeetups.
  ///
  /// In zh, this message translates to:
  /// **'Meetup'**
  String get modularProfileStatMeetups;

  /// No description provided for @modularProfileStatTrips.
  ///
  /// In zh, this message translates to:
  /// **'行程'**
  String get modularProfileStatTrips;

  /// No description provided for @modularProfileStatReviews.
  ///
  /// In zh, this message translates to:
  /// **'评论'**
  String get modularProfileStatReviews;

  /// No description provided for @modularProfileModuleBasicInfo.
  ///
  /// In zh, this message translates to:
  /// **'基本信息'**
  String get modularProfileModuleBasicInfo;

  /// No description provided for @modularProfileBasicInfoSummary.
  ///
  /// In zh, this message translates to:
  /// **'{name} · {occupation}'**
  String modularProfileBasicInfoSummary(String name, String occupation);

  /// No description provided for @modularProfileTapToEditBasicInfo.
  ///
  /// In zh, this message translates to:
  /// **'点击编辑基本信息'**
  String get modularProfileTapToEditBasicInfo;

  /// No description provided for @modularProfileModuleSkills.
  ///
  /// In zh, this message translates to:
  /// **'技能标签'**
  String get modularProfileModuleSkills;

  /// No description provided for @modularProfileTapToAddSkills.
  ///
  /// In zh, this message translates to:
  /// **'点击添加技能标签'**
  String get modularProfileTapToAddSkills;

  /// No description provided for @modularProfileSkillsSummary.
  ///
  /// In zh, this message translates to:
  /// **'{count} 项技能: {names}'**
  String modularProfileSkillsSummary(int count, String names);

  /// No description provided for @modularProfileModuleInterests.
  ///
  /// In zh, this message translates to:
  /// **'兴趣爱好'**
  String get modularProfileModuleInterests;

  /// No description provided for @modularProfileTapToAddInterests.
  ///
  /// In zh, this message translates to:
  /// **'点击添加兴趣爱好'**
  String get modularProfileTapToAddInterests;

  /// No description provided for @modularProfileInterestsSummary.
  ///
  /// In zh, this message translates to:
  /// **'{count} 项兴趣: {names}'**
  String modularProfileInterestsSummary(int count, String names);

  /// No description provided for @modularProfileModuleSocialLinks.
  ///
  /// In zh, this message translates to:
  /// **'社交链接'**
  String get modularProfileModuleSocialLinks;

  /// No description provided for @modularProfileTapToAddSocialLinks.
  ///
  /// In zh, this message translates to:
  /// **'点击添加社交平台链接'**
  String get modularProfileTapToAddSocialLinks;

  /// No description provided for @modularProfileSocialLinksCount.
  ///
  /// In zh, this message translates to:
  /// **'已添加 {count} 个平台'**
  String modularProfileSocialLinksCount(int count);

  /// No description provided for @modularProfileModuleTravelPlans.
  ///
  /// In zh, this message translates to:
  /// **'旅行计划'**
  String get modularProfileModuleTravelPlans;

  /// No description provided for @modularProfileNoTravelPlans.
  ///
  /// In zh, this message translates to:
  /// **'暂无旅行计划'**
  String get modularProfileNoTravelPlans;

  /// No description provided for @modularProfileTravelPlansCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个计划'**
  String modularProfileTravelPlansCount(int count);

  /// No description provided for @modularProfileTravelPlansComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'旅行计划功能开发中'**
  String get modularProfileTravelPlansComingSoon;

  /// No description provided for @modularProfileModuleBadges.
  ///
  /// In zh, this message translates to:
  /// **'成就徽章'**
  String get modularProfileModuleBadges;

  /// No description provided for @modularProfileNoBadges.
  ///
  /// In zh, this message translates to:
  /// **'暂无徽章'**
  String get modularProfileNoBadges;

  /// No description provided for @modularProfileBadgesCount.
  ///
  /// In zh, this message translates to:
  /// **'已获得 {count} 个徽章'**
  String modularProfileBadgesCount(int count);

  /// No description provided for @modularProfileBadgesComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'徽章功能开发中'**
  String get modularProfileBadgesComingSoon;

  /// No description provided for @modularProfileModuleHistory.
  ///
  /// In zh, this message translates to:
  /// **'旅行历史'**
  String get modularProfileModuleHistory;

  /// No description provided for @modularProfileNoHistory.
  ///
  /// In zh, this message translates to:
  /// **'暂无旅行记录'**
  String get modularProfileNoHistory;

  /// No description provided for @modularProfileHistoryCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条记录'**
  String modularProfileHistoryCount(int count);

  /// No description provided for @modularProfileHistoryComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'旅行历史功能开发中'**
  String get modularProfileHistoryComingSoon;

  /// No description provided for @uploading.
  ///
  /// In zh, this message translates to:
  /// **'上传中...'**
  String get uploading;

  /// No description provided for @confirmDelete.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get confirmDelete;

  /// No description provided for @addHotelRoomTypesTitle.
  ///
  /// In zh, this message translates to:
  /// **'房型管理'**
  String get addHotelRoomTypesTitle;

  /// No description provided for @addHotelAddRoomType.
  ///
  /// In zh, this message translates to:
  /// **'添加房型'**
  String get addHotelAddRoomType;

  /// No description provided for @addHotelEditRoomType.
  ///
  /// In zh, this message translates to:
  /// **'编辑房型'**
  String get addHotelEditRoomType;

  /// No description provided for @addHotelRoomTypesHint.
  ///
  /// In zh, this message translates to:
  /// **'添加不同的房型及价格（可选）'**
  String get addHotelRoomTypesHint;

  /// No description provided for @addHotelNoRoomTypes.
  ///
  /// In zh, this message translates to:
  /// **'暂无房型'**
  String get addHotelNoRoomTypes;

  /// No description provided for @addHotelTapToAddRoomType.
  ///
  /// In zh, this message translates to:
  /// **'点击上方按钮添加房型'**
  String get addHotelTapToAddRoomType;

  /// No description provided for @addHotelUnnamedRoomType.
  ///
  /// In zh, this message translates to:
  /// **'未命名房型'**
  String get addHotelUnnamedRoomType;

  /// No description provided for @addHotelPricePerNightChip.
  ///
  /// In zh, this message translates to:
  /// **'{currency} {price}/晚'**
  String addHotelPricePerNightChip(String currency, Object price);

  /// No description provided for @addHotelMaxOccupancyChip.
  ///
  /// In zh, this message translates to:
  /// **'最多{count}人'**
  String addHotelMaxOccupancyChip(Object count);

  /// No description provided for @addHotelAvailableRoomsChip.
  ///
  /// In zh, this message translates to:
  /// **'{count}间'**
  String addHotelAvailableRoomsChip(Object count);

  /// No description provided for @addHotelRoomTypeName.
  ///
  /// In zh, this message translates to:
  /// **'房型名称'**
  String get addHotelRoomTypeName;

  /// No description provided for @addHotelRoomTypeNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：标准双人间'**
  String get addHotelRoomTypeNameHint;

  /// No description provided for @addHotelRoomTypeDescription.
  ///
  /// In zh, this message translates to:
  /// **'房型描述'**
  String get addHotelRoomTypeDescription;

  /// No description provided for @addHotelRoomTypeDescriptionHint.
  ///
  /// In zh, this message translates to:
  /// **'房间设施、特色等'**
  String get addHotelRoomTypeDescriptionHint;

  /// No description provided for @addHotelRoomSize.
  ///
  /// In zh, this message translates to:
  /// **'面积(㎡)'**
  String get addHotelRoomSize;

  /// No description provided for @addHotelMaxOccupancy.
  ///
  /// In zh, this message translates to:
  /// **'最大入住'**
  String get addHotelMaxOccupancy;

  /// No description provided for @addHotelBedType.
  ///
  /// In zh, this message translates to:
  /// **'床型'**
  String get addHotelBedType;

  /// No description provided for @addHotelAvailableRooms.
  ///
  /// In zh, this message translates to:
  /// **'可用房间数'**
  String get addHotelAvailableRooms;

  /// No description provided for @addHotelBedTypeSingle.
  ///
  /// In zh, this message translates to:
  /// **'Single'**
  String get addHotelBedTypeSingle;

  /// No description provided for @addHotelBedTypeDouble.
  ///
  /// In zh, this message translates to:
  /// **'Double'**
  String get addHotelBedTypeDouble;

  /// No description provided for @addHotelBedTypeQueen.
  ///
  /// In zh, this message translates to:
  /// **'Queen'**
  String get addHotelBedTypeQueen;

  /// No description provided for @addHotelBedTypeKing.
  ///
  /// In zh, this message translates to:
  /// **'King'**
  String get addHotelBedTypeKing;

  /// No description provided for @addHotelBedTypeTwin.
  ///
  /// In zh, this message translates to:
  /// **'Twin'**
  String get addHotelBedTypeTwin;

  /// No description provided for @addHotelBedTypeBunk.
  ///
  /// In zh, this message translates to:
  /// **'Bunk'**
  String get addHotelBedTypeBunk;

  /// No description provided for @addHotelEnterRoomTypeName.
  ///
  /// In zh, this message translates to:
  /// **'请输入房型名称'**
  String get addHotelEnterRoomTypeName;

  /// No description provided for @addHotelEnterPricePerNight.
  ///
  /// In zh, this message translates to:
  /// **'请输入每晚价格'**
  String get addHotelEnterPricePerNight;

  /// No description provided for @addHotelRoomTypeUpdated.
  ///
  /// In zh, this message translates to:
  /// **'房型已更新'**
  String get addHotelRoomTypeUpdated;

  /// No description provided for @addHotelRoomTypeAdded.
  ///
  /// In zh, this message translates to:
  /// **'房型已添加'**
  String get addHotelRoomTypeAdded;

  /// No description provided for @addHotelDeleteRoomTypeConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除房型 \"{name}\" 吗？'**
  String addHotelDeleteRoomTypeConfirm(String name);

  /// No description provided for @addHotelRoomTypeDeleted.
  ///
  /// In zh, this message translates to:
  /// **'房型已删除'**
  String get addHotelRoomTypeDeleted;

  /// No description provided for @editSocialLinksUrl.
  ///
  /// In zh, this message translates to:
  /// **'链接地址'**
  String get editSocialLinksUrl;

  /// No description provided for @editSocialLinksExample.
  ///
  /// In zh, this message translates to:
  /// **'示例: {pattern}'**
  String editSocialLinksExample(String pattern);

  /// No description provided for @editSocialLinksTapToAdd.
  ///
  /// In zh, this message translates to:
  /// **'点击添加'**
  String get editSocialLinksTapToAdd;

  /// No description provided for @editSocialLinksAddedCount.
  ///
  /// In zh, this message translates to:
  /// **'已添加 {count} / {total} 个平台'**
  String editSocialLinksAddedCount(int count, int total);

  /// No description provided for @directChatJustNow.
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get directChatJustNow;

  /// No description provided for @directChatMinutesAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count}分钟前'**
  String directChatMinutesAgo(int count);

  /// No description provided for @directChatHoursAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count}小时前'**
  String directChatHoursAgo(int count);

  /// No description provided for @directChatDaysAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count}天前'**
  String directChatDaysAgo(int count);

  /// No description provided for @directChatPickLocationFailed.
  ///
  /// In zh, this message translates to:
  /// **'选择位置失败: {error}'**
  String directChatPickLocationFailed(String error);

  /// No description provided for @directChatSendFileFailed.
  ///
  /// In zh, this message translates to:
  /// **'发送文件失败: {error}'**
  String directChatSendFileFailed(String error);

  /// No description provided for @directChatVoiceFileMissing.
  ///
  /// In zh, this message translates to:
  /// **'语音文件不存在'**
  String get directChatVoiceFileMissing;

  /// No description provided for @directChatVoiceMessageText.
  ///
  /// In zh, this message translates to:
  /// **'语音消息'**
  String get directChatVoiceMessageText;

  /// No description provided for @directChatSendVoiceFailed.
  ///
  /// In zh, this message translates to:
  /// **'发送语音失败: {error}'**
  String directChatSendVoiceFailed(String error);

  /// No description provided for @directChatVoiceMessageUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'语音消息不可用'**
  String get directChatVoiceMessageUnavailable;

  /// No description provided for @directChatFileFallback.
  ///
  /// In zh, this message translates to:
  /// **'文件'**
  String get directChatFileFallback;

  /// No description provided for @directChatChooseMapNavigation.
  ///
  /// In zh, this message translates to:
  /// **'选择地图导航'**
  String get directChatChooseMapNavigation;

  /// No description provided for @directChatMapApple.
  ///
  /// In zh, this message translates to:
  /// **'Apple 地图'**
  String get directChatMapApple;

  /// No description provided for @directChatMapGoogle.
  ///
  /// In zh, this message translates to:
  /// **'Google 地图'**
  String get directChatMapGoogle;

  /// No description provided for @directChatMapAmap.
  ///
  /// In zh, this message translates to:
  /// **'高德地图'**
  String get directChatMapAmap;

  /// No description provided for @directChatMapBaidu.
  ///
  /// In zh, this message translates to:
  /// **'百度地图'**
  String get directChatMapBaidu;

  /// No description provided for @directChatMapTencent.
  ///
  /// In zh, this message translates to:
  /// **'腾讯地图'**
  String get directChatMapTencent;

  /// No description provided for @directChatMapNotInstalled.
  ///
  /// In zh, this message translates to:
  /// **'未安装{mapName}'**
  String directChatMapNotInstalled(String mapName);

  /// No description provided for @directChatImageLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'图片加载失败'**
  String get directChatImageLoadFailed;

  /// No description provided for @directChatSaveComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'保存功能即将推出'**
  String get directChatSaveComingSoon;

  /// No description provided for @directChatShareComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'分享功能即将推出'**
  String get directChatShareComingSoon;

  /// No description provided for @tencentImConnectFailedRetry.
  ///
  /// In zh, this message translates to:
  /// **'连接失败，请重试'**
  String get tencentImConnectFailedRetry;

  /// No description provided for @tencentImImportUserFailed.
  ///
  /// In zh, this message translates to:
  /// **'用户导入失败，消息可能无法送达'**
  String get tencentImImportUserFailed;

  /// No description provided for @tencentImNoMessages.
  ///
  /// In zh, this message translates to:
  /// **'暂无消息'**
  String get tencentImNoMessages;

  /// No description provided for @tencentImFileFallback.
  ///
  /// In zh, this message translates to:
  /// **'文件'**
  String get tencentImFileFallback;

  /// No description provided for @tencentImMessageFallback.
  ///
  /// In zh, this message translates to:
  /// **'[消息]'**
  String get tencentImMessageFallback;

  /// No description provided for @tencentImImageFallback.
  ///
  /// In zh, this message translates to:
  /// **'[图片]'**
  String get tencentImImageFallback;

  /// No description provided for @tencentImLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get tencentImLoadFailed;

  /// No description provided for @tencentImOpenFile.
  ///
  /// In zh, this message translates to:
  /// **'打开文件'**
  String get tencentImOpenFile;

  /// No description provided for @cityChatCreateRoomComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'创建聊天室功能即将推出'**
  String get cityChatCreateRoomComingSoon;

  /// No description provided for @cityChatSaySomething.
  ///
  /// In zh, this message translates to:
  /// **'说点什么...'**
  String get cityChatSaySomething;

  /// No description provided for @cityChatViewMembers.
  ///
  /// In zh, this message translates to:
  /// **'查看成员'**
  String get cityChatViewMembers;

  /// No description provided for @cityChatSearchRecords.
  ///
  /// In zh, this message translates to:
  /// **'搜索聊天记录'**
  String get cityChatSearchRecords;

  /// No description provided for @cityChatDoNotDisturb.
  ///
  /// In zh, this message translates to:
  /// **'消息免打扰'**
  String get cityChatDoNotDisturb;

  /// No description provided for @cityChatDoNotDisturbEnabled.
  ///
  /// In zh, this message translates to:
  /// **'已开启消息免打扰'**
  String get cityChatDoNotDisturbEnabled;

  /// No description provided for @cityChatExitRoom.
  ///
  /// In zh, this message translates to:
  /// **'退出聊天室'**
  String get cityChatExitRoom;

  /// No description provided for @cityChatLocatedMessage.
  ///
  /// In zh, this message translates to:
  /// **'已定位到消息'**
  String get cityChatLocatedMessage;

  /// No description provided for @cityChatMessageOutOfRange.
  ///
  /// In zh, this message translates to:
  /// **'消息不在当前加载范围内，请加载更多历史消息'**
  String get cityChatMessageOutOfRange;

  /// No description provided for @cityChatSearchMessageContent.
  ///
  /// In zh, this message translates to:
  /// **'搜索消息内容...'**
  String get cityChatSearchMessageContent;

  /// No description provided for @dataServiceLoginToAccessFeature.
  ///
  /// In zh, this message translates to:
  /// **'请先登录再使用此功能'**
  String get dataServiceLoginToAccessFeature;

  /// No description provided for @dataServiceInvalidSession.
  ///
  /// In zh, this message translates to:
  /// **'会话无效，请重新登录。'**
  String get dataServiceInvalidSession;

  /// No description provided for @dataServiceAuthenticationError.
  ///
  /// In zh, this message translates to:
  /// **'认证错误'**
  String get dataServiceAuthenticationError;

  /// No description provided for @dataServiceSessionExpiredMessage.
  ///
  /// In zh, this message translates to:
  /// **'您的会话已过期，请重新登录。'**
  String get dataServiceSessionExpiredMessage;

  /// No description provided for @dataServiceSessionExpiredTitle.
  ///
  /// In zh, this message translates to:
  /// **'会话已过期'**
  String get dataServiceSessionExpiredTitle;

  /// No description provided for @dataServiceFoundCities.
  ///
  /// In zh, this message translates to:
  /// **'找到 {count} 个城市'**
  String dataServiceFoundCities(int count);

  /// No description provided for @dataServiceSearchFailed.
  ///
  /// In zh, this message translates to:
  /// **'搜索失败'**
  String get dataServiceSearchFailed;

  /// No description provided for @dataServiceSearchCitiesHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索城市...（支持中英文搜索）'**
  String get dataServiceSearchCitiesHint;

  /// No description provided for @dataServiceClearSearch.
  ///
  /// In zh, this message translates to:
  /// **'清除搜索'**
  String get dataServiceClearSearch;

  /// No description provided for @dataServiceAlreadyJoinedMeetup.
  ///
  /// In zh, this message translates to:
  /// **'您已经加入了这个活动'**
  String get dataServiceAlreadyJoinedMeetup;

  /// No description provided for @dataServiceNotJoinedMeetup.
  ///
  /// In zh, this message translates to:
  /// **'您尚未加入这个活动'**
  String get dataServiceNotJoinedMeetup;

  /// No description provided for @dataServiceLeaveMeetupFailed.
  ///
  /// In zh, this message translates to:
  /// **'退出活动失败'**
  String get dataServiceLeaveMeetupFailed;

  /// No description provided for @dataServiceJoinMeetupFailed.
  ///
  /// In zh, this message translates to:
  /// **'加入活动失败'**
  String get dataServiceJoinMeetupFailed;

  /// No description provided for @dataServiceOperationFailed.
  ///
  /// In zh, this message translates to:
  /// **'操作失败'**
  String get dataServiceOperationFailed;

  /// No description provided for @dataServiceLoginToGenerateImages.
  ///
  /// In zh, this message translates to:
  /// **'请先登录后再生成图片'**
  String get dataServiceLoginToGenerateImages;

  /// No description provided for @dataServiceOnlyAdminOrModeratorCanGenerate.
  ///
  /// In zh, this message translates to:
  /// **'仅管理员或城市版主可生成图片'**
  String get dataServiceOnlyAdminOrModeratorCanGenerate;

  /// No description provided for @dataServiceImageTaskCreated.
  ///
  /// In zh, this message translates to:
  /// **'{cityName} 的 AI 图片生成任务已创建。\n完成后将通知您。'**
  String dataServiceImageTaskCreated(String cityName);

  /// No description provided for @dataServicePermissionDenied.
  ///
  /// In zh, this message translates to:
  /// **'权限不足'**
  String get dataServicePermissionDenied;

  /// No description provided for @dataServiceTaskCreated.
  ///
  /// In zh, this message translates to:
  /// **'任务已创建'**
  String get dataServiceTaskCreated;

  /// No description provided for @dataServiceTaskCreationFailed.
  ///
  /// In zh, this message translates to:
  /// **'任务创建失败'**
  String get dataServiceTaskCreationFailed;

  /// No description provided for @loginTipsTitle.
  ///
  /// In zh, this message translates to:
  /// **'提示'**
  String get loginTipsTitle;

  /// No description provided for @loginPhoneRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入手机号'**
  String get loginPhoneRequired;

  /// No description provided for @loginPhoneInvalid.
  ///
  /// In zh, this message translates to:
  /// **'请输入正确的手机号'**
  String get loginPhoneInvalid;

  /// No description provided for @loginSmsCodeSent.
  ///
  /// In zh, this message translates to:
  /// **'验证码已发送'**
  String get loginSmsCodeSent;

  /// No description provided for @loginSendFailed.
  ///
  /// In zh, this message translates to:
  /// **'发送失败'**
  String get loginSendFailed;

  /// No description provided for @loginSendSmsFailed.
  ///
  /// In zh, this message translates to:
  /// **'发送验证码失败'**
  String get loginSendSmsFailed;

  /// No description provided for @loginSuccessfulTitle.
  ///
  /// In zh, this message translates to:
  /// **'登录成功'**
  String get loginSuccessfulTitle;

  /// No description provided for @loginFailedTitle.
  ///
  /// In zh, this message translates to:
  /// **'登录失败'**
  String get loginFailedTitle;

  /// No description provided for @loginInvalidEmailOrPassword.
  ///
  /// In zh, this message translates to:
  /// **'邮箱或密码错误'**
  String get loginInvalidEmailOrPassword;

  /// No description provided for @loginUnknownErrorRetry.
  ///
  /// In zh, this message translates to:
  /// **'发生错误，请重试。'**
  String get loginUnknownErrorRetry;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In zh, this message translates to:
  /// **'欢迎回来！'**
  String get loginWelcomeBack;

  /// No description provided for @loginFailedRetry.
  ///
  /// In zh, this message translates to:
  /// **'登录失败，请重试'**
  String get loginFailedRetry;

  /// No description provided for @loginSmsCodeInvalidOrExpired.
  ///
  /// In zh, this message translates to:
  /// **'验证码无效或已过期'**
  String get loginSmsCodeInvalidOrExpired;

  /// No description provided for @loginSocialFailed.
  ///
  /// In zh, this message translates to:
  /// **'{platformName} 登录失败，请稍后重试'**
  String loginSocialFailed(String platformName);

  /// No description provided for @loginSocialLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在{platformName}登录...'**
  String loginSocialLoading(String platformName);

  /// No description provided for @loginPleaseWait.
  ///
  /// In zh, this message translates to:
  /// **'请稍候'**
  String get loginPleaseWait;

  /// No description provided for @addInnovationImageSourceLocal.
  ///
  /// In zh, this message translates to:
  /// **'本地图片'**
  String get addInnovationImageSourceLocal;

  /// No description provided for @addInnovationImageSourceAiGenerated.
  ///
  /// In zh, this message translates to:
  /// **'AI 生成'**
  String get addInnovationImageSourceAiGenerated;

  /// No description provided for @addInnovationAiGenerating.
  ///
  /// In zh, this message translates to:
  /// **'AI 正在创作中...'**
  String get addInnovationAiGenerating;

  /// No description provided for @addInnovationSupportAlbumOrAi.
  ///
  /// In zh, this message translates to:
  /// **'支持相册选择或 AI 生成'**
  String get addInnovationSupportAlbumOrAi;

  /// No description provided for @addInnovationSelectCoverImage.
  ///
  /// In zh, this message translates to:
  /// **'选择封面图片'**
  String get addInnovationSelectCoverImage;

  /// No description provided for @addInnovationAddAttractiveCover.
  ///
  /// In zh, this message translates to:
  /// **'为你的项目添加一张吸引眼球的封面'**
  String get addInnovationAddAttractiveCover;

  /// No description provided for @addInnovationAlbum.
  ///
  /// In zh, this message translates to:
  /// **'相册'**
  String get addInnovationAlbum;

  /// No description provided for @addInnovationPickFromLocal.
  ///
  /// In zh, this message translates to:
  /// **'从本地选择'**
  String get addInnovationPickFromLocal;

  /// No description provided for @addInnovationAiGenerate.
  ///
  /// In zh, this message translates to:
  /// **'AI 生成'**
  String get addInnovationAiGenerate;

  /// No description provided for @addInnovationAiCreative.
  ///
  /// In zh, this message translates to:
  /// **'智能创作'**
  String get addInnovationAiCreative;

  /// No description provided for @addInnovationMembershipUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'会员服务不可用，请稍后再试'**
  String get addInnovationMembershipUnavailable;

  /// No description provided for @addInnovationAiImageGeneration.
  ///
  /// In zh, this message translates to:
  /// **'AI 图片生成'**
  String get addInnovationAiImageGeneration;

  /// No description provided for @addInnovationMemberExclusive.
  ///
  /// In zh, this message translates to:
  /// **'会员专属功能'**
  String get addInnovationMemberExclusive;

  /// No description provided for @addInnovationUpgradeMembershipUnlock.
  ///
  /// In zh, this message translates to:
  /// **'升级会员解锁'**
  String get addInnovationUpgradeMembershipUnlock;

  /// No description provided for @addInnovationMaybeLater.
  ///
  /// In zh, this message translates to:
  /// **'稍后再说'**
  String get addInnovationMaybeLater;

  /// No description provided for @addInnovationAiGenerateCover.
  ///
  /// In zh, this message translates to:
  /// **'AI 生成封面'**
  String get addInnovationAiGenerateCover;

  /// No description provided for @addInnovationDescribeCoverHint.
  ///
  /// In zh, this message translates to:
  /// **'请描述您想要的封面图片...'**
  String get addInnovationDescribeCoverHint;

  /// No description provided for @addInnovationQuickTemplates.
  ///
  /// In zh, this message translates to:
  /// **'快速模板：'**
  String get addInnovationQuickTemplates;

  /// No description provided for @addInnovationGenerating.
  ///
  /// In zh, this message translates to:
  /// **'生成中...'**
  String get addInnovationGenerating;

  /// No description provided for @generate.
  ///
  /// In zh, this message translates to:
  /// **'生成'**
  String get generate;

  /// No description provided for @addInnovationAiBadge.
  ///
  /// In zh, this message translates to:
  /// **'AI'**
  String get addInnovationAiBadge;

  /// No description provided for @cityPhotoPickFromGalleryMulti.
  ///
  /// In zh, this message translates to:
  /// **'从相册选择 (可多选)'**
  String get cityPhotoPickFromGalleryMulti;

  /// No description provided for @cityPhotoCaptureAndUpload.
  ///
  /// In zh, this message translates to:
  /// **'拍照上传'**
  String get cityPhotoCaptureAndUpload;

  /// No description provided for @cityPhotoUploadTitle.
  ///
  /// In zh, this message translates to:
  /// **'上传照片 · {cityName}'**
  String cityPhotoUploadTitle(String cityName);

  /// No description provided for @cityPhotoShareExperience.
  ///
  /// In zh, this message translates to:
  /// **'为数字游民社区分享你在 {cityName} 的真实体验'**
  String cityPhotoShareExperience(String cityName);

  /// No description provided for @cityPhotoTitleOrPlace.
  ///
  /// In zh, this message translates to:
  /// **'标题 / 地点'**
  String get cityPhotoTitleOrPlace;

  /// No description provided for @cityPhotoTitleExample.
  ///
  /// In zh, this message translates to:
  /// **'例：北戴河海边日出'**
  String get cityPhotoTitleExample;

  /// No description provided for @cityPhotoTitleRequired.
  ///
  /// In zh, this message translates to:
  /// **'请填写一个标题或地点描述'**
  String get cityPhotoTitleRequired;

  /// No description provided for @cityPhotoLocationOptional.
  ///
  /// In zh, this message translates to:
  /// **'位置信息 (可选)'**
  String get cityPhotoLocationOptional;

  /// No description provided for @cityPhotoLocationHint.
  ///
  /// In zh, this message translates to:
  /// **'街道、地标或更多定位线索'**
  String get cityPhotoLocationHint;

  /// No description provided for @cityPhotoLocateOnMap.
  ///
  /// In zh, this message translates to:
  /// **'在地图上定位'**
  String get cityPhotoLocateOnMap;

  /// No description provided for @cityPhotoDescriptionOptional.
  ///
  /// In zh, this message translates to:
  /// **'描述 (可选)'**
  String get cityPhotoDescriptionOptional;

  /// No description provided for @cityPhotoDescriptionHint.
  ///
  /// In zh, this message translates to:
  /// **'简单介绍照片内容、拍摄时间等'**
  String get cityPhotoDescriptionHint;

  /// No description provided for @cityPhotoSelectedCount.
  ///
  /// In zh, this message translates to:
  /// **'已选择 {count} / {maxCount}'**
  String cityPhotoSelectedCount(int count, int maxCount);

  /// No description provided for @cityPhotoAddPhoto.
  ///
  /// In zh, this message translates to:
  /// **'添加照片'**
  String get cityPhotoAddPhoto;

  /// No description provided for @cityPhotoUploading.
  ///
  /// In zh, this message translates to:
  /// **'正在上传...'**
  String get cityPhotoUploading;

  /// No description provided for @cityPhotoEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'还没有照片，点击上方\"添加照片\"按钮上传'**
  String get cityPhotoEmptyHint;

  /// No description provided for @cityPhotoSubmitting.
  ///
  /// In zh, this message translates to:
  /// **'提交中...'**
  String get cityPhotoSubmitting;

  /// No description provided for @cityPhotoSubmitDescription.
  ///
  /// In zh, this message translates to:
  /// **'提交后后端会通过高德地图自动补齐坐标，成功后你将回到城市详情页，照片会在刷新后展示。'**
  String get cityPhotoSubmitDescription;

  /// No description provided for @currencyOptionUsd.
  ///
  /// In zh, this message translates to:
  /// **'USD (\$)'**
  String get currencyOptionUsd;

  /// No description provided for @currencyOptionEur.
  ///
  /// In zh, this message translates to:
  /// **'EUR (€)'**
  String get currencyOptionEur;

  /// No description provided for @currencyOptionGbp.
  ///
  /// In zh, this message translates to:
  /// **'GBP (£)'**
  String get currencyOptionGbp;

  /// No description provided for @currencyOptionCny.
  ///
  /// In zh, this message translates to:
  /// **'CNY (¥)'**
  String get currencyOptionCny;

  /// No description provided for @currencyOptionJpy.
  ///
  /// In zh, this message translates to:
  /// **'JPY (¥)'**
  String get currencyOptionJpy;

  /// No description provided for @currencyOptionThb.
  ///
  /// In zh, this message translates to:
  /// **'THB (฿)'**
  String get currencyOptionThb;

  /// No description provided for @currencyOptionVnd.
  ///
  /// In zh, this message translates to:
  /// **'VND (₫)'**
  String get currencyOptionVnd;

  /// No description provided for @currencyOptionIdr.
  ///
  /// In zh, this message translates to:
  /// **'IDR (Rp)'**
  String get currencyOptionIdr;

  /// No description provided for @currencyOptionMyr.
  ///
  /// In zh, this message translates to:
  /// **'MYR (RM)'**
  String get currencyOptionMyr;

  /// No description provided for @currencyOptionSgd.
  ///
  /// In zh, this message translates to:
  /// **'SGD (S\$)'**
  String get currencyOptionSgd;

  /// No description provided for @homeMeetupChatButton.
  ///
  /// In zh, this message translates to:
  /// **'聊天'**
  String get homeMeetupChatButton;

  /// No description provided for @moderatorCardTitle.
  ///
  /// In zh, this message translates to:
  /// **'城市版主'**
  String get moderatorCardTitle;

  /// No description provided for @moderatorCardCertified.
  ///
  /// In zh, this message translates to:
  /// **'已认证'**
  String get moderatorCardCertified;

  /// No description provided for @moderatorCardTransferModerator.
  ///
  /// In zh, this message translates to:
  /// **'转让版主'**
  String get moderatorCardTransferModerator;

  /// No description provided for @moderatorCardApplyModerator.
  ///
  /// In zh, this message translates to:
  /// **'申请成为版主'**
  String get moderatorCardApplyModerator;

  /// No description provided for @moderatorCardUnclaimed.
  ///
  /// In zh, this message translates to:
  /// **'待认领'**
  String get moderatorCardUnclaimed;

  /// No description provided for @moderatorCardLookingForModerator.
  ///
  /// In zh, this message translates to:
  /// **'这座城市正在寻找版主！如果你熟悉这里，可以申请成为版主，帮助其他数字游民了解这座城市。'**
  String get moderatorCardLookingForModerator;

  /// No description provided for @moderatorCardAssignModerator.
  ///
  /// In zh, this message translates to:
  /// **'分配版主'**
  String get moderatorCardAssignModerator;

  /// No description provided for @moderatorCardNeedUpgradeMembership.
  ///
  /// In zh, this message translates to:
  /// **'需要升级会员'**
  String get moderatorCardNeedUpgradeMembership;

  /// No description provided for @moderatorCardUpgradeContent.
  ///
  /// In zh, this message translates to:
  /// **'申请成为城市版主需要 Pro 会员或更高等级。\n\n升级到 Pro 会员后，您将获得：\n• 申请成为城市版主的资格\n• 更多 AI 使用次数\n• 专属会员徽章\n• 更多高级功能'**
  String get moderatorCardUpgradeContent;

  /// No description provided for @moderatorCardUpgradeNow.
  ///
  /// In zh, this message translates to:
  /// **'立即升级'**
  String get moderatorCardUpgradeNow;

  /// No description provided for @assignModeratorLoadCandidatesFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载版主候选人失败: {error}'**
  String assignModeratorLoadCandidatesFailed(String error);

  /// No description provided for @assignModeratorSelectAtLeastOneUser.
  ///
  /// In zh, this message translates to:
  /// **'请至少选择一个用户'**
  String get assignModeratorSelectAtLeastOneUser;

  /// No description provided for @assignModeratorUnknownError.
  ///
  /// In zh, this message translates to:
  /// **'未知错误'**
  String get assignModeratorUnknownError;

  /// No description provided for @assignModeratorUserError.
  ///
  /// In zh, this message translates to:
  /// **'用户 {userId}: {error}'**
  String assignModeratorUserError(String userId, String error);

  /// No description provided for @assignModeratorSuccessCount.
  ///
  /// In zh, this message translates to:
  /// **'成功指定 {count} 个版主！'**
  String assignModeratorSuccessCount(int count);

  /// No description provided for @assignModeratorFailCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个用户指定失败，请查看日志'**
  String assignModeratorFailCount(int count);

  /// No description provided for @assignModeratorAllFailed.
  ///
  /// In zh, this message translates to:
  /// **'所有用户指定失败: {reason}'**
  String assignModeratorAllFailed(String reason);

  /// No description provided for @assignModeratorConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认指定版主'**
  String get assignModeratorConfirmTitle;

  /// No description provided for @assignModeratorConfirmMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定要将 {count} 个用户指定为版主吗？\n\n这些用户将自动获得版主角色和相应权限。'**
  String assignModeratorConfirmMessage(int count);

  /// No description provided for @skillCategoryProgramming.
  ///
  /// In zh, this message translates to:
  /// **'编程开发'**
  String get skillCategoryProgramming;

  /// No description provided for @skillCategoryDesign.
  ///
  /// In zh, this message translates to:
  /// **'设计创意'**
  String get skillCategoryDesign;

  /// No description provided for @skillCategoryMarketing.
  ///
  /// In zh, this message translates to:
  /// **'营销商务'**
  String get skillCategoryMarketing;

  /// No description provided for @skillCategoryLanguages.
  ///
  /// In zh, this message translates to:
  /// **'语言能力'**
  String get skillCategoryLanguages;

  /// No description provided for @skillCategoryData.
  ///
  /// In zh, this message translates to:
  /// **'数据分析'**
  String get skillCategoryData;

  /// No description provided for @skillCategoryManagement.
  ///
  /// In zh, this message translates to:
  /// **'项目管理'**
  String get skillCategoryManagement;

  /// No description provided for @skillCategoryOther.
  ///
  /// In zh, this message translates to:
  /// **'其他技能'**
  String get skillCategoryOther;

  /// No description provided for @interestCategorySports.
  ///
  /// In zh, this message translates to:
  /// **'运动健身'**
  String get interestCategorySports;

  /// No description provided for @interestCategoryArts.
  ///
  /// In zh, this message translates to:
  /// **'艺术文化'**
  String get interestCategoryArts;

  /// No description provided for @interestCategoryFood.
  ///
  /// In zh, this message translates to:
  /// **'美食烹饪'**
  String get interestCategoryFood;

  /// No description provided for @interestCategoryTravel.
  ///
  /// In zh, this message translates to:
  /// **'旅行探险'**
  String get interestCategoryTravel;

  /// No description provided for @interestCategoryTechnology.
  ///
  /// In zh, this message translates to:
  /// **'科技数码'**
  String get interestCategoryTechnology;

  /// No description provided for @interestCategoryReading.
  ///
  /// In zh, this message translates to:
  /// **'阅读学习'**
  String get interestCategoryReading;

  /// No description provided for @interestCategoryMusic.
  ///
  /// In zh, this message translates to:
  /// **'音乐娱乐'**
  String get interestCategoryMusic;

  /// No description provided for @interestCategorySocial.
  ///
  /// In zh, this message translates to:
  /// **'社交公益'**
  String get interestCategorySocial;

  /// No description provided for @travelHistory.
  ///
  /// In zh, this message translates to:
  /// **'旅行历史'**
  String get travelHistory;

  /// No description provided for @current.
  ///
  /// In zh, this message translates to:
  /// **'当前'**
  String get current;

  /// No description provided for @connect.
  ///
  /// In zh, this message translates to:
  /// **'联系方式'**
  String get connect;

  /// No description provided for @preferences.
  ///
  /// In zh, this message translates to:
  /// **'偏好设置'**
  String get preferences;

  /// No description provided for @open.
  ///
  /// In zh, this message translates to:
  /// **'打开'**
  String get open;

  /// No description provided for @view.
  ///
  /// In zh, this message translates to:
  /// **'查看'**
  String get view;

  /// No description provided for @apiDeveloperSettings.
  ///
  /// In zh, this message translates to:
  /// **'API 开发者设置'**
  String get apiDeveloperSettings;

  /// No description provided for @createNew.
  ///
  /// In zh, this message translates to:
  /// **'创建新的'**
  String get createNew;

  /// No description provided for @exploreCities.
  ///
  /// In zh, this message translates to:
  /// **'探索城市'**
  String get exploreCities;

  /// No description provided for @travelPlanCard.
  ///
  /// In zh, this message translates to:
  /// **'旅行计划卡片'**
  String get travelPlanCard;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定要退出登录吗？'**
  String get logoutConfirmMessage;

  /// No description provided for @loggedOut.
  ///
  /// In zh, this message translates to:
  /// **'已退出登录'**
  String get loggedOut;

  /// No description provided for @loggedOutSuccess.
  ///
  /// In zh, this message translates to:
  /// **'您已成功退出登录'**
  String get loggedOutSuccess;

  /// No description provided for @aiAssistant.
  ///
  /// In zh, this message translates to:
  /// **'AI助手'**
  String get aiAssistant;

  /// No description provided for @myProfile.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get myProfile;

  /// No description provided for @popular.
  ///
  /// In zh, this message translates to:
  /// **'热门'**
  String get popular;

  /// No description provided for @costOfLiving.
  ///
  /// In zh, this message translates to:
  /// **'生活成本'**
  String get costOfLiving;

  /// No description provided for @internet.
  ///
  /// In zh, this message translates to:
  /// **'网络'**
  String get internet;

  /// No description provided for @internetSpeed.
  ///
  /// In zh, this message translates to:
  /// **'网速'**
  String get internetSpeed;

  /// No description provided for @safety.
  ///
  /// In zh, this message translates to:
  /// **'安全'**
  String get safety;

  /// No description provided for @nomadScore.
  ///
  /// In zh, this message translates to:
  /// **'数字游民评分'**
  String get nomadScore;

  /// No description provided for @humidity.
  ///
  /// In zh, this message translates to:
  /// **'湿度'**
  String get humidity;

  /// No description provided for @airQuality.
  ///
  /// In zh, this message translates to:
  /// **'空气质量'**
  String get airQuality;

  /// No description provided for @placesToWork.
  ///
  /// In zh, this message translates to:
  /// **'工作场所'**
  String get placesToWork;

  /// No description provided for @forNomads.
  ///
  /// In zh, this message translates to:
  /// **'数字游民指数'**
  String get forNomads;

  /// No description provided for @lifeQuality.
  ///
  /// In zh, this message translates to:
  /// **'生活质量'**
  String get lifeQuality;

  /// No description provided for @healthcare.
  ///
  /// In zh, this message translates to:
  /// **'医疗'**
  String get healthcare;

  /// No description provided for @english.
  ///
  /// In zh, this message translates to:
  /// **'英语水平'**
  String get english;

  /// No description provided for @walkability.
  ///
  /// In zh, this message translates to:
  /// **'步行便利性'**
  String get walkability;

  /// No description provided for @peaceScore.
  ///
  /// In zh, this message translates to:
  /// **'和平指数'**
  String get peaceScore;

  /// No description provided for @nightlife.
  ///
  /// In zh, this message translates to:
  /// **'夜生活'**
  String get nightlife;

  /// No description provided for @free.
  ///
  /// In zh, this message translates to:
  /// **'免费'**
  String get free;

  /// No description provided for @ac.
  ///
  /// In zh, this message translates to:
  /// **'空调'**
  String get ac;

  /// No description provided for @totalSpaces.
  ///
  /// In zh, this message translates to:
  /// **'共享办公空间'**
  String get totalSpaces;

  /// No description provided for @upcomingMeetups.
  ///
  /// In zh, this message translates to:
  /// **'即将举行'**
  String get upcomingMeetups;

  /// No description provided for @findYourTribe.
  ///
  /// In zh, this message translates to:
  /// **'找到你的圈子'**
  String get findYourTribe;

  /// No description provided for @create.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get create;

  /// No description provided for @attendees.
  ///
  /// In zh, this message translates to:
  /// **'参与者'**
  String get attendees;

  /// No description provided for @seeAll.
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get seeAll;

  /// No description provided for @topRatedCities.
  ///
  /// In zh, this message translates to:
  /// **'高评分城市'**
  String get topRatedCities;

  /// No description provided for @byNomads.
  ///
  /// In zh, this message translates to:
  /// **'来自数字游民'**
  String get byNomads;

  /// No description provided for @month.
  ///
  /// In zh, this message translates to:
  /// **'月'**
  String get month;

  /// No description provided for @compareWith.
  ///
  /// In zh, this message translates to:
  /// **'对比'**
  String get compareWith;

  /// No description provided for @or.
  ///
  /// In zh, this message translates to:
  /// **'或'**
  String get or;

  /// No description provided for @startComparison.
  ///
  /// In zh, this message translates to:
  /// **'开始对比'**
  String get startComparison;

  /// No description provided for @selectCity.
  ///
  /// In zh, this message translates to:
  /// **'选择城市'**
  String get selectCity;

  /// No description provided for @selectCities.
  ///
  /// In zh, this message translates to:
  /// **'选择城市'**
  String get selectCities;

  /// 在用户选择城市前提示先选择国家
  ///
  /// In zh, this message translates to:
  /// **'请先选择国家'**
  String get selectCountryFirst;

  /// No description provided for @clearAll.
  ///
  /// In zh, this message translates to:
  /// **'清空全部'**
  String get clearAll;

  /// No description provided for @apply.
  ///
  /// In zh, this message translates to:
  /// **'应用'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In zh, this message translates to:
  /// **'重置'**
  String get reset;

  /// No description provided for @sortBy.
  ///
  /// In zh, this message translates to:
  /// **'排序方式'**
  String get sortBy;

  /// No description provided for @filterBy.
  ///
  /// In zh, this message translates to:
  /// **'筛选'**
  String get filterBy;

  /// No description provided for @allCategories.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get allCategories;

  /// No description provided for @searchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索...'**
  String get searchHint;

  /// No description provided for @searchCities.
  ///
  /// In zh, this message translates to:
  /// **'搜索城市'**
  String get searchCities;

  /// No description provided for @searchResults.
  ///
  /// In zh, this message translates to:
  /// **'搜索结果'**
  String get searchResults;

  /// No description provided for @noResults.
  ///
  /// In zh, this message translates to:
  /// **'未找到结果'**
  String get noResults;

  /// No description provided for @tryAgain.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get tryAgain;

  /// No description provided for @yes.
  ///
  /// In zh, this message translates to:
  /// **'是'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In zh, this message translates to:
  /// **'否'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get ok;

  /// No description provided for @done.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get done;

  /// No description provided for @skip.
  ///
  /// In zh, this message translates to:
  /// **'跳过'**
  String get skip;

  /// No description provided for @submit.
  ///
  /// In zh, this message translates to:
  /// **'提交'**
  String get submit;

  /// No description provided for @send.
  ///
  /// In zh, this message translates to:
  /// **'发送'**
  String get send;

  /// No description provided for @reply.
  ///
  /// In zh, this message translates to:
  /// **'回复'**
  String get reply;

  /// No description provided for @comment.
  ///
  /// In zh, this message translates to:
  /// **'评论'**
  String get comment;

  /// No description provided for @comments.
  ///
  /// In zh, this message translates to:
  /// **'评论'**
  String get comments;

  /// No description provided for @like.
  ///
  /// In zh, this message translates to:
  /// **'点赞'**
  String get like;

  /// No description provided for @likes.
  ///
  /// In zh, this message translates to:
  /// **'点赞'**
  String get likes;

  /// No description provided for @viewDetails.
  ///
  /// In zh, this message translates to:
  /// **'查看详情'**
  String get viewDetails;

  /// No description provided for @details.
  ///
  /// In zh, this message translates to:
  /// **'详情'**
  String get details;

  /// No description provided for @overview.
  ///
  /// In zh, this message translates to:
  /// **'概览'**
  String get overview;

  /// No description provided for @photos.
  ///
  /// In zh, this message translates to:
  /// **'照片'**
  String get photos;

  /// No description provided for @reviews.
  ///
  /// In zh, this message translates to:
  /// **'评论'**
  String get reviews;

  /// No description provided for @writeReview.
  ///
  /// In zh, this message translates to:
  /// **'写评论'**
  String get writeReview;

  /// No description provided for @yourRating.
  ///
  /// In zh, this message translates to:
  /// **'您的评分'**
  String get yourRating;

  /// No description provided for @selectDate.
  ///
  /// In zh, this message translates to:
  /// **'选择日期'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In zh, this message translates to:
  /// **'选择时间'**
  String get selectTime;

  /// No description provided for @startDate.
  ///
  /// In zh, this message translates to:
  /// **'开始日期'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In zh, this message translates to:
  /// **'结束日期'**
  String get endDate;

  /// No description provided for @duration.
  ///
  /// In zh, this message translates to:
  /// **'时长'**
  String get duration;

  /// No description provided for @days.
  ///
  /// In zh, this message translates to:
  /// **'天'**
  String days(int count);

  /// No description provided for @hours.
  ///
  /// In zh, this message translates to:
  /// **'小时'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In zh, this message translates to:
  /// **'分钟'**
  String get minutes;

  /// No description provided for @title.
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get title;

  /// No description provided for @name.
  ///
  /// In zh, this message translates to:
  /// **'姓名'**
  String get name;

  /// No description provided for @address.
  ///
  /// In zh, this message translates to:
  /// **'地址'**
  String get address;

  /// No description provided for @phone.
  ///
  /// In zh, this message translates to:
  /// **'电话'**
  String get phone;

  /// No description provided for @website.
  ///
  /// In zh, this message translates to:
  /// **'网站'**
  String get website;

  /// No description provided for @openingHours.
  ///
  /// In zh, this message translates to:
  /// **'营业时间'**
  String get openingHours;

  /// No description provided for @closed.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get closed;

  /// No description provided for @open24Hours.
  ///
  /// In zh, this message translates to:
  /// **'24小时营业'**
  String get open24Hours;

  /// No description provided for @directions.
  ///
  /// In zh, this message translates to:
  /// **'路线导航'**
  String get directions;

  /// No description provided for @callNow.
  ///
  /// In zh, this message translates to:
  /// **'立即呼叫'**
  String get callNow;

  /// No description provided for @bookNow.
  ///
  /// In zh, this message translates to:
  /// **'立即预订'**
  String get bookNow;

  /// No description provided for @visitWebsite.
  ///
  /// In zh, this message translates to:
  /// **'访问网站'**
  String get visitWebsite;

  /// 提交共享办公认证时弹窗的标题
  ///
  /// In zh, this message translates to:
  /// **'空间认证'**
  String get coworkingVerifyTitle;

  /// 未登录用户点击认证徽章时的提示
  ///
  /// In zh, this message translates to:
  /// **'请先登录再进行空间认证。'**
  String get coworkingVerifyLoginRequired;

  /// 提交共享办公认证前的确认文案
  ///
  /// In zh, this message translates to:
  /// **'确定要为 {spaceName} 提交认证吗？'**
  String coworkingVerifyMessage(String spaceName);

  /// 认证成功后的提示
  ///
  /// In zh, this message translates to:
  /// **'认证已提交，感谢你的贡献！'**
  String get coworkingVerifySuccess;

  /// 认证失败后的提示
  ///
  /// In zh, this message translates to:
  /// **'认证提交失败，请稍后再试。'**
  String get coworkingVerifyFailed;

  /// 用户已经验证过该空间的提示
  ///
  /// In zh, this message translates to:
  /// **'您已经为该空间提交过认证。'**
  String get coworkingVerifyAlreadyVoted;

  /// 创建者尝试验证自己的空间的提示
  ///
  /// In zh, this message translates to:
  /// **'创建者不能为自己的空间认证。'**
  String get coworkingVerifyIsCreator;

  /// 空间已经是已验证状态的提示
  ///
  /// In zh, this message translates to:
  /// **'该空间已通过认证。'**
  String get coworkingVerifySpaceVerified;

  /// 检查验证资格时的加载提示
  ///
  /// In zh, this message translates to:
  /// **'正在检查资格...'**
  String get coworkingVerifyChecking;

  /// No description provided for @shareLocation.
  ///
  /// In zh, this message translates to:
  /// **'分享位置'**
  String get shareLocation;

  /// No description provided for @favoriteAdded.
  ///
  /// In zh, this message translates to:
  /// **'已添加到收藏'**
  String get favoriteAdded;

  /// No description provided for @favoriteRemoved.
  ///
  /// In zh, this message translates to:
  /// **'已从收藏移除'**
  String get favoriteRemoved;

  /// No description provided for @myFavorites.
  ///
  /// In zh, this message translates to:
  /// **'我的收藏'**
  String get myFavorites;

  /// No description provided for @noFavorites.
  ///
  /// In zh, this message translates to:
  /// **'暂无收藏'**
  String get noFavorites;

  /// No description provided for @nearby.
  ///
  /// In zh, this message translates to:
  /// **'附近'**
  String get nearby;

  /// No description provided for @distance.
  ///
  /// In zh, this message translates to:
  /// **'距离'**
  String get distance;

  /// No description provided for @away.
  ///
  /// In zh, this message translates to:
  /// **'远'**
  String get away;

  /// No description provided for @filters.
  ///
  /// In zh, this message translates to:
  /// **'筛选'**
  String get filters;

  /// No description provided for @priceRange.
  ///
  /// In zh, this message translates to:
  /// **'价格区间'**
  String get priceRange;

  /// No description provided for @price.
  ///
  /// In zh, this message translates to:
  /// **'价格'**
  String get price;

  /// No description provided for @cheap.
  ///
  /// In zh, this message translates to:
  /// **'便宜'**
  String get cheap;

  /// No description provided for @moderate.
  ///
  /// In zh, this message translates to:
  /// **'中等'**
  String get moderate;

  /// No description provided for @expensive.
  ///
  /// In zh, this message translates to:
  /// **'昂贵'**
  String get expensive;

  /// No description provided for @facilities.
  ///
  /// In zh, this message translates to:
  /// **'设施服务'**
  String get facilities;

  /// No description provided for @wifi.
  ///
  /// In zh, this message translates to:
  /// **'WiFi'**
  String get wifi;

  /// No description provided for @parking.
  ///
  /// In zh, this message translates to:
  /// **'停车场'**
  String get parking;

  /// No description provided for @meetingRoom.
  ///
  /// In zh, this message translates to:
  /// **'会议室'**
  String get meetingRoom;

  /// No description provided for @kitchen.
  ///
  /// In zh, this message translates to:
  /// **'厨房'**
  String get kitchen;

  /// No description provided for @printer.
  ///
  /// In zh, this message translates to:
  /// **'打印机'**
  String get printer;

  /// No description provided for @coffee.
  ///
  /// In zh, this message translates to:
  /// **'咖啡'**
  String get coffee;

  /// No description provided for @events.
  ///
  /// In zh, this message translates to:
  /// **'活动'**
  String get events;

  /// No description provided for @upcomingEvents.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个即将到来的活动'**
  String upcomingEvents(String count);

  /// No description provided for @pastEvents.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个过往活动'**
  String pastEvents(String count);

  /// No description provided for @eventDetails.
  ///
  /// In zh, this message translates to:
  /// **'活动详情'**
  String get eventDetails;

  /// No description provided for @joinEvent.
  ///
  /// In zh, this message translates to:
  /// **'加入活动'**
  String get joinEvent;

  /// No description provided for @leaveEvent.
  ///
  /// In zh, this message translates to:
  /// **'离开活动'**
  String get leaveEvent;

  /// No description provided for @eventFull.
  ///
  /// In zh, this message translates to:
  /// **'活动已满'**
  String get eventFull;

  /// No description provided for @spotsLeft.
  ///
  /// In zh, this message translates to:
  /// **'剩余 {count} 个名额'**
  String spotsLeft(String count);

  /// No description provided for @organizer.
  ///
  /// In zh, this message translates to:
  /// **'组织者'**
  String get organizer;

  /// No description provided for @host.
  ///
  /// In zh, this message translates to:
  /// **'主办方'**
  String get host;

  /// No description provided for @cohost.
  ///
  /// In zh, this message translates to:
  /// **'联合主办'**
  String get cohost;

  /// No description provided for @joined.
  ///
  /// In zh, this message translates to:
  /// **'已加入!'**
  String get joined;

  /// No description provided for @notJoined.
  ///
  /// In zh, this message translates to:
  /// **'未加入'**
  String get notJoined;

  /// No description provided for @rsvp.
  ///
  /// In zh, this message translates to:
  /// **'回复参加'**
  String get rsvp;

  /// No description provided for @going.
  ///
  /// In zh, this message translates to:
  /// **'参加'**
  String get going;

  /// No description provided for @notGoing.
  ///
  /// In zh, this message translates to:
  /// **'不参加'**
  String get notGoing;

  /// No description provided for @maybe.
  ///
  /// In zh, this message translates to:
  /// **'可能'**
  String get maybe;

  /// No description provided for @inviteFriends.
  ///
  /// In zh, this message translates to:
  /// **'邀请朋友'**
  String get inviteFriends;

  /// No description provided for @shareEvent.
  ///
  /// In zh, this message translates to:
  /// **'分享活动'**
  String get shareEvent;

  /// No description provided for @report.
  ///
  /// In zh, this message translates to:
  /// **'举报'**
  String get report;

  /// No description provided for @reportIssue.
  ///
  /// In zh, this message translates to:
  /// **'举报问题'**
  String get reportIssue;

  /// No description provided for @block.
  ///
  /// In zh, this message translates to:
  /// **'屏蔽'**
  String get block;

  /// No description provided for @unblock.
  ///
  /// In zh, this message translates to:
  /// **'取消屏蔽'**
  String get unblock;

  /// No description provided for @follow.
  ///
  /// In zh, this message translates to:
  /// **'关注'**
  String get follow;

  /// No description provided for @unfollow.
  ///
  /// In zh, this message translates to:
  /// **'取消关注'**
  String get unfollow;

  /// No description provided for @following.
  ///
  /// In zh, this message translates to:
  /// **'关注'**
  String get following;

  /// No description provided for @followers.
  ///
  /// In zh, this message translates to:
  /// **'粉丝'**
  String get followers;

  /// No description provided for @posts.
  ///
  /// In zh, this message translates to:
  /// **'帖子'**
  String get posts;

  /// No description provided for @newPost.
  ///
  /// In zh, this message translates to:
  /// **'新帖子'**
  String get newPost;

  /// No description provided for @createPost.
  ///
  /// In zh, this message translates to:
  /// **'创建帖子'**
  String get createPost;

  /// No description provided for @editPost.
  ///
  /// In zh, this message translates to:
  /// **'编辑帖子'**
  String get editPost;

  /// No description provided for @deletePost.
  ///
  /// In zh, this message translates to:
  /// **'删除帖子'**
  String get deletePost;

  /// No description provided for @deleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除吗？'**
  String get deleteConfirm;

  /// No description provided for @deleteSuccess.
  ///
  /// In zh, this message translates to:
  /// **'删除成功'**
  String get deleteSuccess;

  /// No description provided for @saveSuccess.
  ///
  /// In zh, this message translates to:
  /// **'保存成功'**
  String get saveSuccess;

  /// No description provided for @updateSuccess.
  ///
  /// In zh, this message translates to:
  /// **'更新成功'**
  String get updateSuccess;

  /// No description provided for @updateFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新失败'**
  String get updateFailed;

  /// No description provided for @uploadPhoto.
  ///
  /// In zh, this message translates to:
  /// **'上传照片'**
  String get uploadPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In zh, this message translates to:
  /// **'拍照'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In zh, this message translates to:
  /// **'从相册选择'**
  String get chooseFromGallery;

  /// No description provided for @camera.
  ///
  /// In zh, this message translates to:
  /// **'拍摄'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In zh, this message translates to:
  /// **'相册'**
  String get gallery;

  /// No description provided for @selectPhoto.
  ///
  /// In zh, this message translates to:
  /// **'选择照片'**
  String get selectPhoto;

  /// No description provided for @photo.
  ///
  /// In zh, this message translates to:
  /// **'照片'**
  String get photo;

  /// No description provided for @video.
  ///
  /// In zh, this message translates to:
  /// **'视频'**
  String get video;

  /// No description provided for @audio.
  ///
  /// In zh, this message translates to:
  /// **'音频'**
  String get audio;

  /// No description provided for @file.
  ///
  /// In zh, this message translates to:
  /// **'文件'**
  String get file;

  /// No description provided for @attachment.
  ///
  /// In zh, this message translates to:
  /// **'附件'**
  String get attachment;

  /// No description provided for @downloadAttachment.
  ///
  /// In zh, this message translates to:
  /// **'下载附件'**
  String get downloadAttachment;

  /// No description provided for @viewAttachment.
  ///
  /// In zh, this message translates to:
  /// **'查看附件'**
  String get viewAttachment;

  /// No description provided for @typeMessage.
  ///
  /// In zh, this message translates to:
  /// **'输入消息...'**
  String get typeMessage;

  /// No description provided for @newMessage.
  ///
  /// In zh, this message translates to:
  /// **'新消息'**
  String get newMessage;

  /// No description provided for @messages.
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get messages;

  /// No description provided for @conversationListLoadingTitle.
  ///
  /// In zh, this message translates to:
  /// **'正在加载好友列表'**
  String get conversationListLoadingTitle;

  /// No description provided for @conversationListLoadingSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'正在加载会话...'**
  String get conversationListLoadingSubtitle;

  /// No description provided for @inbox.
  ///
  /// In zh, this message translates to:
  /// **'收件箱'**
  String get inbox;

  /// No description provided for @sent.
  ///
  /// In zh, this message translates to:
  /// **'已发送'**
  String get sent;

  /// No description provided for @draft.
  ///
  /// In zh, this message translates to:
  /// **'草稿'**
  String get draft;

  /// No description provided for @trash.
  ///
  /// In zh, this message translates to:
  /// **'垃圾箱'**
  String get trash;

  /// No description provided for @markAsRead.
  ///
  /// In zh, this message translates to:
  /// **'标记为已读'**
  String get markAsRead;

  /// No description provided for @markAsUnread.
  ///
  /// In zh, this message translates to:
  /// **'标记为未读'**
  String get markAsUnread;

  /// No description provided for @archive.
  ///
  /// In zh, this message translates to:
  /// **'归档'**
  String get archive;

  /// No description provided for @unarchive.
  ///
  /// In zh, this message translates to:
  /// **'取消归档'**
  String get unarchive;

  /// No description provided for @starred.
  ///
  /// In zh, this message translates to:
  /// **'已加星标'**
  String get starred;

  /// No description provided for @unstarred.
  ///
  /// In zh, this message translates to:
  /// **'未加星标'**
  String get unstarred;

  /// No description provided for @notification.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get notification;

  /// No description provided for @enableNotifications.
  ///
  /// In zh, this message translates to:
  /// **'启用通知'**
  String get enableNotifications;

  /// No description provided for @disableNotifications.
  ///
  /// In zh, this message translates to:
  /// **'禁用通知'**
  String get disableNotifications;

  /// No description provided for @notificationSettings.
  ///
  /// In zh, this message translates to:
  /// **'通知设置'**
  String get notificationSettings;

  /// No description provided for @pushNotifications.
  ///
  /// In zh, this message translates to:
  /// **'推送通知'**
  String get pushNotifications;

  /// No description provided for @emailNotifications.
  ///
  /// In zh, this message translates to:
  /// **'邮件通知'**
  String get emailNotifications;

  /// No description provided for @account.
  ///
  /// In zh, this message translates to:
  /// **'账户'**
  String get account;

  /// No description provided for @accountSettings.
  ///
  /// In zh, this message translates to:
  /// **'账户设置'**
  String get accountSettings;

  /// No description provided for @profileSettings.
  ///
  /// In zh, this message translates to:
  /// **'个人资料设置'**
  String get profileSettings;

  /// No description provided for @privacySettings.
  ///
  /// In zh, this message translates to:
  /// **'隐私设置'**
  String get privacySettings;

  /// No description provided for @securitySettings.
  ///
  /// In zh, this message translates to:
  /// **'安全设置'**
  String get securitySettings;

  /// No description provided for @changePassword.
  ///
  /// In zh, this message translates to:
  /// **'修改密码'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In zh, this message translates to:
  /// **'当前密码'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In zh, this message translates to:
  /// **'新密码'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In zh, this message translates to:
  /// **'确认新密码'**
  String get confirmNewPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In zh, this message translates to:
  /// **'密码已修改'**
  String get passwordChanged;

  /// No description provided for @logoutConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要退出登录吗？'**
  String get logoutConfirm;

  /// No description provided for @loginRequired.
  ///
  /// In zh, this message translates to:
  /// **'需要登录'**
  String get loginRequired;

  /// No description provided for @pleaseLogin.
  ///
  /// In zh, this message translates to:
  /// **'请先登录'**
  String get pleaseLogin;

  /// No description provided for @signUp.
  ///
  /// In zh, this message translates to:
  /// **'注册'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get signOut;

  /// No description provided for @continueWithGoogle.
  ///
  /// In zh, this message translates to:
  /// **'使用 Google 继续'**
  String get continueWithGoogle;

  /// No description provided for @continueWithFacebook.
  ///
  /// In zh, this message translates to:
  /// **'使用 Facebook 继续'**
  String get continueWithFacebook;

  /// No description provided for @continueWithApple.
  ///
  /// In zh, this message translates to:
  /// **'使用 Apple 继续'**
  String get continueWithApple;

  /// No description provided for @orContinueWith.
  ///
  /// In zh, this message translates to:
  /// **'或继续使用'**
  String get orContinueWith;

  /// No description provided for @termsAndConditions.
  ///
  /// In zh, this message translates to:
  /// **'服务条款'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get privacyPolicy;

  /// No description provided for @agreeToTerms.
  ///
  /// In zh, this message translates to:
  /// **'我同意'**
  String get agreeToTerms;

  /// No description provided for @bySigningUp.
  ///
  /// In zh, this message translates to:
  /// **'注册即表示您同意我们的'**
  String get bySigningUp;

  /// No description provided for @and.
  ///
  /// In zh, this message translates to:
  /// **' 和 '**
  String get and;

  /// No description provided for @required.
  ///
  /// In zh, this message translates to:
  /// **'*'**
  String get required;

  /// No description provided for @optional.
  ///
  /// In zh, this message translates to:
  /// **'可选'**
  String get optional;

  /// No description provided for @invalidEmail.
  ///
  /// In zh, this message translates to:
  /// **'无效的邮箱地址'**
  String get invalidEmail;

  /// No description provided for @invalidPassword.
  ///
  /// In zh, this message translates to:
  /// **'无效的密码'**
  String get invalidPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In zh, this message translates to:
  /// **'密码太短'**
  String get passwordTooShort;

  /// No description provided for @passwordMismatch.
  ///
  /// In zh, this message translates to:
  /// **'密码不匹配'**
  String get passwordMismatch;

  /// No description provided for @fieldRequired.
  ///
  /// In zh, this message translates to:
  /// **'此字段为必填项'**
  String get fieldRequired;

  /// No description provided for @pleaseEnter.
  ///
  /// In zh, this message translates to:
  /// **'请输入'**
  String get pleaseEnter;

  /// No description provided for @pleaseSelect.
  ///
  /// In zh, this message translates to:
  /// **'请选择'**
  String get pleaseSelect;

  /// No description provided for @invalidInput.
  ///
  /// In zh, this message translates to:
  /// **'无效的输入'**
  String get invalidInput;

  /// No description provided for @somethingWentWrong.
  ///
  /// In zh, this message translates to:
  /// **'出错了'**
  String get somethingWentWrong;

  /// No description provided for @tryAgainLater.
  ///
  /// In zh, this message translates to:
  /// **'请稍后再试'**
  String get tryAgainLater;

  /// No description provided for @networkError.
  ///
  /// In zh, this message translates to:
  /// **'网络错误'**
  String get networkError;

  /// No description provided for @loadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get loadFailed;

  /// No description provided for @noInternetConnection.
  ///
  /// In zh, this message translates to:
  /// **'无网络连接'**
  String get noInternetConnection;

  /// No description provided for @checkConnection.
  ///
  /// In zh, this message translates to:
  /// **'请检查您的网络连接'**
  String get checkConnection;

  /// No description provided for @refreshing.
  ///
  /// In zh, this message translates to:
  /// **'刷新中...'**
  String get refreshing;

  /// No description provided for @pullToRefresh.
  ///
  /// In zh, this message translates to:
  /// **'下拉刷新'**
  String get pullToRefresh;

  /// No description provided for @releaseToRefresh.
  ///
  /// In zh, this message translates to:
  /// **'释放以刷新'**
  String get releaseToRefresh;

  /// No description provided for @loadingMore.
  ///
  /// In zh, this message translates to:
  /// **'加载更多...'**
  String get loadingMore;

  /// No description provided for @noMoreData.
  ///
  /// In zh, this message translates to:
  /// **'没有更多数据了'**
  String get noMoreData;

  /// No description provided for @endOfList.
  ///
  /// In zh, this message translates to:
  /// **'已到底部'**
  String get endOfList;

  /// No description provided for @tapToRetry.
  ///
  /// In zh, this message translates to:
  /// **'点击重试'**
  String get tapToRetry;

  /// No description provided for @goBack.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get goBack;

  /// No description provided for @goHome.
  ///
  /// In zh, this message translates to:
  /// **'回到首页'**
  String get goHome;

  /// No description provided for @exit.
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get exit;

  /// No description provided for @exitApp.
  ///
  /// In zh, this message translates to:
  /// **'退出应用'**
  String get exitApp;

  /// No description provided for @exitConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要退出应用吗？'**
  String get exitConfirm;

  /// No description provided for @update.
  ///
  /// In zh, this message translates to:
  /// **'更新'**
  String get update;

  /// No description provided for @updateAvailable.
  ///
  /// In zh, this message translates to:
  /// **'有可用更新'**
  String get updateAvailable;

  /// No description provided for @updateNow.
  ///
  /// In zh, this message translates to:
  /// **'立即更新'**
  String get updateNow;

  /// No description provided for @updateLater.
  ///
  /// In zh, this message translates to:
  /// **'稍后更新'**
  String get updateLater;

  /// No description provided for @versionInfo.
  ///
  /// In zh, this message translates to:
  /// **'版本信息'**
  String get versionInfo;

  /// No description provided for @currentVersion.
  ///
  /// In zh, this message translates to:
  /// **'当前版本'**
  String get currentVersion;

  /// No description provided for @latestVersion.
  ///
  /// In zh, this message translates to:
  /// **'最新版本'**
  String get latestVersion;

  /// No description provided for @aboutApp.
  ///
  /// In zh, this message translates to:
  /// **'关于应用'**
  String get aboutApp;

  /// No description provided for @contactSupport.
  ///
  /// In zh, this message translates to:
  /// **'联系支持'**
  String get contactSupport;

  /// No description provided for @helpCenter.
  ///
  /// In zh, this message translates to:
  /// **'帮助中心'**
  String get helpCenter;

  /// No description provided for @faq.
  ///
  /// In zh, this message translates to:
  /// **'常见问题'**
  String get faq;

  /// No description provided for @reportBug.
  ///
  /// In zh, this message translates to:
  /// **'报告错误'**
  String get reportBug;

  /// No description provided for @suggestFeature.
  ///
  /// In zh, this message translates to:
  /// **'建议功能'**
  String get suggestFeature;

  /// No description provided for @rateApp.
  ///
  /// In zh, this message translates to:
  /// **'给应用评分'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In zh, this message translates to:
  /// **'分享应用'**
  String get shareApp;

  /// No description provided for @allCountries.
  ///
  /// In zh, this message translates to:
  /// **'所有国家'**
  String get allCountries;

  /// No description provided for @allCities.
  ///
  /// In zh, this message translates to:
  /// **'所有城市'**
  String get allCities;

  /// No description provided for @clearFilters.
  ///
  /// In zh, this message translates to:
  /// **'清除筛选'**
  String get clearFilters;

  /// No description provided for @citiesFound.
  ///
  /// In zh, this message translates to:
  /// **'个城市'**
  String get citiesFound;

  /// No description provided for @filtered.
  ///
  /// In zh, this message translates to:
  /// **'已筛选'**
  String get filtered;

  /// No description provided for @searchCityOrCountry.
  ///
  /// In zh, this message translates to:
  /// **'搜索城市或国家...'**
  String get searchCityOrCountry;

  /// No description provided for @noCitiesFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到城市'**
  String get noCitiesFound;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In zh, this message translates to:
  /// **'请调整筛选条件或搜索关键词'**
  String get tryAdjustingFilters;

  /// No description provided for @scores.
  ///
  /// In zh, this message translates to:
  /// **'评分'**
  String get scores;

  /// No description provided for @guide.
  ///
  /// In zh, this message translates to:
  /// **'指南'**
  String get guide;

  /// No description provided for @prosAndCons.
  ///
  /// In zh, this message translates to:
  /// **'乐趣'**
  String get prosAndCons;

  /// No description provided for @pros.
  ///
  /// In zh, this message translates to:
  /// **'优点'**
  String get pros;

  /// No description provided for @cons.
  ///
  /// In zh, this message translates to:
  /// **'缺点'**
  String get cons;

  /// No description provided for @neighborhoods.
  ///
  /// In zh, this message translates to:
  /// **'附近'**
  String get neighborhoods;

  /// No description provided for @noNearbyCities.
  ///
  /// In zh, this message translates to:
  /// **'暂无附近城市'**
  String get noNearbyCities;

  /// No description provided for @loadingGuide.
  ///
  /// In zh, this message translates to:
  /// **'加载指南...'**
  String get loadingGuide;

  /// No description provided for @startRating.
  ///
  /// In zh, this message translates to:
  /// **'开始评分'**
  String get startRating;

  /// No description provided for @tripReports.
  ///
  /// In zh, this message translates to:
  /// **'旅行报告'**
  String get tripReports;

  /// No description provided for @recommendations.
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get recommendations;

  /// No description provided for @qa.
  ///
  /// In zh, this message translates to:
  /// **'问答'**
  String get qa;

  /// No description provided for @question.
  ///
  /// In zh, this message translates to:
  /// **'问题'**
  String get question;

  /// No description provided for @answer.
  ///
  /// In zh, this message translates to:
  /// **'回答'**
  String get answer;

  /// No description provided for @answers.
  ///
  /// In zh, this message translates to:
  /// **'个回答'**
  String get answers;

  /// No description provided for @views.
  ///
  /// In zh, this message translates to:
  /// **'浏览'**
  String get views;

  /// No description provided for @askQuestion.
  ///
  /// In zh, this message translates to:
  /// **'提问'**
  String get askQuestion;

  /// No description provided for @writeRecommendation.
  ///
  /// In zh, this message translates to:
  /// **'写推荐'**
  String get writeRecommendation;

  /// No description provided for @createTripReport.
  ///
  /// In zh, this message translates to:
  /// **'创建旅行报告'**
  String get createTripReport;

  /// No description provided for @typeYourMessage.
  ///
  /// In zh, this message translates to:
  /// **'输入您的消息...'**
  String get typeYourMessage;

  /// No description provided for @chatHistory.
  ///
  /// In zh, this message translates to:
  /// **'聊天记录'**
  String get chatHistory;

  /// No description provided for @clearChat.
  ///
  /// In zh, this message translates to:
  /// **'清除聊天'**
  String get clearChat;

  /// No description provided for @newChat.
  ///
  /// In zh, this message translates to:
  /// **'新建聊天'**
  String get newChat;

  /// No description provided for @createTravelPlan.
  ///
  /// In zh, this message translates to:
  /// **'创建旅行计划'**
  String get createTravelPlan;

  /// No description provided for @destination.
  ///
  /// In zh, this message translates to:
  /// **'目的地'**
  String get destination;

  /// No description provided for @budget.
  ///
  /// In zh, this message translates to:
  /// **'预算'**
  String get budget;

  /// No description provided for @savePlan.
  ///
  /// In zh, this message translates to:
  /// **'保存计划'**
  String get savePlan;

  /// No description provided for @selectDestination.
  ///
  /// In zh, this message translates to:
  /// **'选择目的地'**
  String get selectDestination;

  /// No description provided for @enterBudget.
  ///
  /// In zh, this message translates to:
  /// **'输入预算'**
  String get enterBudget;

  /// No description provided for @addNotes.
  ///
  /// In zh, this message translates to:
  /// **'添加备注'**
  String get addNotes;

  /// No description provided for @addCoworking.
  ///
  /// In zh, this message translates to:
  /// **'添加共享空间'**
  String get addCoworking;

  /// No description provided for @spaceName.
  ///
  /// In zh, this message translates to:
  /// **'空间名称'**
  String get spaceName;

  /// No description provided for @amenities.
  ///
  /// In zh, this message translates to:
  /// **'设施'**
  String get amenities;

  /// No description provided for @pricePerDay.
  ///
  /// In zh, this message translates to:
  /// **'每天价格'**
  String get pricePerDay;

  /// No description provided for @pricePerMonth.
  ///
  /// In zh, this message translates to:
  /// **'每月价格'**
  String get pricePerMonth;

  /// No description provided for @addSpace.
  ///
  /// In zh, this message translates to:
  /// **'添加空间'**
  String get addSpace;

  /// No description provided for @addExpense.
  ///
  /// In zh, this message translates to:
  /// **'添加支出'**
  String get addExpense;

  /// No description provided for @totalCost.
  ///
  /// In zh, this message translates to:
  /// **'总费用'**
  String get totalCost;

  /// No description provided for @monthlyAverage.
  ///
  /// In zh, this message translates to:
  /// **'月均费用'**
  String get monthlyAverage;

  /// No description provided for @tools.
  ///
  /// In zh, this message translates to:
  /// **'工具'**
  String get tools;

  /// No description provided for @compare.
  ///
  /// In zh, this message translates to:
  /// **'对比'**
  String get compare;

  /// No description provided for @compareCities.
  ///
  /// In zh, this message translates to:
  /// **'对比城市'**
  String get compareCities;

  /// No description provided for @addCity.
  ///
  /// In zh, this message translates to:
  /// **'添加城市'**
  String get addCity;

  /// No description provided for @removeCity.
  ///
  /// In zh, this message translates to:
  /// **'移除城市'**
  String get removeCity;

  /// No description provided for @comparison.
  ///
  /// In zh, this message translates to:
  /// **'对比'**
  String get comparison;

  /// No description provided for @winner.
  ///
  /// In zh, this message translates to:
  /// **'获胜者'**
  String get winner;

  /// No description provided for @quality.
  ///
  /// In zh, this message translates to:
  /// **'质量'**
  String get quality;

  /// No description provided for @speed.
  ///
  /// In zh, this message translates to:
  /// **'速度'**
  String get speed;

  /// No description provided for @reliability.
  ///
  /// In zh, this message translates to:
  /// **'可靠性'**
  String get reliability;

  /// No description provided for @coverage.
  ///
  /// In zh, this message translates to:
  /// **'覆盖范围'**
  String get coverage;

  /// No description provided for @avgSpeed.
  ///
  /// In zh, this message translates to:
  /// **'平均速度'**
  String get avgSpeed;

  /// No description provided for @population.
  ///
  /// In zh, this message translates to:
  /// **'人口'**
  String get population;

  /// No description provided for @timezone.
  ///
  /// In zh, this message translates to:
  /// **'时区'**
  String get timezone;

  /// No description provided for @languages.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get languages;

  /// No description provided for @climate.
  ///
  /// In zh, this message translates to:
  /// **'气候'**
  String get climate;

  /// No description provided for @visa.
  ///
  /// In zh, this message translates to:
  /// **'签证'**
  String get visa;

  /// No description provided for @visaRequired.
  ///
  /// In zh, this message translates to:
  /// **'需要签证'**
  String get visaRequired;

  /// No description provided for @visaFree.
  ///
  /// In zh, this message translates to:
  /// **'免签'**
  String get visaFree;

  /// No description provided for @healthcareQuality.
  ///
  /// In zh, this message translates to:
  /// **'医疗质量'**
  String get healthcareQuality;

  /// No description provided for @hospitals.
  ///
  /// In zh, this message translates to:
  /// **'医院'**
  String get hospitals;

  /// No description provided for @transportation.
  ///
  /// In zh, this message translates to:
  /// **'交通'**
  String get transportation;

  /// No description provided for @publicTransport.
  ///
  /// In zh, this message translates to:
  /// **'公共交通、出租车'**
  String get publicTransport;

  /// No description provided for @bikeability.
  ///
  /// In zh, this message translates to:
  /// **'骑行便利性'**
  String get bikeability;

  /// No description provided for @traffic.
  ///
  /// In zh, this message translates to:
  /// **'交通状况'**
  String get traffic;

  /// No description provided for @pollution.
  ///
  /// In zh, this message translates to:
  /// **'污染'**
  String get pollution;

  /// No description provided for @aqi.
  ///
  /// In zh, this message translates to:
  /// **'空气质量指数'**
  String get aqi;

  /// No description provided for @noise.
  ///
  /// In zh, this message translates to:
  /// **'噪音'**
  String get noise;

  /// No description provided for @recreation.
  ///
  /// In zh, this message translates to:
  /// **'娱乐'**
  String get recreation;

  /// No description provided for @restaurants.
  ///
  /// In zh, this message translates to:
  /// **'餐厅'**
  String get restaurants;

  /// No description provided for @cafes.
  ///
  /// In zh, this message translates to:
  /// **'咖啡厅'**
  String get cafes;

  /// No description provided for @bars.
  ///
  /// In zh, this message translates to:
  /// **'酒吧'**
  String get bars;

  /// No description provided for @culture.
  ///
  /// In zh, this message translates to:
  /// **'文化'**
  String get culture;

  /// No description provided for @museums.
  ///
  /// In zh, this message translates to:
  /// **'博物馆'**
  String get museums;

  /// No description provided for @theaters.
  ///
  /// In zh, this message translates to:
  /// **'剧院'**
  String get theaters;

  /// No description provided for @galleries.
  ///
  /// In zh, this message translates to:
  /// **'画廊'**
  String get galleries;

  /// No description provided for @festivals.
  ///
  /// In zh, this message translates to:
  /// **'节日'**
  String get festivals;

  /// No description provided for @concerts.
  ///
  /// In zh, this message translates to:
  /// **'音乐会'**
  String get concerts;

  /// No description provided for @sports.
  ///
  /// In zh, this message translates to:
  /// **'运动'**
  String get sports;

  /// No description provided for @gyms.
  ///
  /// In zh, this message translates to:
  /// **'健身房'**
  String get gyms;

  /// No description provided for @parks.
  ///
  /// In zh, this message translates to:
  /// **'公园'**
  String get parks;

  /// No description provided for @beaches.
  ///
  /// In zh, this message translates to:
  /// **'海滩'**
  String get beaches;

  /// No description provided for @mountains.
  ///
  /// In zh, this message translates to:
  /// **'山脉'**
  String get mountains;

  /// No description provided for @nature.
  ///
  /// In zh, this message translates to:
  /// **'自然'**
  String get nature;

  /// No description provided for @malls.
  ///
  /// In zh, this message translates to:
  /// **'购物中心'**
  String get malls;

  /// No description provided for @markets.
  ///
  /// In zh, this message translates to:
  /// **'市场'**
  String get markets;

  /// No description provided for @groceries.
  ///
  /// In zh, this message translates to:
  /// **'食品杂货'**
  String get groceries;

  /// No description provided for @education.
  ///
  /// In zh, this message translates to:
  /// **'教育'**
  String get education;

  /// No description provided for @schools.
  ///
  /// In zh, this message translates to:
  /// **'学校'**
  String get schools;

  /// No description provided for @universities.
  ///
  /// In zh, this message translates to:
  /// **'大学'**
  String get universities;

  /// No description provided for @libraries.
  ///
  /// In zh, this message translates to:
  /// **'图书馆'**
  String get libraries;

  /// No description provided for @workspace.
  ///
  /// In zh, this message translates to:
  /// **'工作空间'**
  String get workspace;

  /// No description provided for @cafesForWork.
  ///
  /// In zh, this message translates to:
  /// **'工作咖啡厅'**
  String get cafesForWork;

  /// No description provided for @meetingRooms.
  ///
  /// In zh, this message translates to:
  /// **'会议室'**
  String get meetingRooms;

  /// No description provided for @socialLife.
  ///
  /// In zh, this message translates to:
  /// **'社交生活'**
  String get socialLife;

  /// No description provided for @networking.
  ///
  /// In zh, this message translates to:
  /// **'人脉网络'**
  String get networking;

  /// No description provided for @friendliness.
  ///
  /// In zh, this message translates to:
  /// **'友好程度'**
  String get friendliness;

  /// No description provided for @diversity.
  ///
  /// In zh, this message translates to:
  /// **'多样性'**
  String get diversity;

  /// No description provided for @englishSpeaking.
  ///
  /// In zh, this message translates to:
  /// **'英语普及率'**
  String get englishSpeaking;

  /// No description provided for @overall.
  ///
  /// In zh, this message translates to:
  /// **'综合评分'**
  String get overall;

  /// No description provided for @qualityOfLife.
  ///
  /// In zh, this message translates to:
  /// **'生活质量'**
  String get qualityOfLife;

  /// No description provided for @familyScore.
  ///
  /// In zh, this message translates to:
  /// **'家庭友好'**
  String get familyScore;

  /// No description provided for @womenSafety.
  ///
  /// In zh, this message translates to:
  /// **'女性安全'**
  String get womenSafety;

  /// No description provided for @lgbtqSafety.
  ///
  /// In zh, this message translates to:
  /// **'LGBTQ+安全'**
  String get lgbtqSafety;

  /// No description provided for @fun.
  ///
  /// In zh, this message translates to:
  /// **'趣味性'**
  String get fun;

  /// No description provided for @foodSafety.
  ///
  /// In zh, this message translates to:
  /// **'食品安全'**
  String get foodSafety;

  /// No description provided for @freeWiFi.
  ///
  /// In zh, this message translates to:
  /// **'免费WiFi'**
  String get freeWiFi;

  /// No description provided for @expats.
  ///
  /// In zh, this message translates to:
  /// **'外籍人士'**
  String get expats;

  /// No description provided for @digitalNomads.
  ///
  /// In zh, this message translates to:
  /// **'数字游民'**
  String get digitalNomads;

  /// No description provided for @remoteWorkers.
  ///
  /// In zh, this message translates to:
  /// **'远程工作者'**
  String get remoteWorkers;

  /// No description provided for @startupScene.
  ///
  /// In zh, this message translates to:
  /// **'创业环境'**
  String get startupScene;

  /// No description provided for @entrepreneurship.
  ///
  /// In zh, this message translates to:
  /// **'创业精神'**
  String get entrepreneurship;

  /// No description provided for @innovation.
  ///
  /// In zh, this message translates to:
  /// **'创意项目'**
  String get innovation;

  /// No description provided for @techHub.
  ///
  /// In zh, this message translates to:
  /// **'科技中心'**
  String get techHub;

  /// No description provided for @hotels.
  ///
  /// In zh, this message translates to:
  /// **'酒店'**
  String get hotels;

  /// No description provided for @hostels.
  ///
  /// In zh, this message translates to:
  /// **'青年旅社'**
  String get hostels;

  /// No description provided for @apartments.
  ///
  /// In zh, this message translates to:
  /// **'公寓'**
  String get apartments;

  /// No description provided for @rentals.
  ///
  /// In zh, this message translates to:
  /// **'租赁'**
  String get rentals;

  /// No description provided for @realEstate.
  ///
  /// In zh, this message translates to:
  /// **'房地产'**
  String get realEstate;

  /// No description provided for @housingCost.
  ///
  /// In zh, this message translates to:
  /// **'住房成本'**
  String get housingCost;

  /// No description provided for @utilities.
  ///
  /// In zh, this message translates to:
  /// **'水电费'**
  String get utilities;

  /// No description provided for @electricity.
  ///
  /// In zh, this message translates to:
  /// **'电力'**
  String get electricity;

  /// No description provided for @water.
  ///
  /// In zh, this message translates to:
  /// **'水'**
  String get water;

  /// No description provided for @gas.
  ///
  /// In zh, this message translates to:
  /// **'燃气'**
  String get gas;

  /// No description provided for @foodCost.
  ///
  /// In zh, this message translates to:
  /// **'餐饮费用'**
  String get foodCost;

  /// No description provided for @groceryCost.
  ///
  /// In zh, this message translates to:
  /// **'食品杂货费用'**
  String get groceryCost;

  /// No description provided for @restaurantCost.
  ///
  /// In zh, this message translates to:
  /// **'餐厅费用'**
  String get restaurantCost;

  /// No description provided for @transportCost.
  ///
  /// In zh, this message translates to:
  /// **'交通费用'**
  String get transportCost;

  /// No description provided for @entertainmentCost.
  ///
  /// In zh, this message translates to:
  /// **'娱乐费用'**
  String get entertainmentCost;

  /// No description provided for @overallCost.
  ///
  /// In zh, this message translates to:
  /// **'总体费用'**
  String get overallCost;

  /// No description provided for @veryExpensive.
  ///
  /// In zh, this message translates to:
  /// **'非常昂贵'**
  String get veryExpensive;

  /// No description provided for @affordable.
  ///
  /// In zh, this message translates to:
  /// **'负担得起'**
  String get affordable;

  /// No description provided for @value.
  ///
  /// In zh, this message translates to:
  /// **'性价比'**
  String get value;

  /// No description provided for @overallScore.
  ///
  /// In zh, this message translates to:
  /// **'综合评分'**
  String get overallScore;

  /// No description provided for @userReviews.
  ///
  /// In zh, this message translates to:
  /// **'用户评论'**
  String get userReviews;

  /// No description provided for @writeAReview.
  ///
  /// In zh, this message translates to:
  /// **'撰写评价'**
  String get writeAReview;

  /// No description provided for @viewAllReviews.
  ///
  /// In zh, this message translates to:
  /// **'查看所有评价'**
  String get viewAllReviews;

  /// No description provided for @helpful.
  ///
  /// In zh, this message translates to:
  /// **'有用'**
  String get helpful;

  /// No description provided for @notHelpful.
  ///
  /// In zh, this message translates to:
  /// **'无用'**
  String get notHelpful;

  /// No description provided for @reportReview.
  ///
  /// In zh, this message translates to:
  /// **'举报评价'**
  String get reportReview;

  /// No description provided for @verified.
  ///
  /// In zh, this message translates to:
  /// **'已认证'**
  String get verified;

  /// No description provided for @unverified.
  ///
  /// In zh, this message translates to:
  /// **'未验证'**
  String get unverified;

  /// No description provided for @contributor.
  ///
  /// In zh, this message translates to:
  /// **'位贡献者'**
  String get contributor;

  /// No description provided for @localExpert.
  ///
  /// In zh, this message translates to:
  /// **'本地专家'**
  String get localExpert;

  /// No description provided for @frequentTraveler.
  ///
  /// In zh, this message translates to:
  /// **'频繁旅行者'**
  String get frequentTraveler;

  /// No description provided for @lastActive.
  ///
  /// In zh, this message translates to:
  /// **'最后活动'**
  String get lastActive;

  /// No description provided for @contributions.
  ///
  /// In zh, this message translates to:
  /// **'贡献'**
  String get contributions;

  /// No description provided for @readMore.
  ///
  /// In zh, this message translates to:
  /// **'阅读更多'**
  String get readMore;

  /// No description provided for @showLess.
  ///
  /// In zh, this message translates to:
  /// **'收起'**
  String get showLess;

  /// No description provided for @seeMore.
  ///
  /// In zh, this message translates to:
  /// **'查看更多'**
  String get seeMore;

  /// No description provided for @viewMore.
  ///
  /// In zh, this message translates to:
  /// **'查看更多'**
  String get viewMore;

  /// No description provided for @loadMore.
  ///
  /// In zh, this message translates to:
  /// **'加载更多'**
  String get loadMore;

  /// No description provided for @finish.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get finish;

  /// No description provided for @getStarted.
  ///
  /// In zh, this message translates to:
  /// **'开始'**
  String get getStarted;

  /// No description provided for @learnMore.
  ///
  /// In zh, this message translates to:
  /// **'了解更多'**
  String get learnMore;

  /// No description provided for @discoverMore.
  ///
  /// In zh, this message translates to:
  /// **'探索更多'**
  String get discoverMore;

  /// No description provided for @exploreNow.
  ///
  /// In zh, this message translates to:
  /// **'立即探索'**
  String get exploreNow;

  /// No description provided for @reserveNow.
  ///
  /// In zh, this message translates to:
  /// **'立即预定'**
  String get reserveNow;

  /// No description provided for @contactUs.
  ///
  /// In zh, this message translates to:
  /// **'联系我们'**
  String get contactUs;

  /// No description provided for @getInTouch.
  ///
  /// In zh, this message translates to:
  /// **'保持联系'**
  String get getInTouch;

  /// No description provided for @suggestions.
  ///
  /// In zh, this message translates to:
  /// **'建议'**
  String get suggestions;

  /// No description provided for @improvements.
  ///
  /// In zh, this message translates to:
  /// **'改进建议'**
  String get improvements;

  /// No description provided for @goNomad.
  ///
  /// In zh, this message translates to:
  /// **'成为数字游民'**
  String get goNomad;

  /// No description provided for @joinGlobalCommunity.
  ///
  /// In zh, this message translates to:
  /// **'加入全球远程工作者社区'**
  String get joinGlobalCommunity;

  /// No description provided for @chooseUsername.
  ///
  /// In zh, this message translates to:
  /// **'选择您的用户名'**
  String get chooseUsername;

  /// No description provided for @usernameRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入用户名'**
  String get usernameRequired;

  /// No description provided for @usernameMinLength.
  ///
  /// In zh, this message translates to:
  /// **'用户名至少需要3个字符'**
  String get usernameMinLength;

  /// No description provided for @createPassword.
  ///
  /// In zh, this message translates to:
  /// **'创建密码'**
  String get createPassword;

  /// No description provided for @reenterPassword.
  ///
  /// In zh, this message translates to:
  /// **'重新输入密码'**
  String get reenterPassword;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In zh, this message translates to:
  /// **'请确认您的密码'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsNotMatch.
  ///
  /// In zh, this message translates to:
  /// **'密码不匹配'**
  String get passwordsNotMatch;

  /// No description provided for @communityGuidelines.
  ///
  /// In zh, this message translates to:
  /// **'社区准则'**
  String get communityGuidelines;

  /// No description provided for @termsRequired.
  ///
  /// In zh, this message translates to:
  /// **'需要同意条款'**
  String get termsRequired;

  /// No description provided for @pleaseAgreeToTerms.
  ///
  /// In zh, this message translates to:
  /// **'请同意服务条款和社区准则'**
  String get pleaseAgreeToTerms;

  /// No description provided for @joinNomads.
  ///
  /// In zh, this message translates to:
  /// **'加入行途'**
  String get joinNomads;

  /// No description provided for @googleSignIn.
  ///
  /// In zh, this message translates to:
  /// **'Google 登录'**
  String get googleSignIn;

  /// No description provided for @appleSignIn.
  ///
  /// In zh, this message translates to:
  /// **'Apple 登录'**
  String get appleSignIn;

  /// No description provided for @googleAuthComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'Google 认证即将推出'**
  String get googleAuthComingSoon;

  /// No description provided for @appleAuthComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'Apple 认证即将推出'**
  String get appleAuthComingSoon;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In zh, this message translates to:
  /// **'已有账号?'**
  String get alreadyHaveAccount;

  /// No description provided for @welcomeToCommunity.
  ///
  /// In zh, this message translates to:
  /// **'欢迎加入 Nomads 社区!'**
  String get welcomeToCommunity;

  /// No description provided for @joinMembers.
  ///
  /// In zh, this message translates to:
  /// **'加入 38,000+ 会员并获得:'**
  String get joinMembers;

  /// No description provided for @attendMeetups.
  ///
  /// In zh, this message translates to:
  /// **'参加 363 场聚会/年'**
  String get attendMeetups;

  /// No description provided for @inCitiesWorldwide.
  ///
  /// In zh, this message translates to:
  /// **'在全球 100+ 城市'**
  String get inCitiesWorldwide;

  /// No description provided for @meetNewPeople.
  ///
  /// In zh, this message translates to:
  /// **'结识新朋友，寻找约会对象'**
  String get meetNewPeople;

  /// No description provided for @forDatingAndFriends.
  ///
  /// In zh, this message translates to:
  /// **'用于约会和交友'**
  String get forDatingAndFriends;

  /// No description provided for @researchDestinations.
  ///
  /// In zh, this message translates to:
  /// **'研究目的地，找到最适合生活和工作的地方'**
  String get researchDestinations;

  /// No description provided for @findBestPlace.
  ///
  /// In zh, this message translates to:
  /// **'找到最适合您的居住地'**
  String get findBestPlace;

  /// No description provided for @joinExclusiveChat.
  ///
  /// In zh, this message translates to:
  /// **'加入专属聊天'**
  String get joinExclusiveChat;

  /// No description provided for @messagesSentThisMonth.
  ///
  /// In zh, this message translates to:
  /// **'本月发送了 15,000+ 条消息'**
  String get messagesSentThisMonth;

  /// No description provided for @trackTravels.
  ///
  /// In zh, this message translates to:
  /// **'记录您的旅行'**
  String get trackTravels;

  /// No description provided for @shareJourney.
  ///
  /// In zh, this message translates to:
  /// **'分享您的旅程'**
  String get shareJourney;

  /// No description provided for @dataAnalytics.
  ///
  /// In zh, this message translates to:
  /// **'数据分析'**
  String get dataAnalytics;

  /// No description provided for @payment.
  ///
  /// In zh, this message translates to:
  /// **'支付'**
  String get payment;

  /// No description provided for @aiMl.
  ///
  /// In zh, this message translates to:
  /// **'AI/ML'**
  String get aiMl;

  /// No description provided for @socialMedia.
  ///
  /// In zh, this message translates to:
  /// **'社交媒体'**
  String get socialMedia;

  /// No description provided for @ecommerce.
  ///
  /// In zh, this message translates to:
  /// **'电子商务'**
  String get ecommerce;

  /// No description provided for @security.
  ///
  /// In zh, this message translates to:
  /// **'安全'**
  String get security;

  /// No description provided for @freemium.
  ///
  /// In zh, this message translates to:
  /// **'免费增值'**
  String get freemium;

  /// No description provided for @paid.
  ///
  /// In zh, this message translates to:
  /// **'付费'**
  String get paid;

  /// No description provided for @popularity.
  ///
  /// In zh, this message translates to:
  /// **'热门'**
  String get popularity;

  /// No description provided for @bookmarks.
  ///
  /// In zh, this message translates to:
  /// **'书签'**
  String get bookmarks;

  /// No description provided for @cart.
  ///
  /// In zh, this message translates to:
  /// **'购物车'**
  String get cart;

  /// No description provided for @tryDifferentKeywords.
  ///
  /// In zh, this message translates to:
  /// **'尝试不同的关键词'**
  String get tryDifferentKeywords;

  /// No description provided for @hot.
  ///
  /// In zh, this message translates to:
  /// **'热门'**
  String get hot;

  /// No description provided for @responseTime.
  ///
  /// In zh, this message translates to:
  /// **'响应时间'**
  String get responseTime;

  /// No description provided for @apiDetails.
  ///
  /// In zh, this message translates to:
  /// **'API详情'**
  String get apiDetails;

  /// No description provided for @showingDetails.
  ///
  /// In zh, this message translates to:
  /// **'显示详情'**
  String get showingDetails;

  /// No description provided for @bookmarkedApis.
  ///
  /// In zh, this message translates to:
  /// **'已收藏的API'**
  String get bookmarkedApis;

  /// No description provided for @apiCart.
  ///
  /// In zh, this message translates to:
  /// **'API购物车'**
  String get apiCart;

  /// No description provided for @filterOptions.
  ///
  /// In zh, this message translates to:
  /// **'筛选选项'**
  String get filterOptions;

  /// No description provided for @sortOptions.
  ///
  /// In zh, this message translates to:
  /// **'排序选项'**
  String get sortOptions;

  /// No description provided for @selectCurrency.
  ///
  /// In zh, this message translates to:
  /// **'选择货币'**
  String get selectCurrency;

  /// No description provided for @monthlyCost.
  ///
  /// In zh, this message translates to:
  /// **'每月费用'**
  String get monthlyCost;

  /// No description provided for @foodDining.
  ///
  /// In zh, this message translates to:
  /// **'餐饮'**
  String get foodDining;

  /// No description provided for @gym.
  ///
  /// In zh, this message translates to:
  /// **'健身房'**
  String get gym;

  /// No description provided for @coworkingSpace.
  ///
  /// In zh, this message translates to:
  /// **'配套共享空间'**
  String get coworkingSpace;

  /// No description provided for @otherExpenses.
  ///
  /// In zh, this message translates to:
  /// **'其他费用'**
  String get otherExpenses;

  /// No description provided for @monthlyRent.
  ///
  /// In zh, this message translates to:
  /// **'每月租金或酒店'**
  String get monthlyRent;

  /// No description provided for @groceriesRestaurants.
  ///
  /// In zh, this message translates to:
  /// **'杂货、餐厅'**
  String get groceriesRestaurants;

  /// No description provided for @moviesActivities.
  ///
  /// In zh, this message translates to:
  /// **'电影、活动'**
  String get moviesActivities;

  /// No description provided for @gymMembership.
  ///
  /// In zh, this message translates to:
  /// **'健身房会员、运动'**
  String get gymMembership;

  /// No description provided for @workspaceRental.
  ///
  /// In zh, this message translates to:
  /// **'工作空间租赁'**
  String get workspaceRental;

  /// No description provided for @electricityWater.
  ///
  /// In zh, this message translates to:
  /// **'电费、水费、网费'**
  String get electricityWater;

  /// No description provided for @medicalInsurance.
  ///
  /// In zh, this message translates to:
  /// **'医疗、保险'**
  String get medicalInsurance;

  /// No description provided for @clothesPersonal.
  ///
  /// In zh, this message translates to:
  /// **'衣服、个人物品'**
  String get clothesPersonal;

  /// No description provided for @miscellaneous.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get miscellaneous;

  /// No description provided for @additionalNotes.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get additionalNotes;

  /// No description provided for @shareExperience.
  ///
  /// In zh, this message translates to:
  /// **'分享您的花费经验'**
  String get shareExperience;

  /// No description provided for @totalMonthly.
  ///
  /// In zh, this message translates to:
  /// **'每月总计'**
  String get totalMonthly;

  /// No description provided for @averageMonthlyCost.
  ///
  /// In zh, this message translates to:
  /// **'平均月度费用'**
  String get averageMonthlyCost;

  /// No description provided for @sevenDayForecast.
  ///
  /// In zh, this message translates to:
  /// **'7天天气预报'**
  String get sevenDayForecast;

  /// No description provided for @feelsLike.
  ///
  /// In zh, this message translates to:
  /// **'体感温度'**
  String get feelsLike;

  /// No description provided for @wind.
  ///
  /// In zh, this message translates to:
  /// **'风速'**
  String get wind;

  /// No description provided for @pressure.
  ///
  /// In zh, this message translates to:
  /// **'气压'**
  String get pressure;

  /// No description provided for @cloudiness.
  ///
  /// In zh, this message translates to:
  /// **'云量'**
  String get cloudiness;

  /// No description provided for @visibility.
  ///
  /// In zh, this message translates to:
  /// **'能见度'**
  String get visibility;

  /// No description provided for @uvIndex.
  ///
  /// In zh, this message translates to:
  /// **'紫外线指数'**
  String get uvIndex;

  /// No description provided for @sunriseSunset.
  ///
  /// In zh, this message translates to:
  /// **'日出日落'**
  String get sunriseSunset;

  /// No description provided for @sunrise.
  ///
  /// In zh, this message translates to:
  /// **'日出'**
  String get sunrise;

  /// No description provided for @sunset.
  ///
  /// In zh, this message translates to:
  /// **'日落'**
  String get sunset;

  /// No description provided for @fiveDayForecast.
  ///
  /// In zh, this message translates to:
  /// **'5天预报'**
  String get fiveDayForecast;

  /// No description provided for @aqiGood.
  ///
  /// In zh, this message translates to:
  /// **'优'**
  String get aqiGood;

  /// No description provided for @aqiModerate.
  ///
  /// In zh, this message translates to:
  /// **'良'**
  String get aqiModerate;

  /// No description provided for @aqiUnhealthySensitive.
  ///
  /// In zh, this message translates to:
  /// **'轻度污染'**
  String get aqiUnhealthySensitive;

  /// No description provided for @aqiUnhealthy.
  ///
  /// In zh, this message translates to:
  /// **'中度污染'**
  String get aqiUnhealthy;

  /// No description provided for @aqiVeryUnhealthy.
  ///
  /// In zh, this message translates to:
  /// **'重度污染'**
  String get aqiVeryUnhealthy;

  /// No description provided for @aqiHazardous.
  ///
  /// In zh, this message translates to:
  /// **'严重污染'**
  String get aqiHazardous;

  /// No description provided for @daysAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count}天前'**
  String daysAgo(String count);

  /// No description provided for @weeksAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count}周前'**
  String weeksAgo(String count);

  /// No description provided for @monthsAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count}个月前'**
  String monthsAgo(String count);

  /// No description provided for @visited.
  ///
  /// In zh, this message translates to:
  /// **'访问于'**
  String get visited;

  /// No description provided for @posted.
  ///
  /// In zh, this message translates to:
  /// **'发布于'**
  String get posted;

  /// No description provided for @uploaded.
  ///
  /// In zh, this message translates to:
  /// **'上传于'**
  String get uploaded;

  /// No description provided for @dataSource.
  ///
  /// In zh, this message translates to:
  /// **'数据来源'**
  String get dataSource;

  /// No description provided for @updated.
  ///
  /// In zh, this message translates to:
  /// **'更新于'**
  String get updated;

  /// No description provided for @submitCost.
  ///
  /// In zh, this message translates to:
  /// **'提交费用'**
  String get submitCost;

  /// No description provided for @submitting.
  ///
  /// In zh, this message translates to:
  /// **'提交中...'**
  String get submitting;

  /// No description provided for @pleaseEnterCost.
  ///
  /// In zh, this message translates to:
  /// **'请至少输入一项费用'**
  String get pleaseEnterCost;

  /// No description provided for @costShared.
  ///
  /// In zh, this message translates to:
  /// **'您的费用信息已成功分享!'**
  String get costShared;

  /// No description provided for @additionalCostInfo.
  ///
  /// In zh, this message translates to:
  /// **'添加关于您生活费用的其他信息...'**
  String get additionalCostInfo;

  /// No description provided for @aiTravelPlanner.
  ///
  /// In zh, this message translates to:
  /// **'AI旅行规划师'**
  String get aiTravelPlanner;

  /// No description provided for @planYourTrip.
  ///
  /// In zh, this message translates to:
  /// **'规划您的旅行到 {cityName}'**
  String planYourTrip(String cityName);

  /// No description provided for @aiPoweredPlanning.
  ///
  /// In zh, this message translates to:
  /// **'AI智能规划'**
  String get aiPoweredPlanning;

  /// No description provided for @tellPreferences.
  ///
  /// In zh, this message translates to:
  /// **'告诉我们您的偏好，让AI为您创建完美的{cityName}行程'**
  String tellPreferences(String cityName);

  /// No description provided for @departureLocation.
  ///
  /// In zh, this message translates to:
  /// **'出发地点'**
  String get departureLocation;

  /// No description provided for @selectDeparture.
  ///
  /// In zh, this message translates to:
  /// **'选择出发地点'**
  String get selectDeparture;

  /// No description provided for @selectOnMap.
  ///
  /// In zh, this message translates to:
  /// **'在地图上选择'**
  String get selectOnMap;

  /// No description provided for @tapMapIcon.
  ///
  /// In zh, this message translates to:
  /// **'点击地图图标选择您的出发地点'**
  String get tapMapIcon;

  /// No description provided for @tripDuration.
  ///
  /// In zh, this message translates to:
  /// **'旅行天数'**
  String get tripDuration;

  /// No description provided for @day.
  ///
  /// In zh, this message translates to:
  /// **'{count} 天'**
  String day(int count);

  /// No description provided for @budgetLevel.
  ///
  /// In zh, this message translates to:
  /// **'预算等级'**
  String get budgetLevel;

  /// No description provided for @low.
  ///
  /// In zh, this message translates to:
  /// **'低'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In zh, this message translates to:
  /// **'中'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In zh, this message translates to:
  /// **'高'**
  String get high;

  /// No description provided for @luxury.
  ///
  /// In zh, this message translates to:
  /// **'奢华'**
  String get luxury;

  /// No description provided for @travelStyle.
  ///
  /// In zh, this message translates to:
  /// **'旅行风格'**
  String get travelStyle;

  /// No description provided for @adventure.
  ///
  /// In zh, this message translates to:
  /// **'冒险'**
  String get adventure;

  /// No description provided for @relaxation.
  ///
  /// In zh, this message translates to:
  /// **'休闲'**
  String get relaxation;

  /// No description provided for @foodie.
  ///
  /// In zh, this message translates to:
  /// **'美食'**
  String get foodie;

  /// No description provided for @hiking.
  ///
  /// In zh, this message translates to:
  /// **'徒步'**
  String get hiking;

  /// No description provided for @localFood.
  ///
  /// In zh, this message translates to:
  /// **'当地美食'**
  String get localFood;

  /// No description provided for @photography.
  ///
  /// In zh, this message translates to:
  /// **'摄影'**
  String get photography;

  /// No description provided for @history.
  ///
  /// In zh, this message translates to:
  /// **'历史'**
  String get history;

  /// No description provided for @architecture.
  ///
  /// In zh, this message translates to:
  /// **'建筑'**
  String get architecture;

  /// No description provided for @generatePlan.
  ///
  /// In zh, this message translates to:
  /// **'生成旅行计划'**
  String get generatePlan;

  /// No description provided for @generating.
  ///
  /// In zh, this message translates to:
  /// **'生成中...'**
  String get generating;

  /// No description provided for @pleaseSelectDeparture.
  ///
  /// In zh, this message translates to:
  /// **'请选择出发地点'**
  String get pleaseSelectDeparture;

  /// No description provided for @failedToOpenMap.
  ///
  /// In zh, this message translates to:
  /// **'打开地图失败'**
  String get failedToOpenMap;

  /// No description provided for @cities.
  ///
  /// In zh, this message translates to:
  /// **'城市'**
  String get cities;

  /// No description provided for @coworks.
  ///
  /// In zh, this message translates to:
  /// **'共享空间'**
  String get coworks;

  /// No description provided for @countries.
  ///
  /// In zh, this message translates to:
  /// **'国家'**
  String get countries;

  /// No description provided for @meetups.
  ///
  /// In zh, this message translates to:
  /// **'聚会活动'**
  String get meetups;

  /// No description provided for @connections.
  ///
  /// In zh, this message translates to:
  /// **'联系人'**
  String get connections;

  /// No description provided for @viewProfile.
  ///
  /// In zh, this message translates to:
  /// **'查看资料'**
  String get viewProfile;

  /// No description provided for @muteNotifications.
  ///
  /// In zh, this message translates to:
  /// **'静音通知'**
  String get muteNotifications;

  /// No description provided for @blockUser.
  ///
  /// In zh, this message translates to:
  /// **'屏蔽用户'**
  String get blockUser;

  /// No description provided for @muted.
  ///
  /// In zh, this message translates to:
  /// **'已静音'**
  String get muted;

  /// No description provided for @notificationsMuted.
  ///
  /// In zh, this message translates to:
  /// **'已静音通知'**
  String get notificationsMuted;

  /// No description provided for @startConversation.
  ///
  /// In zh, this message translates to:
  /// **'开始与...的对话'**
  String get startConversation;

  /// No description provided for @blockWarning.
  ///
  /// In zh, this message translates to:
  /// **'您确定要屏蔽此用户吗?'**
  String get blockWarning;

  /// No description provided for @blockConfirm.
  ///
  /// In zh, this message translates to:
  /// **'屏蔽后,您将无法看到此用户的消息和活动。'**
  String get blockConfirm;

  /// No description provided for @userBlocked.
  ///
  /// In zh, this message translates to:
  /// **'用户已被屏蔽'**
  String get userBlocked;

  /// No description provided for @filtersApplied.
  ///
  /// In zh, this message translates to:
  /// **'筛选已应用'**
  String get filtersApplied;

  /// No description provided for @showingResults.
  ///
  /// In zh, this message translates to:
  /// **'正在显示符合您条件的结果'**
  String get showingResults;

  /// No description provided for @deepThinking.
  ///
  /// In zh, this message translates to:
  /// **'深度思考'**
  String get deepThinking;

  /// No description provided for @podcast.
  ///
  /// In zh, this message translates to:
  /// **'专属播客'**
  String get podcast;

  /// No description provided for @translation.
  ///
  /// In zh, this message translates to:
  /// **'翻译'**
  String get translation;

  /// No description provided for @creativeAssistant.
  ///
  /// In zh, this message translates to:
  /// **'创作助手'**
  String get creativeAssistant;

  /// No description provided for @freeTrialAvailable.
  ///
  /// In zh, this message translates to:
  /// **'免费试用'**
  String get freeTrialAvailable;

  /// No description provided for @monthlyRate.
  ///
  /// In zh, this message translates to:
  /// **'月租'**
  String get monthlyRate;

  /// No description provided for @locationService.
  ///
  /// In zh, this message translates to:
  /// **'位置服务'**
  String get locationService;

  /// No description provided for @locationDetails.
  ///
  /// In zh, this message translates to:
  /// **'位置详情'**
  String get locationDetails;

  /// No description provided for @noLocationInfo.
  ///
  /// In zh, this message translates to:
  /// **'暂无位置信息'**
  String get noLocationInfo;

  /// No description provided for @latitude.
  ///
  /// In zh, this message translates to:
  /// **'纬度'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In zh, this message translates to:
  /// **'经度'**
  String get longitude;

  /// No description provided for @accuracy.
  ///
  /// In zh, this message translates to:
  /// **'精度'**
  String get accuracy;

  /// No description provided for @altitude.
  ///
  /// In zh, this message translates to:
  /// **'海拔'**
  String get altitude;

  /// No description provided for @distanceCalculation.
  ///
  /// In zh, this message translates to:
  /// **'距离计算'**
  String get distanceCalculation;

  /// No description provided for @stopAutoUpdate.
  ///
  /// In zh, this message translates to:
  /// **'停止自动更新(5秒/次)'**
  String get stopAutoUpdate;

  /// No description provided for @startAutoUpdate.
  ///
  /// In zh, this message translates to:
  /// **'开始自动更新(5秒/次)'**
  String get startAutoUpdate;

  /// No description provided for @manualRefreshLocation.
  ///
  /// In zh, this message translates to:
  /// **'手动刷新位置'**
  String get manualRefreshLocation;

  /// No description provided for @locationSettings.
  ///
  /// In zh, this message translates to:
  /// **'位置设置'**
  String get locationSettings;

  /// No description provided for @snakeGame.
  ///
  /// In zh, this message translates to:
  /// **'贪吃蛇游戏'**
  String get snakeGame;

  /// No description provided for @score.
  ///
  /// In zh, this message translates to:
  /// **'分数'**
  String get score;

  /// No description provided for @length.
  ///
  /// In zh, this message translates to:
  /// **'长度'**
  String get length;

  /// No description provided for @readyToStart.
  ///
  /// In zh, this message translates to:
  /// **'准备开始游戏'**
  String get readyToStart;

  /// No description provided for @gamePlaying.
  ///
  /// In zh, this message translates to:
  /// **'游戏进行中...'**
  String get gamePlaying;

  /// No description provided for @gamePaused.
  ///
  /// In zh, this message translates to:
  /// **'游戏已暂停'**
  String get gamePaused;

  /// No description provided for @gameOver.
  ///
  /// In zh, this message translates to:
  /// **'游戏结束!'**
  String get gameOver;

  /// No description provided for @finalScore.
  ///
  /// In zh, this message translates to:
  /// **'最终分数'**
  String get finalScore;

  /// No description provided for @pause.
  ///
  /// In zh, this message translates to:
  /// **'暂停'**
  String get pause;

  /// No description provided for @start.
  ///
  /// In zh, this message translates to:
  /// **'开始'**
  String get start;

  /// No description provided for @resetGame.
  ///
  /// In zh, this message translates to:
  /// **'重置'**
  String get resetGame;

  /// No description provided for @directionControl.
  ///
  /// In zh, this message translates to:
  /// **'方向控制'**
  String get directionControl;

  /// No description provided for @openingNativeMapPicker.
  ///
  /// In zh, this message translates to:
  /// **'正在打开地图选择器...'**
  String get openingNativeMapPicker;

  /// No description provided for @mapPicker.
  ///
  /// In zh, this message translates to:
  /// **'地图选择器'**
  String get mapPicker;

  /// No description provided for @usesNativeAMapSDK.
  ///
  /// In zh, this message translates to:
  /// **'使用原生 iOS 高德地图 SDK'**
  String get usesNativeAMapSDK;

  /// No description provided for @openMapPicker.
  ///
  /// In zh, this message translates to:
  /// **'打开地图选择器'**
  String get openMapPicker;

  /// No description provided for @failedToOpenMapPicker.
  ///
  /// In zh, this message translates to:
  /// **'无法打开地图选择器'**
  String get failedToOpenMapPicker;

  /// No description provided for @secondPage.
  ///
  /// In zh, this message translates to:
  /// **'第二页'**
  String get secondPage;

  /// No description provided for @secondPageCounterText.
  ///
  /// In zh, this message translates to:
  /// **'第二页,计数器同样可用:'**
  String get secondPageCounterText;

  /// No description provided for @backToHome.
  ///
  /// In zh, this message translates to:
  /// **'返回首页'**
  String get backToHome;

  /// No description provided for @testAuth.
  ///
  /// In zh, this message translates to:
  /// **'测试认证'**
  String get testAuth;

  /// No description provided for @testLoginFunction.
  ///
  /// In zh, this message translates to:
  /// **'用于测试登录功能'**
  String get testLoginFunction;

  /// No description provided for @goToLoginPage.
  ///
  /// In zh, this message translates to:
  /// **'前往登录页面'**
  String get goToLoginPage;

  /// No description provided for @amapNativeTest.
  ///
  /// In zh, this message translates to:
  /// **'高德原生测试'**
  String get amapNativeTest;

  /// No description provided for @testPlatformChannel.
  ///
  /// In zh, this message translates to:
  /// **'测试平台通道'**
  String get testPlatformChannel;

  /// No description provided for @testConnection.
  ///
  /// In zh, this message translates to:
  /// **'测试连接'**
  String get testConnection;

  /// No description provided for @notTested.
  ///
  /// In zh, this message translates to:
  /// **'未测试'**
  String get notTested;

  /// No description provided for @testing.
  ///
  /// In zh, this message translates to:
  /// **'测试中...'**
  String get testing;

  /// No description provided for @platformChannelConnected.
  ///
  /// In zh, this message translates to:
  /// **'✓ 平台通道已连接!'**
  String get platformChannelConnected;

  /// No description provided for @connectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'✗ 连接失败'**
  String get connectionFailed;

  /// No description provided for @openMapPickerSection.
  ///
  /// In zh, this message translates to:
  /// **'2. 打开地图选择器'**
  String get openMapPickerSection;

  /// No description provided for @openNativeMapPicker.
  ///
  /// In zh, this message translates to:
  /// **'打开原生地图选择器'**
  String get openNativeMapPicker;

  /// No description provided for @getCurrentLocationSection.
  ///
  /// In zh, this message translates to:
  /// **'3. 获取当前位置'**
  String get getCurrentLocationSection;

  /// No description provided for @getCurrentLocation.
  ///
  /// In zh, this message translates to:
  /// **'获取当前位置'**
  String get getCurrentLocation;

  /// No description provided for @selectedLocation.
  ///
  /// In zh, this message translates to:
  /// **'📍 已选位置'**
  String get selectedLocation;

  /// No description provided for @instructions.
  ///
  /// In zh, this message translates to:
  /// **'📖 使用说明'**
  String get instructions;

  /// No description provided for @instruction1.
  ///
  /// In zh, this message translates to:
  /// **'1. 首先测试 Platform Channel 连接'**
  String get instruction1;

  /// No description provided for @instruction2.
  ///
  /// In zh, this message translates to:
  /// **'2. 如果已连接，打开原生地图选择器'**
  String get instruction2;

  /// No description provided for @instruction3.
  ///
  /// In zh, this message translates to:
  /// **'3. 拖动地图选择位置'**
  String get instruction3;

  /// No description provided for @instruction4.
  ///
  /// In zh, this message translates to:
  /// **'4. 点击“确认位置”返回'**
  String get instruction4;

  /// No description provided for @simulatorNote.
  ///
  /// In zh, this message translates to:
  /// **'注意：地图瓦片可能在 iOS 模拟器中无法加载。请使用真机进行完整测试。'**
  String get simulatorNote;

  /// No description provided for @locationSelected.
  ///
  /// In zh, this message translates to:
  /// **'位置已选择!'**
  String get locationSelected;

  /// No description provided for @gotCurrentLocation.
  ///
  /// In zh, this message translates to:
  /// **'已获取当前位置!'**
  String get gotCurrentLocation;

  /// No description provided for @failedToGetLocation.
  ///
  /// In zh, this message translates to:
  /// **'获取位置失败'**
  String get failedToGetLocation;

  /// No description provided for @province.
  ///
  /// In zh, this message translates to:
  /// **'省份'**
  String get province;

  /// No description provided for @instructionStep1.
  ///
  /// In zh, this message translates to:
  /// **'1. 首先测试平台通道连接'**
  String get instructionStep1;

  /// No description provided for @instructionStep2.
  ///
  /// In zh, this message translates to:
  /// **'2. 如果连接成功,打开原生地图选择器'**
  String get instructionStep2;

  /// No description provided for @instructionStep3.
  ///
  /// In zh, this message translates to:
  /// **'3. 拖动地图选择一个位置'**
  String get instructionStep3;

  /// No description provided for @instructionStep4.
  ///
  /// In zh, this message translates to:
  /// **'4. 点击\'确认位置\'返回'**
  String get instructionStep4;

  /// No description provided for @mapTilesNote.
  ///
  /// In zh, this message translates to:
  /// **'注意: 地图瓦片可能无法在iOS模拟器中加载。请使用真实设备进行完整测试。'**
  String get mapTilesNote;

  /// No description provided for @selectVenue.
  ///
  /// In zh, this message translates to:
  /// **'选择场地'**
  String get selectVenue;

  /// No description provided for @venues.
  ///
  /// In zh, this message translates to:
  /// **'场地'**
  String get venues;

  /// No description provided for @noSelection.
  ///
  /// In zh, this message translates to:
  /// **'未选择'**
  String get noSelection;

  /// No description provided for @pleaseSelectVenue.
  ///
  /// In zh, this message translates to:
  /// **'请先选择一个场地'**
  String get pleaseSelectVenue;

  /// No description provided for @venuesCount.
  ///
  /// In zh, this message translates to:
  /// **'{count}个场地'**
  String venuesCount(Object count);

  /// No description provided for @restaurant.
  ///
  /// In zh, this message translates to:
  /// **'餐厅'**
  String get restaurant;

  /// No description provided for @hotel.
  ///
  /// In zh, this message translates to:
  /// **'酒店'**
  String get hotel;

  /// No description provided for @trending.
  ///
  /// In zh, this message translates to:
  /// **'热门'**
  String get trending;

  /// No description provided for @featured.
  ///
  /// In zh, this message translates to:
  /// **'精选'**
  String get featured;

  /// No description provided for @shopNow.
  ///
  /// In zh, this message translates to:
  /// **'立即购买'**
  String get shopNow;

  /// No description provided for @viewAll.
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get viewAll;

  /// No description provided for @welcomeBack.
  ///
  /// In zh, this message translates to:
  /// **'欢迎回来'**
  String get welcomeBack;

  /// No description provided for @emailOrUsername.
  ///
  /// In zh, this message translates to:
  /// **'邮箱或用户名'**
  String get emailOrUsername;

  /// No description provided for @dontHaveAccount.
  ///
  /// In zh, this message translates to:
  /// **'还没有账号?'**
  String get dontHaveAccount;

  /// No description provided for @overallRating.
  ///
  /// In zh, this message translates to:
  /// **'总体评分'**
  String get overallRating;

  /// No description provided for @tapStarsToRate.
  ///
  /// In zh, this message translates to:
  /// **'点击星星评分'**
  String get tapStarsToRate;

  /// No description provided for @reviewTitle.
  ///
  /// In zh, this message translates to:
  /// **'评价标题'**
  String get reviewTitle;

  /// No description provided for @reviewTitleHint.
  ///
  /// In zh, this message translates to:
  /// **'给您的评论起个标题'**
  String get reviewTitleHint;

  /// No description provided for @yourReview.
  ///
  /// In zh, this message translates to:
  /// **'您的评论'**
  String get yourReview;

  /// No description provided for @shareYourExperience.
  ///
  /// In zh, this message translates to:
  /// **'分享您在这个城市的体验...'**
  String get shareYourExperience;

  /// No description provided for @addPhotos.
  ///
  /// In zh, this message translates to:
  /// **'添加照片'**
  String get addPhotos;

  /// No description provided for @addPhoto.
  ///
  /// In zh, this message translates to:
  /// **'添加照片'**
  String get addPhoto;

  /// No description provided for @reviewGuidelines.
  ///
  /// In zh, this message translates to:
  /// **'评价指南'**
  String get reviewGuidelines;

  /// No description provided for @beHonest.
  ///
  /// In zh, this message translates to:
  /// **'• 诚实客观'**
  String get beHonest;

  /// No description provided for @beSpecific.
  ///
  /// In zh, this message translates to:
  /// **'• 具体详细'**
  String get beSpecific;

  /// No description provided for @beRespectful.
  ///
  /// In zh, this message translates to:
  /// **'• 尊重他人'**
  String get beRespectful;

  /// No description provided for @submitReview.
  ///
  /// In zh, this message translates to:
  /// **'提交评论'**
  String get submitReview;

  /// No description provided for @pleaseProvideRating.
  ///
  /// In zh, this message translates to:
  /// **'请提供评分'**
  String get pleaseProvideRating;

  /// No description provided for @discussions.
  ///
  /// In zh, this message translates to:
  /// **'讨论'**
  String get discussions;

  /// No description provided for @joinMeetup.
  ///
  /// In zh, this message translates to:
  /// **'加入聚会'**
  String get joinMeetup;

  /// No description provided for @pastMeetups.
  ///
  /// In zh, this message translates to:
  /// **'过去的聚会'**
  String get pastMeetups;

  /// No description provided for @compareCity.
  ///
  /// In zh, this message translates to:
  /// **'城市对比'**
  String get compareCity;

  /// No description provided for @selectCitiesToCompare.
  ///
  /// In zh, this message translates to:
  /// **'选择要对比的城市'**
  String get selectCitiesToCompare;

  /// No description provided for @coworkingDetail.
  ///
  /// In zh, this message translates to:
  /// **'共享空间详情'**
  String get coworkingDetail;

  /// No description provided for @workingHours.
  ///
  /// In zh, this message translates to:
  /// **'工作时间'**
  String get workingHours;

  /// No description provided for @monthlyPrice.
  ///
  /// In zh, this message translates to:
  /// **'月费'**
  String get monthlyPrice;

  /// No description provided for @dailyPrice.
  ///
  /// In zh, this message translates to:
  /// **'日费'**
  String get dailyPrice;

  /// No description provided for @uploadPhotos.
  ///
  /// In zh, this message translates to:
  /// **'上传照片'**
  String get uploadPhotos;

  /// No description provided for @cityChat.
  ///
  /// In zh, this message translates to:
  /// **'城市聊天'**
  String get cityChat;

  /// No description provided for @online.
  ///
  /// In zh, this message translates to:
  /// **'在线'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In zh, this message translates to:
  /// **'离线'**
  String get offline;

  /// No description provided for @myPlans.
  ///
  /// In zh, this message translates to:
  /// **'我的计划'**
  String get myPlans;

  /// No description provided for @notes.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get notes;

  /// No description provided for @attractions.
  ///
  /// In zh, this message translates to:
  /// **'景点'**
  String get attractions;

  /// No description provided for @dashboard.
  ///
  /// In zh, this message translates to:
  /// **'仪表板'**
  String get dashboard;

  /// No description provided for @timeRange.
  ///
  /// In zh, this message translates to:
  /// **'时间范围'**
  String get timeRange;

  /// No description provided for @startingSoon.
  ///
  /// In zh, this message translates to:
  /// **'即将开始'**
  String get startingSoon;

  /// No description provided for @dateAndTime.
  ///
  /// In zh, this message translates to:
  /// **'日期时间'**
  String get dateAndTime;

  /// No description provided for @eventOrganizer.
  ///
  /// In zh, this message translates to:
  /// **'活动组织者'**
  String get eventOrganizer;

  /// No description provided for @message.
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get message;

  /// No description provided for @noAttendeesYet.
  ///
  /// In zh, this message translates to:
  /// **'还没有参与者,成为第一个加入的人吧!'**
  String get noAttendeesYet;

  /// No description provided for @leaveMeetup.
  ///
  /// In zh, this message translates to:
  /// **'退出活动'**
  String get leaveMeetup;

  /// No description provided for @ended.
  ///
  /// In zh, this message translates to:
  /// **'已结束'**
  String get ended;

  /// No description provided for @full.
  ///
  /// In zh, this message translates to:
  /// **'已满员'**
  String get full;

  /// No description provided for @joinedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'您已成功加入此活动'**
  String get joinedSuccessfully;

  /// No description provided for @leftMeetup.
  ///
  /// In zh, this message translates to:
  /// **'已退出活动'**
  String get leftMeetup;

  /// No description provided for @youLeftMeetup.
  ///
  /// In zh, this message translates to:
  /// **'您已退出此活动'**
  String get youLeftMeetup;

  /// No description provided for @joinRequired.
  ///
  /// In zh, this message translates to:
  /// **'需要加入'**
  String get joinRequired;

  /// No description provided for @joinToAccessChat.
  ///
  /// In zh, this message translates to:
  /// **'您需要先加入此活动才能访问群聊'**
  String get joinToAccessChat;

  /// No description provided for @shareMeetupComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'分享活动功能即将推出!'**
  String get shareMeetupComingSoon;

  /// No description provided for @openingChatWith.
  ///
  /// In zh, this message translates to:
  /// **'正在打开与 {name} 的聊天...'**
  String openingChatWith(String name);

  /// No description provided for @allAttendees.
  ///
  /// In zh, this message translates to:
  /// **'所有参与者'**
  String get allAttendees;

  /// No description provided for @user.
  ///
  /// In zh, this message translates to:
  /// **'用户'**
  String get user;

  /// No description provided for @digitalNomad.
  ///
  /// In zh, this message translates to:
  /// **'数字游民'**
  String get digitalNomad;

  /// No description provided for @meetupIsFull.
  ///
  /// In zh, this message translates to:
  /// **'此活动已满员'**
  String get meetupIsFull;

  /// No description provided for @attendeesCount.
  ///
  /// In zh, this message translates to:
  /// **'参与者 ({count})'**
  String attendeesCount(String count);

  /// No description provided for @allMeetups.
  ///
  /// In zh, this message translates to:
  /// **'全部聚会'**
  String get allMeetups;

  /// No description provided for @past.
  ///
  /// In zh, this message translates to:
  /// **'过往'**
  String get past;

  /// No description provided for @upcoming.
  ///
  /// In zh, this message translates to:
  /// **'即将到来'**
  String get upcoming;

  /// No description provided for @statusOngoing.
  ///
  /// In zh, this message translates to:
  /// **'进行中'**
  String get statusOngoing;

  /// No description provided for @statusCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get statusCancelled;

  /// No description provided for @joinedEvents.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个已加入的活动'**
  String joinedEvents(String count);

  /// No description provided for @noJoinedMeetupsYet.
  ///
  /// In zh, this message translates to:
  /// **'还没有加入任何聚会'**
  String get noJoinedMeetupsYet;

  /// No description provided for @noPastMeetups.
  ///
  /// In zh, this message translates to:
  /// **'暂无过往聚会'**
  String get noPastMeetups;

  /// No description provided for @noMeetupsAvailable.
  ///
  /// In zh, this message translates to:
  /// **'暂无可用聚会'**
  String get noMeetupsAvailable;

  /// No description provided for @myMeetups.
  ///
  /// In zh, this message translates to:
  /// **'我的聚会'**
  String get myMeetups;

  /// No description provided for @noMeetups.
  ///
  /// In zh, this message translates to:
  /// **'暂无聚会'**
  String get noMeetups;

  /// No description provided for @createFirstMeetup.
  ///
  /// In zh, this message translates to:
  /// **'创建您的第一个聚会来与其他游牧者建立联系'**
  String get createFirstMeetup;

  /// No description provided for @confirmCancelMeetupTitle.
  ///
  /// In zh, this message translates to:
  /// **'取消活动'**
  String get confirmCancelMeetupTitle;

  /// No description provided for @confirmCancelMeetupMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定要取消这个活动吗？此操作无法撤销。'**
  String get confirmCancelMeetupMessage;

  /// No description provided for @confirmLeaveMeetupTitle.
  ///
  /// In zh, this message translates to:
  /// **'退出活动'**
  String get confirmLeaveMeetupTitle;

  /// No description provided for @confirmLeaveMeetupMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定要退出这个活动吗？'**
  String get confirmLeaveMeetupMessage;

  /// No description provided for @cancelMeetupSuccess.
  ///
  /// In zh, this message translates to:
  /// **'活动已取消'**
  String get cancelMeetupSuccess;

  /// No description provided for @cancelMeetupFailed.
  ///
  /// In zh, this message translates to:
  /// **'取消活动失败'**
  String get cancelMeetupFailed;

  /// No description provided for @leaveMeetupFailed.
  ///
  /// In zh, this message translates to:
  /// **'退出活动失败'**
  String get leaveMeetupFailed;

  /// No description provided for @join.
  ///
  /// In zh, this message translates to:
  /// **'加入'**
  String get join;

  /// No description provided for @youHaveJoined.
  ///
  /// In zh, this message translates to:
  /// **'您已加入 {title}'**
  String youHaveJoined(String title);

  /// No description provided for @youLeft.
  ///
  /// In zh, this message translates to:
  /// **'您已退出 {title}'**
  String youLeft(String title);

  /// No description provided for @country.
  ///
  /// In zh, this message translates to:
  /// **'国家'**
  String get country;

  /// No description provided for @autoDetectedLocation.
  ///
  /// In zh, this message translates to:
  /// **'根据您的当前位置自动检测'**
  String get autoDetectedLocation;

  /// No description provided for @meetupType.
  ///
  /// In zh, this message translates to:
  /// **'类型'**
  String get meetupType;

  /// No description provided for @maximumAttendees.
  ///
  /// In zh, this message translates to:
  /// **'最大参与人数'**
  String get maximumAttendees;

  /// No description provided for @peoplePlus.
  ///
  /// In zh, this message translates to:
  /// **'100+ 人'**
  String get peoplePlus;

  /// No description provided for @peopleCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人'**
  String peopleCount(String count);

  /// No description provided for @applyFilters.
  ///
  /// In zh, this message translates to:
  /// **'应用筛选'**
  String get applyFilters;

  /// No description provided for @excellent.
  ///
  /// In zh, this message translates to:
  /// **'优秀!'**
  String get excellent;

  /// No description provided for @veryGood.
  ///
  /// In zh, this message translates to:
  /// **'非常好'**
  String get veryGood;

  /// No description provided for @good.
  ///
  /// In zh, this message translates to:
  /// **'良好'**
  String get good;

  /// No description provided for @fair.
  ///
  /// In zh, this message translates to:
  /// **'一般'**
  String get fair;

  /// No description provided for @poor.
  ///
  /// In zh, this message translates to:
  /// **'较差'**
  String get poor;

  /// No description provided for @veryPoor.
  ///
  /// In zh, this message translates to:
  /// **'很差'**
  String get veryPoor;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In zh, this message translates to:
  /// **'请输入标题'**
  String get pleaseEnterTitle;

  /// No description provided for @titleMinLength.
  ///
  /// In zh, this message translates to:
  /// **'标题至少需要5个字符'**
  String get titleMinLength;

  /// No description provided for @yourExperience.
  ///
  /// In zh, this message translates to:
  /// **'您的体验'**
  String get yourExperience;

  /// No description provided for @experienceHint.
  ///
  /// In zh, this message translates to:
  /// **'分享您的体验、建议和推荐...\n\n您最喜欢什么?\n有什么可以改进的?\n给其他数字游民的建议?'**
  String get experienceHint;

  /// No description provided for @pleaseShareExperience.
  ///
  /// In zh, this message translates to:
  /// **'请分享您的体验'**
  String get pleaseShareExperience;

  /// No description provided for @experienceMinLength.
  ///
  /// In zh, this message translates to:
  /// **'请至少输入20个字符'**
  String get experienceMinLength;

  /// No description provided for @guidelineHonest.
  ///
  /// In zh, this message translates to:
  /// **'✓ 诚实详细地描述您的体验'**
  String get guidelineHonest;

  /// No description provided for @guidelineFacts.
  ///
  /// In zh, this message translates to:
  /// **'✓ 关注事实和具体例子'**
  String get guidelineFacts;

  /// No description provided for @guidelineRespect.
  ///
  /// In zh, this message translates to:
  /// **'✓ 尊重他人,避免使用攻击性语言'**
  String get guidelineRespect;

  /// No description provided for @guidelinePhotos.
  ///
  /// In zh, this message translates to:
  /// **'✓ 照片应相关且适当'**
  String get guidelinePhotos;

  /// No description provided for @missingRating.
  ///
  /// In zh, this message translates to:
  /// **'缺少评分'**
  String get missingRating;

  /// No description provided for @pleaseSelectRating.
  ///
  /// In zh, this message translates to:
  /// **'提交前请先选择评分'**
  String get pleaseSelectRating;

  /// No description provided for @reviewSubmitted.
  ///
  /// In zh, this message translates to:
  /// **'您的评价已成功提交!'**
  String get reviewSubmitted;

  /// No description provided for @failedToSubmitReview.
  ///
  /// In zh, this message translates to:
  /// **'提交评价失败: {error}'**
  String failedToSubmitReview(String error);

  /// 选择图片失败提示
  ///
  /// In zh, this message translates to:
  /// **'选择图片失败：{error}'**
  String failedToPickImages(String error);

  /// No description provided for @invalidCityId.
  ///
  /// In zh, this message translates to:
  /// **'城市ID无效,无法提交评论'**
  String get invalidCityId;

  /// No description provided for @cannotSubmitReview.
  ///
  /// In zh, this message translates to:
  /// **'无法提交评论'**
  String get cannotSubmitReview;

  /// No description provided for @maxPhotosWarning.
  ///
  /// In zh, this message translates to:
  /// **'最多只能选择5张图片'**
  String get maxPhotosWarning;

  /// No description provided for @coworkingReviewSubmitSuccess.
  ///
  /// In zh, this message translates to:
  /// **'评论提交成功！'**
  String get coworkingReviewSubmitSuccess;

  /// No description provided for @submitFailed.
  ///
  /// In zh, this message translates to:
  /// **'提交失败: {error}'**
  String submitFailed(String error);

  /// No description provided for @visitDate.
  ///
  /// In zh, this message translates to:
  /// **'访问日期'**
  String get visitDate;

  /// No description provided for @visitDateOptional.
  ///
  /// In zh, this message translates to:
  /// **'访问日期(可选)'**
  String get visitDateOptional;

  /// No description provided for @whenDidYouVisit.
  ///
  /// In zh, this message translates to:
  /// **'您什么时候去的?'**
  String get whenDidYouVisit;

  /// No description provided for @sumUpExperience.
  ///
  /// In zh, this message translates to:
  /// **'用几句话总结您的体验'**
  String get sumUpExperience;

  /// No description provided for @coworkingExperienceHint.
  ///
  /// In zh, this message translates to:
  /// **'分享您关于WiFi、工作空间、氛围的体验...'**
  String get coworkingExperienceHint;

  /// No description provided for @reviewMinLength.
  ///
  /// In zh, this message translates to:
  /// **'评论至少需要20个字符'**
  String get reviewMinLength;

  /// No description provided for @photosOptional.
  ///
  /// In zh, this message translates to:
  /// **'照片(可选)'**
  String get photosOptional;

  /// No description provided for @addFromGallery.
  ///
  /// In zh, this message translates to:
  /// **'从相册添加'**
  String get addFromGallery;

  /// No description provided for @takeAPhoto.
  ///
  /// In zh, this message translates to:
  /// **'拍一张照片'**
  String get takeAPhoto;

  /// No description provided for @coworkingReviewGuidelines.
  ///
  /// In zh, this message translates to:
  /// **'评论指南'**
  String get coworkingReviewGuidelines;

  /// No description provided for @coworkingGuidelineHonest.
  ///
  /// In zh, this message translates to:
  /// **'• 诚实具体'**
  String get coworkingGuidelineHonest;

  /// No description provided for @coworkingGuidelineFocus.
  ///
  /// In zh, this message translates to:
  /// **'• 关注工作空间功能'**
  String get coworkingGuidelineFocus;

  /// No description provided for @coworkingGuidelineMention.
  ///
  /// In zh, this message translates to:
  /// **'• 提及WiFi、噪音、设施'**
  String get coworkingGuidelineMention;

  /// No description provided for @coworkingGuidelineRespectful.
  ///
  /// In zh, this message translates to:
  /// **'• 尊重他人，建设性反馈'**
  String get coworkingGuidelineRespectful;

  /// No description provided for @loginToContinue.
  ///
  /// In zh, this message translates to:
  /// **'登录您的账号以继续使用'**
  String get loginToContinue;

  /// No description provided for @orLoginWith.
  ///
  /// In zh, this message translates to:
  /// **'或使用其他方式登录'**
  String get orLoginWith;

  /// No description provided for @registerNow.
  ///
  /// In zh, this message translates to:
  /// **'立即注册'**
  String get registerNow;

  /// No description provided for @registerInDevelopment.
  ///
  /// In zh, this message translates to:
  /// **'立即注册功能开发中'**
  String get registerInDevelopment;

  /// No description provided for @hint.
  ///
  /// In zh, this message translates to:
  /// **'提示'**
  String get hint;

  /// No description provided for @phoneNumber.
  ///
  /// In zh, this message translates to:
  /// **'手机号'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In zh, this message translates to:
  /// **'请输入手机号'**
  String get enterPhoneNumber;

  /// No description provided for @enterPassword.
  ///
  /// In zh, this message translates to:
  /// **'请输入密码'**
  String get enterPassword;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In zh, this message translates to:
  /// **'忘记密码?'**
  String get forgotPasswordQuestion;

  /// No description provided for @forgotPasswordInDevelopment.
  ///
  /// In zh, this message translates to:
  /// **'忘记密码功能开发中'**
  String get forgotPasswordInDevelopment;

  /// No description provided for @passwordLogin.
  ///
  /// In zh, this message translates to:
  /// **'密码登录'**
  String get passwordLogin;

  /// No description provided for @verificationCodeLogin.
  ///
  /// In zh, this message translates to:
  /// **'验证码登录'**
  String get verificationCodeLogin;

  /// No description provided for @secureLoginDescription.
  ///
  /// In zh, this message translates to:
  /// **'使用您的手机号登录管理 API 与追踪进度安全的使用。'**
  String get secureLoginDescription;

  /// No description provided for @sendCode.
  ///
  /// In zh, this message translates to:
  /// **'获取验证码'**
  String get sendCode;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In zh, this message translates to:
  /// **'请输入手机号'**
  String get pleaseEnterPhone;

  /// No description provided for @pleaseEnterValidPhone.
  ///
  /// In zh, this message translates to:
  /// **'请输入正确的手机号'**
  String get pleaseEnterValidPhone;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In zh, this message translates to:
  /// **'请输入密码'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In zh, this message translates to:
  /// **'密码至少6位'**
  String get passwordMinLength;

  /// No description provided for @pleaseEnterCode.
  ///
  /// In zh, this message translates to:
  /// **'请输入验证码'**
  String get pleaseEnterCode;

  /// No description provided for @codeLength.
  ///
  /// In zh, this message translates to:
  /// **'验证码必须为6位数字'**
  String get codeLength;

  /// No description provided for @enterVerificationCode.
  ///
  /// In zh, this message translates to:
  /// **'请输入验证码'**
  String get enterVerificationCode;

  /// No description provided for @resend.
  ///
  /// In zh, this message translates to:
  /// **'重新发送'**
  String get resend;

  /// No description provided for @resendIn.
  ///
  /// In zh, this message translates to:
  /// **'{seconds}秒后重发'**
  String resendIn(String seconds);

  /// No description provided for @rememberMe.
  ///
  /// In zh, this message translates to:
  /// **'记住我'**
  String get rememberMe;

  /// No description provided for @verificationCode.
  ///
  /// In zh, this message translates to:
  /// **'验证码'**
  String get verificationCode;

  /// No description provided for @generatingAiPlan.
  ///
  /// In zh, this message translates to:
  /// **'正在生成您的AI旅行计划...'**
  String get generatingAiPlan;

  /// No description provided for @failedToGeneratePlan.
  ///
  /// In zh, this message translates to:
  /// **'生成旅行计划失败'**
  String get failedToGeneratePlan;

  /// No description provided for @pleaseTryAgain.
  ///
  /// In zh, this message translates to:
  /// **'请重试'**
  String get pleaseTryAgain;

  /// No description provided for @aiGeneratedPlan.
  ///
  /// In zh, this message translates to:
  /// **'AI生成计划'**
  String get aiGeneratedPlan;

  /// No description provided for @personalizedForYou.
  ///
  /// In zh, this message translates to:
  /// **'为您量身定制'**
  String get personalizedForYou;

  /// No description provided for @from.
  ///
  /// In zh, this message translates to:
  /// **'来自'**
  String get from;

  /// No description provided for @budgetBreakdown.
  ///
  /// In zh, this message translates to:
  /// **'预算明细'**
  String get budgetBreakdown;

  /// No description provided for @dailyItinerary.
  ///
  /// In zh, this message translates to:
  /// **'每日行程'**
  String get dailyItinerary;

  /// No description provided for @mustVisitAttractions.
  ///
  /// In zh, this message translates to:
  /// **'必游景点'**
  String get mustVisitAttractions;

  /// No description provided for @recommendedRestaurants.
  ///
  /// In zh, this message translates to:
  /// **'推荐餐厅'**
  String get recommendedRestaurants;

  /// No description provided for @travelTips.
  ///
  /// In zh, this message translates to:
  /// **'旅行小贴士'**
  String get travelTips;

  /// No description provided for @totalEstimatedCost.
  ///
  /// In zh, this message translates to:
  /// **'预计总费用'**
  String get totalEstimatedCost;

  /// No description provided for @foodAndDining.
  ///
  /// In zh, this message translates to:
  /// **'餐饮'**
  String get foodAndDining;

  /// No description provided for @activities.
  ///
  /// In zh, this message translates to:
  /// **'活动'**
  String get activities;

  /// No description provided for @estimatedCost.
  ///
  /// In zh, this message translates to:
  /// **'预计费用'**
  String get estimatedCost;

  /// No description provided for @localTransport.
  ///
  /// In zh, this message translates to:
  /// **'本地交通'**
  String get localTransport;

  /// No description provided for @pricePerNight.
  ///
  /// In zh, this message translates to:
  /// **'每晚价格'**
  String get pricePerNight;

  /// No description provided for @bookingTips.
  ///
  /// In zh, this message translates to:
  /// **'预订建议'**
  String get bookingTips;

  /// No description provided for @dayNumber.
  ///
  /// In zh, this message translates to:
  /// **'第 {number} 天'**
  String dayNumber(int number);

  /// No description provided for @asyncWithMap.
  ///
  /// In zh, this message translates to:
  /// **'地图功能即将推出！'**
  String get asyncWithMap;

  /// No description provided for @planSaved.
  ///
  /// In zh, this message translates to:
  /// **'计划已保存到您的个人资料！'**
  String get planSaved;

  /// No description provided for @sharingPlan.
  ///
  /// In zh, this message translates to:
  /// **'正在分享您的旅行计划...'**
  String get sharingPlan;

  /// No description provided for @noCitiesYet.
  ///
  /// In zh, this message translates to:
  /// **'暂无城市'**
  String get noCitiesYet;

  /// No description provided for @browseCities.
  ///
  /// In zh, this message translates to:
  /// **'浏览城市群'**
  String get browseCities;

  /// No description provided for @info.
  ///
  /// In zh, this message translates to:
  /// **'信息'**
  String get info;

  /// No description provided for @download.
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get download;

  /// No description provided for @currencyUSD.
  ///
  /// In zh, this message translates to:
  /// **'美元'**
  String get currencyUSD;

  /// No description provided for @currencyEUR.
  ///
  /// In zh, this message translates to:
  /// **'欧元'**
  String get currencyEUR;

  /// No description provided for @currencyGBP.
  ///
  /// In zh, this message translates to:
  /// **'英镑'**
  String get currencyGBP;

  /// No description provided for @currencyJPY.
  ///
  /// In zh, this message translates to:
  /// **'日元'**
  String get currencyJPY;

  /// No description provided for @currencyCNY.
  ///
  /// In zh, this message translates to:
  /// **'人民币'**
  String get currencyCNY;

  /// No description provided for @currencyTHB.
  ///
  /// In zh, this message translates to:
  /// **'泰铢'**
  String get currencyTHB;

  /// No description provided for @currencySGD.
  ///
  /// In zh, this message translates to:
  /// **'新加坡元'**
  String get currencySGD;

  /// No description provided for @currencyAUD.
  ///
  /// In zh, this message translates to:
  /// **'澳元'**
  String get currencyAUD;

  /// No description provided for @currencyCAD.
  ///
  /// In zh, this message translates to:
  /// **'加元'**
  String get currencyCAD;

  /// No description provided for @currencyINR.
  ///
  /// In zh, this message translates to:
  /// **'印度卢比'**
  String get currencyINR;

  /// No description provided for @currencyKRW.
  ///
  /// In zh, this message translates to:
  /// **'韩元'**
  String get currencyKRW;

  /// No description provided for @currencyMYR.
  ///
  /// In zh, this message translates to:
  /// **'马来西亚林吉特'**
  String get currencyMYR;

  /// No description provided for @currencyVND.
  ///
  /// In zh, this message translates to:
  /// **'越南盾'**
  String get currencyVND;

  /// No description provided for @currencyIDR.
  ///
  /// In zh, this message translates to:
  /// **'印尼盾'**
  String get currencyIDR;

  /// No description provided for @currencyPHP.
  ///
  /// In zh, this message translates to:
  /// **'菲律宾比索'**
  String get currencyPHP;

  /// No description provided for @livingTravelingWorld.
  ///
  /// In zh, this message translates to:
  /// **'在世界各地生活和旅行'**
  String get livingTravelingWorld;

  /// No description provided for @attendMeetupsInCities.
  ///
  /// In zh, this message translates to:
  /// **'在100多个城市参加363场聚会/年'**
  String get attendMeetupsInCities;

  /// No description provided for @keepTrackTravels.
  ///
  /// In zh, this message translates to:
  /// **'记录您的旅行轨迹，记住去过的地方'**
  String get keepTrackTravels;

  /// No description provided for @joinCommunityChat.
  ///
  /// In zh, this message translates to:
  /// **'加入社区聊天，在旅途中找到您的社区'**
  String get joinCommunityChat;

  /// No description provided for @viewAllCities.
  ///
  /// In zh, this message translates to:
  /// **'查看所有城市'**
  String get viewAllCities;

  /// No description provided for @perMonth.
  ///
  /// In zh, this message translates to:
  /// **'每月'**
  String get perMonth;

  /// No description provided for @minimumInternetSpeed.
  ///
  /// In zh, this message translates to:
  /// **'最低网速'**
  String get minimumInternetSpeed;

  /// No description provided for @minimumOverallRating.
  ///
  /// In zh, this message translates to:
  /// **'最低综合评分'**
  String get minimumOverallRating;

  /// No description provided for @maximumAirQualityIndex.
  ///
  /// In zh, this message translates to:
  /// **'最高空气质量指数'**
  String get maximumAirQualityIndex;

  /// No description provided for @unhealthyForSensitive.
  ///
  /// In zh, this message translates to:
  /// **'对敏感人群不健康'**
  String get unhealthyForSensitive;

  /// No description provided for @unhealthy.
  ///
  /// In zh, this message translates to:
  /// **'不健康'**
  String get unhealthy;

  /// No description provided for @veryUnhealthy.
  ///
  /// In zh, this message translates to:
  /// **'非常不健康'**
  String get veryUnhealthy;

  /// No description provided for @hazardous.
  ///
  /// In zh, this message translates to:
  /// **'有害'**
  String get hazardous;

  /// No description provided for @showResults.
  ///
  /// In zh, this message translates to:
  /// **'显示 {count} 个结果'**
  String showResults(int count);

  /// No description provided for @showCities.
  ///
  /// In zh, this message translates to:
  /// **'显示 {count} 个城市'**
  String showCities(int count);

  /// No description provided for @noResultsFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到结果'**
  String get noResultsFound;

  /// No description provided for @adjustFilters.
  ///
  /// In zh, this message translates to:
  /// **'尝试调整筛选条件'**
  String get adjustFilters;

  /// No description provided for @aqiUnhealthyForSensitive.
  ///
  /// In zh, this message translates to:
  /// **'轻度污染'**
  String get aqiUnhealthyForSensitive;

  /// No description provided for @pricing.
  ///
  /// In zh, this message translates to:
  /// **'价格'**
  String get pricing;

  /// No description provided for @hourly.
  ///
  /// In zh, this message translates to:
  /// **'每小时'**
  String get hourly;

  /// No description provided for @daily.
  ///
  /// In zh, this message translates to:
  /// **'每日'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In zh, this message translates to:
  /// **'每周'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In zh, this message translates to:
  /// **'每月'**
  String get monthly;

  /// No description provided for @specifications.
  ///
  /// In zh, this message translates to:
  /// **'规格'**
  String get specifications;

  /// No description provided for @wifiSpeed.
  ///
  /// In zh, this message translates to:
  /// **'WiFi速度'**
  String get wifiSpeed;

  /// No description provided for @capacity.
  ///
  /// In zh, this message translates to:
  /// **'容量'**
  String get capacity;

  /// No description provided for @people.
  ///
  /// In zh, this message translates to:
  /// **'人'**
  String get people;

  /// No description provided for @desks.
  ///
  /// In zh, this message translates to:
  /// **'工位'**
  String get desks;

  /// No description provided for @noiseLevel.
  ///
  /// In zh, this message translates to:
  /// **'噪音等级'**
  String get noiseLevel;

  /// No description provided for @contactInfo.
  ///
  /// In zh, this message translates to:
  /// **'联系方式'**
  String get contactInfo;

  /// No description provided for @nextMeetups.
  ///
  /// In zh, this message translates to:
  /// **'即将举行的聚会'**
  String get nextMeetups;

  /// No description provided for @upcomingEventsCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个即将举行的活动'**
  String upcomingEventsCount(Object count);

  /// No description provided for @viewAllMeetups.
  ///
  /// In zh, this message translates to:
  /// **'查看所有聚会'**
  String get viewAllMeetups;

  /// No description provided for @pleaseLoginToCreateMeetup.
  ///
  /// In zh, this message translates to:
  /// **'请登录以创建聚会'**
  String get pleaseLoginToCreateMeetup;

  /// No description provided for @transit.
  ///
  /// In zh, this message translates to:
  /// **'交通'**
  String get transit;

  /// No description provided for @recenter.
  ///
  /// In zh, this message translates to:
  /// **'回到中心'**
  String get recenter;

  /// No description provided for @startNavigation.
  ///
  /// In zh, this message translates to:
  /// **'开始导航'**
  String get startNavigation;

  /// No description provided for @noMapAppAvailable.
  ///
  /// In zh, this message translates to:
  /// **'未找到可用的地图应用'**
  String get noMapAppAvailable;

  /// No description provided for @selectMapApp.
  ///
  /// In zh, this message translates to:
  /// **'选择地图应用'**
  String get selectMapApp;

  /// No description provided for @selectMapSource.
  ///
  /// In zh, this message translates to:
  /// **'选择地图源'**
  String get selectMapSource;

  /// 切换地图源成功提示
  ///
  /// In zh, this message translates to:
  /// **'已切换到 {mapSource}'**
  String switchedToMapSource(String mapSource);

  /// 距离某地点
  ///
  /// In zh, this message translates to:
  /// **'距离 {placeName}'**
  String distanceFrom(String placeName);

  /// No description provided for @viewOnMap.
  ///
  /// In zh, this message translates to:
  /// **'在地图上查看'**
  String get viewOnMap;

  /// No description provided for @tapMarkersTip.
  ///
  /// In zh, this message translates to:
  /// **'点击地图上的标记可以查看更多周边设施'**
  String get tapMarkersTip;

  /// No description provided for @mapboxTokenWarning.
  ///
  /// In zh, this message translates to:
  /// **'Mapbox 需要 API Token。当前使用演示 Token，可能有使用限制。'**
  String get mapboxTokenWarning;

  /// 米单位
  ///
  /// In zh, this message translates to:
  /// **'{count}米'**
  String meters(String count);

  /// 公里单位
  ///
  /// In zh, this message translates to:
  /// **'{count}公里'**
  String kilometers(String count);

  /// No description provided for @addCoworkingSpace.
  ///
  /// In zh, this message translates to:
  /// **'添加共享办公空间'**
  String get addCoworkingSpace;

  /// No description provided for @basicInformation.
  ///
  /// In zh, this message translates to:
  /// **'基本信息'**
  String get basicInformation;

  /// No description provided for @spaceNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：WeWork 时代广场'**
  String get spaceNameHint;

  /// No description provided for @descriptionHint.
  ///
  /// In zh, this message translates to:
  /// **'描述共享办公空间...'**
  String get descriptionHint;

  /// No description provided for @addressHint.
  ///
  /// In zh, this message translates to:
  /// **'百老汇大道 1460 号'**
  String get addressHint;

  /// No description provided for @cityHint.
  ///
  /// In zh, this message translates to:
  /// **'纽约'**
  String get cityHint;

  /// No description provided for @countryHint.
  ///
  /// In zh, this message translates to:
  /// **'美国'**
  String get countryHint;

  /// No description provided for @pickLocationOnMap.
  ///
  /// In zh, this message translates to:
  /// **'在地图上选择位置'**
  String get pickLocationOnMap;

  /// No description provided for @locationCoordinates.
  ///
  /// In zh, this message translates to:
  /// **'{lat}, {lon}'**
  String locationCoordinates(String lat, String lon);

  /// No description provided for @contactInformation.
  ///
  /// In zh, this message translates to:
  /// **'联系信息'**
  String get contactInformation;

  /// No description provided for @phoneHint.
  ///
  /// In zh, this message translates to:
  /// **'+86 138 0000 0000'**
  String get phoneHint;

  /// No description provided for @emailHint.
  ///
  /// In zh, this message translates to:
  /// **'contact@example.com'**
  String get emailHint;

  /// No description provided for @websiteHint.
  ///
  /// In zh, this message translates to:
  /// **'https://example.com'**
  String get websiteHint;

  /// No description provided for @hourlyRate.
  ///
  /// In zh, this message translates to:
  /// **'时租'**
  String get hourlyRate;

  /// No description provided for @hourlyRateHint.
  ///
  /// In zh, this message translates to:
  /// **'10'**
  String get hourlyRateHint;

  /// No description provided for @dailyRate.
  ///
  /// In zh, this message translates to:
  /// **'日租'**
  String get dailyRate;

  /// No description provided for @dailyRateHint.
  ///
  /// In zh, this message translates to:
  /// **'50'**
  String get dailyRateHint;

  /// No description provided for @weeklyRate.
  ///
  /// In zh, this message translates to:
  /// **'周租'**
  String get weeklyRate;

  /// No description provided for @weeklyRateHint.
  ///
  /// In zh, this message translates to:
  /// **'200'**
  String get weeklyRateHint;

  /// No description provided for @monthlyRateHint.
  ///
  /// In zh, this message translates to:
  /// **'500'**
  String get monthlyRateHint;

  /// No description provided for @trialDuration.
  ///
  /// In zh, this message translates to:
  /// **'试用时长'**
  String get trialDuration;

  /// No description provided for @trialDurationHint.
  ///
  /// In zh, this message translates to:
  /// **'1天、1周等'**
  String get trialDurationHint;

  /// No description provided for @wifiSpeedHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：100 Mbps'**
  String get wifiSpeedHint;

  /// No description provided for @capacityHint.
  ///
  /// In zh, this message translates to:
  /// **'50'**
  String get capacityHint;

  /// No description provided for @numberOfDesks.
  ///
  /// In zh, this message translates to:
  /// **'桌位数量'**
  String get numberOfDesks;

  /// No description provided for @numberOfDesksHint.
  ///
  /// In zh, this message translates to:
  /// **'30'**
  String get numberOfDesksHint;

  /// No description provided for @meetingRoomsHint.
  ///
  /// In zh, this message translates to:
  /// **'5'**
  String get meetingRoomsHint;

  /// No description provided for @noiseLevelQuiet.
  ///
  /// In zh, this message translates to:
  /// **'安静'**
  String get noiseLevelQuiet;

  /// No description provided for @noiseLevelModerate.
  ///
  /// In zh, this message translates to:
  /// **'适中'**
  String get noiseLevelModerate;

  /// No description provided for @noiseLevelLoud.
  ///
  /// In zh, this message translates to:
  /// **'嘈杂'**
  String get noiseLevelLoud;

  /// No description provided for @spaceType.
  ///
  /// In zh, this message translates to:
  /// **'空间类型'**
  String get spaceType;

  /// No description provided for @spaceTypeOpen.
  ///
  /// In zh, this message translates to:
  /// **'开放式'**
  String get spaceTypeOpen;

  /// No description provided for @spaceTypePrivate.
  ///
  /// In zh, this message translates to:
  /// **'私密'**
  String get spaceTypePrivate;

  /// No description provided for @spaceTypeMixed.
  ///
  /// In zh, this message translates to:
  /// **'混合式'**
  String get spaceTypeMixed;

  /// No description provided for @naturalLight.
  ///
  /// In zh, this message translates to:
  /// **'自然光'**
  String get naturalLight;

  /// No description provided for @freeCoffee.
  ///
  /// In zh, this message translates to:
  /// **'免费咖啡'**
  String get freeCoffee;

  /// No description provided for @phoneBooth.
  ///
  /// In zh, this message translates to:
  /// **'电话亭'**
  String get phoneBooth;

  /// No description provided for @locker.
  ///
  /// In zh, this message translates to:
  /// **'储物柜'**
  String get locker;

  /// No description provided for @twentyFourSevenAccess.
  ///
  /// In zh, this message translates to:
  /// **'24/7 全天候'**
  String get twentyFourSevenAccess;

  /// No description provided for @airConditioning.
  ///
  /// In zh, this message translates to:
  /// **'空调'**
  String get airConditioning;

  /// No description provided for @standingDesk.
  ///
  /// In zh, this message translates to:
  /// **'升降桌'**
  String get standingDesk;

  /// No description provided for @shower.
  ///
  /// In zh, this message translates to:
  /// **'淋浴'**
  String get shower;

  /// No description provided for @bikeStorage.
  ///
  /// In zh, this message translates to:
  /// **'自行车存放'**
  String get bikeStorage;

  /// No description provided for @eventSpace.
  ///
  /// In zh, this message translates to:
  /// **'活动空间'**
  String get eventSpace;

  /// No description provided for @petFriendly.
  ///
  /// In zh, this message translates to:
  /// **'宠物友好'**
  String get petFriendly;

  /// No description provided for @addCoverPhoto.
  ///
  /// In zh, this message translates to:
  /// **'添加封面照片'**
  String get addCoverPhoto;

  /// No description provided for @tapToChoosePhoto.
  ///
  /// In zh, this message translates to:
  /// **'点击从相册或相机选择'**
  String get tapToChoosePhoto;

  /// No description provided for @chooseImageSource.
  ///
  /// In zh, this message translates to:
  /// **'选择图片来源'**
  String get chooseImageSource;

  /// No description provided for @photoLibrary.
  ///
  /// In zh, this message translates to:
  /// **'相册'**
  String get photoLibrary;

  /// No description provided for @submitCoworkingSpace.
  ///
  /// In zh, this message translates to:
  /// **'提交共享办公空间'**
  String get submitCoworkingSpace;

  /// No description provided for @thisFieldIsRequired.
  ///
  /// In zh, this message translates to:
  /// **'此字段为必填项'**
  String get thisFieldIsRequired;

  /// 选择图片失败提示
  ///
  /// In zh, this message translates to:
  /// **'选择图片失败：{error}'**
  String failedToPickImage(String error);

  /// No description provided for @coworkingSubmittedSuccess.
  ///
  /// In zh, this message translates to:
  /// **'共享办公空间提交成功！'**
  String get coworkingSubmittedSuccess;

  /// 提交失败提示
  ///
  /// In zh, this message translates to:
  /// **'提交共享办公空间失败：{error}'**
  String failedToSubmitCoworking(String error);

  /// No description provided for @meetupTitle.
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get meetupTitle;

  /// No description provided for @enterMeetupTitle.
  ///
  /// In zh, this message translates to:
  /// **'输入聚会标题'**
  String get enterMeetupTitle;

  /// No description provided for @meetupTypeHint.
  ///
  /// In zh, this message translates to:
  /// **'选择聚会类型'**
  String get meetupTypeHint;

  /// No description provided for @pleaseEnterType.
  ///
  /// In zh, this message translates to:
  /// **'请输入类型'**
  String get pleaseEnterType;

  /// No description provided for @selectCountry.
  ///
  /// In zh, this message translates to:
  /// **'选择国家'**
  String get selectCountry;

  /// No description provided for @enterVenue.
  ///
  /// In zh, this message translates to:
  /// **'输入场地或从地图选择'**
  String get enterVenue;

  /// No description provided for @pleaseEnterVenue.
  ///
  /// In zh, this message translates to:
  /// **'请输入场地'**
  String get pleaseEnterVenue;

  /// No description provided for @maxAttendees.
  ///
  /// In zh, this message translates to:
  /// **'最大参与人数'**
  String get maxAttendees;

  /// No description provided for @enterMeetupDescription.
  ///
  /// In zh, this message translates to:
  /// **'输入聚会描述'**
  String get enterMeetupDescription;

  /// No description provided for @venuePhotos.
  ///
  /// In zh, this message translates to:
  /// **'场地照片'**
  String get venuePhotos;

  /// 添加场地照片计数
  ///
  /// In zh, this message translates to:
  /// **'添加聚会场地照片（{count}/10）'**
  String addVenuePhotosCount(int count);

  /// No description provided for @coverPhoto.
  ///
  /// In zh, this message translates to:
  /// **'封面'**
  String get coverPhoto;

  /// No description provided for @addVenuePhotos.
  ///
  /// In zh, this message translates to:
  /// **'添加场地照片'**
  String get addVenuePhotos;

  /// No description provided for @tapToSelectPhoto.
  ///
  /// In zh, this message translates to:
  /// **'点击从相册或相机选择'**
  String get tapToSelectPhoto;

  /// 选择多张照片计数
  ///
  /// In zh, this message translates to:
  /// **'选择多张照片（{count}/10）'**
  String selectMultiplePhotos(int count);

  /// No description provided for @useCameraToTakePhoto.
  ///
  /// In zh, this message translates to:
  /// **'使用相机拍摄新照片'**
  String get useCameraToTakePhoto;

  /// No description provided for @maximumImagesAllowed.
  ///
  /// In zh, this message translates to:
  /// **'最多允许 10 张图片'**
  String get maximumImagesAllowed;

  /// No description provided for @notice.
  ///
  /// In zh, this message translates to:
  /// **'提示'**
  String get notice;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In zh, this message translates to:
  /// **'请填写所有必填字段'**
  String get pleaseFillAllFields;

  /// No description provided for @meetupCreatedSuccess.
  ///
  /// In zh, this message translates to:
  /// **'聚会创建成功！'**
  String get meetupCreatedSuccess;

  /// No description provided for @addToCalendar.
  ///
  /// In zh, this message translates to:
  /// **'添加到日历？'**
  String get addToCalendar;

  /// No description provided for @addToCalendarMessage.
  ///
  /// In zh, this message translates to:
  /// **'是否要将此聚会添加到系统日历？'**
  String get addToCalendarMessage;

  /// No description provided for @notNow.
  ///
  /// In zh, this message translates to:
  /// **'暂不'**
  String get notNow;

  /// No description provided for @addToCalendarButton.
  ///
  /// In zh, this message translates to:
  /// **'添加到日历'**
  String get addToCalendarButton;

  /// No description provided for @eventAddedToCalendar.
  ///
  /// In zh, this message translates to:
  /// **'事件已添加到您的日历！'**
  String get eventAddedToCalendar;

  /// 添加事件失败提示
  ///
  /// In zh, this message translates to:
  /// **'添加事件到日历失败：{error}'**
  String failedToAddEvent(String error);

  /// No description provided for @calendarPermissionDenied.
  ///
  /// In zh, this message translates to:
  /// **'日历权限被拒绝，请在设置中开启。'**
  String get calendarPermissionDenied;

  /// No description provided for @noCalendarAvailable.
  ///
  /// In zh, this message translates to:
  /// **'未找到可写入的日历。'**
  String get noCalendarAvailable;

  /// No description provided for @cityChats.
  ///
  /// In zh, this message translates to:
  /// **'城市聊天'**
  String get cityChats;

  /// No description provided for @onlineMembers.
  ///
  /// In zh, this message translates to:
  /// **'在线成员'**
  String get onlineMembers;

  /// No description provided for @justNow.
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get justNow;

  /// No description provided for @photoVideo.
  ///
  /// In zh, this message translates to:
  /// **'照片和视频'**
  String get photoVideo;

  /// No description provided for @document.
  ///
  /// In zh, this message translates to:
  /// **'文档'**
  String get document;

  /// No description provided for @minutesAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count}分钟前'**
  String minutesAgo(String count);

  /// No description provided for @hoursAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count}小时前'**
  String hoursAgo(String count);

  /// No description provided for @lastSeen.
  ///
  /// In zh, this message translates to:
  /// **'最后在线 {time}'**
  String lastSeen(String time);

  /// No description provided for @sendAttachment.
  ///
  /// In zh, this message translates to:
  /// **'发送附件'**
  String get sendAttachment;

  /// No description provided for @sharePhotosAndVideos.
  ///
  /// In zh, this message translates to:
  /// **'分享照片和视频'**
  String get sharePhotosAndVideos;

  /// No description provided for @shareYourLocation.
  ///
  /// In zh, this message translates to:
  /// **'分享你的位置'**
  String get shareYourLocation;

  /// No description provided for @shareFilesAndDocuments.
  ///
  /// In zh, this message translates to:
  /// **'分享文件和文档'**
  String get shareFilesAndDocuments;

  /// No description provided for @shareContactInformation.
  ///
  /// In zh, this message translates to:
  /// **'分享联系信息'**
  String get shareContactInformation;

  /// No description provided for @imageUploadComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'图片上传功能即将推出！'**
  String get imageUploadComingSoon;

  /// No description provided for @locationSharingComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'位置分享功能即将推出！'**
  String get locationSharingComingSoon;

  /// No description provided for @documentUploadComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'文档上传功能即将推出！'**
  String get documentUploadComingSoon;

  /// No description provided for @contactSharingComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'联系人分享功能即将推出！'**
  String get contactSharingComingSoon;

  /// No description provided for @innovationDescription.
  ///
  /// In zh, this message translates to:
  /// **'探索创新想法，寻找合作伙伴'**
  String get innovationDescription;

  /// No description provided for @elevatorPitch.
  ///
  /// In zh, this message translates to:
  /// **'一句话定位'**
  String get elevatorPitch;

  /// No description provided for @problem.
  ///
  /// In zh, this message translates to:
  /// **'要解决的问题'**
  String get problem;

  /// No description provided for @solution.
  ///
  /// In zh, this message translates to:
  /// **'解决方案'**
  String get solution;

  /// No description provided for @targetAudience.
  ///
  /// In zh, this message translates to:
  /// **'目标用户'**
  String get targetAudience;

  /// No description provided for @productType.
  ///
  /// In zh, this message translates to:
  /// **'产品形态'**
  String get productType;

  /// No description provided for @keyFeatures.
  ///
  /// In zh, this message translates to:
  /// **'核心功能'**
  String get keyFeatures;

  /// No description provided for @competitiveAdvantage.
  ///
  /// In zh, this message translates to:
  /// **'竞争优势'**
  String get competitiveAdvantage;

  /// No description provided for @businessModel.
  ///
  /// In zh, this message translates to:
  /// **'商业模式'**
  String get businessModel;

  /// No description provided for @marketOpportunity.
  ///
  /// In zh, this message translates to:
  /// **'市场潜力'**
  String get marketOpportunity;

  /// No description provided for @currentStatus.
  ///
  /// In zh, this message translates to:
  /// **'当前进展'**
  String get currentStatus;

  /// No description provided for @team.
  ///
  /// In zh, this message translates to:
  /// **'团队介绍'**
  String get team;

  /// No description provided for @ask.
  ///
  /// In zh, this message translates to:
  /// **'所需支持'**
  String get ask;

  /// No description provided for @createdAt.
  ///
  /// In zh, this message translates to:
  /// **'创建于'**
  String get createdAt;

  /// No description provided for @createMyInnovation.
  ///
  /// In zh, this message translates to:
  /// **'创建我的创意项目'**
  String get createMyInnovation;

  /// No description provided for @exploreInnovations.
  ///
  /// In zh, this message translates to:
  /// **'探索创意项目'**
  String get exploreInnovations;

  /// No description provided for @contactCreator.
  ///
  /// In zh, this message translates to:
  /// **'联系作者'**
  String get contactCreator;

  /// No description provided for @createInnovationProject.
  ///
  /// In zh, this message translates to:
  /// **'创建创意项目'**
  String get createInnovationProject;

  /// No description provided for @shareYourInnovation.
  ///
  /// In zh, this message translates to:
  /// **'分享你的创意项目,找到志同道合的伙伴和投资人'**
  String get shareYourInnovation;

  /// No description provided for @projectName.
  ///
  /// In zh, this message translates to:
  /// **'项目名称'**
  String get projectName;

  /// No description provided for @projectNameHint.
  ///
  /// In zh, this message translates to:
  /// **'为你的项目起一个响亮的名字'**
  String get projectNameHint;

  /// No description provided for @pleaseEnterProjectName.
  ///
  /// In zh, this message translates to:
  /// **'请输入项目名称'**
  String get pleaseEnterProjectName;

  /// No description provided for @elevatorPitchHint.
  ///
  /// In zh, this message translates to:
  /// **'用一句话描述你的项目'**
  String get elevatorPitchHint;

  /// No description provided for @pleaseEnterElevatorPitch.
  ///
  /// In zh, this message translates to:
  /// **'请输入项目定位'**
  String get pleaseEnterElevatorPitch;

  /// No description provided for @projectCover.
  ///
  /// In zh, this message translates to:
  /// **'项目封面'**
  String get projectCover;

  /// No description provided for @clickToSelectCover.
  ///
  /// In zh, this message translates to:
  /// **'点击选择项目封面图片'**
  String get clickToSelectCover;

  /// No description provided for @recommendedSize.
  ///
  /// In zh, this message translates to:
  /// **'建议尺寸: 1920x1080'**
  String get recommendedSize;

  /// No description provided for @problemAndSolution.
  ///
  /// In zh, this message translates to:
  /// **'问题与解决方案'**
  String get problemAndSolution;

  /// No description provided for @problemHint.
  ///
  /// In zh, this message translates to:
  /// **'你想解决什么问题?这个问题为什么重要?'**
  String get problemHint;

  /// No description provided for @pleaseDescribeProblem.
  ///
  /// In zh, this message translates to:
  /// **'请描述要解决的问题'**
  String get pleaseDescribeProblem;

  /// No description provided for @solutionHint.
  ///
  /// In zh, this message translates to:
  /// **'你的解决方案是什么?如何解决这个问题?'**
  String get solutionHint;

  /// No description provided for @pleaseDescribeSolution.
  ///
  /// In zh, this message translates to:
  /// **'请描述解决方案'**
  String get pleaseDescribeSolution;

  /// No description provided for @marketPositioning.
  ///
  /// In zh, this message translates to:
  /// **'市场定位'**
  String get marketPositioning;

  /// No description provided for @targetAudienceHint.
  ///
  /// In zh, this message translates to:
  /// **'你的目标用户是谁?'**
  String get targetAudienceHint;

  /// No description provided for @pleaseDescribeTargetAudience.
  ///
  /// In zh, this message translates to:
  /// **'请描述目标用户'**
  String get pleaseDescribeTargetAudience;

  /// No description provided for @productTypeHint.
  ///
  /// In zh, this message translates to:
  /// **'例如: 移动应用、网站、硬件设备等'**
  String get productTypeHint;

  /// No description provided for @keyFeaturesHint.
  ///
  /// In zh, this message translates to:
  /// **'核心功能,用逗号分隔\n例如: AI问答, 学习计划, 进度追踪'**
  String get keyFeaturesHint;

  /// No description provided for @pleaseEnterKeyFeatures.
  ///
  /// In zh, this message translates to:
  /// **'请输入核心功能'**
  String get pleaseEnterKeyFeatures;

  /// No description provided for @competitionAndBusiness.
  ///
  /// In zh, this message translates to:
  /// **'竞争与商业'**
  String get competitionAndBusiness;

  /// No description provided for @competitiveAdvantageHint.
  ///
  /// In zh, this message translates to:
  /// **'相比竞品,你的优势是什么?'**
  String get competitiveAdvantageHint;

  /// No description provided for @businessModelHint.
  ///
  /// In zh, this message translates to:
  /// **'你的盈利模式是什么?'**
  String get businessModelHint;

  /// No description provided for @marketOpportunityHint.
  ///
  /// In zh, this message translates to:
  /// **'市场规模和增长潜力如何?'**
  String get marketOpportunityHint;

  /// No description provided for @progressAndNeeds.
  ///
  /// In zh, this message translates to:
  /// **'进展与需求'**
  String get progressAndNeeds;

  /// No description provided for @currentStatusHint.
  ///
  /// In zh, this message translates to:
  /// **'目前的开发进度和已完成的工作'**
  String get currentStatusHint;

  /// No description provided for @pleaseDescribeCurrentStatus.
  ///
  /// In zh, this message translates to:
  /// **'请描述当前进展'**
  String get pleaseDescribeCurrentStatus;

  /// No description provided for @askHint.
  ///
  /// In zh, this message translates to:
  /// **'你需要什么帮助?例如: 技术合伙人、种子资金、市场推广等'**
  String get askHint;

  /// No description provided for @pleaseSpecifyNeeds.
  ///
  /// In zh, this message translates to:
  /// **'请说明所需支持'**
  String get pleaseSpecifyNeeds;

  /// No description provided for @teamInformation.
  ///
  /// In zh, this message translates to:
  /// **'团队信息'**
  String get teamInformation;

  /// No description provided for @teamMembers.
  ///
  /// In zh, this message translates to:
  /// **'团队成员'**
  String get teamMembers;

  /// No description provided for @teamMembersHint.
  ///
  /// In zh, this message translates to:
  /// **'介绍你的团队成员\n格式: 姓名 - 职位 - 简介\n多个成员用分号分隔'**
  String get teamMembersHint;

  /// No description provided for @publishProject.
  ///
  /// In zh, this message translates to:
  /// **'发布创意项目'**
  String get publishProject;

  /// No description provided for @projectCreatedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'创意项目创建成功!'**
  String get projectCreatedSuccessfully;

  /// No description provided for @creationFailed.
  ///
  /// In zh, this message translates to:
  /// **'创建失败'**
  String get creationFailed;

  /// No description provided for @imageSelectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'选择图片失败'**
  String get imageSelectionFailed;

  /// No description provided for @call.
  ///
  /// In zh, this message translates to:
  /// **'拨打'**
  String get call;

  /// No description provided for @cannotMakeCall.
  ///
  /// In zh, this message translates to:
  /// **'无法拨打电话'**
  String get cannotMakeCall;

  /// No description provided for @noBadgesYet.
  ///
  /// In zh, this message translates to:
  /// **'还没有获得勋章'**
  String get noBadgesYet;

  /// No description provided for @noTravelHistoryYet.
  ///
  /// In zh, this message translates to:
  /// **'还没有旅行记录'**
  String get noTravelHistoryYet;

  /// No description provided for @viewAllTrips.
  ///
  /// In zh, this message translates to:
  /// **'查看所有旅行'**
  String get viewAllTrips;

  /// No description provided for @noMembersOnline.
  ///
  /// In zh, this message translates to:
  /// **'暂无在线成员'**
  String get noMembersOnline;

  /// No description provided for @communityCostSummary.
  ///
  /// In zh, this message translates to:
  /// **'社区费用汇总'**
  String get communityCostSummary;

  /// No description provided for @contributors.
  ///
  /// In zh, this message translates to:
  /// **'位贡献者'**
  String get contributors;

  /// No description provided for @averageCommunityCost.
  ///
  /// In zh, this message translates to:
  /// **'平均社区费用'**
  String get averageCommunityCost;

  /// No description provided for @basedOnRealExpenses.
  ///
  /// In zh, this message translates to:
  /// **'基于 {count} 条真实费用{plural}'**
  String basedOnRealExpenses(int count, String plural);

  /// No description provided for @activity.
  ///
  /// In zh, this message translates to:
  /// **'活动'**
  String get activity;

  /// No description provided for @saveChanges.
  ///
  /// In zh, this message translates to:
  /// **'保存更改'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In zh, this message translates to:
  /// **'资料更新成功'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @saved.
  ///
  /// In zh, this message translates to:
  /// **'已保存'**
  String get saved;

  /// No description provided for @enterYourName.
  ///
  /// In zh, this message translates to:
  /// **'请输入您的姓名'**
  String get enterYourName;

  /// No description provided for @bio.
  ///
  /// In zh, this message translates to:
  /// **'个人简介'**
  String get bio;

  /// No description provided for @tellUsAboutYourself.
  ///
  /// In zh, this message translates to:
  /// **'介绍一下你自己...'**
  String get tellUsAboutYourself;

  /// No description provided for @noSkillsAddedYet.
  ///
  /// In zh, this message translates to:
  /// **'还没有添加技能'**
  String get noSkillsAddedYet;

  /// No description provided for @noInterestsAddedYet.
  ///
  /// In zh, this message translates to:
  /// **'还没有添加兴趣'**
  String get noInterestsAddedYet;

  /// No description provided for @enterInterest.
  ///
  /// In zh, this message translates to:
  /// **'输入兴趣'**
  String get enterInterest;

  /// No description provided for @notificationsPreference.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get notificationsPreference;

  /// No description provided for @receiveUpdatesAndAlerts.
  ///
  /// In zh, this message translates to:
  /// **'接收更新和提醒'**
  String get receiveUpdatesAndAlerts;

  /// No description provided for @travelHistoryVisible.
  ///
  /// In zh, this message translates to:
  /// **'旅行历史可见'**
  String get travelHistoryVisible;

  /// No description provided for @showTravelHistoryToOthers.
  ///
  /// In zh, this message translates to:
  /// **'向其他用户展示您的旅行历史'**
  String get showTravelHistoryToOthers;

  /// No description provided for @autoTravelDetection.
  ///
  /// In zh, this message translates to:
  /// **'自动旅行记录'**
  String get autoTravelDetection;

  /// No description provided for @autoTravelDetectionDescription.
  ///
  /// In zh, this message translates to:
  /// **'自动检测并记录您的旅行足迹'**
  String get autoTravelDetectionDescription;

  /// No description provided for @publicProfile.
  ///
  /// In zh, this message translates to:
  /// **'公开资料'**
  String get publicProfile;

  /// No description provided for @makeProfileVisibleToEveryone.
  ///
  /// In zh, this message translates to:
  /// **'让所有人都能看到您的资料'**
  String get makeProfileVisibleToEveryone;

  /// No description provided for @celsius.
  ///
  /// In zh, this message translates to:
  /// **'摄氏度'**
  String get celsius;

  /// No description provided for @fahrenheit.
  ///
  /// In zh, this message translates to:
  /// **'华氏度'**
  String get fahrenheit;

  /// No description provided for @changePasswordComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'修改密码功能即将推出'**
  String get changePasswordComingSoon;

  /// No description provided for @privacySettingsComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'隐私设置功能即将推出'**
  String get privacySettingsComingSoon;

  /// No description provided for @deleteAccount.
  ///
  /// In zh, this message translates to:
  /// **'删除账户'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除您的账户吗？此操作无法撤销。'**
  String get deleteAccountConfirmation;

  /// No description provided for @accountDeletionCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消删除账户'**
  String get accountDeletionCancelled;

  /// No description provided for @membershipPlans.
  ///
  /// In zh, this message translates to:
  /// **'会员计划'**
  String get membershipPlans;

  /// No description provided for @currentPlan.
  ///
  /// In zh, this message translates to:
  /// **'当前：{planName}'**
  String currentPlan(String planName);

  /// No description provided for @daysRemaining.
  ///
  /// In zh, this message translates to:
  /// **'剩余 {days} 天'**
  String daysRemaining(int days);

  /// No description provided for @upgradeToUnlock.
  ///
  /// In zh, this message translates to:
  /// **'升级以解锁更多功能'**
  String get upgradeToUnlock;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In zh, this message translates to:
  /// **'选择支付方式'**
  String get selectPaymentMethod;

  /// No description provided for @upgradeTo.
  ///
  /// In zh, this message translates to:
  /// **'升级到 {planName} - ¥{price}'**
  String upgradeTo(String planName, String price);

  /// No description provided for @paypalPayment.
  ///
  /// In zh, this message translates to:
  /// **'PayPal'**
  String get paypalPayment;

  /// No description provided for @paypalDescription.
  ///
  /// In zh, this message translates to:
  /// **'快捷安全的国际支付'**
  String get paypalDescription;

  /// No description provided for @wechatPayment.
  ///
  /// In zh, this message translates to:
  /// **'微信支付'**
  String get wechatPayment;

  /// No description provided for @wechatDescription.
  ///
  /// In zh, this message translates to:
  /// **'使用微信支付'**
  String get wechatDescription;

  /// No description provided for @qqLogin.
  ///
  /// In zh, this message translates to:
  /// **'QQ登录'**
  String get qqLogin;

  /// No description provided for @qqDescription.
  ///
  /// In zh, this message translates to:
  /// **'使用 QQ 账号登录'**
  String get qqDescription;

  /// No description provided for @securePayment.
  ///
  /// In zh, this message translates to:
  /// **'安全支付'**
  String get securePayment;

  /// No description provided for @allPaymentsSecure.
  ///
  /// In zh, this message translates to:
  /// **'所有支付均安全处理，可随时取消。'**
  String get allPaymentsSecure;

  /// No description provided for @allPaymentsEncrypted.
  ///
  /// In zh, this message translates to:
  /// **'所有支付均安全加密'**
  String get allPaymentsEncrypted;

  /// No description provided for @unableToLoadPlans.
  ///
  /// In zh, this message translates to:
  /// **'无法加载会员计划'**
  String get unableToLoadPlans;

  /// No description provided for @checkNetworkConnection.
  ///
  /// In zh, this message translates to:
  /// **'请检查您的网络连接'**
  String get checkNetworkConnection;

  /// No description provided for @currentPlanLabel.
  ///
  /// In zh, this message translates to:
  /// **'当前计划'**
  String get currentPlanLabel;

  /// No description provided for @selectPlanLabel.
  ///
  /// In zh, this message translates to:
  /// **'选择计划'**
  String get selectPlanLabel;

  /// No description provided for @perYear.
  ///
  /// In zh, this message translates to:
  /// **'/年'**
  String get perYear;

  /// No description provided for @billingMonthly.
  ///
  /// In zh, this message translates to:
  /// **'月付'**
  String get billingMonthly;

  /// No description provided for @billingYearly.
  ///
  /// In zh, this message translates to:
  /// **'年付'**
  String get billingYearly;

  /// No description provided for @saveAmount.
  ///
  /// In zh, this message translates to:
  /// **'省 ¥{amount}'**
  String saveAmount(String amount);

  /// No description provided for @alreadyHavePlan.
  ///
  /// In zh, this message translates to:
  /// **'您已拥有此计划或更高级别的计划'**
  String get alreadyHavePlan;

  /// No description provided for @creatingPaypalOrder.
  ///
  /// In zh, this message translates to:
  /// **'正在创建 PayPal 订单...'**
  String get creatingPaypalOrder;

  /// No description provided for @creatingWechatOrder.
  ///
  /// In zh, this message translates to:
  /// **'正在创建微信支付订单...'**
  String get creatingWechatOrder;

  /// No description provided for @qqAuthInProgress.
  ///
  /// In zh, this message translates to:
  /// **'正在进行 QQ 授权...'**
  String get qqAuthInProgress;

  /// No description provided for @priceForPlan.
  ///
  /// In zh, this message translates to:
  /// **'\${price} - {planName}'**
  String priceForPlan(String price, String planName);

  /// No description provided for @cnyPriceForPlan.
  ///
  /// In zh, this message translates to:
  /// **'¥{price} - {planName}'**
  String cnyPriceForPlan(String price, String planName);

  /// No description provided for @paymentServiceNotAvailable.
  ///
  /// In zh, this message translates to:
  /// **'支付服务不可用'**
  String get paymentServiceNotAvailable;

  /// No description provided for @paymentError.
  ///
  /// In zh, this message translates to:
  /// **'支付错误：{error}'**
  String paymentError(String error);

  /// No description provided for @openingPaypal.
  ///
  /// In zh, this message translates to:
  /// **'正在打开 PayPal 支付...'**
  String get openingPaypal;

  /// No description provided for @failedToCreateOrder.
  ///
  /// In zh, this message translates to:
  /// **'创建支付订单失败'**
  String get failedToCreateOrder;

  /// No description provided for @wechatNotInstalled.
  ///
  /// In zh, this message translates to:
  /// **'请先安装微信客户端'**
  String get wechatNotInstalled;

  /// No description provided for @qqNotInstalled.
  ///
  /// In zh, this message translates to:
  /// **'请先安装 QQ 客户端'**
  String get qqNotInstalled;

  /// No description provided for @paymentSuccessful.
  ///
  /// In zh, this message translates to:
  /// **'支付成功！'**
  String get paymentSuccessful;

  /// No description provided for @wechatPayFailed.
  ///
  /// In zh, this message translates to:
  /// **'微信支付失败'**
  String get wechatPayFailed;

  /// No description provided for @qqLoginFailed.
  ///
  /// In zh, this message translates to:
  /// **'QQ 登录失败'**
  String get qqLoginFailed;

  /// No description provided for @wechatPayError.
  ///
  /// In zh, this message translates to:
  /// **'微信支付错误：{error}'**
  String wechatPayError(String error);

  /// No description provided for @qqError.
  ///
  /// In zh, this message translates to:
  /// **'QQ 错误：{error}'**
  String qqError(String error);

  /// No description provided for @travelDetected.
  ///
  /// In zh, this message translates to:
  /// **'发现新旅行'**
  String get travelDetected;

  /// No description provided for @saveTravelQuestion.
  ///
  /// In zh, this message translates to:
  /// **'要保存这次旅行吗？'**
  String get saveTravelQuestion;

  /// No description provided for @saveTravel.
  ///
  /// In zh, this message translates to:
  /// **'保存旅行'**
  String get saveTravel;

  /// No description provided for @ignore.
  ///
  /// In zh, this message translates to:
  /// **'忽略'**
  String get ignore;

  /// No description provided for @travelSaved.
  ///
  /// In zh, this message translates to:
  /// **'旅行已保存'**
  String get travelSaved;

  /// No description provided for @saveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败'**
  String get saveFailed;

  /// No description provided for @dismiss.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get dismiss;

  /// No description provided for @noPendingTrips.
  ///
  /// In zh, this message translates to:
  /// **'暂无待确认的旅行'**
  String get noPendingTrips;

  /// No description provided for @travelDetectedBanner.
  ///
  /// In zh, this message translates to:
  /// **'我们发现您最近去过 {city}'**
  String travelDetectedBanner(String city);

  /// No description provided for @tapToSave.
  ///
  /// In zh, this message translates to:
  /// **'点击保存这次旅行'**
  String get tapToSave;

  /// No description provided for @durationDays.
  ///
  /// In zh, this message translates to:
  /// **'{days} 天'**
  String durationDays(String days);

  /// No description provided for @distanceFromHome.
  ///
  /// In zh, this message translates to:
  /// **'距离常住地 {km} 公里'**
  String distanceFromHome(String km);

  /// No description provided for @pendingConfirmation.
  ///
  /// In zh, this message translates to:
  /// **'待确认'**
  String get pendingConfirmation;

  /// No description provided for @confirmedTrips.
  ///
  /// In zh, this message translates to:
  /// **'旅行记录'**
  String get confirmedTrips;

  /// No description provided for @homeLocation.
  ///
  /// In zh, this message translates to:
  /// **'常住地'**
  String get homeLocation;

  /// No description provided for @setHomeLocation.
  ///
  /// In zh, this message translates to:
  /// **'设置常住地'**
  String get setHomeLocation;

  /// No description provided for @homeLocationSet.
  ///
  /// In zh, this message translates to:
  /// **'常住地已设置'**
  String get homeLocationSet;

  /// No description provided for @setHomeFailed.
  ///
  /// In zh, this message translates to:
  /// **'设置常住地失败'**
  String get setHomeFailed;

  /// No description provided for @locationUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'无法获取位置信息'**
  String get locationUnavailable;

  /// No description provided for @autoDetectionOn.
  ///
  /// In zh, this message translates to:
  /// **'自动检测已开启'**
  String get autoDetectionOn;

  /// No description provided for @autoDetectionOff.
  ///
  /// In zh, this message translates to:
  /// **'自动检测已关闭'**
  String get autoDetectionOff;

  /// No description provided for @clearAllData.
  ///
  /// In zh, this message translates to:
  /// **'清除所有数据'**
  String get clearAllData;

  /// No description provided for @confirmClear.
  ///
  /// In zh, this message translates to:
  /// **'确认清除'**
  String get confirmClear;

  /// No description provided for @clearAllDataWarning.
  ///
  /// In zh, this message translates to:
  /// **'此操作将清除所有旅行检测数据，包括位置记录、停留点和旅行历史。此操作无法撤销。'**
  String get clearAllDataWarning;

  /// No description provided for @clear.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get clear;

  /// No description provided for @dataCleared.
  ///
  /// In zh, this message translates to:
  /// **'数据已清除'**
  String get dataCleared;

  /// No description provided for @noTravelHistory.
  ///
  /// In zh, this message translates to:
  /// **'暂无旅行记录'**
  String get noTravelHistory;

  /// No description provided for @travelHistoryEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'开启自动检测后，我们会自动识别您的旅行并提醒您保存'**
  String get travelHistoryEmptyHint;

  /// No description provided for @autoDetectionActive.
  ///
  /// In zh, this message translates to:
  /// **'自动检测已开启'**
  String get autoDetectionActive;

  /// No description provided for @enableAutoDetection.
  ///
  /// In zh, this message translates to:
  /// **'开启自动检测'**
  String get enableAutoDetection;

  /// No description provided for @confidence.
  ///
  /// In zh, this message translates to:
  /// **'置信度：{percent}%'**
  String confidence(String percent);

  /// No description provided for @synced.
  ///
  /// In zh, this message translates to:
  /// **'已同步'**
  String get synced;

  /// No description provided for @nights.
  ///
  /// In zh, this message translates to:
  /// **'晚'**
  String get nights;

  /// No description provided for @tip.
  ///
  /// In zh, this message translates to:
  /// **'提示'**
  String get tip;

  /// No description provided for @travelHistoryNoCityLink.
  ///
  /// In zh, this message translates to:
  /// **'此旅行记录暂无关联城市'**
  String get travelHistoryNoCityLink;

  /// No description provided for @syncCompleted.
  ///
  /// In zh, this message translates to:
  /// **'同步完成'**
  String get syncCompleted;

  /// No description provided for @syncFailed.
  ///
  /// In zh, this message translates to:
  /// **'同步失败'**
  String get syncFailed;

  /// No description provided for @addHotel.
  ///
  /// In zh, this message translates to:
  /// **'添加酒店'**
  String get addHotel;

  /// No description provided for @editHotel.
  ///
  /// In zh, this message translates to:
  /// **'编辑酒店'**
  String get editHotel;

  /// No description provided for @hotelName.
  ///
  /// In zh, this message translates to:
  /// **'酒店名称'**
  String get hotelName;

  /// No description provided for @hotelNameHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入酒店名称'**
  String get hotelNameHint;

  /// No description provided for @hotelDescription.
  ///
  /// In zh, this message translates to:
  /// **'描述'**
  String get hotelDescription;

  /// No description provided for @hotelDescriptionHint.
  ///
  /// In zh, this message translates to:
  /// **'为数字游民描述这家酒店'**
  String get hotelDescriptionHint;

  /// No description provided for @pricePerNightHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：50'**
  String get pricePerNightHint;

  /// No description provided for @longStayDiscount.
  ///
  /// In zh, this message translates to:
  /// **'长住优惠'**
  String get longStayDiscount;

  /// No description provided for @longStayDiscountHint.
  ///
  /// In zh, this message translates to:
  /// **'周/月住折扣百分比'**
  String get longStayDiscountHint;

  /// No description provided for @nomadFeatures.
  ///
  /// In zh, this message translates to:
  /// **'数字游民特性'**
  String get nomadFeatures;

  /// No description provided for @nomadFeaturesSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'对远程工作者重要的设施'**
  String get nomadFeaturesSubtitle;

  /// No description provided for @workDesk.
  ///
  /// In zh, this message translates to:
  /// **'工作桌'**
  String get workDesk;

  /// No description provided for @hasCoworkingSpace.
  ///
  /// In zh, this message translates to:
  /// **'有共享办公空间'**
  String get hasCoworkingSpace;

  /// No description provided for @laundry.
  ///
  /// In zh, this message translates to:
  /// **'洗衣'**
  String get laundry;

  /// No description provided for @pool.
  ///
  /// In zh, this message translates to:
  /// **'游泳池'**
  String get pool;

  /// No description provided for @twentyFourHourReception.
  ///
  /// In zh, this message translates to:
  /// **'24小时前台'**
  String get twentyFourHourReception;

  /// No description provided for @submitHotel.
  ///
  /// In zh, this message translates to:
  /// **'提交酒店'**
  String get submitHotel;

  /// No description provided for @hotelSubmittedSuccess.
  ///
  /// In zh, this message translates to:
  /// **'酒店提交成功！'**
  String get hotelSubmittedSuccess;

  /// No description provided for @failedToSubmitHotel.
  ///
  /// In zh, this message translates to:
  /// **'提交酒店失败'**
  String get failedToSubmitHotel;

  /// No description provided for @maxPhotosReached.
  ///
  /// In zh, this message translates to:
  /// **'最多允许 {max} 张照片'**
  String maxPhotosReached(int max);

  /// No description provided for @addFirstHotel.
  ///
  /// In zh, this message translates to:
  /// **'添加第一家酒店'**
  String get addFirstHotel;

  /// No description provided for @noTeamMembersAdded.
  ///
  /// In zh, this message translates to:
  /// **'暂无团队成员'**
  String get noTeamMembersAdded;

  /// No description provided for @addTeamMember.
  ///
  /// In zh, this message translates to:
  /// **'添加团队成员'**
  String get addTeamMember;

  /// No description provided for @editTeamMember.
  ///
  /// In zh, this message translates to:
  /// **'编辑团队成员'**
  String get editTeamMember;

  /// No description provided for @editProject.
  ///
  /// In zh, this message translates to:
  /// **'编辑项目'**
  String get editProject;

  /// No description provided for @enterMemberName.
  ///
  /// In zh, this message translates to:
  /// **'请输入成员姓名'**
  String get enterMemberName;

  /// No description provided for @enterMemberRole.
  ///
  /// In zh, this message translates to:
  /// **'请输入成员职位'**
  String get enterMemberRole;

  /// No description provided for @enterMemberDescription.
  ///
  /// In zh, this message translates to:
  /// **'请输入成员简介（可选）'**
  String get enterMemberDescription;

  /// No description provided for @markAsFounder.
  ///
  /// In zh, this message translates to:
  /// **'标记为创始人'**
  String get markAsFounder;

  /// No description provided for @pleaseEnterMemberName.
  ///
  /// In zh, this message translates to:
  /// **'请输入成员姓名'**
  String get pleaseEnterMemberName;

  /// No description provided for @pleaseEnterMemberRole.
  ///
  /// In zh, this message translates to:
  /// **'请输入成员职位'**
  String get pleaseEnterMemberRole;

  /// No description provided for @founder.
  ///
  /// In zh, this message translates to:
  /// **'创始人'**
  String get founder;

  /// No description provided for @role.
  ///
  /// In zh, this message translates to:
  /// **'职位'**
  String get role;

  /// No description provided for @searchAddress.
  ///
  /// In zh, this message translates to:
  /// **'搜索地址或地点'**
  String get searchAddress;

  /// No description provided for @eventInvitation.
  ///
  /// In zh, this message translates to:
  /// **'活动邀请'**
  String get eventInvitation;

  /// No description provided for @inviteYouToJoin.
  ///
  /// In zh, this message translates to:
  /// **'邀请你参加'**
  String get inviteYouToJoin;

  /// No description provided for @moderatorTransfer.
  ///
  /// In zh, this message translates to:
  /// **'版主转让'**
  String get moderatorTransfer;

  /// No description provided for @accept.
  ///
  /// In zh, this message translates to:
  /// **'接受'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In zh, this message translates to:
  /// **'拒绝'**
  String get decline;

  /// No description provided for @privacyPolicyIntro.
  ///
  /// In zh, this message translates to:
  /// **'欢迎使用行途（Go-Nomads）！为了为您提供更好的服务，我们需要您了解并同意以下隐私政策：'**
  String get privacyPolicyIntro;

  /// No description provided for @privacyDataCollection.
  ///
  /// In zh, this message translates to:
  /// **'数据收集'**
  String get privacyDataCollection;

  /// No description provided for @privacyDataCollectionDesc.
  ///
  /// In zh, this message translates to:
  /// **'我们会收集您的行为数据（如浏览记录、搜索偏好、功能使用频率等），以便优化产品体验和个性化推荐。'**
  String get privacyDataCollectionDesc;

  /// No description provided for @privacyLocationData.
  ///
  /// In zh, this message translates to:
  /// **'位置信息'**
  String get privacyLocationData;

  /// No description provided for @privacyLocationDataDesc.
  ///
  /// In zh, this message translates to:
  /// **'我们会收集您的位置数据，用于提供城市推荐、附近的共享办公空间和活动信息、以及旅行足迹记录等功能。'**
  String get privacyLocationDataDesc;

  /// No description provided for @privacyPersonalData.
  ///
  /// In zh, this message translates to:
  /// **'个人信息'**
  String get privacyPersonalData;

  /// No description provided for @privacyPersonalDataDesc.
  ///
  /// In zh, this message translates to:
  /// **'我们会收集您的基本个人信息（如昵称、头像、联系方式等），用于账号管理和社交功能。'**
  String get privacyPersonalDataDesc;

  /// No description provided for @privacyDataProtection.
  ///
  /// In zh, this message translates to:
  /// **'数据保护'**
  String get privacyDataProtection;

  /// No description provided for @privacyDataProtectionDesc.
  ///
  /// In zh, this message translates to:
  /// **'我们承诺采用行业标准的安全措施保护您的个人数据，不会将您的数据出售给第三方。您可以随时在“设置”中管理您的隐私偏好。'**
  String get privacyDataProtectionDesc;

  /// No description provided for @privacyPolicyNote.
  ///
  /// In zh, this message translates to:
  /// **'如果您不同意以上隐私政策，将无法继续使用本应用。您可以随时在设置中查看完整的隐私政策。'**
  String get privacyPolicyNote;

  /// No description provided for @agreeAndContinue.
  ///
  /// In zh, this message translates to:
  /// **'同意并继续'**
  String get agreeAndContinue;

  /// No description provided for @disagreeAndExit.
  ///
  /// In zh, this message translates to:
  /// **'不同意并退出'**
  String get disagreeAndExit;

  /// No description provided for @viewFullTerms.
  ///
  /// In zh, this message translates to:
  /// **'查看完整的'**
  String get viewFullTerms;

  /// No description provided for @thirdPartyServices.
  ///
  /// In zh, this message translates to:
  /// **'第三方服务'**
  String get thirdPartyServices;

  /// No description provided for @thirdPartyServicesDesc.
  ///
  /// In zh, this message translates to:
  /// **'为实现相关功能，本应用集成了以下第三方服务SDK：\n• 高德地图SDK — 地图显示和定位服务\n• 微信OpenSDK — 微信登录和分享\n• QQ 互联SDK — QQ 登录和分享\n• 腾讯云IM SDK — 即时通信服务\n• Google Location — 海外定位服务\n上述第三方SDK可能会按照其各自的隐私政策收集必要信息。'**
  String get thirdPartyServicesDesc;

  /// No description provided for @permissionUsage.
  ///
  /// In zh, this message translates to:
  /// **'权限使用说明'**
  String get permissionUsage;

  /// No description provided for @permissionUsageDesc.
  ///
  /// In zh, this message translates to:
  /// **'本应用使用以下权限：\n• 位置权限 — 城市推荐、附近活动、旅行足迹\n• 日历权限 — 将活动添加到日历\n• 通知权限 — 消息提醒和活动通知\n所有权限均在使用对应功能时才会申请，您可随时在系统设置中管理。'**
  String get permissionUsageDesc;

  /// No description provided for @privacyDeclineTitle.
  ///
  /// In zh, this message translates to:
  /// **'温馨提示'**
  String get privacyDeclineTitle;

  /// No description provided for @privacyDeclineMessage.
  ///
  /// In zh, this message translates to:
  /// **'如果您不同意隐私政策，将无法使用本应用的相关功能。\n\n我们非常重视您的隐私安全，收集的信息仅用于为您提供更好的服务。\n\n您确定不同意吗？'**
  String get privacyDeclineMessage;

  /// No description provided for @reconsider.
  ///
  /// In zh, this message translates to:
  /// **'再想想'**
  String get reconsider;

  /// No description provided for @confirmExit.
  ///
  /// In zh, this message translates to:
  /// **'确认退出'**
  String get confirmExit;

  /// No description provided for @reportSubmitted.
  ///
  /// In zh, this message translates to:
  /// **'举报已提交'**
  String get reportSubmitted;

  /// No description provided for @reportSubmittedDesc.
  ///
  /// In zh, this message translates to:
  /// **'感谢您的反馈，我们将尽快处理。'**
  String get reportSubmittedDesc;

  /// No description provided for @reportReasonSpam.
  ///
  /// In zh, this message translates to:
  /// **'垃圾信息/广告'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonHarassment.
  ///
  /// In zh, this message translates to:
  /// **'骚扰/欺凌'**
  String get reportReasonHarassment;

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In zh, this message translates to:
  /// **'不当内容'**
  String get reportReasonInappropriate;

  /// No description provided for @reportReasonFraud.
  ///
  /// In zh, this message translates to:
  /// **'欺诈/虚假信息'**
  String get reportReasonFraud;

  /// No description provided for @reportReasonViolence.
  ///
  /// In zh, this message translates to:
  /// **'暴力/危险行为'**
  String get reportReasonViolence;

  /// No description provided for @reportReasonOther.
  ///
  /// In zh, this message translates to:
  /// **'其他原因'**
  String get reportReasonOther;

  /// No description provided for @reportUser.
  ///
  /// In zh, this message translates to:
  /// **'举报用户'**
  String get reportUser;

  /// No description provided for @reportContent.
  ///
  /// In zh, this message translates to:
  /// **'举报内容'**
  String get reportContent;

  /// No description provided for @reportFailed.
  ///
  /// In zh, this message translates to:
  /// **'举报提交失败'**
  String get reportFailed;

  /// No description provided for @reportFailedDesc.
  ///
  /// In zh, this message translates to:
  /// **'网络异常，请稍后重试。'**
  String get reportFailedDesc;

  /// No description provided for @helpAndSupport.
  ///
  /// In zh, this message translates to:
  /// **'帮助与客服'**
  String get helpAndSupport;

  /// No description provided for @helpAndSupportDesc.
  ///
  /// In zh, this message translates to:
  /// **'如有任何问题或建议，请随时联系我们'**
  String get helpAndSupportDesc;

  /// No description provided for @customerServiceEmail.
  ///
  /// In zh, this message translates to:
  /// **'客服邮箱'**
  String get customerServiceEmail;

  /// No description provided for @customerServiceEmailDesc.
  ///
  /// In zh, this message translates to:
  /// **'我们将在 1-2 个工作日内回复您的邮件'**
  String get customerServiceEmailDesc;

  /// No description provided for @emailCopied.
  ///
  /// In zh, this message translates to:
  /// **'邮箱地址已复制'**
  String get emailCopied;

  /// No description provided for @sendEmail.
  ///
  /// In zh, this message translates to:
  /// **'发送邮件'**
  String get sendEmail;

  /// No description provided for @commonQuestions.
  ///
  /// In zh, this message translates to:
  /// **'常见问题'**
  String get commonQuestions;

  /// No description provided for @faqPayment.
  ///
  /// In zh, this message translates to:
  /// **'付费相关问题'**
  String get faqPayment;

  /// No description provided for @faqPaymentAnswer.
  ///
  /// In zh, this message translates to:
  /// **'如您在付费过程中遇到问题，如支付失败、订单异常等，请通过客服邮箱联系我们，并附上您的订单信息，我们会尽快为您处理。'**
  String get faqPaymentAnswer;

  /// No description provided for @faqAccount.
  ///
  /// In zh, this message translates to:
  /// **'账号相关问题'**
  String get faqAccount;

  /// No description provided for @faqAccountAnswer.
  ///
  /// In zh, this message translates to:
  /// **'如遇到账号登录、密码找回、账号注销等问题，请通过客服邮箱联系我们，并提供您的注册信息以便核实。'**
  String get faqAccountAnswer;

  /// No description provided for @faqFeedback.
  ///
  /// In zh, this message translates to:
  /// **'功能建议与反馈'**
  String get faqFeedback;

  /// No description provided for @faqFeedbackAnswer.
  ///
  /// In zh, this message translates to:
  /// **'我们非常重视用户的意见与建议，如您有任何产品改进建议，欢迎通过客服邮箱告诉我们。'**
  String get faqFeedbackAnswer;

  /// No description provided for @serviceHours.
  ///
  /// In zh, this message translates to:
  /// **'服务时间'**
  String get serviceHours;

  /// No description provided for @serviceHoursDesc.
  ///
  /// In zh, this message translates to:
  /// **'工作日 9:00 - 18:00（北京时间）'**
  String get serviceHoursDesc;

  /// No description provided for @aiChatServiceUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'AI 服务暂时不可用，请稍后重试'**
  String get aiChatServiceUnavailable;

  /// No description provided for @aiChatResponseError.
  ///
  /// In zh, this message translates to:
  /// **'AI 返回错误'**
  String get aiChatResponseError;

  /// No description provided for @aiChatFailed.
  ///
  /// In zh, this message translates to:
  /// **'AI Chat 失败'**
  String get aiChatFailed;

  /// No description provided for @aiChatDefaultConversationTitle.
  ///
  /// In zh, this message translates to:
  /// **'Nomads AI 助手'**
  String get aiChatDefaultConversationTitle;

  /// No description provided for @aiChatSystemPrompt.
  ///
  /// In zh, this message translates to:
  /// **'你是 Go Nomads 的 AI 助手，请为数字游民提供简洁且可执行的旅行建议。'**
  String get aiChatSystemPrompt;

  /// No description provided for @aiChatCreateConversationFailed.
  ///
  /// In zh, this message translates to:
  /// **'暂时无法创建 AI 对话'**
  String get aiChatCreateConversationFailed;

  /// No description provided for @aiChatLoadHistoryFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载历史对话失败'**
  String get aiChatLoadHistoryFailed;

  /// No description provided for @aiChatSwitchBlockedWhileStreaming.
  ///
  /// In zh, this message translates to:
  /// **'正在生成回复，请稍后再切换对话'**
  String get aiChatSwitchBlockedWhileStreaming;

  /// No description provided for @aiChatSwitchConversationFailed.
  ///
  /// In zh, this message translates to:
  /// **'切换对话失败，请稍后重试'**
  String get aiChatSwitchConversationFailed;

  /// No description provided for @aiChatThinking.
  ///
  /// In zh, this message translates to:
  /// **'AI 正在思考...'**
  String get aiChatThinking;

  /// No description provided for @aiChatRequestTimeout.
  ///
  /// In zh, this message translates to:
  /// **'请求超时，请稍后重试'**
  String get aiChatRequestTimeout;

  /// No description provided for @aiChatReplyUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'暂时无法获取 AI 回复，请稍后重试'**
  String get aiChatReplyUnavailable;

  /// No description provided for @aiChatSendFailed.
  ///
  /// In zh, this message translates to:
  /// **'AI Chat 发送失败'**
  String get aiChatSendFailed;

  /// No description provided for @aiChatNoReplyYet.
  ///
  /// In zh, this message translates to:
  /// **'暂时未收到 AI 回复，请稍后重试'**
  String get aiChatNoReplyYet;

  /// No description provided for @aiChatUntitledConversation.
  ///
  /// In zh, this message translates to:
  /// **'未命名对话'**
  String get aiChatUntitledConversation;

  /// No description provided for @manageReviewsDeleteConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get manageReviewsDeleteConfirmTitle;

  /// No description provided for @manageReviewsDeleteConfirmMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除这条评论吗？此操作可以恢复。'**
  String get manageReviewsDeleteConfirmMessage;

  /// No description provided for @manageReviewsPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'{cityName} - 评论管理'**
  String manageReviewsPageTitle(Object cityName);

  /// No description provided for @manageReviewsNoData.
  ///
  /// In zh, this message translates to:
  /// **'暂无评论数据'**
  String get manageReviewsNoData;

  /// No description provided for @manageReviewsAddFirstReview.
  ///
  /// In zh, this message translates to:
  /// **'添加第一条评论'**
  String get manageReviewsAddFirstReview;

  /// No description provided for @manageReviewsLoadedAll.
  ///
  /// In zh, this message translates to:
  /// **'已加载全部 {count} 条评论'**
  String manageReviewsLoadedAll(int count);

  /// No description provided for @travelPlanUnableToLoad.
  ///
  /// In zh, this message translates to:
  /// **'无法加载旅行计划'**
  String get travelPlanUnableToLoad;

  /// No description provided for @travelPlanLoadFailedWithError.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String travelPlanLoadFailedWithError(Object error);

  /// No description provided for @travelPlanGenerateErrorWithError.
  ///
  /// In zh, this message translates to:
  /// **'错误: {error}'**
  String travelPlanGenerateErrorWithError(Object error);

  /// No description provided for @travelPlanGeneratedSuccess.
  ///
  /// In zh, this message translates to:
  /// **'旅行计划生成成功！'**
  String get travelPlanGeneratedSuccess;

  /// No description provided for @travelPlanGenerateFailedWithError.
  ///
  /// In zh, this message translates to:
  /// **'生成失败: {error}'**
  String travelPlanGenerateFailedWithError(Object error);

  /// No description provided for @travelPlanNotReadyWarning.
  ///
  /// In zh, this message translates to:
  /// **'计划还未生成完成'**
  String get travelPlanNotReadyWarning;

  /// No description provided for @aiChatCodeCopied.
  ///
  /// In zh, this message translates to:
  /// **'代码已复制'**
  String get aiChatCodeCopied;

  /// No description provided for @aiChatCodeCopiedToClipboard.
  ///
  /// In zh, this message translates to:
  /// **'代码已复制到剪贴板'**
  String get aiChatCodeCopiedToClipboard;

  /// No description provided for @aiChatInputHint.
  ///
  /// In zh, this message translates to:
  /// **'问路、问签证、生成行程，都可以直接开聊…'**
  String get aiChatInputHint;

  /// No description provided for @aiChatEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'还没有对话，向 AI 提问试试'**
  String get aiChatEmptyHint;

  /// No description provided for @aiChatStartConversation.
  ///
  /// In zh, this message translates to:
  /// **'开始对话'**
  String get aiChatStartConversation;

  /// No description provided for @prosConsAddPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'{cityName} - 添加乐趣'**
  String prosConsAddPageTitle(Object cityName);

  /// No description provided for @prosConsAddProsHint.
  ///
  /// In zh, this message translates to:
  /// **'分享这个城市的优点...'**
  String get prosConsAddProsHint;

  /// No description provided for @prosConsAddConsHint.
  ///
  /// In zh, this message translates to:
  /// **'分享这个城市的挑战...'**
  String get prosConsAddConsHint;

  /// No description provided for @manageProsConsPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'{cityName} - 优缺点管理'**
  String manageProsConsPageTitle(Object cityName);

  /// No description provided for @cityDetailGeneratingNearbyCitiesTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 正在生成附近城市'**
  String get cityDetailGeneratingNearbyCitiesTitle;

  /// No description provided for @cityDetailNearbyCitiesGeneratedSuccess.
  ///
  /// In zh, this message translates to:
  /// **'附近城市生成成功!'**
  String get cityDetailNearbyCitiesGeneratedSuccess;

  /// No description provided for @guideTabAiGenerate.
  ///
  /// In zh, this message translates to:
  /// **'AI 生成'**
  String get guideTabAiGenerate;

  /// No description provided for @guideTabAiGenerateGuide.
  ///
  /// In zh, this message translates to:
  /// **'AI 生成指南'**
  String get guideTabAiGenerateGuide;

  /// No description provided for @registerCodeSentToEmail.
  ///
  /// In zh, this message translates to:
  /// **'验证码已发送到邮箱，请查收'**
  String get registerCodeSentToEmail;

  /// No description provided for @registerSendCodeFailedRetry.
  ///
  /// In zh, this message translates to:
  /// **'发送验证码失败，请稍后重试'**
  String get registerSendCodeFailedRetry;

  /// No description provided for @registerFailedTitle.
  ///
  /// In zh, this message translates to:
  /// **'注册失败'**
  String get registerFailedTitle;

  /// No description provided for @registerFailedCheckInput.
  ///
  /// In zh, this message translates to:
  /// **'注册失败,请检查输入信息'**
  String get registerFailedCheckInput;

  /// No description provided for @registerFailedProcessError.
  ///
  /// In zh, this message translates to:
  /// **'注册过程中发生错误，请稍后重试'**
  String get registerFailedProcessError;

  /// No description provided for @conversationDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除会话'**
  String get conversationDeleteTitle;

  /// No description provided for @conversationDeleteMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除这个会话吗？聊天记录将被清除。'**
  String get conversationDeleteMessage;

  /// No description provided for @coworkingDetailUserComments.
  ///
  /// In zh, this message translates to:
  /// **'用户评论'**
  String get coworkingDetailUserComments;

  /// No description provided for @coworkingDetailPostComment.
  ///
  /// In zh, this message translates to:
  /// **'发表评论'**
  String get coworkingDetailPostComment;

  /// No description provided for @coworkingDetailViewMoreComments.
  ///
  /// In zh, this message translates to:
  /// **'查看更多评论'**
  String get coworkingDetailViewMoreComments;

  /// No description provided for @coworkingDetailNoComments.
  ///
  /// In zh, this message translates to:
  /// **'暂无评论'**
  String get coworkingDetailNoComments;

  /// No description provided for @coworkingDetailBeFirstCommenter.
  ///
  /// In zh, this message translates to:
  /// **'成为第一个发表评论的人'**
  String get coworkingDetailBeFirstCommenter;

  /// No description provided for @editSkillsTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑技能'**
  String get editSkillsTitle;

  /// No description provided for @editSkillsAddCustomSkill.
  ///
  /// In zh, this message translates to:
  /// **'添加自定义技能'**
  String get editSkillsAddCustomSkill;

  /// No description provided for @editInterestsTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑兴趣'**
  String get editInterestsTitle;

  /// No description provided for @editInterestsAddCustomInterest.
  ///
  /// In zh, this message translates to:
  /// **'添加自定义兴趣'**
  String get editInterestsAddCustomInterest;

  /// No description provided for @prosConsNoProsTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有优点'**
  String get prosConsNoProsTitle;

  /// No description provided for @prosConsNoProsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'分享你在这座城市的美好体验'**
  String get prosConsNoProsSubtitle;

  /// No description provided for @prosConsAddPros.
  ///
  /// In zh, this message translates to:
  /// **'添加优点'**
  String get prosConsAddPros;

  /// No description provided for @prosConsNoConsTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有挑战'**
  String get prosConsNoConsTitle;

  /// No description provided for @prosConsNoConsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'分享你遇到的困难和需要改进的地方'**
  String get prosConsNoConsSubtitle;

  /// No description provided for @prosConsAddCons.
  ///
  /// In zh, this message translates to:
  /// **'添加挑战'**
  String get prosConsAddCons;

  /// No description provided for @profilePleaseLoginToView.
  ///
  /// In zh, this message translates to:
  /// **'请先登录以查看你的资料'**
  String get profilePleaseLoginToView;

  /// No description provided for @profilePleaseLoginAgain.
  ///
  /// In zh, this message translates to:
  /// **'请重新登录'**
  String get profilePleaseLoginAgain;

  /// No description provided for @profileLogoutSuccessMessage.
  ///
  /// In zh, this message translates to:
  /// **'你已成功退出登录'**
  String get profileLogoutSuccessMessage;

  /// No description provided for @profileLogoutSuccessTitle.
  ///
  /// In zh, this message translates to:
  /// **'退出成功'**
  String get profileLogoutSuccessTitle;

  /// No description provided for @profileLogoutErrorMessage.
  ///
  /// In zh, this message translates to:
  /// **'退出登录时发生错误'**
  String get profileLogoutErrorMessage;

  /// No description provided for @coworkingDetailDeleteConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除确认'**
  String get coworkingDetailDeleteConfirmTitle;

  /// No description provided for @coworkingDetailDeleteConfirmMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除 \"{name}\" 吗？此操作不可撤销。'**
  String coworkingDetailDeleteConfirmMessage(Object name);

  /// No description provided for @loginPhoneAction.
  ///
  /// In zh, this message translates to:
  /// **'点击登录/注册'**
  String get loginPhoneAction;

  /// No description provided for @amapGlobalMapOnlyMobile.
  ///
  /// In zh, this message translates to:
  /// **'地图仅支持 iOS 和 Android 平台'**
  String get amapGlobalMapOnlyMobile;

  /// No description provided for @amapGlobalTitle.
  ///
  /// In zh, this message translates to:
  /// **'全球游民'**
  String get amapGlobalTitle;

  /// No description provided for @amapGlobalByRegion.
  ///
  /// In zh, this message translates to:
  /// **'按地区'**
  String get amapGlobalByRegion;

  /// No description provided for @neighborhoodsDiscoverNearbyHint.
  ///
  /// In zh, this message translates to:
  /// **'发现 100 公里内的 4 个相邻城市'**
  String get neighborhoodsDiscoverNearbyHint;

  /// No description provided for @neighborhoodsGenerateNearbyCities.
  ///
  /// In zh, this message translates to:
  /// **'AI 生成附近城市'**
  String get neighborhoodsGenerateNearbyCities;

  /// No description provided for @neighborhoodsLoadedFromBackend.
  ///
  /// In zh, this message translates to:
  /// **'☁️ 从后端加载'**
  String get neighborhoodsLoadedFromBackend;

  /// No description provided for @aiChatHistoryTooltip.
  ///
  /// In zh, this message translates to:
  /// **'历史对话'**
  String get aiChatHistoryTooltip;

  /// No description provided for @aiChatLoadingHistoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'加载历史对话...'**
  String get aiChatLoadingHistoryTitle;

  /// No description provided for @aiChatNoHistoryStartNew.
  ///
  /// In zh, this message translates to:
  /// **'暂无历史对话，直接开始新对话吧'**
  String get aiChatNoHistoryStartNew;

  /// No description provided for @aiChatHistoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'历史对话'**
  String get aiChatHistoryTitle;

  /// No description provided for @manageCostPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'{cityName} - 费用管理'**
  String manageCostPageTitle(Object cityName);

  /// No description provided for @manageCostNoData.
  ///
  /// In zh, this message translates to:
  /// **'暂无费用数据'**
  String get manageCostNoData;

  /// No description provided for @manageCostAddFirst.
  ///
  /// In zh, this message translates to:
  /// **'添加第一条费用'**
  String get manageCostAddFirst;

  /// No description provided for @skillsInterestsTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择技能与兴趣'**
  String get skillsInterestsTitle;

  /// No description provided for @skillsInterestsSelected.
  ///
  /// In zh, this message translates to:
  /// **'已选择'**
  String get skillsInterestsSelected;

  /// No description provided for @skillsInterestsSummary.
  ///
  /// In zh, this message translates to:
  /// **'技能 {skillsCount}/10  ·  兴趣 {interestsCount}/15'**
  String skillsInterestsSummary(int skillsCount, int interestsCount);

  /// No description provided for @roomTypePreviewToast.
  ///
  /// In zh, this message translates to:
  /// **'房型: {name}'**
  String roomTypePreviewToast(Object name);

  /// No description provided for @roomTypeBookingToast.
  ///
  /// In zh, this message translates to:
  /// **'预订 {name}'**
  String roomTypeBookingToast(Object name);

  /// No description provided for @applyModeratorSubmitSuccess.
  ///
  /// In zh, this message translates to:
  /// **'申请已提交，请等待管理员审核'**
  String get applyModeratorSubmitSuccess;

  /// No description provided for @applyModeratorReasonHint.
  ///
  /// In zh, this message translates to:
  /// **'请说明您申请成为版主的原因，以及您能为社区带来什么...'**
  String get applyModeratorReasonHint;

  /// No description provided for @addCoworkingImageCount.
  ///
  /// In zh, this message translates to:
  /// **'{count}/{max}'**
  String addCoworkingImageCount(int count, int max);

  /// No description provided for @addCoworkingMaxImages.
  ///
  /// In zh, this message translates to:
  /// **'最多上传 {max} 张图片'**
  String addCoworkingMaxImages(int max);

  /// No description provided for @loginFacebookComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'Facebook 登录即将推出'**
  String get loginFacebookComingSoon;

  /// No description provided for @assignModeratorPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'{cityName} - 指定版主'**
  String assignModeratorPageTitle(Object cityName);

  /// No description provided for @homeAiCopilotTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 智能助手'**
  String get homeAiCopilotTitle;

  /// No description provided for @homeAiCopilotBeta.
  ///
  /// In zh, this message translates to:
  /// **'测试版'**
  String get homeAiCopilotBeta;

  /// No description provided for @homeAiCopilotDescription.
  ///
  /// In zh, this message translates to:
  /// **'智能问路 · 行程规划 · 旅行攻略'**
  String get homeAiCopilotDescription;

  /// No description provided for @moderatorAssigned.
  ///
  /// In zh, this message translates to:
  /// **'已指定版主'**
  String get moderatorAssigned;

  /// No description provided for @moderatorPending.
  ///
  /// In zh, this message translates to:
  /// **'待指定版主'**
  String get moderatorPending;

  /// No description provided for @searchResultsFor.
  ///
  /// In zh, this message translates to:
  /// **'搜索结果：'**
  String get searchResultsFor;

  /// No description provided for @citiesFoundCount.
  ///
  /// In zh, this message translates to:
  /// **'找到 {count} 个城市'**
  String citiesFoundCount(int count);

  /// No description provided for @tryDifferentKeyword.
  ///
  /// In zh, this message translates to:
  /// **'请尝试使用其他关键词搜索'**
  String get tryDifferentKeyword;

  /// No description provided for @startExploringCities.
  ///
  /// In zh, this message translates to:
  /// **'添加第一个城市，开始探索之旅'**
  String get startExploringCities;

  /// No description provided for @meetupLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'活动加载失败'**
  String get meetupLoadFailed;

  /// No description provided for @meetupLoadFailedDescription.
  ///
  /// In zh, this message translates to:
  /// **'请检查网络连接后重试'**
  String get meetupLoadFailedDescription;

  /// No description provided for @noMeetupsDescription.
  ///
  /// In zh, this message translates to:
  /// **'成为第一个创建活动的人\n与同城数字游民一起社交吧'**
  String get noMeetupsDescription;

  /// No description provided for @imageLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'图片加载失败'**
  String get imageLoadFailed;

  /// No description provided for @meetupStatusCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get meetupStatusCancelled;

  /// No description provided for @meetupEventCancelled.
  ///
  /// In zh, this message translates to:
  /// **'活动已取消'**
  String get meetupEventCancelled;

  /// No description provided for @meetupStatusEnded.
  ///
  /// In zh, this message translates to:
  /// **'已结束'**
  String get meetupStatusEnded;

  /// No description provided for @meetupEventEnded.
  ///
  /// In zh, this message translates to:
  /// **'活动已结束'**
  String get meetupEventEnded;

  /// No description provided for @leave.
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get leave;

  /// No description provided for @pleaseLoginBeforeAction.
  ///
  /// In zh, this message translates to:
  /// **'请先登录后再{action}'**
  String pleaseLoginBeforeAction(String action);

  /// No description provided for @loginCheckFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法检查登录状态'**
  String get loginCheckFailed;

  /// No description provided for @meetupUpdatedSuccess.
  ///
  /// In zh, this message translates to:
  /// **'活动更新成功！'**
  String get meetupUpdatedSuccess;

  /// No description provided for @meetupCreateFailed.
  ///
  /// In zh, this message translates to:
  /// **'创建活动失败：{error}'**
  String meetupCreateFailed(String error);

  /// No description provided for @meetupUpdateFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新活动失败：{error}'**
  String meetupUpdateFailed(String error);

  /// No description provided for @rsvpSuccess.
  ///
  /// In zh, this message translates to:
  /// **'报名成功！'**
  String get rsvpSuccess;

  /// No description provided for @rsvpFailed.
  ///
  /// In zh, this message translates to:
  /// **'报名失败：{error}'**
  String rsvpFailed(String error);

  /// No description provided for @rsvpCancelledSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已取消报名'**
  String get rsvpCancelledSuccess;

  /// No description provided for @rsvpCancelFailed.
  ///
  /// In zh, this message translates to:
  /// **'取消报名失败：{error}'**
  String rsvpCancelFailed(String error);

  /// No description provided for @meetupCancelledSuccess.
  ///
  /// In zh, this message translates to:
  /// **'活动已取消'**
  String get meetupCancelledSuccess;

  /// No description provided for @meetupCancelFailed.
  ///
  /// In zh, this message translates to:
  /// **'取消活动失败：{error}'**
  String meetupCancelFailed(String error);

  /// No description provided for @inviteSentSuccess.
  ///
  /// In zh, this message translates to:
  /// **'邀请已发送'**
  String get inviteSentSuccess;

  /// No description provided for @spotsLeftCount.
  ///
  /// In zh, this message translates to:
  /// **'剩余 {count}'**
  String spotsLeftCount(int count);

  /// No description provided for @emailLogin.
  ///
  /// In zh, this message translates to:
  /// **'邮箱登录'**
  String get emailLogin;

  /// No description provided for @phoneLogin.
  ///
  /// In zh, this message translates to:
  /// **'手机登录'**
  String get phoneLogin;

  /// No description provided for @clickToLoginOrRegister.
  ///
  /// In zh, this message translates to:
  /// **'点击登录/注册'**
  String get clickToLoginOrRegister;

  /// No description provided for @wechat.
  ///
  /// In zh, this message translates to:
  /// **'微信'**
  String get wechat;

  /// No description provided for @letsGo.
  ///
  /// In zh, this message translates to:
  /// **'Let\'s Go'**
  String get letsGo;

  /// No description provided for @joinNomadsCount.
  ///
  /// In zh, this message translates to:
  /// **'加入 38,000+ 游牧者'**
  String get joinNomadsCount;

  /// No description provided for @livingAndWorkingWorldwide.
  ///
  /// In zh, this message translates to:
  /// **'在全球各地生活和工作'**
  String get livingAndWorkingWorldwide;

  /// No description provided for @meetupsPerYear.
  ///
  /// In zh, this message translates to:
  /// **'363 场聚会/年'**
  String get meetupsPerYear;

  /// No description provided for @messagesCount.
  ///
  /// In zh, this message translates to:
  /// **'15k+ 消息'**
  String get messagesCount;

  /// No description provided for @citiesCount.
  ///
  /// In zh, this message translates to:
  /// **'100+ 城市'**
  String get citiesCount;

  /// No description provided for @verificationCodeRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入验证码'**
  String get verificationCodeRequired;

  /// No description provided for @verificationCodeLength.
  ///
  /// In zh, this message translates to:
  /// **'验证码必须为6位'**
  String get verificationCodeLength;

  /// No description provided for @sendFailed.
  ///
  /// In zh, this message translates to:
  /// **'发送失败'**
  String get sendFailed;

  /// No description provided for @sampleDataPreview.
  ///
  /// In zh, this message translates to:
  /// **'示例数据预览'**
  String get sampleDataPreview;

  /// No description provided for @sampleDataPreviewDescription.
  ///
  /// In zh, this message translates to:
  /// **'您当前查看的是示例用户资料。登录后可查看您的真实个人信息。'**
  String get sampleDataPreviewDescription;

  /// No description provided for @goToLogin.
  ///
  /// In zh, this message translates to:
  /// **'去登录'**
  String get goToLogin;

  /// No description provided for @userCancelledAuth.
  ///
  /// In zh, this message translates to:
  /// **'用户取消授权'**
  String get userCancelledAuth;

  /// No description provided for @wechatNotDetected.
  ///
  /// In zh, this message translates to:
  /// **'未检测到微信'**
  String get wechatNotDetected;

  /// No description provided for @qqNotDetected.
  ///
  /// In zh, this message translates to:
  /// **'未检测到 QQ'**
  String get qqNotDetected;

  /// No description provided for @socialLoginFailed.
  ///
  /// In zh, this message translates to:
  /// **'社交登录失败: {error}'**
  String socialLoginFailed(String error);

  /// No description provided for @userProfileUpdated.
  ///
  /// In zh, this message translates to:
  /// **'用户资料已更新'**
  String get userProfileUpdated;

  /// No description provided for @allNotifications.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get allNotifications;

  /// No description provided for @unread.
  ///
  /// In zh, this message translates to:
  /// **'未读'**
  String get unread;

  /// No description provided for @read.
  ///
  /// In zh, this message translates to:
  /// **'已读'**
  String get read;

  /// No description provided for @markAllAsRead.
  ///
  /// In zh, this message translates to:
  /// **'全部标记为已读'**
  String get markAllAsRead;

  /// No description provided for @noNotifications.
  ///
  /// In zh, this message translates to:
  /// **'暂无通知'**
  String get noNotifications;

  /// No description provided for @noReadNotifications.
  ///
  /// In zh, this message translates to:
  /// **'暂无已读通知'**
  String get noReadNotifications;

  /// No description provided for @noUnreadNotifications.
  ///
  /// In zh, this message translates to:
  /// **'暂无未读通知'**
  String get noUnreadNotifications;

  /// No description provided for @cancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get cancelled;

  /// No description provided for @cancelMeetup.
  ///
  /// In zh, this message translates to:
  /// **'取消活动'**
  String get cancelMeetup;

  /// No description provided for @eventCancelled.
  ///
  /// In zh, this message translates to:
  /// **'活动已取消'**
  String get eventCancelled;

  /// No description provided for @eventEnded.
  ///
  /// In zh, this message translates to:
  /// **'活动已结束'**
  String get eventEnded;

  /// No description provided for @cancelledTab.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get cancelledTab;

  /// No description provided for @joinMeetupsHint.
  ///
  /// In zh, this message translates to:
  /// **'参加一些活动来认识新朋友吧！'**
  String get joinMeetupsHint;

  /// No description provided for @noPastMeetupsHint.
  ///
  /// In zh, this message translates to:
  /// **'还没有参加过任何活动'**
  String get noPastMeetupsHint;

  /// No description provided for @noCancelledMeetups.
  ///
  /// In zh, this message translates to:
  /// **'暂无已取消的活动'**
  String get noCancelledMeetups;

  /// No description provided for @cancelledMeetupHistory.
  ///
  /// In zh, this message translates to:
  /// **'这里会显示你取消参与的活动记录'**
  String get cancelledMeetupHistory;

  /// No description provided for @noUpcomingMeetupsHint.
  ///
  /// In zh, this message translates to:
  /// **'目前没有即将举行的活动'**
  String get noUpcomingMeetupsHint;

  /// No description provided for @attendeesSpotsInfo.
  ///
  /// In zh, this message translates to:
  /// **'{current}/{max} 参与者 · 剩余 {remaining} 个名额'**
  String attendeesSpotsInfo(String current, String max, String remaining);

  /// No description provided for @nomadMeetupShare.
  ///
  /// In zh, this message translates to:
  /// **'{title} - 数字游民聚会'**
  String nomadMeetupShare(String title);

  /// No description provided for @shareTime.
  ///
  /// In zh, this message translates to:
  /// **'📅 时间: {time}'**
  String shareTime(String time);

  /// No description provided for @shareVenue.
  ///
  /// In zh, this message translates to:
  /// **'📍 地点: {venue}'**
  String shareVenue(String venue);

  /// No description provided for @shareOrganizer.
  ///
  /// In zh, this message translates to:
  /// **'👥 组织者: {name}'**
  String shareOrganizer(String name);

  /// No description provided for @chatRoom.
  ///
  /// In zh, this message translates to:
  /// **'聊天室'**
  String get chatRoom;

  /// No description provided for @connecting.
  ///
  /// In zh, this message translates to:
  /// **'正在连接'**
  String get connecting;

  /// No description provided for @noChatRooms.
  ///
  /// In zh, this message translates to:
  /// **'暂无聊天室'**
  String get noChatRooms;

  /// No description provided for @onlineCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人在线'**
  String onlineCount(String count);

  /// No description provided for @startChatting.
  ///
  /// In zh, this message translates to:
  /// **'开始聊天吧'**
  String get startChatting;

  /// No description provided for @replyTo.
  ///
  /// In zh, this message translates to:
  /// **'回复 {name}'**
  String replyTo(String name);

  /// No description provided for @groupMembers.
  ///
  /// In zh, this message translates to:
  /// **'群成员 ({count})'**
  String groupMembers(String count);

  /// No description provided for @noMembers.
  ///
  /// In zh, this message translates to:
  /// **'暂无成员'**
  String get noMembers;

  /// No description provided for @owner.
  ///
  /// In zh, this message translates to:
  /// **'群主'**
  String get owner;

  /// No description provided for @admin.
  ///
  /// In zh, this message translates to:
  /// **'管理员'**
  String get admin;

  /// No description provided for @uploadFailed.
  ///
  /// In zh, this message translates to:
  /// **'上传失败'**
  String get uploadFailed;

  /// No description provided for @storageServiceError.
  ///
  /// In zh, this message translates to:
  /// **'存储服务错误'**
  String get storageServiceError;

  /// No description provided for @pleaseReLogin.
  ///
  /// In zh, this message translates to:
  /// **'请重新登录'**
  String get pleaseReLogin;

  /// No description provided for @pleaseRestartApp.
  ///
  /// In zh, this message translates to:
  /// **'请重启应用'**
  String get pleaseRestartApp;

  /// No description provided for @uploadFailedRetry.
  ///
  /// In zh, this message translates to:
  /// **'上传失败，请重试'**
  String get uploadFailedRetry;

  /// No description provided for @weekDaySun.
  ///
  /// In zh, this message translates to:
  /// **'周日'**
  String get weekDaySun;

  /// No description provided for @weekDayMon.
  ///
  /// In zh, this message translates to:
  /// **'周一'**
  String get weekDayMon;

  /// No description provided for @weekDayTue.
  ///
  /// In zh, this message translates to:
  /// **'周二'**
  String get weekDayTue;

  /// No description provided for @weekDayWed.
  ///
  /// In zh, this message translates to:
  /// **'周三'**
  String get weekDayWed;

  /// No description provided for @weekDayThu.
  ///
  /// In zh, this message translates to:
  /// **'周四'**
  String get weekDayThu;

  /// No description provided for @weekDayFri.
  ///
  /// In zh, this message translates to:
  /// **'周五'**
  String get weekDayFri;

  /// No description provided for @weekDaySat.
  ///
  /// In zh, this message translates to:
  /// **'周六'**
  String get weekDaySat;

  /// No description provided for @unknownFile.
  ///
  /// In zh, this message translates to:
  /// **'未知文件'**
  String get unknownFile;

  /// No description provided for @searchButton.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get searchButton;

  /// No description provided for @searchFoundMessages.
  ///
  /// In zh, this message translates to:
  /// **'找到 {count} 条包含\"{keyword}\"的消息'**
  String searchFoundMessages(String count, String keyword);

  /// No description provided for @searching.
  ///
  /// In zh, this message translates to:
  /// **'搜索中...'**
  String get searching;

  /// No description provided for @searchChatHistory.
  ///
  /// In zh, this message translates to:
  /// **'输入关键词搜索聊天记录'**
  String get searchChatHistory;

  /// No description provided for @searchNotFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到包含\"{keyword}\"的消息'**
  String searchNotFound(String keyword);

  /// No description provided for @tryOtherKeywords.
  ///
  /// In zh, this message translates to:
  /// **'试试其他关键词？'**
  String get tryOtherKeywords;

  /// No description provided for @loadMoreResults.
  ///
  /// In zh, this message translates to:
  /// **'加载更多结果'**
  String get loadMoreResults;

  /// No description provided for @resetZoom.
  ///
  /// In zh, this message translates to:
  /// **'重置缩放'**
  String get resetZoom;

  /// No description provided for @cannotLoadImage.
  ///
  /// In zh, this message translates to:
  /// **'无法加载图片'**
  String get cannotLoadImage;

  /// No description provided for @joinChatRoomFailed.
  ///
  /// In zh, this message translates to:
  /// **'加入聊天室失败: {error}'**
  String joinChatRoomFailed(String error);

  /// No description provided for @joinDirectChatFailed.
  ///
  /// In zh, this message translates to:
  /// **'加入私聊失败: {error}'**
  String joinDirectChatFailed(String error);

  /// No description provided for @createDirectChatFailed.
  ///
  /// In zh, this message translates to:
  /// **'创建私聊失败: {error}'**
  String createDirectChatFailed(String error);

  /// No description provided for @directChatInitFailed.
  ///
  /// In zh, this message translates to:
  /// **'私聊初始化失败: {error}'**
  String directChatInitFailed(String error);

  /// No description provided for @leaveChatRoomFailed.
  ///
  /// In zh, this message translates to:
  /// **'离开聊天室失败: {error}'**
  String leaveChatRoomFailed(String error);

  /// No description provided for @loadMessagesFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载消息失败: {error}'**
  String loadMessagesFailed(String error);

  /// No description provided for @sendMessageFailed.
  ///
  /// In zh, this message translates to:
  /// **'发送消息失败: {error}'**
  String sendMessageFailed(String error);

  /// No description provided for @messageDeleted.
  ///
  /// In zh, this message translates to:
  /// **'消息已删除'**
  String get messageDeleted;

  /// No description provided for @deleteMessageFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除消息失败: {error}'**
  String deleteMessageFailed(String error);

  /// No description provided for @loadFailedTitle.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get loadFailedTitle;

  /// No description provided for @addedToFavorites.
  ///
  /// In zh, this message translates to:
  /// **'已添加到收藏'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In zh, this message translates to:
  /// **'已取消收藏'**
  String get removedFromFavorites;

  /// No description provided for @successTitle.
  ///
  /// In zh, this message translates to:
  /// **'成功'**
  String get successTitle;

  /// No description provided for @operationFailed.
  ///
  /// In zh, this message translates to:
  /// **'操作失败'**
  String get operationFailed;

  /// No description provided for @deleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除失败: {error}'**
  String deleteFailed(String error);

  /// No description provided for @loadRatingFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载评分信息失败: {error}'**
  String loadRatingFailed(String error);

  /// No description provided for @submitRatingFailed.
  ///
  /// In zh, this message translates to:
  /// **'提交评分失败'**
  String get submitRatingFailed;

  /// No description provided for @ratingItemCreated.
  ///
  /// In zh, this message translates to:
  /// **'评分项创建成功'**
  String get ratingItemCreated;

  /// No description provided for @createRatingItemFailed.
  ///
  /// In zh, this message translates to:
  /// **'创建评分项失败: {error}'**
  String createRatingItemFailed(String error);

  /// No description provided for @ratingItemDeleted.
  ///
  /// In zh, this message translates to:
  /// **'评分项删除成功'**
  String get ratingItemDeleted;

  /// No description provided for @deleteRatingItemFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除评分项失败: {error}'**
  String deleteRatingItemFailed(String error);

  /// No description provided for @imageGenFailed.
  ///
  /// In zh, this message translates to:
  /// **'图片生成失败'**
  String get imageGenFailed;

  /// No description provided for @imageGenComplete.
  ///
  /// In zh, this message translates to:
  /// **'图片生成完成'**
  String get imageGenComplete;

  /// No description provided for @cityImageUpdated.
  ///
  /// In zh, this message translates to:
  /// **'{city} 的图片已更新'**
  String cityImageUpdated(String city);

  /// No description provided for @imageGenTimeout.
  ///
  /// In zh, this message translates to:
  /// **'图片生成超时，请稍后刷新页面查看'**
  String get imageGenTimeout;

  /// No description provided for @genTimeout.
  ///
  /// In zh, this message translates to:
  /// **'生成超时'**
  String get genTimeout;

  /// No description provided for @removeSkillFailed.
  ///
  /// In zh, this message translates to:
  /// **'移除技能失败'**
  String get removeSkillFailed;

  /// No description provided for @removeInterestFailed.
  ///
  /// In zh, this message translates to:
  /// **'移除兴趣失败'**
  String get removeInterestFailed;

  /// No description provided for @partialDataLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'部分数据加载失败'**
  String get partialDataLoadFailed;

  /// No description provided for @loadAnswersFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载答案失败: {error}'**
  String loadAnswersFailed(String error);

  /// No description provided for @operationFailedWithError.
  ///
  /// In zh, this message translates to:
  /// **'操作失败: {error}'**
  String operationFailedWithError(String error);

  /// No description provided for @deleteEntity.
  ///
  /// In zh, this message translates to:
  /// **'删除{entity}'**
  String deleteEntity(String entity);

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除这个{entity}吗？此操作不可撤销。'**
  String confirmDeleteMessage(String entity);

  /// No description provided for @entityDeleted.
  ///
  /// In zh, this message translates to:
  /// **'{entity}已删除'**
  String entityDeleted(String entity);

  /// No description provided for @deleteFailedWithError.
  ///
  /// In zh, this message translates to:
  /// **'删除失败: {error}'**
  String deleteFailedWithError(String error);

  /// No description provided for @selectImageFailed.
  ///
  /// In zh, this message translates to:
  /// **'选择图片失败: {error}'**
  String selectImageFailed(String error);

  /// No description provided for @selectFileFailed.
  ///
  /// In zh, this message translates to:
  /// **'选择文件失败: {error}'**
  String selectFileFailed(String error);

  /// No description provided for @allowMicPermission.
  ///
  /// In zh, this message translates to:
  /// **'请允许录音权限'**
  String get allowMicPermission;

  /// No description provided for @recordingFailed.
  ///
  /// In zh, this message translates to:
  /// **'录音失败: {error}'**
  String recordingFailed(String error);

  /// No description provided for @talkTooShort.
  ///
  /// In zh, this message translates to:
  /// **'说话时间太短'**
  String get talkTooShort;

  /// No description provided for @recordingCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get recordingCancelled;

  /// No description provided for @holdToTalk.
  ///
  /// In zh, this message translates to:
  /// **'按住 说话'**
  String get holdToTalk;

  /// No description provided for @releaseToCancel.
  ///
  /// In zh, this message translates to:
  /// **'松开取消'**
  String get releaseToCancel;

  /// No description provided for @cancelRecording.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancelRecording;

  /// No description provided for @holdButtonToRecord.
  ///
  /// In zh, this message translates to:
  /// **'按住下方按钮开始录音'**
  String get holdButtonToRecord;

  /// No description provided for @releaseToCancelSend.
  ///
  /// In zh, this message translates to:
  /// **'松开手指，取消发送'**
  String get releaseToCancelSend;

  /// No description provided for @swipeUpToCancel.
  ///
  /// In zh, this message translates to:
  /// **'上滑取消'**
  String get swipeUpToCancel;

  /// No description provided for @recording.
  ///
  /// In zh, this message translates to:
  /// **'正在录音...'**
  String get recording;

  /// No description provided for @interestLevelTitle.
  ///
  /// In zh, this message translates to:
  /// **'喜爱程度'**
  String get interestLevelTitle;

  /// No description provided for @interestLevelCasual.
  ///
  /// In zh, this message translates to:
  /// **'一般'**
  String get interestLevelCasual;

  /// No description provided for @interestLevelLike.
  ///
  /// In zh, this message translates to:
  /// **'喜欢'**
  String get interestLevelLike;

  /// No description provided for @interestLevelPassionate.
  ///
  /// In zh, this message translates to:
  /// **'热爱'**
  String get interestLevelPassionate;

  /// No description provided for @searchInterests.
  ///
  /// In zh, this message translates to:
  /// **'搜索兴趣爱好...'**
  String get searchInterests;

  /// No description provided for @selected.
  ///
  /// In zh, this message translates to:
  /// **'已选择'**
  String get selected;

  /// No description provided for @categoryFitness.
  ///
  /// In zh, this message translates to:
  /// **'运动健身'**
  String get categoryFitness;

  /// No description provided for @categoryArtCulture.
  ///
  /// In zh, this message translates to:
  /// **'艺术文化'**
  String get categoryArtCulture;

  /// No description provided for @categoryCooking.
  ///
  /// In zh, this message translates to:
  /// **'美食烹饪'**
  String get categoryCooking;

  /// No description provided for @categoryTravel.
  ///
  /// In zh, this message translates to:
  /// **'旅行探险'**
  String get categoryTravel;

  /// No description provided for @categoryTech.
  ///
  /// In zh, this message translates to:
  /// **'科技数码'**
  String get categoryTech;

  /// No description provided for @categoryReading.
  ///
  /// In zh, this message translates to:
  /// **'阅读学习'**
  String get categoryReading;

  /// No description provided for @categoryMusic.
  ///
  /// In zh, this message translates to:
  /// **'音乐娱乐'**
  String get categoryMusic;

  /// No description provided for @categorySocial.
  ///
  /// In zh, this message translates to:
  /// **'社交公益'**
  String get categorySocial;

  /// No description provided for @maxInterestsReached.
  ///
  /// In zh, this message translates to:
  /// **'最多只能选择 {count} 个兴趣'**
  String maxInterestsReached(String count);

  /// No description provided for @cannotLoadInterests.
  ///
  /// In zh, this message translates to:
  /// **'无法加载兴趣列表，请稍后重试'**
  String get cannotLoadInterests;

  /// No description provided for @proficiencyTitle.
  ///
  /// In zh, this message translates to:
  /// **'熟练度'**
  String get proficiencyTitle;

  /// No description provided for @experienceYears.
  ///
  /// In zh, this message translates to:
  /// **'经验年限'**
  String get experienceYears;

  /// No description provided for @lessThanOneYear.
  ///
  /// In zh, this message translates to:
  /// **'少于1年'**
  String get lessThanOneYear;

  /// No description provided for @yearsCount.
  ///
  /// In zh, this message translates to:
  /// **'{count}年'**
  String yearsCount(String count);

  /// No description provided for @beginner.
  ///
  /// In zh, this message translates to:
  /// **'初学者'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In zh, this message translates to:
  /// **'中级'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In zh, this message translates to:
  /// **'高级'**
  String get advanced;

  /// No description provided for @expert.
  ///
  /// In zh, this message translates to:
  /// **'专家'**
  String get expert;

  /// No description provided for @searchSkills.
  ///
  /// In zh, this message translates to:
  /// **'搜索技能...'**
  String get searchSkills;

  /// No description provided for @categoryProgramming.
  ///
  /// In zh, this message translates to:
  /// **'编程开发'**
  String get categoryProgramming;

  /// No description provided for @categoryDesign.
  ///
  /// In zh, this message translates to:
  /// **'设计创意'**
  String get categoryDesign;

  /// No description provided for @categoryMarketing.
  ///
  /// In zh, this message translates to:
  /// **'营销商务'**
  String get categoryMarketing;

  /// No description provided for @categoryLanguage.
  ///
  /// In zh, this message translates to:
  /// **'语言能力'**
  String get categoryLanguage;

  /// No description provided for @categoryDataAnalysis.
  ///
  /// In zh, this message translates to:
  /// **'数据分析'**
  String get categoryDataAnalysis;

  /// No description provided for @categoryProjectMgmt.
  ///
  /// In zh, this message translates to:
  /// **'项目管理'**
  String get categoryProjectMgmt;

  /// No description provided for @categoryOther.
  ///
  /// In zh, this message translates to:
  /// **'其他技能'**
  String get categoryOther;

  /// No description provided for @maxSkillsReached.
  ///
  /// In zh, this message translates to:
  /// **'最多只能选择 {count} 个技能'**
  String maxSkillsReached(String count);

  /// No description provided for @shareToWechat.
  ///
  /// In zh, this message translates to:
  /// **'分享到微信'**
  String get shareToWechat;

  /// No description provided for @shareToQQ.
  ///
  /// In zh, this message translates to:
  /// **'分享到QQ'**
  String get shareToQQ;

  /// No description provided for @shareTo.
  ///
  /// In zh, this message translates to:
  /// **'分享到'**
  String get shareTo;

  /// No description provided for @qqFriends.
  ///
  /// In zh, this message translates to:
  /// **'QQ好友'**
  String get qqFriends;

  /// No description provided for @qqZone.
  ///
  /// In zh, this message translates to:
  /// **'QQ空间'**
  String get qqZone;

  /// No description provided for @wechatFriends.
  ///
  /// In zh, this message translates to:
  /// **'微信好友'**
  String get wechatFriends;

  /// No description provided for @moments.
  ///
  /// In zh, this message translates to:
  /// **'朋友圈'**
  String get moments;

  /// No description provided for @copyLink.
  ///
  /// In zh, this message translates to:
  /// **'复制链接'**
  String get copyLink;

  /// No description provided for @systemShare.
  ///
  /// In zh, this message translates to:
  /// **'系统分享'**
  String get systemShare;

  /// No description provided for @weibo.
  ///
  /// In zh, this message translates to:
  /// **'微博'**
  String get weibo;

  /// No description provided for @wechatNotInstalledSystemShare.
  ///
  /// In zh, this message translates to:
  /// **'微信未安装，已使用系统分享'**
  String get wechatNotInstalledSystemShare;

  /// No description provided for @linkCopied.
  ///
  /// In zh, this message translates to:
  /// **'链接已复制'**
  String get linkCopied;

  /// No description provided for @cannotOpenShareLink.
  ///
  /// In zh, this message translates to:
  /// **'无法打开分享链接'**
  String get cannotOpenShareLink;

  /// No description provided for @shareFailedWithError.
  ///
  /// In zh, this message translates to:
  /// **'分享失败: {error}'**
  String shareFailedWithError(String error);

  /// No description provided for @confirmApprove.
  ///
  /// In zh, this message translates to:
  /// **'确认通过'**
  String get confirmApprove;

  /// No description provided for @confirmApproveMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定要通过{name}的版主申请吗？'**
  String confirmApproveMessage(String name);

  /// No description provided for @rejectApplication.
  ///
  /// In zh, this message translates to:
  /// **'拒绝申请'**
  String get rejectApplication;

  /// No description provided for @confirmRejectMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定要拒绝{name}的版主申请吗？'**
  String confirmRejectMessage(String name);

  /// No description provided for @rejectReasonOptional.
  ///
  /// In zh, this message translates to:
  /// **'拒绝原因（可选）'**
  String get rejectReasonOptional;

  /// No description provided for @enterRejectReason.
  ///
  /// In zh, this message translates to:
  /// **'请输入拒绝原因...'**
  String get enterRejectReason;

  /// No description provided for @confirmReject.
  ///
  /// In zh, this message translates to:
  /// **'确认拒绝'**
  String get confirmReject;

  /// No description provided for @confirmRevoke.
  ///
  /// In zh, this message translates to:
  /// **'确认撤销'**
  String get confirmRevoke;

  /// No description provided for @confirmRevokeMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定要撤销{name}的版主资格吗？'**
  String confirmRevokeMessage(String name);

  /// No description provided for @moderatorRevoked.
  ///
  /// In zh, this message translates to:
  /// **'已撤销版主资格'**
  String get moderatorRevoked;

  /// No description provided for @revokeFailed.
  ///
  /// In zh, this message translates to:
  /// **'撤销失败: {error}'**
  String revokeFailed(String error);

  /// No description provided for @applicationApproved.
  ///
  /// In zh, this message translates to:
  /// **'已通过申请'**
  String get applicationApproved;

  /// No description provided for @applicationRejected.
  ///
  /// In zh, this message translates to:
  /// **'已拒绝申请'**
  String get applicationRejected;

  /// No description provided for @moderatorApplicationDetail.
  ///
  /// In zh, this message translates to:
  /// **'版主申请详情'**
  String get moderatorApplicationDetail;

  /// No description provided for @applicationNotExists.
  ///
  /// In zh, this message translates to:
  /// **'申请不存在'**
  String get applicationNotExists;

  /// No description provided for @applicationTime.
  ///
  /// In zh, this message translates to:
  /// **'申请时间: {time}'**
  String applicationTime(String time);

  /// No description provided for @processTime.
  ///
  /// In zh, this message translates to:
  /// **'处理时间: {time}'**
  String processTime(String time);

  /// No description provided for @applicantInfo.
  ///
  /// In zh, this message translates to:
  /// **'申请人信息'**
  String get applicantInfo;

  /// No description provided for @unknownUser.
  ///
  /// In zh, this message translates to:
  /// **'未知用户'**
  String get unknownUser;

  /// No description provided for @applicationCity.
  ///
  /// In zh, this message translates to:
  /// **'申请管理的城市'**
  String get applicationCity;

  /// No description provided for @unknownCity.
  ///
  /// In zh, this message translates to:
  /// **'未知城市'**
  String get unknownCity;

  /// No description provided for @applicationReason.
  ///
  /// In zh, this message translates to:
  /// **'申请理由'**
  String get applicationReason;

  /// No description provided for @noReasonProvided.
  ///
  /// In zh, this message translates to:
  /// **'未填写申请理由'**
  String get noReasonProvided;

  /// No description provided for @rejectReason.
  ///
  /// In zh, this message translates to:
  /// **'拒绝原因'**
  String get rejectReason;

  /// No description provided for @reject.
  ///
  /// In zh, this message translates to:
  /// **'拒绝'**
  String get reject;

  /// No description provided for @approve.
  ///
  /// In zh, this message translates to:
  /// **'通过'**
  String get approve;

  /// No description provided for @revokeModeratorStatus.
  ///
  /// In zh, this message translates to:
  /// **'撤销版主资格'**
  String get revokeModeratorStatus;

  /// No description provided for @visitedPlaces.
  ///
  /// In zh, this message translates to:
  /// **'访问过的地方'**
  String get visitedPlaces;

  /// No description provided for @placesCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个地方'**
  String placesCount(String count);

  /// No description provided for @highlightsCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个亮点'**
  String highlightsCount(String count);

  /// No description provided for @noDateInfo.
  ///
  /// In zh, this message translates to:
  /// **'无日期信息'**
  String get noDateInfo;

  /// No description provided for @present.
  ///
  /// In zh, this message translates to:
  /// **'至今'**
  String get present;

  /// No description provided for @noVisitedPlacesYet.
  ///
  /// In zh, this message translates to:
  /// **'暂无访问记录'**
  String get noVisitedPlacesYet;

  /// No description provided for @visitedPlacesHint.
  ///
  /// In zh, this message translates to:
  /// **'停留超过40分钟的地方会显示在这里'**
  String get visitedPlacesHint;

  /// No description provided for @unknownPlace.
  ///
  /// In zh, this message translates to:
  /// **'未知地点'**
  String get unknownPlace;

  /// No description provided for @arrival.
  ///
  /// In zh, this message translates to:
  /// **'到达'**
  String get arrival;

  /// No description provided for @departure.
  ///
  /// In zh, this message translates to:
  /// **'离开'**
  String get departure;

  /// No description provided for @mapViewComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'地图视图即将上线'**
  String get mapViewComingSoon;

  /// No description provided for @nomadFriendly.
  ///
  /// In zh, this message translates to:
  /// **'数字游民友好'**
  String get nomadFriendly;

  /// No description provided for @ratingExcellent.
  ///
  /// In zh, this message translates to:
  /// **'极好'**
  String get ratingExcellent;

  /// No description provided for @ratingVeryGood.
  ///
  /// In zh, this message translates to:
  /// **'很好'**
  String get ratingVeryGood;

  /// No description provided for @ratingGood.
  ///
  /// In zh, this message translates to:
  /// **'不错'**
  String get ratingGood;

  /// No description provided for @ratingAverage.
  ///
  /// In zh, this message translates to:
  /// **'一般'**
  String get ratingAverage;

  /// No description provided for @ratingPoor.
  ///
  /// In zh, this message translates to:
  /// **'较差'**
  String get ratingPoor;

  /// No description provided for @priceLabel.
  ///
  /// In zh, this message translates to:
  /// **'价格'**
  String get priceLabel;

  /// No description provided for @perNight.
  ///
  /// In zh, this message translates to:
  /// **'/晚'**
  String get perNight;

  /// No description provided for @available.
  ///
  /// In zh, this message translates to:
  /// **'有'**
  String get available;

  /// No description provided for @coworkingSpaceIncluded.
  ///
  /// In zh, this message translates to:
  /// **'配套'**
  String get coworkingSpaceIncluded;

  /// No description provided for @emailLabel.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get emailLabel;

  /// No description provided for @roomTypes.
  ///
  /// In zh, this message translates to:
  /// **'房型 ({count})'**
  String roomTypes(String count);

  /// No description provided for @roomTypeList.
  ///
  /// In zh, this message translates to:
  /// **'房型列表'**
  String get roomTypeList;

  /// No description provided for @soldOut.
  ///
  /// In zh, this message translates to:
  /// **'已满'**
  String get soldOut;

  /// No description provided for @maxOccupancy.
  ///
  /// In zh, this message translates to:
  /// **'最多{count}人'**
  String maxOccupancy(String count);

  /// No description provided for @pleaseLoginToReview.
  ///
  /// In zh, this message translates to:
  /// **'请先登录后再发表评论'**
  String get pleaseLoginToReview;

  /// No description provided for @reviewTitleOptional.
  ///
  /// In zh, this message translates to:
  /// **'标题（选填）'**
  String get reviewTitleOptional;

  /// No description provided for @reviewContent.
  ///
  /// In zh, this message translates to:
  /// **'评论内容'**
  String get reviewContent;

  /// No description provided for @reviewContentHint.
  ///
  /// In zh, this message translates to:
  /// **'分享您的入住体验...'**
  String get reviewContentHint;

  /// No description provided for @selectRating.
  ///
  /// In zh, this message translates to:
  /// **'请选择评分'**
  String get selectRating;

  /// No description provided for @enterReviewContent.
  ///
  /// In zh, this message translates to:
  /// **'请输入评论内容'**
  String get enterReviewContent;

  /// No description provided for @reviewSubmitSuccess.
  ///
  /// In zh, this message translates to:
  /// **'评论发表成功！'**
  String get reviewSubmitSuccess;

  /// No description provided for @reviewSubmitFailed.
  ///
  /// In zh, this message translates to:
  /// **'评论发表失败'**
  String get reviewSubmitFailed;

  /// No description provided for @alreadyReviewed.
  ///
  /// In zh, this message translates to:
  /// **'您已经评论过这家酒店了'**
  String get alreadyReviewed;

  /// No description provided for @reviewSubmitFailedRetry.
  ///
  /// In zh, this message translates to:
  /// **'评论发表失败，请稍后重试'**
  String get reviewSubmitFailedRetry;

  /// No description provided for @tapToRate.
  ///
  /// In zh, this message translates to:
  /// **'点击星星评分'**
  String get tapToRate;

  /// No description provided for @ratingVeryPoor.
  ///
  /// In zh, this message translates to:
  /// **'很差'**
  String get ratingVeryPoor;

  /// No description provided for @ratingFair.
  ///
  /// In zh, this message translates to:
  /// **'较差'**
  String get ratingFair;

  /// No description provided for @ratingNice.
  ///
  /// In zh, this message translates to:
  /// **'一般'**
  String get ratingNice;

  /// No description provided for @ratingGreat.
  ///
  /// In zh, this message translates to:
  /// **'很好'**
  String get ratingGreat;

  /// No description provided for @ratingExcellentReview.
  ///
  /// In zh, this message translates to:
  /// **'非常好'**
  String get ratingExcellentReview;

  /// No description provided for @viewAllCount.
  ///
  /// In zh, this message translates to:
  /// **'查看全部 ({count})'**
  String viewAllCount(String count);

  /// No description provided for @reviewCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条评论'**
  String reviewCount(String count);

  /// No description provided for @noReviews.
  ///
  /// In zh, this message translates to:
  /// **'暂无评论'**
  String get noReviews;

  /// No description provided for @beFirstReviewer.
  ///
  /// In zh, this message translates to:
  /// **'成为第一个评论的人'**
  String get beFirstReviewer;

  /// No description provided for @loadMoreReviews.
  ///
  /// In zh, this message translates to:
  /// **'加载更多评论'**
  String get loadMoreReviews;

  /// No description provided for @helpfulCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人觉得有用'**
  String helpfulCount(String count);

  /// No description provided for @userNotLoggedIn.
  ///
  /// In zh, this message translates to:
  /// **'用户未登录'**
  String get userNotLoggedIn;

  /// No description provided for @userInfoUpdated.
  ///
  /// In zh, this message translates to:
  /// **'用户信息已更新'**
  String get userInfoUpdated;

  /// No description provided for @errorTitle.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get errorTitle;

  /// No description provided for @unauthorizedTitle.
  ///
  /// In zh, this message translates to:
  /// **'未授权'**
  String get unauthorizedTitle;

  /// No description provided for @networkErrorTitle.
  ///
  /// In zh, this message translates to:
  /// **'网络错误'**
  String get networkErrorTitle;

  /// No description provided for @serverErrorTitle.
  ///
  /// In zh, this message translates to:
  /// **'服务器错误'**
  String get serverErrorTitle;

  /// No description provided for @validationFailedTitle.
  ///
  /// In zh, this message translates to:
  /// **'验证失败'**
  String get validationFailedTitle;

  /// No description provided for @unknownErrorTitle.
  ///
  /// In zh, this message translates to:
  /// **'未知错误'**
  String get unknownErrorTitle;

  /// No description provided for @removeSkillFailedWithError.
  ///
  /// In zh, this message translates to:
  /// **'移除技能失败: {error}'**
  String removeSkillFailedWithError(String error);

  /// No description provided for @removeInterestFailedWithError.
  ///
  /// In zh, this message translates to:
  /// **'移除兴趣失败: {error}'**
  String removeInterestFailedWithError(String error);

  /// No description provided for @searchError.
  ///
  /// In zh, this message translates to:
  /// **'搜索出错: {error}'**
  String searchError(String error);

  /// No description provided for @loadMoreSearchError.
  ///
  /// In zh, this message translates to:
  /// **'加载更多搜索结果出错: {error}'**
  String loadMoreSearchError(String error);

  /// No description provided for @generateImageFailed.
  ///
  /// In zh, this message translates to:
  /// **'生成图片失败: {error}'**
  String generateImageFailed(String error);

  /// No description provided for @imageGenFailedDefault.
  ///
  /// In zh, this message translates to:
  /// **'图片生成失败'**
  String get imageGenFailedDefault;

  /// No description provided for @moderatorStatusPending.
  ///
  /// In zh, this message translates to:
  /// **'待审核'**
  String get moderatorStatusPending;

  /// No description provided for @moderatorStatusApproved.
  ///
  /// In zh, this message translates to:
  /// **'已通过'**
  String get moderatorStatusApproved;

  /// No description provided for @moderatorStatusRejected.
  ///
  /// In zh, this message translates to:
  /// **'已拒绝'**
  String get moderatorStatusRejected;

  /// No description provided for @revokePermissionWarning.
  ///
  /// In zh, this message translates to:
  /// **'此操作将移除该用户在此城市的所有版主权限。'**
  String get revokePermissionWarning;

  /// No description provided for @perNightLabel.
  ///
  /// In zh, this message translates to:
  /// **'每晚'**
  String get perNightLabel;

  /// No description provided for @ratingDescExcellent.
  ///
  /// In zh, this message translates to:
  /// **'优秀'**
  String get ratingDescExcellent;

  /// No description provided for @ratingDescVeryGood.
  ///
  /// In zh, this message translates to:
  /// **'很好'**
  String get ratingDescVeryGood;

  /// No description provided for @ratingDescGood.
  ///
  /// In zh, this message translates to:
  /// **'良好'**
  String get ratingDescGood;

  /// No description provided for @ratingDescAverage.
  ///
  /// In zh, this message translates to:
  /// **'一般'**
  String get ratingDescAverage;

  /// No description provided for @ratingDescPoor.
  ///
  /// In zh, this message translates to:
  /// **'较差'**
  String get ratingDescPoor;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
