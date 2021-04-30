import 'package:flutter/material.dart';
import 'explanation.dart';
import 'goals.dart';
import 'questionnaireLinks.dart';
import 'progressOverview.dart';

class SideBarNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      child: Drawer(
        child: Container(
          color: Colors.green,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.green[700],
                  ),
                  child: FlatButton(
                    child: Text("Performance Overview",
                      style: TextStyle(
                        color: Colors.white,
                      ),),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProgressOverview()));
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.green[700],
                  ),
                  child: FlatButton(
                    child: Text("Goals",
                      style: TextStyle(
                        color: Colors.white,
                      ),),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Goals()));
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.green[700],
                  ),
                  child: FlatButton(
                    child: Text("Questionnaire Links",
                      style: TextStyle(
                        color: Colors.white,
                      ),),
                    onPressed: () {
                      Navigator.pop(context);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QuestionnaireLinks()));
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.green[700],
                  ),
                  child: FlatButton(
                    child: Text("Explanation",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Explanation()));
                    },
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
