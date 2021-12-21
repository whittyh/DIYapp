import 'package:diy/models/article.dart';
import 'package:diy/screens/view_article.dart';
import 'package:flutter/material.dart';

class ArticleCard extends StatelessWidget {
  /*
   This is the widget that displays some basic information to the screen about the article. 
   This widget is used in the HomeScreen and SearchScreen.
   This widget requires an Article object as argument.
  */
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
        /*
         Whenever the user taps on this widget, then they are navigated to the ViewArticle Screen.
         The ViewArticle Scren will provide/display more information about the given article. 
        */
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
          child: Column(
            children: [
              //Displays the name of the Article
              Text(
                article.name,
                textAlign: TextAlign.center,
                style: (const TextStyle(
                    color: Colors.white, fontSize: 26, height: 1.5)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  article.description!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              // If the given article has a difficulty, then display it to the
              (article.difficulty != null
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            const TextSpan(
                                text: "Difficulty: ",
                                style: TextStyle(color: Colors.white)),
                            TextSpan(
                                text: article.difficulty!,
                                style: const TextStyle(color: Colors.white))
                          ],
                        ),
                      ),
                    )
                  : Container()),
            ],
          ),
        ),
      ),
    );
  }
}
