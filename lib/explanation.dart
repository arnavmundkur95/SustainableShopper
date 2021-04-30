import 'package:flutter/material.dart';

class Explanation extends StatelessWidget {


  List data = [

    ["Search Function", "assets/images/searchBar.jpeg", "This allows you to add items to your cart. Simply choose a store by clicking "
        "one of the buttons pertaining to a store, then enter your search term and hit the search icon. The search function works best when"
        "the search term is entered in Dutch and not English. Using the English term will yield some results but may not locate the item you"
        "would expect to find. \n\nTo add an item, simply press on the resulting items from the search to add it to your basket. ", 150],

    ["Color Coding", "assets/images/ratings.jpeg", "Orange: represents a product with sustainable alternatives available. If no "
        "action is taken, the user's score decreases by 1 point.\n\n"
        "No Color: this product has no sustainable alternatives available. \n\n"
        "Green: This product is a sustainable alternative and increases your score.", 100],

    ["Removing Items from your List", "assets/images/swipe.jpeg", "To remove a product from your list, simply swipe it off to either "
        "side of the screen.", 180],

    ["Verifying Shopping Basket", "assets/images/verify.jpeg", "Verifying your shopping list allows the score to be calculated for the basket "
        " and your Performance Overview to be updated. In addition the feature updates your progress on goals you set. \n\nIn order to verify "
        "your basket, simply press the check-mark button at the bottom of the main page. ", 100],

    ["Alternatives", "assets/images/alternatives.jpeg", "The Alternatives page is found by pressing on an item in your shopping basket that "
        "is colored either orange or green. The Alternatives page shows you sustainable alternatives for the item you selected. \n\n"
        "The page shows you which of the alternatives are popular among other users and allows you to replace the selected item with a chosen "
        "alternative simply by tapping on the alternative. \n\nIn addition, a banner on the top of the page will appear if the alternative on the"
        " page help you achieve a certain goal you set yourself.", 200],

    ["Score", "assets/icons/doubleup.png", "The score is determined by whether or not a sustainable alternative is purchased. "
        "If you do not choose a sustainable alternative to an item color-coded as orange, then the score for your current "
        "basket reduces by 1. \n\nIf you choose an alternative that is equal to or cheaper than the original product, your score increases "
        "by 1. If you purchase a sustainable alternative that is more expensive than your original product, then your score increases by 2.", 100],

    ["Goals", "assets/images/goal.png", "The Goal Setting feature can be located on the \"Goals\" page and allows you to set your own purchasing goal"
        " to guide your purchases. \n\nThe feature allows you to set the type of item you would like to substitute (meat or dairy), how many products "
        "you aim to substitute and the number of shopping trips over which you would like to accomplish the goal.", 100],

    ["Goal Overview", "assets/images/goalOverview.jpeg", "The Goals page gives you an overview of current goals and previous goals. "
        "You can keep track of your progress by observing the progress bar under each active goal as well as see how many shopping trips "
        "you have left until the deadline for the goal is reached, and see how many substitutes you need to purchase to meet your goal. "
        "\n\nIn the \"Expired Goals\" block, you can see the old goals that you set yourself and whether or not you completed them. ", 150],

    ["Performance Overview", "assets/images/progressoverview.jpeg", "The Performance Overview Page allows you to view your performance with "
        "regards to your score for each shopping trip, as well as the meat and dairy alternative substitution rates of each of your baskets. "
        "It also keeps you up to date with your goal completion rate and informs you of the group's goal completion rate too. ", 150],

    ["Questionnaire Links", "assets/images/questionnairelinks.jpeg", "This page has links to the two questionnaires that you are asked to fill out "
        "as part of this experiment. In order to get to the questionnaire, simply tap the respective button. Your Unique ID is given with an option"
        " for you to copy it to your clipboard in order to easily enter it in the questionnaire.\n\nThis page also has a link to submit your email address"
        " if you would like to be interviewed about your experiences with the application.", 200],

  ];


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Explanation"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: data.length,
          itemBuilder: (BuildContext context, int i){
          return explanation(data[i]);
        },
        ),
      ),
    );
  }

  Widget explanation(List l) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.grey[500],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 3,
                offset: Offset(1, 2),
              ),
            ]),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(l[0],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.grey[200],
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Image(
                        height: double.parse(l[3].toString()),
                        image: AssetImage(l[1]),
                      ),
                    ),
                    Container(
                      child: Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                          child: Text(l[2], textAlign: TextAlign.justify)),
                    )
                  ],
                ),
              ),
            ],
          )
        ),
      ),
    );
  }


}
