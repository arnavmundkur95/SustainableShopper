import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as l;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class QuestionnaireLinks extends StatefulWidget {
//  QuestionnaireLinks({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QuestionnaireLinks();
}

class _QuestionnaireLinks extends State<QuestionnaireLinks> {
  Color b1;
  Color b2;
  bool button2;
  String id;
  int listsMade;
  String beforeLink;
  String afterLink;
  String emailLink;

  _QuestionnaireLinks() {
    b1 = Colors.blue;
    b2 = Colors.blueGrey;
    button2 = false;
    id = "";
    listsMade = 0;
    beforeLink = "https://forms.gle/a4MPbWtUSK2JNvu8A";
    afterLink = "https://forms.gle/smKw5Ys2Hvfaa1JN8";
    emailLink = "https://forms.gle/UMhojcaBzVGWJbCd6";
  }

  @override
  void initState() {
    super.initState();
    checkStates();
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = new GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Questionnaire Links"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Wrap(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
                  child: Container(
                    width: 300,
                    child: Text("On this page you can find the links to the first and second questionnaires, as well as "
                        "the link to submit your email address to arrange an interview about your experience with the application."
                        "\n\nDon't forget to copy your"
                        " unique User ID by clicking the icon below next to your ID!", textAlign: TextAlign.justify, style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold
                    ),),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      userID(scaffoldKey),
                      Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: RaisedButton(
                          color: b1,
                          onPressed: () async {
                            // open link to browser with questionnaire link
                            bool done = await _launchInBrowser(beforeLink);
                            if(done){
                              setDBContentsList([
                                ['filledOutBefore', true]
                              ]);
                            } else{
                              scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please make sure you are connected to WiFi or Cellular data!")));
                              Future.delayed(Duration(seconds: 5), () {
                                scaffoldKey.currentState.hideCurrentSnackBar();
                              });
                            }
                          },
                          child: Text("First Questionnaire"),
                        ),
                      ),
                      RaisedButton(
                        color: b2,
                        onPressed: () async{
                          if (listsMade < 5) {
                            scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text(
                                    "Please confirm 5 shopping lists before attempting to fill out the After questionnaire!")));
                            Future.delayed(Duration(seconds: 5), () {
                              scaffoldKey.currentState.hideCurrentSnackBar();
                            });
                          } else {
                            bool done = await _launchInBrowser(afterLink);
                            if(done){
                              setDBContentsList([
                                ['filledOutAfter', true]
                              ]);
                            } else{
                              scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please make sure you are connected to WiFi or Cellular data!")));
                              Future.delayed(Duration(seconds: 5), () {
                                scaffoldKey.currentState.hideCurrentSnackBar();
                              });
                            }
                          }
                        },
                        child: Text("Second Questionnaire"),
                      ),
                      RaisedButton(
                        color:b2,
                        onPressed: () async{
                          if (listsMade < 5) {
                            scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text(
                                    "Please confirm 5 shopping lists before sending in your email to arrange an interview!")));
                            Future.delayed(Duration(seconds: 5), () {
                              scaffoldKey.currentState.hideCurrentSnackBar();
                            });
                          } else {
                            bool done = await _launchInBrowser(emailLink);
                            if(done){
                              print("Thanks");
                            } else{
                              scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please make sure you are connected to WiFi or Cellular data!")));
                              Future.delayed(Duration(seconds: 5), () {
                                scaffoldKey.currentState.hideCurrentSnackBar();
                              });
                            }
                          }
                        },
                        child: Text("Email Submission"),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<dynamic, dynamic>> getDBContents() async {
    var contents;
    await getApplicationDocumentsDirectory().then((Directory d) {
      File jsonFile = File(d.path + '/database.json');
      contents = JsonDecoder().convert(jsonFile.readAsStringSync());
    });
    return contents;
  }

  void checkStates() async {
    var contents = await getDBContents();

    setState(() {
      id = contents["id"];
      listsMade = contents["listsMade"];
    });

    if (contents["listsMade"] >= 5) {
      setState(() {
        button2 = true;
        b2 = Colors.blue;
      });
    }
  }

  Future<bool> setDBContentsList(List<dynamic> args) async {
    Directory d = await getApplicationDocumentsDirectory();
    File jsonFile = File(d.path + '/database.json');
    var contents = JsonDecoder().convert(jsonFile.readAsStringSync());
    var oldContents = contents;

    for (List l in args) {
      contents[l[0]] = l[1];
    }

//    print("OLD: " + oldContents.toString());
    File done = await jsonFile.writeAsString(JsonEncoder().convert(contents));
//    print("NEW: " +
//        JsonDecoder().convert(jsonFile.readAsStringSync()).toString());
//    print("Finished Updating");

    return true;
  }

  Widget userID(GlobalKey<ScaffoldState> key) {
    return Padding(
      padding: EdgeInsets.only(left: 23, right: 10, bottom: 20),
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
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: Container(
                width: 250,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 4,
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
                    Expanded(
                        flex: 1,
                        child: FlatButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: id));
                            key.currentState.showSnackBar(SnackBar(
                              content: Text("Copied User ID to clipboard!"),
                            ));
                          },
                          child: Icon(Icons.content_copy),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _launchInBrowser(String url) async {
    if (await l.canLaunch(url)) {
      await l.launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
      return true;
    } else {
//      throw 'Could not launch $url';
      return false;
    }
  }
}
