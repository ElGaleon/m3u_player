import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:m3u_player/model/media_entity.dart';
import 'package:m3u_player/utils/m3u_parser.dart';

void main() {
  test('aggregates duplicate entries as resolution variants', () async {
    final tempDir = await Directory.systemTemp.createTemp('m3u_parser_test');
    final file = File('${tempDir.path}/playlist.m3u');
    await file.writeAsString('''
#EXTM3U
#EXTINF:-1 tvg-id="live-1" tvg-name="News Channel HD" tvg-logo="live.png" group-title="News",News Channel HD
http://example.com/live/news_hd.m3u8
#EXTINF:-1 tvg-id="live-2" tvg-name="News Channel 4K" tvg-logo="live.png" group-title="News",News Channel 4K
http://example.com/live/news_4k.m3u8
#EXTINF:-1 tvg-id="movie-1" tvg-name="Big Movie (2024) HD" tvg-logo="movie.png" group-title="Movies",Big Movie (2024) HD
http://example.com/movie/big_movie_hd.mp4
#EXTINF:-1 tvg-id="movie-2" tvg-name="Big Movie (2024) 4K" tvg-logo="movie.png" group-title="Movies",Big Movie (2024) 4K
http://example.com/movie/big_movie_4k.mp4
#EXTINF:-1 tvg-id="series-1" tvg-name="Great Show S01E02 HD" tvg-logo="series.png" group-title="Series",Great Show S01E02 HD
http://example.com/series/great_show_s01e02_hd.mp4
#EXTINF:-1 tvg-id="series-2" tvg-name="Great Show S01E02 4K" tvg-logo="series.png" group-title="Series",Great Show S01E02 4K
http://example.com/series/great_show_s01e02_4k.mp4
''');

    final catalog = await M3uParser.parseFromFile(file.path);

    final liveChannels = catalog.whereType<LiveChannel>().toList();
    final movies = catalog.whereType<Movie>().toList();
    final series = catalog.whereType<Series>().toList();

    expect(liveChannels, hasLength(1));
    expect(liveChannels.single.title, 'News Channel');
    expect(liveChannels.single.resolutions, {'4K', 'HD'});

    expect(movies, hasLength(1));
    expect(movies.single.title, 'Big Movie');
    expect(movies.single.year, '2024');
    expect(movies.single.resolutions, {'4K', 'HD'});

    expect(series, hasLength(1));
    expect(series.single.title, 'Great Show');
    final episode = series.single.seasons[1]!.single;
    expect(episode.episodeNumber, 2);
    expect(episode.resolutions, {'4K', 'HD'});

    await tempDir.delete(recursive: true);
  });

  test('keeps parsing duplicate-heavy playlists fast', () async {
    final tempDir = await Directory.systemTemp.createTemp('m3u_parser_perf');
    final file = File('${tempDir.path}/playlist.m3u');
    final buffer = StringBuffer('#EXTM3U\n');

    for (var index = 0; index < 1500; index++) {
      final title = 'Movie $index';
      buffer
        ..writeln(
          '#EXTINF:-1 tvg-id="movie-$index-hd" tvg-name="$title (2024) HD" tvg-logo="movie.png" group-title="Movies",$title HD',
        )
        ..writeln('http://example.com/movie/$index/hd.mp4')
        ..writeln(
          '#EXTINF:-1 tvg-id="movie-$index-4k" tvg-name="$title (2024) 4K" tvg-logo="movie.png" group-title="Movies",$title 4K',
        )
        ..writeln('http://example.com/movie/$index/4k.mp4');
    }

    await file.writeAsString(buffer.toString());
    final stopwatch = Stopwatch()..start();
    final catalog = await M3uParser.parseFromFile(file.path);
    stopwatch.stop();

    expect(catalog.whereType<Movie>(), hasLength(1500));
    expect(catalog.whereType<Movie>().first.resolutions, {'4K', 'HD'});
    expect(stopwatch.elapsed.inSeconds, lessThan(2));

    await tempDir.delete(recursive: true);
  });
}
