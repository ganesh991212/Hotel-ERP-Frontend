// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Vethra';

  @override
  String get signInTitle => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to run your restaurant.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get loginHeadline => 'Orders, kitchen and money in one calm place.';

  @override
  String get loginPointQr => 'Table QR ordering';

  @override
  String get loginPointKitchen => 'Live chef queues';

  @override
  String get loginPointDashboards => 'Daily dashboards';

  @override
  String get yourProfile => 'Your profile';

  @override
  String get settings => 'Settings';

  @override
  String get alerts => 'Alerts';

  @override
  String get noAlerts => 'Nothing needs you right now';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get more => 'More';

  @override
  String get add => 'Add';

  @override
  String get increase => 'Increase';

  @override
  String get decrease => 'Decrease';

  @override
  String get all => 'All';

  @override
  String get name => 'Name';

  @override
  String get status => 'Status';

  @override
  String get role => 'Role';

  @override
  String get phone => 'Phone';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get date => 'Date';

  @override
  String get type => 'Type';

  @override
  String get reason => 'Reason';

  @override
  String get reasonAuditedHelp => 'Saved in the audit log.';

  @override
  String get defaultReason => 'Changed by platform admin';

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabHotels => 'Hotels';

  @override
  String get tabPlans => 'Plans';

  @override
  String get tabFloor => 'Floor';

  @override
  String get tabKitchen => 'Kitchen';

  @override
  String get tabMenu => 'Menu';

  @override
  String get tabTables => 'Tables';

  @override
  String get tabTeam => 'Team';

  @override
  String get tabExpenses => 'Expenses';

  @override
  String goodMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String goodAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String goodEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String get waiting => 'Waiting';

  @override
  String get cooking => 'Cooking';

  @override
  String get tablesBusy => 'Tables busy';

  @override
  String get servedToday => 'Served';

  @override
  String get ordersToday => 'Orders today';

  @override
  String get revenueToday => 'Revenue today';

  @override
  String get avgPrep => 'Avg prep';

  @override
  String get thisMonth => 'This month';

  @override
  String expensesAmount(String amount) {
    return 'Expenses $amount';
  }

  @override
  String netAmount(String amount) {
    return 'Net $amount';
  }

  @override
  String get ordersByHour => 'Orders by hour';

  @override
  String get ordersSoFarToday => 'orders so far today';

  @override
  String get openFloor => 'Open floor';

  @override
  String get openKitchen => 'Open kitchen';

  @override
  String get kitchenPace => 'Kitchen pace';

  @override
  String get avgPrepMinutes => 'avg minutes to cook';

  @override
  String chefsOnShift(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chefs on shift',
      one: '1 chef on shift',
    );
    return '$_temp0';
  }

  @override
  String cookingNow(int count) {
    return '$count cooking';
  }

  @override
  String get servedShare => 'Served today';

  @override
  String get liveOrders => 'Live orders';

  @override
  String get noLiveOrders => 'No open orders';

  @override
  String get topDishes => 'Top dishes';

  @override
  String get chefs => 'Chefs';

  @override
  String get avgTicket => 'Average ticket';

  @override
  String get perOrderToday => 'per order today';

  @override
  String get noDataYet => 'No data yet';

  @override
  String get noChefsYet => 'No chefs added yet';

  @override
  String soldCount(int count) {
    return '$count sold';
  }

  @override
  String doneCount(int count) {
    return '$count done';
  }

  @override
  String get revenueLast7Days => 'Revenue, last 7 days';

  @override
  String get statusPlaced => 'Awaiting confirmation';

  @override
  String get statusConfirmed => 'New';

  @override
  String get statusQueued => 'Queued';

  @override
  String get statusPreparing => 'Preparing';

  @override
  String get statusReady => 'Ready';

  @override
  String get statusServed => 'Served';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get channelQr => 'QR';

  @override
  String get channelWaiter => 'Server';

  @override
  String get channelAdmin => 'Admin';

  @override
  String orderNumberTable(int number, String table) {
    return '#$number · Table $table';
  }

  @override
  String tableLabel(String label) {
    return 'Table $label';
  }

  @override
  String minutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes min ago',
      one: '1 min ago',
      zero: 'just now',
    );
    return '$_temp0';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get roleHotelAdmin => 'Hotel admin';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleCashier => 'Cashier';

  @override
  String get roleWaiter => 'Server';

  @override
  String get roleChef => 'Chef';

  @override
  String get rolePlatformAdmin => 'Platform admin';

  @override
  String get live => 'Live';

  @override
  String get reconnecting => 'Reconnecting';

  @override
  String get staleBanner =>
      'Connection lost. Showing the last known queue; refreshing every few seconds.';

  @override
  String get modeChefAccept => 'Chefs pick up';

  @override
  String get modeAutoAssign => 'Auto assign';

  @override
  String get modeAdminPrint => 'Printed tickets';

  @override
  String get upForGrabs => 'New orders';

  @override
  String get waitingForChef => 'Waiting for a chef';

  @override
  String get noNewOrders => 'No new orders';

  @override
  String get noNewOrdersBody => 'New orders appear here instantly.';

  @override
  String get pickUp => 'Pick up';

  @override
  String get pickedUp => 'Order is yours';

  @override
  String get myQueue => 'My queue';

  @override
  String get queueEmpty => 'You\'re free. Pick up the next order.';

  @override
  String get offShiftBody => 'You\'re off shift. Switch on to receive orders.';

  @override
  String get lockedUntilHead => 'Starts after the order ahead of it is ready';

  @override
  String get startCooking => 'Start cooking';

  @override
  String get started => 'Started';

  @override
  String get markReady => 'Mark ready';

  @override
  String get markedReady => 'Marked ready. The server has been told.';

  @override
  String cookingFor(int minutes, int target) {
    return 'Cooking $minutes min · target $target min';
  }

  @override
  String waitingFor(int minutes) {
    return 'Waiting $minutes min';
  }

  @override
  String get otherChefs => 'Other chefs';

  @override
  String get noOtherChefs => 'No other chefs';

  @override
  String get idle => 'Idle';

  @override
  String get onShift => 'On shift';

  @override
  String get offShift => 'Off shift';

  @override
  String get returnToBoard => 'Return to board';

  @override
  String get readyToServe => 'Ready to serve';

  @override
  String get nothingWaiting => 'Nothing waiting to be served';

  @override
  String get serve => 'Serve';

  @override
  String get needsAttention => 'Needs attention';

  @override
  String get allCalm => 'All calm. Nothing to confirm or serve.';

  @override
  String get markServed => 'Served';

  @override
  String get confirmOrder => 'Confirm';

  @override
  String get noTables => 'No tables yet';

  @override
  String get noTablesBody => 'Add tables to print their QR codes.';

  @override
  String seats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seats',
      one: '1 seat',
    );
    return '$_temp0';
  }

  @override
  String get seatsLabel => 'Seats';

  @override
  String get inactive => 'Inactive';

  @override
  String get free => 'Free';

  @override
  String get openOrders => 'Open orders';

  @override
  String get cannotTakeOrders => 'Your role can\'t take orders here.';

  @override
  String get searchMenu => 'Search the menu';

  @override
  String get kitchenNoteHint => 'Note for the kitchen (optional)';

  @override
  String get sendToKitchen => 'Send to kitchen';

  @override
  String get orderSent => 'Order sent to the kitchen';

  @override
  String get soldOut => 'Sold out';

  @override
  String get veg => 'Veg';

  @override
  String get nonVeg => 'Non-veg';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get tax => 'GST';

  @override
  String get serviceCharge => 'Service charge';

  @override
  String get total => 'Total';

  @override
  String get addCategory => 'Add category';

  @override
  String get addItem => 'Add item';

  @override
  String get editItem => 'Edit item';

  @override
  String get addCategoryFirst => 'Add a category first';

  @override
  String get menuEmpty => 'Your menu is empty';

  @override
  String get menuEmptyBody => 'Add a category, then your dishes.';

  @override
  String get noMatches => 'Nothing matches';

  @override
  String get category => 'Category';

  @override
  String get price => 'Price';

  @override
  String get prepTime => 'Prep time';

  @override
  String get availability => 'Availability';

  @override
  String get available => 'Available';

  @override
  String get priceRupees => 'Price (₹)';

  @override
  String get priceHelp =>
      'Before tax. GST is added automatically if you are registered.';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get addTable => 'Add table';

  @override
  String get tableName => 'Table name';

  @override
  String get tableNameHelp => 'Short and unique, like T1 or P2.';

  @override
  String get areaOptional => 'Area (optional)';

  @override
  String get copyLink => 'Copy link';

  @override
  String get openDinerView => 'Open diner view';

  @override
  String get rotateQr => 'Replace QR code';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get activate => 'Activate';

  @override
  String get qrActive => 'QR active';

  @override
  String openOrdersCount(int count) {
    return '$count open';
  }

  @override
  String get linkCopied => 'Link copied';

  @override
  String get qrRotated =>
      'New QR created. Print it; the old one no longer works.';

  @override
  String get people => 'People';

  @override
  String get rolesAndAccess => 'Roles & access';

  @override
  String get searchPeople => 'Search by name or role';

  @override
  String get addMember => 'Add member';

  @override
  String get newRole => 'New role';

  @override
  String get newRoleLocked => 'Custom roles (upgrade)';

  @override
  String get newRoleHelp => 'Then tick what this role can do.';

  @override
  String get permission => 'Permission';

  @override
  String get adminLocked => 'Hotel admins always have every permission';

  @override
  String get disabled => 'Disabled';

  @override
  String get active => 'Active';

  @override
  String makeRole(String role) {
    return 'Make $role';
  }

  @override
  String get disableAccount => 'Disable account';

  @override
  String get enableAccount => 'Enable account';

  @override
  String get emailLoginHelp => 'They sign in with this email.';

  @override
  String get tempPassword => 'Temporary password';

  @override
  String get tempPasswordHelp => 'At least 8 characters. Share it privately.';

  @override
  String get sendInvite => 'Add member';

  @override
  String get permDashboard => 'See the dashboard';

  @override
  String get permOrderView => 'See orders';

  @override
  String get permOrderCreate => 'Take orders';

  @override
  String get permOrderConfirm => 'Confirm QR orders';

  @override
  String get permOrderServe => 'Mark orders served';

  @override
  String get permOrderCancel => 'Cancel orders';

  @override
  String get permKitchenCook => 'Pick up and cook';

  @override
  String get permKitchenManage => 'Manage chef queues';

  @override
  String get permTableManage => 'Manage tables and QR';

  @override
  String get permMenuManage => 'Edit menu and prices';

  @override
  String get permMenuAvailability => 'Mark items sold out';

  @override
  String get permStaffManage => 'Manage staff';

  @override
  String get permRoleManage => 'Configure roles';

  @override
  String get permExpenseView => 'See expenses';

  @override
  String get permExpenseManage => 'Record expenses';

  @override
  String get permReportView => 'See reports';

  @override
  String get permSettingsManage => 'Settings and billing';

  @override
  String get addExpense => 'Add expense';

  @override
  String get editExpense => 'Edit expense';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get spentThisMonth => 'Spent this month';

  @override
  String get byDay => 'By day';

  @override
  String get noExpenses => 'No expenses this month';

  @override
  String get noExpensesBody => 'Record gas, groceries, salaries and more.';

  @override
  String get amountRupees => 'Amount (₹)';

  @override
  String get paidBy => 'Paid by';

  @override
  String get payCash => 'Cash';

  @override
  String get payUpi => 'UPI';

  @override
  String get payCard => 'Card';

  @override
  String get payBank => 'Bank';

  @override
  String get vendorOptional => 'Vendor (optional)';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get kitchenAndOrdering => 'Kitchen';

  @override
  String get planAndBilling => 'Plan & billing';

  @override
  String get restaurantName => 'Restaurant name';

  @override
  String get kitchenMode => 'How orders reach chefs';

  @override
  String get kitchenModeHelp => 'Locked options need a higher plan.';

  @override
  String get maxQueue => 'Orders per chef at once';

  @override
  String get maxQueueHelp =>
      'A chef can\'t hold more than this in their queue.';

  @override
  String get confirmQrOrders => 'Confirm QR orders first';

  @override
  String get confirmQrOrdersHelp =>
      'A server approves table orders before the kitchen sees them.';

  @override
  String get subActive => 'Active';

  @override
  String get subTrial => 'Trial';

  @override
  String get subPastDue => 'Payment due';

  @override
  String get subSuspended => 'Suspended';

  @override
  String perMonth(String amount) {
    return '$amount / month';
  }

  @override
  String get perMonthShort => '/ month';

  @override
  String trialEndsOn(String date) {
    return 'Trial ends $date';
  }

  @override
  String renewsOn(String date) {
    return 'Renews $date';
  }

  @override
  String get choosePlan => 'Choose a plan';

  @override
  String get choosePlanHelp =>
      'You\'ll pay securely on Razorpay. Your plan activates as soon as the payment clears.';

  @override
  String get paymentsNotConfigured =>
      'Online payment isn\'t switched on yet. Contact support to activate.';

  @override
  String get payAndActivate => 'Pay & activate';

  @override
  String get renew => 'Renew';

  @override
  String get payments => 'Payments';

  @override
  String get managePlan => 'Manage plan';

  @override
  String get bannerPastDue =>
      'Your payment is due. Pay now to avoid interruption.';

  @override
  String get bannerSuspended =>
      'Your account is paused. You can still view your data; pay to resume orders.';

  @override
  String get hotels => 'Hotels';

  @override
  String get mrr => 'Monthly revenue';

  @override
  String get orders30d => 'Orders (30 days)';

  @override
  String get collected30d => 'Collected, last 30 days';

  @override
  String trialsEnding(int count) {
    return '$count trials end this week';
  }

  @override
  String get signups => 'New hotels';

  @override
  String get planMix => 'Plan mix';

  @override
  String get recentHotels => 'Recent hotels';

  @override
  String get noHotels => 'No hotels yet';

  @override
  String get noHotelsBody => 'Register your first hotel to get started.';

  @override
  String get searchHotels => 'Search hotels';

  @override
  String get registerHotel => 'Register hotel';

  @override
  String get hotelRegistered =>
      'Hotel registered. Share the admin login with them.';

  @override
  String get hotel => 'Hotel';

  @override
  String get plan => 'Plan';

  @override
  String get city => 'City';

  @override
  String get tablesCol => 'Tables';

  @override
  String get hotelName => 'Hotel name';

  @override
  String get trialHelp => 'Every new hotel starts on a free trial.';

  @override
  String get gstRegistration => 'GST registration';

  @override
  String get gstRegular => 'Regular';

  @override
  String get gstComposition => 'Composition';

  @override
  String get gstUnregistered => 'Not registered';

  @override
  String get gstin => 'GSTIN';

  @override
  String get hotelAdmin => 'Hotel admin';

  @override
  String get suspendHotel => 'Suspend';

  @override
  String get resumeHotel => 'Resume';

  @override
  String get changePlan => 'Change plan';

  @override
  String get overrides => 'Feature overrides';

  @override
  String get overridesHelp =>
      'Turn a feature on or off for this hotel only, regardless of its plan.';

  @override
  String get overridden => 'Overridden for this hotel';

  @override
  String get fromPlan => 'From plan';

  @override
  String get placeholderPrice => 'Placeholder';

  @override
  String get editPrice => 'Edit price';

  @override
  String get monthlyPrice => 'Monthly price (₹)';

  @override
  String get priceChangeHelp =>
      'Applies to new subscriptions. Existing hotels keep their price until renewal.';

  @override
  String get features => 'Features';

  @override
  String get limits => 'Limits';

  @override
  String get limit => 'Limit';

  @override
  String get limitHelp => 'Leave empty for unlimited.';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get featQr => 'QR ordering';

  @override
  String get featWaiter => 'Server ordering';

  @override
  String get featChefAccept => 'Chefs pick up orders';

  @override
  String get featAutoRouting => 'Auto-assign to chefs';

  @override
  String get featAdminPrint => 'Printed kitchen tickets';

  @override
  String get featExpenses => 'Expenses';

  @override
  String get featCustomRoles => 'Custom roles';

  @override
  String get featReports => 'Advanced reports';

  @override
  String get featRatings => 'Ratings';

  @override
  String get featApi => 'API & webhooks';

  @override
  String get featRooms => 'Rooms';

  @override
  String get limOutlets => 'Outlets';

  @override
  String get limTables => 'Tables';

  @override
  String get limStaff => 'Staff';

  @override
  String get limChefs => 'Chefs';

  @override
  String get limMenuItems => 'Menu items';

  @override
  String get limOrders => 'Orders per month';

  @override
  String get qrInvalid => 'This QR code doesn\'t work';

  @override
  String get qrInvalidBody => 'Please ask a server for help.';

  @override
  String get dinerHeadline => 'What would you like?';

  @override
  String get dinerViewOnly =>
      'Browse the menu and tell your server when you\'re ready.';

  @override
  String get yourOrder => 'Your order';

  @override
  String get yourOrders => 'Your orders';

  @override
  String get stepSent => 'Sent';

  @override
  String get dinerNoteHint => 'Anything the kitchen should know?';

  @override
  String get pricesByRestaurant =>
      'Prices and taxes are set by the restaurant.';

  @override
  String get placeOrder => 'Place order';

  @override
  String get orderPlaced => 'Order placed. We\'ll update you here.';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get viewOrder => 'View order';

  @override
  String chefPreparing(String name) {
    return '$name is preparing it';
  }

  @override
  String get readyOnItsWay => 'Ready! It\'s on its way to your table.';

  @override
  String get printKot => 'Print KOT';

  @override
  String printKotTitle(int number) {
    return 'Print KOT #$number';
  }

  @override
  String get printKotExplain =>
      'Is the kitchen cooking from paper for this order? Sending it on paper takes it off the chefs\' screen so nobody picks it up twice.';

  @override
  String get printAndSend => 'Print and send to kitchen';

  @override
  String get printCopyOnly => 'Just print a copy';

  @override
  String get kotPrinted => 'KOT printed';

  @override
  String get kotSentOnPaper =>
      'KOT printed. The order is now with the kitchen on paper.';

  @override
  String get onPaper => 'On paper';

  @override
  String get onPaperTitle => 'Cooking from paper';

  @override
  String get onPaperHelp =>
      'Printed tickets handed to the kitchen. Mark them ready when the food comes out.';

  @override
  String get billTable => 'Bill';

  @override
  String billForTable(String label) {
    return 'Bill · Table $label';
  }

  @override
  String get billExplain =>
      'Creates one bill for every unbilled order on this table. Bills are numbered and cannot be edited.';

  @override
  String get createBill => 'Create bill';

  @override
  String notServedYet(String orders) {
    return 'Not served yet: #$orders';
  }

  @override
  String get billAnyway => 'Bill them anyway';

  @override
  String billPaid(String method) {
    return 'Paid · $method';
  }

  @override
  String get billUnpaid => 'Unpaid';

  @override
  String ordersIncluded(String orders) {
    return 'Orders #$orders';
  }

  @override
  String get cgst => 'CGST';

  @override
  String get sgst => 'SGST';

  @override
  String get printBill => 'Print bill';

  @override
  String get printDuplicate => 'Print duplicate';

  @override
  String get billPrinted => 'Bill printed';

  @override
  String get settlePayment => 'Payment received by';

  @override
  String get voidBill => 'Void bill';

  @override
  String get printerSetup => 'Printer setup';

  @override
  String get paperSize => 'Paper';

  @override
  String get paperSizeHelp =>
      'Match your printer\'s roll. A4 for office printers.';

  @override
  String get paper58 => '58 mm';

  @override
  String get paper80 => '80 mm';

  @override
  String get paperA4 => 'A4';

  @override
  String get printWith => 'Print using';

  @override
  String get printSystem => 'Print dialog';

  @override
  String get printNetwork => 'Network printer';

  @override
  String get printSystemHelp =>
      'Works with any printer this device can use: thermal, laser, inkjet, Bluetooth or USB.';

  @override
  String get printNetworkHelp =>
      'Sends straight to a Wi-Fi/LAN thermal printer. No dialog; fastest for the kitchen.';

  @override
  String get printWebHelp =>
      'In the browser, printing always opens the print dialog. Use the Android or iPhone app to print straight to a network printer.';

  @override
  String get printerIp => 'Printer IP address';

  @override
  String get port => 'Port';

  @override
  String get testPrint => 'Test print';

  @override
  String get testPrintTitle => 'TEST PRINT';

  @override
  String get testPrintBody => 'If you can read this, the printer works.';

  @override
  String get soundAlertsOn => 'Sound alerts: on';

  @override
  String get soundAlertsOff => 'Sound alerts: off';

  @override
  String get soundOn => 'Sound alerts on';

  @override
  String get soundOff => 'Sound alerts off';

  @override
  String get testSound => 'Test alert sound';

  @override
  String get soundBlocked =>
      'The browser blocked sound. Tap anywhere on the page, then try again.';

  @override
  String get serviceTimes => 'Service times';

  @override
  String get serviceTimesHelp =>
      'Orders placed today. p90 = 9 out of 10 orders were faster than this.';

  @override
  String get stageWait => 'Wait for chef';

  @override
  String get stageWaitHelp => 'Order confirmed → cooking starts';

  @override
  String get stagePrep => 'Preparation';

  @override
  String get stagePrepHelp => 'Cooking starts → ready';

  @override
  String get stageServe => 'Serving';

  @override
  String get stageServeHelp => 'Ready → on the table';

  @override
  String get stageTotal => 'Order to table';

  @override
  String get stageTotalHelp => 'What the guest feels';

  @override
  String get minAvg => 'min avg';

  @override
  String p90Line(String minutes, int count) {
    return 'p90 $minutes min · $count orders';
  }

  @override
  String get servingByServer => 'Serving time by server';

  @override
  String serverServeLine(String name, String minutes, int count) {
    return '$name: $minutes min · $count served';
  }

  @override
  String get categories => 'Categories';

  @override
  String get expenseCategories => 'Expense categories';

  @override
  String get categoriesHelp =>
      'Global categories are set for every hotel. Add your own for anything else; only your hotel sees them.';

  @override
  String get scopeGlobal => 'Global';

  @override
  String get scopeHotel => 'Yours';

  @override
  String get renameCategory => 'Rename category';

  @override
  String get addOwnCategory => 'Add your own category';

  @override
  String get addOwnCategoryHelp => 'Visible only to your hotel.';

  @override
  String get tabCategories => 'Categories';

  @override
  String get globalCategoriesHelp =>
      'Categories here appear for every hotel immediately. Switching one off hides it for new expenses; past expenses keep it.';

  @override
  String get newGlobalCategory => 'New global category';

  @override
  String get globalCategoryAdded => 'Added for every hotel';

  @override
  String usedTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'used $count times',
      one: 'used once',
      zero: 'unused',
    );
    return '$_temp0';
  }

  @override
  String get printQr => 'Print QR';

  @override
  String get printAllQr => 'Print all QR codes';

  @override
  String get enableAlerts => 'Enable alerts';

  @override
  String get enableAlertsBody =>
      'Turn on loud alerts for new and ready orders. Keep this tab open for the loud sound; when the tab is closed you get a normal notification.';

  @override
  String get enableAlertsDenied =>
      'Notifications are blocked for this site in your browser settings. Tap to turn on the loud in-page sound; keep this tab open.';

  @override
  String get notNow => 'Not now';

  @override
  String get language => 'Language';

  @override
  String get langEn => 'English';

  @override
  String get langTe => 'తెలుగు';

  @override
  String get langHi => 'हिन्दी';

  @override
  String get branding => 'Branding';

  @override
  String get hotelLogo => 'Hotel logo';

  @override
  String get hotelLogoHelp =>
      'Shown in the app and printed on table QR cards. PNG or JPEG.';

  @override
  String get uploadLogo => 'Upload logo';

  @override
  String get replaceLogo => 'Replace logo';

  @override
  String get removeLogo => 'Remove';

  @override
  String get logoUpdated => 'Logo updated';

  @override
  String get addressLine => 'Address (one line)';

  @override
  String get addressLineHelp => 'Printed under your hotel name on QR cards.';

  @override
  String get poweredByNote =>
      'QR cards end with a small \"Powered by\" line from the platform.';

  @override
  String get errGeneric => 'Something went wrong. Please try again.';

  @override
  String get errOffline => 'You\'re offline. Check the connection and retry.';

  @override
  String get errCredentials => 'Email or password is wrong.';

  @override
  String get errFeatureLocked =>
      'Your plan doesn\'t include this. Upgrade to unlock it.';

  @override
  String get errLimit => 'You\'ve reached your plan\'s limit.';

  @override
  String get errPermission => 'Your role doesn\'t allow this.';

  @override
  String get errTaken => 'Another chef already picked this order.';

  @override
  String get errQueueFull => 'Finish an order before picking another.';

  @override
  String get errNotHead => 'Finish the order ahead of this one first.';

  @override
  String get errSoldOut => 'An item just sold out. Please update your order.';

  @override
  String get errSessionExpired =>
      'Your table session ended. Scan the QR again.';

  @override
  String get errRequired => 'Required';

  @override
  String get errEmail => 'Enter a valid email';

  @override
  String get errAmount => 'Enter an amount like 250 or 99.50';

  @override
  String get errPasswordLength => 'At least 8 characters';

  @override
  String get errGstin => 'Enter a 15-character GSTIN';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get brandingSaved => 'Branding saved';

  @override
  String get nextConfirm => 'Next: confirm this order';

  @override
  String get nextChefPickup => 'Next: a chef picks it up on the Kitchen screen';

  @override
  String get nextFreeChef => 'Next: waiting for a free chef';

  @override
  String get nextPrintKot => 'Next: print the KOT for the kitchen';

  @override
  String nextChefStarts(String chef) {
    return 'Next: $chef starts cooking';
  }

  @override
  String nowCooking(String chef) {
    return '$chef is cooking';
  }

  @override
  String get nowCookingPaper =>
      'Cooking from the printed KOT. Mark ready when it comes out';

  @override
  String get nextServe => 'Next: serve it to the table';

  @override
  String get nextBill => 'Next: bill the table';

  @override
  String get notPickedUp => 'Not picked up in time';

  @override
  String pickupOverdueToast(int number, String place) {
    return 'Order #$number ($place) has not been picked up';
  }

  @override
  String get billPending => 'Bill pending';

  @override
  String get billNow => 'Bill';

  @override
  String get tabOrders => 'Orders';

  @override
  String get ordersToday2 => 'Today';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get billed => 'Billed';

  @override
  String get servingMode => 'How food reaches the table';

  @override
  String get serveByWaiter => 'Waiter serves';

  @override
  String get serveAtCounter => 'Diner collects at counter';

  @override
  String get servingModeHelp =>
      'Counter: when food is ready the diner is told to collect it; there is no Served step.';

  @override
  String get pickupAlert => 'Alert if no chef picks up within';

  @override
  String get pickupAlertHelp => 'Admins and chefs on shift get a loud alert.';

  @override
  String get off => 'Off';

  @override
  String get collectAtCounter => 'Ready! Please collect it from the counter.';

  @override
  String get changePassword => 'Change password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmNewPassword => 'Type the new password again';

  @override
  String get passwordsDontMatch => 'The two new passwords don\'t match';

  @override
  String get passwordChanged =>
      'Password changed. Other devices are signed out.';

  @override
  String get errWrongPassword => 'Current password is wrong';

  @override
  String get errSamePassword => 'Choose a different password';

  @override
  String get resetPassword => 'Reset password';

  @override
  String resetPasswordFor(String name) {
    return 'Reset password for $name';
  }

  @override
  String get resetPasswordHelp =>
      'They are signed out everywhere. Give them the new password in person; they can change it from their profile.';

  @override
  String passwordResetDone(String name) {
    return 'Password reset for $name';
  }

  @override
  String get periodToday => 'Today';

  @override
  String get periodWeek => 'Last 7 days';

  @override
  String get myCooking => 'Your cooking';

  @override
  String get myServing => 'Your serving';

  @override
  String get myBilling => 'Your billing';

  @override
  String get statOrdersCooked => 'Orders cooked';

  @override
  String get statItemsCooked => 'Items cooked';

  @override
  String get statAvgCook => 'Avg cooking time';

  @override
  String get statAvgWaitStart => 'Avg wait to start';

  @override
  String get statInQueue => 'In your queue now';

  @override
  String get statOrdersServed => 'Orders served';

  @override
  String get statTablesServed => 'Tables served';

  @override
  String get statAvgServe => 'Avg ready to table';

  @override
  String get statOrdersTaken => 'Orders you took';

  @override
  String get statReadyNow => 'Ready to serve now';

  @override
  String get statBillsRaised => 'Bills raised';

  @override
  String get statCollected => 'Collected';

  @override
  String get statUnpaidNow => 'Unpaid bills now';

  @override
  String teamAverage(String value) {
    return 'Team $value';
  }

  @override
  String minutesDecimal(String value) {
    return '$value min';
  }

  @override
  String get noWorkYet => 'Nothing yet in this period';

  @override
  String newOrdersSinceBill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new orders since this bill',
      one: '1 new order since this bill',
    );
    return '$_temp0';
  }

  @override
  String get updateBill => 'Update bill';

  @override
  String get updateBillHelp =>
      'The current bill is cancelled and one new bill covers everything.';

  @override
  String billReplaced(String old, String next) {
    return '$old cancelled. $next has every order.';
  }

  @override
  String get billCancelled => 'Cancelled';

  @override
  String get tablesToBill => 'Tables to bill';

  @override
  String get viewOrders => 'Orders';

  @override
  String get viewBills => 'Bills';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get pickDates => 'Pick dates';

  @override
  String get searchOrdersHint => 'Order # or table';

  @override
  String get searchBillsHint => 'Bill # or table';

  @override
  String get loadMore => 'Load more';

  @override
  String get noBillsYet => 'No bills in this period';

  @override
  String get errRangeTooLong => 'Pick at most 31 days';

  @override
  String get openBill => 'Open bill';

  @override
  String get statusPaid => 'Paid';

  @override
  String printedTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Printed $count times',
      one: 'Printed once',
    );
    return '$_temp0';
  }

  @override
  String get takeaway => 'Takeaway';

  @override
  String get newTakeaway => 'Takeaway';

  @override
  String takeawayTitle(int number) {
    return 'Takeaway #$number';
  }

  @override
  String takeawayTitleFor(int number, String name) {
    return 'Takeaway #$number · $name';
  }

  @override
  String takeawayFor(String name) {
    return 'Takeaway · $name';
  }

  @override
  String get guestName => 'Guest name (optional)';

  @override
  String get guestPhone => 'Phone (optional)';

  @override
  String get handedOver => 'Handed over';

  @override
  String get nextHandOver => 'Next: hand it over to the guest';

  @override
  String get nextBillOrder => 'Next: bill this order';

  @override
  String get channelTakeaway => 'Takeaway';

  @override
  String billForOrder(String title) {
    return 'Bill · $title';
  }

  @override
  String get discount => 'Discount';

  @override
  String get addDiscount => 'Add discount';

  @override
  String get discountByPercent => 'Percent';

  @override
  String get discountByAmount => 'Amount (₹)';

  @override
  String get discountValue => 'How much';

  @override
  String get discountReason => 'Reason (printed on the bill)';

  @override
  String discountLimit(String limit) {
    return 'Your limit: $limit';
  }

  @override
  String get discountHelp =>
      'Tax is recalculated on the discounted amount. A printed bill is replaced by a new one.';

  @override
  String get taxableValue => 'Taxable value';

  @override
  String get maxBillDiscount => 'Max bill discount';

  @override
  String errDiscountLimit(String limit) {
    return 'That is more than your role may give ($limit)';
  }

  @override
  String get errBadDiscount => 'Enter a valid discount and a reason';

  @override
  String get noDiscountAllowed => 'Your role cannot give discounts';

  @override
  String get paidSoFar => 'Paid';

  @override
  String get dueNow => 'Due';

  @override
  String get payPart => 'Pay part';

  @override
  String get splitEqually => 'Split equally';

  @override
  String get howManyGuests => 'How many guests?';

  @override
  String guestShare(int n, String amount) {
    return 'Guest $n: $amount';
  }

  @override
  String get payThisShare => 'Pay this share';

  @override
  String get amountReceived => 'Amount received';

  @override
  String get paymentRef => 'Reference (optional: UPI ref, card slip)';

  @override
  String get removePayment => 'Remove this payment';

  @override
  String get payMixed => 'Mixed';

  @override
  String errOverpayment(String due) {
    return 'That is more than is due ($due)';
  }

  @override
  String get errHasPayments =>
      'Part of this bill is paid. Remove those payments first.';

  @override
  String get errPaymentsExceedTotal =>
      'More has been paid than the new total. Remove a payment first.';

  @override
  String get payWholeDue => 'Pay what is due';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportSales => 'Sales';

  @override
  String get reportItems => 'Items';

  @override
  String get reportGst => 'GST';

  @override
  String get reportStaff => 'Staff';

  @override
  String get downloadCsv => 'Download CSV';

  @override
  String get billsRegisterCsv => 'Bills register (CSV)';

  @override
  String fileSaved(String name) {
    return 'Saved $name';
  }

  @override
  String get basisSales =>
      'Counts bills issued on the hotel\'s calendar day. Cancelled bills are left out and shown separately.';

  @override
  String get basisItems =>
      'Dishes on issued bills, as printed. Cancelled bills are left out.';

  @override
  String basisGst(String sac) {
    return 'Tax per rate exactly as printed on each bill. B2C, within the state (CGST + SGST). SAC $sac.';
  }

  @override
  String get basisStaff =>
      'Bills each person raised, discounts they gave and money they received.';

  @override
  String get ladderGross => 'Gross (menu value)';

  @override
  String get ladderDiscount => 'Discounts';

  @override
  String get ladderTaxable => 'Taxable value';

  @override
  String get ladderOtherTax => 'Other tax';

  @override
  String get ladderRoundOff => 'Round off';

  @override
  String get ladderTotal => 'Bill total';

  @override
  String repBills(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bills',
      one: '1 bill',
    );
    return '$_temp0';
  }

  @override
  String repReplaced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bills replaced when more food was added',
      one: '1 bill replaced when more food was added',
    );
    return '$_temp0';
  }

  @override
  String get repReceived => 'Money received';

  @override
  String repUnbilled(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
    );
    return 'Not billed yet: $_temp0, $amount';
  }

  @override
  String get repUnbilledHelp =>
      'Bill these or cancel the order. They are not counted as sales.';

  @override
  String get repByDay => 'By day';

  @override
  String get repNoBills => 'No bills in these dates';

  @override
  String repSold(int qty) {
    return '$qty sold';
  }

  @override
  String gstRate(String rate) {
    return 'GST $rate';
  }

  @override
  String get gstDocuments => 'Documents issued';

  @override
  String gstDocCounts(
    String from,
    String to,
    int count,
    int cancelled,
    int net,
  ) {
    return '$from to $to: $count issued, $cancelled cancelled, $net net';
  }

  @override
  String get docTaxInvoice => 'Tax invoice';

  @override
  String get docBillOfSupply => 'Bill of supply';

  @override
  String get docBill => 'Bill';

  @override
  String staffDiscounts(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count discounts',
      one: '1 discount',
    );
    return '$_temp0 · $amount';
  }

  @override
  String staffCancelled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bills cancelled by hand',
      one: '1 bill cancelled by hand',
    );
    return '$_temp0';
  }

  @override
  String get noStaffActivity => 'No bills or payments by staff in these dates';

  @override
  String errRangeTooLongDays(int days) {
    return 'Pick at most $days days';
  }

  @override
  String unbilledToday(String amount) {
    return 'Not billed yet today: $amount';
  }

  @override
  String get splitByItems => 'Split by items';

  @override
  String get splitByItemsHelp =>
      'Tap a guest to give them one; the x takes one back. Shared: the ticked guests pay an equal part.';

  @override
  String get guestsCount => 'Guests';

  @override
  String guestN(int n) {
    return 'Guest $n';
  }

  @override
  String guestUnits(int n, int count) {
    return 'Guest $n · $count';
  }

  @override
  String guestNofM(int n, int m) {
    return 'Guest $n of $m';
  }

  @override
  String splitLeft(int count) {
    return '$count left';
  }

  @override
  String get splitShared => 'Shared';

  @override
  String splitCreate(int count) {
    return 'Create $count bills';
  }

  @override
  String get splitIncomplete =>
      'Give out every dish and give every guest something';

  @override
  String splitDone(int count) {
    return '$count guest bills issued';
  }

  @override
  String get guestBills => 'Guest bills';

  @override
  String get splitNothing => 'Nothing to split at this table yet';

  @override
  String get errLinesChanged =>
      'The table\'s items changed. The list has been refreshed.';

  @override
  String get errSplitPartlyPaid =>
      'A guest has already paid, so this split cannot be cancelled.';

  @override
  String get errBillDiscounted =>
      'This bill has a discount. Cancel it first, then split by items.';

  @override
  String get chooseSize => 'Choose a size';

  @override
  String pickUpTo(int max) {
    return 'Up to $max';
  }

  @override
  String pickExactly(int n) {
    return 'Choose $n';
  }

  @override
  String pickBetween(int min, int max) {
    return 'Choose $min to $max';
  }

  @override
  String get addToOrder => 'Add';

  @override
  String get hasOptions => 'Sizes / add-ons';

  @override
  String get errVariantRequired => 'Choose a size first';

  @override
  String get errAddonCount => 'Check the add-on choices';

  @override
  String get removeLine => 'Remove';

  @override
  String get sizes => 'Sizes';

  @override
  String get sizesHelp =>
      'Two or more sizes, each with its own price (e.g. Half ₹180, Full ₹320). Remove them all to sell the dish at one price.';

  @override
  String get addSize => 'Add size';

  @override
  String get sizeNameHint => 'e.g. Half';

  @override
  String get errSizesCount => 'Give two or more sizes, or none';

  @override
  String get errPriceInvalid => 'Enter a valid price';

  @override
  String get addons => 'Add-ons';

  @override
  String get addonGroups => 'Add-on groups';

  @override
  String get addonGroupsHelp =>
      'Make a group once (e.g. Extras, Choose your bread) and offer it with any dish.';

  @override
  String get newGroup => 'New group';

  @override
  String get groupNameHint => 'e.g. Extras';

  @override
  String get minPicks => 'At least';

  @override
  String get maxPicks => 'At most';

  @override
  String get addAddon => 'Add add-on';

  @override
  String get addonNameHint => 'e.g. Raita';

  @override
  String usedBy(String names) {
    return 'Used by: $names';
  }

  @override
  String get notUsedYet => 'Not offered with any dish yet';

  @override
  String addonsForItem(String item) {
    return 'Choose which add-on groups $item offers.';
  }

  @override
  String get noAddonGroups =>
      'No add-on groups yet. Create one in Add-on groups.';

  @override
  String deleteGroupConfirm(String name) {
    return 'Delete $name? Dishes using it will stop offering it. Orders already placed keep their add-ons.';
  }

  @override
  String get saved => 'Saved';

  @override
  String offerBadge(String name, String percent, String time) {
    return '$name −$percent till $time';
  }

  @override
  String get happyHour => 'Happy hour';

  @override
  String get happyHourHelp =>
      'Percent off the dish or size price on chosen days and times, for every order (waiter or QR). Add-ons keep their price; overlapping offers never add up.';

  @override
  String get newOffer => 'New offer';

  @override
  String get offerNameHint => 'e.g. Happy hour';

  @override
  String get percentOff => 'Percent off';

  @override
  String get days => 'Days';

  @override
  String get fromTime => 'From';

  @override
  String get toTime => 'To';

  @override
  String get appliesTo => 'Applies to';

  @override
  String get wholeMenu => 'Whole menu';

  @override
  String get offerOn => 'On';

  @override
  String get noOffers => 'No offers yet';

  @override
  String offerSummary(String percent, String days, String from, String to) {
    return '$percent off · $days · $from–$to';
  }

  @override
  String get everyDay => 'Every day';

  @override
  String get errBadPercent => 'Enter a percent between 0.01 and 90';

  @override
  String get errSameTimes => 'Start and end times must differ';

  @override
  String get combo => 'Combo';

  @override
  String get comboHelp =>
      'List the dishes in this combo. It keeps its own price and tax. For a choice (e.g. a drink), attach an add-on group set to choose 1.';

  @override
  String get comboNeedsTwo =>
      'A combo needs at least two dishes. Remove them all to make it an ordinary dish.';

  @override
  String get errBadCombo =>
      'That combo isn\'t allowed (a combo can\'t contain itself or another combo, and needs two dishes)';

  @override
  String get errItemInCombo =>
      'This dish is in a combo. Take it out of the combo first, or mark it sold out.';

  @override
  String get editCategory => 'Edit category';

  @override
  String get servingHours => 'Serving hours';

  @override
  String get servedAllDay => 'Served all day';

  @override
  String servedHours(String hours) {
    return 'Served $hours';
  }

  @override
  String get outsideHoursTitle => 'Not served now';

  @override
  String outsideHoursBody(String items, String category, String hours) {
    return '$items ($category, $hours) are outside their serving hours. Order anyway?';
  }

  @override
  String get orderAnyway => 'Order anyway';

  @override
  String get errOutsideHours => 'Not served at this time';

  @override
  String get closeDay => 'Close day';

  @override
  String get closeDayHelp =>
      'What the drawer should hold, from everything recorded on every device today. Count the cash and enter it below.';

  @override
  String get today => 'Today';

  @override
  String get history => 'History';

  @override
  String get openingFloat => 'Opening float';

  @override
  String get cashReceived => 'Cash received';

  @override
  String get cashPaidOut => 'Cash paid out (expenses)';

  @override
  String get expectedInDrawer => 'Should be in the drawer';

  @override
  String get countedCash => 'Cash counted';

  @override
  String get keepForTomorrow => 'Keep in the drawer for tomorrow';

  @override
  String toDeposit(String amount) {
    return 'To the bank: $amount';
  }

  @override
  String cashOver(String amount) {
    return 'Over $amount';
  }

  @override
  String cashShort(String amount) {
    return 'Short $amount';
  }

  @override
  String get cashExact => 'Exact';

  @override
  String get whyDifferent => 'Why is it different? (needed)';

  @override
  String get closeDayButton => 'Close the day';

  @override
  String get closeDayConfirm =>
      'This is final. Tomorrow\'s opening float will be what you keep in the drawer.';

  @override
  String dayClosedBy(String name, String time) {
    return 'Closed by $name at $time';
  }

  @override
  String cashAfterClose(String amount) {
    return 'Cash taken after closing: $amount';
  }

  @override
  String unpaidBillsWarning(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bills are still unpaid',
      one: '1 bill is still unpaid',
    );
    return '$_temp0 ($amount)';
  }

  @override
  String shortDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count short days',
      one: '1 short day',
      zero: 'No short days',
    );
    return '$_temp0';
  }

  @override
  String netOverShort(String amount) {
    return 'Net over/short: $amount';
  }

  @override
  String get noCloses => 'No days closed yet';

  @override
  String get errNoteRequired => 'Say why the cash is over or short';

  @override
  String get errAlreadyClosed => 'This day is already closed';

  @override
  String get seated => 'Seated';

  @override
  String get cleaning => 'Cleaning';

  @override
  String get reserved => 'Reserved';

  @override
  String get seatGuests => 'Seat guests';

  @override
  String get guestsCountLabel => 'How many guests?';

  @override
  String guestsAndTime(String guests, int minutes) {
    return '$guests · $minutes min';
  }

  @override
  String guestsN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guests',
      one: '1 guest',
    );
    return '$_temp0';
  }

  @override
  String get markClean => 'Clean';

  @override
  String get reserve => 'Reserve';

  @override
  String get reserveNoteHint => 'e.g. 8 pm, 4 people';

  @override
  String get cancelReservation => 'Cancel reservation';

  @override
  String get guestsLeft => 'Guests left (free table)';

  @override
  String get changeGuests => 'Change guests';

  @override
  String coversLine(int covers) {
    String _temp0 = intl.Intl.pluralLogic(
      covers,
      locale: localeName,
      other: '$covers guests',
      one: '1 guest',
      zero: 'No guests recorded',
    );
    return '$_temp0';
  }

  @override
  String avgPerGuest(String amount) {
    return 'Average per guest: $amount';
  }

  @override
  String get errTableInUse => 'Guests are at this table';

  @override
  String get moveTable => 'Move';

  @override
  String get mergeTables => 'Merge';

  @override
  String get moveTo => 'Move to which table?';

  @override
  String get mergeWhich => 'Which tables join this one?';

  @override
  String get noFreeTables => 'No free table right now';

  @override
  String get noOtherBusy => 'No other table has guests';

  @override
  String movedTo(String label) {
    return 'Moved to table $label';
  }

  @override
  String mergedInto(String label) {
    return 'Merged into table $label';
  }

  @override
  String get errTableHasBill =>
      'This table already has a bill. Settle or cancel it first.';

  @override
  String get bookings => 'Bookings';

  @override
  String get waitlist => 'Waitlist';

  @override
  String get newBooking => 'New booking';

  @override
  String get addToWaitlist => 'Add to waitlist';

  @override
  String get tableOptional => 'Table (optional)';

  @override
  String get anyTable => 'Any table';

  @override
  String get quotedWait => 'Wait told to the guest (minutes)';

  @override
  String avgWaitToday(int minutes) {
    return 'Today\'s real average wait: $minutes min';
  }

  @override
  String waitedOfQuoted(int waited, int quoted) {
    return 'Waiting $waited min (told $quoted)';
  }

  @override
  String waitedMin(int waited) {
    return 'Waiting $waited min';
  }

  @override
  String get seat => 'Seat';

  @override
  String get noShow => 'No-show';

  @override
  String get cancelBooking => 'Cancel';

  @override
  String noShowsBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count no-shows before',
      one: '1 no-show before',
    );
    return '$_temp0';
  }

  @override
  String get noBookingsDay => 'No bookings for this day';

  @override
  String get nobodyWaiting => 'Nobody is waiting';

  @override
  String bookedAt(String time, String name) {
    return 'Booked $time · $name';
  }

  @override
  String get pickTable => 'Pick a table';

  @override
  String get bookingStatusSeated => 'Seated';

  @override
  String get bookingStatusCancelled => 'Cancelled';

  @override
  String tableBookedWarn(String name, String time) {
    return '$name has this table at $time. Book anyway?';
  }

  @override
  String get bookAnyway => 'Book anyway';

  @override
  String get errPastTime => 'That time has passed';

  @override
  String get stations => 'Stations';

  @override
  String get stationsHelp =>
      'Sections of the kitchen that get their own ticket and screen, e.g. Bar, Tandoor. Dishes without a station go to the main Kitchen.';

  @override
  String get newStationHint => 'e.g. Bar';

  @override
  String get mainKitchen => 'Kitchen';

  @override
  String get station => 'Station';

  @override
  String get followCategory => 'Same as category';

  @override
  String get allStations => 'All stations';

  @override
  String goesTo(String station) {
    return 'Goes to: $station';
  }

  @override
  String get errStationExists => 'A station with this name already exists';

  @override
  String vsLastWeek(String weekday) {
    return 'Compared with last $weekday at this time';
  }

  @override
  String upBy(String amount, String pct) {
    return 'Up $amount ($pct%)';
  }

  @override
  String downBy(String amount, String pct) {
    return 'Down $amount ($pct%)';
  }

  @override
  String get sameAsLastWeek => 'Same as last week';

  @override
  String get noSalesToCompare => 'No sales to compare';

  @override
  String get receivedToday => 'Money received today';

  @override
  String sharePct(String pct) {
    return '$pct%';
  }

  @override
  String get repByCategory => 'By category';

  @override
  String repCategoryLine(int dishes, String qty, String pct) {
    String _temp0 = intl.Intl.pluralLogic(
      dishes,
      locale: localeName,
      other: '$dishes dishes',
      one: '1 dish',
    );
    return '$_temp0 · $qty sold · $pct% of sales';
  }

  @override
  String get repNotRecorded => 'Not recorded';

  @override
  String get basisCategories =>
      'Each dish counts under the category it had when it was billed; moving it later does not change past reports.';

  @override
  String get categoriesCsv => 'Categories (CSV)';

  @override
  String get holdOrder => 'Hold';

  @override
  String get orderHeld => 'Order held. Resume it from the table or Takeaway.';

  @override
  String get heldOrders => 'Held orders';

  @override
  String heldAt(String time) {
    return 'Held $time';
  }

  @override
  String get heldNeedsChanges => 'needs changes';

  @override
  String get resumeHeld => 'Resume this order';

  @override
  String get discardHeld => 'Discard';

  @override
  String get discardHeldTitle => 'Discard this held order?';

  @override
  String get discardHeldBody =>
      'Nothing was sent to the kitchen. The guest\'s order will be lost.';

  @override
  String heldMissing(String names) {
    return 'No longer on the menu: $names';
  }

  @override
  String get errHoldGone =>
      'This held order was already sent or discarded on another device';

  @override
  String heldCount(String count) {
    return '$count held';
  }

  @override
  String heldOrdersWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count held orders were never sent to the kitchen',
      one: '1 held order was never sent to the kitchen',
    );
    return '$_temp0';
  }

  @override
  String dueIn(int minutes) {
    return 'Due in $minutes min';
  }

  @override
  String get readyDueNow => 'Due now';

  @override
  String delayedBy(int minutes) {
    return 'Delayed $minutes min';
  }

  @override
  String onTimeToday(String pct, int onTime, int ready) {
    return 'On time today: $pct% ($onTime of $ready orders ready by their due time)';
  }

  @override
  String get companyBill => 'Company GST bill';

  @override
  String get buyerName => 'Company name';

  @override
  String get buyerGstin => 'Company GSTIN';

  @override
  String get buyerAddress => 'Company address (optional)';

  @override
  String get companyBillHelp =>
      'The bill is re-issued with the company\'s details (the old number stays in the register as cancelled). The GSTIN must be valid and from this state.';

  @override
  String billTo(String name) {
    return 'Bill to: $name';
  }

  @override
  String get errBadGstin => 'That GSTIN is not valid. Check it with the guest.';

  @override
  String get errInterstateB2b =>
      'This GSTIN is from another state. Bills for other-state companies need IGST, which is not supported yet.';

  @override
  String get errNotTaxInvoice =>
      'Only a GST-registered hotel can issue a company (B2B) bill.';

  @override
  String get errBillHasBuyer =>
      'This is a company bill; it cannot be split by items.';

  @override
  String get gstB2b => 'Company (B2B) bills';

  @override
  String get reportPnl => 'Profit & loss';

  @override
  String lastMonths(int count) {
    return 'Last $count months';
  }

  @override
  String get pnlSoFar => 'So far';

  @override
  String get pnlSales => 'Sales before GST';

  @override
  String get pnlExpenses => 'Expenses';

  @override
  String get pnlProfit => 'Operating profit';

  @override
  String get pnlLoss => 'Operating loss';

  @override
  String pnlMargin(String pct) {
    return '$pct% of sales';
  }

  @override
  String get pnlGst => 'GST collected';

  @override
  String get pnlGstHelp => 'Owed to the government; not income';

  @override
  String pnlTotal(int count) {
    return 'Total, $count months';
  }

  @override
  String get basisPnl =>
      'Sales are issued bills before GST, after discounts. Expenses are counted on the day they were spent. Food cost is only what you entered as expenses (stock is not tracked yet).';

  @override
  String get thisMonthBeforeGst => 'This month, before GST';

  @override
  String get searchMenuKeys => 'Search the menu (/), Enter adds the top dish';

  @override
  String get keyboardShortcuts => 'Keyboard shortcuts';

  @override
  String get keySearch => 'Search the menu';

  @override
  String get keyAddTop => 'Add the top dish from the search';

  @override
  String get keySend => 'Send to kitchen';

  @override
  String get keyHold => 'Hold the order';

  @override
  String get keyTakeaway => 'New takeaway (Floor)';

  @override
  String get keyPrint => 'Print the bill (bill window)';

  @override
  String get keyPay => 'Pay what is due by cash / UPI / card (bill window)';

  @override
  String get keyHelp => 'Show this list';

  @override
  String get downloadPdf => 'PDF';

  @override
  String get attendance => 'Attendance';

  @override
  String get clockIn => 'Clock in';

  @override
  String clockOutSince(String time) {
    return 'Clock out (in since $time)';
  }

  @override
  String get clockedIn => 'Clocked in';

  @override
  String get clockedOut => 'Clocked out';

  @override
  String hoursMinutes(int h, String m) {
    return '$h h $m m';
  }

  @override
  String lastDays(int count) {
    return 'Last $count days';
  }

  @override
  String get noShifts => 'No one has clocked in yet';

  @override
  String get attendanceHelp =>
      'Staff clock in and out on their own login, from Overview or My work.';

  @override
  String attendanceLine(int days, String hours) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0 · $hours';
  }

  @override
  String get noClockOut => 'No clock-out';

  @override
  String get onShiftNow => 'On shift';

  @override
  String get shifts => 'Shifts';

  @override
  String fixShift(String name) {
    return 'Fix $name\'s shift';
  }

  @override
  String get fixShiftShort => 'Fix shift';

  @override
  String clockedInAt(String time) {
    return 'Clocked in $time';
  }

  @override
  String get clockOutTime => 'Clock-out time';

  @override
  String get pickTime => 'Pick a time';

  @override
  String get fixReason => 'Reason';

  @override
  String get fixShiftHelp =>
      'The original times are kept and the change is recorded with your name and reason.';

  @override
  String get saveFix => 'Save';

  @override
  String correctedBecause(String reason) {
    return 'Corrected: $reason';
  }

  @override
  String get rota => 'Rota';

  @override
  String get addShift => 'Add shift';

  @override
  String get person => 'Person';

  @override
  String get day => 'Day';

  @override
  String get shiftStart => 'Starts';

  @override
  String get shiftEnd => 'Ends';

  @override
  String get shiftOvernight => 'Ends after midnight (next day)';

  @override
  String get copyLastWeek => 'Copy last week';

  @override
  String weekCopied(int copied, int skipped) {
    return '$copied shifts copied, $skipped skipped (already planned)';
  }

  @override
  String get previousWeek => 'Previous week';

  @override
  String get nextWeek => 'Next week';

  @override
  String get noShiftsPlanned => 'No shifts planned';

  @override
  String get removeShift => 'Remove shift';

  @override
  String get shiftOnTime => 'On time';

  @override
  String shiftLate(int minutes) {
    return 'Late $minutes min';
  }

  @override
  String shiftNotIn(int minutes) {
    return 'Not in · $minutes min late';
  }

  @override
  String get shiftNoShow => 'No-show';

  @override
  String get shiftUpcoming => 'Upcoming';

  @override
  String get myNextShifts => 'My next shifts';

  @override
  String get handover => 'Hand over';

  @override
  String get handoverHelp =>
      'Count the cash in the drawer before you see what it should be. The count is saved as typed and can\'t be changed.';

  @override
  String get cashInDrawerNow => 'Cash in the drawer now';

  @override
  String get handingOverTo => 'Handing over to';

  @override
  String get saveCount => 'Save count';

  @override
  String get handoverSaved => 'Handover saved';

  @override
  String get whyOverShort => 'Why is it over or short?';

  @override
  String get saveNote => 'Save reason';

  @override
  String get done => 'Done';

  @override
  String get handoversToday => 'Shift handovers today';

  @override
  String handoverLine(String time, String from, String to) {
    return '$time: $from → $to';
  }

  @override
  String countedOf(String counted, String expected) {
    return 'Counted $counted of $expected expected';
  }
}
