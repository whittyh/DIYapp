import 'package:diy/models/article.dart';
import 'package:diy/screens/view_article.dart';
import 'package:flutter/material.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    Key? key,
    required this.article,
  }) : super(key: key);

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
          onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewArticle(
                      article: article,
                    ),
                  ),
                ),
              },
          child: Card(
              elevation: 0,
              color: Colors.grey[850],
              child: Column(children: [
                Text(article.name,
                    textAlign: TextAlign.center,
                    style: (const TextStyle(
                        color: Colors.white, fontSize: 26, height: 1.5))),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(article.description!,
                        style: const TextStyle(color: Colors.white))),
                (article.difficulty != null
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                          const TextSpan(
                              text: "Difficulty: ",
                              style: TextStyle(color: Colors.white)),
                          TextSpan(
                              text: article.difficulty!,
                              style: const TextStyle(color: Colors.white))
                        ])))
                    : Container()),
              ]))),
    );
  }
}
