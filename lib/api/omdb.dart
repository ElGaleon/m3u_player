import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:m3u_player/api/base.dart';
import 'package:m3u_player/model/movie_metadata.dart';

class OmdbClient {
  static const _instance = OmdbClient._();

  const OmdbClient._();

  factory OmdbClient() => _instance;

  static final _apiKey = dotenv.get('OMDB_APY_KEY');
  static const _baseUrl = 'http://www.omdbapi.com';

  Future<MovieMetadata> findOmdbMetadataByIdOrTitle({
    String? id,
    String? title,
    String? year,
  }) async {
    assert(id != null || title != null, 'Id or title have to be not null');
    final url = '$_baseUrl/';
    final params = {'apiKey': _apiKey, 'plot': 'full'};
    if (id != null) {
      params['i'] = id;
    }
    if (title != null) {
      params['t'] = title;
    }
    if (year != null) {
      params['y'] = year;
    }
    final response = await BaseClient().get(url, params: params);
    return MovieMetadata.fromJson(response.data as Json);
  }
}
