import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en', 'US'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Navigation and common terms
  String get manage => _getText('manage');
  String get home => _getText('home');
  String get topics => _getText('topics');
  String get favorites => _getText('favorites');
  String get preferences => _getText('preferences');
  String get videoSettings => _getText('video_settings');
  String get storage => _getText('storage');
  String get about => _getText('about');

  // Common actions
  String get cancel => _getText('cancel');
  String get close => _getText('close');
  String get ok => _getText('ok');
  String get save => _getText('save');
  String get delete => _getText('delete');
  String get edit => _getText('edit');
  String get share => _getText('share');
  String get refresh => _getText('refresh');
  String get search => _getText('search');
  String get clear => _getText('clear');
  String get back => _getText('back');
  String get next => _getText('next');
  String get previous => _getText('previous');

  // Settings
  String get notifications => _getText('notifications');
  String get notificationsDesc => _getText('notifications_desc');
  String get darkMode => _getText('dark_mode');
  String get darkModeDesc => _getText('dark_mode_desc');
  String get language => _getText('language');
  String get languageDesc => _getText('language_desc');
  String get autoPlay => _getText('auto_play');
  String get autoPlayDesc => _getText('auto_play_desc');
  String get wifiOnly => _getText('wifi_only');
  String get wifiOnlyDesc => _getText('wifi_only_desc');
  String get offlineVideos => _getText('offline_videos');
  String get offlineVideosDesc => _getText('offline_videos_desc');

  // Downloaded Videos Management
  String get downloadedVideos => _getText('downloaded_videos');
  String get noDownloadedVideos => _getText('no_downloaded_videos');
  String get downloadVideosForOfflineViewing =>
      _getText('download_videos_for_offline_viewing');
  String get storageUsed => _getText('storage_used');
  String get videos => _getText('videos');
  String get downloaded => _getText('downloaded');
  String get deleteDownload => _getText('delete_download');
  String get deleteDownloadConfirmation =>
      _getText('delete_download_confirmation');
  String get videoDeletedSuccessfully => _getText('video_deleted_successfully');
  String get failedToDeleteVideo => _getText('failed_to_delete_video');
  String get clearAllDownloads => _getText('clear_all_downloads');
  String get clearAllDownloadsConfirmation =>
      _getText('clear_all_downloads_confirmation');
  String get clearAll => _getText('clear_all');
  String get allDownloadsClearedSuccessfully =>
      _getText('all_downloads_cleared_successfully');

  // Video Download Actions
  String get downloadVideo => _getText('download_video');
  String get downloading => _getText('downloading');
  String get downloadCompleted => _getText('download_completed');
  String get downloadFailed => _getText('download_failed');
  String get downloadStarted => _getText('download_started');
  String get playOffline => _getText('play_offline');
  String get downloadInProgress => _getText('download_in_progress');
  String get downloadPaused => _getText('download_paused');

  // Storage Permissions
  String get storagePermissionRequired =>
      _getText('storage_permission_required');
  String get storagePermissionDescription =>
      _getText('storage_permission_description');
  String get grantPermission => _getText('grant_permission');
  String get permissionDenied => _getText('permission_denied');
  String get permissionDeniedMessage => _getText('permission_denied_message');
  String get settings => _getText('settings');

  // Storage
  String get downloadedContent => _getText('downloaded_content');
  String get downloadedContentDesc => _getText('downloaded_content_desc');
  String get clearCache => _getText('clear_cache');
  String get clearCacheDesc => _getText('clear_cache_desc');
  String get clearCacheConfirm => _getText('clear_cache_confirm');
  String get cacheClearedSuccess => _getText('cache_cleared_success');

  // About
  String get helpSupport => _getText('help_support');
  String get helpSupportDesc => _getText('help_support_desc');
  String get privacyPolicy => _getText('privacy_policy');
  String get privacyPolicyDesc => _getText('privacy_policy_desc');
  String get termsOfService => _getText('terms_of_service');
  String get termsOfServiceDesc => _getText('terms_of_service_desc');
  String get aboutApp => _getText('about_app');
  String get appVersion => _getText('app_version');

  // Authentication
  String get signOut => _getText('sign_out');
  String get signOutConfirm => _getText('sign_out_confirm');
  String get signOutSuccess => _getText('sign_out_success');
  String get signIn => _getText('sign_in');
  String get signUp => _getText('sign_up');

  // Home screen
  String get todaysVerse => _getText('todays_verse');
  String get islamicDate => _getText('islamic_date');
  String get recentTopics => _getText('recent_topics');
  String get seeAll => _getText('see_all');
  String get failedToLoadVerse => _getText('failed_to_load_verse');
  String get failedToLoadTopics => _getText('failed_to_load_topics');

  // Topics
  String get allTopics => _getText('all_topics');
  String get searchTopics => _getText('search_topics');
  String get noTopicsFound => _getText('no_topics_found');
  String get lessons => _getText('lessons');
  String get lesson => _getText('lesson');

  // Favorites
  String get noFavoritesYet => _getText('no_favorites_yet');
  String get noFavoritesDesc => _getText('no_favorites_desc');
  String get exploreTopics => _getText('explore_topics');
  String get favoriteLessons => _getText('favorite_lessons');
  String get addedToFavorites => _getText('added_to_favorites');
  String get removedFromFavorites => _getText('removed_from_favorites');
  String get failedToUpdateFavorites => _getText('failed_to_update_favorites');
  String get clearAllFavorites => _getText('clear_all_favorites');
  String get clearAllFavoritesConfirm =>
      _getText('clear_all_favorites_confirm');
  String get allFavoritesCleared => _getText('all_favorites_cleared');

  // Video Player
  String get relatedLessons => _getText('related_lessons');
  String get downloadReference => _getText('download_reference');
  String get downloadReferenceMaterial =>
      _getText('download_reference_material');
  String get noReferenceMaterial => _getText('no_reference_material');
  String get openingReferenceMaterial => _getText('opening_reference_material');
  String get cannotOpenReference => _getText('cannot_open_reference');
  String get failedToOpenReference => _getText('failed_to_open_reference');
  String get errorLoadingVideo => _getText('error_loading_video');
  String get failedToLoadVideo => _getText('failed_to_load_video');
  String get sharingLesson => _getText('sharing_lesson');

  // Notifications
  String get notificationDetails => _getText('notification_details');
  String get markAllRead => _getText('mark_all_read');
  String get allNotificationsRead => _getText('all_notifications_read');
  String get backToList => _getText('back_to_list');
  String get noNotifications => _getText('no_notifications');

  // Loading and errors
  String get loading => _getText('loading');
  String get error => _getText('error');
  String get tryAgain => _getText('try_again');
  String get comingSoon => _getText('coming_soon');

  // Languages
  String get english => _getText('english');
  String get arabic => _getText('arabic');
  String get urdu => _getText('urdu');

  String _getText(String key) {
    switch (locale.languageCode) {
      case 'ar':
        return _arabicTexts[key] ?? _englishTexts[key] ?? key;
      case 'ur':
        return _urduTexts[key] ?? _englishTexts[key] ?? key;
      default:
        return _englishTexts[key] ?? key;
    }
  }

  static const Map<String, String> _englishTexts = {
    'manage': 'Manage',
    'home': 'Home',
    'topics': 'Topics',
    'favorites': 'Favorites',
    'preferences': 'Preferences',
    'video_settings': 'Video Settings',
    'storage': 'Storage',
    'about': 'About',

    // Common actions
    'cancel': 'Cancel',
    'close': 'Close',
    'ok': 'OK',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'share': 'Share',
    'refresh': 'Refresh',
    'search': 'Search',
    'clear': 'Clear',
    'back': 'Back',
    'next': 'Next',
    'previous': 'Previous',

    'notifications': 'Notifications',
    'notifications_desc': 'Receive prayer reminders and lesson updates',
    'dark_mode': 'Dark Mode',
    'dark_mode_desc': 'Enable dark theme',
    'language': 'Language',
    'language_desc': 'Select app language',
    'auto_play': 'Auto Play',
    'auto_play_desc': 'Automatically play next lesson',
    'wifi_only': 'WiFi Only Downloads',
    'wifi_only_desc': 'Download content only over WiFi',
    'offline_videos': 'Offline Videos',
    'offline_videos_desc': 'Enable downloading videos for offline viewing',
    'downloaded_content': 'Downloaded Content',
    'downloaded_content_desc': 'Manage offline downloads',

    // Downloaded Videos Management
    'downloaded_videos': 'Downloaded Videos',
    'no_downloaded_videos': 'No downloaded videos',
    'download_videos_for_offline_viewing':
        'Download videos from lessons to watch them offline',
    'storage_used': 'Storage Used',
    'videos': 'videos',
    'downloaded': 'Downloaded',
    'delete_download': 'Delete Download',
    'delete_download_confirmation':
        'Are you sure you want to delete this downloaded video?',
    'video_deleted_successfully': 'Video deleted successfully',
    'failed_to_delete_video': 'Failed to delete video',
    'clear_all_downloads': 'Clear All Downloads',
    'clear_all_downloads_confirmation':
        'Are you sure you want to delete all downloaded videos?',
    'clear_all': 'Clear All',
    'all_downloads_cleared_successfully': 'All downloads cleared successfully',

    // Video Download Actions
    'download_video': 'Download Video',
    'downloading': 'Downloading...',
    'download_completed': 'Download Completed',
    'download_failed': 'Download Failed',
    'download_started': 'Download Started',
    'play_offline': 'Play Offline',
    'download_in_progress': 'Download in Progress',
    'download_paused': 'Download Paused',

    // Storage Permissions
    'storage_permission_required': 'Storage Permission Required',
    'storage_permission_description':
        'This app needs storage permission to download videos for offline viewing. Grant permission?',
    'grant_permission': 'Grant Permission',
    'permission_denied': 'Permission Denied',
    'permission_denied_message':
        'Storage permission denied. Cannot download videos without permission.',
    'clear_cache': 'Clear Cache',
    'clear_cache_desc': 'Free up storage space',
    'clear_cache_confirm': 'This will free up storage space. Continue?',
    'cache_cleared_success': 'Cache cleared successfully!',
    'help_support': 'Help & Support',
    'help_support_desc': 'Get help and contact support',
    'privacy_policy': 'Privacy Policy',
    'privacy_policy_desc': 'View our privacy policy',
    'terms_of_service': 'Terms of Service',
    'terms_of_service_desc': 'View terms and conditions',
    'about_app': 'About App',
    'app_version': 'Version 1.2.4',

    // Authentication
    'sign_out': 'Sign Out',
    'sign_out_confirm': 'Are you sure you want to sign out?',
    'sign_out_success': 'Signed out successfully!',
    'sign_in': 'Sign In',
    'sign_up': 'Sign Up',

    // Home screen
    'todays_verse': 'Today\'s Verse',
    'islamic_date': 'Islamic Date',
    'recent_topics': 'Recent Topics',
    'see_all': 'See All',
    'failed_to_load_verse': 'Failed to load verse',
    'failed_to_load_topics': 'Failed to load topics, showing sample data',

    // Topics
    'all_topics': 'All Topics',
    'search_topics': 'Search topics...',
    'no_topics_found': 'No topics found',
    'lessons': 'lessons',
    'lesson': 'Lesson',

    // Favorites
    'no_favorites_yet': 'No Favorites Yet',
    'no_favorites_desc': 'Your favorite lessons will appear here',
    'explore_topics': 'Explore Topics',
    'favorite_lessons': 'Favorite Lessons',
    'added_to_favorites': 'Added to favorites',
    'removed_from_favorites': 'Removed from favorites',
    'failed_to_update_favorites': 'Failed to update favorites',
    'clear_all_favorites': 'Clear All Favorites',
    'clear_all_favorites_confirm':
        'Are you sure you want to remove all lessons from favorites?',
    'all_favorites_cleared': 'All favorites cleared',

    // Video Player
    'related_lessons': 'Related Lessons',
    'download_reference': 'Download Reference',
    'download_reference_material': 'Download Reference Material',
    'no_reference_material': 'No reference material available',
    'opening_reference_material': 'Opening reference material',
    'cannot_open_reference': 'Cannot open reference material',
    'failed_to_open_reference': 'Failed to open reference material',
    'error_loading_video': 'Error loading video',
    'failed_to_load_video': 'Failed to load video',
    'sharing_lesson': 'Sharing lesson...',

    // Notifications
    'notification_details': 'Notification Details',
    'mark_all_read': 'Mark All Read',
    'all_notifications_read': 'All notifications marked as read',
    'back_to_list': 'Back to List',
    'no_notifications': 'No notifications',

    // Loading and errors
    'loading': 'Loading...',
    'error': 'Error',
    'try_again': 'Try Again',
    'coming_soon': 'Coming Soon!',

    'english': 'English',
    'arabic': 'Arabic',
    'urdu': 'Urdu',
  };

  static const Map<String, String> _arabicTexts = {
    'manage': 'إدارة',
    'home': 'الرئيسية',
    'topics': 'المواضيع',
    'favorites': 'المفضلة',
    'preferences': 'التفضيلات',
    'video_settings': 'إعدادات الفيديو',
    'storage': 'التخزين',
    'about': 'حول',

    // Common actions
    'cancel': 'إلغاء',
    'close': 'إغلاق',
    'ok': 'موافق',
    'save': 'حفظ',
    'delete': 'حذف',
    'edit': 'تعديل',
    'share': 'مشاركة',
    'refresh': 'تحديث',
    'search': 'بحث',
    'clear': 'مسح',
    'back': 'رجوع',
    'next': 'التالي',
    'previous': 'السابق',

    'notifications': 'الإشعارات',
    'notifications_desc': 'تلقي تذكيرات الصلاة وتحديثات الدروس',
    'dark_mode': 'الوضع المظلم',
    'dark_mode_desc': 'تفعيل المظهر المظلم',
    'language': 'اللغة',
    'language_desc': 'اختر لغة التطبيق',
    'auto_play': 'التشغيل التلقائي',
    'auto_play_desc': 'تشغيل الدرس التالي تلقائياً',
    'wifi_only': 'التحميل عبر الواي فاي فقط',
    'wifi_only_desc': 'تحميل المحتوى عبر الواي فاي فقط',
    'offline_videos': 'الفيديوهات غير المتصلة',
    'offline_videos_desc': 'تمكين تحميل الفيديوهات للمشاهدة دون اتصال',
    'downloaded_content': 'المحتوى المحمل',
    'downloaded_content_desc': 'إدارة التحميلات غير المتصلة',

    // Downloaded Videos Management
    'downloaded_videos': 'الفيديوهات المحملة',
    'no_downloaded_videos': 'لا توجد فيديوهات محملة',
    'download_videos_for_offline_viewing':
        'حمل الفيديوهات من الدروس لمشاهدتها دون اتصال',
    'storage_used': 'المساحة المستخدمة',
    'videos': 'فيديوهات',
    'downloaded': 'محمل',
    'delete_download': 'حذف التحميل',
    'delete_download_confirmation': 'هل أنت متأكد من حذف هذا الفيديو المحمل؟',
    'video_deleted_successfully': 'تم حذف الفيديو بنجاح',
    'failed_to_delete_video': 'فشل في حذف الفيديو',
    'clear_all_downloads': 'مسح جميع التحميلات',
    'clear_all_downloads_confirmation':
        'هل أنت متأكد من حذف جميع الفيديوهات المحملة؟',
    'clear_all': 'مسح الكل',
    'all_downloads_cleared_successfully': 'تم مسح جميع التحميلات بنجاح',

    // Video Download Actions
    'download_video': 'تحميل الفيديو',
    'downloading': 'جاري التحميل...',
    'download_completed': 'تم التحميل',
    'download_failed': 'فشل التحميل',
    'download_started': 'بدأ التحميل',
    'play_offline': 'تشغيل دون اتصال',
    'download_in_progress': 'التحميل قيد التقدم',
    'download_paused': 'التحميل متوقف',

    // Storage Permissions
    'storage_permission_required': 'إذن التخزين مطلوب',
    'storage_permission_description':
        'يحتاج هذا التطبيق إلى إذن التخزين لتحميل الفيديوهات للمشاهدة دون اتصال. هل تريد منح الإذن؟',
    'grant_permission': 'منح الإذن',
    'permission_denied': 'تم رفض الإذن',
    'permission_denied_message':
        'تم رفض إذن التخزين. لا يمكن تحميل الفيديوهات بدون إذن.',
    'clear_cache': 'مسح التخزين المؤقت',
    'clear_cache_desc': 'تحرير مساحة التخزين',
    'clear_cache_confirm':
        'سيؤدي هذا إلى تحرير مساحة التخزين. هل تريد المتابعة؟',
    'cache_cleared_success': 'تم مسح التخزين المؤقت بنجاح!',
    'help_support': 'المساعدة والدعم',
    'help_support_desc': 'الحصول على المساعدة والاتصال بالدعم',
    'privacy_policy': 'سياسة الخصوصية',
    'privacy_policy_desc': 'عرض سياسة الخصوصية',
    'terms_of_service': 'شروط الخدمة',
    'terms_of_service_desc': 'عرض الشروط والأحكام',
    'about_app': 'حول التطبيق',
    'app_version': 'الإصدار 1.2.4',

    // Authentication
    'sign_out': 'تسجيل الخروج',
    'sign_out_confirm': 'هل أنت متأكد من تسجيل الخروج؟',
    'sign_out_success': 'تم تسجيل الخروج بنجاح!',
    'sign_in': 'تسجيل الدخول',
    'sign_up': 'إنشاء حساب',

    // Home screen
    'todays_verse': 'آية اليوم',
    'islamic_date': 'التاريخ الهجري',
    'recent_topics': 'المواضيع الحديثة',
    'see_all': 'عرض الكل',
    'failed_to_load_verse': 'فشل في تحميل الآية',
    'failed_to_load_topics': 'فشل في تحميل المواضيع، عرض بيانات تجريبية',

    // Topics
    'all_topics': 'جميع المواضيع',
    'search_topics': 'البحث في المواضيع...',
    'no_topics_found': 'لم يتم العثور على مواضيع',
    'lessons': 'دروس',
    'lesson': 'الدرس',

    // Favorites
    'no_favorites_yet': 'لا توجد مفضلة بعد',
    'no_favorites_desc': 'ستظهر دروسك المفضلة هنا',
    'explore_topics': 'استكشف المواضيع',
    'favorite_lessons': 'الدروس المفضلة',
    'added_to_favorites': 'تمت الإضافة إلى المفضلة',
    'removed_from_favorites': 'تمت الإزالة من المفضلة',
    'failed_to_update_favorites': 'فشل في تحديث المفضلة',
    'clear_all_favorites': 'مسح جميع المفضلة',
    'clear_all_favorites_confirm':
        'هل أنت متأكد من إزالة جميع الدروس من المفضلة؟',
    'all_favorites_cleared': 'تم مسح جميع المفضلة',

    // Video Player
    'related_lessons': 'الدروس ذات الصلة',
    'download_reference': 'تحميل المرجع',
    'download_reference_material': 'تحميل المواد المرجعية',
    'no_reference_material': 'لا توجد مواد مرجعية متاحة',
    'opening_reference_material': 'فتح المواد المرجعية',
    'cannot_open_reference': 'لا يمكن فتح المواد المرجعية',
    'failed_to_open_reference': 'فشل في فتح المواد المرجعية',
    'error_loading_video': 'خطأ في تحميل الفيديو',
    'failed_to_load_video': 'فشل في تحميل الفيديو',
    'sharing_lesson': 'مشاركة الدرس...',

    // Notifications
    'notification_details': 'تفاصيل الإشعار',
    'mark_all_read': 'تحديد الكل كمقروء',
    'all_notifications_read': 'تم تحديد جميع الإشعارات كمقروءة',
    'back_to_list': 'العودة إلى القائمة',
    'no_notifications': 'لا توجد إشعارات',

    // Loading and errors
    'loading': 'جارٍ التحميل...',
    'error': 'خطأ',
    'try_again': 'حاول مرة أخرى',
    'coming_soon': 'قريباً!',

    'english': 'الإنجليزية',
    'arabic': 'العربية',
    'urdu': 'الأردية',
  };

  static const Map<String, String> _urduTexts = {
    'manage': 'منظم کریں',
    'home': 'ہوم',
    'topics': 'مضامین',
    'favorites': 'پسندیدہ',
    'preferences': 'ترجیحات',
    'video_settings': 'ویڈیو کی ترتیبات',
    'storage': 'اسٹوریج',
    'about': 'کے بارے میں',

    // Common actions
    'cancel': 'منسوخ',
    'close': 'بند',
    'ok': 'ٹھیک ہے',
    'save': 'محفوظ کریں',
    'delete': 'ڈیلیٹ',
    'edit': 'ترمیم',
    'share': 'شیئر',
    'refresh': 'ریفریش',
    'search': 'تلاش',
    'clear': 'صاف',
    'back': 'واپس',
    'next': 'اگلا',
    'previous': 'پچھلا',

    'notifications': 'اطلاعات',
    'notifications_desc': 'نماز کی یاد دہانی اور سبق کی تازہ کاری حاصل کریں',
    'dark_mode': 'ڈارک موڈ',
    'dark_mode_desc': 'تاریک تھیم کو فعال کریں',
    'language': 'زبان',
    'language_desc': 'ایپ کی زبان منتخب کریں',
    'auto_play': 'خودکار چلانا',
    'auto_play_desc': 'اگلا سبق خودکار طور پر چلائیں',
    'wifi_only': 'صرف WiFi ڈاؤن لوڈ',
    'wifi_only_desc': 'صرف WiFi پر مواد ڈاؤن لوڈ کریں',
    'offline_videos': 'آف لائن ویڈیوز',
    'offline_videos_desc':
        'آف لائن دیکھنے کے لیے ویڈیوز ڈاؤن لوڈ کرنے کو فعال کریں',
    'downloaded_content': 'ڈاؤن لوڈ شدہ مواد',
    'downloaded_content_desc': 'آف لائن ڈاؤن لوڈز کا انتظام کریں',

    // Downloaded Videos Management
    'downloaded_videos': 'ڈاؤن لوڈ شدہ ویڈیوز',
    'no_downloaded_videos': 'کوئی ڈاؤن لوڈ شدہ ویڈیوز نہیں',
    'download_videos_for_offline_viewing':
        'آف لائن دیکھنے کے لیے اسباق سے ویڈیوز ڈاؤن لوڈ کریں',
    'storage_used': 'استعمال شدہ اسٹوریج',
    'videos': 'ویڈیوز',
    'downloaded': 'ڈاؤن لوڈ شدہ',
    'delete_download': 'ڈاؤن لوڈ حذف کریں',
    'delete_download_confirmation':
        'کیا آپ واقعی اس ڈاؤن لوڈ شدہ ویڈیو کو حذف کرنا چاہتے ہیں؟',
    'video_deleted_successfully': 'ویڈیو کامیابی سے حذف ہو گئی',
    'failed_to_delete_video': 'ویڈیو حذف کرنے میں ناکام',
    'clear_all_downloads': 'تمام ڈاؤن لوڈز صاف کریں',
    'clear_all_downloads_confirmation':
        'کیا آپ واقعی تمام ڈاؤن لوڈ شدہ ویڈیوز حذف کرنا چاہتے ہیں؟',
    'clear_all': 'سب صاف کریں',
    'all_downloads_cleared_successfully':
        'تمام ڈاؤن لوڈز کامیابی سے صاف ہو گئے',

    // Video Download Actions
    'download_video': 'ویڈیو ڈاؤن لوڈ کریں',
    'downloading': 'ڈاؤن لوڈ ہو رہا ہے...',
    'download_completed': 'ڈاؤن لوڈ مکمل',
    'download_failed': 'ڈاؤن لوڈ ناکام',
    'download_started': 'ڈاؤن لوڈ شروع ہوا',
    'play_offline': 'آف لائن چلائیں',
    'download_in_progress': 'ڈاؤن لوڈ جاری ہے',
    'download_paused': 'ڈاؤن لوڈ رک گیا',

    // Storage Permissions
    'storage_permission_required': 'اسٹوریج کی اجازت درکار',
    'storage_permission_description':
        'اس ایپ کو آف لائن دیکھنے کے لیے ویڈیوز ڈاؤن لوڈ کرنے کے لیے اسٹوریج کی اجازت کی ضرورت ہے۔ اجازت دیں؟',
    'grant_permission': 'اجازت دیں',
    'permission_denied': 'اجازت مسترد',
    'permission_denied_message':
        'اسٹوریج کی اجازت مسترد کر دی گئی۔ اجازت کے بغیر ویڈیوز ڈاؤن لوڈ نہیں کر سکتے۔',
    'clear_cache': 'کیش صاف کریں',
    'clear_cache_desc': 'اسٹوریج کی جگہ خالی کریں',
    'clear_cache_confirm': 'یہ اسٹوریج کی جگہ خالی کر دے گا۔ جاری رکھیں؟',
    'cache_cleared_success': 'کیش کامیابی سے صاف کیا گیا!',
    'help_support': 'مدد اور سپورٹ',
    'help_support_desc': 'مدد حاصل کریں اور سپورٹ سے رابطہ کریں',
    'privacy_policy': 'رازداری کی پالیسی',
    'privacy_policy_desc': 'ہماری رازداری کی پالیسی دیکھیں',
    'terms_of_service': 'خدمات کی شرائط',
    'terms_of_service_desc': 'شرائط و ضوابط دیکھیں',
    'about_app': 'ایپ کے بارے میں',
    'app_version': 'ورژن 1.2.4',

    // Authentication
    'sign_out': 'سائن آؤٹ',
    'sign_out_confirm': 'کیا آپ واقعی سائن آؤٹ کرنا چاہتے ہیں؟',
    'sign_out_success': 'کامیابی سے سائن آؤٹ ہو گئے!',
    'sign_in': 'سائن ان',
    'sign_up': 'سائن اپ',

    // Home screen
    'todays_verse': 'آج کی آیت',
    'islamic_date': 'اسلامی تاریخ',
    'recent_topics': 'حالیہ مضامین',
    'see_all': 'سب دیکھیں',
    'failed_to_load_verse': 'آیت لوڈ کرنے میں ناکام',
    'failed_to_load_topics':
        'مضامین لوڈ کرنے میں ناکام، نمونہ ڈیٹا دکھا رہے ہیں',

    // Topics
    'all_topics': 'تمام مضامین',
    'search_topics': 'مضامین تلاش کریں...',
    'no_topics_found': 'کوئی مضمون نہیں ملا',
    'lessons': 'اسباق',
    'lesson': 'سبق',

    // Favorites
    'no_favorites_yet': 'ابھی تک کوئی پسندیدہ نہیں',
    'no_favorites_desc': 'آپ کے پسندیدہ اسباق یہاں نظر آئیں گے',
    'explore_topics': 'مضامین دریافت کریں',
    'favorite_lessons': 'پسندیدہ اسباق',
    'added_to_favorites': 'پسندیدہ میں شامل کیا گیا',
    'removed_from_favorites': 'پسندیدہ سے ہٹایا گیا',
    'failed_to_update_favorites': 'پسندیدہ اپڈیٹ کرنے میں ناکام',
    'clear_all_favorites': 'تمام پسندیدہ صاف کریں',
    'clear_all_favorites_confirm':
        'کیا آپ واقعی تمام اسباق کو پسندیدہ سے ہٹانا چاہتے ہیں؟',
    'all_favorites_cleared': 'تمام پسندیدہ صاف کر دیے گئے',

    // Video Player
    'related_lessons': 'متعلقہ اسباق',
    'download_reference': 'ریفرنس ڈاؤن لوڈ',
    'download_reference_material': 'ریفرنس میٹریل ڈاؤن لوڈ کریں',
    'no_reference_material': 'کوئی ریفرنس میٹریل دستیاب نہیں',
    'opening_reference_material': 'ریفرنس میٹریل کھولا جا رہا ہے',
    'cannot_open_reference': 'ریفرنس میٹریل نہیں کھول سکتے',
    'failed_to_open_reference': 'ریفرنس میٹریل کھولنے میں ناکام',
    'error_loading_video': 'ویڈیو لوڈ کرنے میں خرابی',
    'failed_to_load_video': 'ویڈیو لوڈ کرنے میں ناکام',
    'sharing_lesson': 'سبق شیئر کر رہے ہیں...',

    // Notifications
    'notification_details': 'اطلاع کی تفصیلات',
    'mark_all_read': 'سب کو پڑھا ہوا نشان زد کریں',
    'all_notifications_read': 'تمام اطلاعات کو پڑھا ہوا نشان زد کیا گیا',
    'back_to_list': 'فہرست میں واپس',
    'no_notifications': 'کوئی اطلاع نہیں',

    // Loading and errors
    'loading': 'لوڈ ہو رہا ہے...',
    'error': 'خرابی',
    'try_again': 'دوبارہ کوشش کریں',
    'coming_soon': 'جلد آ رہا ہے!',

    'english': 'انگریزی',
    'arabic': 'عربی',
    'urdu': 'اردو',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'ur'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
