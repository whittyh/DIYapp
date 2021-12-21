// ignore_for_file: constant_identifier_names
/*
  This is a class that represent that diffent fields an article can have
  The only required parameters is the name, whether the article is private/puiblic, and 
  a Map that specify which fields (e.g description, tools , etc) are private.
*/
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

  /* 
    This function convert the Article object to Json object.
    This is nessesary when storing the article onto the users @asign.
  */
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

  /* 
    This function convert the Json object to an Article object.
    This is useful when retrieving the article from the user's @sign.
    It is required that a Map is passed as argument.
  */
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
