import 'dart:convert';

import 'package:diy/models/article.dart';
import 'package:flutter/material.dart';

class ViewArticle extends StatelessWidget {
  const ViewArticle({Key? key, required this.article}) : super(key: key);
  final Article article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text(article.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                    if (article.difficulty != null)
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                          child: SizedBox(
                              width: 325,
                              child: Column(children: [
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
                              ]))),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            width: 325,
                            child: Column(children: [
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
                            ]))),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                        child: SizedBox(
                            width: 325,
                            child: Column(children: [
                              Text(article.description!,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                  textAlign: TextAlign.left),
                              const Text(
                                  "___________________________________________________",
                                  style: TextStyle(color: Colors.blueGrey))
                            ]))),
                    for (int i = 0; i < article.tools!.length; i++)
                      SizedBox(
                        width: 325,
                        child: Text(article.tools![i],
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20)),
                      ),
                    const Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                        child: Text(
                            "___________________________________________________",
                            style: TextStyle(color: Colors.blueGrey))),
                    for (int i = 0; i < article.steps!.length; i++)
                      SizedBox(
                        width: 325,
                        child: Text(article.steps![i],
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20)),
                      ),
                    for (int i = 0; i < article.tags!.length; i++)
                      SizedBox(
                        width: 325,
                        child: Text(article.tags![i],
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20)),
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
