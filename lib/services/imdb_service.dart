import 'package:flutter/material.dart';
import 'package:m3u_player/api/imdb.dart';
import 'package:m3u_player/model/imdb_metadata.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ImdbService {
  static const _instance = ImdbService._();

  const ImdbService._();

  factory ImdbService() => _instance;

  Future<List<ImdbMetadata>> getImdbMetadataListFromTitle(String title) async {
    try {
      final result = await ImdbClient().findImdbMetadataListByTitle(title);
      return result;
    } catch (err) {
      ShadToast.destructive(
        title: Text('Error'),
        description: Text(err.toString()),
      );
      return [];
    }
  }
}
