// Conditionally export platform implementations
export 'web_timezone_service.dart'
    if (dart.library.io) 'mobile_timezone_service.dart'
    show createTimezoneService;
export 'timezone_service_interface.dart' hide createTimezoneService;
