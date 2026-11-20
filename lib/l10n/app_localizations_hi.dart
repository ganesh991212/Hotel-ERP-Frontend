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

  @override
  String get settingsSaved => 'सेटिंग्स सेव हो गईं';

  @override
  String get brandingSaved => 'ब्रांडिंग सेव हो गई';

  @override
  String get nextConfirm => 'अगला: यह ऑर्डर कन्फ़र्म करें';

  @override
  String get nextChefPickup => 'अगला: किचन स्क्रीन पर कोई शेफ़ इसे लेगा';

  @override
  String get nextFreeChef => 'अगला: खाली शेफ़ का इंतज़ार';

  @override
  String get nextPrintKot => 'अगला: किचन के लिए KOT प्रिंट करें';

  @override
  String nextChefStarts(String chef) {
    return 'अगला: $chef खाना बनाना शुरू करेंगे';
  }

  @override
  String nowCooking(String chef) {
    return '$chef बना रहे हैं';
  }

  @override
  String get nowCookingPaper =>
      'प्रिंटेड KOT से बन रहा है। तैयार होने पर \'तैयार\' दबाएँ';

  @override
  String get nextServe => 'अगला: टेबल पर परोसें';

  @override
  String get nextBill => 'अगला: टेबल का बिल बनाएँ';

  @override
  String get notPickedUp => 'समय पर किसी ने नहीं लिया';

  @override
  String pickupOverdueToast(int number, String place) {
    return 'ऑर्डर #$number ($place) अभी तक किसी ने नहीं लिया';
  }

  @override
  String get billPending => 'बिल बाकी';

  @override
  String get billNow => 'बिल';

  @override
  String get tabOrders => 'ऑर्डर';

  @override
  String get ordersToday2 => 'आज';

  @override
  String get noOrdersYet => 'अभी कोई ऑर्डर नहीं';

  @override
  String get billed => 'बिल बना';

  @override
  String get servingMode => 'खाना टेबल तक कैसे पहुँचता है';

  @override
  String get serveByWaiter => 'वेटर परोसता है';

  @override
  String get serveAtCounter => 'ग्राहक काउंटर से लेता है';

  @override
  String get servingModeHelp =>
      'काउंटर: तैयार होने पर ग्राहक को लेने के लिए कहा जाता है; \'परोसा\' वाला कदम नहीं होता।';

  @override
  String get pickupAlert => 'इतने समय में शेफ़ न ले तो अलर्ट';

  @override
  String get pickupAlertHelp =>
      'एडमिन और शिफ़्ट पर मौजूद शेफ़ को तेज़ अलर्ट मिलता है।';

  @override
  String get off => 'बंद';

  @override
  String get collectAtCounter => 'तैयार! कृपया काउंटर से ले लें।';

  @override
  String get changePassword => 'पासवर्ड बदलें';

  @override
  String get currentPassword => 'मौजूदा पासवर्ड';

  @override
  String get newPassword => 'नया पासवर्ड';

  @override
  String get confirmNewPassword => 'नया पासवर्ड फिर से लिखें';

  @override
  String get passwordsDontMatch => 'दोनों नए पासवर्ड मेल नहीं खाते';

  @override
  String get passwordChanged =>
      'पासवर्ड बदल गया। दूसरे डिवाइस से साइन आउट हो गया।';

  @override
  String get errWrongPassword => 'मौजूदा पासवर्ड गलत है';

  @override
  String get errSamePassword => 'कोई दूसरा पासवर्ड चुनें';

  @override
  String get resetPassword => 'पासवर्ड रीसेट';

  @override
  String resetPasswordFor(String name) {
    return '$name का पासवर्ड रीसेट';
  }

  @override
  String get resetPasswordHelp =>
      'वे हर डिवाइस से साइन आउट हो जाएँगे। नया पासवर्ड उन्हें खुद दें; वे प्रोफ़ाइल से बदल सकते हैं।';

  @override
  String passwordResetDone(String name) {
    return '$name का पासवर्ड रीसेट हो गया';
  }

  @override
  String get periodToday => 'आज';

  @override
  String get periodWeek => 'पिछले 7 दिन';

  @override
  String get myCooking => 'आपकी कुकिंग';

  @override
  String get myServing => 'आपकी सर्विंग';

  @override
  String get myBilling => 'आपकी बिलिंग';

  @override
  String get statOrdersCooked => 'बनाए गए ऑर्डर';

  @override
  String get statItemsCooked => 'बनाए गए आइटम';

  @override
  String get statAvgCook => 'औसत कुकिंग समय';

  @override
  String get statAvgWaitStart => 'शुरू होने तक इंतज़ार';

  @override
  String get statInQueue => 'अभी आपकी कतार में';

  @override
  String get statOrdersServed => 'परोसे गए ऑर्डर';

  @override
  String get statTablesServed => 'सर्व की गई टेबल';

  @override
  String get statAvgServe => 'तैयार से टेबल तक औसत';

  @override
  String get statOrdersTaken => 'आपके लिए गए ऑर्डर';

  @override
  String get statReadyNow => 'अभी परोसने को तैयार';

  @override
  String get statBillsRaised => 'बनाए गए बिल';

  @override
  String get statCollected => 'वसूला';

  @override
  String get statUnpaidNow => 'अभी बकाया बिल';

  @override
  String teamAverage(String value) {
    return 'टीम $value';
  }

  @override
  String minutesDecimal(String value) {
    return '$value मिनट';
  }

  @override
  String get noWorkYet => 'इस अवधि में अभी कुछ नहीं';

  @override
  String newOrdersSinceBill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'इस बिल के बाद $count नए ऑर्डर',
      one: 'इस बिल के बाद 1 नया ऑर्डर',
    );
    return '$_temp0';
  }

  @override
  String get updateBill => 'बिल अपडेट करें';

  @override
  String get updateBillHelp =>
      'मौजूदा बिल रद्द होगा और एक नया बिल सब कुछ कवर करेगा।';

  @override
  String billReplaced(String old, String next) {
    return '$old रद्द हुआ। $next में सभी ऑर्डर हैं।';
  }

  @override
  String get billCancelled => 'रद्द';

  @override
  String get tablesToBill => 'बिल बनाने वाली टेबल';

  @override
  String get viewOrders => 'ऑर्डर';

  @override
  String get viewBills => 'बिल';

  @override
  String get yesterday => 'कल';

  @override
  String get pickDates => 'तारीख चुनें';

  @override
  String get searchOrdersHint => 'ऑर्डर # या टेबल';

  @override
  String get searchBillsHint => 'बिल # या टेबल';

  @override
  String get loadMore => 'और दिखाएँ';

  @override
  String get noBillsYet => 'इस अवधि में कोई बिल नहीं';

  @override
  String get errRangeTooLong => 'अधिकतम 31 दिन चुनें';

  @override
  String get openBill => 'बिल खोलें';

  @override
  String get statusPaid => 'भुगतान हुआ';

  @override
  String printedTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बार प्रिंट हुआ',
      one: 'एक बार प्रिंट हुआ',
    );
    return '$_temp0';
  }

  @override
  String get takeaway => 'टेकअवे';

  @override
  String get newTakeaway => 'टेकअवे';

  @override
  String takeawayTitle(int number) {
    return 'टेकअवे #$number';
  }

  @override
  String takeawayTitleFor(int number, String name) {
    return 'टेकअवे #$number · $name';
  }

  @override
  String takeawayFor(String name) {
    return 'टेकअवे · $name';
  }

  @override
  String get guestName => 'मेहमान का नाम (वैकल्पिक)';

  @override
  String get guestPhone => 'फ़ोन (वैकल्पिक)';

  @override
  String get handedOver => 'सौंप दिया';

  @override
  String get nextHandOver => 'अगला: मेहमान को सौंपें';

  @override
  String get nextBillOrder => 'अगला: इस ऑर्डर का बिल बनाएँ';

  @override
  String get channelTakeaway => 'टेकअवे';

  @override
  String billForOrder(String title) {
    return 'बिल · $title';
  }

  @override
  String get discount => 'छूट';

  @override
  String get addDiscount => 'छूट दें';

  @override
  String get discountByPercent => 'प्रतिशत';

  @override
  String get discountByAmount => 'राशि (₹)';

  @override
  String get discountValue => 'कितना';

  @override
  String get discountReason => 'कारण (बिल पर छपेगा)';

  @override
  String discountLimit(String limit) {
    return 'आपकी सीमा: $limit';
  }

  @override
  String get discountHelp =>
      'छूट के बाद टैक्स दोबारा गिना जाता है। छपा बिल नए बिल से बदल जाता है।';

  @override
  String get taxableValue => 'कर योग्य मूल्य';

  @override
  String get maxBillDiscount => 'अधिकतम बिल छूट';

  @override
  String errDiscountLimit(String limit) {
    return 'यह आपकी भूमिका की सीमा से अधिक है ($limit)';
  }

  @override
  String get errBadDiscount => 'सही छूट और कारण दें';

  @override
  String get noDiscountAllowed => 'आपकी भूमिका छूट नहीं दे सकती';

  @override
  String get paidSoFar => 'भुगतान हुआ';

  @override
  String get dueNow => 'बकाया';

  @override
  String get payPart => 'आंशिक भुगतान';

  @override
  String get splitEqually => 'बराबर बाँटें';

  @override
  String get howManyGuests => 'कितने मेहमान?';

  @override
  String guestShare(int n, String amount) {
    return 'मेहमान $n: $amount';
  }

  @override
  String get payThisShare => 'यह हिस्सा चुकाएँ';

  @override
  String get amountReceived => 'प्राप्त राशि';

  @override
  String get paymentRef => 'रेफ़रेंस (वैकल्पिक)';

  @override
  String get removePayment => 'यह भुगतान हटाएँ';

  @override
  String get payMixed => 'मिश्रित';

  @override
  String errOverpayment(String due) {
    return 'यह बकाया से अधिक है ($due)';
  }

  @override
  String get errHasPayments =>
      'इस बिल का कुछ भुगतान हो चुका है। पहले वे भुगतान हटाएँ।';

  @override
  String get errPaymentsExceedTotal =>
      'नई राशि से ज़्यादा भुगतान हो चुका है। पहले एक भुगतान हटाएँ।';

  @override
  String get payWholeDue => 'पूरा बकाया चुकाएँ';

  @override
  String get reportsTitle => 'रिपोर्ट';

  @override
  String get reportSales => 'बिक्री';

  @override
  String get reportItems => 'आइटम';

  @override
  String get reportGst => 'GST';

  @override
  String get reportStaff => 'स्टाफ';

  @override
  String get downloadCsv => 'CSV डाउनलोड';

  @override
  String get billsRegisterCsv => 'बिल रजिस्टर (CSV)';

  @override
  String fileSaved(String name) {
    return '$name सेव हो गई';
  }

  @override
  String get basisSales =>
      'होटल की तारीख पर जारी बिल। रद्द बिल अलग दिखते हैं, बिक्री में नहीं जुड़ते।';

  @override
  String get basisItems =>
      'जारी बिलों के व्यंजन, जैसे छपे। रद्द बिल शामिल नहीं।';

  @override
  String basisGst(String sac) {
    return 'हर बिल पर छपा टैक्स, दर के अनुसार। B2C, राज्य के भीतर (CGST + SGST)। SAC $sac।';
  }

  @override
  String get basisStaff =>
      'हर व्यक्ति के बनाए बिल, दी गई छूट और लिया गया पैसा।';

  @override
  String get ladderGross => 'कुल (मेनू मूल्य)';

  @override
  String get ladderDiscount => 'छूट';

  @override
  String get ladderTaxable => 'कर योग्य मूल्य';

  @override
  String get ladderOtherTax => 'अन्य कर';

  @override
  String get ladderRoundOff => 'राउंड ऑफ';

  @override
  String get ladderTotal => 'बिल कुल';

  @override
  String repBills(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बिल',
      one: '1 बिल',
    );
    return '$_temp0';
  }

  @override
  String repReplaced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'और खाना जुड़ने पर $count बिल बदले गए',
      one: 'और खाना जुड़ने पर 1 बिल बदला गया',
    );
    return '$_temp0';
  }

  @override
  String get repReceived => 'मिला पैसा';

  @override
  String repUnbilled(int count, String amount) {
    return 'अभी बिल नहीं: $count ऑर्डर, $amount';
  }

  @override
  String get repUnbilledHelp =>
      'इनका बिल बनाएं या ऑर्डर रद्द करें। ये बिक्री में नहीं गिने जाते।';

  @override
  String get repByDay => 'दिन के अनुसार';

  @override
  String get repNoBills => 'इन तारीखों में कोई बिल नहीं';

  @override
  String repSold(int qty) {
    return '$qty बिके';
  }

  @override
  String gstRate(String rate) {
    return 'GST $rate';
  }

  @override
  String get gstDocuments => 'जारी दस्तावेज़';

  @override
  String gstDocCounts(
    String from,
    String to,
    int count,
    int cancelled,
    int net,
  ) {
    return '$from से $to: $count जारी, $cancelled रद्द, $net शुद्ध';
  }

  @override
  String get docTaxInvoice => 'टैक्स इनवॉइस';

  @override
  String get docBillOfSupply => 'बिल ऑफ सप्लाई';

  @override
  String get docBill => 'बिल';

  @override
  String staffDiscounts(int count, String amount) {
    return '$count छूट · $amount';
  }

  @override
  String staffCancelled(int count) {
    return '$count बिल हाथ से रद्द';
  }

  @override
  String get noStaffActivity => 'इन तारीखों में स्टाफ के बिल या भुगतान नहीं';

  @override
  String errRangeTooLongDays(int days) {
    return 'अधिकतम $days दिन चुनें';
  }

  @override
  String unbilledToday(String amount) {
    return 'आज अभी बिल नहीं: $amount';
  }

  @override
  String get splitByItems => 'आइटम के हिसाब से बाँटें';

  @override
  String get splitByItemsHelp =>
      'गेस्ट पर टैप करें तो एक उन्हें; x से वापस। शेयर्ड: टिक किए गेस्ट बराबर हिस्सा देंगे।';

  @override
  String get guestsCount => 'गेस्ट';

  @override
  String guestN(int n) {
    return 'गेस्ट $n';
  }

  @override
  String guestUnits(int n, int count) {
    return 'गेस्ट $n · $count';
  }

  @override
  String guestNofM(int n, int m) {
    return '$m में से गेस्ट $n';
  }

  @override
  String splitLeft(int count) {
    return '$count बाकी';
  }

  @override
  String get splitShared => 'शेयर्ड';

  @override
  String splitCreate(int count) {
    return '$count बिल बनाएं';
  }

  @override
  String get splitIncomplete => 'हर व्यंजन किसी को दें और हर गेस्ट को कुछ मिले';

  @override
  String splitDone(int count) {
    return '$count गेस्ट बिल जारी हुए';
  }

  @override
  String get guestBills => 'गेस्ट बिल';

  @override
  String get splitNothing => 'इस टेबल पर बाँटने को अभी कुछ नहीं';

  @override
  String get errLinesChanged => 'टेबल के आइटम बदल गए। सूची रिफ्रेश हो गई।';

  @override
  String get errSplitPartlyPaid =>
      'एक गेस्ट भुगतान कर चुका है, यह बँटवारा रद्द नहीं हो सकता।';

  @override
  String get errBillDiscounted =>
      'इस बिल पर छूट है। पहले इसे रद्द करें, फिर आइटम के हिसाब से बाँटें।';

  @override
  String get chooseSize => 'साइज़ चुनें';

  @override
  String pickUpTo(int max) {
    return 'अधिकतम $max';
  }

  @override
  String pickExactly(int n) {
    return '$n चुनें';
  }

  @override
  String pickBetween(int min, int max) {
    return '$min से $max चुनें';
  }

  @override
  String get addToOrder => 'जोड़ें';

  @override
  String get hasOptions => 'साइज़ / ऐड-ऑन';

  @override
  String get errVariantRequired => 'पहले साइज़ चुनें';

  @override
  String get errAddonCount => 'ऐड-ऑन विकल्प जाँचें';

  @override
  String get removeLine => 'हटाएं';

  @override
  String get sizes => 'साइज़';

  @override
  String get sizesHelp =>
      'दो या अधिक साइज़, हर एक की अपनी कीमत (जैसे हाफ़ ₹180, फुल ₹320)। एक ही कीमत पर बेचने के लिए सब हटा दें।';

  @override
  String get addSize => 'साइज़ जोड़ें';

  @override
  String get sizeNameHint => 'जैसे हाफ़';

  @override
  String get errSizesCount => 'दो या अधिक साइज़ दें, या कोई नहीं';

  @override
  String get errPriceInvalid => 'सही कीमत डालें';

  @override
  String get addons => 'ऐड-ऑन';

  @override
  String get addonGroups => 'ऐड-ऑन ग्रुप';

  @override
  String get addonGroupsHelp =>
      'एक बार ग्रुप बनाएं (जैसे एक्स्ट्रा, ब्रेड चुनें) और किसी भी व्यंजन के साथ दें।';

  @override
  String get newGroup => 'नया ग्रुप';

  @override
  String get groupNameHint => 'जैसे एक्स्ट्रा';

  @override
  String get minPicks => 'कम से कम';

  @override
  String get maxPicks => 'अधिकतम';

  @override
  String get addAddon => 'ऐड-ऑन जोड़ें';

  @override
  String get addonNameHint => 'जैसे रायता';

  @override
  String usedBy(String names) {
    return 'इस्तेमाल: $names';
  }

  @override
  String get notUsedYet => 'अभी किसी व्यंजन के साथ नहीं';

  @override
  String addonsForItem(String item) {
    return '$item के साथ कौन से ऐड-ऑन ग्रुप दें, चुनें।';
  }

  @override
  String get noAddonGroups =>
      'अभी कोई ऐड-ऑन ग्रुप नहीं। ऐड-ऑन ग्रुप में एक बनाएं।';

  @override
  String deleteGroupConfirm(String name) {
    return '$name हटाएं? इसे इस्तेमाल करने वाले व्यंजन इसे नहीं देंगे। पहले के ऑर्डर नहीं बदलेंगे।';
  }

  @override
  String get saved => 'सेव हो गया';

  @override
  String offerBadge(String name, String percent, String time) {
    return '$name −$percent $time तक';
  }

  @override
  String get happyHour => 'हैप्पी आवर';

  @override
  String get happyHourHelp =>
      'चुने दिनों और समय पर व्यंजन या साइज़ की कीमत पर प्रतिशत छूट, हर ऑर्डर पर (वेटर या QR)। ऐड-ऑन की कीमत वही; ऑफ़र जुड़ते नहीं।';

  @override
  String get newOffer => 'नया ऑफ़र';

  @override
  String get offerNameHint => 'जैसे हैप्पी आवर';

  @override
  String get percentOff => 'प्रतिशत छूट';

  @override
  String get days => 'दिन';

  @override
  String get fromTime => 'से';

  @override
  String get toTime => 'तक';

  @override
  String get appliesTo => 'किस पर लागू';

  @override
  String get wholeMenu => 'पूरा मेनू';

  @override
  String get offerOn => 'चालू';

  @override
  String get noOffers => 'अभी कोई ऑफ़र नहीं';

  @override
  String offerSummary(String percent, String days, String from, String to) {
    return '$percent छूट · $days · $from–$to';
  }

  @override
  String get everyDay => 'हर दिन';

  @override
  String get errBadPercent => '0.01 से 90 के बीच प्रतिशत डालें';

  @override
  String get errSameTimes => 'शुरू और खत्म का समय अलग होना चाहिए';

  @override
  String get combo => 'कॉम्बो';

  @override
  String get comboHelp =>
      'इस कॉम्बो के व्यंजन चुनें। कीमत और टैक्स इसके अपने रहेंगे। चुनाव के लिए (जैसे ड्रिंक) 1 चुनने वाला ऐड-ऑन ग्रुप जोड़ें।';

  @override
  String get comboNeedsTwo =>
      'कॉम्बो में कम से कम दो व्यंजन चाहिए। सामान्य व्यंजन बनाने के लिए सब हटा दें।';

  @override
  String get errBadCombo =>
      'यह कॉम्बो मान्य नहीं (कॉम्बो में खुद या दूसरा कॉम्बो नहीं हो सकता, और दो व्यंजन चाहिए)';

  @override
  String get errItemInCombo =>
      'यह व्यंजन एक कॉम्बो में है। पहले उसे कॉम्बो से हटाएं, या सोल्ड आउट करें।';

  @override
  String get editCategory => 'कैटेगरी बदलें';

  @override
  String get servingHours => 'परोसने का समय';

  @override
  String get servedAllDay => 'पूरे दिन परोसा जाता है';

  @override
  String servedHours(String hours) {
    return '$hours परोसा जाता है';
  }

  @override
  String get outsideHoursTitle => 'अभी नहीं परोसा जाता';

  @override
  String outsideHoursBody(String items, String category, String hours) {
    return '$items ($category, $hours) परोसने के समय से बाहर हैं। फिर भी ऑर्डर करें?';
  }

  @override
  String get orderAnyway => 'फिर भी ऑर्डर करें';

  @override
  String get errOutsideHours => 'इस समय नहीं परोसा जाता';

  @override
  String get closeDay => 'दिन बंद करें';

  @override
  String get closeDayHelp =>
      'आज हर डिवाइस पर दर्ज के हिसाब से दराज़ में कितना होना चाहिए। नकद गिनकर नीचे लिखें।';

  @override
  String get today => 'आज';

  @override
  String get history => 'इतिहास';

  @override
  String get openingFloat => 'शुरुआती नकद';

  @override
  String get cashReceived => 'मिला नकद';

  @override
  String get cashPaidOut => 'दिया गया नकद (खर्च)';

  @override
  String get expectedInDrawer => 'दराज़ में होना चाहिए';

  @override
  String get countedCash => 'गिना गया नकद';

  @override
  String get keepForTomorrow => 'कल के लिए दराज़ में रखें';

  @override
  String toDeposit(String amount) {
    return 'बैंक में: $amount';
  }

  @override
  String cashOver(String amount) {
    return 'ज़्यादा $amount';
  }

  @override
  String cashShort(String amount) {
    return 'कम $amount';
  }

  @override
  String get cashExact => 'बिल्कुल सही';

  @override
  String get whyDifferent => 'अंतर क्यों? (ज़रूरी)';

  @override
  String get closeDayButton => 'दिन बंद करें';

  @override
  String get closeDayConfirm =>
      'यह अंतिम है। कल का शुरुआती नकद वही होगा जो आप रखेंगे।';

  @override
  String dayClosedBy(String name, String time) {
    return '$time पर $name ने बंद किया';
  }

  @override
  String cashAfterClose(String amount) {
    return 'बंद करने के बाद मिला नकद: $amount';
  }

  @override
  String unpaidBillsWarning(int count, String amount) {
    return '$count बिल अभी बाकी हैं ($amount)';
  }

  @override
  String shortDays(int count) {
    return '$count कम वाले दिन';
  }

  @override
  String netOverShort(String amount) {
    return 'कुल ज़्यादा/कम: $amount';
  }

  @override
  String get noCloses => 'अभी कोई दिन बंद नहीं';

  @override
  String get errNoteRequired => 'बताएं कि नकद ज़्यादा/कम क्यों है';

  @override
  String get errAlreadyClosed => 'यह दिन पहले ही बंद है';

  @override
  String get seated => 'बैठे हैं';

  @override
  String get cleaning => 'सफ़ाई';

  @override
  String get reserved => 'आरक्षित';

  @override
  String get seatGuests => 'मेहमान बैठाएं';

  @override
  String get guestsCountLabel => 'कितने मेहमान?';

  @override
  String guestsAndTime(String guests, int minutes) {
    return '$guests · $minutes मि';
  }

  @override
  String guestsN(int count) {
    return '$count मेहमान';
  }

  @override
  String get markClean => 'साफ़';

  @override
  String get reserve => 'आरक्षित करें';

  @override
  String get reserveNoteHint => 'जैसे रात 8 बजे, 4 लोग';

  @override
  String get cancelReservation => 'आरक्षण रद्द करें';

  @override
  String get guestsLeft => 'मेहमान चले गए (टेबल खाली)';

  @override
  String get changeGuests => 'मेहमान बदलें';

  @override
  String coversLine(int covers) {
    return '$covers मेहमान';
  }

  @override
  String avgPerGuest(String amount) {
    return 'प्रति मेहमान औसत: $amount';
  }

  @override
  String get errTableInUse => 'इस टेबल पर मेहमान हैं';
}
