class LocationTransformer {
  LocationTransformer._();

  static Map<String, dynamic> parse(dynamic rawLocation) {
    if (rawLocation is Map<String, dynamic>) {
      return {
        'city': (rawLocation['city'] ?? '').toString(),
        'state': (rawLocation['state'] ?? '').toString(),
        'country': (rawLocation['country'] ?? '').toString(),
      };
    }

    if (rawLocation is String) {
      final parts = rawLocation
          .split(',')
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();

      return {
        'city': parts.isNotEmpty ? parts[0] : '',
        'state': parts.length > 1 ? parts[1] : '',
        'country': parts.length > 2 ? parts.sublist(2).join(', ') : '',
      };
    }

    return const {'city': '', 'state': '', 'country': ''};
  }

  static String compose({String? city, String? state, String? country}) {
    return [city, state, country]
        .map((part) => part?.trim() ?? '')
        .where((part) => part.isNotEmpty)
        .join(', ');
  }
}
