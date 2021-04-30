import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:path_provider/path_provider.dart';
//import '';

class Alternatives extends StatefulWidget {
  String productName;
  double price;
  String meatOrDairy;
  String shop;
  String productLink;

  Alternatives(Map<dynamic, dynamic> data) {
    productName = data["productName"].toString();
    price = double.parse(data["price"]);
    shop = data["shop"].toString();
    meatOrDairy = data["meatOrDairy"].toString();
    productLink = data["link"];
    print(data["oldBad"]);
  }

  @override
  createState() =>
      _AlternativesState(productName, productLink, price, shop, meatOrDairy);
}

class _AlternativesState extends State<Alternatives> {
  String productName;
  double price;
  String shop;
  List results;
  String meatOrDairy;
  String productLink;
  int score;
  bool meat;
  bool dairy;
  String message;

  _AlternativesState(String pn, String pl, double p, String s, String mord) {
    productName = pn;
    price = p;
    shop = s;
    meatOrDairy = mord;
    results = List();
    score = 0;
    productLink = pl;
    message = "";
    meat = false;
    dairy = false;
  }

  @override
  void initState() {
    super.initState();
    checkGoals();
    getAlternatives();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alternatives"),
        centerTitle: true,
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  createInfoDialogue(context);
                },
                child: Icon(Icons.info),
              )),
        ],
      ),
      body: SafeArea(
        child: Scaffold(
            body: ListView(
//                scrollDirection: Axis.vertical,
          children: <Widget>[
            goalBanner(),
            Container(
              padding: EdgeInsets.only(top: 5, left: 10),
              child: Text(
                "Chosen Item",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            oldProduct(),
            Container(
              padding: EdgeInsets.only(top: 5, left: 10),
              child: Text(
                "Alternatives for Chosen Item",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Container(
              child: FutureBuilder<dynamic>(
                future: getAlternatives(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext cntx, int index) {
                        if (index == 0) {
                          return mainOption(
                              snapshot.data[index][0],
                              snapshot.data[index][2],
                              price.toString(),
                              snapshot.data[index][1]);
                        } else {
                          return otherOptions(
                              snapshot.data[index][0],
                              snapshot.data[index][2],
                              price.toString(),
                              snapshot.data[index][1]);
                        }
                      },
                    );
                  } else {
                    return Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Container(
                            child: Center(child: CircularProgressIndicator())));
                  }
                },
              ),
//              child: ListView.builder(
//                shrinkWrap: true,
//                scrollDirection: Axis.vertical,
//                physics: NeverScrollableScrollPhysics(),
//                itemCount: results.length,
//                itemBuilder: (BuildContext cntx, int index) {
//                  if (index == 0) {
//                    return mainOption(results[index][0], results[index][2],
//                        price.toString(), results[index][1]);
//                  } else {
//                    return otherOptions(results[index][0], results[index][2],
//                        price.toString(), results[index][1]);
//                  }
//                },
//              ),
            )
          ],
        )),
      ),
    );
  }

  Future getAlternatives() async {
    List<List> res = List();
    bool albertMilk = false;
    String albertMeatAltLink =
        "https://www.ah.nl/producten/vlees-kip-vis-vega/vegetarisch-vegan-vleesvervangers?query=";
    String albertDairyAltLink =
        "https://www.ah.nl/producten/zuivel-eieren?kenmerk=dieet_veganistisch";
    String albertMilkLink =
        "https://www.ah.nl/producten/bewuste-voeding/plantaardige-dranken?sortBy=price";
    List<String> meatTerms = [
      'spek',
      'hamburger',
      'slavink',
      'chipolata',
      'worst',
      'schnitzel',
      'biefstuk',
      'shoarma',
      'filet',
      'varken',
      'burger',
      'rib',
      'schouderkarbonade',
      'ossenhaas',
      'bacon',
      'gyros',
      'ribeye',
      'kip',
      'vlees',
      'rund',
      'gehakt',
      'vis',
    ];

    List<String> dairyTerms = [
      'yoghurt',
      'kaas',
      'room',
      'zuivel',
      'cappuccino',
      'chocomel',
      'kwark',
      'skyr',
      'melk',
      'choco',
    ];

    List<String> goodTerms = [
      'soja',
      'soya',
      'kokos',
      'haver',
      'plantaardige',
      'amandel',
      'rijst',
      'vegetarische',
    ];

    if (shop.contains("albert")) {
      String term = "";
      for (String s in meatTerms) {
        if (productName.toLowerCase().contains(s)) {
          term = s;
        }
      }
      String link;
      if (term != "") {
        link = albertMeatAltLink;
      } else {
        for (String s in dairyTerms) {
          if (productName.toLowerCase().contains(s)) {
            term = s;
          }
        }
        if (term == "melk") {
          albertMilk = true;
        } else if (term == "kaas") {
          link =
              "https://www.ah.nl/zoeken?query=kaas&kenmerk=dieet_veganistisch";
        } else {
          link = albertDairyAltLink.split("?")[0] +
              "?query=" +
              term +
              "&kenmerk=dieet_veganistisch";
        }
      }
//      print("link is :" + link);
      dom.Document doc;
      if (albertMilk) {
        final response = await http.get(albertMilkLink);
        doc = parser.parse(response.body);
      } else {
        final response = await http.get(link + term + "&sortBy=price");
        doc = parser.parse(response.body);
      }

      var test = doc.querySelectorAll("a");
      for(int i = 0; i < test.length; i++){
        if(test[i].innerHtml.toString().contains("image_root__")){
          if(test[i].children.length > 0){
            var name;
            var link;
            var euro;
            var cents;
            var price;
            var amount;
            for(int j = 0; j < test[i].children.length; j++){
//              print(test[i].children[j].innerHtml);
              var tempSearch = test[i].children[j].innerHtml;
              // Get the name of the product
              if(tempSearch.contains("title=")){
//                print(tempSearch.split("title=")[1].split("\" ")[0].substring(1));
                name = tempSearch.split("title=")[1].split("\" ")[0].substring(1);
//                print(name);
              }
              if(tempSearch.contains("\" src=")){
//                print(tempSearch.split("\" src=")[1].substring(1).split(" ")[0]);
                link = tempSearch.split("\" src=")[1].substring(1).split(" ")[0];
//                print(link);
              }
              if(tempSearch.contains("class=\"price-amount_integer")){
//                print(tempSearch.split("class=\"price-amount_integer")[1].split(">")[1].split("<")[0]);
                euro = tempSearch.split("class=\"price-amount_integer")[1].split(">")[1].split("<")[0];
              }
              if(tempSearch.contains("price-amount_fractional")){
//                print(tempSearch.split("class=\"price-amount_integer")[1].split(">")[1].split("<")[0]);
                cents = tempSearch.split("price-amount_fractional")[1].split(">")[1].split("<")[0];
//                print(cents);
              }
              if(euro != null || cents != null){
                price = euro.toString() + "." + cents.toString();
//                print(price);
              }
              if(tempSearch.contains("product-unit-size")){
                amount = tempSearch.split("product-unit-size")[1].split(">")[1].split("<")[0];
//                print(amount);
              }
            }
            name = name + " " + amount;
            res.add([name, link, price]);
            name = null;
            amount = null;
            link = null;
            price = null;
          }
        }
      }
//      var elements = doc.getElementsByClassName("link_root__fmxIo");
//      for (int i = 0; i < elements.length; i++) {
//        if (elements[i].getElementsByTagName("img").length > 0) {
//          List temp = [];
//          //name of the product
//          temp.add(
//              elements[i].getElementsByTagName("img")[0].attributes['title']);
//          //amount of product
//          if (elements[i]
//                  .getElementsByClassName("price_unitSize__26KBz")
//                  .length >=
//              1) {
//            String amount = elements[i]
//                .getElementsByClassName("price_unitSize__26KBz")[0]
//                .innerHtml;
//            temp[0] = temp[0] + " (" + amount + ")";
//          }
//          //image of the product
//          temp.add(
//              elements[i].getElementsByTagName("img")[0].attributes['src']);
//          //price of the product
//          temp.add(elements[i]
//                  .getElementsByClassName("price-amount_integer__N3JDd")[0]
//                  .innerHtml +
//              "." +
//              elements[i]
//                  .getElementsByClassName("price-amount_fractional__3sfJy")[0]
//                  .innerHtml);
//          res.add(temp);
//        }
//      }
    }

    if (shop.contains("jumbo")) {
      String term = "";
      for (String s in meatTerms) {
        if (productName.toLowerCase().contains(s)) {
          term = s;
        }
      }
      if (term == "") {
        for (String s in dairyTerms) {
          if (productName.toLowerCase().contains(s)) {
            term = s;
          }
        }
      }
      print("This is the term: " + term);
      final response = await http.get(
          "https://www.jumbo.com/producten/dieetvoorkeuren/geschikt-voor-veganisten/?Ns=P_Price%7C0&searchTerms=" +
              term);
      dom.Document doc = parser.parse(response.body);

      var elements = doc.getElementsByTagName('div');
      List<String> names = [];

      for (int i = 0; i < elements.length; i++) {
        if (elements[i].className.contains("jum-product-card")) {
          List temp = ['', '', ''];
          var divs = elements[i].getElementsByTagName('div');
          for (int j = 0; j < divs.length; j++) {
            // Getting the image
            if (divs[j].className.contains("d-inline-flex align-self-start")) {
              temp[1] = divs[j]
                  .getElementsByTagName("a")[0]
                  .getElementsByTagName("img")[0]
                  .attributes['src'];
            }
            if (divs[j].className.contains("jum-product-card__content")) {
              temp[0] = divs[j].getElementsByTagName("span")[0].innerHtml;
            }
            if (divs[j].className.contains("jum-product-price d-inline-flex")) {
              var spans = divs[j].getElementsByTagName("span");
              for (int k = 0; k < spans.length; k++) {
                if (spans[k].className.contains(
                    "jum-product-price__current-price d-inline-flex align-items-start")) {
                  temp[2] = spans[k].getElementsByTagName("span")[0].innerHtml +
                      "." +
                      spans[k]
                          .getElementsByTagName("span")[1]
                          .innerHtml
                          .toString();
                }
              }
            }
            if (temp[0] != null && temp[1] != null && temp[2] != null) {
              if (temp[0].contains("&amp;")) {
                temp[0] = temp[0].split("&amp;")[0].toString() +
                    "&" +
                    temp[0].split("&amp;")[1].toString();
              }
              if (res.length == 0) {
                res.add(temp);
                names.add(temp[0]);
              } else {
                if (!names.contains(temp[0])) {
                  res.add(temp);
                  names.add(temp[0]);
                }
              }
            }
          }
        }
      }
      res.removeAt(0);
    }

    return res;
  }

  Widget mainOption(
      String optionName, String optionPrice, String price, String imageLink) {
    String message = "";
    String iconLink = "";

    if (double.parse(optionPrice) > double.parse(price)) {
      message = "This option increases your score more than normal!";
      iconLink = "assets/icons/doubleup.png";
    } else{
      message = "This option increases your score!";
      iconLink = "assets/icons/up.png";
    }

    return InkWell(
      onTap: () {
        print("Main option tapped");
        setState(() {
          if (message == "This option increases your score more than normal!") {
            score = 2;
          } else {
            score = 1;
          }
        });
        goBackWithData(
            context, [optionName, optionPrice, imageLink, meatOrDairy, score]);
      },
      child: Padding(
        padding: EdgeInsets.only(right: 10, left: 10, top: 5, bottom: 10),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.grey[350],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: Offset(1, 2),
                ),
              ]),
//        color: Colors.grey[500],
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Row(children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              "Most Popular\n Choice!",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ))),
                  ),
                  Expanded(
                    flex: 2,
                    child: Image.network(
                      imageLink,
                      height: 150,
                    ),
                  ),
                ]),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(optionName),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Text("€" + optionPrice)),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: ListTile(
                      leading: Image.asset(
                        iconLink,
                        height: 30,
                      ),
                      title: Text(message),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget otherOptions(
      String optionName, String optionPrice, String price, String imageLink) {
    String message = "";
    String iconLink = "";

    if (double.parse(optionPrice) > double.parse(price)) {
      message = "This option increases your score more than normal!";
      iconLink = "assets/icons/doubleup.png";
    } else{
      message = "This option increases your score!";
        iconLink = "assets/icons/up.png";
    }

    if (optionName == "") {
      return Container(width: 0.0, height: 0.0);
    }
    return InkWell(
      onTap: () {
        print("Option tapped");
        setState(() {
          if (message == "This option increases your score more than normal!") {
            score = 2;
          } else {
            score = 1;
          }
        });
        goBackWithData(
            context, [optionName, optionPrice, imageLink, meatOrDairy, score]);
      },
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.grey[350],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: Offset(1, 2),
                ),
              ]),
          child: ListTile(
            leading: Image.network(
              imageLink,
//          height: 10,
            ),
            title: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.white70,
                ),
                child: Padding(
                    padding: EdgeInsets.all(5), child: Text(optionName))),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 3),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.white70,
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    "€ " + optionPrice,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            trailing: Image.asset(
              iconLink,
              height: 40,
            ),
          ),
        ),
      ),
    );
  }

  Widget goalBanner() {
    if (message != "") {
      return Padding(
        padding: EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.green[200],
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Image.asset(
                    "assets/icons/goal.png",
                    height: 40,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    message,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Future<String> checkGoals() async {
    Directory d = await getApplicationDocumentsDirectory();
    File jsonFile = File(d.path + "/goals.json");
    var contents = JsonDecoder().convert(jsonFile.readAsStringSync());

    // Getting the goals that were set and checking which types
    for (Map m in contents) {
      print(m["goal"]);
      if (m["goal"].contains("meat") && m["deadline"] > 0) {
        meat = true;
      } else if (m["goal"].contains("dairy") && m["deadline"] > 0) {
        dairy = true;
      }
    }
    String m = "";
    // Checking what the current product is
    if (meatOrDairy.contains("meat") && meat) {
      m = "These items help contribute to your goal of substituting meat products!";
    } else if (meatOrDairy.contains("dairy") && dairy) {
      m = "These items help contribute to your goal of substituting dairy products!";
    }

    setState(() {
      message = m;
    });
  }

  createInfoDialogue(BuildContext c) {
    return showDialog(
        context: c,
        builder: (c) {
          return AlertDialog(
            title: Text(
              "The Sustainable Alternatives Page",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            content: Text(
              "This page shows you the alternatives to a product you selected from your shopping list.\n\n"
              "If you have set yourself any goals, this page will alert you to the fact that the alternatives bring you"
              " closer to achieving your goal.\n\nEach alternative also shows you how much your score will improve "
              "if you select it (either +1 or +2).",
              textAlign: TextAlign.justify,
            ),
            actions: <Widget>[
              FlatButton(
                child: (Text("Got It!")),
                onPressed: () {
                  Navigator.pop(c);
                },
              )
            ],
          );
        });
  }

  Widget oldProduct() {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.orange[500],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: Offset(1, 2),
                ),
              ]),
          child: ListTile(
            leading: Image.network(
              productLink,
//          height: 10,
            ),
            title: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.white70,
                ),
                child: Padding(
                    padding: EdgeInsets.all(5), child: Text(productName))),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 3),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.white70,
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    "€ " + price.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void goBackWithData(BuildContext context, List data) {
    Navigator.pop(context, data);
  }

  int getItemAmount(String name) {
    RegExp multiplier = RegExp(r"\d+\sx\s\d+");
    RegExp stukFinder = RegExp(r"\d\s(s|S)tuks*\s\d+");
    RegExp numberFinder = RegExp(r"\d+");
    print("problem: " + name);
    if (!numberFinder.hasMatch(name)) {
      return 200;
    }

    if (multiplier.hasMatch(name)) {
      print(multiplier.firstMatch(name).group(0).toString());
      var t1 = multiplier.firstMatch(name).group(0).substring(0, 1);
      var t2 = multiplier
          .firstMatch(name)
          .group(0)
          .substring(4, multiplier.firstMatch(name).group(0).length);
      int f = int.parse(t1);
      int s = int.parse(t2);
      print("This is the amount: " + (f * s).toString());
      return f * s;
    } else if (stukFinder.hasMatch(name)) {
      int t1 = int.parse(stukFinder.firstMatch(name).group(0).substring(0, 1));
      if (numberFinder
          .hasMatch(stukFinder.firstMatch(name).group(0).split(" ")[2])) {
        print("This is the amount: " +
            (t1 *
                    int.parse(numberFinder
                        .firstMatch(
                            stukFinder.firstMatch(name).group(0).split(" ")[2])
                        .group(0)))
                .toString());
        return t1 *
            int.parse(numberFinder
                .firstMatch(stukFinder.firstMatch(name).group(0).split(" ")[2])
                .group(0));
      }
      return t1 * 300;
    }

    RegExp matcher = RegExp(
        r"(\d+\s(g\d*|G\d*|l\d*|L\d*|mL|mg|ml|kg|KG))|(\d+(g\d*|G\d*|l\d*|L\d*|mL|mg|ml|kg|KG))");
//
    print("problem: " + name);

    var matches = matcher.firstMatch(name);
    var result = matches.group(0);

    RegExp letterFinder = RegExp(r"\D");
    var letterMatches = letterFinder.firstMatch(result);
    int match = 0;

    if (letterMatches != null) {
      int letterIndex = result.indexOf(letterMatches.group(0));

      String firstHalf = result.substring(0, letterIndex);
      match = int.parse(firstHalf);

      if (match < 10 && match > 0) {
        match = match * 1000;
      }

      print("This is the amount: " + match.toString());
    }

    return match;
  }
}
