import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class Goals extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Goals();
}

class _Goals extends State<Goals> {
  List<dynamic> goals = List<dynamic>();
  List<dynamic> oldGoals = List<dynamic>();
  bool chosenMeat = false;
  bool chosenDairy = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getGoals();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("My Goals"),
          centerTitle: true,
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    
                    createInfoDialogue(context);
                  },
                  child: Icon(
                      Icons.info
                  ),
                )
            ),
          ],
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 5, right: 5, top: 10),
              child: Container(
                height: double.parse((goals.length * 130 + 30).toString()),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text("Active Goals", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),)
                    ),
                    goalBody(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5, right: 5, top: 10),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        child: Text("Expired Goals", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),)),
                    oldGoalsBody(),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            setNewGoal(context);
          },
        ),
      ),
    );
  }

  createInfoDialogue(BuildContext c){
    return showDialog(context: c, builder: (c){
      return AlertDialog(
        title: Text("The Goal Setting Page"),
        content: Text("This page allows you to set yourself meat/dairy substitution goals.\n\nYou can choose:\n\n - The type of food to substitute"
            "  \n\n - The number of items you would like to substitute \n\n - The number of shopping trips within which you want to achieve"
            " this goal.", textAlign: TextAlign.justify,),
        actions: <Widget>[
          FlatButton(
            child: (Text("Got It!")),
            onPressed: (){
              Navigator.pop(c);
            },
          )
        ],
      );
    });
  }

  Widget goalBody() {
    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: goals.length,
        itemBuilder: (context, index) {
          return goalDisplay(goals[index]);
        });
  }

  Widget oldGoalsBody(){
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
        itemCount: oldGoals.length,
        itemBuilder: (context, index) {
          return oldGoalDisplay(oldGoals[index]);
        });
  }

  Widget oldGoalDisplay(Map m){
    Color c;
    String progress;

    if (m["progress"] < m["amount"]){
      progress = ((m["progress"] / m["amount"]) * 100).toString();
    } else{
      progress = "100";
    }

    if(m["result"].contains("passed")){
      c = Colors.green[200];
    }else{
      c = Colors.red[200];
    }

    String sub = "";
    if (m["amount"] > 1) {
      sub = " substitutes";
    } else {
      sub = " substitute";
    }

    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom:5),
      child: Container(
//        color: c,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 10),
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: "Purchase ",
                  style: TextStyle(fontSize: 17, color: Colors.black)),
              TextSpan(
                  text: m["amount"].toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 17)),
              TextSpan(
                  text: " " + m["goal"].toString().split(" ")[0] + sub,
                  style: TextStyle(fontSize: 17, color: Colors.black)),
              TextSpan(text: " (Achieved: " + double.parse(progress).round().toString() + "%)", style: TextStyle(fontSize: 17, color: Colors.black)),
            ]
            ),
          ),
        ),
      ),
    );
  }

  Widget goalDisplay(Map m) {
    String sub = "";
    if (m["amount"] > 1) {
      sub = " substitutes";
    } else {
      sub = " substitute";
    }

    print("Progress: " + (m["progress"] / m["amount"]).toString());
    print("Amount: " + m["amount"].toString());
    print("Done: " + m["progress"].toString());

    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.grey[200],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(1, 2),
              ),
            ]),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: "Purchase ",
                      style: TextStyle(fontSize: 17, color: Colors.black)),
                  TextSpan(
                      text: m["amount"].toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17)),
                  TextSpan(
                      text: " " + m["goal"].toString().split(" ")[0] + sub,
                      style: TextStyle(fontSize: 17, color: Colors.black))
                ]),
              ),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 5, bottom: 10, top: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Padding(
                        padding: EdgeInsets.only(top: 5, left: 10, bottom: 10),
                        child: Text(
                          "Progress: ",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: SizedBox(
                    width: 220,
                    height: 15,
                    child: LinearProgressIndicator(
                      value: m["progress"] / m["amount"],
                      backgroundColor: Colors.amber,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(top: 3, bottom: 3, left: 5),
                          child: Text("Deadline: ", style: TextStyle(fontWeight: FontWeight.bold),)
                      ),
                      Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(getDeadline(m["deadline"]), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontStyle: FontStyle.italic),)),
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }

  setNewGoal(BuildContext context) {
    // Make a pop up menu
    String dateMade = DateTime.now().toString();
    String goal = "";
    chosenDairy = false;
    chosenMeat = false;
    int goalCompletion = 0;
    int numberOfProducts = 0;
    bool choice1 = false;
    bool choice2 = false;
    bool choice3 = false;

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Set a New Goal", textAlign: TextAlign.center),
                content: SingleChildScrollView(
                  child: Container(
                    height: 350,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      "Goal: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 5),
                                    child: FlatButton(
                                      color: (chosenMeat)
                                          ? Colors.green
                                          : Colors.grey,
                                      child: Text(
                                        "Less Meat",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () {
                                        goal = "meat";
                                        setState(() {
                                          chosenMeat = true;
                                          chosenDairy = false;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 5),
                                    child: FlatButton(
                                      child: Text(
                                        "Less Dairy",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color: (chosenDairy)
                                          ? Colors.green
                                          : Colors.grey,
                                      onPressed: () {
                                        goal = "dairy";
                                        setState(() {
                                          chosenMeat = false;
                                          chosenDairy = true;
//                                    print(chosenDairy);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5, right: 5, top: 5),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Number of substitutes:",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  )),
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  width: 80,
                                  height: 20,
                                  child: TextField(
                                    decoration: InputDecoration(
                                        hintText: "Enter a number here!",
                                        hintStyle: TextStyle(fontSize: 15)),
                                    keyboardType: TextInputType.number,
                                    onChanged: (String input) {
                                      numberOfProducts = int.parse(input);
                                      print("number is: " +
                                          numberOfProducts.toString());
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5, left: 5, right: 5),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Deadline: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    FlatButton(
                                      color:
                                          choice1 ? Colors.green : Colors.grey,
                                      child: Text(
                                        "Next Trip",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () {
                                        goalCompletion = 1;
                                        setState(() {
                                          choice1 = true;
                                          choice2 = false;
                                          choice3 = false;
                                        });
                                      },
                                    ),
                                    FlatButton(
                                      color:
                                          choice2 ? Colors.green : Colors.grey,
                                      child: Text(
                                        "In 2 Trips",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () {
                                        goalCompletion = 2;
                                        setState(() {
                                          choice2 = true;
                                          choice1 = false;
                                          choice3 = false;
                                        });
                                      },
                                    ),
                                    FlatButton(
                                      color:
                                          choice3 ? Colors.green : Colors.grey,
                                      child: Text(
                                        "In 3 Trips",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () {
                                        goalCompletion = 3;
                                        setState(() {
                                          choice3 = true;
                                          choice1 = false;
                                          choice2 = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: FlatButton(
                              color: Colors.blue,
                              child: Text(
                                "Submit",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                if (goal != "" &&
                                    (choice1 || choice2 || choice3) &&
                                    numberOfProducts > 0) {
                                  bool done = await addGoalToDatabase(
                                      goal,
                                      dateMade,
                                      numberOfProducts,
                                      goalCompletion,
                                      0);
                                  bool done1 = await getGoals();
                                  Navigator.pop(context);
                                } else {
                                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                                      content: Text(
                                          "Please fill out all the fields!")));
                                  Future.delayed(Duration(seconds: 3), () {
                                    _scaffoldKey.currentState
                                        .hideCurrentSnackBar();
                                  });
                                }
                              }),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  Future<bool> getGoals() async {
    Directory d = await getApplicationDocumentsDirectory();
    File jsonFile = File(d.path + "/goals.json");

    var contents = JsonDecoder().convert(jsonFile.readAsStringSync());
//    print("Type: " + contents.runtimeType.toString());
    List tempGoals = List();
    List tempOldGoals = List();

    print("Goals Found: "+contents.toString());

    for(Map m in contents){
      if(m["deadline"] >= 0 && m["progress"]/m["amount"] >= 1){
        m["result"] = "passed";
        tempOldGoals.add(m);
      } else if (m["deadline"] == 0 && m["progress"]/m["amount"] < 1){
        m["result"] = "failed";
        tempOldGoals.add(m);
      }
      else{
        tempGoals.add(m);
      }
    }

    setState(() {
      goals = tempGoals;
      oldGoals = tempOldGoals;
    });
  }

  Future<bool> addGoalToDatabase(String goal, String date, int products,
      int deadline, int progress) async {
    Map<String, dynamic> data = {
      "goal": goal,
      "amount": products,
      "dateMade": date,
      "deadline": deadline,
      "progress": progress
    };
    print("Adding this: " + data.toString());

    Directory d = await getApplicationDocumentsDirectory();
    File jsonFile = File(d.path + "/goals.json");

    var contents = JsonDecoder().convert(jsonFile.readAsStringSync());
//    print("Current goals: " + contents.toString());
    contents.add(data);
    jsonFile.writeAsStringSync(JsonEncoder().convert(contents));
    print("Saved goal to database");
//    print(contents);
  }

  String getDeadline(int deadline){
    String answer = "";
    String trip = "";

    if(deadline > 1){
      trip = " Shopping Trips";
    } else{
      trip = " Shopping Trip";
    }
    answer = deadline.toString() + trip + " Left!";
    return answer;
  }
}
