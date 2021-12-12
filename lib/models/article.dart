// ignore_for_file: constant_identifier_names

class Article {
  String name;
  String? description;
  DateTime? datePosted;
  String? difficulty;
  List? tools;
  List? steps;
  List? tags;
  List? images;
  bool isPrivate = false;
  Map? privateFields;

  Article(
      {required this.name,
      this.description,
      this.datePosted,
      this.difficulty,
      this.tools,
      this.steps,
      this.tags,
      this.images,
      required this.isPrivate,
      required this.privateFields});

  Map toJson() {
    return {
      'name': name,
      'description': description,
      "datePosted": datePosted,
      "difficulty": difficulty,
      'tools': tools,
      'steps': steps,
      'tags': tags,
      'images': images,
      'isPrivate': isPrivate,
      'privateFields': privateFields
    };
  }

  factory Article.fromJson(Map<String, dynamic> map) {
    return Article(
        name: map['name'],
        description: map['description'],
        datePosted: map['datePosted'],
        difficulty: map['difficulty'],
        tools: map['tools'],
        steps: map['steps'],
        tags: map['tags'],
        images: map['images'],
        isPrivate: map['isPrivate'],
        privateFields: map['privateFields']);
  }
}
