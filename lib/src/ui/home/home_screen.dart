/*
 * @copyright : ToXSL Technologies Pvt. Ltd. < www.toxsl.com >
 * @author     : Shiv Charan Panjeta < shiv@toxsl.com >
 * All Rights Reserved.
 * Proprietary and confidential :  All information contained herein is, and remains
 * the property of ToXSL Technologies Pvt. Ltd. and its partners.
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 */

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:news_app/src/model/category/category.dart';
import 'package:news_app/src/model/topheadlinesnews/headline_response.dart';
import 'package:news_app/src/ui/home/home_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      body: BlocProvider<HomeBloc>(
        create: (context) => HomeBloc(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                WidgetTitle(),
              ],
            ),
            Expanded(
              child: WidgetLatestNews(),
            ),
            WidgetCategory(),
          ],
        ),
      ),
    );
  }
}

class WidgetTitle extends StatelessWidget {
  WidgetTitle();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Daily News app',
                style: Theme.of(context).textTheme.title.merge(
                      TextStyle(
                        color: Color(0xFF325384),
                      ),
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class WidgetCategory extends StatefulWidget {
  @override
  _WidgetCategoryState createState() => _WidgetCategoryState();
}

class _WidgetCategoryState extends State<WidgetCategory> {
  final listCategories = [
    Category('assets/images/ic_all.png', 'All'),
    Category('assets/images/ic_busiuness.png', 'Business'),
    Category('assets/images/ic_entertainment.png', 'Entertainment'),
    Category('assets/images/ic_health.png', 'Health'),
    Category('assets/images/ic_science.png', 'Science'),
    Category('assets/images/ic_sports.png', 'Sport'),
    Category('assets/images/ic_technology.png', 'Technology'),
  ];
  int indexSelectedCategory = 0;

  @override
  void initState() {
    BlocProvider.of<HomeBloc>(context).add(DataEvent(listCategories[indexSelectedCategory].title));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: ListView.builder(
        shrinkWrap: false,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          Category itemCategory = listCategories[index];
          return Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: index == listCategories.length - 1 ? 16.0 : 0.0,
            ),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      indexSelectedCategory = index;
                      BlocProvider.of<HomeBloc>(context).add(DataEvent(
                          listCategories[indexSelectedCategory].title));
                    });
                  },
                  child: Container(
                    width: 35.0,
                    height: 35.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(itemCategory.image),
                        fit: BoxFit.cover,
                      ),
                      border: indexSelectedCategory == index
                          ? Border.all(
                              color: Colors.cyan,
                              width: 2.0,
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  itemCategory.title,
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF325384),
                    fontWeight: indexSelectedCategory == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        },
        itemCount: listCategories.length,
      ),
    );
  }
}

class WidgetLatestNews extends StatefulWidget {
  WidgetLatestNews();

  @override
  _WidgetLatestNewsState createState() => _WidgetLatestNewsState();
}

class _WidgetLatestNewsState extends State<WidgetLatestNews> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        top: 8.0,
        right: 16.0,
        bottom: mediaQuery.padding.bottom + 16.0,
      ),
      child: BlocListener<HomeBloc, DataState>(
        listener: (context, state) {
          if (state is DataFailed) {
            Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        child: BlocBuilder(
          bloc: BlocProvider.of<HomeBloc>(context),
          builder: (BuildContext context, DataState state) {
            return _buildWidgetContentLatestNews(state, mediaQuery);
          },
        ),
      ),
    );
  }

  Widget _buildWidgetContentLatestNews(
      DataState state, MediaQueryData mediaQuery) {
    if (state is DataLoading) {
      return Center(
        child: Platform.isAndroid
            ? CircularProgressIndicator()
            : CupertinoActivityIndicator(),
      );
    } else if (state is DataSuccess) {
      ResponseTopHeadlinesNews data = state.data;
      return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: data.articles.length,
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemBuilder: (context, index) {
          Article itemArticle = data.articles[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipRRect(
                    child: CachedNetworkImage(
                      imageUrl: itemArticle.urlToImage != null
                          ? itemArticle.urlToImage
                          : "",
                      height: 200.0,
                      width: mediaQuery.size.width,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Platform.isAndroid
                          ? CircularProgressIndicator()
                          : CupertinoActivityIndicator(),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/img_not_found.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (await canLaunch(itemArticle.url != null
                          ? itemArticle.url
                          : "")) {
                        await launch(itemArticle.url != null
                            ? itemArticle.url
                            : "");
                      } else {
                        scaffoldState.currentState.showSnackBar(SnackBar(
                          content: Text('Could not launch news'),
                        ));
                      }
                    },
                    child: Container(
                      width: mediaQuery.size.width,
                      height: 200.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.black.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [
                            0.0,
                            0.7,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 12.0,
                          top: 12.0,
                          right: 12.0,
                        ),
                        child: Text(
                          itemArticle.title,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Html(
                  data: itemArticle.description != null ? itemArticle.description : "",
                  padding: const EdgeInsets.only(
                    left: 5.0,
                    top: 5.0,
                    right: 12.0,
                  )),
              Padding(
                padding: const EdgeInsets.only(
                  left: 5.0,
                  top: 4.0,
                  right: 5.0,
                ),
                child: Wrap(
                  children: <Widget>[
                    Icon(
                      Icons.launch,
                      color: Colors.black.withOpacity(0.8),
                      size: 12.0,
                    ),
                    SizedBox(width: 4.0),
                    Text(
                      timeAgo(DateTime.parse(itemArticle.publishedAt)),
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.8),
                        fontSize: 11.0,
                      ),
                    ),
                    SizedBox(width: 4.0),
                    Text(
                      '${itemArticle.source.name}',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.8),
                        fontSize: 11.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    } else {
      return Container();
    }
  }

  String timeAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365)
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    if (diff.inDays > 30)
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    if (diff.inDays > 7)
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    if (diff.inDays > 0)
      return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
    if (diff.inHours > 0)
      return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    return "just now";
  }
}
