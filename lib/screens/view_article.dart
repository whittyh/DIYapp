import 'dart:convert';

import 'package:diy/models/article.dart';
import 'package:flutter/material.dart';

import 'edit_article.dart';

class ViewArticle extends StatelessWidget {
  // The ViewArticle screen is required to recieve as argument a Article object
  const ViewArticle({Key? key, required this.article}) : super(key: key);
  final Article article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text(article.name),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EditArticle(
                    article: article,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      // Allows the screen to be scrollable
      body: SingleChildScrollView(
        child: Column(
          children: [
            /* 
              If the article has any images, then display them. 
              User can select multiple images but current only the first image is display. 
              We hope to add a carosel, which user can swipe to see various images.
            */
            (article.images != null
                ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Image.memory(
                      base64Decode(article.images![0]),
                      fit: BoxFit.fill,
                    ),
                  )
                : Container()),
            if (article.description != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  children: [
                    // If the article has a selected difficulty then display it
                    if (article.difficulty != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                        child: SizedBox(
                          width: 325,
                          child: Column(
                            children: [
                              Row(children: [
                                const Text("Difficulty:    ",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                    textAlign: TextAlign.left),
                                Text(article.difficulty!,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    textAlign: TextAlign.right)
                              ]),
                              const Text(
                                  "___________________________________________________",
                                  style: TextStyle(color: Colors.blueGrey))
                            ],
                          ),
                        ),
                      ),
                    // Display the article name
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 325,
                        child: Column(
                          children: [
                            Text(article.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    height: 1.2,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25)),
                            const Text(
                                "___________________________________________________",
                                style: TextStyle(color: Colors.blueGrey))
                          ],
                        ),
                      ),
                    ),
                    //Display the article's description
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                      child: SizedBox(
                        width: 325,
                        child: Column(
                          children: [
                            Text(article.description!,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                                textAlign: TextAlign.left),
                            const Text(
                                "___________________________________________________",
                                style: TextStyle(color: Colors.blueGrey))
                          ],
                        ),
                      ),
                    ),
                    // Displays all the tools nessesary for this DIY project
                    for (int i = 0; i < article.tools!.length; i++)
                      SizedBox(
                        width: 325,
                        child: Text(
                          article.tools![i],
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                      ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                      child: Text(
                        "___________________________________________________",
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                    // Displays all the steps to complete the DIY project
                    for (int i = 0; i < article.steps!.length; i++)
                      SizedBox(
                        width: 325,
                        child: Text(
                          article.steps![i],
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                      ),
                    // Displays the tags which user enter that are relevent to this article
                    for (int i = 0; i < article.tags!.length; i++)
                      SizedBox(
                        width: 325,
                        child: Text(
                          article.tags![i],
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                      )
                  ],
                ),
              )
            else
              Container(),
          ],
        ),
      ),
    );
  }
}
