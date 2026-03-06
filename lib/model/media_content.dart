import 'package:m3u_player/model/media_content_type.dart';

class MediaContent {
  final String id;
  final String name;
  final MediaContentType type;
  final String logo;
  final Uri url;
  final String group;

  const MediaContent({
    required this.id,
    required this.name,
    required this.type,
    required this.group,
    required this.logo,
    required this.url,
  });

  String get cleanTitle {
    String clean = name.split('(')[0].trim();
    return clean.isEmpty ? name : clean;
  }

  MediaContent copyWith({
    String? id,
    String? name,
    MediaContentType? type,
    String? logo,
    Uri? url,
    String? group,
  }) => MediaContent(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    logo: logo ?? this.logo,
    url: url ?? this.url,
    group: group ?? this.group,
  );

  bool get isLive => type == MediaContentType.live;

  bool get isMovie => type == MediaContentType.movie;

  bool get isSeries => type == MediaContentType.series;
}

class MediaContentList {
  final List<MediaContent> content;

  MediaContentList({required this.content});

  factory MediaContentList.fake() {
    return MediaContentList(
      content: [
        MediaContent(
          id: 'l1',
          name: 'Rai 1 HD',
          type: MediaContentType.live,
          group: 'Nazionale',
          logo: 'https://dummyimage.com/150x150/007bff/fff&text=Rai1',
          url: Uri.parse('http://fake.tv/rai1.m3u8'),
        ),
        MediaContent(
          id: 'l2',
          name: 'Canale 5 HD',
          type: MediaContentType.live,
          group: 'Nazionale',
          logo: 'https://dummyimage.com/150x150/ff8800/fff&text=Canale5',
          url: Uri.parse('http://fake.tv/canale5.m3u8'),
        ),
        MediaContent(
          id: 'l3',
          name: 'Sky Sport 24',
          type: MediaContentType.live,
          group: 'Sport',
          logo: 'https://dummyimage.com/150x150/0044cc/fff&text=SkySport',
          url: Uri.parse('http://fake.tv/skysport.m3u8'),
        ),
        MediaContent(
          id: 'l4',
          name: 'Eurosport 1',
          type: MediaContentType.live,
          group: 'Sport',
          logo: 'https://dummyimage.com/150x150/002266/fff&text=Eurosport',
          url: Uri.parse('http://fake.tv/eurosport.m3u8'),
        ),
        MediaContent(
          id: 'l5',
          name: 'Sky Cinema Uno',
          type: MediaContentType.live,
          group: 'Cinema',
          logo: 'https://dummyimage.com/150x150/cc0000/fff&text=SkyCinema',
          url: Uri.parse('http://fake.tv/skycinema.m3u8'),
        ),
        MediaContent(
          id: 'l6',
          name: 'CNN International',
          type: MediaContentType.live,
          group: 'News',
          logo: 'https://dummyimage.com/150x150/dd0000/fff&text=CNN',
          url: Uri.parse('http://fake.tv/cnn.m3u8'),
        ),
        MediaContent(
          id: 'l7',
          name: 'BBC News',
          type: MediaContentType.live,
          group: 'News',
          logo: 'https://dummyimage.com/150x150/880000/fff&text=BBC',
          url: Uri.parse('http://fake.tv/bbc.m3u8'),
        ),
        MediaContent(
          id: 'l8',
          name: 'National Geographic',
          type: MediaContentType.live,
          group: 'Documentari',
          logo: 'https://dummyimage.com/150x150/ffcc00/000&text=NatGeo',
          url: Uri.parse('http://fake.tv/natgeo.m3u8'),
        ),
        MediaContent(
          id: 'l9',
          name: 'Discovery Channel',
          type: MediaContentType.live,
          group: 'Documentari',
          logo: 'https://dummyimage.com/150x150/0088cc/fff&text=Discovery',
          url: Uri.parse('http://fake.tv/discovery.m3u8'),
        ),
        MediaContent(
          id: 'l10',
          name: 'MTV Hits',
          type: MediaContentType.live,
          group: 'Musica',
          logo: 'https://dummyimage.com/150x150/ff00ff/fff&text=MTV',
          url: Uri.parse('http://fake.tv/mtv.m3u8'),
        ),

        MediaContent(
          id: 'm1',
          name: 'Il Padrino (1972)',
          type: MediaContentType.movie,
          group: 'Drammatico',
          logo: 'https://dummyimage.com/200x300/333/fff&text=Godfather',
          url: Uri.parse('http://fake.tv/movies/godfather.mp4'),
        ),
        MediaContent(
          id: 'm2',
          name: 'Matrix',
          type: MediaContentType.movie,
          group: 'Fantascienza',
          logo: 'https://dummyimage.com/200x300/003300/0f0&text=Matrix',
          url: Uri.parse('http://fake.tv/movies/matrix.mp4'),
        ),
        MediaContent(
          id: 'm3',
          name: 'Inception',
          type: MediaContentType.movie,
          group: 'Fantascienza',
          logo: 'https://dummyimage.com/200x300/222/fff&text=Inception',
          url: Uri.parse('http://fake.tv/movies/inception.mp4'),
        ),
        MediaContent(
          id: 'm4',
          name: 'Avengers: Endgame',
          type: MediaContentType.movie,
          group: 'Azione',
          logo: 'https://dummyimage.com/200x300/550000/fff&text=Avengers',
          url: Uri.parse('http://fake.tv/movies/avengers.mp4'),
        ),
        MediaContent(
          id: 'm5',
          name: 'Il Cavaliere Oscuro',
          type: MediaContentType.movie,
          group: 'Azione',
          logo: 'https://dummyimage.com/200x300/111/fff&text=Batman',
          url: Uri.parse('http://fake.tv/movies/dark_knight.mp4'),
        ),
        MediaContent(
          id: 'm6',
          name: 'Pulp Fiction',
          type: MediaContentType.movie,
          group: 'Thriller',
          logo: 'https://dummyimage.com/200x300/ccaa00/000&text=Pulp+Fiction',
          url: Uri.parse('http://fake.tv/movies/pulp_fiction.mp4'),
        ),
        MediaContent(
          id: 'm7',
          name: 'Forrest Gump',
          type: MediaContentType.movie,
          group: 'Drammatico',
          logo: 'https://dummyimage.com/200x300/0055aa/fff&text=Forrest+Gump',
          url: Uri.parse('http://fake.tv/movies/forrest.mp4'),
        ),
        MediaContent(
          id: 'm8',
          name: 'Una notte da leoni',
          type: MediaContentType.movie,
          group: 'Commedia',
          logo: 'https://dummyimage.com/200x300/ff8800/fff&text=Hangover',
          url: Uri.parse('http://fake.tv/movies/hangover.mp4'),
        ),
        MediaContent(
          id: 'm9',
          name: 'Tre uomini e una gamba',
          type: MediaContentType.movie,
          group: 'Commedia',
          logo:
              'https://dummyimage.com/200x300/00aa55/fff&text=AldoGiovanniGiacomo',
          url: Uri.parse('http://fake.tv/movies/tre_uomini.mp4'),
        ),
        MediaContent(
          id: 'm10',
          name: 'Parasite',
          type: MediaContentType.movie,
          group: 'Thriller',
          logo: 'https://dummyimage.com/200x300/444/fff&text=Parasite',
          url: Uri.parse('http://fake.tv/movies/parasite.mp4'),
        ),

        MediaContent(
          id: 's1',
          name: 'Breaking Bad S01 E01',
          type: MediaContentType.series,
          group: 'Drammatico',
          logo: 'https://dummyimage.com/200x300/004411/fff&text=Breaking+Bad',
          url: Uri.parse('http://fake.tv/series/bb_s1e1.mp4'),
        ),
        MediaContent(
          id: 's2',
          name: 'Breaking Bad S01 E02',
          type: MediaContentType.series,
          group: 'Drammatico',
          logo: 'https://dummyimage.com/200x300/004411/fff&text=Breaking+Bad',
          url: Uri.parse('http://fake.tv/series/bb_s1e2.mp4'),
        ),
        MediaContent(
          id: 's3',
          name: 'Game of Thrones S01 E01',
          type: MediaContentType.series,
          group: 'Fantasy',
          logo: 'https://dummyimage.com/200x300/333/fff&text=GOT',
          url: Uri.parse('http://fake.tv/series/got_s1e1.mp4'),
        ),
        MediaContent(
          id: 's4',
          name: 'Stranger Things S01 E01',
          type: MediaContentType.series,
          group: 'Fantascienza',
          logo:
              'https://dummyimage.com/200x300/cc0000/fff&text=Stranger+Things',
          url: Uri.parse('http://fake.tv/series/st_s1e1.mp4'),
        ),
        MediaContent(
          id: 's5',
          name: 'The Office S01 E01',
          type: MediaContentType.series,
          group: 'Commedia',
          logo: 'https://dummyimage.com/200x300/ffffff/000&text=The+Office',
          url: Uri.parse('http://fake.tv/series/office_s1e1.mp4'),
        ),
        MediaContent(
          id: 's6',
          name: 'Friends S01 E01',
          type: MediaContentType.series,
          group: 'Commedia',
          logo: 'https://dummyimage.com/200x300/222222/fff&text=Friends',
          url: Uri.parse('http://fake.tv/series/friends_s1e1.mp4'),
        ),
        MediaContent(
          id: 's7',
          name: 'Peaky Blinders S01 E01',
          type: MediaContentType.series,
          group: 'Drammatico',
          logo: 'https://dummyimage.com/200x300/111/fff&text=Peaky+Blinders',
          url: Uri.parse('http://fake.tv/series/peaky_s1e1.mp4'),
        ),
        MediaContent(
          id: 's8',
          name: 'Black Mirror S01 E01',
          type: MediaContentType.series,
          group: 'Fantascienza',
          logo: 'https://dummyimage.com/200x300/000/fff&text=Black+Mirror',
          url: Uri.parse('http://fake.tv/series/bm_s1e1.mp4'),
        ),
        MediaContent(
          id: 's9',
          name: 'The Boys S01 E01',
          type: MediaContentType.series,
          group: 'Azione',
          logo: 'https://dummyimage.com/200x300/aa0000/fff&text=The+Boys',
          url: Uri.parse('http://fake.tv/series/boys_s1e1.mp4'),
        ),
        MediaContent(
          id: 's10',
          name: 'Dark S01 E01',
          type: MediaContentType.series,
          group: 'Thriller',
          logo: 'https://dummyimage.com/200x300/222/aaa&text=Dark',
          url: Uri.parse('http://fake.tv/series/dark_s1e1.mp4'),
        ),
      ],
    );
  }
}
