import 'package:m3u_player/model/imdb_metadata.dart';

import 'base.dart';

class ImdbClient {
  static const _instance = ImdbClient._();

  const ImdbClient._();

  factory ImdbClient() => _instance;

  static const _baseUrl = 'https://imdb.iamidiotareyoutoo.com';

  Future<List<ImdbMetadata>> findImdbMetadataListByTitle(String title) async {
    final url = '$_baseUrl/search';
    final params = {'q': title};
    final response = await BaseClient().get(url, params: params);
    final data = response.data;

    if (data is Map<String, dynamic> && data['description'] != null) {
      final rawList = data['description'] as List<dynamic>;
      return rawList.map((item) => ImdbMetadata.fromJson(item)).toList();
    }
    return [];
  }
}
