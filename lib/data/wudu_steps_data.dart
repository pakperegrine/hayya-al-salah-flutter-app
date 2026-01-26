import '../models/wudu_model.dart';

/// Global list of wudu steps with video paths, descriptions, and verses
final List<WuduSliderItem> wuduSteps = [
  WuduSliderItem(
    videoPath:
        'https://salah.imtiazkausar.org.pk/uploads/videos/wudu/niyyah.mp4',
    title: 'Niyyah (Intention)',
    urdu: 'نیت کریں کہ میں وضو کر رہا ہوں اللہ کی رضا کے لیے',
    arabic: 'النية: أن تنوي في قلبك أنك تتوضأ لطاعة الله',
    english:
        'Make the intention in your heart that you are performing wudu for the sake of Allah',
    banner: 'assets/images/banners/niyyah.png',
    action: 'niyyah',
    verses: [
      'بِسْمِ اللَّهِ',
    ],
  ),
  WuduSliderItem(
    videoPath:
        'https://salah.imtiazkausar.org.pk/uploads/videos/wudu/wash_hands.mp4',
    title: 'Wash Hands',
    urdu: 'دونوں ہاتھوں کو کلائیوں تک تین بار دھوئیں',
    arabic: 'غسل اليدين إلى الرسغين ثلاث مرات',
    english: 'Wash both hands up to the wrists three times',
    banner: 'assets/images/banners/wash_hands.png',
    action: 'wash_hands',
    verses: [''],
  ),
  WuduSliderItem(
    videoPath:
        'https://salah.imtiazkausar.org.pk/uploads/videos/wudu/rinse_mouth.mp4',
    title: 'Rinse Mouth',
    urdu: 'منہ میں پانی ڈال کر کلی کریں تین بار',
    arabic: 'المضمضة ثلاث مرات',
    english: 'Rinse the mouth thoroughly three times',
    banner: 'assets/images/banners/rinse_mouth.png',
    action: 'rinse_mouth',
    verses: [''],
  ),
  WuduSliderItem(
    videoPath:
        'https://salah.imtiazkausar.org.pk/uploads/videos/wudu/sniff_water.mp4',
    title: 'Sniff Water into Nose',
    urdu: 'ناک میں پانی چڑھائیں اور صاف کریں تین بار',
    arabic: 'الاستنشاق والاستنثار ثلاث مرات',
    english: 'Sniff water into the nose and blow it out three times',
    banner: 'assets/images/banners/sniff_water.png',
    action: 'sniff_water',
    verses: [
      '',
    ],
  ),
  WuduSliderItem(
    videoPath:
        'https://salah.imtiazkausar.org.pk/uploads/videos/wudu/wash_face_1.mp4',
    title: 'Wash Face',
    urdu:
        'چہرے کو تین بار دھوئیں (پیشانی سے ٹھوڑی تک، ایک کان سے دوسرے کان تک)',
    arabic: 'غسل الوجه ثلاث مرات من منابت الشعر إلى الذقن ومن الأذن إلى الأذن',
    english:
        'Wash the face three times (from forehead to chin, from ear to ear)',
    banner: 'assets/images/banners/wash_face.png',
    action: 'wash_face',
    verses: [
      '',
    ],
  ),
  WuduSliderItem(
    videoPath:
        'https://salah.imtiazkausar.org.pk/uploads/videos/wudu/wash_arms.mp4',
    title: 'Wash Arms',
    urdu: 'دائیں ہاتھ کو کہنی تک تین بار دھوئیں، پھر بائیں ہاتھ کو',
    arabic: 'غسل اليد اليمنى إلى المرفق ثلاث مرات، ثم اليسرى',
    english: 'Wash the right arm up to the elbow three times, then the left',
    banner: 'assets/images/banners/wash_arms.png',
    action: 'wash_arms',
    verses: [
      '',
    ],
  ),
  WuduSliderItem(
    videoPath:
        'https://salah.imtiazkausar.org.pk/uploads/videos/wudu/wipe_head_1.mp4',
    title: 'Wipe Head',
    urdu: 'سر کا مسح کریں ایک بار (گیلے ہاتھوں سے)',
    arabic: 'مسح الرأس مرة واحدة',
    english: 'Wipe the head once with wet hands',
    banner: 'assets/images/banners/wipe_head.png',
    action: 'wipe_head',
    verses: [
      '',
    ],
  ),
  WuduSliderItem(
    videoPath:
        'https://salah.imtiazkausar.org.pk/uploads/videos/wudu/wash_feet_1.mp4',
    title: 'Wash Feet',
    urdu: 'دائیں پاؤں کو ٹخنوں تک تین بار دھوئیں، پھر بائیں پاؤں کو',
    arabic: 'غسل القدم اليمنى إلى الكعبين ثلاث مرات، ثم اليسرى',
    english: 'Wash the right foot up to the ankles three times, then the left',
    banner: 'assets/images/banners/wash_feet.png',
    action: 'wash_feet',
    verses: [
      '',
    ],
  ),
  WuduSliderItem(
    videoPath:
        'https://salah.imtiazkausar.org.pk/uploads/videos/wudu/completion_dua.mp4',
    title: 'Completion Dua',
    urdu: 'وضو مکمل کرنے کے بعد کی دعا پڑھیں',
    arabic: 'دعاء ما بعد الوضوء',
    english: 'Recite the dua after completing wudu',
    banner: 'assets/images/banners/completion_dua.png',
    action: 'completion_dua',
    verses: [''],
  ),
];
