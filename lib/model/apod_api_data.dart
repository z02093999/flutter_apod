/*
{
  "copyright":"Daniel Stern",
  "date":"2023-04-10",
  "explanation":"To some, it looks like a giant chicken running across the sky. To others, it looks like a gaseous nebula where star formation takes place. Cataloged as IC 2944, the Running Chicken Nebula spans about 100 light years and lies about 6,000 light years away toward the constellation of the Centaur (Centaurus).  The featured image, shown in scientifically assigned colors, was captured recently in a 16-hour exposure over three nights. The star cluster Collinder 249 is visible embedded in the nebula's glowing gas.  Although difficult to discern here, several dark molecular clouds with distinct shapes can be found inside the nebula.",
  "hdurl":"https://apod.nasa.gov/apod/image/2304/ChickenRun_Stern_9006.jpg",
  "media_type":"image",
  "service_version":"v1",
  "title":"IC 2944: The Running Chicken Nebula",
  "url":"https://apod.nasa.gov/apod/image/2304/ChickenRun_Stern_960.jpg"
  }

video(thumb=true)
"title":"M1: The Expanding Crab Nebula"
"service_version":"v1"
"thumbnail_url":"https://img.youtube.com/vi/wfzz8FUD4TM/0.jpg"
"url":"https://www.youtube.com/embed/wfzz8FUD4TM?rel=0"
"media_type":"video"
"date":"2023-03-20"
"explanation":"1111"
"copyright":"Detlef Hartmann"

*/

const String apodApiUrl = 'https://api.nasa.gov/planetary/apod';

class ApodApiData {
  final String copyright;
  final String date;
  final String explanation;
  final String hdurl;
  final String mediaType;
  final String serviceVersion;
  final String title;
  final String url;
  final String thumbnailUrl;

  ApodApiData(
      this.copyright,
      this.date,
      this.explanation,
      this.hdurl,
      this.mediaType,
      this.serviceVersion,
      this.title,
      this.url,
      this.thumbnailUrl);

/*
  ApodApiData.fromJsonWithCopyright(Map<String, dynamic> json)
      : copyright = json['copyright'],
        date = json['date'],
        explanation = json['explanation'],
        hdurl = json['hdurl'],
        mediaType = json['media_type'],
        serviceVersion = json['service_version'],
        title = json['title'],
        url = json['url'];

  ApodApiData.fromJsonWithoutCopyright(Map<String, dynamic> json)
      : copyright = '',
        date = json['date'],
        explanation = json['explanation'],
        hdurl = json['hdurl'],
        mediaType = json['media_type'],
        serviceVersion = json['service_version'],
        title = json['title'],
        url = json['url'];
*/

  Map<String, dynamic> toJson() => {
        'copyright': copyright,
        'date': date,
        'explanation': explanation,
        'hdurl': hdurl,
        'mediaType': mediaType,
        'serviceVersion': serviceVersion,
        'title': title,
        'url': url,
        'thumbnailUrl': thumbnailUrl
      };
}
