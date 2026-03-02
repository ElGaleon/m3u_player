import 'package:flutter/material.dart';

enum GroupCategory {
  scopri('SCOPRI', Icons.explore),
  genere('GENERI', Icons.movie_filter_outlined),
  annata('ANNATE', Icons.calendar_today_rounded),
  piattaforma('PIATTAFORMA', Icons.live_tv_outlined),
  attore('ATTORI', Icons.person_outline_rounded),
  regista('REGISTI', Icons.movie_creation_outlined),
  adult('ADULTI', Icons.eighteen_up_rating);

  final String label;
  final IconData icon;
  const GroupCategory(this.label, this.icon);
}

class GroupClassifier {
  static GroupCategory classify(String name) {
    final lower = name.toLowerCase();

    if (lower.startsWith('xxx')) {
      return GroupCategory.adult;
    }

    const platformKeywords = {'disney+', 'netflix'};
    if (platformKeywords.any((key) => lower.contains(key))) {
      return GroupCategory.piattaforma;
    }

    if (lower.contains('anno') ||
        lower.contains('anni') ||
        RegExp(r'^\d{4}').hasMatch(lower)) {
      return GroupCategory.annata;
    }

    const generi = {
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
    if (generi.any((keyword) => lower.contains(keyword))) {
      return GroupCategory.genere;
    }

    if (lower.startsWith('regia di')) {
      return GroupCategory.regista;
    }

    const discoverKeywords = {
      'film più',
      'oggi al cinema',
      'recenti',
      '4k',
      'visti ultima',
    };
    if (discoverKeywords.any((key) => lower.contains(key))) {
      return GroupCategory.scopri;
    }

    // 4. Default agli Attori
    return GroupCategory.attore;
  }
}
