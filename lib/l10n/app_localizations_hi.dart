// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Vethra';

  @override
  String get signInTitle => 'फिर से स्वागत है';

  @override
  String get signInSubtitle => 'अपना रेस्टोरेंट चलाने के लिए साइन इन करें।';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get signIn => 'साइन इन';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get showPassword => 'पासवर्ड दिखाएँ';

  @override
  String get hidePassword => 'पासवर्ड छिपाएँ';

  @override
  String get loginHeadline => 'ऑर्डर, किचन और पैसा — सब एक शांत जगह पर।';

  @override
  String get loginPointQr => 'टेबल QR ऑर्डरिंग';

  @override
  String get loginPointKitchen => 'लाइव शेफ़ कतारें';

  @override
  String get loginPointDashboards => 'रोज़ के डैशबोर्ड';

  @override
  String get yourProfile => 'आपकी प्रोफ़ाइल';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get alerts => 'अलर्ट';

  @override
  String get noAlerts => 'अभी आपके लिए कुछ नहीं है';

  @override
  String get close => 'बंद करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get save => 'सेव करें';

  @override
  String get saveChanges => 'बदलाव सेव करें';

  @override
  String get edit => 'बदलें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get more => 'और';

  @override
  String get add => 'जोड़ें';

  @override
  String get increase => 'बढ़ाएँ';

  @override
  String get decrease => 'घटाएँ';

  @override
  String get all => 'सभी';

  @override
  String get name => 'नाम';

  @override
  String get status => 'स्थिति';

  @override
  String get role => 'भूमिका';

  @override
  String get phone => 'फ़ोन';

  @override
  String get phoneOptional => 'फ़ोन (वैकल्पिक)';

  @override
  String get date => 'तारीख';

  @override
  String get type => 'प्रकार';

  @override
  String get reason => 'कारण';

  @override
  String get reasonAuditedHelp => 'ऑडिट लॉग में सेव होता है।';

  @override
  String get defaultReason => 'प्लेटफ़ॉर्म एडमिन ने बदला';

  @override
  String get tabOverview => 'सारांश';

  @override
  String get tabHotels => 'होटल';

  @override
  String get tabPlans => 'प्लान';

  @override
  String get tabFloor => 'फ़्लोर';

  @override
  String get tabKitchen => 'किचन';

  @override
  String get tabMenu => 'मेन्यू';

  @override
  String get tabTables => 'टेबल';

  @override
  String get tabTeam => 'टीम';

  @override
  String get tabExpenses => 'खर्चे';

  @override
  String goodMorning(String name) {
    return 'सुप्रभात, $name';
  }

  @override
  String goodAfternoon(String name) {
    return 'नमस्कार, $name';
  }

  @override
  String goodEvening(String name) {
    return 'शुभ संध्या, $name';
  }

  @override
  String get waiting => 'इंतज़ार में';

  @override
  String get cooking => 'बन रहे हैं';

  @override
  String get tablesBusy => 'भरी टेबल';

  @override
  String get servedToday => 'परोसे गए';

  @override
  String get ordersToday => 'आज के ऑर्डर';

  @override
  String get revenueToday => 'आज की कमाई';

  @override
  String get avgPrep => 'औसत तैयारी';

  @override
  String get thisMonth => 'इस महीने';

  @override
  String expensesAmount(String amount) {
    return 'खर्चे $amount';
  }

  @override
  String netAmount(String amount) {
    return 'शुद्ध $amount';
  }

  @override
  String get ordersByHour => 'घंटे के हिसाब से ऑर्डर';

  @override
  String get ordersSoFarToday => 'आज अब तक के ऑर्डर';

  @override
  String get openFloor => 'फ़्लोर खोलें';

  @override
  String get openKitchen => 'किचन खोलें';

  @override
  String get kitchenPace => 'किचन की रफ़्तार';

  @override
  String get avgPrepMinutes => 'बनाने के औसत मिनट';

  @override
  String chefsOnShift(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'शिफ़्ट पर $count शेफ़',
      one: 'शिफ़्ट पर 1 शेफ़',
    );
    return '$_temp0';
  }

  @override
  String cookingNow(int count) {
    return '$count बन रहे हैं';
  }

  @override
  String get servedShare => 'आज परोसे गए';

  @override
  String get liveOrders => 'लाइव ऑर्डर';

  @override
  String get noLiveOrders => 'कोई खुला ऑर्डर नहीं';

  @override
  String get topDishes => 'टॉप व्यंजन';

  @override
  String get chefs => 'शेफ़';

  @override
  String get avgTicket => 'औसत बिल';

  @override
  String get perOrderToday => 'आज प्रति ऑर्डर';

  @override
  String get noDataYet => 'अभी कोई डेटा नहीं';

  @override
  String get noChefsYet => 'अभी कोई शेफ़ नहीं जोड़ा';

  @override
  String soldCount(int count) {
    return '$count बिके';
  }

  @override
  String doneCount(int count) {
    return '$count पूरे';
  }

  @override
  String get revenueLast7Days => 'कमाई, पिछले 7 दिन';

  @override
  String get statusPlaced => 'पुष्टि का इंतज़ार';

  @override
  String get statusConfirmed => 'नया';

  @override
  String get statusQueued => 'कतार में';

  @override
  String get statusPreparing => 'बन रहा है';

  @override
  String get statusReady => 'तैयार';

  @override
  String get statusServed => 'परोसा गया';

  @override
  String get statusCancelled => 'रद्द';

  @override
  String get channelQr => 'QR';

  @override
  String get channelWaiter => 'सर्वर';

  @override
  String get channelAdmin => 'एडमिन';

  @override
  String orderNumberTable(int number, String table) {
    return '#$number · टेबल $table';
  }

  @override
  String tableLabel(String label) {
    return 'टेबल $label';
  }

  @override
  String minutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes मिनट पहले',
      one: '1 मिनट पहले',
      zero: 'अभी',
    );
    return '$_temp0';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes मि';
  }

  @override
  String get roleHotelAdmin => 'होटल एडमिन';

  @override
  String get roleManager => 'मैनेजर';

  @override
  String get roleCashier => 'कैशियर';

  @override
  String get roleWaiter => 'सर्वर';

  @override
  String get roleChef => 'शेफ़';

  @override
  String get rolePlatformAdmin => 'प्लेटफ़ॉर्म एडमिन';

  @override
  String get live => 'लाइव';

  @override
  String get reconnecting => 'फिर से जुड़ रहा है';

  @override
  String get staleBanner =>
      'कनेक्शन टूट गया। आख़िरी पता कतार दिखा रहे हैं; हर कुछ सेकंड में रिफ़्रेश होगा।';

  @override
  String get modeChefAccept => 'शेफ़ खुद उठाएँ';

  @override
  String get modeAutoAssign => 'अपने आप बाँटें';

  @override
  String get modeAdminPrint => 'प्रिंटेड टिकट';

  @override
  String get upForGrabs => 'नए ऑर्डर';

  @override
  String get waitingForChef => 'शेफ़ का इंतज़ार';

  @override
  String get noNewOrders => 'कोई नया ऑर्डर नहीं';

  @override
  String get noNewOrdersBody => 'नए ऑर्डर तुरंत यहाँ दिखते हैं।';

  @override
  String get pickUp => 'उठाएँ';

  @override
  String get pickedUp => 'यह ऑर्डर आपका है';

  @override
  String get myQueue => 'मेरी कतार';

  @override
  String get queueEmpty => 'आप खाली हैं। अगला ऑर्डर उठाएँ।';

  @override
  String get offShiftBody =>
      'आप शिफ़्ट पर नहीं हैं। ऑर्डर पाने के लिए चालू करें।';

  @override
  String get lockedUntilHead => 'आगे वाला ऑर्डर तैयार होने के बाद शुरू होगा';

  @override
  String get startCooking => 'बनाना शुरू करें';

  @override
  String get started => 'शुरू हुआ';

  @override
  String get markReady => 'तैयार मार्क करें';

  @override
  String get markedReady => 'तैयार मार्क किया। सर्वर को बता दिया गया।';

  @override
  String cookingFor(int minutes, int target) {
    return '$minutes मि से बन रहा है · लक्ष्य $target मि';
  }

  @override
  String waitingFor(int minutes) {
    return '$minutes मि से इंतज़ार';
  }

  @override
  String get otherChefs => 'दूसरे शेफ़';

  @override
  String get noOtherChefs => 'कोई दूसरा शेफ़ नहीं';

  @override
  String get idle => 'खाली';

  @override
  String get onShift => 'शिफ़्ट पर';

  @override
  String get offShift => 'शिफ़्ट पर नहीं';

  @override
  String get returnToBoard => 'बोर्ड पर वापस भेजें';

  @override
  String get readyToServe => 'परोसने के लिए तैयार';

  @override
  String get nothingWaiting => 'परोसने के लिए कुछ नहीं';

  @override
  String get serve => 'परोसें';

  @override
  String get needsAttention => 'ध्यान दें';

  @override
  String get allCalm => 'सब ठीक है। पुष्टि या परोसने के लिए कुछ नहीं।';

  @override
  String get markServed => 'परोसा गया';

  @override
  String get confirmOrder => 'पुष्टि करें';

  @override
  String get noTables => 'अभी कोई टेबल नहीं';

  @override
  String get noTablesBody => 'QR कोड प्रिंट करने के लिए टेबल जोड़ें।';

  @override
  String seats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सीटें',
      one: '1 सीट',
    );
    return '$_temp0';
  }

  @override
  String get seatsLabel => 'सीटें';

  @override
  String get inactive => 'बंद';

  @override
  String get free => 'खाली';

  @override
  String get openOrders => 'खुले ऑर्डर';

  @override
  String get cannotTakeOrders => 'आपकी भूमिका यहाँ ऑर्डर नहीं ले सकती।';

  @override
  String get searchMenu => 'मेन्यू में खोजें';

  @override
  String get kitchenNoteHint => 'किचन के लिए नोट (वैकल्पिक)';

  @override
  String get sendToKitchen => 'किचन भेजें';

  @override
  String get orderSent => 'ऑर्डर किचन भेज दिया';

  @override
  String get soldOut => 'ख़त्म';

  @override
  String get veg => 'वेज';

  @override
  String get nonVeg => 'नॉन-वेज';

  @override
  String get subtotal => 'उप-योग';

  @override
  String get tax => 'GST';

  @override
  String get serviceCharge => 'सर्विस चार्ज';

  @override
  String get total => 'कुल';

  @override
  String get addCategory => 'कैटेगरी जोड़ें';

  @override
  String get addItem => 'आइटम जोड़ें';

  @override
  String get editItem => 'आइटम बदलें';

  @override
  String get addCategoryFirst => 'पहले एक कैटेगरी जोड़ें';

  @override
  String get menuEmpty => 'आपका मेन्यू खाली है';

  @override
  String get menuEmptyBody => 'एक कैटेगरी जोड़ें, फिर अपने व्यंजन।';

  @override
  String get noMatches => 'कुछ नहीं मिला';

  @override
  String get category => 'कैटेगरी';

  @override
  String get price => 'दाम';

  @override
  String get prepTime => 'तैयारी का समय';

  @override
  String get availability => 'उपलब्धता';

  @override
  String get available => 'उपलब्ध';

  @override
  String get priceRupees => 'दाम (₹)';

  @override
  String get priceHelp =>
      'टैक्स से पहले। रजिस्टर्ड हैं तो GST अपने आप जुड़ जाएगा।';

  @override
  String get descriptionOptional => 'विवरण (वैकल्पिक)';

  @override
  String get addTable => 'टेबल जोड़ें';

  @override
  String get tableName => 'टेबल का नाम';

  @override
  String get tableNameHelp => 'छोटा और अलग, जैसे T1 या P2।';

  @override
  String get areaOptional => 'जगह (वैकल्पिक)';

  @override
  String get copyLink => 'लिंक कॉपी करें';

  @override
  String get openDinerView => 'ग्राहक व्यू खोलें';

  @override
  String get rotateQr => 'QR कोड बदलें';

  @override
  String get deactivate => 'बंद करें';

  @override
  String get activate => 'चालू करें';

  @override
  String get qrActive => 'QR चालू';

  @override
  String openOrdersCount(int count) {
    return '$count खुले';
  }

  @override
  String get linkCopied => 'लिंक कॉपी हो गया';

  @override
  String get qrRotated =>
      'नया QR बन गया। इसे प्रिंट करें; पुराना अब काम नहीं करेगा।';

  @override
  String get people => 'लोग';

  @override
  String get rolesAndAccess => 'भूमिकाएँ और अनुमति';

  @override
  String get searchPeople => 'नाम या भूमिका से खोजें';

  @override
  String get addMember => 'सदस्य जोड़ें';

  @override
  String get newRole => 'नई भूमिका';

  @override
  String get newRoleLocked => 'कस्टम भूमिकाएँ (अपग्रेड)';

  @override
  String get newRoleHelp => 'फिर टिक करें कि यह भूमिका क्या कर सकती है।';

  @override
  String get permission => 'अनुमति';

  @override
  String get adminLocked => 'होटल एडमिन के पास हमेशा सारी अनुमतियाँ होती हैं';

  @override
  String get disabled => 'बंद';

  @override
  String get active => 'चालू';

  @override
  String makeRole(String role) {
    return '$role बनाएँ';
  }

  @override
  String get disableAccount => 'खाता बंद करें';

  @override
  String get enableAccount => 'खाता चालू करें';

  @override
  String get emailLoginHelp => 'वे इसी ईमेल से साइन इन करेंगे।';

  @override
  String get tempPassword => 'अस्थायी पासवर्ड';

  @override
  String get tempPasswordHelp => 'कम से कम 8 अक्षर। निजी रूप से बताएँ।';

  @override
  String get sendInvite => 'सदस्य जोड़ें';

  @override
  String get permDashboard => 'डैशबोर्ड देखना';

  @override
  String get permOrderView => 'ऑर्डर देखना';

  @override
  String get permOrderCreate => 'ऑर्डर लेना';

  @override
  String get permOrderConfirm => 'QR ऑर्डर की पुष्टि';

  @override
  String get permOrderServe => 'परोसा गया मार्क करना';

  @override
  String get permOrderCancel => 'ऑर्डर रद्द करना';

  @override
  String get permKitchenCook => 'उठाना और बनाना';

  @override
  String get permKitchenManage => 'शेफ़ कतार संभालना';

  @override
  String get permTableManage => 'टेबल और QR संभालना';

  @override
  String get permMenuManage => 'मेन्यू और दाम बदलना';

  @override
  String get permMenuAvailability => 'आइटम ख़त्म मार्क करना';

  @override
  String get permStaffManage => 'स्टाफ़ संभालना';

  @override
  String get permRoleManage => 'भूमिकाएँ सेट करना';

  @override
  String get permExpenseView => 'खर्चे देखना';

  @override
  String get permExpenseManage => 'खर्चे दर्ज करना';

  @override
  String get permReportView => 'रिपोर्ट देखना';

  @override
  String get permSettingsManage => 'सेटिंग्स और बिलिंग';

  @override
  String get addExpense => 'खर्चा जोड़ें';

  @override
  String get editExpense => 'खर्चा बदलें';

  @override
  String get previousMonth => 'पिछला महीना';

  @override
  String get nextMonth => 'अगला महीना';

  @override
  String get spentThisMonth => 'इस महीने का खर्च';

  @override
  String get byDay => 'दिन के हिसाब से';

  @override
  String get noExpenses => 'इस महीने कोई खर्चा नहीं';

  @override
  String get noExpensesBody => 'गैस, राशन, तनख़्वाह वगैरह दर्ज करें।';

  @override
  String get amountRupees => 'रकम (₹)';

  @override
  String get paidBy => 'भुगतान का तरीका';

  @override
  String get payCash => 'नकद';

  @override
  String get payUpi => 'UPI';

  @override
  String get payCard => 'कार्ड';

  @override
  String get payBank => 'बैंक';

  @override
  String get vendorOptional => 'विक्रेता (वैकल्पिक)';

  @override
  String get noteOptional => 'नोट (वैकल्पिक)';

  @override
  String get kitchenAndOrdering => 'किचन';

  @override
  String get planAndBilling => 'प्लान और बिलिंग';

  @override
  String get restaurantName => 'रेस्टोरेंट का नाम';

  @override
  String get kitchenMode => 'ऑर्डर शेफ़ तक कैसे पहुँचें';

  @override
  String get kitchenModeHelp => 'लॉक विकल्पों के लिए बड़ा प्लान चाहिए।';

  @override
  String get maxQueue => 'एक शेफ़ के पास एक साथ ऑर्डर';

  @override
  String get maxQueueHelp => 'किसी शेफ़ की कतार में इससे ज़्यादा नहीं होंगे।';

  @override
  String get confirmQrOrders => 'पहले QR ऑर्डर की पुष्टि करें';

  @override
  String get confirmQrOrdersHelp =>
      'किचन से पहले सर्वर टेबल के ऑर्डर मंज़ूर करेगा।';

  @override
  String get subActive => 'चालू';

  @override
  String get subTrial => 'ट्रायल';

  @override
  String get subPastDue => 'भुगतान बाकी';

  @override
  String get subSuspended => 'रोका गया';

  @override
  String perMonth(String amount) {
    return '$amount / महीना';
  }

  @override
  String get perMonthShort => '/ महीना';

  @override
  String trialEndsOn(String date) {
    return 'ट्रायल ख़त्म $date';
  }

  @override
  String renewsOn(String date) {
    return 'नवीनीकरण $date';
  }

  @override
  String get choosePlan => 'प्लान चुनें';

  @override
  String get choosePlanHelp =>
      'भुगतान Razorpay पर सुरक्षित होगा। भुगतान होते ही प्लान चालू हो जाएगा।';

  @override
  String get paymentsNotConfigured =>
      'ऑनलाइन भुगतान अभी चालू नहीं है। चालू करने के लिए सपोर्ट से संपर्क करें।';

  @override
  String get payAndActivate => 'भुगतान करें और चालू करें';

  @override
  String get renew => 'नवीनीकरण करें';

  @override
  String get payments => 'भुगतान';

  @override
  String get managePlan => 'प्लान संभालें';

  @override
  String get bannerPastDue =>
      'आपका भुगतान बाकी है। रुकावट से बचने के लिए अभी भुगतान करें।';

  @override
  String get bannerSuspended =>
      'आपका खाता रोका गया है। डेटा देख सकते हैं; ऑर्डर फिर शुरू करने के लिए भुगतान करें।';

  @override
  String get hotels => 'होटल';

  @override
  String get mrr => 'मासिक कमाई';

  @override
  String get orders30d => 'ऑर्डर (30 दिन)';

  @override
  String get collected30d => 'वसूली, पिछले 30 दिन';

  @override
  String trialsEnding(int count) {
    return 'इस हफ़्ते $count ट्रायल ख़त्म';
  }

  @override
  String get signups => 'नए होटल';

  @override
  String get planMix => 'प्लान बँटवारा';

  @override
  String get recentHotels => 'हाल के होटल';

  @override
  String get noHotels => 'अभी कोई होटल नहीं';

  @override
  String get noHotelsBody => 'शुरू करने के लिए पहला होटल रजिस्टर करें।';

  @override
  String get searchHotels => 'होटल खोजें';

  @override
  String get registerHotel => 'होटल रजिस्टर करें';

  @override
  String get hotelRegistered => 'होटल रजिस्टर हो गया। एडमिन लॉगिन उन्हें दें।';

  @override
  String get hotel => 'होटल';

  @override
  String get plan => 'प्लान';

  @override
  String get city => 'शहर';

  @override
  String get tablesCol => 'टेबल';

  @override
  String get hotelName => 'होटल का नाम';

  @override
  String get trialHelp => 'हर नया होटल मुफ़्त ट्रायल से शुरू होता है।';

  @override
  String get gstRegistration => 'GST रजिस्ट्रेशन';

  @override
  String get gstRegular => 'रेगुलर';

  @override
  String get gstComposition => 'कंपोज़िशन';

  @override
  String get gstUnregistered => 'रजिस्टर्ड नहीं';

  @override
  String get gstin => 'GSTIN';

  @override
  String get hotelAdmin => 'होटल एडमिन';

  @override
  String get suspendHotel => 'रोकें';

  @override
  String get resumeHotel => 'फिर चालू करें';

  @override
  String get changePlan => 'प्लान बदलें';

  @override
  String get overrides => 'फ़ीचर ओवरराइड';

  @override
  String get overridesHelp =>
      'प्लान से अलग, सिर्फ़ इस होटल के लिए कोई फ़ीचर चालू/बंद करें।';

  @override
  String get overridden => 'इस होटल के लिए बदला गया';

  @override
  String get fromPlan => 'प्लान से';

  @override
  String get placeholderPrice => 'अस्थायी';

  @override
  String get editPrice => 'दाम बदलें';

  @override
  String get monthlyPrice => 'मासिक दाम (₹)';

  @override
  String get priceChangeHelp =>
      'नई सदस्यता पर लागू। मौजूदा होटल नवीनीकरण तक पुराने दाम पर रहेंगे।';

  @override
  String get features => 'फ़ीचर';

  @override
  String get limits => 'सीमाएँ';

  @override
  String get limit => 'सीमा';

  @override
  String get limitHelp => 'असीमित के लिए खाली छोड़ें।';

  @override
  String get unlimited => 'असीमित';

  @override
  String get featQr => 'QR ऑर्डरिंग';

  @override
  String get featWaiter => 'सर्वर ऑर्डरिंग';

  @override
  String get featChefAccept => 'शेफ़ खुद ऑर्डर उठाएँ';

  @override
  String get featAutoRouting => 'शेफ़ को अपने आप बाँटें';

  @override
  String get featAdminPrint => 'प्रिंटेड किचन टिकट';

  @override
  String get featExpenses => 'खर्चे';

  @override
  String get featCustomRoles => 'कस्टम भूमिकाएँ';

  @override
  String get featReports => 'एडवांस रिपोर्ट';

  @override
  String get featRatings => 'रेटिंग';

  @override
  String get featApi => 'API और वेबहुक';

  @override
  String get featRooms => 'कमरे';

  @override
  String get limOutlets => 'आउटलेट';

  @override
  String get limTables => 'टेबल';

  @override
  String get limStaff => 'स्टाफ़';

  @override
  String get limChefs => 'शेफ़';

  @override
  String get limMenuItems => 'मेन्यू आइटम';

  @override
  String get limOrders => 'हर महीने ऑर्डर';

  @override
  String get qrInvalid => 'यह QR कोड काम नहीं कर रहा';

  @override
  String get qrInvalidBody => 'कृपया सर्वर से मदद लें।';

  @override
  String get dinerHeadline => 'आप क्या लेंगे?';

  @override
  String get dinerViewOnly => 'मेन्यू देखें और तैयार होने पर सर्वर को बताएँ।';

  @override
  String get yourOrder => 'आपका ऑर्डर';

  @override
  String get yourOrders => 'आपके ऑर्डर';

  @override
  String get stepSent => 'भेजा गया';

  @override
  String get dinerNoteHint => 'किचन को कुछ बताना है?';

  @override
  String get pricesByRestaurant => 'दाम और टैक्स रेस्टोरेंट तय करता है।';

  @override
  String get placeOrder => 'ऑर्डर करें';

  @override
  String get orderPlaced => 'ऑर्डर हो गया। अपडेट यहीं दिखेंगे।';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम',
      one: '1 आइटम',
    );
    return '$_temp0';
  }

  @override
  String get viewOrder => 'ऑर्डर देखें';

  @override
  String chefPreparing(String name) {
    return '$name बना रहे हैं';
  }

  @override
  String get readyOnItsWay => 'तैयार! आपकी टेबल पर आ रहा है।';

  @override
  String get printKot => 'KOT प्रिंट';

  @override
  String printKotTitle(int number) {
    return 'KOT #$number प्रिंट';
  }

  @override
  String get printKotExplain =>
      'क्या किचन इस ऑर्डर को कागज़ से बना रहा है? कागज़ पर भेजने से यह शेफ़ की स्क्रीन से हट जाएगा, ताकि कोई इसे दोबारा न उठाए।';

  @override
  String get printAndSend => 'प्रिंट करके किचन भेजें';

  @override
  String get printCopyOnly => 'सिर्फ़ कॉपी प्रिंट करें';

  @override
  String get kotPrinted => 'KOT प्रिंट हुआ';

  @override
  String get kotSentOnPaper => 'KOT प्रिंट हुआ। ऑर्डर अब कागज़ पर किचन में है।';

  @override
  String get onPaper => 'कागज़ पर';

  @override
  String get onPaperTitle => 'कागज़ से बन रहे';

  @override
  String get onPaperHelp =>
      'किचन को दिए गए प्रिंटेड टिकट। खाना बाहर आते ही तैयार मार्क करें।';

  @override
  String get billTable => 'बिल';

  @override
  String billForTable(String label) {
    return 'बिल · टेबल $label';
  }

  @override
  String get billExplain =>
      'इस टेबल के सभी बिना-बिल ऑर्डर का एक बिल बनेगा। बिल पर नंबर होता है और बदला नहीं जा सकता।';

  @override
  String get createBill => 'बिल बनाएँ';

  @override
  String notServedYet(String orders) {
    return 'अभी परोसे नहीं: #$orders';
  }

  @override
  String get billAnyway => 'फिर भी बिल बनाएँ';

  @override
  String billPaid(String method) {
    return 'भुगतान हुआ · $method';
  }

  @override
  String get billUnpaid => 'भुगतान बाकी';

  @override
  String ordersIncluded(String orders) {
    return 'ऑर्डर #$orders';
  }

  @override
  String get cgst => 'CGST';

  @override
  String get sgst => 'SGST';

  @override
  String get printBill => 'बिल प्रिंट';

  @override
  String get printDuplicate => 'डुप्लिकेट प्रिंट';

  @override
  String get billPrinted => 'बिल प्रिंट हुआ';

  @override
  String get settlePayment => 'भुगतान मिला';

  @override
  String get voidBill => 'बिल रद्द करें';

  @override
  String get printerSetup => 'प्रिंटर सेटअप';

  @override
  String get paperSize => 'कागज़';

  @override
  String get paperSizeHelp =>
      'अपने प्रिंटर के रोल जैसा चुनें। ऑफ़िस प्रिंटर के लिए A4।';

  @override
  String get paper58 => '58 mm';

  @override
  String get paper80 => '80 mm';

  @override
  String get paperA4 => 'A4';

  @override
  String get printWith => 'किससे प्रिंट करें';

  @override
  String get printSystem => 'प्रिंट डायलॉग';

  @override
  String get printNetwork => 'नेटवर्क प्रिंटर';

  @override
  String get printSystemHelp =>
      'इस डिवाइस से चलने वाले किसी भी प्रिंटर पर: थर्मल, लेज़र, इंकजेट, ब्लूटूथ या USB।';

  @override
  String get printNetworkHelp =>
      'Wi-Fi/LAN थर्मल प्रिंटर पर सीधे भेजता है। कोई डायलॉग नहीं; किचन के लिए सबसे तेज़।';

  @override
  String get printWebHelp =>
      'ब्राउज़र में प्रिंट हमेशा प्रिंट डायलॉग खोलता है। नेटवर्क प्रिंटर पर सीधे प्रिंट के लिए Android या iPhone ऐप इस्तेमाल करें।';

  @override
  String get printerIp => 'प्रिंटर का IP पता';

  @override
  String get port => 'पोर्ट';

  @override
  String get testPrint => 'टेस्ट प्रिंट';

  @override
  String get testPrintTitle => 'TEST PRINT';

  @override
  String get testPrintBody => 'If you can read this, the printer works.';

  @override
  String get soundAlertsOn => 'साउंड अलर्ट: चालू';

  @override
  String get soundAlertsOff => 'साउंड अलर्ट: बंद';

  @override
  String get soundOn => 'साउंड अलर्ट चालू';

  @override
  String get soundOff => 'साउंड अलर्ट बंद';

  @override
  String get testSound => 'अलर्ट साउंड टेस्ट';

  @override
  String get soundBlocked =>
      'ब्राउज़र ने आवाज़ रोक दी। पेज पर कहीं भी टैप करके फिर कोशिश करें।';

  @override
  String get serviceTimes => 'सर्विस का समय';

  @override
  String get serviceTimesHelp =>
      'आज के ऑर्डर। p90 = 10 में से 9 ऑर्डर इससे जल्दी हुए।';

  @override
  String get stageWait => 'शेफ़ का इंतज़ार';

  @override
  String get stageWaitHelp => 'ऑर्डर की पुष्टि → बनना शुरू';

  @override
  String get stagePrep => 'तैयारी';

  @override
  String get stagePrepHelp => 'बनना शुरू → तैयार';

  @override
  String get stageServe => 'परोसना';

  @override
  String get stageServeHelp => 'तैयार → टेबल पर';

  @override
  String get stageTotal => 'ऑर्डर से टेबल तक';

  @override
  String get stageTotalHelp => 'मेहमान को जो लगता है';

  @override
  String get minAvg => 'मि औसत';

  @override
  String p90Line(String minutes, int count) {
    return 'p90 $minutes मि · $count ऑर्डर';
  }

  @override
  String get servingByServer => 'सर्वर के हिसाब से परोसने का समय';

  @override
  String serverServeLine(String name, String minutes, int count) {
    return '$name: $minutes मि · $count परोसे';
  }

  @override
  String get categories => 'कैटेगरी';

  @override
  String get expenseCategories => 'खर्चों की कैटेगरी';

  @override
  String get categoriesHelp =>
      'ग्लोबल कैटेगरी हर होटल के लिए होती हैं। बाकी के लिए अपनी जोड़ें; वे सिर्फ़ आपके होटल को दिखेंगी।';

  @override
  String get scopeGlobal => 'ग्लोबल';

  @override
  String get scopeHotel => 'आपकी';

  @override
  String get renameCategory => 'कैटेगरी का नाम बदलें';

  @override
  String get addOwnCategory => 'अपनी कैटेगरी जोड़ें';

  @override
  String get addOwnCategoryHelp => 'सिर्फ़ आपके होटल को दिखेगी।';

  @override
  String get tabCategories => 'कैटेगरी';

  @override
  String get globalCategoriesHelp =>
      'यहाँ की कैटेगरी तुरंत हर होटल को दिखती हैं। किसी को बंद करने से वह नए खर्चों में नहीं दिखेगी; पुराने खर्चों में बनी रहेगी।';

  @override
  String get newGlobalCategory => 'नई ग्लोबल कैटेगरी';

  @override
  String get globalCategoryAdded => 'हर होटल के लिए जुड़ गई';

  @override
  String usedTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बार इस्तेमाल',
      one: 'एक बार इस्तेमाल',
      zero: 'इस्तेमाल नहीं',
    );
    return '$_temp0';
  }

  @override
  String get printQr => 'QR प्रिंट';

  @override
  String get printAllQr => 'सभी QR कोड प्रिंट';

  @override
  String get enableAlerts => 'अलर्ट चालू करें';

  @override
  String get enableAlertsBody =>
      'नए और तैयार ऑर्डर के लिए तेज़ अलर्ट चालू करें। तेज़ आवाज़ के लिए यह टैब खुला रखें; टैब बंद होने पर सामान्य नोटिफ़िकेशन आएगा।';

  @override
  String get enableAlertsDenied =>
      'आपके ब्राउज़र की सेटिंग्स में इस साइट के नोटिफ़िकेशन बंद हैं। पेज पर तेज़ आवाज़ के लिए टैप करें; यह टैब खुला रखें।';

  @override
  String get notNow => 'अभी नहीं';

  @override
  String get language => 'भाषा';

  @override
  String get langEn => 'English';

  @override
  String get langTe => 'తెలుగు';

  @override
  String get langHi => 'हिन्दी';

  @override
  String get branding => 'ब्रांडिंग';

  @override
  String get hotelLogo => 'होटल लोगो';

  @override
  String get hotelLogoHelp =>
      'ऐप में दिखता है और टेबल QR कार्ड पर छपता है। PNG या JPEG।';

  @override
  String get uploadLogo => 'लोगो अपलोड करें';

  @override
  String get replaceLogo => 'लोगो बदलें';

  @override
  String get removeLogo => 'हटाएँ';

  @override
  String get logoUpdated => 'लोगो अपडेट हो गया';

  @override
  String get addressLine => 'पता (एक लाइन)';

  @override
  String get addressLineHelp => 'QR कार्ड पर होटल के नाम के नीचे छपता है।';

  @override
  String get poweredByNote =>
      'QR कार्ड के आख़िर में प्लेटफ़ॉर्म की छोटी \"Powered by\" लाइन होती है।';

  @override
  String get errGeneric => 'कुछ गड़बड़ हो गई। कृपया फिर कोशिश करें।';

  @override
  String get errOffline => 'आप ऑफ़लाइन हैं। कनेक्शन देखकर फिर कोशिश करें।';

  @override
  String get errCredentials => 'ईमेल या पासवर्ड ग़लत है।';

  @override
  String get errFeatureLocked =>
      'आपके प्लान में यह नहीं है। खोलने के लिए अपग्रेड करें।';

  @override
  String get errLimit => 'आप अपने प्लान की सीमा तक पहुँच गए हैं।';

  @override
  String get errPermission => 'आपकी भूमिका को इसकी अनुमति नहीं है।';

  @override
  String get errTaken => 'यह ऑर्डर दूसरे शेफ़ ने पहले ही उठा लिया।';

  @override
  String get errQueueFull => 'दूसरा उठाने से पहले एक ऑर्डर पूरा करें।';

  @override
  String get errNotHead => 'पहले इससे आगे वाला ऑर्डर पूरा करें।';

  @override
  String get errSoldOut => 'एक आइटम अभी ख़त्म हुआ। कृपया अपना ऑर्डर बदलें।';

  @override
  String get errSessionExpired =>
      'आपका टेबल सेशन ख़त्म हो गया। QR फिर से स्कैन करें।';

  @override
  String get errRequired => 'ज़रूरी';

  @override
  String get errEmail => 'सही ईमेल डालें';

  @override
  String get errAmount => '250 या 99.50 जैसी रकम डालें';

  @override
  String get errPasswordLength => 'कम से कम 8 अक्षर';

  @override
  String get errGstin => '15 अक्षर का GSTIN डालें';
}
