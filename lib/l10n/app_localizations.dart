import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('hi'),
    Locale('te'),
  ];

  /// Product name shown in the brand pill and browser title (working name)
  ///
  /// In en, this message translates to:
  /// **'Vethra'**
  String get appName;

  /// Login card heading
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get signInTitle;

  /// Login card subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to run your restaurant.'**
  String get signInSubtitle;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Login button
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// Profile menu: sign out
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Tooltip to reveal password
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// Tooltip to hide password
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// Large headline on the login screen
  ///
  /// In en, this message translates to:
  /// **'Orders, kitchen and money in one calm place.'**
  String get loginHeadline;

  /// Login screen feature chip
  ///
  /// In en, this message translates to:
  /// **'Table QR ordering'**
  String get loginPointQr;

  /// Login screen feature chip
  ///
  /// In en, this message translates to:
  /// **'Live chef queues'**
  String get loginPointKitchen;

  /// Login screen feature chip
  ///
  /// In en, this message translates to:
  /// **'Daily dashboards'**
  String get loginPointDashboards;

  /// Tooltip for the profile button
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get yourProfile;

  /// Settings button
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Notification bell title
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// Empty alerts list
  ///
  /// In en, this message translates to:
  /// **'Nothing needs you right now'**
  String get noAlerts;

  /// Close dialog button tooltip
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Save settings button
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// Edit tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Overflow menu tooltip
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// Add item to order button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Increase quantity tooltip
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// Decrease quantity tooltip
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decrease;

  /// Filter chip that shows everything
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Name field or column label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Status column label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Role field or column label
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// Phone column label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Optional phone field label
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get phoneOptional;

  /// Date field label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Veg or non-veg selector label
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Reason field label
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// Help text under a reason field
  ///
  /// In en, this message translates to:
  /// **'Saved in the audit log.'**
  String get reasonAuditedHelp;

  /// Reason recorded when the admin leaves the reason empty
  ///
  /// In en, this message translates to:
  /// **'Changed by platform admin'**
  String get defaultReason;

  /// Navigation tab: dashboard
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get tabOverview;

  /// Navigation tab: hotels (platform)
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get tabHotels;

  /// Navigation tab: subscription plans (platform)
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get tabPlans;

  /// Navigation tab: tables and order taking
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get tabFloor;

  /// Navigation tab: kitchen display
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get tabKitchen;

  /// Navigation tab: menu
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get tabMenu;

  /// Navigation tab: tables and QR codes
  ///
  /// In en, this message translates to:
  /// **'Tables'**
  String get tabTables;

  /// Navigation tab: staff and roles
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get tabTeam;

  /// Navigation tab: hotel expenses
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get tabExpenses;

  /// Dashboard greeting before noon
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String goodMorning(String name);

  /// Dashboard greeting in the afternoon
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String goodAfternoon(String name);

  /// Dashboard greeting in the evening
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String goodEvening(String name);

  /// Pill bar: orders waiting for the kitchen
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// Pill bar: orders being prepared
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get cooking;

  /// Pill bar: share of tables with open orders
  ///
  /// In en, this message translates to:
  /// **'Tables busy'**
  String get tablesBusy;

  /// Pill bar: orders served today
  ///
  /// In en, this message translates to:
  /// **'Served'**
  String get servedToday;

  /// Big number caption
  ///
  /// In en, this message translates to:
  /// **'Orders today'**
  String get ordersToday;

  /// Big number caption
  ///
  /// In en, this message translates to:
  /// **'Revenue today'**
  String get revenueToday;

  /// Big number caption: average preparation time
  ///
  /// In en, this message translates to:
  /// **'Avg prep'**
  String get avgPrep;

  /// Revenue card caption
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// Revenue card: expenses this month
  ///
  /// In en, this message translates to:
  /// **'Expenses {amount}'**
  String expensesAmount(String amount);

  /// Revenue card: revenue minus expenses
  ///
  /// In en, this message translates to:
  /// **'Net {amount}'**
  String netAmount(String amount);

  /// Card title: hourly orders chart
  ///
  /// In en, this message translates to:
  /// **'Orders by hour'**
  String get ordersByHour;

  /// Caption next to the order count
  ///
  /// In en, this message translates to:
  /// **'orders so far today'**
  String get ordersSoFarToday;

  /// Tooltip: go to the floor page
  ///
  /// In en, this message translates to:
  /// **'Open floor'**
  String get openFloor;

  /// Tooltip: go to the kitchen page
  ///
  /// In en, this message translates to:
  /// **'Open kitchen'**
  String get openKitchen;

  /// Card title: preparation time dial
  ///
  /// In en, this message translates to:
  /// **'Kitchen pace'**
  String get kitchenPace;

  /// Caption under the dial value
  ///
  /// In en, this message translates to:
  /// **'avg minutes to cook'**
  String get avgPrepMinutes;

  /// Chip: chefs currently on shift
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 chef on shift} other{{count} chefs on shift}}'**
  String chefsOnShift(int count);

  /// Chip: orders being cooked now
  ///
  /// In en, this message translates to:
  /// **'{count} cooking'**
  String cookingNow(int count);

  /// Live orders card title with percent served
  ///
  /// In en, this message translates to:
  /// **'Served today'**
  String get servedShare;

  /// Dark panel title
  ///
  /// In en, this message translates to:
  /// **'Live orders'**
  String get liveOrders;

  /// Empty live orders panel
  ///
  /// In en, this message translates to:
  /// **'No open orders'**
  String get noLiveOrders;

  /// Accordion section: best sellers this week
  ///
  /// In en, this message translates to:
  /// **'Top dishes'**
  String get topDishes;

  /// Accordion section or card title: chefs
  ///
  /// In en, this message translates to:
  /// **'Chefs'**
  String get chefs;

  /// Accordion section: average order value
  ///
  /// In en, this message translates to:
  /// **'Average ticket'**
  String get avgTicket;

  /// Caption next to average ticket
  ///
  /// In en, this message translates to:
  /// **'per order today'**
  String get perOrderToday;

  /// Empty chart or list
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No chefs in the team
  ///
  /// In en, this message translates to:
  /// **'No chefs added yet'**
  String get noChefsYet;

  /// Dish sales count
  ///
  /// In en, this message translates to:
  /// **'{count} sold'**
  String soldCount(int count);

  /// Orders a chef finished today
  ///
  /// In en, this message translates to:
  /// **'{count} done'**
  String doneCount(int count);

  /// Week card subtitle
  ///
  /// In en, this message translates to:
  /// **'Revenue, last 7 days'**
  String get revenueLast7Days;

  /// Order status: placed by diner, needs staff confirmation
  ///
  /// In en, this message translates to:
  /// **'Awaiting confirmation'**
  String get statusPlaced;

  /// Order status: confirmed, waiting for a chef
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statusConfirmed;

  /// Order status: assigned to a chef's queue
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get statusQueued;

  /// Order status: being cooked
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get statusPreparing;

  /// Order status: ready to serve
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get statusReady;

  /// Order status: served to the table
  ///
  /// In en, this message translates to:
  /// **'Served'**
  String get statusServed;

  /// Order status: cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// Order channel: diner scanned the table QR
  ///
  /// In en, this message translates to:
  /// **'QR'**
  String get channelQr;

  /// Order channel: taken by a server
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get channelWaiter;

  /// Order channel: taken by an admin
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get channelAdmin;

  /// Order number with table label
  ///
  /// In en, this message translates to:
  /// **'#{number} · Table {table}'**
  String orderNumberTable(int number, String table);

  /// Table name
  ///
  /// In en, this message translates to:
  /// **'Table {label}'**
  String tableLabel(String label);

  /// Relative time
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =0{just now} =1{1 min ago} other{{minutes} min ago}}'**
  String minutesAgo(int minutes);

  /// Duration in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// Role name
  ///
  /// In en, this message translates to:
  /// **'Hotel admin'**
  String get roleHotelAdmin;

  /// Role name
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get roleManager;

  /// Role name
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get roleCashier;

  /// Role name for waiter staff
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get roleWaiter;

  /// Role name
  ///
  /// In en, this message translates to:
  /// **'Chef'**
  String get roleChef;

  /// Role name for the super admin
  ///
  /// In en, this message translates to:
  /// **'Platform admin'**
  String get rolePlatformAdmin;

  /// Connection chip: realtime connected
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// Connection chip: realtime disconnected
  ///
  /// In en, this message translates to:
  /// **'Reconnecting'**
  String get reconnecting;

  /// Banner when the realtime socket is down
  ///
  /// In en, this message translates to:
  /// **'Connection lost. Showing the last known queue; refreshing every few seconds.'**
  String get staleBanner;

  /// Kitchen mode: chefs pick orders from a board
  ///
  /// In en, this message translates to:
  /// **'Chefs pick up'**
  String get modeChefAccept;

  /// Kitchen mode: system assigns orders
  ///
  /// In en, this message translates to:
  /// **'Auto assign'**
  String get modeAutoAssign;

  /// Kitchen mode: cooks from printed tickets
  ///
  /// In en, this message translates to:
  /// **'Printed tickets'**
  String get modeAdminPrint;

  /// Card title: orders waiting for a chef to pick up
  ///
  /// In en, this message translates to:
  /// **'New orders'**
  String get upForGrabs;

  /// Card title in auto-assign mode
  ///
  /// In en, this message translates to:
  /// **'Waiting for a chef'**
  String get waitingForChef;

  /// Empty new orders list
  ///
  /// In en, this message translates to:
  /// **'No new orders'**
  String get noNewOrders;

  /// Empty new orders list body
  ///
  /// In en, this message translates to:
  /// **'New orders appear here instantly.'**
  String get noNewOrdersBody;

  /// Button: chef claims an order
  ///
  /// In en, this message translates to:
  /// **'Pick up'**
  String get pickUp;

  /// Snackbar after a chef picks up an order
  ///
  /// In en, this message translates to:
  /// **'Order is yours'**
  String get pickedUp;

  /// Chef's own queue panel title
  ///
  /// In en, this message translates to:
  /// **'My queue'**
  String get myQueue;

  /// Empty chef queue
  ///
  /// In en, this message translates to:
  /// **'You\'re free. Pick up the next order.'**
  String get queueEmpty;

  /// Chef queue when off shift
  ///
  /// In en, this message translates to:
  /// **'You\'re off shift. Switch on to receive orders.'**
  String get offShiftBody;

  /// Tooltip on queued orders
  ///
  /// In en, this message translates to:
  /// **'Starts after the order ahead of it is ready'**
  String get lockedUntilHead;

  /// Button: start the head order
  ///
  /// In en, this message translates to:
  /// **'Start cooking'**
  String get startCooking;

  /// Snackbar after starting; also a date column header
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// Button: order is ready
  ///
  /// In en, this message translates to:
  /// **'Mark ready'**
  String get markReady;

  /// Snackbar after marking ready
  ///
  /// In en, this message translates to:
  /// **'Marked ready. The server has been told.'**
  String get markedReady;

  /// Elapsed cooking time
  ///
  /// In en, this message translates to:
  /// **'Cooking {minutes} min · target {target} min'**
  String cookingFor(int minutes, int target);

  /// Elapsed waiting time
  ///
  /// In en, this message translates to:
  /// **'Waiting {minutes} min'**
  String waitingFor(int minutes);

  /// Card title: other chefs' queues
  ///
  /// In en, this message translates to:
  /// **'Other chefs'**
  String get otherChefs;

  /// Empty other chefs list
  ///
  /// In en, this message translates to:
  /// **'No other chefs'**
  String get noOtherChefs;

  /// Chef has nothing queued
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get idle;

  /// Chef shift status
  ///
  /// In en, this message translates to:
  /// **'On shift'**
  String get onShift;

  /// Chef shift status
  ///
  /// In en, this message translates to:
  /// **'Off shift'**
  String get offShift;

  /// Manager action: unassign an order
  ///
  /// In en, this message translates to:
  /// **'Return to board'**
  String get returnToBoard;

  /// Card title: ready orders
  ///
  /// In en, this message translates to:
  /// **'Ready to serve'**
  String get readyToServe;

  /// Empty ready list
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting to be served'**
  String get nothingWaiting;

  /// Button: mark served
  ///
  /// In en, this message translates to:
  /// **'Serve'**
  String get serve;

  /// Card title: orders to confirm or serve
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get needsAttention;

  /// Empty attention list
  ///
  /// In en, this message translates to:
  /// **'All calm. Nothing to confirm or serve.'**
  String get allCalm;

  /// Button: mark order served
  ///
  /// In en, this message translates to:
  /// **'Served'**
  String get markServed;

  /// Button: confirm a QR order
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmOrder;

  /// Empty tables list
  ///
  /// In en, this message translates to:
  /// **'No tables yet'**
  String get noTables;

  /// Empty tables list body
  ///
  /// In en, this message translates to:
  /// **'Add tables to print their QR codes.'**
  String get noTablesBody;

  /// Seats at a table
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 seat} other{{count} seats}}'**
  String seats(int count);

  /// Seats field label
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get seatsLabel;

  /// Table is not taking orders
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Table has no open orders
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// Section title in table sheet
  ///
  /// In en, this message translates to:
  /// **'Open orders'**
  String get openOrders;

  /// Shown when the user lacks order permission
  ///
  /// In en, this message translates to:
  /// **'Your role can\'t take orders here.'**
  String get cannotTakeOrders;

  /// Search field hint
  ///
  /// In en, this message translates to:
  /// **'Search the menu'**
  String get searchMenu;

  /// Order note hint
  ///
  /// In en, this message translates to:
  /// **'Note for the kitchen (optional)'**
  String get kitchenNoteHint;

  /// Button: place staff order
  ///
  /// In en, this message translates to:
  /// **'Send to kitchen'**
  String get sendToKitchen;

  /// Snackbar after placing a staff order
  ///
  /// In en, this message translates to:
  /// **'Order sent to the kitchen'**
  String get orderSent;

  /// Item unavailable
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get soldOut;

  /// Vegetarian
  ///
  /// In en, this message translates to:
  /// **'Veg'**
  String get veg;

  /// Non-vegetarian
  ///
  /// In en, this message translates to:
  /// **'Non-veg'**
  String get nonVeg;

  /// Order subtotal
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// Tax line
  ///
  /// In en, this message translates to:
  /// **'GST'**
  String get tax;

  /// Service charge line
  ///
  /// In en, this message translates to:
  /// **'Service charge'**
  String get serviceCharge;

  /// Order total
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// Dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get editItem;

  /// Snackbar when adding an item without categories
  ///
  /// In en, this message translates to:
  /// **'Add a category first'**
  String get addCategoryFirst;

  /// Empty menu
  ///
  /// In en, this message translates to:
  /// **'Your menu is empty'**
  String get menuEmpty;

  /// Empty menu body
  ///
  /// In en, this message translates to:
  /// **'Add a category, then your dishes.'**
  String get menuEmptyBody;

  /// Empty search result
  ///
  /// In en, this message translates to:
  /// **'Nothing matches'**
  String get noMatches;

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Price column
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// Preparation time label
  ///
  /// In en, this message translates to:
  /// **'Prep time'**
  String get prepTime;

  /// Availability column
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// Item available
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Price field label
  ///
  /// In en, this message translates to:
  /// **'Price (₹)'**
  String get priceRupees;

  /// Help under the price field
  ///
  /// In en, this message translates to:
  /// **'Before tax. GST is added automatically if you are registered.'**
  String get priceHelp;

  /// Item description field
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Add table'**
  String get addTable;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Table name'**
  String get tableName;

  /// Help under table name
  ///
  /// In en, this message translates to:
  /// **'Short and unique, like T1 or P2.'**
  String get tableNameHelp;

  /// Field label, e.g. Indoor or Patio
  ///
  /// In en, this message translates to:
  /// **'Area (optional)'**
  String get areaOptional;

  /// Menu action
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// Menu action
  ///
  /// In en, this message translates to:
  /// **'Open diner view'**
  String get openDinerView;

  /// Menu action: invalidate the old QR
  ///
  /// In en, this message translates to:
  /// **'Replace QR code'**
  String get rotateQr;

  /// Menu action
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// Menu action
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// Chip
  ///
  /// In en, this message translates to:
  /// **'QR active'**
  String get qrActive;

  /// Chip: open orders on a table
  ///
  /// In en, this message translates to:
  /// **'{count} open'**
  String openOrdersCount(int count);

  /// Snackbar
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// Snackbar after rotating a QR
  ///
  /// In en, this message translates to:
  /// **'New QR created. Print it; the old one no longer works.'**
  String get qrRotated;

  /// Team sub-tab
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// Team sub-tab: permission matrix
  ///
  /// In en, this message translates to:
  /// **'Roles & access'**
  String get rolesAndAccess;

  /// Search hint
  ///
  /// In en, this message translates to:
  /// **'Search by name or role'**
  String get searchPeople;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get addMember;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'New role'**
  String get newRole;

  /// Button when the plan lacks custom roles
  ///
  /// In en, this message translates to:
  /// **'Custom roles (upgrade)'**
  String get newRoleLocked;

  /// Help under new role name
  ///
  /// In en, this message translates to:
  /// **'Then tick what this role can do.'**
  String get newRoleHelp;

  /// Matrix column header
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get permission;

  /// Tooltip on the locked admin column
  ///
  /// In en, this message translates to:
  /// **'Hotel admins always have every permission'**
  String get adminLocked;

  /// Account disabled
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// Account active
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Menu action to change a user's role
  ///
  /// In en, this message translates to:
  /// **'Make {role}'**
  String makeRole(String role);

  /// Menu action
  ///
  /// In en, this message translates to:
  /// **'Disable account'**
  String get disableAccount;

  /// Menu action
  ///
  /// In en, this message translates to:
  /// **'Enable account'**
  String get enableAccount;

  /// Help under email
  ///
  /// In en, this message translates to:
  /// **'They sign in with this email.'**
  String get emailLoginHelp;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Temporary password'**
  String get tempPassword;

  /// Help under temporary password
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters. Share it privately.'**
  String get tempPasswordHelp;

  /// Primary button in add member dialog
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get sendInvite;

  /// Permission label
  ///
  /// In en, this message translates to:
  /// **'See the dashboard'**
  String get permDashboard;

  /// Permission label
  ///
  /// In en, this message translates to:
  /// **'See orders'**
  String get permOrderView;

  /// Permission label
  ///
  /// In en, this message translates to:
  /// **'Take orders'**
  String get permOrderCreate;

  /// Permission label
  ///
  /// In en, this message translates to:
  /// **'Confirm QR orders'**
  String get permOrderConfirm;

  /// Permission label
  ///
  /// In en, this message translates to:
  /// **'Mark orders served'**
  String get permOrderServe;

  /// Permission label
  ///
  /// In en, this message translates to:
  /// **'Cancel orders'**
  String get permOrderCancel;

  /// Permission label
  ///
  /// In en, this message translates to:
  /// **'Pick up and cook'**
  String get permKitchenCook;

  /// Permission label
  ///
  /// In en, this message translates to:
  /// **'Manage chef queues'**
  String get permKitchenManage;

  /// Permission label
  ///
  /// In en, this message translates to:
  /// **'Manage tables and QR'**
  String get permTableManage;

  /// Permission label
  ///
  /// In en, this message translates to:
  /// **'Edit menu and prices'**
  String get permMenuManage;

  /// Permission label
  ///
  /// In en, this message translates to:
  /// **'Mark items sold out'**
  String get permMenuAvailability;

  /// Permission label
  ///
  /// In en, this message translates to:
  /// **'Manage staff'**
  String get permStaffManage;

  /// Permission label
  ///
  /// In en, this message translates to:
  /// **'Configure roles'**
  String get permRoleManage;

  /// Permission label
  ///
  /// In en, this message translates to:
  /// **'See expenses'**
  String get permExpenseView;

  /// Permission label
  ///
  /// In en, this message translates to:
  /// **'Record expenses'**
  String get permExpenseManage;

  /// Permission label
  ///
  /// In en, this message translates to:
  /// **'See reports'**
  String get permReportView;

  /// Permission label
  ///
  /// In en, this message translates to:
  /// **'Settings and billing'**
  String get permSettingsManage;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// Dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get editExpense;

  /// Tooltip
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// Tooltip
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// Summary caption
  ///
  /// In en, this message translates to:
  /// **'Spent this month'**
  String get spentThisMonth;

  /// Card title
  ///
  /// In en, this message translates to:
  /// **'By day'**
  String get byDay;

  /// Empty state
  ///
  /// In en, this message translates to:
  /// **'No expenses this month'**
  String get noExpenses;

  /// Empty state body
  ///
  /// In en, this message translates to:
  /// **'Record gas, groceries, salaries and more.'**
  String get noExpensesBody;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Amount (₹)'**
  String get amountRupees;

  /// Payment method label
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get paidBy;

  /// Payment method
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get payCash;

  /// Payment method
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get payUpi;

  /// Payment method
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get payCard;

  /// Payment method
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get payBank;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Vendor (optional)'**
  String get vendorOptional;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// Settings tab
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get kitchenAndOrdering;

  /// Settings tab
  ///
  /// In en, this message translates to:
  /// **'Plan & billing'**
  String get planAndBilling;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Restaurant name'**
  String get restaurantName;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'How orders reach chefs'**
  String get kitchenMode;

  /// Help under kitchen mode
  ///
  /// In en, this message translates to:
  /// **'Locked options need a higher plan.'**
  String get kitchenModeHelp;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Orders per chef at once'**
  String get maxQueue;

  /// Help under max queue
  ///
  /// In en, this message translates to:
  /// **'A chef can\'t hold more than this in their queue.'**
  String get maxQueueHelp;

  /// Switch label
  ///
  /// In en, this message translates to:
  /// **'Confirm QR orders first'**
  String get confirmQrOrders;

  /// Switch help
  ///
  /// In en, this message translates to:
  /// **'A server approves table orders before the kitchen sees them.'**
  String get confirmQrOrdersHelp;

  /// Subscription status
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get subActive;

  /// Subscription status
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get subTrial;

  /// Subscription status
  ///
  /// In en, this message translates to:
  /// **'Payment due'**
  String get subPastDue;

  /// Subscription status
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get subSuspended;

  /// Plan price
  ///
  /// In en, this message translates to:
  /// **'{amount} / month'**
  String perMonth(String amount);

  /// Suffix after a plan price
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get perMonthShort;

  /// Trial end date
  ///
  /// In en, this message translates to:
  /// **'Trial ends {date}'**
  String trialEndsOn(String date);

  /// Renewal date
  ///
  /// In en, this message translates to:
  /// **'Renews {date}'**
  String renewsOn(String date);

  /// Section label
  ///
  /// In en, this message translates to:
  /// **'Choose a plan'**
  String get choosePlan;

  /// Help under plan choice
  ///
  /// In en, this message translates to:
  /// **'You\'ll pay securely on Razorpay. Your plan activates as soon as the payment clears.'**
  String get choosePlanHelp;

  /// Shown when Razorpay keys are missing
  ///
  /// In en, this message translates to:
  /// **'Online payment isn\'t switched on yet. Contact support to activate.'**
  String get paymentsNotConfigured;

  /// Button: start checkout
  ///
  /// In en, this message translates to:
  /// **'Pay & activate'**
  String get payAndActivate;

  /// Button: renew current plan
  ///
  /// In en, this message translates to:
  /// **'Renew'**
  String get renew;

  /// Section label: past subscription payments
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// Banner action
  ///
  /// In en, this message translates to:
  /// **'Manage plan'**
  String get managePlan;

  /// Banner when subscription is past due
  ///
  /// In en, this message translates to:
  /// **'Your payment is due. Pay now to avoid interruption.'**
  String get bannerPastDue;

  /// Banner when suspended
  ///
  /// In en, this message translates to:
  /// **'Your account is paused. You can still view your data; pay to resume orders.'**
  String get bannerSuspended;

  /// Big number caption
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get hotels;

  /// Big number caption: recurring revenue
  ///
  /// In en, this message translates to:
  /// **'Monthly revenue'**
  String get mrr;

  /// Big number caption and column
  ///
  /// In en, this message translates to:
  /// **'Orders (30 days)'**
  String get orders30d;

  /// Card caption
  ///
  /// In en, this message translates to:
  /// **'Collected, last 30 days'**
  String get collected30d;

  /// Chip
  ///
  /// In en, this message translates to:
  /// **'{count} trials end this week'**
  String trialsEnding(int count);

  /// Card title: signups per month
  ///
  /// In en, this message translates to:
  /// **'New hotels'**
  String get signups;

  /// Card title
  ///
  /// In en, this message translates to:
  /// **'Plan mix'**
  String get planMix;

  /// Card title
  ///
  /// In en, this message translates to:
  /// **'Recent hotels'**
  String get recentHotels;

  /// Empty state
  ///
  /// In en, this message translates to:
  /// **'No hotels yet'**
  String get noHotels;

  /// Empty state body
  ///
  /// In en, this message translates to:
  /// **'Register your first hotel to get started.'**
  String get noHotelsBody;

  /// Search hint
  ///
  /// In en, this message translates to:
  /// **'Search hotels'**
  String get searchHotels;

  /// Button and dialog title
  ///
  /// In en, this message translates to:
  /// **'Register hotel'**
  String get registerHotel;

  /// Snackbar
  ///
  /// In en, this message translates to:
  /// **'Hotel registered. Share the admin login with them.'**
  String get hotelRegistered;

  /// Column header
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get hotel;

  /// Column header or field label
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// Column header or field label
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// Column header
  ///
  /// In en, this message translates to:
  /// **'Tables'**
  String get tablesCol;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Hotel name'**
  String get hotelName;

  /// Help under plan choice
  ///
  /// In en, this message translates to:
  /// **'Every new hotel starts on a free trial.'**
  String get trialHelp;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'GST registration'**
  String get gstRegistration;

  /// GST registration type
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get gstRegular;

  /// GST registration type
  ///
  /// In en, this message translates to:
  /// **'Composition'**
  String get gstComposition;

  /// GST registration type
  ///
  /// In en, this message translates to:
  /// **'Not registered'**
  String get gstUnregistered;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'GSTIN'**
  String get gstin;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Hotel admin'**
  String get hotelAdmin;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get suspendHotel;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeHotel;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Change plan'**
  String get changePlan;

  /// Button and dialog title
  ///
  /// In en, this message translates to:
  /// **'Feature overrides'**
  String get overrides;

  /// Dialog help
  ///
  /// In en, this message translates to:
  /// **'Turn a feature on or off for this hotel only, regardless of its plan.'**
  String get overridesHelp;

  /// Subtitle when an override exists
  ///
  /// In en, this message translates to:
  /// **'Overridden for this hotel'**
  String get overridden;

  /// Subtitle when no override exists
  ///
  /// In en, this message translates to:
  /// **'From plan'**
  String get fromPlan;

  /// Chip: price not yet market-validated
  ///
  /// In en, this message translates to:
  /// **'Placeholder'**
  String get placeholderPrice;

  /// Tooltip and dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit price'**
  String get editPrice;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Monthly price (₹)'**
  String get monthlyPrice;

  /// Help under price
  ///
  /// In en, this message translates to:
  /// **'Applies to new subscriptions. Existing hotels keep their price until renewal.'**
  String get priceChangeHelp;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Limits'**
  String get limits;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limit;

  /// Help under limit
  ///
  /// In en, this message translates to:
  /// **'Leave empty for unlimited.'**
  String get limitHelp;

  /// Limit value
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// Feature name
  ///
  /// In en, this message translates to:
  /// **'QR ordering'**
  String get featQr;

  /// Feature name
  ///
  /// In en, this message translates to:
  /// **'Server ordering'**
  String get featWaiter;

  /// Feature name
  ///
  /// In en, this message translates to:
  /// **'Chefs pick up orders'**
  String get featChefAccept;

  /// Feature name
  ///
  /// In en, this message translates to:
  /// **'Auto-assign to chefs'**
  String get featAutoRouting;

  /// Feature name
  ///
  /// In en, this message translates to:
  /// **'Printed kitchen tickets'**
  String get featAdminPrint;

  /// Feature name
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get featExpenses;

  /// Feature name
  ///
  /// In en, this message translates to:
  /// **'Custom roles'**
  String get featCustomRoles;

  /// Feature name
  ///
  /// In en, this message translates to:
  /// **'Advanced reports'**
  String get featReports;

  /// Feature name
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get featRatings;

  /// Feature name
  ///
  /// In en, this message translates to:
  /// **'API & webhooks'**
  String get featApi;

  /// Feature name
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get featRooms;

  /// Limit name
  ///
  /// In en, this message translates to:
  /// **'Outlets'**
  String get limOutlets;

  /// Limit name
  ///
  /// In en, this message translates to:
  /// **'Tables'**
  String get limTables;

  /// Limit name
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get limStaff;

  /// Limit name
  ///
  /// In en, this message translates to:
  /// **'Chefs'**
  String get limChefs;

  /// Limit name
  ///
  /// In en, this message translates to:
  /// **'Menu items'**
  String get limMenuItems;

  /// Limit name
  ///
  /// In en, this message translates to:
  /// **'Orders per month'**
  String get limOrders;

  /// Diner error title
  ///
  /// In en, this message translates to:
  /// **'This QR code doesn\'t work'**
  String get qrInvalid;

  /// Diner error body
  ///
  /// In en, this message translates to:
  /// **'Please ask a server for help.'**
  String get qrInvalidBody;

  /// Diner page headline
  ///
  /// In en, this message translates to:
  /// **'What would you like?'**
  String get dinerHeadline;

  /// Shown when QR ordering is off
  ///
  /// In en, this message translates to:
  /// **'Browse the menu and tell your server when you\'re ready.'**
  String get dinerViewOnly;

  /// Cart dialog title
  ///
  /// In en, this message translates to:
  /// **'Your order'**
  String get yourOrder;

  /// Tracker title
  ///
  /// In en, this message translates to:
  /// **'Your orders'**
  String get yourOrders;

  /// Diner tracker first step: order sent to the restaurant
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get stepSent;

  /// Order note hint for diners
  ///
  /// In en, this message translates to:
  /// **'Anything the kitchen should know?'**
  String get dinerNoteHint;

  /// Small print under totals
  ///
  /// In en, this message translates to:
  /// **'Prices and taxes are set by the restaurant.'**
  String get pricesByRestaurant;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get placeOrder;

  /// Snackbar
  ///
  /// In en, this message translates to:
  /// **'Order placed. We\'ll update you here.'**
  String get orderPlaced;

  /// Cart bar count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemsCount(int count);

  /// Cart bar button
  ///
  /// In en, this message translates to:
  /// **'View order'**
  String get viewOrder;

  /// Tracker: chef name
  ///
  /// In en, this message translates to:
  /// **'{name} is preparing it'**
  String chefPreparing(String name);

  /// Tracker: ready message
  ///
  /// In en, this message translates to:
  /// **'Ready! It\'s on its way to your table.'**
  String get readyOnItsWay;

  /// Tooltip: print a kitchen order ticket
  ///
  /// In en, this message translates to:
  /// **'Print KOT'**
  String get printKot;

  /// Dialog title
  ///
  /// In en, this message translates to:
  /// **'Print KOT #{number}'**
  String printKotTitle(int number);

  /// Explains the paper path
  ///
  /// In en, this message translates to:
  /// **'Is the kitchen cooking from paper for this order? Sending it on paper takes it off the chefs\' screen so nobody picks it up twice.'**
  String get printKotExplain;

  /// Primary action: print KOT and move order to paper path
  ///
  /// In en, this message translates to:
  /// **'Print and send to kitchen'**
  String get printAndSend;

  /// Secondary action: print without changing the order
  ///
  /// In en, this message translates to:
  /// **'Just print a copy'**
  String get printCopyOnly;

  /// Snackbar
  ///
  /// In en, this message translates to:
  /// **'KOT printed'**
  String get kotPrinted;

  /// Snackbar after paper-path KOT
  ///
  /// In en, this message translates to:
  /// **'KOT printed. The order is now with the kitchen on paper.'**
  String get kotSentOnPaper;

  /// Chip: order handed to the kitchen as a printed ticket
  ///
  /// In en, this message translates to:
  /// **'On paper'**
  String get onPaper;

  /// Kitchen card title
  ///
  /// In en, this message translates to:
  /// **'Cooking from paper'**
  String get onPaperTitle;

  /// Kitchen card help
  ///
  /// In en, this message translates to:
  /// **'Printed tickets handed to the kitchen. Mark them ready when the food comes out.'**
  String get onPaperHelp;

  /// Button on a table: open the bill
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get billTable;

  /// Bill dialog title
  ///
  /// In en, this message translates to:
  /// **'Bill · Table {label}'**
  String billForTable(String label);

  /// Bill dialog help
  ///
  /// In en, this message translates to:
  /// **'Creates one bill for every unbilled order on this table. Bills are numbered and cannot be edited.'**
  String get billExplain;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Create bill'**
  String get createBill;

  /// Warning listing unserved orders
  ///
  /// In en, this message translates to:
  /// **'Not served yet: #{orders}'**
  String notServedYet(String orders);

  /// Button: include unserved orders
  ///
  /// In en, this message translates to:
  /// **'Bill them anyway'**
  String get billAnyway;

  /// Chip: bill paid with a method
  ///
  /// In en, this message translates to:
  /// **'Paid · {method}'**
  String billPaid(String method);

  /// Chip: bill not paid
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get billUnpaid;

  /// Orders on this bill
  ///
  /// In en, this message translates to:
  /// **'Orders #{orders}'**
  String ordersIncluded(String orders);

  /// Central GST line
  ///
  /// In en, this message translates to:
  /// **'CGST'**
  String get cgst;

  /// State GST line
  ///
  /// In en, this message translates to:
  /// **'SGST'**
  String get sgst;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Print bill'**
  String get printBill;

  /// Button when the bill was printed before
  ///
  /// In en, this message translates to:
  /// **'Print duplicate'**
  String get printDuplicate;

  /// Snackbar
  ///
  /// In en, this message translates to:
  /// **'Bill printed'**
  String get billPrinted;

  /// Label above payment method buttons
  ///
  /// In en, this message translates to:
  /// **'Payment received by'**
  String get settlePayment;

  /// Button: cancel an issued bill
  ///
  /// In en, this message translates to:
  /// **'Void bill'**
  String get voidBill;

  /// Profile menu item and dialog title
  ///
  /// In en, this message translates to:
  /// **'Printer setup'**
  String get printerSetup;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get paperSize;

  /// Help under paper size
  ///
  /// In en, this message translates to:
  /// **'Match your printer\'s roll. A4 for office printers.'**
  String get paperSizeHelp;

  /// Paper size
  ///
  /// In en, this message translates to:
  /// **'58 mm'**
  String get paper58;

  /// Paper size
  ///
  /// In en, this message translates to:
  /// **'80 mm'**
  String get paper80;

  /// Paper size
  ///
  /// In en, this message translates to:
  /// **'A4'**
  String get paperA4;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Print using'**
  String get printWith;

  /// Route: OS print dialog
  ///
  /// In en, this message translates to:
  /// **'Print dialog'**
  String get printSystem;

  /// Route: raw ESC/POS over Wi-Fi
  ///
  /// In en, this message translates to:
  /// **'Network printer'**
  String get printNetwork;

  /// Help
  ///
  /// In en, this message translates to:
  /// **'Works with any printer this device can use: thermal, laser, inkjet, Bluetooth or USB.'**
  String get printSystemHelp;

  /// Help
  ///
  /// In en, this message translates to:
  /// **'Sends straight to a Wi-Fi/LAN thermal printer. No dialog; fastest for the kitchen.'**
  String get printNetworkHelp;

  /// Help on web
  ///
  /// In en, this message translates to:
  /// **'In the browser, printing always opens the print dialog. Use the Android or iPhone app to print straight to a network printer.'**
  String get printWebHelp;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Printer IP address'**
  String get printerIp;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Test print'**
  String get testPrint;

  /// Heading printed on the test ticket
  ///
  /// In en, this message translates to:
  /// **'TEST PRINT'**
  String get testPrintTitle;

  /// Body of the test ticket
  ///
  /// In en, this message translates to:
  /// **'If you can read this, the printer works.'**
  String get testPrintBody;

  /// Profile menu toggle state
  ///
  /// In en, this message translates to:
  /// **'Sound alerts: on'**
  String get soundAlertsOn;

  /// Profile menu toggle state
  ///
  /// In en, this message translates to:
  /// **'Sound alerts: off'**
  String get soundAlertsOff;

  /// Snackbar
  ///
  /// In en, this message translates to:
  /// **'Sound alerts on'**
  String get soundOn;

  /// Snackbar
  ///
  /// In en, this message translates to:
  /// **'Sound alerts off'**
  String get soundOff;

  /// Profile menu item
  ///
  /// In en, this message translates to:
  /// **'Test alert sound'**
  String get testSound;

  /// Snackbar when autoplay is blocked
  ///
  /// In en, this message translates to:
  /// **'The browser blocked sound. Tap anywhere on the page, then try again.'**
  String get soundBlocked;

  /// Dashboard card title
  ///
  /// In en, this message translates to:
  /// **'Service times'**
  String get serviceTimes;

  /// Card help
  ///
  /// In en, this message translates to:
  /// **'Orders placed today. p90 = 9 out of 10 orders were faster than this.'**
  String get serviceTimesHelp;

  /// Stage name
  ///
  /// In en, this message translates to:
  /// **'Wait for chef'**
  String get stageWait;

  /// Stage definition
  ///
  /// In en, this message translates to:
  /// **'Order confirmed → cooking starts'**
  String get stageWaitHelp;

  /// Stage name
  ///
  /// In en, this message translates to:
  /// **'Preparation'**
  String get stagePrep;

  /// Stage definition
  ///
  /// In en, this message translates to:
  /// **'Cooking starts → ready'**
  String get stagePrepHelp;

  /// Stage name
  ///
  /// In en, this message translates to:
  /// **'Serving'**
  String get stageServe;

  /// Stage definition
  ///
  /// In en, this message translates to:
  /// **'Ready → on the table'**
  String get stageServeHelp;

  /// Stage name: total time
  ///
  /// In en, this message translates to:
  /// **'Order to table'**
  String get stageTotal;

  /// Stage definition
  ///
  /// In en, this message translates to:
  /// **'What the guest feels'**
  String get stageTotalHelp;

  /// Suffix after average minutes
  ///
  /// In en, this message translates to:
  /// **'min avg'**
  String get minAvg;

  /// Slowest-10% line
  ///
  /// In en, this message translates to:
  /// **'p90 {minutes} min · {count} orders'**
  String p90Line(String minutes, int count);

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Serving time by server'**
  String get servingByServer;

  /// Per-server serving time
  ///
  /// In en, this message translates to:
  /// **'{name}: {minutes} min · {count} served'**
  String serverServeLine(String name, String minutes, int count);

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Dialog and page title
  ///
  /// In en, this message translates to:
  /// **'Expense categories'**
  String get expenseCategories;

  /// Help
  ///
  /// In en, this message translates to:
  /// **'Global categories are set for every hotel. Add your own for anything else; only your hotel sees them.'**
  String get categoriesHelp;

  /// Chip: category from the platform
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get scopeGlobal;

  /// Chip: hotel's own category
  ///
  /// In en, this message translates to:
  /// **'Yours'**
  String get scopeHotel;

  /// Dialog title
  ///
  /// In en, this message translates to:
  /// **'Rename category'**
  String get renameCategory;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Add your own category'**
  String get addOwnCategory;

  /// Help
  ///
  /// In en, this message translates to:
  /// **'Visible only to your hotel.'**
  String get addOwnCategoryHelp;

  /// Platform navigation tab
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get tabCategories;

  /// Help
  ///
  /// In en, this message translates to:
  /// **'Categories here appear for every hotel immediately. Switching one off hides it for new expenses; past expenses keep it.'**
  String get globalCategoriesHelp;

  /// Field hint
  ///
  /// In en, this message translates to:
  /// **'New global category'**
  String get newGlobalCategory;

  /// Snackbar
  ///
  /// In en, this message translates to:
  /// **'Added for every hotel'**
  String get globalCategoryAdded;

  /// How many expenses use a category
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{unused} =1{used once} other{used {count} times}}'**
  String usedTimes(int count);

  /// Table menu: print this table's QR code
  ///
  /// In en, this message translates to:
  /// **'Print QR'**
  String get printQr;

  /// Button: print QR codes for every active table
  ///
  /// In en, this message translates to:
  /// **'Print all QR codes'**
  String get printAllQr;

  /// Button: unlock sound and ask for notification permission
  ///
  /// In en, this message translates to:
  /// **'Enable alerts'**
  String get enableAlerts;

  /// Banner text in the browser
  ///
  /// In en, this message translates to:
  /// **'Turn on loud alerts for new and ready orders. Keep this tab open for the loud sound; when the tab is closed you get a normal notification.'**
  String get enableAlertsBody;

  /// Banner text when notification permission is denied
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked for this site in your browser settings. Tap to turn on the loud in-page sound; keep this tab open.'**
  String get enableAlertsDenied;

  /// Dismiss button
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// Language switcher label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Native name of English; identical in every language file
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEn;

  /// Native name of Telugu; identical in every language file
  ///
  /// In en, this message translates to:
  /// **'తెలుగు'**
  String get langTe;

  /// Native name of Hindi; identical in every language file
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get langHi;

  /// Settings tab: logo and address
  ///
  /// In en, this message translates to:
  /// **'Branding'**
  String get branding;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Hotel logo'**
  String get hotelLogo;

  /// Help under logo
  ///
  /// In en, this message translates to:
  /// **'Shown in the app and printed on table QR cards. PNG or JPEG.'**
  String get hotelLogoHelp;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Upload logo'**
  String get uploadLogo;

  /// Button when a logo exists
  ///
  /// In en, this message translates to:
  /// **'Replace logo'**
  String get replaceLogo;

  /// Button: delete logo
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeLogo;

  /// Confirmation message after uploading a logo
  ///
  /// In en, this message translates to:
  /// **'Logo updated'**
  String get logoUpdated;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Address (one line)'**
  String get addressLine;

  /// Help under address
  ///
  /// In en, this message translates to:
  /// **'Printed under your hotel name on QR cards.'**
  String get addressLineHelp;

  /// Note in branding settings
  ///
  /// In en, this message translates to:
  /// **'QR cards end with a small \"Powered by\" line from the platform.'**
  String get poweredByNote;

  /// Generic error
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errGeneric;

  /// Network error
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Check the connection and retry.'**
  String get errOffline;

  /// Login error
  ///
  /// In en, this message translates to:
  /// **'Email or password is wrong.'**
  String get errCredentials;

  /// Feature locked error
  ///
  /// In en, this message translates to:
  /// **'Your plan doesn\'t include this. Upgrade to unlock it.'**
  String get errFeatureLocked;

  /// Plan limit error
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your plan\'s limit.'**
  String get errLimit;

  /// Permission error
  ///
  /// In en, this message translates to:
  /// **'Your role doesn\'t allow this.'**
  String get errPermission;

  /// Accept race lost
  ///
  /// In en, this message translates to:
  /// **'Another chef already picked this order.'**
  String get errTaken;

  /// Chef queue full
  ///
  /// In en, this message translates to:
  /// **'Finish an order before picking another.'**
  String get errQueueFull;

  /// Strict queue error
  ///
  /// In en, this message translates to:
  /// **'Finish the order ahead of this one first.'**
  String get errNotHead;

  /// Item unavailable error
  ///
  /// In en, this message translates to:
  /// **'An item just sold out. Please update your order.'**
  String get errSoldOut;

  /// Diner session expired
  ///
  /// In en, this message translates to:
  /// **'Your table session ended. Scan the QR again.'**
  String get errSessionExpired;

  /// Validation: empty field
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get errRequired;

  /// Validation: email
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get errEmail;

  /// Validation: amount
  ///
  /// In en, this message translates to:
  /// **'Enter an amount like 250 or 99.50'**
  String get errAmount;

  /// Validation: password length
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get errPasswordLength;

  /// Validation: GSTIN
  ///
  /// In en, this message translates to:
  /// **'Enter a 15-character GSTIN'**
  String get errGstin;

  /// Confirmation shown above the settings dialog after a successful save (the dialog stays open)
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// Confirmation shown after saving the hotel address on the Branding tab
  ///
  /// In en, this message translates to:
  /// **'Branding saved'**
  String get brandingSaved;

  /// Next-step line on an order waiting for staff confirmation
  ///
  /// In en, this message translates to:
  /// **'Next: confirm this order'**
  String get nextConfirm;

  /// Next-step line: order is on the chefs' board
  ///
  /// In en, this message translates to:
  /// **'Next: a chef picks it up on the Kitchen screen'**
  String get nextChefPickup;

  /// Next-step line in auto-assign mode when every chef is busy
  ///
  /// In en, this message translates to:
  /// **'Next: waiting for a free chef'**
  String get nextFreeChef;

  /// Next-step line in printed-ticket mode
  ///
  /// In en, this message translates to:
  /// **'Next: print the KOT for the kitchen'**
  String get nextPrintKot;

  /// Next-step line: assigned to a chef who has not started
  ///
  /// In en, this message translates to:
  /// **'Next: {chef} starts cooking'**
  String nextChefStarts(String chef);

  /// Order line: a chef is cooking it
  ///
  /// In en, this message translates to:
  /// **'{chef} is cooking'**
  String nowCooking(String chef);

  /// Order line: paper path
  ///
  /// In en, this message translates to:
  /// **'Cooking from the printed KOT. Mark ready when it comes out'**
  String get nowCookingPaper;

  /// Next-step line: food is ready and a waiter carries it
  ///
  /// In en, this message translates to:
  /// **'Next: serve it to the table'**
  String get nextServe;

  /// Next-step line: served and not billed yet
  ///
  /// In en, this message translates to:
  /// **'Next: bill the table'**
  String get nextBill;

  /// Warning chip: no chef took the order within the alert time
  ///
  /// In en, this message translates to:
  /// **'Not picked up in time'**
  String get notPickedUp;

  /// Alert shown to admins and chefs when an order waits too long
  ///
  /// In en, this message translates to:
  /// **'Order #{number} ({place}) has not been picked up'**
  String pickupOverdueToast(int number, String place);

  /// Table status: food served, not paid yet
  ///
  /// In en, this message translates to:
  /// **'Bill pending'**
  String get billPending;

  /// Button: open the bill for this table
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get billNow;

  /// Bottom navigation tab: list of all orders
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get tabOrders;

  /// Orders screen filter: last 24 hours
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get ordersToday2;

  /// Empty state on the Orders screen
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// Orders screen: the order is on a bill
  ///
  /// In en, this message translates to:
  /// **'Billed'**
  String get billed;

  /// Settings label: serving mode
  ///
  /// In en, this message translates to:
  /// **'How food reaches the table'**
  String get servingMode;

  /// Serving mode option
  ///
  /// In en, this message translates to:
  /// **'Waiter serves'**
  String get serveByWaiter;

  /// Serving mode option
  ///
  /// In en, this message translates to:
  /// **'Diner collects at counter'**
  String get serveAtCounter;

  /// Settings help for serving mode
  ///
  /// In en, this message translates to:
  /// **'Counter: when food is ready the diner is told to collect it; there is no Served step.'**
  String get servingModeHelp;

  /// Settings label: no-pickup alert time
  ///
  /// In en, this message translates to:
  /// **'Alert if no chef picks up within'**
  String get pickupAlert;

  /// Settings help for the no-pickup alert
  ///
  /// In en, this message translates to:
  /// **'Admins and chefs on shift get a loud alert.'**
  String get pickupAlertHelp;

  /// Option: feature switched off
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// Diner page: order ready in counter mode
  ///
  /// In en, this message translates to:
  /// **'Ready! Please collect it from the counter.'**
  String get collectAtCounter;

  /// Profile menu item and dialog title
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Type the new password again'**
  String get confirmNewPassword;

  /// Validation
  ///
  /// In en, this message translates to:
  /// **'The two new passwords don\'t match'**
  String get passwordsDontMatch;

  /// Confirmation after changing own password
  ///
  /// In en, this message translates to:
  /// **'Password changed. Other devices are signed out.'**
  String get passwordChanged;

  /// Error
  ///
  /// In en, this message translates to:
  /// **'Current password is wrong'**
  String get errWrongPassword;

  /// Error: new password equals the current one
  ///
  /// In en, this message translates to:
  /// **'Choose a different password'**
  String get errSamePassword;

  /// Team menu item: set a new password for a staff member
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// Dialog title
  ///
  /// In en, this message translates to:
  /// **'Reset password for {name}'**
  String resetPasswordFor(String name);

  /// Dialog help
  ///
  /// In en, this message translates to:
  /// **'They are signed out everywhere. Give them the new password in person; they can change it from their profile.'**
  String get resetPasswordHelp;

  /// Confirmation
  ///
  /// In en, this message translates to:
  /// **'Password reset for {name}'**
  String passwordResetDone(String name);

  /// My work period filter
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get periodToday;

  /// My work period filter
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get periodWeek;

  /// My work section title for chefs
  ///
  /// In en, this message translates to:
  /// **'Your cooking'**
  String get myCooking;

  /// My work section title for waiters
  ///
  /// In en, this message translates to:
  /// **'Your serving'**
  String get myServing;

  /// My work section title for cashiers
  ///
  /// In en, this message translates to:
  /// **'Your billing'**
  String get myBilling;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Orders cooked'**
  String get statOrdersCooked;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Items cooked'**
  String get statItemsCooked;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Avg cooking time'**
  String get statAvgCook;

  /// Stat label: average minutes from order confirmed to this chef starting it
  ///
  /// In en, this message translates to:
  /// **'Avg wait to start'**
  String get statAvgWaitStart;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'In your queue now'**
  String get statInQueue;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Orders served'**
  String get statOrdersServed;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Tables served'**
  String get statTablesServed;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Avg ready to table'**
  String get statAvgServe;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Orders you took'**
  String get statOrdersTaken;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Ready to serve now'**
  String get statReadyNow;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Bills raised'**
  String get statBillsRaised;

  /// Stat label: money received on your paid bills
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get statCollected;

  /// Stat label (whole hotel)
  ///
  /// In en, this message translates to:
  /// **'Unpaid bills now'**
  String get statUnpaidNow;

  /// Caption under a personal average, e.g. 'Team 12.5 min'
  ///
  /// In en, this message translates to:
  /// **'Team {value}'**
  String teamAverage(String value);

  /// Minutes with one decimal, e.g. 12.5 min
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String minutesDecimal(String value);

  /// Empty state
  ///
  /// In en, this message translates to:
  /// **'Nothing yet in this period'**
  String get noWorkYet;

  /// Bill window: the guest ordered more after the bill was issued
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new order since this bill} other{{count} new orders since this bill}}'**
  String newOrdersSinceBill(int count);

  /// Button: replace the unpaid bill with one covering every order
  ///
  /// In en, this message translates to:
  /// **'Update bill'**
  String get updateBill;

  /// Help under Update bill
  ///
  /// In en, this message translates to:
  /// **'The current bill is cancelled and one new bill covers everything.'**
  String get updateBillHelp;

  /// Confirmation after a bill replaced an earlier one
  ///
  /// In en, this message translates to:
  /// **'{old} cancelled. {next} has every order.'**
  String billReplaced(String old, String next);

  /// Bill status: void
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get billCancelled;

  /// Orders screen: tables whose food is served but not paid
  ///
  /// In en, this message translates to:
  /// **'Tables to bill'**
  String get tablesToBill;

  /// Orders screen toggle
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get viewOrders;

  /// Orders screen toggle: bills register
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get viewBills;

  /// Date filter
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Date filter: open a date range picker
  ///
  /// In en, this message translates to:
  /// **'Pick dates'**
  String get pickDates;

  /// Search box hint on Orders
  ///
  /// In en, this message translates to:
  /// **'Order # or table'**
  String get searchOrdersHint;

  /// Search box hint on Bills
  ///
  /// In en, this message translates to:
  /// **'Bill # or table'**
  String get searchBillsHint;

  /// Button at the end of a long list
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// Empty state on Bills
  ///
  /// In en, this message translates to:
  /// **'No bills in this period'**
  String get noBillsYet;

  /// Error: date range too long
  ///
  /// In en, this message translates to:
  /// **'Pick at most 31 days'**
  String get errRangeTooLong;

  /// Button: show this order's bill
  ///
  /// In en, this message translates to:
  /// **'Open bill'**
  String get openBill;

  /// Bills filter: paid bills
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// Bills register: how many copies were printed
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Printed once} other{Printed {count} times}}'**
  String printedTimes(int count);

  /// Order type: no table, the guest collects it
  ///
  /// In en, this message translates to:
  /// **'Takeaway'**
  String get takeaway;

  /// Floor button: take a takeaway / counter order
  ///
  /// In en, this message translates to:
  /// **'Takeaway'**
  String get newTakeaway;

  /// Order title for a takeaway order
  ///
  /// In en, this message translates to:
  /// **'Takeaway #{number}'**
  String takeawayTitle(int number);

  /// Order title for a takeaway order with the guest's name
  ///
  /// In en, this message translates to:
  /// **'Takeaway #{number} · {name}'**
  String takeawayTitleFor(int number, String name);

  /// Where an order goes: takeaway for this guest
  ///
  /// In en, this message translates to:
  /// **'Takeaway · {name}'**
  String takeawayFor(String name);

  /// Takeaway: name the guest collects with
  ///
  /// In en, this message translates to:
  /// **'Guest name (optional)'**
  String get guestName;

  /// Takeaway: guest phone
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get guestPhone;

  /// Button: the takeaway guest collected the order
  ///
  /// In en, this message translates to:
  /// **'Handed over'**
  String get handedOver;

  /// Next-step line: takeaway order ready
  ///
  /// In en, this message translates to:
  /// **'Next: hand it over to the guest'**
  String get nextHandOver;

  /// Next-step line: takeaway handed over, not billed
  ///
  /// In en, this message translates to:
  /// **'Next: bill this order'**
  String get nextBillOrder;

  /// Order channel label
  ///
  /// In en, this message translates to:
  /// **'Takeaway'**
  String get channelTakeaway;

  /// Bill window title for a takeaway order
  ///
  /// In en, this message translates to:
  /// **'Bill · {title}'**
  String billForOrder(String title);

  /// Bill line and button: discount
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// Bill window button
  ///
  /// In en, this message translates to:
  /// **'Add discount'**
  String get addDiscount;

  /// Discount kind: percent of the bill
  ///
  /// In en, this message translates to:
  /// **'Percent'**
  String get discountByPercent;

  /// Discount kind: fixed rupee amount
  ///
  /// In en, this message translates to:
  /// **'Amount (₹)'**
  String get discountByAmount;

  /// Discount value field
  ///
  /// In en, this message translates to:
  /// **'How much'**
  String get discountValue;

  /// Discount reason field
  ///
  /// In en, this message translates to:
  /// **'Reason (printed on the bill)'**
  String get discountReason;

  /// Shown under the discount form
  ///
  /// In en, this message translates to:
  /// **'Your limit: {limit}'**
  String discountLimit(String limit);

  /// Discount form help
  ///
  /// In en, this message translates to:
  /// **'Tax is recalculated on the discounted amount. A printed bill is replaced by a new one.'**
  String get discountHelp;

  /// Bill line: subtotal after discount
  ///
  /// In en, this message translates to:
  /// **'Taxable value'**
  String get taxableValue;

  /// Roles matrix row: largest discount the role may give
  ///
  /// In en, this message translates to:
  /// **'Max bill discount'**
  String get maxBillDiscount;

  /// Error: discount over the role limit
  ///
  /// In en, this message translates to:
  /// **'That is more than your role may give ({limit})'**
  String errDiscountLimit(String limit);

  /// Validation: discount form
  ///
  /// In en, this message translates to:
  /// **'Enter a valid discount and a reason'**
  String get errBadDiscount;

  /// Shown instead of the discount button
  ///
  /// In en, this message translates to:
  /// **'Your role cannot give discounts'**
  String get noDiscountAllowed;

  /// Bill window: amount paid so far
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidSoFar;

  /// Bill window: amount still due
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get dueNow;

  /// Button: record one part of the payment
  ///
  /// In en, this message translates to:
  /// **'Pay part'**
  String get payPart;

  /// Button: equal shares per guest
  ///
  /// In en, this message translates to:
  /// **'Split equally'**
  String get splitEqually;

  /// Split dialog label
  ///
  /// In en, this message translates to:
  /// **'How many guests?'**
  String get howManyGuests;

  /// One equal share
  ///
  /// In en, this message translates to:
  /// **'Guest {n}: {amount}'**
  String guestShare(int n, String amount);

  /// Button next to a share
  ///
  /// In en, this message translates to:
  /// **'Pay this share'**
  String get payThisShare;

  /// Pay part: amount field
  ///
  /// In en, this message translates to:
  /// **'Amount received'**
  String get amountReceived;

  /// Pay part: reference field
  ///
  /// In en, this message translates to:
  /// **'Reference (optional: UPI ref, card slip)'**
  String get paymentRef;

  /// Tooltip: undo a part entered by mistake
  ///
  /// In en, this message translates to:
  /// **'Remove this payment'**
  String get removePayment;

  /// Payment method: several parts
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get payMixed;

  /// Error
  ///
  /// In en, this message translates to:
  /// **'That is more than is due ({due})'**
  String errOverpayment(String due);

  /// Error: void refused
  ///
  /// In en, this message translates to:
  /// **'Part of this bill is paid. Remove those payments first.'**
  String get errHasPayments;

  /// Error
  ///
  /// In en, this message translates to:
  /// **'More has been paid than the new total. Remove a payment first.'**
  String get errPaymentsExceedTotal;

  /// Label above the method buttons
  ///
  /// In en, this message translates to:
  /// **'Pay what is due'**
  String get payWholeDue;

  /// Reports screen title and the Overview button that opens it
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// Reports tab: sales by day
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get reportSales;

  /// Reports tab: item-wise sales
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get reportItems;

  /// Reports tab: GST summary
  ///
  /// In en, this message translates to:
  /// **'GST'**
  String get reportGst;

  /// Reports tab: per staff member
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get reportStaff;

  /// Button: save this report as a spreadsheet file
  ///
  /// In en, this message translates to:
  /// **'Download CSV'**
  String get downloadCsv;

  /// Button: every bill in the dates, for the accountant
  ///
  /// In en, this message translates to:
  /// **'Bills register (CSV)'**
  String get billsRegisterCsv;

  /// Toast after a file download
  ///
  /// In en, this message translates to:
  /// **'Saved {name}'**
  String fileSaved(String name);

  /// What the sales report counts (shown under the title)
  ///
  /// In en, this message translates to:
  /// **'Counts bills issued on the hotel\'s calendar day. Cancelled bills are left out and shown separately.'**
  String get basisSales;

  /// What the items report counts
  ///
  /// In en, this message translates to:
  /// **'Dishes on issued bills, as printed. Cancelled bills are left out.'**
  String get basisItems;

  /// What the GST summary counts; sac is the services code
  ///
  /// In en, this message translates to:
  /// **'Tax per rate exactly as printed on each bill. B2C, within the state (CGST + SGST). SAC {sac}.'**
  String basisGst(String sac);

  /// What the staff report counts
  ///
  /// In en, this message translates to:
  /// **'Bills each person raised, discounts they gave and money they received.'**
  String get basisStaff;

  /// Report line: value at menu prices before discounts
  ///
  /// In en, this message translates to:
  /// **'Gross (menu value)'**
  String get ladderGross;

  /// Report line: total discounts (shown with a minus)
  ///
  /// In en, this message translates to:
  /// **'Discounts'**
  String get ladderDiscount;

  /// Report line: gross minus discounts
  ///
  /// In en, this message translates to:
  /// **'Taxable value'**
  String get ladderTaxable;

  /// Report line: tax that is not CGST/SGST
  ///
  /// In en, this message translates to:
  /// **'Other tax'**
  String get ladderOtherTax;

  /// Report line: rounding difference
  ///
  /// In en, this message translates to:
  /// **'Round off'**
  String get ladderRoundOff;

  /// Report line: what guests were billed
  ///
  /// In en, this message translates to:
  /// **'Bill total'**
  String get ladderTotal;

  /// Count of bills
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bill} other{{count} bills}}'**
  String repBills(int count);

  /// Note: replaced bills are counted once (the new bill)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bill replaced when more food was added} other{{count} bills replaced when more food was added}}'**
  String repReplaced(int count);

  /// Report section: cash/UPI/card actually taken
  ///
  /// In en, this message translates to:
  /// **'Money received'**
  String get repReceived;

  /// Warning: food ordered with no bill
  ///
  /// In en, this message translates to:
  /// **'Not billed yet: {count, plural, =1{1 order} other{{count} orders}}, {amount}'**
  String repUnbilled(int count, String amount);

  /// Explains the not-billed warning
  ///
  /// In en, this message translates to:
  /// **'Bill these or cancel the order. They are not counted as sales.'**
  String get repUnbilledHelp;

  /// Report section: one row per day
  ///
  /// In en, this message translates to:
  /// **'By day'**
  String get repByDay;

  /// Empty report
  ///
  /// In en, this message translates to:
  /// **'No bills in these dates'**
  String get repNoBills;

  /// Item quantity sold
  ///
  /// In en, this message translates to:
  /// **'{qty} sold'**
  String repSold(int qty);

  /// Row title for one GST rate, e.g. GST 5%
  ///
  /// In en, this message translates to:
  /// **'GST {rate}'**
  String gstRate(String rate);

  /// GST summary section (GSTR-1 table 13)
  ///
  /// In en, this message translates to:
  /// **'Documents issued'**
  String get gstDocuments;

  /// Invoice number range and counts
  ///
  /// In en, this message translates to:
  /// **'{from} to {to}: {count} issued, {cancelled} cancelled, {net} net'**
  String gstDocCounts(
    String from,
    String to,
    int count,
    int cancelled,
    int net,
  );

  /// Bill document type (GST registered)
  ///
  /// In en, this message translates to:
  /// **'Tax invoice'**
  String get docTaxInvoice;

  /// Bill document type (composition scheme)
  ///
  /// In en, this message translates to:
  /// **'Bill of supply'**
  String get docBillOfSupply;

  /// Bill document type (not GST registered)
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get docBill;

  /// Staff report: discounts given
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 discount} other{{count} discounts}} · {amount}'**
  String staffDiscounts(int count, String amount);

  /// Staff report: bills this person cancelled
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bill cancelled by hand} other{{count} bills cancelled by hand}}'**
  String staffCancelled(int count);

  /// Empty staff report
  ///
  /// In en, this message translates to:
  /// **'No bills or payments by staff in these dates'**
  String get noStaffActivity;

  /// Error: date range too long
  ///
  /// In en, this message translates to:
  /// **'Pick at most {days} days'**
  String errRangeTooLongDays(int days);

  /// Overview warning: food ordered today that is on no bill; tap opens Orders
  ///
  /// In en, this message translates to:
  /// **'Not billed yet today: {amount}'**
  String unbilledToday(String amount);

  /// Button: one GST bill per guest, by what each had
  ///
  /// In en, this message translates to:
  /// **'Split by items'**
  String get splitByItems;

  /// How to use the split screen
  ///
  /// In en, this message translates to:
  /// **'Tap a guest to give them one; the x takes one back. Shared: the ticked guests pay an equal part.'**
  String get splitByItemsHelp;

  /// Label for the number of guests
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get guestsCount;

  /// One guest in a split
  ///
  /// In en, this message translates to:
  /// **'Guest {n}'**
  String guestN(int n);

  /// Guest chip with how many units they have
  ///
  /// In en, this message translates to:
  /// **'Guest {n} · {count}'**
  String guestUnits(int n, int count);

  /// Which guest bill this is
  ///
  /// In en, this message translates to:
  /// **'Guest {n} of {m}'**
  String guestNofM(int n, int m);

  /// Units of a dish not given to anyone yet
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String splitLeft(int count);

  /// Switch: this dish is shared equally by the ticked guests
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get splitShared;

  /// Button: issue one bill per guest
  ///
  /// In en, this message translates to:
  /// **'Create {count} bills'**
  String splitCreate(int count);

  /// Why the split cannot be created yet
  ///
  /// In en, this message translates to:
  /// **'Give out every dish and give every guest something'**
  String get splitIncomplete;

  /// Toast after a split
  ///
  /// In en, this message translates to:
  /// **'{count} guest bills issued'**
  String splitDone(int count);

  /// Section listing every guest bill of a split
  ///
  /// In en, this message translates to:
  /// **'Guest bills'**
  String get guestBills;

  /// Empty split screen
  ///
  /// In en, this message translates to:
  /// **'Nothing to split at this table yet'**
  String get splitNothing;

  /// Error: orders changed while splitting
  ///
  /// In en, this message translates to:
  /// **'The table\'s items changed. The list has been refreshed.'**
  String get errLinesChanged;

  /// Error: void refused on a split
  ///
  /// In en, this message translates to:
  /// **'A guest has already paid, so this split cannot be cancelled.'**
  String get errSplitPartlyPaid;

  /// Error: a discounted bill cannot be split by items
  ///
  /// In en, this message translates to:
  /// **'This bill has a discount. Cancel it first, then split by items.'**
  String get errBillDiscounted;

  /// Label above Half / Full
  ///
  /// In en, this message translates to:
  /// **'Choose a size'**
  String get chooseSize;

  /// Add-on group rule: optional, at most max
  ///
  /// In en, this message translates to:
  /// **'Up to {max}'**
  String pickUpTo(int max);

  /// Add-on group rule: exactly n
  ///
  /// In en, this message translates to:
  /// **'Choose {n}'**
  String pickExactly(int n);

  /// Add-on group rule
  ///
  /// In en, this message translates to:
  /// **'Choose {min} to {max}'**
  String pickBetween(int min, int max);

  /// Button: add the dish with its size and add-ons
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addToOrder;

  /// Hint on a dish that opens a choice sheet
  ///
  /// In en, this message translates to:
  /// **'Sizes / add-ons'**
  String get hasOptions;

  /// Error from the server
  ///
  /// In en, this message translates to:
  /// **'Choose a size first'**
  String get errVariantRequired;

  /// Error from the server
  ///
  /// In en, this message translates to:
  /// **'Check the add-on choices'**
  String get errAddonCount;

  /// Tooltip: remove a dish (with its size and add-ons) from the order being built
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeLine;

  /// Menu: a dish's sizes (Half / Full)
  ///
  /// In en, this message translates to:
  /// **'Sizes'**
  String get sizes;

  /// Explains sizes
  ///
  /// In en, this message translates to:
  /// **'Two or more sizes, each with its own price (e.g. Half ₹180, Full ₹320). Remove them all to sell the dish at one price.'**
  String get sizesHelp;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Add size'**
  String get addSize;

  /// Hint for a size name
  ///
  /// In en, this message translates to:
  /// **'e.g. Half'**
  String get sizeNameHint;

  /// Validation
  ///
  /// In en, this message translates to:
  /// **'Give two or more sizes, or none'**
  String get errSizesCount;

  /// Validation
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price'**
  String get errPriceInvalid;

  /// Menu: add-ons offered with a dish
  ///
  /// In en, this message translates to:
  /// **'Add-ons'**
  String get addons;

  /// Menu: reusable add-on groups
  ///
  /// In en, this message translates to:
  /// **'Add-on groups'**
  String get addonGroups;

  /// Explains add-on groups
  ///
  /// In en, this message translates to:
  /// **'Make a group once (e.g. Extras, Choose your bread) and offer it with any dish.'**
  String get addonGroupsHelp;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get newGroup;

  /// Hint for a group name
  ///
  /// In en, this message translates to:
  /// **'e.g. Extras'**
  String get groupNameHint;

  /// How many add-ons must be picked
  ///
  /// In en, this message translates to:
  /// **'At least'**
  String get minPicks;

  /// How many add-ons may be picked
  ///
  /// In en, this message translates to:
  /// **'At most'**
  String get maxPicks;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Add add-on'**
  String get addAddon;

  /// Hint for an add-on name
  ///
  /// In en, this message translates to:
  /// **'e.g. Raita'**
  String get addonNameHint;

  /// Which dishes offer this group
  ///
  /// In en, this message translates to:
  /// **'Used by: {names}'**
  String usedBy(String names);

  /// Group not attached anywhere
  ///
  /// In en, this message translates to:
  /// **'Not offered with any dish yet'**
  String get notUsedYet;

  /// Explains attaching groups to a dish
  ///
  /// In en, this message translates to:
  /// **'Choose which add-on groups {item} offers.'**
  String addonsForItem(String item);

  /// Empty state
  ///
  /// In en, this message translates to:
  /// **'No add-on groups yet. Create one in Add-on groups.'**
  String get noAddonGroups;

  /// Confirm deleting an add-on group
  ///
  /// In en, this message translates to:
  /// **'Delete {name}? Dishes using it will stop offering it. Orders already placed keep their add-ons.'**
  String deleteGroupConfirm(String name);

  /// Toast
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// Badge on a dish while a happy-hour offer runs
  ///
  /// In en, this message translates to:
  /// **'{name} −{percent} till {time}'**
  String offerBadge(String name, String percent, String time);

  /// Menu: time-based offers
  ///
  /// In en, this message translates to:
  /// **'Happy hour'**
  String get happyHour;

  /// Explains happy hour
  ///
  /// In en, this message translates to:
  /// **'Percent off the dish or size price on chosen days and times, for every order (waiter or QR). Add-ons keep their price; overlapping offers never add up.'**
  String get happyHourHelp;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'New offer'**
  String get newOffer;

  /// Hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Happy hour'**
  String get offerNameHint;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Percent off'**
  String get percentOff;

  /// Field label
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// Start time
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromTime;

  /// End time
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toTime;

  /// Field label: which categories
  ///
  /// In en, this message translates to:
  /// **'Applies to'**
  String get appliesTo;

  /// No category chosen = whole menu
  ///
  /// In en, this message translates to:
  /// **'Whole menu'**
  String get wholeMenu;

  /// Switch label: offer is switched on
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get offerOn;

  /// Empty state
  ///
  /// In en, this message translates to:
  /// **'No offers yet'**
  String get noOffers;

  /// One offer in the list
  ///
  /// In en, this message translates to:
  /// **'{percent} off · {days} · {from}–{to}'**
  String offerSummary(String percent, String days, String from, String to);

  /// All seven days
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// Validation
  ///
  /// In en, this message translates to:
  /// **'Enter a percent between 0.01 and 90'**
  String get errBadPercent;

  /// Validation
  ///
  /// In en, this message translates to:
  /// **'Start and end times must differ'**
  String get errSameTimes;

  /// Menu: a dish made of other dishes
  ///
  /// In en, this message translates to:
  /// **'Combo'**
  String get combo;

  /// Explains combos
  ///
  /// In en, this message translates to:
  /// **'List the dishes in this combo. It keeps its own price and tax. For a choice (e.g. a drink), attach an add-on group set to choose 1.'**
  String get comboHelp;

  /// Validation
  ///
  /// In en, this message translates to:
  /// **'A combo needs at least two dishes. Remove them all to make it an ordinary dish.'**
  String get comboNeedsTwo;

  /// Error from the server
  ///
  /// In en, this message translates to:
  /// **'That combo isn\'t allowed (a combo can\'t contain itself or another combo, and needs two dishes)'**
  String get errBadCombo;

  /// Error: delete refused
  ///
  /// In en, this message translates to:
  /// **'This dish is in a combo. Take it out of the combo first, or mark it sold out.'**
  String get errItemInCombo;

  /// Button: rename a category and set its serving hours
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// Field label: when a category's dishes can be ordered
  ///
  /// In en, this message translates to:
  /// **'Serving hours'**
  String get servingHours;

  /// Switch: no time window
  ///
  /// In en, this message translates to:
  /// **'Served all day'**
  String get servedAllDay;

  /// Label on a section outside its hours, e.g. Served 07:00-11:00
  ///
  /// In en, this message translates to:
  /// **'Served {hours}'**
  String servedHours(String hours);

  /// Warning title
  ///
  /// In en, this message translates to:
  /// **'Not served now'**
  String get outsideHoursTitle;

  /// Staff warning before ordering outside hours
  ///
  /// In en, this message translates to:
  /// **'{items} ({category}, {hours}) are outside their serving hours. Order anyway?'**
  String outsideHoursBody(String items, String category, String hours);

  /// Button: send the order despite the serving hours
  ///
  /// In en, this message translates to:
  /// **'Order anyway'**
  String get orderAnyway;

  /// Error for diners
  ///
  /// In en, this message translates to:
  /// **'Not served at this time'**
  String get errOutsideHours;

  /// Overview button and screen title: count the cash drawer
  ///
  /// In en, this message translates to:
  /// **'Close day'**
  String get closeDay;

  /// Explains the close day screen
  ///
  /// In en, this message translates to:
  /// **'What the drawer should hold, from everything recorded on every device today. Count the cash and enter it below.'**
  String get closeDayHelp;

  /// Tab
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Tab
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Cash in the drawer at the start of the day
  ///
  /// In en, this message translates to:
  /// **'Opening float'**
  String get openingFloat;

  /// Cash payments taken today
  ///
  /// In en, this message translates to:
  /// **'Cash received'**
  String get cashReceived;

  /// Cash expenses paid from the drawer
  ///
  /// In en, this message translates to:
  /// **'Cash paid out (expenses)'**
  String get cashPaidOut;

  /// Expected cash
  ///
  /// In en, this message translates to:
  /// **'Should be in the drawer'**
  String get expectedInDrawer;

  /// Input: what is in the drawer
  ///
  /// In en, this message translates to:
  /// **'Cash counted'**
  String get countedCash;

  /// Input: tomorrow's opening float
  ///
  /// In en, this message translates to:
  /// **'Keep in the drawer for tomorrow'**
  String get keepForTomorrow;

  /// Counted minus kept
  ///
  /// In en, this message translates to:
  /// **'To the bank: {amount}'**
  String toDeposit(String amount);

  /// Result: more cash than expected
  ///
  /// In en, this message translates to:
  /// **'Over {amount}'**
  String cashOver(String amount);

  /// Result: less cash than expected
  ///
  /// In en, this message translates to:
  /// **'Short {amount}'**
  String cashShort(String amount);

  /// Result: no difference
  ///
  /// In en, this message translates to:
  /// **'Exact'**
  String get cashExact;

  /// Note label when over or short
  ///
  /// In en, this message translates to:
  /// **'Why is it different? (needed)'**
  String get whyDifferent;

  /// Button: save the final close
  ///
  /// In en, this message translates to:
  /// **'Close the day'**
  String get closeDayButton;

  /// Confirm before closing
  ///
  /// In en, this message translates to:
  /// **'This is final. Tomorrow\'s opening float will be what you keep in the drawer.'**
  String get closeDayConfirm;

  /// Who closed the day
  ///
  /// In en, this message translates to:
  /// **'Closed by {name} at {time}'**
  String dayClosedBy(String name, String time);

  /// Cash payments after the close
  ///
  /// In en, this message translates to:
  /// **'Cash taken after closing: {amount}'**
  String cashAfterClose(String amount);

  /// Warning before closing
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bill is still unpaid} other{{count} bills are still unpaid}} ({amount})'**
  String unpaidBillsWarning(int count, String amount);

  /// History summary
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No short days} =1{1 short day} other{{count} short days}}'**
  String shortDays(int count);

  /// History summary
  ///
  /// In en, this message translates to:
  /// **'Net over/short: {amount}'**
  String netOverShort(String amount);

  /// Empty history
  ///
  /// In en, this message translates to:
  /// **'No days closed yet'**
  String get noCloses;

  /// Error
  ///
  /// In en, this message translates to:
  /// **'Say why the cash is over or short'**
  String get errNoteRequired;

  /// Error
  ///
  /// In en, this message translates to:
  /// **'This day is already closed'**
  String get errAlreadyClosed;

  /// Table state: guests sat, nothing ordered yet
  ///
  /// In en, this message translates to:
  /// **'Seated'**
  String get seated;

  /// Table state: paid, needs clearing
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get cleaning;

  /// Table state: held for a booking
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get reserved;

  /// Button: start a table visit
  ///
  /// In en, this message translates to:
  /// **'Seat guests'**
  String get seatGuests;

  /// Question when seating
  ///
  /// In en, this message translates to:
  /// **'How many guests?'**
  String get guestsCountLabel;

  /// Seated line on a table, e.g. 4 guests · 25 min
  ///
  /// In en, this message translates to:
  /// **'{guests} · {minutes} min'**
  String guestsAndTime(String guests, int minutes);

  /// Guest count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 guest} other{{count} guests}}'**
  String guestsN(int count);

  /// Button: the table is ready again
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get markClean;

  /// Button: hold a free table
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get reserve;

  /// Hint for the reservation note
  ///
  /// In en, this message translates to:
  /// **'e.g. 8 pm, 4 people'**
  String get reserveNoteHint;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Cancel reservation'**
  String get cancelReservation;

  /// Button: end a visit with no orders
  ///
  /// In en, this message translates to:
  /// **'Guests left (free table)'**
  String get guestsLeft;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Change guests'**
  String get changeGuests;

  /// Report: covers
  ///
  /// In en, this message translates to:
  /// **'{covers, plural, =0{No guests recorded} =1{1 guest} other{{covers} guests}}'**
  String coversLine(int covers);

  /// Report: average spend per cover
  ///
  /// In en, this message translates to:
  /// **'Average per guest: {amount}'**
  String avgPerGuest(String amount);

  /// Error
  ///
  /// In en, this message translates to:
  /// **'Guests are at this table'**
  String get errTableInUse;

  /// Button: the guests changed tables
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get moveTable;

  /// Button: one party across several tables
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get mergeTables;

  /// Move picker title
  ///
  /// In en, this message translates to:
  /// **'Move to which table?'**
  String get moveTo;

  /// Merge picker title
  ///
  /// In en, this message translates to:
  /// **'Which tables join this one?'**
  String get mergeWhich;

  /// Empty move picker
  ///
  /// In en, this message translates to:
  /// **'No free table right now'**
  String get noFreeTables;

  /// Empty merge picker
  ///
  /// In en, this message translates to:
  /// **'No other table has guests'**
  String get noOtherBusy;

  /// Toast after a move
  ///
  /// In en, this message translates to:
  /// **'Moved to table {label}'**
  String movedTo(String label);

  /// Toast after a merge
  ///
  /// In en, this message translates to:
  /// **'Merged into table {label}'**
  String mergedInto(String label);

  /// Error
  ///
  /// In en, this message translates to:
  /// **'This table already has a bill. Settle or cancel it first.'**
  String get errTableHasBill;

  /// Floor button and screen title
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// Tab: walk-ins waiting
  ///
  /// In en, this message translates to:
  /// **'Waitlist'**
  String get waitlist;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'New booking'**
  String get newBooking;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Add to waitlist'**
  String get addToWaitlist;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Table (optional)'**
  String get tableOptional;

  /// No table chosen
  ///
  /// In en, this message translates to:
  /// **'Any table'**
  String get anyTable;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Wait told to the guest (minutes)'**
  String get quotedWait;

  /// Hint next to the quote
  ///
  /// In en, this message translates to:
  /// **'Today\'s real average wait: {minutes} min'**
  String avgWaitToday(int minutes);

  /// Waitlist row
  ///
  /// In en, this message translates to:
  /// **'Waiting {waited} min (told {quoted})'**
  String waitedOfQuoted(int waited, int quoted);

  /// Waitlist row without a quote
  ///
  /// In en, this message translates to:
  /// **'Waiting {waited} min'**
  String waitedMin(int waited);

  /// Button: seat this party
  ///
  /// In en, this message translates to:
  /// **'Seat'**
  String get seat;

  /// Button / status
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get noShow;

  /// Button: cancel a booking
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelBooking;

  /// Warning on a booking
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 no-show before} other{{count} no-shows before}}'**
  String noShowsBefore(int count);

  /// Empty
  ///
  /// In en, this message translates to:
  /// **'No bookings for this day'**
  String get noBookingsDay;

  /// Empty
  ///
  /// In en, this message translates to:
  /// **'Nobody is waiting'**
  String get nobodyWaiting;

  /// Badge on a table
  ///
  /// In en, this message translates to:
  /// **'Booked {time} · {name}'**
  String bookedAt(String time, String name);

  /// Seat dialog title
  ///
  /// In en, this message translates to:
  /// **'Pick a table'**
  String get pickTable;

  /// Booking status
  ///
  /// In en, this message translates to:
  /// **'Seated'**
  String get bookingStatusSeated;

  /// Booking status
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bookingStatusCancelled;

  /// Overlap warning
  ///
  /// In en, this message translates to:
  /// **'{name} has this table at {time}. Book anyway?'**
  String tableBookedWarn(String name, String time);

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Book anyway'**
  String get bookAnyway;

  /// Error
  ///
  /// In en, this message translates to:
  /// **'That time has passed'**
  String get errPastTime;

  /// Menu button: kitchen stations
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get stations;

  /// Explains stations
  ///
  /// In en, this message translates to:
  /// **'Sections of the kitchen that get their own ticket and screen, e.g. Bar, Tandoor. Dishes without a station go to the main Kitchen.'**
  String get stationsHelp;

  /// Hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Bar'**
  String get newStationHint;

  /// The main kitchen (dishes without a station)
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get mainKitchen;

  /// Field / menu option
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get station;

  /// Dish station: follow its category
  ///
  /// In en, this message translates to:
  /// **'Same as category'**
  String get followCategory;

  /// Kitchen screen filter
  ///
  /// In en, this message translates to:
  /// **'All stations'**
  String get allStations;

  /// Where a dish's ticket goes
  ///
  /// In en, this message translates to:
  /// **'Goes to: {station}'**
  String goesTo(String station);

  /// Error
  ///
  /// In en, this message translates to:
  /// **'A station with this name already exists'**
  String get errStationExists;

  /// Overview: today's revenue so far against the same weekday last week up to the same time. weekday is a day name, e.g. Tuesday
  ///
  /// In en, this message translates to:
  /// **'Compared with last {weekday} at this time'**
  String vsLastWeek(String weekday);

  /// Overview: revenue is higher than the same time last week. amount is money, pct a number like 12.5
  ///
  /// In en, this message translates to:
  /// **'Up {amount} ({pct}%)'**
  String upBy(String amount, String pct);

  /// Overview: revenue is lower than the same time last week. amount is money, pct a number like 12.5
  ///
  /// In en, this message translates to:
  /// **'Down {amount} ({pct}%)'**
  String downBy(String amount, String pct);

  /// Overview: revenue equals the same time last week
  ///
  /// In en, this message translates to:
  /// **'Same as last week'**
  String get sameAsLastWeek;

  /// Overview: there were no sales at this time last week, so no comparison is shown
  ///
  /// In en, this message translates to:
  /// **'No sales to compare'**
  String get noSalesToCompare;

  /// Overview: heading over today's payments by cash / UPI / card
  ///
  /// In en, this message translates to:
  /// **'Money received today'**
  String get receivedToday;

  /// Overview: a payment method's share of money received today, e.g. 40%
  ///
  /// In en, this message translates to:
  /// **'{pct}%'**
  String sharePct(String pct);

  /// Reports, Items: heading over sales grouped by menu category (Starters, Mains...)
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get repByCategory;

  /// Reports: one menu category's line. dishes and qty are counts, pct a number like 42.5
  ///
  /// In en, this message translates to:
  /// **'{dishes, plural, =1{1 dish} other{{dishes} dishes}} · {qty} sold · {pct}% of sales'**
  String repCategoryLine(int dishes, String qty, String pct);

  /// Reports: category for bills issued before categories were kept on bills
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get repNotRecorded;

  /// Reports: explains that categories are as they were when billed
  ///
  /// In en, this message translates to:
  /// **'Each dish counts under the category it had when it was billed; moving it later does not change past reports.'**
  String get basisCategories;

  /// Reports: button to download sales by category as a CSV file
  ///
  /// In en, this message translates to:
  /// **'Categories (CSV)'**
  String get categoriesCsv;

  /// Order composer: button that saves the cart without sending it to the kitchen, to finish later
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get holdOrder;

  /// Toast after holding a cart
  ///
  /// In en, this message translates to:
  /// **'Order held. Resume it from the table or Takeaway.'**
  String get orderHeld;

  /// Order composer: heading over carts put on hold
  ///
  /// In en, this message translates to:
  /// **'Held orders'**
  String get heldOrders;

  /// Held order chip; time is a clock time like 7:42 PM
  ///
  /// In en, this message translates to:
  /// **'Held {time}'**
  String heldAt(String time);

  /// Held order chip: a dish was removed or sold out since it was held
  ///
  /// In en, this message translates to:
  /// **'needs changes'**
  String get heldNeedsChanges;

  /// Tooltip on a held order chip
  ///
  /// In en, this message translates to:
  /// **'Resume this order'**
  String get resumeHeld;

  /// Tooltip on the cross of a held order chip
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardHeld;

  /// Dialog title before discarding a held cart
  ///
  /// In en, this message translates to:
  /// **'Discard this held order?'**
  String get discardHeldTitle;

  /// Dialog body before discarding a held cart
  ///
  /// In en, this message translates to:
  /// **'Nothing was sent to the kitchen. The guest\'s order will be lost.'**
  String get discardHeldBody;

  /// Toast when resuming a held order whose dishes were removed; names is a comma list
  ///
  /// In en, this message translates to:
  /// **'No longer on the menu: {names}'**
  String heldMissing(String names);

  /// Error when two devices resume the same held order
  ///
  /// In en, this message translates to:
  /// **'This held order was already sent or discarded on another device'**
  String get errHoldGone;

  /// Floor: number of held orders on a table or for takeaway, e.g. 2 held
  ///
  /// In en, this message translates to:
  /// **'{count} held'**
  String heldCount(String count);

  /// Close the day: carts put on hold and never sent (a guest may still be waiting)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 held order was never sent to the kitchen} other{{count} held orders were never sent to the kitchen}}'**
  String heldOrdersWaiting(int count);

  /// Kitchen card: minutes left before the order should be ready
  ///
  /// In en, this message translates to:
  /// **'Due in {minutes} min'**
  String dueIn(int minutes);

  /// Kitchen card: the order should be ready about now
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get readyDueNow;

  /// Kitchen card: minutes past the time the order should have been ready
  ///
  /// In en, this message translates to:
  /// **'Delayed {minutes} min'**
  String delayedBy(int minutes);

  /// Overview: share of today's orders made ready by the due time set when they were placed
  ///
  /// In en, this message translates to:
  /// **'On time today: {pct}% ({onTime} of {ready} orders ready by their due time)'**
  String onTimeToday(String pct, int onTime, int ready);

  /// Bill window: button and dialog title to put a company's GSTIN on the tax invoice (B2B)
  ///
  /// In en, this message translates to:
  /// **'Company GST bill'**
  String get companyBill;

  /// Company GST bill: the buyer's registered name
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get buyerName;

  /// Company GST bill: the buyer's 15-character GSTIN
  ///
  /// In en, this message translates to:
  /// **'Company GSTIN'**
  String get buyerGstin;

  /// Company GST bill: the buyer's address
  ///
  /// In en, this message translates to:
  /// **'Company address (optional)'**
  String get buyerAddress;

  /// Company GST bill dialog help
  ///
  /// In en, this message translates to:
  /// **'The bill is re-issued with the company\'s details (the old number stays in the register as cancelled). The GSTIN must be valid and from this state.'**
  String get companyBillHelp;

  /// Bill window: the company the tax invoice is issued to
  ///
  /// In en, this message translates to:
  /// **'Bill to: {name}'**
  String billTo(String name);

  /// Error: the buyer's GSTIN failed the format or check digit
  ///
  /// In en, this message translates to:
  /// **'That GSTIN is not valid. Check it with the guest.'**
  String get errBadGstin;

  /// Error: inter-state B2B is not supported yet
  ///
  /// In en, this message translates to:
  /// **'This GSTIN is from another state. Bills for other-state companies need IGST, which is not supported yet.'**
  String get errInterstateB2b;

  /// Error: B2B bills need a GST-registered hotel
  ///
  /// In en, this message translates to:
  /// **'Only a GST-registered hotel can issue a company (B2B) bill.'**
  String get errNotTaxInvoice;

  /// Error: splitting a B2B bill by items
  ///
  /// In en, this message translates to:
  /// **'This is a company bill; it cannot be split by items.'**
  String get errBillHasBuyer;

  /// GST report: heading over bills issued to a company's GSTIN, one per line (GSTR-1 B2B)
  ///
  /// In en, this message translates to:
  /// **'Company (B2B) bills'**
  String get gstB2b;
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
      <String>['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
