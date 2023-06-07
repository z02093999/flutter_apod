const String tableName = 'apod';
const String pkField = '_date';
const String favoriteField = 'favorite';

class ApodDbData {
  final String date;
  final String title;
  String _imagePath;
  String videoUrl;
  String mediaType;
  final String copyright;
  final String explanation;
  int favorite;

  String get hdImagePath {
    final path = _imagePath.split(';');
    return path[0];
  }

  String get smallImagePath {
    final path = _imagePath.split(';');
    return path[1];
  }

  ApodDbData(this.date, this.title, this._imagePath, this.videoUrl,
      this.mediaType, this.copyright, this.explanation, this.favorite);

  ApodDbData.fromDbMap(Map<String, dynamic> map)
      : date = map[pkField],
        title = map['title'],
        _imagePath = map['imagePath'],
        videoUrl = map['videoUrl'],
        mediaType = map['mediaType'],
        copyright = map['copyright'],
        explanation = map['explanation'],
        favorite = map['favorite'];

  Map<String, dynamic> toMap() => {
        pkField: date,
        'title': title,
        'imagePath': _imagePath,
        'videoUrl': videoUrl,
        'mediaType': mediaType,
        'copyright': copyright,
        'explanation': explanation,
        'favorite': favorite
      };
}
