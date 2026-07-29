import 'song.dart';

class Playlist {
  final String id;
  String name;
  List<Song> songs;
  String? coverUri;
  DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    List<Song>? songs,
    this.coverUri,
    DateTime? createdAt,
  })  : songs = songs ?? [],
        createdAt = createdAt ?? DateTime.now();

  int get songCount => songs.length;

  String get totalDurationFormatted {
    final totalMs = songs.fold<int>(0, (sum, s) => sum + s.duration);
    final d = Duration(milliseconds: totalMs);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'songs': songs.map((s) => s.toJson()).toList(),
        'coverUri': coverUri,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'],
        name: json['name'],
        songs: (json['songs'] as List<dynamic>)
            .map((s) => Song.fromJson(s))
            .toList(),
        coverUri: json['coverUri'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
