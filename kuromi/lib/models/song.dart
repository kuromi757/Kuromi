class Song {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String uri;
  final String? albumArtUri;
  final int duration; // ms
  final String? folderPath;
  bool isFavorite;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.uri,
    this.albumArtUri,
    required this.duration,
    this.folderPath,
    this.isFavorite = false,
  });

  String get durationFormatted {
    final d = Duration(milliseconds: duration);
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'uri': uri,
        'albumArtUri': albumArtUri,
        'duration': duration,
        'folderPath': folderPath,
        'isFavorite': isFavorite,
      };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json['id'],
        title: json['title'],
        artist: json['artist'],
        album: json['album'],
        uri: json['uri'],
        albumArtUri: json['albumArtUri'],
        duration: json['duration'],
        folderPath: json['folderPath'],
        isFavorite: json['isFavorite'] ?? false,
      );

  @override
  bool operator ==(Object other) => other is Song && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
