import 'media_content.dart';

class Series {
  final String title;
  final String logo;
  final String group;
  final Map<int, List<MediaContent>> seasons;

  Series({
    required this.title,
    required this.logo,
    required this.group,
    required this.seasons,
  });

  String get cleanTitle {
    String clean = title.split('(')[0].trim();
    return clean.isEmpty ? title : clean;
  }

  int get episodeNumber {
    final match = RegExp(r'E(\d+)').firstMatch(title);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  final seriesRegex = RegExp(r'S(\d+)\s+E(\d+)', caseSensitive: false);

  String? get year {
    final match = RegExp(r'\((\d{4})\)').firstMatch(title);
    return match?.group(1);
  }

  String? get resolution {
    final match = RegExp(
      r'(4[kK]|HD|FullHD|1080p|720p)$',
    ).firstMatch(title.trim());
    return match?.group(0)?.toUpperCase();
  }

  Map<String, Series> aggregateSeries(List<MediaContent> allContent) {
    Map<String, Series> seriesMap = {};

    for (var item in allContent) {
      if (!item.isSeries) continue;

      final match = seriesRegex.firstMatch(item.name);
      final cleanTitle = item.name.split('S0')[0].trim();

      int seasonNumber = match != null ? int.parse(match.group(1)!) : 1;

      if (!seriesMap.containsKey(cleanTitle)) {
        seriesMap[cleanTitle] = Series(
          title: cleanTitle,
          logo: item.logo,
          group: item.group,
          seasons: {},
        );
      }

      seriesMap[cleanTitle]!.seasons.putIfAbsent(seasonNumber, () => []);
      seriesMap[cleanTitle]!.seasons[seasonNumber]!.add(item);
    }

    return seriesMap;
  }
}
