import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ProgressOverview extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProgressOverview();
}

class _ProgressOverview extends State<ProgressOverview> {
  String fileName = '/database.json';
  String id = "";

  List<charts.Series<dynamic, String>> seriesList = List();
  List<charts.Series<dynamic, String>> comparisonList = List();
  List<DataPoints> scoreData = List();
  List<DataPoints> groupScoreData = List();
//  double indivMeat = 0.0;
//  double indivDairy = 0.0;
//  double groupMeat = 0.0;
//  double groupDairy = 0.0;
  List<DataPoints2> iMeat = List();
  List<DataPoints2> iDairy = List();
  List<DataPoints2> gMeat = List();
  List<DataPoints2> gDairy = List();
  int gGoals = 0;
  int iGoals = 0;
  Map<String, int> dates = Map<String, int>();

  Color meatPerformance;
  Color dairyPerformance;
  int listsMade = -1;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = new GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Progress Overview"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            userIDAndConfirmed(),
            goalComparison(),
            scoreOverview(),
            indivVsGroup(),
          ],
        ),
      ),
    );
  }

  Widget goalComparison(){
    return Padding(
      padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.grey[400],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 1,
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
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.grey[200]
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: Text("Your Goal Completion Rate:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Text(iGoals.toString()+"%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.grey[200]
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: Container(
                          child: Text("Group Goal Completion Rate:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
//                        padding: ,
                          child: Text(gGoals.toString() + "%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget userIDAndConfirmed() {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      child: Container(
        padding: EdgeInsets.only(left: 5, right: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.grey[400],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(1, 2),
              ),
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: Container(
                width: 250,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(right: 23),
                      child: Text(
                        "User ID:",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "$id",
                        style: TextStyle(
                          fontSize: 30,
//                fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: Container(
                width: 300,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(right: 23),
                      child: Text(
                        "Shopping Lists Confirmed:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        listsMade.toString(),
                        style: TextStyle(
                          fontSize: 30,
//                fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget scoreOverview() {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Container(
          height: 300,
          decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(1, 2),
                ),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                  flex: 0,
                  child: Padding(
                    padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                          child: Text(
                            "Your Score Overview",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          )),
                    ),
                  )),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: charts.BarChart(
                        seriesList,
                        animate: true,
                        defaultInteractions: false,
                        barGroupingType: charts.BarGroupingType.grouped,
                        domainAxis: charts.OrdinalAxisSpec(
                          showAxisLine: true,
                          renderSpec: charts.SmallTickRendererSpec(
                              minimumPaddingBetweenLabelsPx: 0,
                              labelAnchor: charts.TickLabelAnchor.centered,
                              labelStyle: charts.TextStyleSpec(
                                fontSize: 10,
                                color: charts.MaterialPalette.black,
                              ),
                              labelRotation: 60,
                              // Change the line colors to match text color.
                              lineStyle: charts.LineStyleSpec(color: charts.MaterialPalette.black)
                          )
                        ),
                        primaryMeasureAxis: charts.NumericAxisSpec(
                            tickProviderSpec: charts.BasicNumericTickProviderSpec(
                          desiredMinTickCount: 4,
                        )),
                        behaviors: [
                          charts.SeriesLegend(
                            cellPadding:
                                new EdgeInsets.only(right: 20.0, bottom: 5.0),
                          ),
                          charts.ChartTitle(
                            'Date',
                            behaviorPosition: charts.BehaviorPosition.bottom,
                            titleStyleSpec: charts.TextStyleSpec(fontSize: 14, fontWeight: "thick"),
                          ),
                          charts.ChartTitle(
                            'Score',
                            behaviorPosition: charts.BehaviorPosition.start,
                            titleStyleSpec: charts.TextStyleSpec(fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget indivVsGroup(){
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      child: Container(
          height: 500,
          decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(1, 2),
                ),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                  flex: 0,
                  child: Padding(
                    padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 10),
                    child: Container(
                      width: 280,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                        child: Text(
                          "Your Meat and Dairy Substitution Rate Overview",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  )),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.only(left: 5, right: 5, bottom: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: charts.BarChart(
                        comparisonList,
                        animate: true,
                        defaultInteractions: false,
                        barGroupingType: charts.BarGroupingType.grouped,
                        domainAxis: charts.OrdinalAxisSpec(
                            showAxisLine: true,
                            renderSpec: charts.SmallTickRendererSpec(
                                minimumPaddingBetweenLabelsPx: 0,
                                labelAnchor: charts.TickLabelAnchor.centered,
                                labelStyle: charts.TextStyleSpec(
                                  fontSize: 10,
                                  color: charts.MaterialPalette.black,
                                ),
                                labelRotation: 60,
                                // Change the line colors to match text color.
                                lineStyle: charts.LineStyleSpec(color: charts.MaterialPalette.black)
                            )
                        ),
                        primaryMeasureAxis: charts.NumericAxisSpec(
                            tickProviderSpec: charts.BasicNumericTickProviderSpec(
                              desiredMinTickCount: 4,
                            )),
                        behaviors: [
                          charts.SeriesLegend(
                            cellPadding: new EdgeInsets.only(right: 20.0, bottom: 5.0),
                            desiredMaxRows: 4,
                            desiredMaxColumns: 1,
                          ),
                          charts.ChartTitle(
                            'Date',
                            behaviorPosition: charts.BehaviorPosition.bottom,
                            titleStyleSpec: charts.TextStyleSpec(fontSize: 14),
                          ),
                          charts.ChartTitle(
                            'Rates (%)',
                            behaviorPosition: charts.BehaviorPosition.start,
                            titleStyleSpec: charts.TextStyleSpec(fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  getData() async {
    var m = await getDBContents();
    var g = await getGoals();
    print(m);
    print(g);
    int counter = 0;

    for(Map i in g){
      if(i["result"] == "passed"){
        counter += 1;
      }
    }
//    print("COunter: " + counter.toString());

    setState(() {

      if(g.length > 0){
        iGoals = ((counter/g.length) * 100).round();
      } else{
        iGoals = 0;
      }

      gGoals = m["gGoals"];
      id = m["id"];
      listsMade = m["listsMade"];

      if (m["listsMade"] > 0) {

        // Adding the individual and group scores to the series Lists
        for (int i = 0; i < m["score"].length; i++) {
          if(dates.keys.toList().contains(m["dates"][i])){
            dates[m["dates"][i]] = dates[m["dates"][i]] + 1;
            String addition = " (" + dates[m["dates"][i]].toString() + ")";
            scoreData.add(DataPoints(m["score"][i], m["dates"][i] + addition));
            groupScoreData.add(DataPoints(m["groupScore"][i], m["dates"][i] + addition));

            iMeat.add(DataPoints2(m["substitution"]["iMeat"][i], m["dates"][i] + addition));
            gMeat.add(DataPoints2(m["substitution"]["gMeat"][i], m["dates"][i] + addition));
            iDairy.add(DataPoints2(m["substitution"]["iDairy"][i], m["dates"][i] + addition));
            gDairy.add(DataPoints2(m["substitution"]["gDairy"][i], m["dates"][i] + addition));
          } else{
            scoreData.add(DataPoints(m["score"][i], m["dates"][i]));
            groupScoreData.add(DataPoints(m["groupScore"][i], m["dates"][i]));

            iMeat.add(DataPoints2(m["substitution"]["iMeat"][i], m["dates"][i]));
            gMeat.add(DataPoints2(m["substitution"]["gMeat"][i], m["dates"][i]));
            iDairy.add(DataPoints2(m["substitution"]["iDairy"][i], m["dates"][i]));
            gDairy.add(DataPoints2(m["substitution"]["gDairy"][i], m["dates"][i]));

            dates[m["dates"][i]] = 1;
          }
        }

        seriesList.add(charts.Series<DataPoints, String>(
          id: "Individual",
          data: scoreData,
          seriesColor: charts.Color.fromHex(code: "#F15152"),
          domainFn: (DataPoints point, _) => point.date,
          measureFn: (DataPoints point, _) => point.score,
        ));

        seriesList.add(charts.Series<DataPoints, String>(
          id: "Group",
          data: groupScoreData,
          seriesColor: charts.Color.fromHex(code: "#3A2E39"),
          domainFn: (DataPoints point, _) => point.date,
          measureFn: (DataPoints point, _) => point.score,
        ));

//        for(int i = 0; i < m["substitution"]["iMeat"].length; i++){
//          print("From data: " + m["substitution"]["iMeat"][i].toString());
//          if(dates.keys.toList().contains(m["dates"][i])){
//            dates[m["dates"][i]] = dates[m["dates"][i]] + 1;
//            String addition = " (" + dates[m["dates"][i]].toString() + ")";
//            iMeat.add(DataPoints2(m["substitution"]["iMeat"][i], m["dates"][i] + addition));
//            gMeat.add(DataPoints2(m["substitution"]["gMeat"][i], m["dates"][i] + addition));
//            iDairy.add(DataPoints2(m["substitution"]["iDairy"][i], m["dates"][i] + addition));
//            gDairy.add(DataPoints2(m["substitution"]["gDairy"][i], m["dates"][i] + addition));
////            scoreData.add(DataPoints(m["score"][i], m["dates"][i] + addition));
////            groupScoreData.add(DataPoints(m["groupScore"][i], m["dates"][i] + addition));
//          } else{
//            iMeat.add(DataPoints2(m["substitution"]["iMeat"][i], m["dates"][i]));
//            gMeat.add(DataPoints2(m["substitution"]["gMeat"][i], m["dates"][i]));
//            iDairy.add(DataPoints2(m["substitution"]["iDairy"][i], m["dates"][i]));
//            gDairy.add(DataPoints2(m["substitution"]["gDairy"][i], m["dates"][i]));
////            gMeat.add(DataPoints(m["groupScore"][i], m["dates"][i]));
//            dates[m["dates"][i]] = 1;
//          }
//        }
        comparisonList.add(charts.Series<DataPoints2, String>(
          id: "Individual Meat Substitution",
          data: iMeat,
          seriesColor: charts.Color.fromHex(code: "#00ABE7"),
          domainFn: (DataPoints2 point, _) => point.date,
          measureFn: (DataPoints2 point, _) => point.score,
        ));

        comparisonList.add(charts.Series<DataPoints2, String>(
          id: "Group Meat Substitution",
          data: gMeat,
          seriesColor: charts.Color.fromHex(code: "#0081AF"),
          domainFn: (DataPoints2 point, _) => point.date,
          measureFn: (DataPoints2 point, _) => point.score,
        ));

        comparisonList.add(charts.Series<DataPoints2, String>(
          id: "Individual Dairy Substitution",
          data: iDairy,
          seriesColor: charts.Color.fromHex(code: "#EAD2AC"),
          domainFn: (DataPoints2 point, _) => point.date,
          measureFn: (DataPoints2 point, _) => point.score,
        ));

        comparisonList.add(charts.Series<DataPoints2, String>(
          id: "Group Dairy Substitution",
          data: gDairy,
          seriesColor: charts.Color.fromHex(code: "#EABA6B"),
          domainFn: (DataPoints2 point, _) => point.date,
          measureFn: (DataPoints2 point, _) => point.score,
        ));

//        if (indivMeat > groupMeat) {
//          meatPerformance = Colors.green;
//        } else if (indivMeat == groupMeat) {
//          meatPerformance = Colors.blue;
//        } else {
//          meatPerformance = Colors.red;
//        }
//
//        if (indivDairy > groupDairy) {
//          dairyPerformance = Colors.green;
//        } else if (indivDairy == groupDairy) {
//          dairyPerformance = Colors.blue;
//        } else {
//          dairyPerformance = Colors.red;
//        }
      }
    });
  }

  Future<Map<dynamic, dynamic>> getDBContents() async {
    var contents;
    await getApplicationDocumentsDirectory().then((Directory d) {
      File jsonFile = File(d.path + fileName);
      contents = JsonDecoder().convert(jsonFile.readAsStringSync());
    });
    return contents;
  }

  Future<List> getGoals() async{
    Directory d = await getApplicationDocumentsDirectory();
    File jsonFile = File(d.path + "/goals.json");

    var contents = JsonDecoder().convert(jsonFile.readAsStringSync());
    return contents;
  }

  int randomGenerator(int max, int min, String condition) {
    var rn = Random();
    if (condition == "more") {
      return min + rn.nextInt(max - min);
    } else if (condition == "less") {
      return min - rn.nextInt(max - min);
    }
  }

}

class DataPoints {
  String date;
  double score;

  DataPoints(int s, String d) {
    if (s == 0) {
      this.score = 0.1;
    } else {
      this.score = double.parse(s.toString());
    }
    this.date = d;
  }
}

class DataPoints2 {
  String date;
  double score;

  DataPoints2(double s, String d) {
    if (s == 0.0) {
      this.score = 0.3;
    } else {
      this.score = double.parse(s.toString()) * 100;
    }
    this.date = d;
  }
}
