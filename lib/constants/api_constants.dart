class ApiConstants {
  // For Android Emulator
  static const String localEmulatorUrl = 'http://10.0.2.2:3000';

  // For Physical Device - Using your actual IP
  static const String localDeviceUrl = 'http://192.168.20.9:3000';

  // Google Maps API Key
  static const String googleMapsApiKey =
      'AIzaSyD3GamLtkYbSkixHX6ybPKnzjxdQ46pBIU';

  // Change this line based on your testing environment
  static String baseUrl = localDeviceUrl; // if using physical device
  // static String baseUrl = localEmulatorUrl;  // if using emulator
}
