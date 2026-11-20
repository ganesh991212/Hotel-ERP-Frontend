// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appName => 'Vethra';

  @override
  String get signInTitle => 'మళ్ళీ స్వాగతం';

  @override
  String get signInSubtitle => 'మీ రెస్టారెంట్ నడపడానికి సైన్ ఇన్ చేయండి.';

  @override
  String get email => 'ఈమెయిల్';

  @override
  String get password => 'పాస్‌వర్డ్';

  @override
  String get signIn => 'సైన్ ఇన్';

  @override
  String get signOut => 'సైన్ అవుట్';

  @override
  String get showPassword => 'పాస్‌వర్డ్ చూపించు';

  @override
  String get hidePassword => 'పాస్‌వర్డ్ దాచు';

  @override
  String get loginHeadline =>
      'ఆర్డర్లు, కిచెన్, డబ్బు — అన్నీ ఒకే చోట ప్రశాంతంగా.';

  @override
  String get loginPointQr => 'టేబుల్ QR ఆర్డరింగ్';

  @override
  String get loginPointKitchen => 'లైవ్ చెఫ్ క్యూలు';

  @override
  String get loginPointDashboards => 'రోజువారీ డాష్‌బోర్డులు';

  @override
  String get yourProfile => 'మీ ప్రొఫైల్';

  @override
  String get settings => 'సెట్టింగ్‌లు';

  @override
  String get alerts => 'అలర్ట్‌లు';

  @override
  String get noAlerts => 'ఇప్పుడు మీరు చూడాల్సినది ఏమీ లేదు';

  @override
  String get close => 'మూసివేయి';

  @override
  String get cancel => 'రద్దు';

  @override
  String get save => 'సేవ్';

  @override
  String get saveChanges => 'మార్పులు సేవ్ చేయి';

  @override
  String get edit => 'ఎడిట్';

  @override
  String get delete => 'తొలగించు';

  @override
  String get more => 'మరిన్ని';

  @override
  String get add => 'జోడించు';

  @override
  String get increase => 'పెంచు';

  @override
  String get decrease => 'తగ్గించు';

  @override
  String get all => 'అన్నీ';

  @override
  String get name => 'పేరు';

  @override
  String get status => 'స్థితి';

  @override
  String get role => 'పాత్ర';

  @override
  String get phone => 'ఫోన్';

  @override
  String get phoneOptional => 'ఫోన్ (ఐచ్ఛికం)';

  @override
  String get date => 'తేదీ';

  @override
  String get type => 'రకం';

  @override
  String get reason => 'కారణం';

  @override
  String get reasonAuditedHelp => 'ఆడిట్ లాగ్‌లో సేవ్ అవుతుంది.';

  @override
  String get defaultReason => 'ప్లాట్‌ఫామ్ అడ్మిన్ మార్చారు';

  @override
  String get tabOverview => 'అవలోకనం';

  @override
  String get tabHotels => 'హోటళ్లు';

  @override
  String get tabPlans => 'ప్లాన్లు';

  @override
  String get tabFloor => 'ఫ్లోర్';

  @override
  String get tabKitchen => 'కిచెన్';

  @override
  String get tabMenu => 'మెనూ';

  @override
  String get tabTables => 'టేబుళ్లు';

  @override
  String get tabTeam => 'టీమ్';

  @override
  String get tabExpenses => 'ఖర్చులు';

  @override
  String goodMorning(String name) {
    return 'శుభోదయం, $name';
  }

  @override
  String goodAfternoon(String name) {
    return 'శుభ మధ్యాహ్నం, $name';
  }

  @override
  String goodEvening(String name) {
    return 'శుభ సాయంత్రం, $name';
  }

  @override
  String get waiting => 'వేచి ఉన్నవి';

  @override
  String get cooking => 'వండుతున్నవి';

  @override
  String get tablesBusy => 'నిండిన టేబుళ్లు';

  @override
  String get servedToday => 'సర్వ్ అయినవి';

  @override
  String get ordersToday => 'ఈరోజు ఆర్డర్లు';

  @override
  String get revenueToday => 'ఈరోజు ఆదాయం';

  @override
  String get avgPrep => 'సగటు తయారీ';

  @override
  String get thisMonth => 'ఈ నెల';

  @override
  String expensesAmount(String amount) {
    return 'ఖర్చులు $amount';
  }

  @override
  String netAmount(String amount) {
    return 'నికరం $amount';
  }

  @override
  String get ordersByHour => 'గంటల వారీగా ఆర్డర్లు';

  @override
  String get ordersSoFarToday => 'ఈరోజు ఇప్పటివరకు ఆర్డర్లు';

  @override
  String get openFloor => 'ఫ్లోర్ తెరువు';

  @override
  String get openKitchen => 'కిచెన్ తెరువు';

  @override
  String get kitchenPace => 'కిచెన్ వేగం';

  @override
  String get avgPrepMinutes => 'వండడానికి సగటు నిమిషాలు';

  @override
  String chefsOnShift(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'షిఫ్ట్‌లో $count చెఫ్‌లు',
      one: 'షిఫ్ట్‌లో 1 చెఫ్',
    );
    return '$_temp0';
  }

  @override
  String cookingNow(int count) {
    return '$count వండుతున్నారు';
  }

  @override
  String get servedShare => 'ఈరోజు సర్వ్ అయినవి';

  @override
  String get liveOrders => 'లైవ్ ఆర్డర్లు';

  @override
  String get noLiveOrders => 'తెరిచిన ఆర్డర్లు లేవు';

  @override
  String get topDishes => 'టాప్ వంటకాలు';

  @override
  String get chefs => 'చెఫ్‌లు';

  @override
  String get avgTicket => 'సగటు బిల్లు';

  @override
  String get perOrderToday => 'ఈరోజు ఒక్కో ఆర్డర్‌కు';

  @override
  String get noDataYet => 'ఇంకా డేటా లేదు';

  @override
  String get noChefsYet => 'ఇంకా చెఫ్‌లను జోడించలేదు';

  @override
  String soldCount(int count) {
    return '$count అమ్ముడయ్యాయి';
  }

  @override
  String doneCount(int count) {
    return '$count పూర్తి';
  }

  @override
  String get revenueLast7Days => 'ఆదాయం, గత 7 రోజులు';

  @override
  String get statusPlaced => 'నిర్ధారణ కోసం వేచి ఉంది';

  @override
  String get statusConfirmed => 'కొత్తది';

  @override
  String get statusQueued => 'క్యూలో ఉంది';

  @override
  String get statusPreparing => 'తయారవుతోంది';

  @override
  String get statusReady => 'సిద్ధం';

  @override
  String get statusServed => 'సర్వ్ అయింది';

  @override
  String get statusCancelled => 'రద్దయింది';

  @override
  String get channelQr => 'QR';

  @override
  String get channelWaiter => 'సర్వర్';

  @override
  String get channelAdmin => 'అడ్మిన్';

  @override
  String orderNumberTable(int number, String table) {
    return '#$number · టేబుల్ $table';
  }

  @override
  String tableLabel(String label) {
    return 'టేబుల్ $label';
  }

  @override
  String minutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes నిమిషాల క్రితం',
      one: '1 నిమిషం క్రితం',
      zero: 'ఇప్పుడే',
    );
    return '$_temp0';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes ని';
  }

  @override
  String get roleHotelAdmin => 'హోటల్ అడ్మిన్';

  @override
  String get roleManager => 'మేనేజర్';

  @override
  String get roleCashier => 'క్యాషియర్';

  @override
  String get roleWaiter => 'సర్వర్';

  @override
  String get roleChef => 'చెఫ్';

  @override
  String get rolePlatformAdmin => 'ప్లాట్‌ఫామ్ అడ్మిన్';

  @override
  String get live => 'లైవ్';

  @override
  String get reconnecting => 'మళ్ళీ కనెక్ట్ అవుతోంది';

  @override
  String get staleBanner =>
      'కనెక్షన్ పోయింది. చివరిగా తెలిసిన క్యూ చూపిస్తున్నాం; కొన్ని సెకన్లకు ఒకసారి రిఫ్రెష్ అవుతుంది.';

  @override
  String get modeChefAccept => 'చెఫ్‌లు తీసుకుంటారు';

  @override
  String get modeAutoAssign => 'ఆటో కేటాయింపు';

  @override
  String get modeAdminPrint => 'ప్రింట్ టికెట్లు';

  @override
  String get upForGrabs => 'కొత్త ఆర్డర్లు';

  @override
  String get waitingForChef => 'చెఫ్ కోసం వేచి ఉంది';

  @override
  String get noNewOrders => 'కొత్త ఆర్డర్లు లేవు';

  @override
  String get noNewOrdersBody => 'కొత్త ఆర్డర్లు వెంటనే ఇక్కడ కనిపిస్తాయి.';

  @override
  String get pickUp => 'తీసుకో';

  @override
  String get pickedUp => 'ఈ ఆర్డర్ మీది';

  @override
  String get myQueue => 'నా క్యూ';

  @override
  String get queueEmpty => 'మీరు ఖాళీగా ఉన్నారు. తదుపరి ఆర్డర్ తీసుకోండి.';

  @override
  String get offShiftBody =>
      'మీరు షిఫ్ట్‌లో లేరు. ఆర్డర్లు రావడానికి ఆన్ చేయండి.';

  @override
  String get lockedUntilHead => 'ముందు ఉన్న ఆర్డర్ సిద్ధమైన తర్వాత మొదలవుతుంది';

  @override
  String get startCooking => 'వంట మొదలుపెట్టు';

  @override
  String get started => 'మొదలైంది';

  @override
  String get markReady => 'సిద్ధం అని గుర్తించు';

  @override
  String get markedReady => 'సిద్ధం అని గుర్తించాం. సర్వర్‌కు తెలియజేశాం.';

  @override
  String cookingFor(int minutes, int target) {
    return '$minutes ని వండుతోంది · లక్ష్యం $target ని';
  }

  @override
  String waitingFor(int minutes) {
    return '$minutes ని వేచి ఉంది';
  }

  @override
  String get otherChefs => 'ఇతర చెఫ్‌లు';

  @override
  String get noOtherChefs => 'ఇతర చెఫ్‌లు లేరు';

  @override
  String get idle => 'ఖాళీ';

  @override
  String get onShift => 'షిఫ్ట్‌లో';

  @override
  String get offShift => 'షిఫ్ట్ లేదు';

  @override
  String get returnToBoard => 'బోర్డుకు తిరిగి పంపు';

  @override
  String get readyToServe => 'సర్వ్ చేయడానికి సిద్ధం';

  @override
  String get nothingWaiting => 'సర్వ్ చేయాల్సినవి ఏమీ లేవు';

  @override
  String get serve => 'సర్వ్';

  @override
  String get needsAttention => 'శ్రద్ధ అవసరం';

  @override
  String get allCalm =>
      'అంతా ప్రశాంతం. నిర్ధారించాల్సినవి లేదా సర్వ్ చేయాల్సినవి లేవు.';

  @override
  String get markServed => 'సర్వ్ అయింది';

  @override
  String get confirmOrder => 'నిర్ధారించు';

  @override
  String get noTables => 'ఇంకా టేబుళ్లు లేవు';

  @override
  String get noTablesBody => 'QR కోడ్‌లు ప్రింట్ చేయడానికి టేబుళ్లు జోడించండి.';

  @override
  String seats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సీట్లు',
      one: '1 సీటు',
    );
    return '$_temp0';
  }

  @override
  String get seatsLabel => 'సీట్లు';

  @override
  String get inactive => 'నిష్క్రియం';

  @override
  String get free => 'ఖాళీ';

  @override
  String get openOrders => 'తెరిచిన ఆర్డర్లు';

  @override
  String get cannotTakeOrders =>
      'మీ పాత్రకు ఇక్కడ ఆర్డర్లు తీసుకునే అనుమతి లేదు.';

  @override
  String get searchMenu => 'మెనూలో వెతకండి';

  @override
  String get kitchenNoteHint => 'కిచెన్‌కు నోట్ (ఐచ్ఛికం)';

  @override
  String get sendToKitchen => 'కిచెన్‌కు పంపు';

  @override
  String get orderSent => 'ఆర్డర్ కిచెన్‌కు వెళ్ళింది';

  @override
  String get soldOut => 'అయిపోయింది';

  @override
  String get veg => 'వెజ్';

  @override
  String get nonVeg => 'నాన్-వెజ్';

  @override
  String get subtotal => 'ఉపమొత్తం';

  @override
  String get tax => 'GST';

  @override
  String get serviceCharge => 'సర్వీస్ ఛార్జ్';

  @override
  String get total => 'మొత్తం';

  @override
  String get addCategory => 'కేటగిరీ జోడించు';

  @override
  String get addItem => 'ఐటెమ్ జోడించు';

  @override
  String get editItem => 'ఐటెమ్ ఎడిట్';

  @override
  String get addCategoryFirst => 'ముందుగా ఒక కేటగిరీ జోడించండి';

  @override
  String get menuEmpty => 'మీ మెనూ ఖాళీగా ఉంది';

  @override
  String get menuEmptyBody => 'ఒక కేటగిరీ, తర్వాత మీ వంటకాలు జోడించండి.';

  @override
  String get noMatches => 'ఏదీ సరిపోలలేదు';

  @override
  String get category => 'కేటగిరీ';

  @override
  String get price => 'ధర';

  @override
  String get prepTime => 'తయారీ సమయం';

  @override
  String get availability => 'లభ్యత';

  @override
  String get available => 'అందుబాటులో ఉంది';

  @override
  String get priceRupees => 'ధర (₹)';

  @override
  String get priceHelp =>
      'పన్ను ముందు ధర. మీరు రిజిస్టర్ అయితే GST ఆటోమేటిక్‌గా కలుస్తుంది.';

  @override
  String get descriptionOptional => 'వివరణ (ఐచ్ఛికం)';

  @override
  String get addTable => 'టేబుల్ జోడించు';

  @override
  String get tableName => 'టేబుల్ పేరు';

  @override
  String get tableNameHelp => 'చిన్నగా, ప్రత్యేకంగా — T1 లేదా P2 లాగా.';

  @override
  String get areaOptional => 'ప్రాంతం (ఐచ్ఛికం)';

  @override
  String get copyLink => 'లింక్ కాపీ';

  @override
  String get openDinerView => 'కస్టమర్ వీక్షణ తెరువు';

  @override
  String get rotateQr => 'QR కోడ్ మార్చు';

  @override
  String get deactivate => 'నిష్క్రియం చేయి';

  @override
  String get activate => 'సక్రియం చేయి';

  @override
  String get qrActive => 'QR సక్రియం';

  @override
  String openOrdersCount(int count) {
    return '$count తెరిచి ఉన్నాయి';
  }

  @override
  String get linkCopied => 'లింక్ కాపీ అయింది';

  @override
  String get qrRotated =>
      'కొత్త QR తయారైంది. దాన్ని ప్రింట్ చేయండి; పాతది ఇక పనిచేయదు.';

  @override
  String get people => 'వ్యక్తులు';

  @override
  String get rolesAndAccess => 'పాత్రలు & అనుమతులు';

  @override
  String get searchPeople => 'పేరు లేదా పాత్రతో వెతకండి';

  @override
  String get addMember => 'సభ్యుడిని జోడించు';

  @override
  String get newRole => 'కొత్త పాత్ర';

  @override
  String get newRoleLocked => 'కస్టమ్ పాత్రలు (అప్‌గ్రేడ్)';

  @override
  String get newRoleHelp => 'తర్వాత ఈ పాత్ర ఏమి చేయగలదో టిక్ చేయండి.';

  @override
  String get permission => 'అనుమతి';

  @override
  String get adminLocked => 'హోటల్ అడ్మిన్‌లకు ఎప్పుడూ అన్ని అనుమతులు ఉంటాయి';

  @override
  String get disabled => 'నిలిపివేయబడింది';

  @override
  String get active => 'సక్రియం';

  @override
  String makeRole(String role) {
    return '$role గా చేయి';
  }

  @override
  String get disableAccount => 'ఖాతా నిలిపివేయి';

  @override
  String get enableAccount => 'ఖాతా ప్రారంభించు';

  @override
  String get emailLoginHelp => 'వారు ఈ ఈమెయిల్‌తో సైన్ ఇన్ చేస్తారు.';

  @override
  String get tempPassword => 'తాత్కాలిక పాస్‌వర్డ్';

  @override
  String get tempPasswordHelp => 'కనీసం 8 అక్షరాలు. రహస్యంగా పంచుకోండి.';

  @override
  String get sendInvite => 'సభ్యుడిని జోడించు';

  @override
  String get permDashboard => 'డాష్‌బోర్డ్ చూడటం';

  @override
  String get permOrderView => 'ఆర్డర్లు చూడటం';

  @override
  String get permOrderCreate => 'ఆర్డర్లు తీసుకోవడం';

  @override
  String get permOrderConfirm => 'QR ఆర్డర్లు నిర్ధారించడం';

  @override
  String get permOrderServe => 'సర్వ్ అయిందని గుర్తించడం';

  @override
  String get permOrderCancel => 'ఆర్డర్లు రద్దు చేయడం';

  @override
  String get permKitchenCook => 'తీసుకుని వండటం';

  @override
  String get permKitchenManage => 'చెఫ్ క్యూలు నిర్వహించడం';

  @override
  String get permTableManage => 'టేబుళ్లు, QR నిర్వహణ';

  @override
  String get permMenuManage => 'మెనూ, ధరలు మార్చడం';

  @override
  String get permMenuAvailability => 'ఐటెమ్‌లు అయిపోయాయని గుర్తించడం';

  @override
  String get permStaffManage => 'సిబ్బంది నిర్వహణ';

  @override
  String get permRoleManage => 'పాత్రలు సెట్ చేయడం';

  @override
  String get permExpenseView => 'ఖర్చులు చూడటం';

  @override
  String get permExpenseManage => 'ఖర్చులు నమోదు చేయడం';

  @override
  String get permReportView => 'రిపోర్టులు చూడటం';

  @override
  String get permSettingsManage => 'సెట్టింగ్‌లు, బిల్లింగ్';

  @override
  String get addExpense => 'ఖర్చు జోడించు';

  @override
  String get editExpense => 'ఖర్చు ఎడిట్';

  @override
  String get previousMonth => 'గత నెల';

  @override
  String get nextMonth => 'వచ్చే నెల';

  @override
  String get spentThisMonth => 'ఈ నెల ఖర్చు';

  @override
  String get byDay => 'రోజు వారీగా';

  @override
  String get noExpenses => 'ఈ నెల ఖర్చులు లేవు';

  @override
  String get noExpensesBody => 'గ్యాస్, కిరాణా, జీతాలు మొదలైనవి నమోదు చేయండి.';

  @override
  String get amountRupees => 'మొత్తం (₹)';

  @override
  String get paidBy => 'చెల్లింపు విధానం';

  @override
  String get payCash => 'నగదు';

  @override
  String get payUpi => 'UPI';

  @override
  String get payCard => 'కార్డ్';

  @override
  String get payBank => 'బ్యాంక్';

  @override
  String get vendorOptional => 'విక్రేత (ఐచ్ఛికం)';

  @override
  String get noteOptional => 'నోట్ (ఐచ్ఛికం)';

  @override
  String get kitchenAndOrdering => 'కిచెన్';

  @override
  String get planAndBilling => 'ప్లాన్ & బిల్లింగ్';

  @override
  String get restaurantName => 'రెస్టారెంట్ పేరు';

  @override
  String get kitchenMode => 'ఆర్డర్లు చెఫ్‌లకు ఎలా చేరాలి';

  @override
  String get kitchenModeHelp => 'లాక్ అయిన ఆప్షన్లకు పెద్ద ప్లాన్ కావాలి.';

  @override
  String get maxQueue => 'ఒక చెఫ్‌కు ఒకేసారి ఆర్డర్లు';

  @override
  String get maxQueueHelp => 'ఒక చెఫ్ క్యూలో ఇంతకంటే ఎక్కువ ఉండవు.';

  @override
  String get confirmQrOrders => 'ముందుగా QR ఆర్డర్లు నిర్ధారించాలి';

  @override
  String get confirmQrOrdersHelp =>
      'కిచెన్ చూసే ముందు సర్వర్ టేబుల్ ఆర్డర్లను ఆమోదిస్తారు.';

  @override
  String get subActive => 'సక్రియం';

  @override
  String get subTrial => 'ట్రయల్';

  @override
  String get subPastDue => 'చెల్లింపు బాకీ';

  @override
  String get subSuspended => 'నిలిపివేయబడింది';

  @override
  String perMonth(String amount) {
    return '$amount / నెల';
  }

  @override
  String get perMonthShort => '/ నెల';

  @override
  String trialEndsOn(String date) {
    return 'ట్రయల్ ముగింపు $date';
  }

  @override
  String renewsOn(String date) {
    return 'పునరుద్ధరణ $date';
  }

  @override
  String get choosePlan => 'ప్లాన్ ఎంచుకోండి';

  @override
  String get choosePlanHelp =>
      'Razorpay లో సురక్షితంగా చెల్లిస్తారు. చెల్లింపు పూర్తవగానే ప్లాన్ ప్రారంభమవుతుంది.';

  @override
  String get paymentsNotConfigured =>
      'ఆన్‌లైన్ చెల్లింపు ఇంకా ఆన్ కాలేదు. ప్రారంభించడానికి సపోర్ట్‌ను సంప్రదించండి.';

  @override
  String get payAndActivate => 'చెల్లించి ప్రారంభించు';

  @override
  String get renew => 'పునరుద్ధరించు';

  @override
  String get payments => 'చెల్లింపులు';

  @override
  String get managePlan => 'ప్లాన్ నిర్వహణ';

  @override
  String get bannerPastDue =>
      'మీ చెల్లింపు బాకీ ఉంది. అంతరాయం రాకుండా ఇప్పుడే చెల్లించండి.';

  @override
  String get bannerSuspended =>
      'మీ ఖాతా నిలిపివేయబడింది. మీ డేటా చూడవచ్చు; ఆర్డర్లు మళ్ళీ మొదలవడానికి చెల్లించండి.';

  @override
  String get hotels => 'హోటళ్లు';

  @override
  String get mrr => 'నెలవారీ ఆదాయం';

  @override
  String get orders30d => 'ఆర్డర్లు (30 రోజులు)';

  @override
  String get collected30d => 'వసూలు, గత 30 రోజులు';

  @override
  String trialsEnding(int count) {
    return 'ఈ వారం $count ట్రయల్స్ ముగుస్తాయి';
  }

  @override
  String get signups => 'కొత్త హోటళ్లు';

  @override
  String get planMix => 'ప్లాన్ల విభజన';

  @override
  String get recentHotels => 'ఇటీవలి హోటళ్లు';

  @override
  String get noHotels => 'ఇంకా హోటళ్లు లేవు';

  @override
  String get noHotelsBody => 'మొదలుపెట్టడానికి మీ మొదటి హోటల్‌ను నమోదు చేయండి.';

  @override
  String get searchHotels => 'హోటళ్లలో వెతకండి';

  @override
  String get registerHotel => 'హోటల్ నమోదు';

  @override
  String get hotelRegistered =>
      'హోటల్ నమోదైంది. అడ్మిన్ లాగిన్ వివరాలు వారికి ఇవ్వండి.';

  @override
  String get hotel => 'హోటల్';

  @override
  String get plan => 'ప్లాన్';

  @override
  String get city => 'నగరం';

  @override
  String get tablesCol => 'టేబుళ్లు';

  @override
  String get hotelName => 'హోటల్ పేరు';

  @override
  String get trialHelp => 'ప్రతి కొత్త హోటల్ ఉచిత ట్రయల్‌తో మొదలవుతుంది.';

  @override
  String get gstRegistration => 'GST నమోదు';

  @override
  String get gstRegular => 'రెగ్యులర్';

  @override
  String get gstComposition => 'కంపోజిషన్';

  @override
  String get gstUnregistered => 'నమోదు కాలేదు';

  @override
  String get gstin => 'GSTIN';

  @override
  String get hotelAdmin => 'హోటల్ అడ్మిన్';

  @override
  String get suspendHotel => 'నిలిపివేయి';

  @override
  String get resumeHotel => 'మళ్ళీ ప్రారంభించు';

  @override
  String get changePlan => 'ప్లాన్ మార్చు';

  @override
  String get overrides => 'ఫీచర్ ఓవర్‌రైడ్‌లు';

  @override
  String get overridesHelp =>
      'ప్లాన్‌తో సంబంధం లేకుండా ఈ హోటల్‌కు మాత్రమే ఒక ఫీచర్‌ను ఆన్/ఆఫ్ చేయండి.';

  @override
  String get overridden => 'ఈ హోటల్‌కు మార్చబడింది';

  @override
  String get fromPlan => 'ప్లాన్ నుండి';

  @override
  String get placeholderPrice => 'తాత్కాలికం';

  @override
  String get editPrice => 'ధర మార్చు';

  @override
  String get monthlyPrice => 'నెలవారీ ధర (₹)';

  @override
  String get priceChangeHelp =>
      'కొత్త సబ్‌స్క్రిప్షన్లకు వర్తిస్తుంది. ఉన్న హోటళ్లకు పునరుద్ధరణ వరకు పాత ధర.';

  @override
  String get features => 'ఫీచర్లు';

  @override
  String get limits => 'పరిమితులు';

  @override
  String get limit => 'పరిమితి';

  @override
  String get limitHelp => 'అపరిమితం కోసం ఖాళీగా వదిలేయండి.';

  @override
  String get unlimited => 'అపరిమితం';

  @override
  String get featQr => 'QR ఆర్డరింగ్';

  @override
  String get featWaiter => 'సర్వర్ ఆర్డరింగ్';

  @override
  String get featChefAccept => 'చెఫ్‌లు ఆర్డర్లు తీసుకుంటారు';

  @override
  String get featAutoRouting => 'చెఫ్‌లకు ఆటో కేటాయింపు';

  @override
  String get featAdminPrint => 'ప్రింట్ కిచెన్ టికెట్లు';

  @override
  String get featExpenses => 'ఖర్చులు';

  @override
  String get featCustomRoles => 'కస్టమ్ పాత్రలు';

  @override
  String get featReports => 'అడ్వాన్స్‌డ్ రిపోర్టులు';

  @override
  String get featRatings => 'రేటింగ్‌లు';

  @override
  String get featApi => 'API & వెబ్‌హుక్స్';

  @override
  String get featRooms => 'గదులు';

  @override
  String get limOutlets => 'అవుట్‌లెట్లు';

  @override
  String get limTables => 'టేబుళ్లు';

  @override
  String get limStaff => 'సిబ్బంది';

  @override
  String get limChefs => 'చెఫ్‌లు';

  @override
  String get limMenuItems => 'మెనూ ఐటెమ్‌లు';

  @override
  String get limOrders => 'నెలకు ఆర్డర్లు';

  @override
  String get qrInvalid => 'ఈ QR కోడ్ పనిచేయడం లేదు';

  @override
  String get qrInvalidBody => 'దయచేసి సర్వర్ సహాయం అడగండి.';

  @override
  String get dinerHeadline => 'మీకు ఏమి కావాలి?';

  @override
  String get dinerViewOnly => 'మెనూ చూసి, సిద్ధమైనప్పుడు సర్వర్‌కు చెప్పండి.';

  @override
  String get yourOrder => 'మీ ఆర్డర్';

  @override
  String get yourOrders => 'మీ ఆర్డర్లు';

  @override
  String get stepSent => 'పంపబడింది';

  @override
  String get dinerNoteHint => 'కిచెన్‌కు ఏమైనా చెప్పాలా?';

  @override
  String get pricesByRestaurant => 'ధరలు, పన్నులు రెస్టారెంట్ నిర్ణయిస్తుంది.';

  @override
  String get placeOrder => 'ఆర్డర్ చేయి';

  @override
  String get orderPlaced => 'ఆర్డర్ అయింది. అప్‌డేట్‌లు ఇక్కడే చూపిస్తాం.';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ఐటెమ్‌లు',
      one: '1 ఐటెమ్',
    );
    return '$_temp0';
  }

  @override
  String get viewOrder => 'ఆర్డర్ చూడండి';

  @override
  String chefPreparing(String name) {
    return '$name తయారు చేస్తున్నారు';
  }

  @override
  String get readyOnItsWay => 'సిద్ధం! మీ టేబుల్‌కు వస్తోంది.';

  @override
  String get printKot => 'KOT ప్రింట్';

  @override
  String printKotTitle(int number) {
    return 'KOT #$number ప్రింట్';
  }

  @override
  String get printKotExplain =>
      'ఈ ఆర్డర్‌ను కిచెన్ పేపర్ చూసి వండుతుందా? పేపర్‌పై పంపితే చెఫ్ స్క్రీన్ నుండి తీసివేస్తాం, ఎవరూ రెండుసార్లు తీసుకోరు.';

  @override
  String get printAndSend => 'ప్రింట్ చేసి కిచెన్‌కు పంపు';

  @override
  String get printCopyOnly => 'కాపీ మాత్రమే ప్రింట్';

  @override
  String get kotPrinted => 'KOT ప్రింట్ అయింది';

  @override
  String get kotSentOnPaper =>
      'KOT ప్రింట్ అయింది. ఆర్డర్ ఇప్పుడు పేపర్‌పై కిచెన్‌లో ఉంది.';

  @override
  String get onPaper => 'పేపర్‌పై';

  @override
  String get onPaperTitle => 'పేపర్ చూసి వంట';

  @override
  String get onPaperHelp =>
      'కిచెన్‌కు ఇచ్చిన ప్రింట్ టికెట్లు. ఆహారం బయటకు రాగానే సిద్ధం అని గుర్తించండి.';

  @override
  String get billTable => 'బిల్';

  @override
  String billForTable(String label) {
    return 'బిల్ · టేబుల్ $label';
  }

  @override
  String get billExplain =>
      'ఈ టేబుల్‌లో బిల్ కాని అన్ని ఆర్డర్లకు ఒకే బిల్ తయారవుతుంది. బిల్లులకు నంబర్ ఉంటుంది, మార్చలేరు.';

  @override
  String get createBill => 'బిల్ తయారు చేయి';

  @override
  String notServedYet(String orders) {
    return 'ఇంకా సర్వ్ కాలేదు: #$orders';
  }

  @override
  String get billAnyway => 'అయినా బిల్ చేయి';

  @override
  String billPaid(String method) {
    return 'చెల్లించారు · $method';
  }

  @override
  String get billUnpaid => 'చెల్లించలేదు';

  @override
  String ordersIncluded(String orders) {
    return 'ఆర్డర్లు #$orders';
  }

  @override
  String get cgst => 'CGST';

  @override
  String get sgst => 'SGST';

  @override
  String get printBill => 'బిల్ ప్రింట్';

  @override
  String get printDuplicate => 'డూప్లికేట్ ప్రింట్';

  @override
  String get billPrinted => 'బిల్ ప్రింట్ అయింది';

  @override
  String get settlePayment => 'చెల్లింపు అందిన విధానం';

  @override
  String get voidBill => 'బిల్ రద్దు';

  @override
  String get printerSetup => 'ప్రింటర్ సెటప్';

  @override
  String get paperSize => 'పేపర్';

  @override
  String get paperSizeHelp =>
      'మీ ప్రింటర్ రోల్‌కు సరిపోయేది. ఆఫీస్ ప్రింటర్లకు A4.';

  @override
  String get paper58 => '58 mm';

  @override
  String get paper80 => '80 mm';

  @override
  String get paperA4 => 'A4';

  @override
  String get printWith => 'దీనితో ప్రింట్';

  @override
  String get printSystem => 'ప్రింట్ డైలాగ్';

  @override
  String get printNetwork => 'నెట్‌వర్క్ ప్రింటర్';

  @override
  String get printSystemHelp =>
      'ఈ పరికరం వాడగల ఏ ప్రింటర్‌తోనైనా పనిచేస్తుంది: థర్మల్, లేజర్, ఇంక్‌జెట్, బ్లూటూత్ లేదా USB.';

  @override
  String get printNetworkHelp =>
      'Wi-Fi/LAN థర్మల్ ప్రింటర్‌కు నేరుగా పంపుతుంది. డైలాగ్ ఉండదు; కిచెన్‌కు వేగంగా.';

  @override
  String get printWebHelp =>
      'బ్రౌజర్‌లో ప్రింట్ ఎప్పుడూ ప్రింట్ డైలాగ్ తెరుస్తుంది. నెట్‌వర్క్ ప్రింటర్‌కు నేరుగా ప్రింట్ చేయడానికి Android లేదా iPhone యాప్ వాడండి.';

  @override
  String get printerIp => 'ప్రింటర్ IP అడ్రస్';

  @override
  String get port => 'పోర్ట్';

  @override
  String get testPrint => 'టెస్ట్ ప్రింట్';

  @override
  String get testPrintTitle => 'TEST PRINT';

  @override
  String get testPrintBody => 'If you can read this, the printer works.';

  @override
  String get soundAlertsOn => 'సౌండ్ అలర్ట్‌లు: ఆన్';

  @override
  String get soundAlertsOff => 'సౌండ్ అలర్ట్‌లు: ఆఫ్';

  @override
  String get soundOn => 'సౌండ్ అలర్ట్‌లు ఆన్';

  @override
  String get soundOff => 'సౌండ్ అలర్ట్‌లు ఆఫ్';

  @override
  String get testSound => 'అలర్ట్ సౌండ్ టెస్ట్';

  @override
  String get soundBlocked =>
      'బ్రౌజర్ సౌండ్‌ను ఆపింది. పేజీపై ఎక్కడైనా ట్యాప్ చేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get serviceTimes => 'సర్వీస్ సమయాలు';

  @override
  String get serviceTimesHelp =>
      'ఈరోజు ఆర్డర్లు. p90 = 10 లో 9 ఆర్డర్లు దీనికంటే వేగంగా అయ్యాయి.';

  @override
  String get stageWait => 'చెఫ్ కోసం వేచి ఉండటం';

  @override
  String get stageWaitHelp => 'ఆర్డర్ నిర్ధారణ → వంట మొదలు';

  @override
  String get stagePrep => 'తయారీ';

  @override
  String get stagePrepHelp => 'వంట మొదలు → సిద్ధం';

  @override
  String get stageServe => 'సర్వింగ్';

  @override
  String get stageServeHelp => 'సిద్ధం → టేబుల్‌పై';

  @override
  String get stageTotal => 'ఆర్డర్ నుండి టేబుల్ వరకు';

  @override
  String get stageTotalHelp => 'అతిథికి అనిపించేది';

  @override
  String get minAvg => 'ని సగటు';

  @override
  String p90Line(String minutes, int count) {
    return 'p90 $minutes ని · $count ఆర్డర్లు';
  }

  @override
  String get servingByServer => 'సర్వర్ వారీగా సర్వింగ్ సమయం';

  @override
  String serverServeLine(String name, String minutes, int count) {
    return '$name: $minutes ని · $count సర్వ్';
  }

  @override
  String get categories => 'కేటగిరీలు';

  @override
  String get expenseCategories => 'ఖర్చుల కేటగిరీలు';

  @override
  String get categoriesHelp =>
      'గ్లోబల్ కేటగిరీలు అన్ని హోటళ్లకు ఉంటాయి. మిగతావాటికి మీ సొంతవి జోడించండి; అవి మీ హోటల్‌కు మాత్రమే కనిపిస్తాయి.';

  @override
  String get scopeGlobal => 'గ్లోబల్';

  @override
  String get scopeHotel => 'మీది';

  @override
  String get renameCategory => 'కేటగిరీ పేరు మార్చు';

  @override
  String get addOwnCategory => 'మీ సొంత కేటగిరీ జోడించండి';

  @override
  String get addOwnCategoryHelp => 'మీ హోటల్‌కు మాత్రమే కనిపిస్తుంది.';

  @override
  String get tabCategories => 'కేటగిరీలు';

  @override
  String get globalCategoriesHelp =>
      'ఇక్కడి కేటగిరీలు వెంటనే అన్ని హోటళ్లకు కనిపిస్తాయి. ఒకదాన్ని ఆఫ్ చేస్తే కొత్త ఖర్చులకు దాగుతుంది; పాత ఖర్చులకు అలాగే ఉంటుంది.';

  @override
  String get newGlobalCategory => 'కొత్త గ్లోబల్ కేటగిరీ';

  @override
  String get globalCategoryAdded => 'అన్ని హోటళ్లకు జోడించబడింది';

  @override
  String usedTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సార్లు వాడారు',
      one: 'ఒకసారి వాడారు',
      zero: 'వాడలేదు',
    );
    return '$_temp0';
  }

  @override
  String get printQr => 'QR ప్రింట్';

  @override
  String get printAllQr => 'అన్ని QR కోడ్‌లు ప్రింట్';

  @override
  String get enableAlerts => 'అలర్ట్‌లు ఆన్ చేయి';

  @override
  String get enableAlertsBody =>
      'కొత్త, సిద్ధమైన ఆర్డర్లకు గట్టి అలర్ట్‌లు ఆన్ చేయండి. గట్టి సౌండ్ కోసం ఈ ట్యాబ్ తెరిచే ఉంచండి; ట్యాబ్ మూసితే సాధారణ నోటిఫికేషన్ వస్తుంది.';

  @override
  String get enableAlertsDenied =>
      'మీ బ్రౌజర్ సెట్టింగ్‌లలో ఈ సైట్‌కు నోటిఫికేషన్లు బ్లాక్ అయ్యాయి. పేజీలో గట్టి సౌండ్ కోసం ట్యాప్ చేయండి; ఈ ట్యాబ్ తెరిచే ఉంచండి.';

  @override
  String get notNow => 'ఇప్పుడు కాదు';

  @override
  String get language => 'భాష';

  @override
  String get langEn => 'English';

  @override
  String get langTe => 'తెలుగు';

  @override
  String get langHi => 'हिन्दी';

  @override
  String get branding => 'బ్రాండింగ్';

  @override
  String get hotelLogo => 'హోటల్ లోగో';

  @override
  String get hotelLogoHelp =>
      'యాప్‌లో కనిపిస్తుంది, టేబుల్ QR కార్డులపై ప్రింట్ అవుతుంది. PNG లేదా JPEG.';

  @override
  String get uploadLogo => 'లోగో అప్‌లోడ్';

  @override
  String get replaceLogo => 'లోగో మార్చు';

  @override
  String get removeLogo => 'తొలగించు';

  @override
  String get logoUpdated => 'లోగో అప్‌డేట్ అయింది';

  @override
  String get addressLine => 'చిరునామా (ఒక లైన్)';

  @override
  String get addressLineHelp =>
      'QR కార్డులపై మీ హోటల్ పేరు కింద ప్రింట్ అవుతుంది.';

  @override
  String get poweredByNote =>
      'QR కార్డుల చివర ప్లాట్‌ఫామ్ నుండి చిన్న \"Powered by\" లైన్ ఉంటుంది.';

  @override
  String get errGeneric => 'ఏదో తప్పు జరిగింది. దయచేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get errOffline =>
      'మీరు ఆఫ్‌లైన్‌లో ఉన్నారు. కనెక్షన్ చూసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get errCredentials => 'ఈమెయిల్ లేదా పాస్‌వర్డ్ తప్పు.';

  @override
  String get errFeatureLocked =>
      'మీ ప్లాన్‌లో ఇది లేదు. అన్‌లాక్ చేయడానికి అప్‌గ్రేడ్ చేయండి.';

  @override
  String get errLimit => 'మీ ప్లాన్ పరిమితి దాటారు.';

  @override
  String get errPermission => 'మీ పాత్రకు ఈ అనుమతి లేదు.';

  @override
  String get errTaken => 'ఈ ఆర్డర్‌ను ఇంకో చెఫ్ ఇప్పటికే తీసుకున్నారు.';

  @override
  String get errQueueFull => 'ఇంకోటి తీసుకునే ముందు ఒక ఆర్డర్ పూర్తి చేయండి.';

  @override
  String get errNotHead => 'ముందుగా దీనికంటే ముందున్న ఆర్డర్ పూర్తి చేయండి.';

  @override
  String get errSoldOut =>
      'ఒక ఐటెమ్ ఇప్పుడే అయిపోయింది. దయచేసి మీ ఆర్డర్ మార్చండి.';

  @override
  String get errSessionExpired =>
      'మీ టేబుల్ సెషన్ ముగిసింది. QR మళ్ళీ స్కాన్ చేయండి.';

  @override
  String get errRequired => 'తప్పనిసరి';

  @override
  String get errEmail => 'సరైన ఈమెయిల్ ఇవ్వండి';

  @override
  String get errAmount => '250 లేదా 99.50 లాంటి మొత్తం ఇవ్వండి';

  @override
  String get errPasswordLength => 'కనీసం 8 అక్షరాలు';

  @override
  String get errGstin => '15 అక్షరాల GSTIN ఇవ్వండి';

  @override
  String get settingsSaved => 'సెట్టింగ్‌లు సేవ్ అయ్యాయి';

  @override
  String get brandingSaved => 'బ్రాండింగ్ సేవ్ అయింది';

  @override
  String get nextConfirm => 'తదుపరి: ఈ ఆర్డర్‌ను నిర్ధారించండి';

  @override
  String get nextChefPickup => 'తదుపరి: కిచెన్ స్క్రీన్‌లో చెఫ్ తీసుకుంటారు';

  @override
  String get nextFreeChef => 'తదుపరి: ఖాళీ చెఫ్ కోసం వేచి ఉంది';

  @override
  String get nextPrintKot => 'తదుపరి: కిచెన్ కోసం KOT ప్రింట్ చేయండి';

  @override
  String nextChefStarts(String chef) {
    return 'తదుపరి: $chef వంట మొదలుపెడతారు';
  }

  @override
  String nowCooking(String chef) {
    return '$chef వండుతున్నారు';
  }

  @override
  String get nowCookingPaper =>
      'ప్రింటెడ్ KOT నుండి వండుతున్నారు. సిద్ధమైనప్పుడు \'సిద్ధం\' నొక్కండి';

  @override
  String get nextServe => 'తదుపరి: టేబుల్‌కి అందించండి';

  @override
  String get nextBill => 'తదుపరి: టేబుల్‌కి బిల్ చేయండి';

  @override
  String get notPickedUp => 'సమయానికి ఎవరూ తీసుకోలేదు';

  @override
  String pickupOverdueToast(int number, String place) {
    return 'ఆర్డర్ #$number ($place) ఇంకా ఎవరూ తీసుకోలేదు';
  }

  @override
  String get billPending => 'బిల్ పెండింగ్';

  @override
  String get billNow => 'బిల్';

  @override
  String get tabOrders => 'ఆర్డర్లు';

  @override
  String get ordersToday2 => 'ఈరోజు';

  @override
  String get noOrdersYet => 'ఇంకా ఆర్డర్లు లేవు';

  @override
  String get billed => 'బిల్ అయింది';

  @override
  String get servingMode => 'భోజనం టేబుల్‌కి ఎలా వస్తుంది';

  @override
  String get serveByWaiter => 'వెయిటర్ అందిస్తారు';

  @override
  String get serveAtCounter => 'కస్టమర్ కౌంటర్ వద్ద తీసుకుంటారు';

  @override
  String get servingModeHelp =>
      'కౌంటర్: సిద్ధమైనప్పుడు కస్టమర్‌కి తీసుకోమని చెబుతుంది; \'అందించారు\' దశ ఉండదు.';

  @override
  String get pickupAlert => 'ఈ సమయంలో చెఫ్ తీసుకోకపోతే హెచ్చరిక';

  @override
  String get pickupAlertHelp =>
      'అడ్మిన్‌లు మరియు షిఫ్ట్‌లో ఉన్న చెఫ్‌లకు గట్టి హెచ్చరిక వస్తుంది.';

  @override
  String get off => 'ఆఫ్';

  @override
  String get collectAtCounter => 'సిద్ధం! దయచేసి కౌంటర్ వద్ద తీసుకోండి.';

  @override
  String get changePassword => 'పాస్‌వర్డ్ మార్చండి';

  @override
  String get currentPassword => 'ప్రస్తుత పాస్‌వర్డ్';

  @override
  String get newPassword => 'కొత్త పాస్‌వర్డ్';

  @override
  String get confirmNewPassword => 'కొత్త పాస్‌వర్డ్ మళ్లీ టైప్ చేయండి';

  @override
  String get passwordsDontMatch => 'రెండు కొత్త పాస్‌వర్డ్‌లు సరిపోలలేదు';

  @override
  String get passwordChanged =>
      'పాస్‌వర్డ్ మారింది. ఇతర పరికరాల నుండి సైన్ అవుట్ అయింది.';

  @override
  String get errWrongPassword => 'ప్రస్తుత పాస్‌వర్డ్ తప్పు';

  @override
  String get errSamePassword => 'వేరే పాస్‌వర్డ్ ఎంచుకోండి';

  @override
  String get resetPassword => 'పాస్‌వర్డ్ రీసెట్';

  @override
  String resetPasswordFor(String name) {
    return '$name కోసం పాస్‌వర్డ్ రీసెట్';
  }

  @override
  String get resetPasswordHelp =>
      'వారు అన్ని పరికరాల నుండి సైన్ అవుట్ అవుతారు. కొత్త పాస్‌వర్డ్‌ను నేరుగా ఇవ్వండి; వారు ప్రొఫైల్ నుండి మార్చుకోవచ్చు.';

  @override
  String passwordResetDone(String name) {
    return '$name పాస్‌వర్డ్ రీసెట్ అయింది';
  }

  @override
  String get periodToday => 'ఈరోజు';

  @override
  String get periodWeek => 'గత 7 రోజులు';

  @override
  String get myCooking => 'మీ వంట';

  @override
  String get myServing => 'మీ సర్వింగ్';

  @override
  String get myBilling => 'మీ బిల్లింగ్';

  @override
  String get statOrdersCooked => 'వండిన ఆర్డర్లు';

  @override
  String get statItemsCooked => 'వండిన ఐటమ్స్';

  @override
  String get statAvgCook => 'సగటు వంట సమయం';

  @override
  String get statAvgWaitStart => 'మొదలుపెట్టే ముందు నిరీక్షణ';

  @override
  String get statInQueue => 'ఇప్పుడు మీ క్యూలో';

  @override
  String get statOrdersServed => 'అందించిన ఆర్డర్లు';

  @override
  String get statTablesServed => 'సర్వ్ చేసిన టేబుల్స్';

  @override
  String get statAvgServe => 'సిద్ధం నుండి టేబుల్ వరకు సగటు';

  @override
  String get statOrdersTaken => 'మీరు తీసుకున్న ఆర్డర్లు';

  @override
  String get statReadyNow => 'ఇప్పుడు అందించడానికి సిద్ధం';

  @override
  String get statBillsRaised => 'తయారుచేసిన బిల్లులు';

  @override
  String get statCollected => 'వసూలు';

  @override
  String get statUnpaidNow => 'ఇప్పుడు చెల్లించని బిల్లులు';

  @override
  String teamAverage(String value) {
    return 'బృందం $value';
  }

  @override
  String minutesDecimal(String value) {
    return '$value నిమి';
  }

  @override
  String get noWorkYet => 'ఈ కాలంలో ఇంకా ఏమీ లేదు';

  @override
  String newOrdersSinceBill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ఈ బిల్ తర్వాత $count కొత్త ఆర్డర్లు',
      one: 'ఈ బిల్ తర్వాత 1 కొత్త ఆర్డర్',
    );
    return '$_temp0';
  }

  @override
  String get updateBill => 'బిల్ అప్‌డేట్ చేయండి';

  @override
  String get updateBillHelp =>
      'ప్రస్తుత బిల్ రద్దవుతుంది; ఒకే కొత్త బిల్‌లో అన్నీ ఉంటాయి.';

  @override
  String billReplaced(String old, String next) {
    return '$old రద్దయింది. $nextలో అన్ని ఆర్డర్లు ఉన్నాయి.';
  }

  @override
  String get billCancelled => 'రద్దయింది';

  @override
  String get tablesToBill => 'బిల్ చేయాల్సిన టేబుల్స్';

  @override
  String get viewOrders => 'ఆర్డర్లు';

  @override
  String get viewBills => 'బిల్లులు';

  @override
  String get yesterday => 'నిన్న';

  @override
  String get pickDates => 'తేదీలు ఎంచుకోండి';

  @override
  String get searchOrdersHint => 'ఆర్డర్ # లేదా టేబుల్';

  @override
  String get searchBillsHint => 'బిల్ # లేదా టేబుల్';

  @override
  String get loadMore => 'మరిన్ని చూపించు';

  @override
  String get noBillsYet => 'ఈ కాలంలో బిల్లులు లేవు';

  @override
  String get errRangeTooLong => 'గరిష్టంగా 31 రోజులు ఎంచుకోండి';

  @override
  String get openBill => 'బిల్ తెరవండి';

  @override
  String get statusPaid => 'చెల్లించారు';

  @override
  String printedTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సార్లు ప్రింట్ అయింది',
      one: 'ఒకసారి ప్రింట్ అయింది',
    );
    return '$_temp0';
  }

  @override
  String get takeaway => 'టేక్‌అవే';

  @override
  String get newTakeaway => 'టేక్‌అవే';

  @override
  String takeawayTitle(int number) {
    return 'టేక్‌అవే #$number';
  }

  @override
  String takeawayTitleFor(int number, String name) {
    return 'టేక్‌అవే #$number · $name';
  }

  @override
  String takeawayFor(String name) {
    return 'టేక్‌అవే · $name';
  }

  @override
  String get guestName => 'అతిథి పేరు (ఐచ్ఛికం)';

  @override
  String get guestPhone => 'ఫోన్ (ఐచ్ఛికం)';

  @override
  String get handedOver => 'అందజేశారు';

  @override
  String get nextHandOver => 'తదుపరి: అతిథికి అందజేయండి';

  @override
  String get nextBillOrder => 'తదుపరి: ఈ ఆర్డర్‌కి బిల్ చేయండి';

  @override
  String get channelTakeaway => 'టేక్‌అవే';

  @override
  String billForOrder(String title) {
    return 'బిల్ · $title';
  }

  @override
  String get discount => 'డిస్కౌంట్';

  @override
  String get addDiscount => 'డిస్కౌంట్ ఇవ్వండి';

  @override
  String get discountByPercent => 'శాతం';

  @override
  String get discountByAmount => 'మొత్తం (₹)';

  @override
  String get discountValue => 'ఎంత';

  @override
  String get discountReason => 'కారణం (బిల్‌పై ముద్రించబడుతుంది)';

  @override
  String discountLimit(String limit) {
    return 'మీ పరిమితి: $limit';
  }

  @override
  String get discountHelp =>
      'డిస్కౌంట్ తర్వాత పన్ను మళ్లీ లెక్కించబడుతుంది. ముద్రించిన బిల్ కొత్తదానితో మార్చబడుతుంది.';

  @override
  String get taxableValue => 'పన్ను విధించదగిన విలువ';

  @override
  String get maxBillDiscount => 'గరిష్ట బిల్ డిస్కౌంట్';

  @override
  String errDiscountLimit(String limit) {
    return 'అది మీ పాత్ర ఇవ్వగలిగిన దానికంటే ఎక్కువ ($limit)';
  }

  @override
  String get errBadDiscount => 'సరైన డిస్కౌంట్ మరియు కారణం ఇవ్వండి';

  @override
  String get noDiscountAllowed => 'మీ పాత్ర డిస్కౌంట్ ఇవ్వలేదు';

  @override
  String get paidSoFar => 'చెల్లించారు';

  @override
  String get dueNow => 'బకాయి';

  @override
  String get payPart => 'కొంత చెల్లించండి';

  @override
  String get splitEqually => 'సమానంగా పంచండి';

  @override
  String get howManyGuests => 'ఎంత మంది అతిథులు?';

  @override
  String guestShare(int n, String amount) {
    return 'అతిథి $n: $amount';
  }

  @override
  String get payThisShare => 'ఈ భాగం చెల్లించండి';

  @override
  String get amountReceived => 'అందిన మొత్తం';

  @override
  String get paymentRef => 'రిఫరెన్స్ (ఐచ్ఛికం)';

  @override
  String get removePayment => 'ఈ చెల్లింపును తొలగించండి';

  @override
  String get payMixed => 'మిశ్రమం';

  @override
  String errOverpayment(String due) {
    return 'అది బకాయి కంటే ఎక్కువ ($due)';
  }

  @override
  String get errHasPayments =>
      'ఈ బిల్‌లో కొంత చెల్లించారు. ముందు ఆ చెల్లింపులను తొలగించండి.';

  @override
  String get errPaymentsExceedTotal =>
      'కొత్త మొత్తం కంటే ఎక్కువ చెల్లించారు. ముందు ఒక చెల్లింపును తొలగించండి.';

  @override
  String get payWholeDue => 'బకాయి మొత్తం చెల్లించండి';

  @override
  String get reportsTitle => 'రిపోర్టులు';

  @override
  String get reportSales => 'అమ్మకాలు';

  @override
  String get reportItems => 'ఐటమ్స్';

  @override
  String get reportGst => 'GST';

  @override
  String get reportStaff => 'సిబ్బంది';

  @override
  String get downloadCsv => 'CSV డౌన్‌లోడ్';

  @override
  String get billsRegisterCsv => 'బిల్లుల రిజిస్టర్ (CSV)';

  @override
  String fileSaved(String name) {
    return '$name సేవ్ అయింది';
  }

  @override
  String get basisSales =>
      'హోటల్ తేదీలో ఇచ్చిన బిల్లులు. రద్దైన బిల్లులు వేరుగా చూపబడతాయి, అమ్మకాల్లో కలపవు.';

  @override
  String get basisItems =>
      'ఇచ్చిన బిల్లుల్లోని వంటకాలు, ప్రింట్ అయినట్లే. రద్దైన బిల్లులు లేవు.';

  @override
  String basisGst(String sac) {
    return 'ప్రతి బిల్లుపై ప్రింట్ అయిన పన్ను, రేటు వారీగా. B2C, రాష్ట్రం లోపల (CGST + SGST). SAC $sac.';
  }

  @override
  String get basisStaff =>
      'ప్రతి వ్యక్తి చేసిన బిల్లులు, ఇచ్చిన డిస్కౌంట్లు, తీసుకున్న డబ్బు.';

  @override
  String get ladderGross => 'మొత్తం (మెనూ విలువ)';

  @override
  String get ladderDiscount => 'డిస్కౌంట్లు';

  @override
  String get ladderTaxable => 'పన్ను విధించే విలువ';

  @override
  String get ladderOtherTax => 'ఇతర పన్ను';

  @override
  String get ladderRoundOff => 'రౌండ్ ఆఫ్';

  @override
  String get ladderTotal => 'బిల్లు మొత్తం';

  @override
  String repBills(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count బిల్లులు',
      one: '1 బిల్లు',
    );
    return '$_temp0';
  }

  @override
  String repReplaced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ఎక్కువ ఆర్డర్ వల్ల $count బిల్లులు మార్చబడ్డాయి',
      one: 'ఎక్కువ ఆర్డర్ వల్ల 1 బిల్లు మార్చబడింది',
    );
    return '$_temp0';
  }

  @override
  String get repReceived => 'వచ్చిన డబ్బు';

  @override
  String repUnbilled(int count, String amount) {
    return 'ఇంకా బిల్ కాలేదు: $count ఆర్డర్లు, $amount';
  }

  @override
  String get repUnbilledHelp =>
      'వీటికి బిల్ చేయండి లేదా ఆర్డర్ రద్దు చేయండి. ఇవి అమ్మకాల్లో లెక్కించబడవు.';

  @override
  String get repByDay => 'రోజు వారీగా';

  @override
  String get repNoBills => 'ఈ తేదీల్లో బిల్లులు లేవు';

  @override
  String repSold(int qty) {
    return '$qty అమ్ముడయ్యాయి';
  }

  @override
  String gstRate(String rate) {
    return 'GST $rate';
  }

  @override
  String get gstDocuments => 'జారీ చేసిన పత్రాలు';

  @override
  String gstDocCounts(
    String from,
    String to,
    int count,
    int cancelled,
    int net,
  ) {
    return '$from నుండి $to: $count జారీ, $cancelled రద్దు, $net నికరం';
  }

  @override
  String get docTaxInvoice => 'టాక్స్ ఇన్వాయిస్';

  @override
  String get docBillOfSupply => 'బిల్ ఆఫ్ సప్లై';

  @override
  String get docBill => 'బిల్లు';

  @override
  String staffDiscounts(int count, String amount) {
    return '$count డిస్కౌంట్లు · $amount';
  }

  @override
  String staffCancelled(int count) {
    return '$count బిల్లులు చేతితో రద్దు';
  }

  @override
  String get noStaffActivity =>
      'ఈ తేదీల్లో సిబ్బంది బిల్లులు లేదా చెల్లింపులు లేవు';

  @override
  String errRangeTooLongDays(int days) {
    return 'గరిష్టంగా $days రోజులు ఎంచుకోండి';
  }

  @override
  String unbilledToday(String amount) {
    return 'ఈరోజు ఇంకా బిల్ కానివి: $amount';
  }

  @override
  String get splitByItems => 'ఐటమ్స్ వారీగా విభజించండి';

  @override
  String get splitByItemsHelp =>
      'ఒక గెస్ట్‌ను నొక్కితే ఒకటి వారికి; x తో వెనక్కి. షేర్డ్: టిక్ చేసిన గెస్ట్‌లు సమానంగా చెల్లిస్తారు.';

  @override
  String get guestsCount => 'గెస్ట్‌లు';

  @override
  String guestN(int n) {
    return 'గెస్ట్ $n';
  }

  @override
  String guestUnits(int n, int count) {
    return 'గెస్ట్ $n · $count';
  }

  @override
  String guestNofM(int n, int m) {
    return '$m లో గెస్ట్ $n';
  }

  @override
  String splitLeft(int count) {
    return '$count మిగిలాయి';
  }

  @override
  String get splitShared => 'షేర్డ్';

  @override
  String splitCreate(int count) {
    return '$count బిల్లులు చేయండి';
  }

  @override
  String get splitIncomplete =>
      'ప్రతి వంటకం ఎవరికైనా ఇవ్వండి, ప్రతి గెస్ట్‌కు ఏదో ఒకటి ఉండాలి';

  @override
  String splitDone(int count) {
    return '$count గెస్ట్ బిల్లులు జారీ అయ్యాయి';
  }

  @override
  String get guestBills => 'గెస్ట్ బిల్లులు';

  @override
  String get splitNothing => 'ఈ టేబుల్‌లో విభజించడానికి ఇంకా ఏమీ లేదు';

  @override
  String get errLinesChanged => 'టేబుల్ ఐటమ్స్ మారాయి. జాబితా రిఫ్రెష్ అయింది.';

  @override
  String get errSplitPartlyPaid =>
      'ఒక గెస్ట్ ఇప్పటికే చెల్లించారు, ఈ విభజనను రద్దు చేయలేరు.';

  @override
  String get errBillDiscounted =>
      'ఈ బిల్లుకు డిస్కౌంట్ ఉంది. ముందు దాన్ని రద్దు చేసి, తర్వాత విభజించండి.';

  @override
  String get chooseSize => 'సైజ్ ఎంచుకోండి';

  @override
  String pickUpTo(int max) {
    return 'గరిష్టంగా $max';
  }

  @override
  String pickExactly(int n) {
    return '$n ఎంచుకోండి';
  }

  @override
  String pickBetween(int min, int max) {
    return '$min నుండి $max ఎంచుకోండి';
  }

  @override
  String get addToOrder => 'జోడించు';

  @override
  String get hasOptions => 'సైజ్‌లు / యాడ్-ఆన్‌లు';

  @override
  String get errVariantRequired => 'ముందు సైజ్ ఎంచుకోండి';

  @override
  String get errAddonCount => 'యాడ్-ఆన్ ఎంపికలను సరిచూడండి';

  @override
  String get removeLine => 'తీసివేయి';

  @override
  String get sizes => 'సైజ్‌లు';

  @override
  String get sizesHelp =>
      'రెండు లేదా అంతకంటే ఎక్కువ సైజ్‌లు, ప్రతిదానికి సొంత ధర (ఉదా. హాఫ్ ₹180, ఫుల్ ₹320). ఒకే ధరకు అమ్మాలంటే అన్నీ తీసివేయండి.';

  @override
  String get addSize => 'సైజ్ జోడించు';

  @override
  String get sizeNameHint => 'ఉదా. హాఫ్';

  @override
  String get errSizesCount =>
      'రెండు లేదా ఎక్కువ సైజ్‌లు ఇవ్వండి, లేదా ఏదీ వద్దు';

  @override
  String get errPriceInvalid => 'సరైన ధర ఇవ్వండి';

  @override
  String get addons => 'యాడ్-ఆన్‌లు';

  @override
  String get addonGroups => 'యాడ్-ఆన్ గ్రూప్‌లు';

  @override
  String get addonGroupsHelp =>
      'ఒకసారి గ్రూప్ చేయండి (ఉదా. ఎక్స్‌ట్రాస్, బ్రెడ్ ఎంచుకోండి), ఏ వంటకంతోనైనా ఇవ్వండి.';

  @override
  String get newGroup => 'కొత్త గ్రూప్';

  @override
  String get groupNameHint => 'ఉదా. ఎక్స్‌ట్రాస్';

  @override
  String get minPicks => 'కనీసం';

  @override
  String get maxPicks => 'గరిష్టంగా';

  @override
  String get addAddon => 'యాడ్-ఆన్ జోడించు';

  @override
  String get addonNameHint => 'ఉదా. రైతా';

  @override
  String usedBy(String names) {
    return 'వాడేవి: $names';
  }

  @override
  String get notUsedYet => 'ఇంకా ఏ వంటకంతోనూ ఇవ్వలేదు';

  @override
  String addonsForItem(String item) {
    return '$item తో ఏ యాడ్-ఆన్ గ్రూప్‌లు ఇవ్వాలో ఎంచుకోండి.';
  }

  @override
  String get noAddonGroups =>
      'ఇంకా యాడ్-ఆన్ గ్రూప్‌లు లేవు. యాడ్-ఆన్ గ్రూప్‌లలో ఒకటి చేయండి.';

  @override
  String deleteGroupConfirm(String name) {
    return '$name తొలగించాలా? దాన్ని వాడే వంటకాలు ఇక ఇవ్వవు. ఇప్పటికే చేసిన ఆర్డర్లు మారవు.';
  }

  @override
  String get saved => 'సేవ్ అయింది';

  @override
  String offerBadge(String name, String percent, String time) {
    return '$name −$percent $time వరకు';
  }

  @override
  String get happyHour => 'హ్యాపీ అవర్';

  @override
  String get happyHourHelp =>
      'ఎంచుకున్న రోజులు, సమయాల్లో వంటకం లేదా సైజ్ ధరపై శాతం తగ్గింపు, ప్రతి ఆర్డర్‌కు (వెయిటర్ లేదా QR). యాడ్-ఆన్‌ల ధర మారదు; ఆఫర్లు కలవవు.';

  @override
  String get newOffer => 'కొత్త ఆఫర్';

  @override
  String get offerNameHint => 'ఉదా. హ్యాపీ అవర్';

  @override
  String get percentOff => 'శాతం తగ్గింపు';

  @override
  String get days => 'రోజులు';

  @override
  String get fromTime => 'నుండి';

  @override
  String get toTime => 'వరకు';

  @override
  String get appliesTo => 'వర్తించేది';

  @override
  String get wholeMenu => 'మొత్తం మెనూ';

  @override
  String get offerOn => 'ఆన్';

  @override
  String get noOffers => 'ఇంకా ఆఫర్లు లేవు';

  @override
  String offerSummary(String percent, String days, String from, String to) {
    return '$percent తగ్గింపు · $days · $from–$to';
  }

  @override
  String get everyDay => 'ప్రతి రోజు';

  @override
  String get errBadPercent => '0.01 నుండి 90 మధ్య శాతం ఇవ్వండి';

  @override
  String get errSameTimes => 'ప్రారంభ, ముగింపు సమయాలు వేరుగా ఉండాలి';

  @override
  String get combo => 'కాంబో';

  @override
  String get comboHelp =>
      'ఈ కాంబోలోని వంటకాలను జాబితా చేయండి. దాని ధర, పన్ను దానివే. ఎంపిక కోసం (ఉదా. డ్రింక్) 1 ఎంచుకునే యాడ్-ఆన్ గ్రూప్ జోడించండి.';

  @override
  String get comboNeedsTwo =>
      'కాంబోకు కనీసం రెండు వంటకాలు కావాలి. సాధారణ వంటకంగా చేయాలంటే అన్నీ తీసివేయండి.';

  @override
  String get errBadCombo =>
      'ఆ కాంబో అనుమతించబడదు (కాంబోలో తానే లేదా మరో కాంబో ఉండకూడదు, రెండు వంటకాలు కావాలి)';

  @override
  String get errItemInCombo =>
      'ఈ వంటకం ఒక కాంబోలో ఉంది. ముందు కాంబో నుండి తీసివేయండి, లేదా సోల్డ్ అవుట్ చేయండి.';

  @override
  String get editCategory => 'కేటగిరీ మార్చు';

  @override
  String get servingHours => 'వడ్డించే సమయం';

  @override
  String get servedAllDay => 'రోజంతా వడ్డిస్తారు';

  @override
  String servedHours(String hours) {
    return '$hours వడ్డిస్తారు';
  }

  @override
  String get outsideHoursTitle => 'ఇప్పుడు వడ్డించరు';

  @override
  String outsideHoursBody(String items, String category, String hours) {
    return '$items ($category, $hours) వడ్డించే సమయం దాటింది. అయినా ఆర్డర్ చేయాలా?';
  }

  @override
  String get orderAnyway => 'అయినా ఆర్డర్ చేయి';

  @override
  String get errOutsideHours => 'ఈ సమయంలో వడ్డించరు';

  @override
  String get closeDay => 'రోజు ముగించు';

  @override
  String get closeDayHelp =>
      'ఈరోజు ప్రతి డివైస్‌లో నమోదైన దాని ప్రకారం డ్రాయర్‌లో ఉండాల్సిన మొత్తం. నగదు లెక్కించి క్రింద ఇవ్వండి.';

  @override
  String get today => 'ఈరోజు';

  @override
  String get history => 'చరిత్ర';

  @override
  String get openingFloat => 'ప్రారంభ నగదు';

  @override
  String get cashReceived => 'వచ్చిన నగదు';

  @override
  String get cashPaidOut => 'చెల్లించిన నగదు (ఖర్చులు)';

  @override
  String get expectedInDrawer => 'డ్రాయర్‌లో ఉండాల్సింది';

  @override
  String get countedCash => 'లెక్కించిన నగదు';

  @override
  String get keepForTomorrow => 'రేపటికి డ్రాయర్‌లో ఉంచేది';

  @override
  String toDeposit(String amount) {
    return 'బ్యాంకుకు: $amount';
  }

  @override
  String cashOver(String amount) {
    return 'ఎక్కువ $amount';
  }

  @override
  String cashShort(String amount) {
    return 'తక్కువ $amount';
  }

  @override
  String get cashExact => 'సరిగ్గా';

  @override
  String get whyDifferent => 'ఎందుకు తేడా? (అవసరం)';

  @override
  String get closeDayButton => 'రోజు ముగించండి';

  @override
  String get closeDayConfirm => 'ఇది తుది. రేపటి ప్రారంభ నగదు మీరు ఉంచేదే.';

  @override
  String dayClosedBy(String name, String time) {
    return '$time కి $name ముగించారు';
  }

  @override
  String cashAfterClose(String amount) {
    return 'ముగించిన తర్వాత వచ్చిన నగదు: $amount';
  }

  @override
  String unpaidBillsWarning(int count, String amount) {
    return '$count బిల్లులు ఇంకా చెల్లించలేదు ($amount)';
  }

  @override
  String shortDays(int count) {
    return '$count తక్కువ రోజులు';
  }

  @override
  String netOverShort(String amount) {
    return 'మొత్తం ఎక్కువ/తక్కువ: $amount';
  }

  @override
  String get noCloses => 'ఇంకా ఏ రోజూ ముగించలేదు';

  @override
  String get errNoteRequired => 'నగదు ఎందుకు ఎక్కువ/తక్కువో చెప్పండి';

  @override
  String get errAlreadyClosed => 'ఈ రోజు ఇప్పటికే ముగిసింది';

  @override
  String get seated => 'కూర్చున్నారు';

  @override
  String get cleaning => 'శుభ్రం చేస్తున్నారు';

  @override
  String get reserved => 'రిజర్వ్';

  @override
  String get seatGuests => 'అతిథులను కూర్చోబెట్టు';

  @override
  String get guestsCountLabel => 'ఎంత మంది అతిథులు?';

  @override
  String guestsAndTime(String guests, int minutes) {
    return '$guests · $minutes ని';
  }

  @override
  String guestsN(int count) {
    return '$count అతిథులు';
  }

  @override
  String get markClean => 'శుభ్రం';

  @override
  String get reserve => 'రిజర్వ్ చేయి';

  @override
  String get reserveNoteHint => 'ఉదా. రాత్రి 8, 4 మంది';

  @override
  String get cancelReservation => 'రిజర్వేషన్ రద్దు';

  @override
  String get guestsLeft => 'అతిథులు వెళ్లారు (టేబుల్ ఖాళీ)';

  @override
  String get changeGuests => 'అతిథుల సంఖ్య మార్చు';

  @override
  String coversLine(int covers) {
    return '$covers అతిథులు';
  }

  @override
  String avgPerGuest(String amount) {
    return 'ఒక్కో అతిథికి సగటు: $amount';
  }

  @override
  String get errTableInUse => 'ఈ టేబుల్ వద్ద అతిథులు ఉన్నారు';

  @override
  String get moveTable => 'మార్చు';

  @override
  String get mergeTables => 'కలపండి';

  @override
  String get moveTo => 'ఏ టేబుల్‌కు మార్చాలి?';

  @override
  String get mergeWhich => 'ఏ టేబుల్‌లు దీనితో కలవాలి?';

  @override
  String get noFreeTables => 'ఇప్పుడు ఖాళీ టేబుల్ లేదు';

  @override
  String get noOtherBusy => 'వేరే టేబుల్‌లో అతిథులు లేరు';

  @override
  String movedTo(String label) {
    return 'టేబుల్ $label కు మార్చారు';
  }

  @override
  String mergedInto(String label) {
    return 'టేబుల్ $label లో కలిపారు';
  }

  @override
  String get errTableHasBill =>
      'ఈ టేబుల్‌కు బిల్లు ఉంది. ముందు చెల్లించండి లేదా రద్దు చేయండి.';

  @override
  String get bookings => 'బుకింగ్‌లు';

  @override
  String get waitlist => 'వెయిట్‌లిస్ట్';

  @override
  String get newBooking => 'కొత్త బుకింగ్';

  @override
  String get addToWaitlist => 'వెయిట్‌లిస్ట్‌లో చేర్చు';

  @override
  String get tableOptional => 'టేబుల్ (ఐచ్ఛికం)';

  @override
  String get anyTable => 'ఏ టేబుల్ అయినా';

  @override
  String get quotedWait => 'అతిథికి చెప్పిన వేచి సమయం (నిమిషాలు)';

  @override
  String avgWaitToday(int minutes) {
    return 'ఈరోజు నిజమైన సగటు వేచి సమయం: $minutes ని';
  }

  @override
  String waitedOfQuoted(int waited, int quoted) {
    return '$waited ని వేచి ఉన్నారు (చెప్పింది $quoted)';
  }

  @override
  String waitedMin(int waited) {
    return '$waited ని వేచి ఉన్నారు';
  }

  @override
  String get seat => 'కూర్చోబెట్టు';

  @override
  String get noShow => 'రాలేదు';

  @override
  String get cancelBooking => 'రద్దు';

  @override
  String noShowsBefore(int count) {
    return '$count సార్లు ముందు రాలేదు';
  }

  @override
  String get noBookingsDay => 'ఈ రోజుకు బుకింగ్‌లు లేవు';

  @override
  String get nobodyWaiting => 'ఎవరూ వేచి లేరు';

  @override
  String bookedAt(String time, String name) {
    return 'బుక్ $time · $name';
  }

  @override
  String get pickTable => 'టేబుల్ ఎంచుకోండి';

  @override
  String get bookingStatusSeated => 'కూర్చున్నారు';

  @override
  String get bookingStatusCancelled => 'రద్దు';

  @override
  String tableBookedWarn(String name, String time) {
    return '$time కి ఈ టేబుల్ $name కి బుక్ అయింది. అయినా బుక్ చేయాలా?';
  }

  @override
  String get bookAnyway => 'అయినా బుక్ చేయి';

  @override
  String get errPastTime => 'ఆ సమయం దాటిపోయింది';

  @override
  String get stations => 'స్టేషన్లు';

  @override
  String get stationsHelp =>
      'వాటి సొంత టికెట్, స్క్రీన్ ఉండే వంటగది విభాగాలు, ఉదా. బార్, తందూర్. స్టేషన్ లేని వంటకాలు ప్రధాన వంటగదికి వెళ్తాయి.';

  @override
  String get newStationHint => 'ఉదా. బార్';

  @override
  String get mainKitchen => 'వంటగది';

  @override
  String get station => 'స్టేషన్';

  @override
  String get followCategory => 'కేటగిరీ లాగే';

  @override
  String get allStations => 'అన్ని స్టేషన్లు';

  @override
  String goesTo(String station) {
    return 'వెళ్తుంది: $station';
  }

  @override
  String get errStationExists => 'ఈ పేరుతో స్టేషన్ ఇప్పటికే ఉంది';

  @override
  String vsLastWeek(String weekday) {
    return 'గత $weekday ఇదే సమయంతో పోలిస్తే';
  }

  @override
  String upBy(String amount, String pct) {
    return '$amount పెరిగింది ($pct%)';
  }

  @override
  String downBy(String amount, String pct) {
    return '$amount తగ్గింది ($pct%)';
  }

  @override
  String get sameAsLastWeek => 'గత వారం లాగానే';

  @override
  String get noSalesToCompare => 'పోల్చడానికి అమ్మకాలు లేవు';

  @override
  String get receivedToday => 'ఈరోజు వచ్చిన డబ్బు';

  @override
  String sharePct(String pct) {
    return '$pct%';
  }
}
