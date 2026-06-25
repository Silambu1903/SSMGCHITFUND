enum AppLanguage { english, tamil }

class AppStrings {
  static AppLanguage currentLanguage = AppLanguage.tamil;

  static bool get isTamil => currentLanguage == AppLanguage.tamil;

  /// Brand prefix for chit names, codes, and labels (SSMG — not SSGM).
  static const brandPrefix = 'SSMG';
  static const brandFullName = 'SSMG Chit Fund';
  static const adminLoginEmail = 'admin@ssmg.com';
  static const adminLoginPhone = '9442410630';

  static String get appName => isTamil ? '$brandPrefix சீட்டு நிதி' : brandFullName;
  static String get appTagline =>
      isTamil ? 'நம்பகமான சீட்டு மேலாண்மை' : 'Trusted Chit Management';

  // Navigation
  static String get dashboard => isTamil ? 'டாஷ்போர்டு' : 'Dashboard';
  static String get chitFunds => isTamil ? 'சீட்டுகள்' : 'Chit Funds';
  static String get customers => isTamil ? 'உறுப்பினர்கள்' : 'Customers';
  static String get payments => isTamil ? 'கட்டணங்கள்' : 'Payments';
  static String get reports => isTamil ? 'அறிக்கைகள்' : 'Reports';
  static String get auctions => isTamil ? 'ஏலங்கள்' : 'Auctions';
  static String get settlements => isTamil ? 'தீர்வுகள்' : 'Settlements';
  static String get settings => isTamil ? 'அமைப்புகள்' : 'Settings';
  static String get logout => isTamil ? 'வெளியேறு' : 'Logout';
  static String get helpCenter => isTamil ? 'உதவி மையம்' : 'Help Center';

  // Auth
  static String get login => isTamil ? 'உள்நுழைவு' : 'Login';
  static String get email => isTamil ? 'மின்னஞ்சல்' : 'Email';
  static String get emailOrMobile =>
      isTamil ? 'மின்னஞ்சல் / கைபேசி' : 'Email / Mobile';
  static String get enterEmailOrMobile => isTamil
      ? 'மின்னஞ்சல் அல்லது கைபேசி எண் உள்ளிடவும்'
      : 'Enter email or mobile number';
  static String get invalidEmailOrMobile => isTamil
      ? 'சரியான மின்னஞ்சல் அல்லது 10 இலக்க கைபேசி எண் உள்ளிடவும்'
      : 'Enter a valid email or 10-digit mobile number';
  static String get loginHint => isTamil
      ? '$adminLoginEmail அல்லது $adminLoginPhone'
      : '$adminLoginEmail or $adminLoginPhone';
  static String get loginSubtitle =>
      isTamil ? 'உங்கள் கணக்கில் உள்நுழைக' : 'Sign in to your account';
  static String get password => isTamil ? 'கடவுச்சொல்' : 'Password';
  static String get forgotPassword =>
      isTamil ? 'கடவுச்சொல் மறந்தீர்களா?' : 'Forgot Password?';
  static String get loginButton => isTamil ? 'உள்நுழைக' : 'Sign In';
  static String get loginBrandName => isTamil
      ? 'ஸ்ரீ செல்வ மகா கணபதி\nசீட்டு நிதி'
      : 'Sri Selva Maha Ganapathi\nChit Fund';
  static String get loginWelcomeTitle =>
      isTamil ? 'மீண்டும் வரவேற்பு' : 'Welcome Back';
  static String get loginWelcomeSubtitle => isTamil
      ? 'உங்கள் பிரீமியம் சீட்டு நிதி டாஷ்போர்டை அணுகவும்.'
      : 'Access your premium chit fund dashboard.';
  static String get loginPhoneLabel =>
      isTamil ? 'மின்னஞ்சல் / கைபேசி எண்' : 'Email / Mobile Number';
  static String get loginPhoneHint => isTamil
      ? '$adminLoginEmail / $adminLoginPhone'
      : '$adminLoginEmail / $adminLoginPhone';
  static String get enterPhone => isTamil
      ? 'கைபேசி எண் உள்ளிடவும்'
      : 'Enter mobile number';
  static String get invalidPhone => isTamil
      ? '10 இலக்க கைபேசி எண் உள்ளிடவும்'
      : 'Enter a valid 10-digit mobile number';
  static String get rememberMe =>
      isTamil ? 'என்னை நினைவில் கொள்க' : 'Remember me';
  static String get loginSignIn => isTamil ? 'உள்நுழை' : 'Sign In';
  static String get loginFeatureSafe => isTamil
      ? 'பாதுகாப்பானது மற்றும் நம்பகமானது'
      : 'Safe and Reliable';
  static String get loginFeatureGrowth =>
      isTamil ? 'உறுதியான வளர்ச்சி' : 'Steady Growth';
  static String get loginFeatureSavings =>
      isTamil ? 'எளிதான சேமிப்பு' : 'Easy Savings';
  static String get loginFeatureSupport => isTamil
      ? '24/7 முன்னுரிமை ஆதரவு'
      : '24/7 Priority Support';
  static String get privacyPolicy =>
      isTamil ? 'தனியுரிமைக் கொள்கை' : 'Privacy Policy';
  static String get terms => isTamil ? 'விதிமுறைகள்' : 'Terms';
  static String get security => isTamil ? 'பாதுகாப்பு' : 'Security';
  static String get help => isTamil ? 'உதவி' : 'Help';
  static String get loginCopyright => isTamil
      ? '© 2024 ஸ்ரீ செல்வ மகா கணபதி சீட்டு நிதி'
      : '© 2024 Sri Selva Maha Ganapathi Chit Fund';

  // Dashboard
  static String get totalMembers =>
      isTamil ? 'மொத்த உறுப்பினர்கள்' : 'Total Members';
  static String get activeChits =>
      isTamil ? 'செயலில் உள்ள சீட்டுகள்' : 'Active Chits';
  static String get monthlyCollection =>
      isTamil ? 'மாதாந்திர வசூல்' : 'Monthly Collection';
  static String get pendingAmount =>
      isTamil ? 'நிலுவை தொகை' : 'Pending Amount';
  static String get completedChits =>
      isTamil ? 'முடிவடைந்த சீட்டுகள்' : 'Completed Chits';
  static String get upcomingAuctions =>
      isTamil ? 'வரவிருக்கும் ஏலங்கள்' : 'Upcoming Auctions';
  static String get defaulters => isTamil ? 'நிலுவைகாரர்கள்' : 'Defaulters';

  // Members
  static String get newMember =>
      isTamil ? 'புதிய உறுப்பினர்' : 'New Member';
  static String get memberNo =>
      isTamil ? 'உறுப்பினர் எண்' : 'Member No';
  static String get memberName =>
      isTamil ? 'உறுப்பினர் பெயர்' : 'Member Name';
  static String get fatherName =>
      isTamil ? 'தந்தையின் பெயர்' : 'Father Name';
  static String get mobile => isTamil ? 'கைபேசி' : 'Mobile';
  static String get address => isTamil ? 'முகவரி' : 'Address';
  static String get aadhaar => isTamil ? 'ஆதார்' : 'Aadhaar';
  static String get pan => isTamil ? 'பான்' : 'PAN';
  static String get occupation => isTamil ? 'தொழில்' : 'Occupation';
  static String get income => isTamil ? 'வருமானம்' : 'Income';
  static String get joiningDate =>
      isTamil ? 'சேர்ந்த தேதி' : 'Joining Date';
  static String get photo => isTamil ? 'புகைப்படம்' : 'Photo';
  static String get signature => isTamil ? 'கையொப்பம்' : 'Signature';
  static String get guarantor => isTamil ? 'ஜமீந்தார்' : 'Guarantor';
  static String get addGuarantor =>
      isTamil ? 'ஜமீந்தார் சேர்க்கவும்' : 'Add Guarantor';
  static String get relationship =>
      isTamil ? 'உறவுமுறை' : 'Relationship';

  // Chits
  static String get createNewChit =>
      isTamil ? 'புதிய சீட்டு உருவாக்கம்' : 'Create New Chit';
  static String get chitAmount =>
      isTamil ? 'சீட்டு தொகை' : 'Chit Amount';
  static String get totalMembersLabel =>
      isTamil ? 'மொத்த உறுப்பினர்கள்' : 'Total Members';
  static String get startDate =>
      isTamil ? 'தொடங்கும் தேதி' : 'Start Date';
  static String get duration =>
      isTamil ? 'காலம் (மாதங்கள்)' : 'Duration (Months)';
  static String get biddingDate =>
      isTamil ? 'ஏல தேதி' : 'Bidding Date';
  static String get commissionPercent =>
      isTamil ? 'கமிஷன் சதவீதம்' : 'Commission %';
  static String get chitValue =>
      isTamil ? 'சீட்டு மொத்த தொகை' : 'Chit Value';
  static String get baseInstallment =>
      isTamil ? 'மாத தவணை' : 'Base Installment';
  static String get liveSummary =>
      isTamil ? 'நேரலை முன்னோட்டம்' : 'Live Summary';
  static String get createChit =>
      isTamil ? 'சீட்டு உருவாக்கவும்' : 'Create Chit';
  static String get cancel => isTamil ? 'ரத்து செய்' : 'Cancel';
  static String get basicDetails =>
      isTamil ? 'அடிப்படை விவரங்கள்' : 'Basic Details';
  static String get financialRules =>
      isTamil ? 'நிதி விதிகள்' : 'Financial Rules';
  static String get chitName => isTamil ? 'சீட்டு பெயர்' : 'Chit Name';
  static String get chitCode => isTamil ? 'சீட்டு குறியீடு' : 'Chit Code';

  // Auction
  static String get auctionCalculation =>
      isTamil ? 'ஏல கணக்கீடு' : 'Auction Calculation';
  static String get chitTotal =>
      isTamil ? 'சீட்டு மொத்த தொகை' : 'Chit Total Amount';
  static String get discountAmount =>
      isTamil ? 'தள்ளு தொகை' : 'Discount Amount';
  static String get prizeAmount =>
      isTamil ? 'மீதி தொகை' : 'Prize Amount';
  static String get commissionAmount =>
      isTamil ? 'கமிஷன் தொகை' : 'Commission Amount';
  static String get dividendPool =>
      isTamil ? 'இந்த மாத இருப்பு தொகை' : 'Dividend Pool';
  static String get dividendPerMember =>
      isTamil ? 'உறுப்பினரின் லாபத் தொகை' : 'Dividend Per Member';
  static String get nextMonthPayable =>
      isTamil ? 'அடுத்த மாதம் செலுத்த வேண்டிய தவணை தொகை' : 'Next Month Payable';
  static String get winnerName =>
      isTamil ? 'உறுப்பினர் பெயர்' : 'Winner Name';
  static String get guarantorName =>
      isTamil ? 'ஜமீந்தார் பெயர்' : 'Guarantor Name';

  // Payments
  static String get recordPayment =>
      isTamil ? 'கட்டணம் பதிவு செய்க' : 'Record Payment';
  static String get dueAmount =>
      isTamil ? 'செலுத்த வேண்டிய தொகை' : 'Due Amount';
  static String get paidAmount =>
      isTamil ? 'செலுத்திய தொகை' : 'Paid Amount';
  static String get balanceAmount =>
      isTamil ? 'நிலுவை தொகை' : 'Balance Amount';
  static String get penaltyAmount =>
      isTamil ? 'அபராதம்' : 'Penalty Amount';
  static String get paymentMode =>
      isTamil ? 'கட்டண முறை' : 'Payment Mode';
  static String get receiptNumber =>
      isTamil ? 'ரசீது எண்' : 'Receipt Number';
  static String get paymentDate =>
      isTamil ? 'கட்டண தேதி' : 'Payment Date';
  static String get paid => isTamil ? 'செலுத்தியது' : 'Paid';
  static String get pending => isTamil ? 'நிலுவை' : 'Pending';
  static String get partial => isTamil ? 'பகுதி' : 'Partial';
  static String get overdue => isTamil ? 'தாமதம்' : 'Overdue';

  // Settlement
  static String get settlement =>
      isTamil ? 'இறுதி தீர்வு' : 'Settlement';
  static String get totalPaid =>
      isTamil ? 'மொத்த செலுத்திய தொகை' : 'Total Paid';
  static String get prizeReceived =>
      isTamil ? 'பெற்ற ஏலத் தொகை' : 'Prize Received';
  static String get dividendReceived =>
      isTamil ? 'லாபத் தொகை' : 'Dividend Received';
  static String get settlementAmount =>
      isTamil ? 'இறுதி தீர்வு தொகை' : 'Settlement Amount';

  // Reports
  static String get dailyCollection =>
      isTamil ? 'தினசரி வசூல்' : 'Daily Collection';
  static String get monthlyReport =>
      isTamil ? 'மாதாந்திர அறிக்கை' : 'Monthly Report';
  static String get memberReport =>
      isTamil ? 'உறுப்பினர் அறிக்கை' : 'Member Report';
  static String get auctionReport =>
      isTamil ? 'ஏல அறிக்கை' : 'Auction Report';
  static String get outstandingReport =>
      isTamil ? 'நிலுவை அறிக்கை' : 'Outstanding Report';
  static String get incomeReport =>
      isTamil ? 'வருமான அறிக்கை' : 'Income Report';

  // Common
  static String get save => isTamil ? 'சேமி' : 'Save';
  static String get edit => isTamil ? 'திருத்து' : 'Edit';
  static String get delete => isTamil ? 'நீக்கு' : 'Delete';
  static String get search =>
      isTamil ? 'தேடுக...' : 'Search members...';
  static String get active => isTamil ? 'செயலில்' : 'Active';
  static String get inactive => isTamil ? 'செயலற்ற' : 'Inactive';
  static String get loading => isTamil ? 'ஏற்றுகிறது...' : 'Loading...';
  static String get error => isTamil ? 'பிழை' : 'Error';
  static String get retry => isTamil ? 'மீண்டும் முயற்சி' : 'Retry';
  static String get noData =>
      isTamil ? 'தரவு இல்லை' : 'No data available';
  static String get month => isTamil ? 'மாதம்' : 'Month';
  static String get commissionFee =>
      isTamil ? 'கமிஷன் கட்டணம்' : 'Commission Fee';
  static String get subjectToDividends =>
      isTamil ? '* ஏலத்திற்கு பிறகு மாறும்' : '* Subject to dividends after bidding';
  static String get trustFactorInsight =>
      isTamil ? 'நம்பிக்கை காரணி' : 'Trust Factor Insight';
  static String get manageWithEase =>
      isTamil ? 'எளிதாக நிர்வகிக்கவும்' : 'Manage with Ease';
  static String get perMonth => isTamil ? '/மாதம்' : '/month';
  static String get enterprise =>
      isTamil ? 'நிறுவன பதிப்பு' : 'Enterprise Edition';
  static String get branchAdmin =>
      isTamil ? 'கிளை நிர்வாகி' : 'Branch Admin';

  // Chit detail
  static String get totalAmount =>
      isTamil ? 'மொத்த தொகை' : 'Total Amount';
  static String get installment =>
      isTamil ? 'மாத தவணை' : 'Installment';
  static String get bidSchedule =>
      isTamil ? 'ஏல அட்டவணை' : 'Bid Schedule';
  static String get everyMonth =>
      isTamil ? 'ஒவ்வொரு மாதமும்' : 'Every Month';
  static String get commission =>
      isTamil ? 'கமிஷன்' : 'Commission';
  static String get membersLabel =>
      isTamil ? 'உறுப்பினர்கள்' : 'Members';
  static String get durationLabel =>
      isTamil ? 'கால அளவு' : 'Duration';
  static String get monthsShort => isTamil ? 'மாதம்' : 'mo';

  // Auctions (chit detail)
  static String get newAuction =>
      isTamil ? 'புதிய ஏலம் பதிவு' : 'New Auction';
  static String get recentAuctions =>
      isTamil ? 'ஏல விவரங்கள்' : 'Recent Auctions';
  static String get recentAuctionsSubtitle => isTamil
      ? 'இந்த சீட்டின் ஏல முடிவுகள்'
      : 'Latest auction results for this chit';
  static String get viewAll => isTamil ? 'அனைத்தும் பார்' : 'View All';
  static String get noAuctionsYet =>
      isTamil ? 'இன்னும் ஏலம் பதிவு செய்யப்படவில்லை' : 'No auctions yet';
  static String get noWinnerYet =>
      isTamil ? 'வெற்றியாளர் இன்னும் இல்லை' : 'No winner yet';
  static String get prize => isTamil ? 'பரிசு தொகை' : 'Prize';
  static String get prizePaid => isTamil ? 'செலுத்தப்பட்டது' : 'Paid';
  static String get discountLabel =>
      isTamil ? 'தள்ளு' : 'Discount';

  // Assign members
  static String get assignMembersTitle => isTamil
      ? 'சீட்டில் உறுப்பினர் நியமிப்பு'
      : 'Assign Members to Chit';
  static String assignedCount(int n, int max) => isTamil
      ? '$n / $max நியமிக்கப்பட்டது'
      : '$n of $max assigned';
  static String get full => isTamil ? 'நிரம்பியது' : 'Full';
  static String get assignMember =>
      isTamil ? 'உறுப்பினர் நியமிக்க' : 'Assign Member';
  static String get searchMemberHint => isTamil
      ? 'பெயர், கைபேசி அல்லது உறுப்பினர் எண் தேடுக...'
      : 'Search by name, mobile or member ID';
  static String get typeToSearch =>
      isTamil ? 'தேட தட்டச்சு செய்க...' : 'Type to search…';
  static String get noMembersAssigned => isTamil
      ? 'இன்னும் உறுப்பினர் நியமிக்கப்படவில்லை'
      : 'No members assigned yet';
  static String get assignMembersEmptyHint => isTamil
      ? 'மேலே தேடி சேர் அல்லது புதிய உறுப்பினர் சேர்க்கவும்'
      : 'Search above and click Add, or Add New Member';
  static String get addNewMember =>
      isTamil ? 'புதிய உறுப்பினர் சேர்' : 'Add New Member';
  static String get ticketNo =>
      isTamil ? 'சீட்டு எண்' : 'Ticket #';
  static String get actions => isTamil ? 'செயல்கள்' : 'Actions';
  static String get member => isTamil ? 'உறுப்பினர்' : 'Member';
  static String get unassigned =>
      isTamil ? 'நியமிக்கப்படவில்லை' : 'Unassigned';
  static String get add => isTamil ? 'சேர்' : 'Add';
  static String get allSlotsFilled => isTamil
      ? 'அனைத்து இடங்களும் நிரம்பியுள்ளன'
      : 'All member slots are filled';
  static String get assignedMembersTitle => isTamil
      ? 'நியமிக்கப்பட்ட உறுப்பினர்'
      : 'Assigned Members';
  static String get ticketEditable => isTamil
      ? 'சீட்டு எண் திருத்த 가능'
      : 'Ticket # editable';

  // Payment schedule
  static String get paymentScheduleTitle => isTamil
      ? 'கட்டண அட்டவணை'
      : 'Member Payment Schedule';
  static String paymentScheduleSubtitle(int members, int months) => isTamil
      ? '$members உறுப்பினர் × $months மாதம் — ஏலத்திற்குப் பிறகு செலுத்த வேண்டிய தொகை'
      : '$members members × $months months — amount due after each auction';
  static String membersBadge(int n, int max) =>
      isTamil ? 'உறுப்பினர்: $n/$max' : 'Members: $n/$max';
  static String auctionsHeldBadge(int held, int total) => isTamil
      ? 'நடந்த ஏலங்கள்: $held / $total'
      : 'Auctions held: $held / $total';
  static String get exportPdf =>
      isTamil ? 'PDF ஏற்றுமதி' : 'Export to PDF';
  static String get exportExcel =>
      isTamil ? 'Excel ஏற்றுமதி' : 'Export to Excel';
  static String get assignMembersForGrid => isTamil
      ? 'கட்டண அட்டவணைக்கு உறுப்பினரை நியமிக்கவும்'
      : 'Assign members to see the payment grid';
  static String get paidLegend => isTamil ? 'செலுத்தியது' : 'Paid';
  static String get notPaidLegend =>
      isTamil ? 'செலுத்தவில்லை' : 'Not Paid';
  static String get partialLegend => isTamil ? 'பகுதி' : 'Partial';
  static String get noAuctionLegend =>
      isTamil ? 'ஏலம் இன்னும் இல்லை' : 'No auction yet';
  static String monthLabel(int m) =>
      isTamil ? 'மா$m' : 'M$m';

  // Common actions
  static String get back => isTamil ? 'பின்' : 'Back';
  static String get update => isTamil ? 'புதுப்பி' : 'Update';
  static String get confirm => isTamil ? 'உறுதி' : 'Confirm';
  static String get chits => isTamil ? 'சீட்டுகள்' : 'Chits';
  static String get members => isTamil ? 'உறுப்பினர்கள்' : 'Members';

  // ── Dashboard ──────────────────────────────────────────────────────────────
  static String get thisMonth => isTamil ? 'இந்த மாதம்' : 'This month';
  static String monthlyOverview(String monthYear) => isTamil
      ? 'மாதாந்திர சுருக்கம் — $monthYear'
      : 'Monthly Overview — $monthYear';
  static String get settlementSplitSubtitle => isTamil
      ? 'ஏல நாளின் அடிப்படையில் தீர்வு மற்றும் கமிஷன்'
      : 'Settlement & commission split by auction day';
  static String everyNth(int day) =>
      isTamil ? 'ஒவ்வொரு மாதமும் ${day}ம்' : 'Every ${day}th';
  static String get auctionGroup =>
      isTamil ? 'ஏல குழு' : 'Auction Group';
  static String activeChitsCount(int n) =>
      isTamil ? '$n சீட்டுகள்' : '$n Chits';
  static String get totalSettlement =>
      isTamil ? 'மொத்த தீர்வு தொகை' : 'Total Settlement';
  static String winnersThisMonth(int n) => isTamil
      ? 'இந்த மாதம் $n வெற்றியாளர்${n > 1 ? 'கள்' : ''}'
      : '$n winner${n > 1 ? 's' : ''} this month';
  static String get noWinnerRecordedYet => isTamil
      ? 'இன்னும் வெற்றியாளர் பதிவு இல்லை'
      : 'No winner recorded yet';
  static String paidRemaining(String paid, String remaining) => isTamil
      ? '$paid செலுத்தப்பட்டது • $remaining நிலுவை'
      : '$paid paid • $remaining remaining';
  static String get yourCommission =>
      isTamil ? 'உங்கள் கமிஷன்' : 'Your Commission';
  static String get foremanEarningsSubtitle => isTamil
      ? 'இந்த மாதத்தின் நிறுவன வருமானம்'
      : 'Foreman earnings this month';
  static String get auctionPending =>
      isTamil ? 'ஏலம் நிலுவையில்' : 'Auction pending';
  static String prizeSettlement(String monthYear) => isTamil
      ? 'பரிசு தீர்வு — $monthYear'
      : 'Prize Settlement — $monthYear';
  static String amountPending(String amt) =>
      isTamil ? '$amt நிலுவை' : '$amt pending';
  static String amountPaidBadge(String amt) =>
      isTamil ? '$amt செலுத்தப்பட்டது' : '$amt paid';
  static String auctionWinnersCount(int n) => isTamil
      ? 'இந்த மாதம் $n ஏல வெற்றியாளர்${n > 1 ? 'கள்' : ''}'
      : '$n auction winner${n > 1 ? 's' : ''} this month';
  static String get winnerCol => isTamil ? 'வெற்றியாளர்' : 'WINNER';
  static String get chitSchemeCol => isTamil ? 'சீட்டு திட்டம்' : 'CHIT SCHEME';
  static String get dayCol => isTamil ? 'நாள்' : 'DAY';
  static String get prizeAmountCol => isTamil ? 'பரிசு தொகை' : 'PRIZE AMOUNT';
  static String get markPaid => isTamil ? 'செலுத்தியது' : 'Mark Paid';
  static String get unknown => isTamil ? 'தெரியவில்லை' : 'Unknown';
  static String nthDay(int? day) =>
      isTamil ? '${day ?? '-'}ம்' : '${day ?? '-'}th';
  static String get recentPaymentsTitle =>
      isTamil ? 'சமீப கட்டணங்கள்' : 'Recent Payments';
  static String get recentPaymentsSubtitle => isTamil
      ? 'சமீபத்திய வசூல் நடவடிக்கை'
      : 'Latest collection activity';
  static String get noRecentPayments =>
      isTamil ? 'சமீப கட்டணங்கள் இல்லை' : 'No recent payments';
  static String get defaultersSubtitle => isTamil
      ? 'நிலுவை கட்டணம் உள்ள உறுப்பினர்கள்'
      : 'Members with overdue payments';
  static String get noDefaulters =>
      isTamil ? 'நிலுவைதாரர்கள் இல்லை!' : 'No defaulters!';
  static String monthsOverdue(int n) =>
      isTamil ? '$n மாதம் நிலுவை' : '$n months overdue';
  static String paymentMonthLine(int month, String chitName) => isTamil
      ? 'மாதம் $month • $chitName'
      : 'Month $month • $chitName';

  // ── List screens ─────────────────────────────────────────────────────────
  static String get manageChitsSubtitle => isTamil
      ? 'அனைத்து சீட்டு திட்டங்களை நிர்வகிக்கவும்'
      : 'Manage all chit schemes';
  static String get noChitsYet =>
      isTamil ? 'இன்னும் சீட்டுகள் இல்லை' : 'No chit funds yet';
  static String noChitsOnDay(int day) => isTamil
      ? '${day}ம் நாள் சீட்டுகள் இல்லை'
      : 'No chits on the ${day}th';
  static String get filterAll => isTamil ? 'அனைத்தும்' : 'All';
  static String filterNth(int day) => isTamil ? '${day}ம்' : '${day}th';
  static String get membersCountLabel => isTamil ? 'உறுப்பினர்கள்' : 'Members';
  static String get monthsScheme => isTamil ? 'மாத திட்டம்' : 'months scheme';
  static String get commissionLabel => isTamil ? 'கமிஷன்' : 'Commission';
  static String get newEntry => isTamil ? 'புதிய பதிவு' : 'New Entry';
  static String get noAuctionsFound =>
      isTamil ? 'ஏலங்கள் இல்லை' : 'No auctions found';
  static String noAuctionsOnDay(int day) => isTamil
      ? '${day}ம் நாள் ஏலங்கள் இல்லை'
      : 'No auctions for the ${day}th';
  static String get recordPaymentTitle =>
      isTamil ? 'கட்டணம் பதிவு' : 'Record Payment';
  static String get monthlyAuctionEntry =>
      isTamil ? 'மாதாந்திர ஏல பதிவு' : 'Monthly Auction Entry';
  static String get recordAuctionSubtitle => isTamil
      ? 'ஏல முடிவை பதிவு செய்யவும்'
      : 'Record auction result';
  static String get auctionDetailTitle =>
      isTamil ? 'ஏல விவரம்' : 'Auction Detail';
  static String get editMember => isTamil ? 'உறுப்பினர் திருத்தம்' : 'Edit Member';
  static String get personalInfo =>
      isTamil ? 'தனிப்பட்ட விவரங்கள்' : 'Personal Information';
  static String get financialDetails =>
      isTamil ? 'நிதி விவரங்கள்' : 'Financial Details';
  static String get incomeOccupation =>
      isTamil ? 'வருமானம் & தொழில்' : 'Income & Occupation';
  static String get required => isTamil ? 'தேவை' : 'Required';
  static String get enterEmail => isTamil ? 'மின்னஞ்சல் உள்ளிடவும்' : 'Enter email';
  static String get enterPassword =>
      isTamil ? 'கடவுச்சொல் உள்ளிடவும்' : 'Enter password';

  static String paymentStatus(String status) {
    switch (status) {
      case 'Paid':
        return paid;
      case 'Overdue':
        return overdue;
      case 'Partial':
        return partial;
      case 'Pending':
        return pending;
      default:
        return status;
    }
  }

  static String monthName(int m) {
    const en = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const ta = [
      '', 'ஜனவரி', 'பிப்ரவரி', 'மார்ச்', 'ஏப்ரல்', 'மே', 'ஜூன்',
      'ஜூலை', 'ஆகஸ்ட்', 'செப்டம்பர்', 'அக்டோபர்', 'நவம்பர்', 'டிசம்பர்',
    ];
    if (m < 1 || m > 12) return '';
    return isTamil ? ta[m] : en[m];
  }

  static String monthYear(DateTime d) => '${monthName(d.month)} ${d.year}';

  // ── Errors & snackbars ─────────────────────────────────────────────────────
  static String errorMessage(String e) =>
      isTamil ? 'பிழை: $e' : 'Error: $e';

  static String get memberUpdatedSuccess =>
      isTamil ? 'உறுப்பினர் வெற்றிகரமாக புதுப்பிக்கப்பட்டது' : 'Member updated successfully';
  static String get chitFullMemberNotAssigned => isTamil
      ? 'சீட் நிரம்பியது — உறுப்பினர் உருவாக்கப்பட்டது, நியமிக்கப்படவில்லை'
      : 'Chit is full — member created but not assigned';
  static String memberCreatedAssignFailed(String e) => isTamil
      ? 'உறுப்பினர் உருவாக்கப்பட்டது, நியமிப்பு தோல்வி: $e'
      : 'Member created but assign failed: $e';
  static String get chitUpdatedSuccess =>
      isTamil ? 'சீட் வெற்றிகரமாக புதுப்பிக்கப்பட்டது' : 'Chit updated successfully';
  static String chitCreated(String name) =>
      isTamil ? 'சீட் "$name" உருவாக்கப்பட்டது!' : 'Chit "$name" created!';
  static String chitCreatedWithMembers(String name, int count) => isTamil
      ? 'சீட் "$name" $count உறுப்பினர்(களுடன்) உருவாக்கப்பட்டது!'
      : 'Chit "$name" created with $count member(s)!';
  static String get updateChit =>
      isTamil ? 'சீட் புதுப்பி' : 'Update Chit';
  static String get autoGeneratedHint => isTamil
      ? 'தானாக உருவாக்கப்படும் — திருத்தலாம்'
      : 'Auto-generated — edit to customise';
  static String get resetAutoName =>
      isTamil ? 'தானியங்கி பெயருக்கு மீட்டமை' : 'Reset to auto-generated name';
  static String get autoCodeHint => isTamil
      ? 'ஏல அட்டவணை — ஏல நாளிலிருந்து தானாக'
      : 'Bid schedule — auto from auction day';
  static String get resetAutoCode =>
      isTamil ? 'தானியங்கி குறியீட்டுக்கு மீட்டமை' : 'Reset to auto-generated code';
  static String get chitCodeExampleHint =>
      isTamil ? 'எ.கா. SSMG-10th-Jun26-9:00AM' : 'e.g. SSMG-10th-Jul26';
  static String trustFactorMessage(int months, int members) => isTamil
      ? '$members உறுப்பினர்களுக்கு $months மாத காலம் பங்கேற்புக்கு சிறந்தது.'
      : 'A $months-month duration for $members members is considered optimal for high participant engagement.';
  static String get deleteChitTitle =>
      isTamil ? 'சீட்டை நீக்கு' : 'Delete Chit';
  static String get deleteChitMessage => isTamil
      ? 'இந்த சீட்டு திட்டம், அதன் ஏலங்கள் மற்றும் கட்டணங்கள் நிரந்தரமாக நீக்கப்படும்.'
      : 'This will permanently delete this chit scheme and all its auctions and payments.';
  static String get deleteAuctionTitle =>
      isTamil ? 'ஏலத்தை நீக்கு' : 'Delete Auction';
  static String get deleteAuctionMessage => isTamil
      ? 'இந்த ஏல பதிவு மற்றும் தொடர்புடைய ஏலங்கள் நிரந்தரமாக நீக்கப்படும்.'
      : 'This will permanently delete this auction entry and all related bids.';
  static String get chitNotFound =>
      isTamil ? 'சீட் கிடைக்கவில்லை' : 'Chit not found';
  static String get auctionNotFound =>
      isTamil ? 'ஏலம் கிடைக்கவில்லை' : 'Auction not found';
  static String get ticketNumberUpdated =>
      isTamil ? 'சீட்டு எண் புதுப்பிக்கப்பட்டது' : 'Ticket number updated';
  static String get memberRemovedFromChit =>
      isTamil ? 'உறுப்பினர் சீட்டிலிருந்து நீக்கப்பட்டது' : 'Member removed from chit';
  static String errorLoadingMembers(String e) => isTamil
      ? 'உறுப்பினர்களை ஏற்றுவதில் பிழை: $e'
      : 'Error loading members: $e';
  static String pdfExportFailed(String e) =>
      isTamil ? 'PDF ஏற்றுமதி தோல்வி: $e' : 'PDF export failed: $e';
  static String get markPrizeAsPaid =>
      isTamil ? 'பரிசு தொகை செலுத்தியது' : 'Mark Prize as Paid';
  static String get confirmPaidNote =>
      isTamil ? 'வெற்றியாளருக்கு பரிசு தொகை செலுத்தியதை உறுதி செய்க.' : 'Confirm you have paid the prize amount to the winner.';
  static String get noteOptional =>
      isTamil ? 'குறிப்பு (விரும்பினால்)' : 'Note (optional)';
  static String get noteHint =>
      isTamil ? 'எ.கா. வங்கி பரிமாற்றம் மூலம்' : 'e.g. Paid via bank transfer';
  static String get confirmPaid =>
      isTamil ? 'செலுத்தியது உறுதி' : 'Confirm Paid';
  static String get prizeMarkedPaid =>
      isTamil ? 'பரிசு செலுத்தியதாக குறிக்கப்பட்டது!' : 'Prize marked as paid!';
  static String monthAuction(int m) =>
      isTamil ? 'மாதம் $m ஏலம்' : 'Month $m Auction';
  static String get auctionBids =>
      isTamil ? 'ஏல போட்டிகள்' : 'Auction Bids';
  static String get noBidsRecorded =>
      isTamil ? 'ஏல போட்டிகள் பதிவு இல்லை' : 'No bids recorded';
  static String get exportAuctionReceipt =>
      isTamil ? 'ஏல ரசீது ஏற்றுமதி' : 'Export Auction Receipt';
  static String get auctionSavedExportPrompt => isTamil
      ? 'ஏலம் வெற்றிகரமாக சேமிக்கப்பட்டது.\n\nதமிழ் ஏல ரசீதை PDF ஆக ஏற்றுமதி செய்யவா?'
      : 'Auction saved successfully.\n\nExport the Tamil auction receipt as PDF now?';
  static String get later => isTamil ? 'பின்னர்' : 'Later';
  static String get selectChitScheme =>
      isTamil ? 'சீட்டு திட்டம் தேர்ந்தெடுக்கவும்' : 'Select chit scheme';
  static String get noMembersFound =>
      isTamil ? 'உறுப்பினர்கள் இல்லை' : 'No members found';
  static String get activeWinner =>
      isTamil ? 'தற்போதைய வெற்றியாளர்' : 'ACTIVE WINNER';
  static String get change => isTamil ? 'மாற்று' : 'Change';
  static String get live => isTamil ? 'நேரலை' : 'LIVE';
  static String get finalPrizeAmountLabel =>
      isTamil ? 'இறுதி பரிசுத் தொகை' : 'FINAL PRIZE AMOUNT';
  static String get discardEntry =>
      isTamil ? 'பதிவை நிராகரி' : 'Discard Entry';
  static String get editAuctionEntry =>
      isTamil ? 'ஏல பதிவு திருத்தம்' : 'Edit Auction Entry';
  static String get selectChitToBegin =>
      isTamil ? 'தொடங்க சீட்டை தேர்ந்தெடுக்கவும்' : 'Select a chit to begin';
  static String get auctionDetailsTitle =>
      isTamil ? 'ஏல விவரங்கள்' : 'Auction Details';
  static String get pleaseSelectChit =>
      isTamil ? 'சீட்டு திட்டம் தேர்ந்தெடுக்கவும்' : 'Please select a chit scheme';
  static String chitMonthsCompleted(int months) => isTamil
      ? 'அனைத்து $months மாதங்களும் பதிவு செய்யப்பட்டன. இந்த சீட் முடிந்தது.'
      : 'All $months months are already recorded. This chit is completed.';
  static String get enterValidDiscount =>
      isTamil ? 'சரியான தள்ளு தொகை உள்ளிடவும்' : 'Enter a valid discount amount';
  static String get enterValidDividend =>
      isTamil ? 'சரியான இருப்பு தொகை உள்ளிடவும்' : 'Enter a valid dividend pool amount';
  static String get selectWinnerMember =>
      isTamil ? 'வெற்றியாளர் உறுப்பினரை தேர்ந்தெடுக்கவும்' : 'Please select the winner member';
  static String get deleteAllMembersTitle =>
      isTamil ? 'அனைத்து உறுப்பினர்களையும் நீக்கு' : 'Delete All Members';
  static String get deleteAllMembersMessage => isTamil
      ? 'அனைத்து உறுப்பினர்கள், கட்டணங்கள், ரசீதுகள், சீட் பதிவுகள் மற்றும் ஏல போட்டிகள் நிரந்தரமாக நீக்கப்படும். இதை மீளமுடியாது.'
      : 'This will permanently delete ALL members and their payments, receipts, chit enrollments, and auction bids. This cannot be undone.';
  static String get allMembersDeleted =>
      isTamil ? 'அனைத்து உறுப்பினர்களும் நீக்கப்பட்டன' : 'All members deleted';
  static String get deleteAll =>
      isTamil ? 'அனைத்தையும் நீக்கு' : 'Delete All';
  static String get finalChitSettlementsSubtitle =>
      isTamil ? 'இறுதி சீட் தீர்வுகள்' : 'Final chit settlements';
  static String get noSettlementsYet =>
      isTamil ? 'இன்னும் தீர்வுகள் இல்லை' : 'No settlements yet';
  static String get outstanding =>
      isTamil ? 'நிலுவை' : 'Outstanding';
  static String get noPaymentsFound =>
      isTamil ? 'கட்டணங்கள் இல்லை' : 'No payments found';
  static String get reportsSubtitle => isTamil
      ? 'வணிக அறிக்கைகளை பதிவிறக்கம் செய்து பார்க்கவும்'
      : 'Download and view business reports';
  static String get dailyCollectionSubtitle =>
      isTamil ? 'தினசரி வசூல் அறிக்கை' : 'Daily collection report';
  static String get monthlyReportSubtitle =>
      isTamil ? 'மாதாந்திர வசூல் சுருக்கம்' : 'Monthly collection summary';
  static String get memberReportSubtitle =>
      isTamil ? 'அனைத்து உறுப்பினர் நடவடிக்கை' : 'All member activity';
  static String get auctionReportSubtitle =>
      isTamil ? 'ஏல வரலாறு மற்றும் முடிவுகள்' : 'Auction history and results';
  static String get outstandingReportSubtitle =>
      isTamil ? 'நிலுவை மற்றும் தாமத கட்டணங்கள்' : 'Pending and overdue dues';
  static String get incomeReportSubtitle =>
      isTamil ? 'கமிஷன் மற்றும் வருமானம்' : 'Commission and income';
  static String get chitAuctionFallback =>
      isTamil ? 'சீட் ஏலம்' : 'Chit Auction';
  static String get statusCompleted =>
      isTamil ? 'முடிந்தது' : 'Completed';
  static String get payWinner =>
      isTamil ? 'வெற்றியாளருக்கு செலுத்து' : 'Pay Winner';
  static String get prizePaidLabel =>
      isTamil ? 'பரிசு செலுத்தப்பட்டது' : 'Prize Paid';
  static String get prizePendingPayment =>
      isTamil ? 'பரிசு செலுத்தம் நிலுவை' : 'Prize Pending Payment';
  static String prizePaidOn(String date, {String? note}) {
    final base = isTamil ? '$date அன்று செலுத்தப்பட்டது' : 'Paid on $date';
    if (note != null && note.isNotEmpty) {
      return isTamil ? '$base • $note' : '$base • $note';
    }
    return base;
  }
  static String get assignToChit =>
      isTamil ? 'சீட்டில் நியமிக்க' : 'Assign to Chit';
  static String get remove => isTamil ? 'நீக்கு' : 'Remove';
  static String get documentsUploadHint => isTamil
      ? 'ஆதார், PAN, புகைப்படம், கையொப்பம் உறுப்பினர் பதிவுக்குப் பிறகு பதிவேற்றலாம்.'
      : 'Documents (Aadhaar, PAN, Photo, Signature) can be uploaded after member registration.';
  static String get alternateMobile =>
      isTamil ? 'மாற்று கைபேசி' : 'Alternate Mobile';
  static String get fullNameHint =>
      isTamil ? 'முழு பெயர்' : 'Full name';
  static String get fatherHusbandHint =>
      isTamil ? 'தந்தை / கணவர் பெயர்' : 'Father / Husband name';
  static String get optional => isTamil ? 'விரும்பினால்' : 'Optional';
  static String get panHint => isTamil ? 'ABCDE1234F' : 'ABCDE1234F';
  static String get autoGeneratedMemberNo => isTamil
      ? 'காலியாக விட்டால் தானாக உருவாக்கப்படும்'
      : 'Auto-generated if empty';
  static String get occupationHint =>
      isTamil ? 'வணிகம் / சேவை / பிற' : 'Business / Service / Other';
  static String get monthlyIncomeHint =>
      isTamil ? 'மாத வருமானம் ₹' : 'Monthly income in ₹';
  static String get addressHint =>
      isTamil ? 'முழு முகவரி' : 'Complete address';
  static String get bidStartTime =>
      isTamil ? 'ஏல தொடக்க நேரம்' : 'Bid Start Time';
  static String get monthShort => isTamil ? 'மா' : 'M';
  static String bidsFromMonth(String monthYear) => isTamil
      ? '$monthYear முதல் ஏலம்'
      : 'Bids from $monthYear';
  static String commissionPercentLabel(int pct) =>
      isTamil ? '$pct% கமிஷன்' : '$pct% Commission';
  static String durationValue(int months) =>
      isTamil ? '$months ${monthsShort}' : '$months mo';
  static String durationScheme(int months) =>
      isTamil ? '$months மாத திட்டம்' : '$months months scheme';
  static String lakhLabel(num lakhs) {
    final s = lakhs == lakhs.roundToDouble()
        ? lakhs.toInt().toString()
        : lakhs.toString();
    if (isTamil) {
      return lakhs == 1 ? '$s லட்சம்' : '$s லட்சம்';
    }
    return lakhs == 1 ? '$s Lakh' : '$s Lakhs';
  }
  static String get removeFromChitTitle =>
      isTamil ? 'சீட்டிலிருந்து நீக்கு' : 'Remove from Chit';
  static String removeFromChitMessage(String name) => isTamil
      ? '$name-ஐ இந்த சீட்டிலிருந்து நீக்கவா? அவரின் சீட்டு எண் விடுவிக்கப்படும்.'
      : 'Remove $name from this chit? Their ticket will be freed.';
  static String chitFullMax(int max) =>
      isTamil ? 'சீட் நிரம்பியது (அதிகபட்சம் $max உறுப்பினர்கள்)' : 'Chit is full ($max members max)';
  static String couldNotAssignMember(String e) =>
      isTamil ? 'உறுப்பினரை நியமிக்க முடியவில்லை: $e' : 'Could not assign member: $e';
  static String couldNotUpdateTicket(String e) =>
      isTamil ? 'சீட்டு எண் புதுப்பிக்க முடியவில்லை: $e' : 'Could not update ticket: $e';
  static String get cannotRemoveHasPayments => isTamil
      ? 'நீக்க முடியாது — இந்த சீட்டுக்கு கட்டண பதிவுகள் உள்ளன'
      : 'Cannot remove — member has payment records for this chit';
  static String couldNotRemoveMember(String e) =>
      isTamil ? 'உறுப்பினரை நீக்க முடியவில்லை: $e' : 'Could not remove member: $e';
  static String ticketRangeError(int max) => isTamil
      ? 'சீட்டு எண் 1 முதல் $max வரை இருக்க வேண்டும்'
      : 'Ticket numbers must be between 1 and $max';
  static String duplicateTicketError(int ticketNo) => isTamil
      ? 'சீட்டு #$ticketNo ஒன்றுக்கு மேல் உறுப்பினர்களுக்கு நியமிக்கப்பட்டுள்ளது'
      : 'Ticket #$ticketNo is assigned to more than one member';
  static String errorLoadingPaymentSchedule(String e) => isTamil
      ? 'கட்டண அட்டவணை ஏற்றுவதில் பிழை: $e'
      : 'Error loading payment schedule: $e';
  static String get notPaid => isTamil ? 'செலுத்தவில்லை' : 'Not Paid';
  static String memberPaymentLine(String memberNo, int month, String chitName) =>
      isTamil
          ? '$memberNo • மாதம் $month • $chitName'
          : '$memberNo • Month $month • $chitName';
  static String get noMembersYet =>
      isTamil ? 'இன்னும் உறுப்பினர்கள் இல்லை' : 'No members yet';
  static String get deleteMemberTitle =>
      isTamil ? 'உறுப்பினரை நீக்கு' : 'Delete Member';
  static String get deleteMemberMessage => isTamil
      ? 'இந்த உறுப்பினர் நிரந்தரமாக நீக்கப்படும்.'
      : 'This member will be permanently deleted.';
  static String get memberNotFound =>
      isTamil ? 'உறுப்பினர் கிடைக்கவில்லை' : 'Member not found';
  static String get financialLedger =>
      isTamil ? 'நிதி பதிவேடு' : 'Financial Ledger';
  static String get enterBidDiscount =>
      isTamil ? 'ஏல தள்ளு உள்ளிடவும்' : 'Enter bid discount';
  static String get totalCollectedThisMonth =>
      isTamil ? 'இந்த மாதம் மொத்த வசூல்' : 'Total collected this month';
  static String get discountMinusCommission =>
      isTamil ? 'தள்ளு கழித்து கமிஷன்' : 'Discount minus commission';
  static String get winnerDrawTitle =>
      isTamil ? 'ஏலம் வென்றவர்' : 'The person who drew the lot';
  static String bidDiscountPercent(double pct) =>
      isTamil ? '$pct% தள்ளு' : '$pct% discount';
  static String chitMonthLine(String chitName, String month) =>
      isTamil ? '$chitName • மா$month' : '$chitName • Month $month';
  static String allAuctionsRecorded(int months) => isTamil
      ? 'அனைத்து $months ஏலங்களும் பதிவு — சீட் முடிந்தது'
      : 'All $months auctions recorded — chit completed';
  static String monthProgress(int current, int total, int remaining) => isTamil
      ? 'மா$current / $total • $remaining மீதம்'
      : 'Month $current of $total • $remaining remaining';
  static String get auctionMonthLabel =>
      isTamil ? 'ஏல மாதம்' : 'Auction Month';
  static String get dateLabel => isTamil ? 'தேதி' : 'Date';
  static String get chitScheme =>
      isTamil ? 'சீட்டு திட்டம்' : 'Chit Scheme';
  static String get collectionThisMonth =>
      isTamil ? 'இந்த மாத வசூல்' : 'Collection';
  static String get remarksOptional =>
      isTamil ? 'குறிப்புகள் (விரும்பினால்)' : 'Remarks (optional)';
  static String get dividendPerMemberShort =>
      isTamil ? 'லாபம் / உறுப்பினர்' : 'Dividend / Member';
  static String get nextMonthDue =>
      isTamil ? 'அடுத்த மாத தவணை' : 'Next Month Due';
  static String get saving => isTamil ? 'சேமிக்கிறது…' : 'Saving…';
  static String get updateAuction =>
      isTamil ? 'ஏலம் புதுப்பி' : 'Update Auction';
  static String get saveAuctionResult => isTamil
      ? 'ஏல முடிவை சேமி'
      : 'Save Auction Result';
  static String errorLoadingChits(String e) =>
      isTamil ? 'சீட்டுகளை ஏற்றுவதில் பிழை: $e' : 'Error loading chits: $e';
  static String get joinedLabel =>
      isTamil ? 'சேர்ந்த தேதி' : 'Joined';
  static String memberSavedSuccess(String name) =>
      isTamil ? '$name வெற்றிகரமாக சேமிக்கப்பட்டது' : '$name saved successfully';
  static String memberCreatedAssignedTicket(String name, int ticket) => isTamil
      ? '$name உருவாக்கப்பட்டு சீட்டு #$ticket நியமிக்கப்பட்டது'
      : '$name created and assigned ticket #$ticket';
  static String memberAssignedTicket(String name, int ticket) => isTamil
      ? '$name-க்கு சீட்டு #$ticket நியமிக்கப்பட்டது'
      : '$name assigned ticket #$ticket';
  static String get aadhaarHint =>
      isTamil ? '12 இலக்க ஆதார்' : '12-digit Aadhaar';
  static String get noOutstandingBalance =>
      isTamil ? 'நிலுவை தொகை இல்லை' : 'No outstanding balance';
  static String get noGuarantorsAdded =>
      isTamil ? 'ஜமீந்தார் சேர்க்கப்படவில்லை' : 'No guarantors added';
  static String get enterTicketNumber =>
      isTamil ? 'சீட்டு எண் உள்ளிடவும்' : 'Enter a ticket number';
  static String get assign =>
      isTamil ? 'நியமி' : 'Assign';
  static String get schemeWord =>
      isTamil ? 'திட்டம்' : 'Scheme';
  static String thousandLabel(num thousands) {
    final s = thousands == thousands.roundToDouble()
        ? thousands.toInt().toString()
        : thousands.toString();
    if (isTamil) return '$s ஆயிரம்';
    return '$s Thousand';
  }
  static String paymentRecorded(String receipt) => isTamil
      ? 'கட்டணம் பதிவு செய்யப்பட்டது. ரசீது: $receipt'
      : 'Payment recorded. Receipt: $receipt';
  static String paymentModeLabel(String mode) {
    switch (mode.toLowerCase()) {
      case 'cash':
        return isTamil ? 'பணம்' : 'CASH';
      case 'upi':
        return 'UPI';
      case 'bank_transfer':
        return isTamil ? 'வங்கி பரிமாற்றம்' : 'BANK TRANSFER';
      case 'cheque':
        return isTamil ? 'காசோலை' : 'CHEQUE';
      default:
        return mode.toUpperCase();
    }
  }

  /// Localized auction day schedule label.
  static String auctionSchedule(int auctionDay, String? auctionTime) {
    final dayLabel = isTamil ? '${auctionDay}ம்' : _ordinalEn(auctionDay);
    if (auctionTime == null || auctionTime.isEmpty) {
      return isTamil
          ? 'ஒவ்வொரு மாதமும் $dayLabel நாள்'
          : 'Every month $dayLabel';
    }
    final parts = auctionTime.split(':');
    if (parts.length < 2) {
      return isTamil
          ? 'ஒவ்வொரு மாதமும் $dayLabel நாள்'
          : 'Every month $dayLabel';
    }
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final timeStr = _formatTime(hour, minute);
    return isTamil
        ? 'ஒவ்வொரு மாதமும் $dayLabel நாள் $timeStr'
        : 'Every month $dayLabel at $timeStr';
  }

  static String _ordinalEn(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  static String _formatTime(int hour, int minute) {
    if (isTamil) {
      final period = hour < 12 ? 'காலை' : 'மாலை';
      final h12 = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
      return '$period $h12:${minute.toString().padLeft(2, '0')}';
    }
    final ampm = hour < 12 ? 'AM' : 'PM';
    final h12 = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
    return '$h12:${minute.toString().padLeft(2, '0')} $ampm';
  }

  static String chitStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return active;
      case 'completed':
        return statusCompleted;
      case 'paid':
        return paid;
      case 'overdue':
        return overdue;
      case 'partial':
        return partial;
      case 'pending':
        return pending;
      default:
        return status;
    }
  }
}
