import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/city_option.dart';
import '../models/country_option.dart';
import 'http_service.dart';
import 'nomads_auth_service.dart';

/// Location API service for fetching countries and cities from backend.
class LocationApiService {
  LocationApiService();

  final HttpService _httpService = HttpService();
  final NomadsAuthService _authService = NomadsAuthService();

  Future<void> _ensureAuthToken() async {
    final token = _httpService.authToken;
    if (token != null && token.isNotEmpty) {
      return;
    }

    final isLoggedIn = await _authService.checkLoginStatus();
    if (!isLoggedIn) {
      throw HttpException('未授权，请先登录', 401);
    }

    final refreshedToken = _httpService.authToken;
    if (refreshedToken == null || refreshedToken.isEmpty) {
      throw HttpException('未能获取有效的认证信息', 401);
    }
  }

  Future<List<CountryOption>> fetchCountries() async {
    await _ensureAuthToken();

    final Response<List<dynamic>> response =
        await _httpService.get<List<dynamic>>(ApiConfig.cityCountriesEndpoint);

    if (response.statusCode == 200 && response.data != null) {
      return response.data!
          .map((dynamic item) =>
              CountryOption.fromJson(item as Map<String, dynamic>))
          .where((country) => country.name.isNotEmpty)
          .toList();
    }

    throw Exception('Failed to load country list');
  }

  Future<List<CityOption>> fetchCitiesByCountry(String countryId) async {
    await _ensureAuthToken();

    final endpoint =
        ApiConfig.cityByCountryEndpoint.replaceAll('{id}', countryId);
    final Response<List<dynamic>> response =
        await _httpService.get<List<dynamic>>(endpoint);

    if (response.statusCode == 200 && response.data != null) {
      return response.data!
          .map((dynamic item) =>
              CityOption.fromJson(item as Map<String, dynamic>))
          .where((city) => city.name.isNotEmpty)
          .toList();
    }

    throw Exception('Failed to load city list');
  }
}
