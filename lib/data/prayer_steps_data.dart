import '../models/preyer_model.dart';

/// Global list of prayer steps with SVG icons, descriptions, and verses
final List<PrayerSliderItem> prayerSteps = [
  PrayerSliderItem(
    svgPath: 'assets/namaz/svg/takbeer.svg',
    title: 'Takbeer',
    urdu: 'دونوں ہاتھ کانوں کے پاس اٹھا کر کھڑا ہونا (اللہ اکبر کہتے ہوئے)',
    arabic: 'الوقوف مع رفع اليدين بجانب الأذنين (قائلاً "الله أكبر")',
    english: 'Standing with both hands raised near ears (saying "Allahu Akbar")',
    banner: 'assets/images/banners/takbeer.png',
    action: 'takbeer',
    audio: 'assets/audio/takbeer.mp3',
    verses: [
      'اللہ أكبر'
    ],
  ),
  PrayerSliderItem(
    svgPath: 'assets/namaz/svg/qeyam.svg',
    title: 'Qeyam',
    urdu: 'سینے پر ہاتھ باندھ کر کھڑا ہونا',
    arabic: 'الوقوف مع طي اليدين على الصدر',
    english: 'Standing with hands folded on the chest',
    banner: 'assets/images/banners/qeyam.png',
    action: 'qeyam',
    audio: 'assets/audio/qeyam.mp3',
    verses: [
      'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ وَتَبَارَكَ اسْمُكَ وَتَعَالَى جَدُّكَ وَلَا إِلَهَ غَيْرُكَ',
      'اعوذ بالله من الشيطان الرجيم',
      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      'الرَّحْمَٰنِ الرَّحِيمِ',
      'مَالِكِ يَوْمِ الدِّينِ',
      'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
      'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
      'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      'آمِينَ',
      'قُلْ هُوَ اللَّهُ أَحَدٌ',
      'اللَّهُ الصَّمَدُ',
      'لَمْ يَلِدْ وَلَمْ يُولَدْ',
      'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ'
    ],
  ),
  PrayerSliderItem(
    svgPath: 'assets/namaz/svg/allah-akbar.svg',
    title: 'Allah Akbar',
    urdu: 'اللہ اکبر کہتے ہوے رکوع میں جانا',
    arabic: 'الذهاب إلى الركوع مع قول "الله أكبر"',
    english: 'Going into Ruku while saying "Allahu Akbar"',
    banner: 'assets/images/banners/allah-akbar.png',
    action: 'allah-akbar',
    audio: 'assets/audio/allah-akbar.mp3',
    verses: [
      'الله أكبر'
    ],
  ),
  PrayerSliderItem(
    svgPath: 'assets/namaz/svg/rakuh.svg',
    title: 'Rakuh',
    urdu: 'دونوں ہاتھ گھٹنوں پر رکھ کر جھکنا (رکوع)',
    arabic: 'الركوع مع وضع اليدين على الركبتين',
    english: 'Bowing (bending at the waist)',
    banner: 'assets/images/banners/rakuh.png',
    action: 'rakuh',
    audio: 'assets/audio/rakuh.mp3',
    verses: [
      'سُبْحَانَ رَبِّيَ الْعَظِيمِ ',
      'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
      'سُبْحَانَ رَبِّيَ الْعَظِيمِ'
    ],
  ),
  
  PrayerSliderItem(
    svgPath: 'assets/namaz/svg/qauma.svg',
    title: 'Qauma',
    urdu: 'سیدھا کھڑا ہونا، ہاتھ آرام سے اطراف میں (قیام سے مختلف)',
    arabic: 'القيام بعد الركوع، اليدين مرتخيتين بجانب الجسم (مختلف عن القيام)',
    english: 'Standing straight again after bowing, hands relaxed at sides (distinct from Qiyam)',
    banner: 'assets/images/banners/qauma.png',
    action: 'qauma',
    audio: 'assets/audio/qauma.mp3',
    verses: [
      'سمیعَ اللَّهُ لِمَنْ حَمِدَهُ',
      'رَبَّنَا وَلَكَ الْحَمْدُ ']
  ),
  PrayerSliderItem(
    svgPath: 'assets/namaz/svg/allah-akbar.svg',
    title: 'Allah Akbar',
    urdu: 'اللہ اکبر کہتے ہوے پہلے سجدے کے لیے نیچے جانا',
    arabic: 'النزول للسجدة الأولى مع قول "الله أكبر"',
    english: 'Going down for the first prostration while saying "Allahu Akbar"',
    banner: 'assets/images/banners/allah-akbar.png',
    action: 'allah-akbar',
    audio: 'assets/audio/allah-akbar.mp3',
    verses: [
      'الله أكبر'
    ],
  ),
  PrayerSliderItem(
    svgPath: 'assets/namaz/svg/sajda.svg',
    title: 'First Sajda',
    urdu: 'سات اعضاء زمین سے لگائیں: پیشانی (ساتھ ناک)، دونوں ہاتھ، دونوں گھٹنے اور پاؤں کے انگوٹھے۔',
    arabic: 'وضع سبعة أعضاء على الأرض: الجبهة (مع الأنف)، واليدين، والركبتين، وأصابع القدمين الكبيرة',
    english: 'Placing seven body parts on the ground: forehead (with nose), both hands, both knees, and toes.',
    banner: 'assets/images/banners/sajda.png',
    action: 'sajda',
    audio: 'assets/audio/sajda.mp3',
    verses: [
      'سُبْحَانَ رَبِّيَ الْأَعْلَى ',
      'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      'سُبْحَانَ رَبِّيَ الْأَعْلَى'
    ],
  ),
  PrayerSliderItem(
    svgPath: 'assets/namaz/svg/allah-akbar.svg',
    title: 'Allah Akbar',
    urdu: 'اللہ اکبر کہتے ہوے ہاتھ گھٹنوں پر رکھ کر سیدھا بیٹھ جائیں',
    arabic: 'الجلوس مستقيماً مع وضع اليدين على الركبتين قائلاً "الله أكبر"',
    english: 'Sitting straight with hands on knees while saying "Allahu Akbar"',
    banner: 'assets/images/banners/allah-akbar.png',
    action: 'allah-akbar',
    audio: 'assets/audio/allah-akbar.mp3',
    verses: [
      'الله أكبر'
    ],
  ),
  PrayerSliderItem(
    svgPath: 'assets/namaz/svg/jalsa.svg',
    title: 'Jalsa',
    urdu: ' دو سجدوں کے درمیان بیٹھنا',
    arabic: 'الجلوس بين السجدتين',
    english: 'Sitting between two Sajdas',
    banner: 'assets/images/banners/jalsa.png',
    action: 'jalsa',
    audio: 'assets/audio/jalsa.mp3',
    verses: [
      ''
    ],
  ),
  PrayerSliderItem(
    svgPath: 'assets/namaz/svg/allah-akbar.svg',
    title: 'Allah Akbar',
    urdu: 'اللہ اکبر کہتے ہوے دوسرے سجدے کے لیے نیچے جانا',
    arabic: 'النزول للسجدة الثانية مع قول "الله أكبر"',
    english: 'Going down for the second prostration while saying "Allahu Akbar"',
    banner: 'assets/images/banners/allah-akbar.png',
    action: 'allah-akbar',
    audio: 'assets/audio/allah-akbar.mp3',
    verses: [
      'الله أكبر'
    ],
  ),
  PrayerSliderItem(
    svgPath: 'assets/namaz/svg/sajda.svg',
    title: 'Second Sajdah',
     urdu: 'سات اعضاء زمین سے لگائیں: پیشانی (ساتھ ناک)، دونوں ہاتھ، دونوں گھٹنے اور پاؤں کے انگوٹھے۔',
    arabic: 'وضع سبعة أعضاء على الأرض: الجبهة (مع الأنف)، واليدين، والركبتين، وأصابع القدمين الكبيرة',
    english: 'Placing seven body parts on the ground: forehead (with nose), both hands, both knees, and toes.',
     banner: 'assets/images/banners/sajda.png',
    action: 'sajda2',
    audio: 'assets/audio/sajda.mp3',
    verses: [
      'سُبْحَانَ رَبِّيَ الْأَعْلَى ',
      'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      'سُبْحَانَ رَبِّيَ الْأَعْلَى'
    ],
  ),
  PrayerSliderItem(
    svgPath: 'assets/namaz/svg/allah-akbar.svg',
    title: 'Allah Akbar',
    urdu: 'اللہ اکبر کہتے ہوئے تشہد کے لیے بیٹھ جائیں',
    arabic: 'الجلوس مستقيماً مع قول "الله أكبر"',
    english: 'Sitting straight while saying "Allahu Akbar"',
    banner: 'assets/images/banners/allah-akbar.png',
    action: 'allah-akbar',
    audio: 'assets/audio/allah-akbar.mp3',
    verses: [
      'الله أكبر'
    ],
  ),
  PrayerSliderItem(
    svgPath: 'assets/namaz/svg/tashud.svg',
    title: 'Tashahhud ',
    urdu: 'دو سجدوں کے بعد ہاتھ گھٹنوں پر رکھے بیٹھ کر مخصوص دعا پڑھنا ',
    arabic: 'الجلوس بعد السجدتين مع وضع اليدين على الركبتين وتلاوة التشهد المخصوص',
    english: 'Sitting after two prostrations with hands on knees and reciting the specific prayer (Tashahhud)',
    banner: 'assets/images/banners/tashud.png',
    action: 'tashud',
    audio: 'assets/audio/tashud.mp3',
    verses: [
      'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ',
      'السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ',
      'السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ',
      'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ',
      'وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
      'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
      'كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ',
      'إِنَّكَ حَمِيدٌ مَجِيدٌ',
      'اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
      'كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ',
      'إِنَّكَ حَمِيدٌ مَجِيدٌ',
      'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي رَبَّنَا وَتَقَبَّلْ دُعَاءِ',
      'رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
    ],
  ),
  PrayerSliderItem(
    svgPath: 'assets/namaz/svg/salam-right.svg',
    title: 'Salam Right ',
    urdu: 'دائیں جانب گردن موڑنا',
    arabic: 'تحويل الرقبة إلى الجانب الأيمن',
    english: 'Turning neck to the right side',
    banner: 'assets/images/banners/salam-right.png',
    action: 'salam-right',
    audio: 'assets/audio/salam-right.mp3',
    verses: [
      'السلام عليكم ورحمة الله وبركاته'
    ],
  ),
  PrayerSliderItem(
    svgPath: 'assets/namaz/svg/salam-left.svg',
    title: 'Salam Left ',
    urdu: 'بائیں جانب گردن موڑنا',
    arabic: 'تحويل الرقبة إلى الجانب الأيسر',
    english: 'Turning neck to the left side',
    banner: 'assets/images/banners/salam-left.png',
    action: 'salam-left',
    audio: 'assets/audio/salam-left.mp3',
    verses: [
      'السلام عليكم ورحمة الله وبركاته'
    ]
  ),
];
