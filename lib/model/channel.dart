class Channel {
  final String id;
  final String name;
  final String logo;
  final Uri url;
  final String group;

  const Channel({
    required this.id,
    required this.name,
    required this.group,
    required this.logo,
    required this.url,
  });

  Channel copyWith({
    String? id,
    String? name,
    String? logo,
    Uri? url,
    String? group,
  }) => Channel(
    id: id ?? this.id,
    name: name ?? this.name,
    logo: logo ?? this.logo,
    url: url ?? this.url,
    group: group ?? this.group,
  );
}
