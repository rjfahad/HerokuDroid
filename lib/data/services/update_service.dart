import 'package:dio/dio.dart';
import 'package:herokudroid/core/constants/update_constants.dart';
import 'package:herokudroid/data/models/app_update.dart';

/// Fetches the app's update manifest from the GitHub repository.
///
/// This is unauthenticated and unrelated to the Heroku API, so it uses its own
/// Dio instance instead of `HerokuApiService`.
class UpdateService {
  UpdateService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: UpdateConstants.timeout,
              receiveTimeout: UpdateConstants.timeout,
            ),
          );

  final Dio _dio;

  /// Fetch the latest advertised release.
  ///
  /// Returns null when the manifest is empty or unparseable. Throws on network
  /// failures so callers can decide whether to surface an error.
  Future<AppUpdate?> fetchLatest() async {
    final response = await _dio.get<String>(
      UpdateConstants.manifestUrl,
      // Bust the raw.githubusercontent CDN cache.
      queryParameters: {'t': DateTime.now().millisecondsSinceEpoch},
      options: Options(responseType: ResponseType.plain),
    );

    final text = response.data;
    if (text == null) return null;
    return AppUpdate.parse(text);
  }
}
