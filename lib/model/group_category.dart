import 'package:flutter/material.dart';
import 'package:m3u_player/model/media_content_type.dart';

class GroupedCategoryMap {
  final Map<GroupCategory, List<String>> value;

  const GroupedCategoryMap({this.value = const {}});

  factory GroupedCategoryMap.fake() => GroupedCategoryMap(
    value: {
      GroupCategory.discover: [
        'Film del momento',
        'Aggiunti di recente',
        'I più premiati dell\'anno',
      ],
      GroupCategory.genres: [
        'Azione e Avventura',
        'Commedia brillante',
        'Thriller psicologico',
        'Fantascienza',
        'Documentari storici',
        'Animazione per famiglia',
      ],
      GroupCategory.years: [
        '2025',
        '2024',
        '2023',
        'Anni 2010',
        'Anni 2000',
        'Anni 90',
        'Anni 80',
      ],
      GroupCategory.platform: [
        'Netflix Originals',
        'Amazon Prime Video',
        'Disney Plus',
        'Paramount+',
        'Apple TV+',
      ],
      GroupCategory.actor: [
        'Leonardo DiCaprio',
        'Scarlett Johansson',
        'Tom Hanks',
        'Denzel Washington',
        'Meryl Streep',
      ],
      GroupCategory.director: [
        'Christopher Nolan',
        'Steven Spielberg',
        'Quentin Tarantino',
        'Martin Scorsese',
      ],
      GroupCategory.adult: ['Contenuti 18+', 'Thriller VM18'],
    },
  );
}

enum GroupCategory implements Comparable<GroupCategory> {
  discover('SCOPRI', Icons.explore),
  genres('GENERI', Icons.movie_filter_outlined),
  years('ANNATE', Icons.calendar_today_rounded),
  platform('PIATTAFORMA', Icons.live_tv_outlined),
  actor('ATTORI', Icons.person_outline_rounded),
  director('REGISTI', Icons.movie_creation_outlined),
  adult('ADULTI', Icons.eighteen_up_rating);

  final String label;
  final IconData icon;

  const GroupCategory(this.label, this.icon);

  List<GroupCategory> get displayOrder => [
    GroupCategory.discover,
    GroupCategory.genres,
    GroupCategory.platform,
    GroupCategory.years,
    GroupCategory.actor,
    GroupCategory.director,
    GroupCategory.adult,
  ];

  @override
  int compareTo(GroupCategory other) =>
      displayOrder.indexOf(this) - displayOrder.indexOf(other);
}

class GroupClassifier {
  static GroupCategory classify(String name, MediaContentType type) {
    final lower = name.toLowerCase();

    if (type == MediaContentType.movie) {
      if (lower.startsWith('xxx')) {
        return GroupCategory.adult;
      }

      const platformKeywords = {'disney+', 'netflix'};
      if (platformKeywords.any((key) => lower.contains(key))) {
        return GroupCategory.platform;
      }

      if (lower.contains('anno') ||
          lower.contains('anni') ||
          RegExp(r'^\d{4}').hasMatch(lower)) {
        return GroupCategory.years;
      }

      const genres = {
        'avventura',
        'commedia',
        'crime',
        'documentario',
        'dramma',
        'famiglia',
        'fantascienza',
        'fantasy',
        'fiabe',
        'fitness',
        'guerra',
        'mistero',
        'musica',
        'natale',
        'romance',
        'sport',
        'storia',
        'teatrale',
        'televisione',
        'thriller',
        'western',
        'horror',
        'azione',
      };
      if (genres.any((keyword) => lower.contains(keyword))) {
        return GroupCategory.genres;
      }

      if (lower.startsWith('regia di')) {
        return GroupCategory.director;
      }

      const discoverKeywords = {
        'film più',
        'oggi al cinema',
        'recenti',
        '4k',
        'visti ultima',
      };
      if (discoverKeywords.any((key) => lower.contains(key))) {
        return GroupCategory.discover;
      }

      return GroupCategory.actor;
    }

    if (type == MediaContentType.live) {
      if (lower.contains('sport') ||
          lower.contains('calcio') ||
          lower.contains('dazn')) {
        return GroupCategory.discover;
      }
      if (lower.contains('notizie') ||
          lower.contains('news') ||
          lower.contains('tg')) {
        return GroupCategory.discover;
      }
    }
    // Series
    if (lower.contains('stagioni') || lower.contains('complete')) {
      return GroupCategory.discover;
    }

    return GroupCategory.discover;
  }
}
