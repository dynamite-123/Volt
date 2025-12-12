class ApiConstants {
  ApiConstants._();
  
  // Base URL - Update this with your server URL
  // For Android Emulator, use 10.0.2.2 to access host machine's localhost
  // For physical device, use your machine's IP address
  static const String baseUrl = 'http://10.116.58.245:8000';
  // static const String baseUrl = 'http://10.0.2.2:8000';
  // static const String baseUrl = 'https://8d0a4b31ba4e.ngrok-free.app';
  // Auth endpoints
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login/json';
  static const String getCurrentUserEndpoint = '/auth/me';
  
  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
}

  