import 'package:flutter/material.dart';
import 'package:flutterapp/alternatives.dart';
import 'package:flutterapp/explanation.dart';
import 'package:flutterapp/questionnaireLinks.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'sideBarNavigation.dart';
import 'dart:math';
import 'goals.dart';
import 'package:connectivity/connectivity.dart';
//import 'package:flutter/reg';
import 'package:giffy_dialog/giffy_dialog.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        highlightColor: Colors.green[800],
      ),
      home: MyHomePage(
        title: 'My List',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String debriefMessage =
      "All Group statistics such as score and substitution rates were faked for the purpose of this experiment.";
  String fileName = '/database.json';
  Directory dir;
  File data;
  bool fileExists = false;
  bool show = false;
  bool albert = false;
  Color albertColor = Colors.white;
  Color jumboColor = Colors.white;
  Color itemColor = Colors.grey;
  bool jumbo = false;
  List shoppingList = new List<Map>();
  String searchTerm = "";
//  List<Widget> searchResults = new List();
  TextEditingController controller = TextEditingController();
  Map<String, dynamic> defaultContents = {
    "couldMeat": 0,
    "couldDairy": 0,
    "didMeat": 0,
    "didDairy": 0,
    "dateInstalled": "",
    "score": [],
//    "indivMeat": 0.0,
//    "indivDairy": 0.0,
    "groupScore": [],
//    "groupMeat": 0.0,
//    "groupDairy": 0.0,
    "substitution": {"iMeat": [], "iDairy": [], "gMeat": [], "gDairy": []},
    "listsMade": 0,
    "id": "",
    "scoreConditions": {"better": 0, "worse": 0, "random": 0},
    "meatConditions": {"better": 0, "worse": 0, "random": 0},
    "dairyConditions": {"better": 0, "worse": 0, "random": 0},
    "dates": [],
    "filledOutBefore": false,
    "filledOutAfter": false,
    "gGoals": 0,
  };
  final ScrollController _scrollController = ScrollController();

  List colors = [Colors.orange, Colors.white70, Colors.lightGreen];
  final scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
//    dbDeleter();
    dbInitializer();
//    deleteList();
    storedListInitializer();
//    deleteGoals();
    goalInitializer();
    checkIfFilled(context, scaffoldKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
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
      drawer: SideBarNavigation(),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: _onBackPressed,
          child: Scaffold(
            body: Column(
              children: <Widget>[
                debriefer(context),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: albertJumboButtons(),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          width: 300,
                          color: Colors.lightGreen[100],
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: 'Search for a product in Dutch',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        color: Colors.green,
                        child: IconButton(
                          icon: Icon(Icons.search),
                          color: Colors.black,
                          onPressed: () async {
                            if (!jumbo && !albert) {
                              scaffoldKey.currentState
                                  .showSnackBar(new SnackBar(
                                content: new Text("Please Choose A Store"),
                              ));
                            } else {
                              var connected =
                                  await Connectivity().checkConnectivity();
//                              print("Connected is: " + connected.toString());
                              if (connected == ConnectivityResult.wifi ||
                                  connected == ConnectivityResult.mobile) {
//                                getProducts(controller.text);
                                setState(() {
                                  show = true;
                                  searchTerm = controller.text;
                                });
                              } else {
                                scaffoldKey.currentState.showSnackBar(SnackBar(
                                  content: Text(
                                      "Please make sure your Wifi or Cellular Data is switched on!"),
                                ));
                              }
                            }
//                          FocusScope.of(context).unfocus();
                          },
                        ),
                      ),
                    )
                  ],
                ),
//                if (show) resultsBox(context, controller.text),
                FutureBuilder(
                  future: getProducts(searchTerm),
                  builder: (context, AsyncSnapshot<dynamic> snapshot){
                    if(show){
                      if(snapshot.hasData){
                        return resultsBox(snapshot.data);
                      }
                      else{
                        return Padding(
                            padding:  EdgeInsets.only(left: 10, right: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Center(child: CircularProgressIndicator())));
                      }
                    }
                    return Container(
                      height: 0.0,
                      width: 0.0,
                    );
                  },
                ),
                Container(
                  child: Text(
                    "Shopping List",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green[50]),
                        color: Colors.lightGreen[50],
                      ),
                      child: ListView.builder(
                          itemCount: shoppingList.length,
                          itemBuilder: (BuildContext cntx, int index) {
                            return Dismissible(
                              key: ValueKey("stuff"),
                              onDismissed: (direction) {
                                setState(() {
                                  shoppingList.removeAt(index);
                                });
                                saveList();
                              },
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Container(
                                  color:
                                      colors[shoppingList[index]["rating"] + 1],
                                  child: ListTile(
                                    title: Text(shoppingList[index]
                                            ["productName"] +
                                        " €" +
                                        shoppingList[index]["price"]),
                                    leading: Image.network(
                                        shoppingList[index]["link"]),
                                    trailing: (shoppingList[index]["shop"]
                                            .toString()
                                            .contains("albert"))
                                        ? Image.asset(
                                            "assets/images/albertheijn.png")
                                        : Image.asset(
                                            "assets/images/jumbo.png"),
                                    onTap: () async {
                                      String shop = "";
//                                      print(shoppingList[index]);
                                      if (shoppingList[index]["shop"]
                                          .contains("albert")) {
                                        shop = "albert";
                                      } else {
                                        shop = "jumbo";
                                      }

                                      if (shoppingList[index]["rating"] != 0) {
                                        List result = List();
                                        if (shoppingList[index]["oldBad"] ==
                                                null &&
                                            shoppingList[index]["old"] ==
                                                null) {
//                                          print("Duh");
                                          setState(() {
                                            shoppingList[index]["oldBad"] = [
                                              shoppingList[index]
                                                  ["productName"],
                                              shoppingList[index]["price"],
                                              shoppingList[index]["link"]
                                            ];
                                            shoppingList[index]["old"] = [
                                              shoppingList[index]
                                                  ["productName"],
                                              shoppingList[index]["price"],
                                              shoppingList[index]["link"]
                                            ];
                                          });
                                          result = await goToAlternatives(
                                              context, shoppingList[index]);
                                        } else {
                                          var tempMap = shoppingList[index];
                                          // search for alternatives for original meat/dairy product
                                          tempMap["productName"] =
                                              shoppingList[index]["oldBad"][0];
                                          tempMap["price"] =
                                              shoppingList[index]["oldBad"][1];
                                          tempMap["link"] =
                                              shoppingList[index]["oldBad"][2];

//
                                          result = await goToAlternatives(
                                              context, tempMap);
                                        }

//                                        print("Result: " + result.toString());
                                        if (shoppingList[index]["rating"] ==
                                                -1 &&
                                            result != null) {
//                                          print("Alternative chosen");
                                          setState(() {
                                            shoppingList[index]["old"] = [
                                              result[0],
                                              result[1],
                                              result[2]
                                            ];
                                            shoppingList[index]["productName"] =
                                                result[0];
                                            shoppingList[index]["price"] =
                                                result[1];
                                            shoppingList[index]["link"] =
                                                result[2];
                                            shoppingList[index]["rating"] = 1;
                                            shoppingList[index]["score"] =
                                                result[result.length - 1];

                                            saveList();
                                          });
//                                          print(shoppingList[index]);

                                        } else if (result != null &&
                                            shoppingList[index]["rating"] ==
                                                1) {
//                                          print("Another Alternative Chosen");
                                          setState(() {
//                                            if (result != null) {
                                            shoppingList[index]["old"] = [
                                              result[0],
                                              result[1],
                                              result[2]
                                            ];
                                            shoppingList[index]["productName"] =
                                                result[0];
                                            shoppingList[index]["price"] =
                                                result[1];
                                            shoppingList[index]["link"] =
                                                result[2];
                                            shoppingList[index]["rating"] = 1;
                                            shoppingList[index]["score"] =
                                                result[result.length - 1];
                                            saveList();
//                                            }
                                          });
//                                          print(shoppingList[index]);
                                        } else if (result == null) {
//                                          print("Nothing chosen");
                                          setState(() {
                                            shoppingList[index]["productName"] =
                                                shoppingList[index]["old"][0];
                                            shoppingList[index]["price"] =
                                                shoppingList[index]["old"][1];
                                            shoppingList[index]["link"] =
                                                shoppingList[index]["old"][2];
                                            saveList();
                                          });
//                                          print(shoppingList[index]);
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.check),
              onPressed: () async {
                var contents = await getDBContents();
                if (contents["filledOutBefore"]) {
                  createVerificationAlert(context, scaffoldKey);
                } else {
                  createQuestionnaireAlert(context);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  checkIfFilled(BuildContext cntx, GlobalKey<ScaffoldState> k) async{
    var contents = await getDBContents();
    if (contents["filledOutBefore"]) {
      createVerificationAlert(cntx, k);
    } else {
      createQuestionnaireAlert(cntx);
    }
  }

  Future getProducts(term) async {
    List res = [];
    List<String> badTerms = [
      'kip',
      'vlees',
      'rund',
      'gehakt',
      'vis',
      'spek',
      'sausage',
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
      'yoghurt',
      'kaas',
      'room',
      'zuivel',
      'cappuccino',
      'chocomel',
      'kwark',
      'skyr',
      'chocolade',
      'chocolate',
      'melk',
      'crème',
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
      'veggie',
      'vegetarisch',
      'veggy',
      'garden gourmet',
      'plant-based',
      'plant',
      'beyond meat',
      'margarine',
      'wajang',
      'rulstukjes',
      'quorn',
      'ruig',
      'gvp',
      'vivera',
      'valess',
      'kaasschnitzel',
      'tempeh',
      'vega',
      'linzen',
      'gold & green',
      'tijmburger',
      'champignon',
      'als van',
      'gordon bleu',
      'zeesticks',
      'notenballetjes',
      'tofu',
      'krokante schnitzel',
      'italiaanse carré',
      'sofine',
      'falafel',
      'like meat',
      'moving mountains',
      'boon',
      'goodbite',
      'seitan',
      'good & green',
      'simply v',
      'well well',
      'heüra',
      'bedda',
      'fry\'s',
      'follow your heart',
      'one planet',
      'stegeman',
      'becel',
      'oatly',
    ];

    List<String> meatTerms = [
      'spek',
      'sausage',
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
      'rulstukjes',
    ];

    List<String> dairyTerms = [
      'yoghurt',
      'kaas',
      'chocolade',
      'chocolate',
      'room',
      'zuivel',
      'cappuccino',
      'chocomel',
      'kwark',
      'skyr',
      'melk',
      'soja',
      'soya',
      'drink',
    ];

    if (albert) {
      final response =
          await http.get("https://www.ah.nl/zoeken?query=" + term + "&page=10");
      dom.Document doc = parser.parse(response.body);
      // Find a way to locate the products without using permanent class names
      var test = doc.querySelectorAll("a");
      int count = 0;
      for(int i = 0; i < test.length; i++){
        if(test[i].innerHtml.toString().contains("image_root__")){
          if(count > 20) break;
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
                link = link.substring(0, link.length-1);
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
            count += 1;
            name = null;
            amount = null;
            link = null;
            price = null;
          }
        }
      }
//      for (int i = 0; i < elements.length; i++) {
//
////        print("Name: " + elements[i].className);
////        if(elements[i].className.contains("")){
////          for(int j = 0; j < elements[i].children.length; j++){
////            print(elements[i].children[j].innerHtml);
////          }
////        }
//
//        if (elements[i].getElementsByTagName("img").length > 0) {
//          List temp = [];
//
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

    if (jumbo) {
      final response = await http.get(
          "https://www.jumbo.com/zoeken?SynchronizerToken=49eff10c618cdffda76d11c18a54d91e4544273b77155ccc51659571a4c7393d&searchTerms=" +
              term);
      dom.Document doc = parser.parse(response.body);

      var elements = doc.getElementsByTagName('div');

      List<String> names = [];
      int counter = 0;
      for (int i = 0; i < elements.length; i++) {
//        print(elements[i].className);

      if(counter > 10) break;
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
            //product name
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
            if (temp[0] != null && temp[1] != null && temp[2] != null && temp[0] != "" && temp[1] != "" && temp[2] != "") {
              if (temp[0].contains("&amp;")) {
                temp[0] = temp[0].split("&amp;")[0].toString() +
                    "&" +
                    temp[0].split("&amp;")[1].toString();
              }
              if (res.length == 0) {
                res.add(temp);
                names.add(temp[0]);
                counter += 1;
              } else{
                if (!names.contains(temp[0])) {
                  res.add(temp);
                  names.add(temp[0]);
                  counter += 1;
                }
              }
            }
          }
        }
      }
    }

    List<Widget> searchResults = List();

    for (List l in res) {
      if (l[0] != "") {
        l.add(0);
        bool plant = false;
        bool animal = false;
        for (String s in badTerms) {
          if (l[0].toLowerCase().contains(s)) {
            animal = true;
          }
        }

        for (String s in goodTerms) {
          if (l[0].toLowerCase().contains(s)) {
            plant = true;
          }
        }

        if (plant && animal) {
          l[3] = 1;
        } else if (!plant && !animal) {
          l[3] = 0;
        } else if (plant) {
          l[3] = 1;
        } else if (animal) {
          l[3] = -1;
        }

        if (jumbo) {
          l.add("jumbo");
        } else {
          l.add("albertheijn");
        }

        if (meatOrDairyChecker(l[0]) == "meat") {
          l.add("meat");
        } else if (meatOrDairyChecker(l[0]) == "dairy") {
          l.add("dairy");
        } else {
          l.add("neither");
        }

        if (l[3] == 1) {
          for (String s in meatTerms) {
            if (l[0].toLowerCase().contains(s)) {
              l[5] = "good Meat";
            }
          }

          for (String s in dairyTerms) {
            if (l[0].toLowerCase().contains(s)) {
              l[5] = "good Dairy";
            }
          }
        }

        Map list = Map();
        list["productName"] = l[0];
        list["link"] = l[1];
        list["price"] = l[2];
        list["rating"] = l[3];
        list["shop"] = l[4];
        list["meatOrDairy"] = l[5];

        if (list["rating"] == 0) {
          list["score"] = 0;
        } else if (list["rating"] == 1) {
          list["score"] = 1;
        } else if (list["rating"] == -1) {
          list["score"] = 0;
        }

        searchResults.add(Card(
          color: Colors.grey[100],
          child: ListTile(
            title: Text(l[0] + " €" + l[2]),
            leading: Image.network(l[1]),
            onTap: () {
              setState(() {
                show = false;
                controller.text = "";
                shoppingList.add(list);
//                if (meatOrDairyChecker(l[0]) == "meat") {
//                  //update local couldMeat value
//                  updateDBContents("tempCouldMeat", 1);
//                } else {
//                  //update local couldDairy value
//                  updateDBContents("tempCouldDairy", 1);
//                }
//                print(shoppingList[0]);
                saveList();
              });
            },
          ),
        ));
      }
    }
    return searchResults;
  }

  List<Widget> albertJumboButtons() {
    List buttons = List<Widget>();
    RaisedButton alButton = RaisedButton(
      color: albertColor,
      child: Row(
        children: <Widget>[
          Image.asset(
            'assets/images/albertheijn.png',
            height: 50,
          ),
        ],
      ),
      onPressed: () {
        setState(() {
          albert = !albert;

          if (albert) {
            albertColor = Colors.green;
            jumboColor = Colors.white;
            if (jumbo) jumbo = false;
          } else {
            albertColor = Colors.white;
          }
//          print("AlbertHeijn is selected, albert is: " +
//              albert.toString() +
//              " jumbo is: " +
//              jumbo.toString());
        });
      },
    );
    RaisedButton juButton = RaisedButton(
      color: jumboColor,
      child: Row(
        children: <Widget>[
          Image.asset(
            'assets/images/jumbo.png',
            height: 50,
          ),
        ],
      ),
      onPressed: () {
        setState(() {
          jumbo = !jumbo;
          if (jumbo) {
//                        albert = !albert;
            jumboColor = Colors.green;
            albertColor = Colors.white;
            if (albert) albert = false;
          } else {
            jumboColor = Colors.white;
          }
//          print("Jumbo is selected, albert is: " +
//              albert.toString() +
//              " jumbo is: " +
//              jumbo.toString());
        });
      },
    );
    buttons.add(alButton);
    buttons.add(juButton);
    return buttons;
  }

  createInfoDialogue(BuildContext c) {
    return showDialog(
        context: c,
        builder: (c) {
          return AlertDialog(
            title: Text(
              "Help",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            content: Text(
              "If you need a refresher on some of the functionality of this application, "
              "head on over to the Explanations Page for a quick recap.",
              textAlign: TextAlign.justify,
            ),
            actions: <Widget>[
              FlatButton(
                child: (Text("Take Me There!")),
                onPressed: () {
                  Navigator.pop(c);
                  Navigator.push(
                      c, MaterialPageRoute(builder: (c) => Explanation()));
                },
              ),
              FlatButton(
                child: (Text("No Thanks")),
                onPressed: () {
                  Navigator.pop(c);
                },
              )
            ],
          );
        });
  }

  Future<bool> _onBackPressed() {
    setState(() {
      show = false;
    });
  }

  void dbDeleter() async {
    Directory d = await getApplicationDocumentsDirectory();
    File jsonFile = File(d.path + fileName);
//    print("exists: " + jsonFile.existsSync().toString());
    if (jsonFile.existsSync()) {
      jsonFile.deleteSync();
    }
    bool done = await dbInitializer();
//    print("exists: " + jsonFile.existsSync().toString());
    print("Database refreshed");
  }

  Future<bool> dbInitializer() async {
    Directory d = await getApplicationDocumentsDirectory();
    File jsonFile = File(d.path + fileName);
    Map tempContents = defaultContents;
    if (!jsonFile.existsSync()) {
      jsonFile.createSync();
      tempContents['dateInstalled'] =
          DateTime.now().toString().split(" ")[0].toString();
      var rng = Random();
      tempContents["id"] = rng.nextInt(10).toString() +
          rng.nextInt(10).toString() +
          rng.nextInt(10).toString() +
          rng.nextInt(10).toString() +
          rng.nextInt(10).toString();
      tempContents["gGoals"] = randomGenerator(90, 8, "more");
      File done =
          await jsonFile.writeAsString(JsonEncoder().convert(tempContents));
    } else {
      bool done = await updateDBContentsList([
        ["gGoals", randomGenerator(90, 8, "more")]
      ]);
    }
    print("Database intialized");
    return true;
  }

  void goalInitializer() async {
    Directory d = await getApplicationDocumentsDirectory();
    File jsonFile = File(d.path + "/goals.json");
    if (!jsonFile.existsSync()) {
      jsonFile.createSync();
      var contents = List();
      jsonFile.writeAsString(JsonEncoder().convert(contents));
    }
    print("Goal database initialized");
  }

  void storedListInitializer() async {
    Directory d = await getApplicationDocumentsDirectory();
    File jsonFile = File(d.path + "list");
//    Map<String, List> list = {'list': shoppingList};

    if (!jsonFile.existsSync()) {
      jsonFile.createSync();
      jsonFile.writeAsString(JsonEncoder().convert(shoppingList));
    } else {
      var sl = JsonDecoder().convert(jsonFile.readAsStringSync());
//      print(sl.runtimeType);
//      if(sl.runtimeType.toString() == "_InternalLinkedHashMap<String, dynamic>"){
//        List<dynamic> tempL = List();
//        tempL.add(sl);
//        setState(() {
//          shoppingList = tempL;
//        });
//      } else{
      setState(() {
        shoppingList = sl;
      });
//      }
    }
  }

  void saveList() async {
    Directory d = await getApplicationDocumentsDirectory();
    File jsonFile = File(d.path + "list");

    jsonFile.writeAsStringSync(JsonEncoder().convert(shoppingList));
  }

  void deleteList() async {
    Directory d = await getApplicationDocumentsDirectory();
    File jsonFile = File(d.path + "list");
    List<dynamic> temp = List<dynamic>();
    if (jsonFile.existsSync()) {
      File done = await jsonFile.writeAsString(JsonEncoder().convert(temp));
    }
  }

  void deleteGoals() async {
    Directory d = await getApplicationDocumentsDirectory();
    File jsonFile = File(d.path + "/goals.json");
//    if(!jsonFile.existsSync()){
//      jsonFile.createSync();
    var contents = List();
    jsonFile.writeAsString(JsonEncoder().convert(contents));

    print("Goals Deleted");
  }

  Widget resultsBox(List l){
//    if(show){
//      setState(() {
//        show = false;
//      });
//      return FutureBuilder<dynamic>(
//        future: getProducts(term),
//        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//          if (snapshot.hasData) {
//            print("got data");
//            return ListView.builder(
//              shrinkWrap: true,
//              scrollDirection: Axis.vertical,
//              physics: NeverScrollableScrollPhysics(),
//              itemCount: snapshot.data.length,
//              itemBuilder: (BuildContext cntx, int index) {
//                print("Length: " + snapshot.data.length.toString());
//                if (snapshot.data.length < 5 && snapshot.data.length > 0) {
//                  return Expanded(
//                    child: Container(
//                      color: Colors.grey[500],
//                      child: Scrollbar(
//                        child: ListView(
//                          children: snapshot.data,
//                        ),
//                      ),
//                    ),
//                  );
//                } else if (snapshot.data.length == 0) {
//                  print("in here");
//                  return Padding(
//                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
//                    child: Container(
//                      height: 50,
//                      decoration: BoxDecoration(
//                          color: Colors.grey[500],
//                          borderRadius: BorderRadius.all(Radius.circular(10))),
//                      child: Center(
//                          child: Text(
//                            "No items found, try another search term",
//                            style: TextStyle(color: Colors.black),
//                          )),
//                    ),
//                  );
//                } else {
//                  return Expanded(
//                    child: Container(
//                        height: 400,
//                        color: Colors.grey[500],
//                        child: Column(
//                          children: <Widget>[
//                            Expanded(
//                              child: Scrollbar(
//                                child: ListView(
////                    shrinkWrap: true,
////                    scrollDirection: Axis.vertical,
//                                  children: snapshot.data,
////                    searchResults,
//                                ),
//                              ),
//                            ),
//                            Icon(Icons.keyboard_arrow_down),
//                          ],
//                        )),
//                  );
//                }
//              },
//            );
//          } else {
//            return Padding(
//                padding: EdgeInsets.only(top: 50),
//                child:
//                Container(child: Center(child: CircularProgressIndicator())));
//          }
//        },
//      );
//    } else{
//      return Container(
//        width: 0.0,
//        height: 0.0,
//      );
//    }
//    print("Length: " + l.length.toString());
    if(l.length < 5 && l.length > 0){
      return Expanded(
        child: Container(
          color: Colors.grey[500],
          child: Scrollbar(
            child: ListView(
              children: l,
            ),
          ),
        ),
      );
    } else if (l.length == 0){
      return Padding(
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Container(
          height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[500],
              borderRadius: BorderRadius.all(Radius.circular(10))
            ),
          child: Center(child: Text("No items found, try another search term", style: TextStyle(color: Colors.black),)),
        ),
      );
    } else {
      return Expanded(
        child: Container(
                height: 400,
                color: Colors.grey[500],
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Scrollbar(
                      child: ListView(
//                    shrinkWrap: true,
//                    scrollDirection: Axis.vertical,
                        children: l,
//                    searchResults,
                      ),
                  ),
                    ),
                  Icon(Icons.keyboard_arrow_down),
                  ],
                )
              ),
      );
    }
  }

  Future<Map<dynamic, dynamic>> getDBContents() async {
    var contents;
    await getApplicationDocumentsDirectory().then((Directory d) {
      File jsonFile = File(d.path + fileName);
      contents = JsonDecoder().convert(jsonFile.readAsStringSync());
    });
    return contents;
  }

  Future<int> getDBValue(String key) async {
    var contents;
    await getApplicationDocumentsDirectory().then((Directory d) {
      File jsonFile = File(d.path + fileName);
      contents = JsonDecoder().convert(jsonFile.readAsStringSync());
    });
    return contents[key];
  }

  String getData() {
    getApplicationDocumentsDirectory().then((Directory d) {
      File jsonFile = File(d.path + fileName);
      var contents = JsonDecoder().convert(jsonFile.readAsStringSync());
      return contents.toString();
    });
  }

  Future<List> goToAlternatives(
      BuildContext context, Map<dynamic, dynamic> data) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Alternatives(data)));
    return result;
  }

  void verifyShoppingList(BuildContext c, GlobalKey<ScaffoldState> k) async {
    var done4 = await checkIfNoGoals(c);
    if (done4 is bool && done4) {
      if (shoppingList.length > 0) {
        print("VERIFYING SHOPPING LIST");

        // check if the goals are affected
        var done3 = await checkEffectOnGoals(c);

        // Tally couldWouldMeatDairy, Score and ListsMade and update database
        bool done = await calculateSaveIndivDairyMeatScoreListsMade();

        //calculate dairy and meat replacement percentage
        bool done1 = await calculateSaveCouldWouldMeatDairyIndivGroup();

        String date = DateTime.now().toString().substring(0, 10);
//        print("Resulting date: " + date);
        bool done2 = await updateDBContentsList([
          ["dates", date]
        ]);
        var done5 = await createFillAfterAlert(c);
        var contents = await getDBContents();
        int confirms = contents["listsMade"];
        k.currentState.showSnackBar(SnackBar(
          content: Text(
            "Shopping List Confirmed! You Have Confirmed $confirms Lists!",
            textAlign: TextAlign.center,
          ),
        ));
      } else {
//        Scaffold.of(c).showSnackBar(SnackBar(content: Text("Make sure your basket isn't empty!"),));
        k.currentState.showSnackBar(SnackBar(
          content: Text("Make sure your basket isn't empty!"),
        ));
      }
    }
  }

  Future<dynamic> createFillAfterAlert(BuildContext cont) async {
    var contents = await getDBContents();
    if (contents["listsMade"] >= 5 && contents["filledOutAfter"] == false) {
      return showDialog(
          barrierDismissible: false,
          context: cont,
          builder: (cont) {
            return AlertDialog(
              title: Text("Finished Experiment"),
              content: Text("You can now fill out the Second questionnaire!"),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(cont);
                    Navigator.push(
                        cont,
                        MaterialPageRoute(
                            builder: (cont) => QuestionnaireLinks()));
                  },
                  child: Text("Take Me There!"),
                )
              ],
            );
          });
    } else {
      return Container(
        width: 0.0,
        height: 0.0,
      );
    }
  }

  Future createVerificationAlert(
      BuildContext cntx, GlobalKey<ScaffoldState> k) {
    return showDialog(
//        barrierDismissible: false,
        context: cntx,
        builder: (cntx) {
          return AlertDialog(
            title: Text("Confirm Shopping List?"),
            content:
                Text("Are you sure you want to finalize your shopping list?"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(cntx);
                    verifyShoppingList(cntx, k);
                  },
                  child: Text("Yes")),
              FlatButton(
                onPressed: () {
                  Navigator.pop(cntx);
                },
                child: Text("No"),
              )
            ],
          );
        });
  }

  Future createQuestionnaireAlert(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Fill Out the First Questionnaire"),
            content: Text(
              "Please fill out the first questionnaire before beginning to use the application!",
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QuestionnaireLinks()));
                  },
                  child: Text("Take Me There")),
            ],
          );
        });
  }

  String meatOrDairyChecker(String name) {
    String answer = "";

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
      'vis'
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
      'melk'
    ];

    for (String s in meatTerms) {
      if (name.toLowerCase().contains(s)) {
        answer = "meat";
      }
    }
    for (String s in dairyTerms) {
      if (name.toLowerCase().contains(s)) {
        answer = "dairy";
      }
    }
//    print("Its: " + answer);
    return answer;
  }

  Future<bool> updateDBContents(String tag, int value) async {
    Directory d = await getApplicationDocumentsDirectory();
    File jsonFile = File(d.path + fileName);
    var contents = JsonDecoder().convert(jsonFile.readAsStringSync());

    if (contents[tag] >= 0) {
//      print("Current value: " + contents[tag].toString());
      int updatedValue = contents[tag] + value;
      contents[tag] = updatedValue;
//      print("Updated value: " + contents[tag].toString());
//      print(JsonDecoder().convert(jsonFile.readAsStringSync()));
      jsonFile.writeAsString(JsonEncoder().convert(contents)).then((_) {
//        print("Finished Updating");
        print(JsonDecoder().convert(jsonFile.readAsStringSync()));
        return true;
      });
    }
  }

  Future<bool> updateDBContentsList(List<dynamic> args) async {
    Directory d = await getApplicationDocumentsDirectory();
    File jsonFile = File(d.path + fileName);
    List lists = ["score", "groupScore", "dates"];
    List conditions = ["meatConditions", "dairyConditions", "scoreConditions"];

    var contents = JsonDecoder().convert(jsonFile.readAsStringSync());
    var oldContents = contents;
    for (List l in args) {
      if (lists.contains(l[0])) {
        contents[l[0]].add(l[1]);
      } else if (conditions.contains(l[0])) {
        contents[l[0]][l[1]] += 1;
      } else if (l[0].contains("gGoals")) {
        contents[l[0]] = l[1];
      } else {
        if (contents[l[0]] >= 0) {
          int updatedValue = contents[l[0]] + l[1];
          contents[l[0]] = updatedValue;
        }
      }
    }

//    print("OLD: " + oldContents.toString());
    File done = await jsonFile.writeAsString(JsonEncoder().convert(contents));
//    print("NEW: " +
//        JsonDecoder().convert(jsonFile.readAsStringSync()).toString());
//    print("Finished Updating");
//    jsonFile.writeAsString(JsonEncoder().convert(contents)).then((_) {
//      print("NEW: " + JsonDecoder().convert(jsonFile.readAsStringSync()));
//      print("Finished Updating");
//    });

//    if (contents[tag] >= 0) {
////      print("Current value: " + contents[tag].toString());
//      int updatedValue = contents[tag] + value;
//      contents[tag] = updatedValue;
////      print("Updated value: " + contents[tag].toString());
////      print(JsonDecoder().convert(jsonFile.readAsStringSync()));
//      jsonFile.writeAsString(JsonEncoder().convert(contents)).then((_) {
//        print("Finished Updating");
//        print(JsonDecoder().convert(jsonFile.readAsStringSync()));
//      });
//    }
    return true;
  }

  Future<bool> setDBContents(Map args) async {
    Directory d = await getApplicationDocumentsDirectory();
    File jsonFile = File(d.path + fileName);
    var contents = JsonDecoder().convert(jsonFile.readAsStringSync());

//    for (List l in args) {
//      var updatedValue = l[1];
//      contents[l[0]] = updatedValue;
//    }
    List k = args.keys.toList();
    for (String s in k) {
      contents["substitution"][s].add(args[s]);
    }

//      print("Current value: " + contents[tag].toString());

//      print("Updated value: " + contents[tag].toString());
//      print(JsonDecoder().convert(jsonFile.readAsStringSync()));
    File done = await jsonFile.writeAsString(JsonEncoder().convert(contents));

//    print(JsonDecoder().convert(jsonFile.readAsStringSync()));
//    print("Finished setting values");

    return true;
  }

  Future<int> generateGroupScore() async {
    Map<dynamic, dynamic> data = await getDBContents();
    var scores = data["score"];
    var _conditions = data["scoreConditions"];
    var rng = Random();
    int listsMade = data["listsMade"];
    Map maxes = {"better": 2, "worse": 2, "random": 1};

    int groupS = 0;
    int current = 0;
    if (scores.length == 0) {
      current = 0;
    } else {
      current = scores[scores.length - 1];
    }

//    for(int i = 0; i < scores.length; i++){
    List keys = _conditions.keys.toList();
    String cond = keys[rng.nextInt(keys.length)];

//    print("Lists made " + listsMade.toString());

    if (listsMade < 5) {
      while (_conditions[cond] >= maxes[cond]) {
//        print("Length: " + keys.length.toString());
        cond = keys[rng.nextInt(keys.length)];
//        print("Condition: " + cond.toString());
      }

      if (cond == "better" && _conditions[cond] < maxes[cond]) {
        groupS = randomGenerator(current + 4, current + 1, "more");
      } else if (cond == "worse" && _conditions[cond] < maxes[cond]) {
        if (current > 1 && current < 5) {
          groupS = randomGenerator(current - 1, 0, "less");
        } else if (current <= 1) {
          groupS = randomGenerator(6, 1, "more");
        } else {
          groupS = randomGenerator(current - 1 + 4, current, "less");
        }
      } else if (cond == "random" && _conditions[cond] < maxes[cond]) {
        groupS = current;
      }

      List dumb = List();
      dumb.add(["scoreConditions", cond]);
      bool poop = await updateDBContentsList(dumb);
    }
    return groupS;
  }

  int randomGenerator(int max, int min, String condition) {
    var rn = Random();
    if (condition == "more") {
      return min + rn.nextInt(max - min);
    } else if (condition == "less") {
      return min - rn.nextInt(max - min);
    }
  }

  Future<bool> calculateSaveIndivDairyMeatScoreListsMade() async {
    Map args = {};
    args["didDairy"] = 0;
    args["didMeat"] = 0;
    args["couldDairy"] = 0;
    args["couldMeat"] = 0;
    int localPos = 0;
    int localNeg = 0;

    for (Map l in shoppingList) {
//      print(l.toString());
      if (l["rating"] == 1 && l["meatOrDairy"] == "meat") {
        args["didMeat"] += 1;
        args["couldMeat"] += 1;
      } else if (l["rating"] == 1 && l["meatOrDairy"] == "dairy") {
        args["didDairy"] += 1;
        args["couldDairy"] += 1;
      } else if (l["rating"] == -1 && l["meatOrDairy"] == "meat") {
        args["couldMeat"] += 1;
      } else if (l["rating"] == -1 && l["meatOrDairy"] == "dairy") {
        args["couldDairy"] += 1;
      }

      if (l["rating"] == 1) {
        localPos += l["score"];
      } else if (l["rating"] == -1) {
        localNeg += 1;
      }
    }

    int net = localPos - localNeg;
    if (net <= 0) net = 0;
    List data = List();
    args.forEach((k, v) => data.add([k, v]));
//    print("data is type: " + data.runtimeType.toString());
    data.add(["listsMade", 1]);
    data.add(["score", net]);

    // generate group Score
    var groupScore = await generateGroupScore();
    data.add(["groupScore", groupScore]);

    // update the database
    bool done = await updateDBContentsList(data);

    return done;
  }

  Future<bool> calculateSaveCouldWouldMeatDairyIndivGroup() async {
    var contents = await getDBContents();
    Map args = Map();
    var _meatConditions = contents["meatConditions"];
    var _dairyConditions = contents["dairyConditions"];
    Map maxes = {"better": 2, "worse": 2, "random": 1};
    bool meatNotNull = false;
    bool dairyNotNull = false;
    double dairyRatio;
    double meatRatio;

    if (contents["couldDairy"] > 0) {
      dairyRatio = contents["didDairy"] / contents["couldDairy"];
      dairyRatio = double.parse(dairyRatio.toStringAsPrecision(2));
//      print("Dairy Ratio: " + dairyRatio.toString());
      dairyNotNull = true;
    } else {
      dairyRatio = 0.0;
    }

    if (contents["couldMeat"] > 0) {
      meatRatio = contents["didMeat"] / contents["couldMeat"];
      meatRatio = double.parse(meatRatio.toStringAsPrecision(2));
//      print("Meat Ratio: " + meatRatio.toString());
      meatNotNull = true;
    } else {
      meatRatio = 0.0;
    }

    var rng = Random();
    double groupMeat = 0.0;
    double groupDairy = 0.0;

    if (contents["listsMade"] < 6) {
      // first meat
      List keys = _meatConditions.keys.toList();
      String cond = keys[rng.nextInt(keys.length)];

      while (_meatConditions[cond] >= maxes[cond]) {
//        print("Length: " + keys.length.toString());
        cond = keys[rng.nextInt(keys.length)];
//        print("Condition: " + cond.toString());
      }

      if (meatNotNull) {
        if (cond == "better" && _meatConditions[cond] < maxes[cond]) {
          groupMeat = randomRatioGenerator(meatRatio, "better");
        } else if (cond == "worse" && _meatConditions[cond] < maxes[cond]) {
          groupMeat = randomRatioGenerator(meatRatio, "worse");
        } else if (cond == "random" && _meatConditions[cond] < maxes[cond]) {
          groupMeat = meatRatio;
        }
      } else {
        groupMeat = (Random().nextInt(8) + 1) / 10;
      }

      bool poop = await updateDBContentsList([
        ["meatConditions", cond]
      ]);

      // now dairy

      keys = _dairyConditions.keys.toList();
      String cond2 = keys[rng.nextInt(keys.length)];
      while (_dairyConditions[cond2] >= maxes[cond2]) {
//        print("Length: " + keys.length.toString());
        cond2 = keys[rng.nextInt(keys.length)];
//        print("Condition: " + cond2.toString());
      }

      if (dairyNotNull) {
        if (cond2 == "better" && _dairyConditions[cond2] < maxes[cond2]) {
          groupDairy = randomRatioGenerator(dairyRatio, "better");
        } else if (cond2 == "worse" && _dairyConditions[cond2] < maxes[cond2]) {
          groupDairy = randomRatioGenerator(dairyRatio, "worse");
//          if (groupDairy > 0.1 && groupDairy < 0.4) {
//            return randomRatioGenerator(current, "less");
//          } else if (groupDairy <= 0.1) {
//            return 0;
//          } else {
//            return randomGenerator(groupDairy - 0.1 + 0.4,"less");
//          }
        } else if (cond2 == "random" &&
            _dairyConditions[cond2] < maxes[cond2]) {
          groupDairy = dairyRatio;
        }
      } else {
        groupDairy = (Random().nextInt(8) + 1) / 10;
      }
      bool poop2 = await updateDBContentsList([
        ["dairyConditions", cond2]
      ]);
    } else {
      groupDairy = randomGenerator(80, 15, "more") / 100;
      groupMeat = randomGenerator(80, 15, "more") / 100;
    }

//    if (meatNotNull) args.add(["indivMeat", meatRatio]);
    if (meatNotNull) {
      args["iMeat"] = meatRatio;
    } else {
      args["iMeat"] = 0.0;
    }
//    if (dairyNotNull) args.add(["indivDairy", dairyRatio]);
    if (meatNotNull) {
      args["iDairy"] = dairyRatio;
    } else {
      args["iDairy"] = 0.0;
    }

    args["gMeat"] = groupMeat;
    args["gDairy"] = groupDairy;

    bool done = await setDBContents(args);
    return done;
  }

  double randomRatioGenerator(double current, String condition) {
//    print("Random Ratio Generator: \n");
//    print("Current: " + current.toString());
    var difference = 1 - current;
    double choice = 0.0;

    if (current == 0.0 && condition == "worse") {
      return 0.0;
    } else if (current == 0 && condition == "better") {
      return randomGenerator(45, 12, "more") / 100;
    }

    if (difference >= 0.5) {
      choice = (difference / 2) + (Random().nextInt(5) / 100) + 0.01;
    } else {
      choice = (difference / 2) - (Random().nextInt(5) / 100) - 0.01;
    }
//    print("Choice: " + choice.toString());

    if (condition.contains("better")) {
//      print("Returned Group Meat as: " + (current + choice).toString());
      return current + choice;
    } else if (condition.contains("worse")) {
      return current - choice;
    } else if (condition.contains("random")) {
      return current;
    }
  }

  Future checkEffectOnGoals(BuildContext context) async {
    // get list of goals
    List goals = await getGoals();
    List actualGoals = List();
    bool alreadyMeat = false;
    bool alreadyDairy = false;
    int goodMeat = 0;
    int goodDairy = 0;
    int failedGoals = 0;
    int finishedGoals = 0;

    // Look for just one goal for meat and one goal for dairy that are active
    for (Map l in goals) {
      if (l["goal"] == "meat" && l["deadline"] > 0) {
        if (!alreadyMeat) {
          actualGoals.add(l);
          alreadyMeat = true;
        }
      } else if (l["goal"] == "dairy" && l["deadline"] > 0) {
        if (!alreadyDairy) {
          actualGoals.add(l);
          alreadyDairy = true;
        }
      } else if (l["deadline"] == 0) {
        finishedGoals += 1;
      }
    }

    print("Finished Goals: " + finishedGoals.toString());

    for (int i = 0; i < actualGoals.length; i++) {
      goals.remove(actualGoals[i]);
    }

    print("Actual goals: " + actualGoals.toString());

    // Check if there are any products that affect possible goals
    for (Map m in shoppingList) {
      if (m["rating"] == 1) {
//        print(m);
        if (m["meatOrDairy"].contains("meat") ||
            m["meatOrDairy"].contains("Meat")) {
          goodMeat = goodMeat + 1;
        } else if (m["meatOrDairy"].contains("dairy") ||
            m["meatOrDairy"].contains("Dairy")) {
          goodDairy = goodDairy + 1;
        }
      }
    }

    int secondCheck = 0;
    print("Good Meat: " + goodMeat.toString());

    for (int i = 0; i < actualGoals.length; i++) {
      if (actualGoals[i]["goal"].contains("meat")) {
        actualGoals[i]["progress"] = actualGoals[i]["progress"] + goodMeat;
      } else if (actualGoals[i]["goal"].contains("dairy")) {
        actualGoals[i]["progress"] = actualGoals[i]["progress"] + goodDairy;
      }
      actualGoals[i]["deadline"] = actualGoals[i]["deadline"] - 1;
      print("Deadline: " + actualGoals[i]["deadline"].toString());
      //Checking if a goal was completed with the current list

      if (actualGoals[i]["deadline"] >= 0 &&
          (actualGoals[i]["progress"] / actualGoals[i]["amount"]) ==
              1.00) {
        actualGoals[i]["result"] = "passed";
        secondCheck += 1;
      } else if (actualGoals[i]["deadline"] == 0 &&
          (actualGoals[i]["progress"] / actualGoals[i]["amount"]) < 1) {
        actualGoals[i]["result"] = "failed";
        failedGoals += 1;
      }
    }

    print("Updated Actual goals: " + actualGoals.toString());

    List n = actualGoals + goals;

    // Updating database of goals
    Directory d = await getApplicationDocumentsDirectory();
    File jsonFile = File(d.path + "/goals.json");
    jsonFile.writeAsStringSync(JsonEncoder().convert(n));
    print("UPDATED GOAL DATABASE WITH SHOPPING LIST");

    if (secondCheck > 0) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Goal Completed!"),
              content: Image.asset('assets/images/earth_spinning.gif'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Goals()));
                    },
                    child: Text("Take me to the Goals Page!")),
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("No Thanks")),
              ],
            );
          });
    } else if (failedGoals > 0) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Goal Failed!"),
              content: Image.asset('assets/images/earth_burning.gif'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Goals()));
                    },
                    child: Text("Take me to the Goals Page!")),
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("No Thanks")),
              ],
            );
          });
    }
  }

  Future<List> getGoals() async {
    Directory d = await getApplicationDocumentsDirectory();
    File jsonFile = File(d.path + "/goals.json");

    List contents = JsonDecoder().convert(jsonFile.readAsStringSync());
//    print("Type: " + contents.runtimeType.toString());
    return contents;
  }

  Future<dynamic> checkIfNoGoals(BuildContext context) async {
    List goals = await getGoals();
    Map m = await getDBContents();
    if (goals.length == 0 && m["listsMade"] > 1) {
      var alert = showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("No Goals Yet?"),
              content: Text(
                  "If you haven't set yourself a goal yet, head on over to the Goals page to do so!"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Take me to the Goals page!"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Goals()));
                  },
                ),
              ],
            );
          });
      return alert;
    } else {
      return true;
    }
  }

  FutureBuilder debriefer(BuildContext cntx) {
    return FutureBuilder(
      future: getDBContents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data != null && snapshot.data["filledOutAfter"]) {
            return GestureDetector(
              onHorizontalDragEnd: (e) {
                showDialog(
                    context: cntx,
                    builder: (cntx) {
                      return AlertDialog(
                        title: Text("Dismiss?"),
                        content:
                            Text("Would you like to dismiss this message?"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("Yes"),
                            onPressed: () {
                              setState(() {
                                debriefMessage = "";
                                Navigator.pop(cntx);
                              });
                            },
                          ),
                          FlatButton(
                            child: Text("No"),
                            onPressed: () {
                              Navigator.pop(cntx);
                            },
                          )
                        ],
                      );
                    });
              },
              child: Container(
                padding:
                    EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
                width: (debriefMessage == "") ? 0.0 : 400,
                height: (debriefMessage == "") ? 0.0 : 80,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      debriefMessage.toString(),
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    )),
              ),
            );
          } else {
            return Container(
              width: 0.0,
              height: 0.0,
            );
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
