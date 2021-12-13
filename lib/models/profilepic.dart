class ProfilePic {
  List? images;
  bool isPrivate = false;

  ProfilePic({this.images, required this.isPrivate});

  Map toJson() {
    return {
      'images': images,
      'isPrivate': isPrivate,
    };
  }

  factory ProfilePic.fromJson(Map<String, dynamic> map) {
    return ProfilePic(images: map['images'], isPrivate: map['isPrivate']);
  }
}
