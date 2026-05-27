/// Static string constants for WATT Smart Meter
class AppStrings {
  AppStrings._();

  static const String appName = 'WATT Smart Meter';
  static const String appTagline = 'Solar Energy Monitoring';
  static const String poweredBy = 'Powered by WATT Protocol';

  // Auth
  static const String signIn = 'Sign In';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String loginSubtitle = 'Monitor your solar energy in real time';
  static const String invalidCredentials = 'Invalid email or password';
  static const String loginError = 'An error occurred. Please try again.';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String voltage = 'Voltage';
  static const String current = 'Current';
  static const String power = 'Power';
  static const String energy = 'Energy (kWh)';
  static const String totalRewards = 'TOTAL REWARDS';
  static const String energyConsumedToday = 'Energy consumed today';
  static const String todaysInsight = "Today's Insight";
  static const String powerVsEnergyHint =
      'Power (W) is instant draw; energy (kWh) is total used over time (1 kWh = 1,000 W for 1 hour).';
  static const String noSamplesTodayYet = 'No meter samples yet today';
  static const String lifetimeWatt = 'Lifetime WATT';
  static const String frequency = 'Frequency';
  static const String powerFactor = 'Power Factor';
  static const String statusLive = 'Live';
  static const String statusNotLive = 'Meter not live';
  static const String statusOffline = 'Offline';
  static const String deviceOnline = 'Meter connected';
  static const String deviceOffline = 'Meter not connected';
  static const String lastUpdated = 'Last updated';
  static const String noData = 'No data yet';
  static const String noDataSubtitle = 'Waiting for sensor readings...';

  // History
  static const String history = 'Energy History';
  static const String energyHistory = 'Energy History';
  static const String energyUsageKwh = 'Energy consumed (kWh)';
  static const String energyFromMeterRegister = 'Meter register';
  static const String energyMintedInPeriod = 'Minted (rewards basis)';
  static const String energyMeterMintMismatchHint =
      'Minting uses whole kWh batches from the meter worker; the register line shows only samples in this period.';
  static const String wattEarnedEst = 'WATT Earned (EST)';
  static const String onChain = 'ON-CHAIN';
  static const String pending = 'PENDING';
  /// Fractional kWh toward the next whole-kWh mint (not unconfirmed WATT).
  static const String accruingKwh = 'Accruing kWh';
  static const String pendingBalance = 'Accruing';
  static const String uptime = 'Uptime';
  static const String significantEvents = 'SIGNIFICANT EVENTS';
  static const String viewAll = 'View All';
  static const String vsPriorPeriod = 'vs prior period';
  static const String vsLastWeek = 'vs last week';
  static const String energyFilter = 'ENERGY';
  static const String powerFilter = 'POWER';
  static const String powerUsageKw = 'Power Usage (KW)';
  static const String selectMeter = 'Select meter';
  static const String noReadingsForMeter = 'No readings for this meter in this period';
  static const String today = 'Today';
  static const String last7Days = '7 Days';
  static const String last30Days = '30 Days';
  static const String totalEnergy = 'Total Energy';
  static const String avgPower = 'Avg Power';
  static const String peakPower = 'Peak Power';
  static const String noReadings = 'No readings for this period';
  static const String energyConsumption = 'ENERGY CONSUMPTION';
  static const String economyRewards = 'ECONOMY & REWARDS';
  static const String mintingActivity = 'MINTING ACTIVITY';
  static const String kwhMinted = 'kWh minted';
  static const String wattMinted = 'WATT minted';
  static const String statusPending = 'Pending';
  static const String statusConfirmed = 'Confirmed';
  static const String statusFailed = 'Failed';
  static const String userWattReceived = 'You received';
  static const String wattGrossMint = 'Gross mint';
  static const String userMintTx = 'Your wallet TX';
  static const String cifMintTx = 'CIF wallet TX';
  static const String userTxStatus = 'User transfer';
  static const String cifTxStatus = 'CIF transfer';
  static const String walletTxCountHint =
      'One confirmed mint = one incoming TX to your wallet';
  static const String lifetimeCifFromYou = 'CIF from your mints';
  static const String yourWalletBalance = 'Received (net)';
  static const String noMintingEvents = 'No minting events in this period';
  static const String recentMint = 'RECENT MINT';
  static const String viewHistory = 'View full history';
  static const String send = 'Send';
  static const String receive = 'Receive';
  static const String sendWatt = 'Send WATT';
  static const String receiveWatt = 'Receive WATT';
  static const String scanQr = 'Scan QR';
  static const String recipientAddress = 'Recipient address';
  static const String amountWatt = 'Amount (WATT)';
  static const String openInWallet = 'Open in wallet';
  static const String copyTransferDetails = 'Copy transfer details';
  static const String receiveQrHint = 'Share this QR to receive WATT';
  static const String noWalletConnected = 'No wallet on your account';
  static const String invalidAddress = 'Enter a valid 0x address';
  static const String periodMinted = 'Minted this period';
  static const String cifContribution = 'CIF';
  static const String txHash = 'TX';
  static const String mintingActivityTitle = 'Minting Activity';
  static const String filterAll = 'All';
  static const String sortBy = 'Sort';
  static const String sortNewest = 'Newest first';
  static const String sortOldest = 'Oldest first';
  static const String sortWattHigh = 'Highest WATT';
  static const String sortKwhHigh = 'Highest kWh';
  static const String activityDetail = 'Activity Detail';
  static const String eventId = 'Event ID';
  static const String walletAddress = 'Wallet Address';
  static const String mintTransaction = 'Mint Transaction';
  static const String cifTransaction = 'CIF Transaction';
  static const String status = 'Status';
  static const String dateTime = 'Date & Time';
  static const String copy = 'Copy';
  static const String copied = 'Copied to clipboard';
  static const String noMatchingEvents = 'No events match these filters';
  static const String tapForDetails = 'Tap for full details';

  // Settings
  static const String settings = 'Settings';
  static const String metersAndDevices = 'METERS & DEVICES';
  static const String myMeters = 'My Meters';
  static const String activeMonitoring = 'Active monitoring enabled';
  static const String addNewMeter = 'Add New Meter';
  static const String display = 'DISPLAY';
  static const String displaySettings = 'Display';
  static const String appearance = 'Appearance';
  static const String themeDark = 'Dark';
  static const String themeLight = 'Light';
  static const String themeSystem = 'System';
  static const String defaultScreenLabel = 'Default Screen';
  static const String defaultScreenHint = 'Used when you open the app';
  static const String walletAndRewards = 'WALLET & REWARDS';
  static const String walletSettingsTitle = 'Wallet & rewards';
  static const String notificationsSettingsTitle = 'Notifications';
  static const String walletSettingsSubtitle =
      'Send, receive, payouts & explorer';
  static const String notificationsSettingsSubtitle =
      'Alerts and quiet meter threshold';
  static const String connectedWallet = 'Connected Wallet';
  static const String editWallet = 'Set wallet';
  static const String walletAddressHint = '0x… wallet address';
  static const String walletSaved = 'Wallet address saved';
  static const String invalidWallet = 'Enter a valid 0x address (40 hex characters)';
  static const String noWalletSet = 'No wallet connected';
  static const String payouts = 'Payouts';
  static const String explorer = 'Explorer';
  static const String notifications = 'NOTIFICATIONS';
  static const String notificationsMaster = 'Master Toggle';
  static const String staleDataThreshold = 'Quiet meter alert';
  static const String highVoltageAlert = 'High Voltage Alert';
  static const String referralLink = 'Referral Link';
  static const String userId = 'User ID';
  static const String signOut = 'SIGN OUT';
  static const String signOutConfirm = 'Are you sure you want to sign out?';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String meterConnection = 'METER CONNECTION';
  static const String deviceConfig = 'Meter setup';
  static const String meterCode = 'Meter code';
  static const String meterCodeHint = 'Same code as on your meter label';
  static const String meterCodeSaved = 'Meter code updated';
  static const String meterWifiTitle = 'Wi‑Fi for your meter';
  static const String meterWifiEmptyHint =
      'No network saved yet. Enter your phone hotspot or home Wi‑Fi so the meter can connect.';
  static String meterWifiActiveHint(String networkName) =>
      'Saved network: $networkName. The meter picks this up on its next check (about every 2 minutes).';
  static const String wifiNetworkName = 'Network name';
  static const String wifiPassword = 'Password';
  static const String wifiNetworkNameRequired = 'Enter the network name';
  static const String wifiPasswordRequired = 'Enter the Wi‑Fi password';
  static const String saveWifiForMeter = 'Save network for meter';
  static const String wifiSaved =
      'Network saved. Turn on the hotspot and power-cycle the meter if it does not connect.';
  static const String wifiSaveFailed =
      'Could not save network. Check your connection and try again.';
  static const String wifiLoadFailed =
      'Could not load saved network. Pull to refresh or try again later.';
  static const String loadingWifi = 'Loading saved network…';
  static const String wifiLastUpdated = 'Last saved';
  static const String offlineNoDataHint =
      'No readings yet. Plug in the meter, turn on your phone hotspot or Wi‑Fi, and save the network below.';
  static const String offlineStaleHint =
      'The meter is not sending new readings. Check power, Wi‑Fi, and save your network in Settings → Meter connection.';
  static const String offlineWaitingHint =
      'Waiting for a new reading (about every 15 seconds when connected). Update Wi‑Fi under Settings if you changed networks.';
  static const String staleBannerBody =
      'Numbers below are from your last saved reading. Fresh readings arrive about every 15 seconds when the meter is connected.';
  static const String account = 'ACCOUNT';
  static const String logout = 'Logout';
  static const String about = 'About';
  static const String version = 'Version';
  static const String defaultDeviceId = 'esp32_001';

  // Units
  static const String unitVoltage = 'V';
  static const String unitCurrent = 'A';
  static const String unitPower = 'W';
  static const String unitEnergy = 'kWh';
  static const String unitFrequency = 'Hz';
  static const String unitPowerFactor = '';

  // Errors
  static const String connectionError = 'Connection error';
  static const String retry = 'Retry';
}
