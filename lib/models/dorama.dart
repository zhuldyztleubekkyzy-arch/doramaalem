class Dorama {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String genre;
  final int year;
  final double rating;
  final int episodeCount;
  final String country;
  final DateTime createdAt;
  final DateTime updatedAt;

  Dorama({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.genre,
    required this.year,
    required this.rating,
    required this.episodeCount,
    required this.country,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Dorama.fromJson(Map<String, dynamic> json) {
    return Dorama(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      genre: json['genre'] as String,
      year: json['year'] as int,
      rating: (json['rating'] as num).toDouble(),
      episodeCount: json['episode_count'] as int,
      country: json['country'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'genre': genre,
      'year': year,
      'rating': rating,
      'episode_count': episodeCount,
      'country': country,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

