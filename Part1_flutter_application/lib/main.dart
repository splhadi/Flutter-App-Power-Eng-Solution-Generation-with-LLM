import 'package:flutter/material.dart';
import 'solver_page.dart';
import 'chatbot.dart';
import 'bot_image_prompt.dart';
import 'variable_list.dart' as var_list;
import 'package:flutter_math_fork/flutter_math.dart';



//this is the main file for the flutter application
void main() => runApp( MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    //build all the routes leading to the subpages
    var routes = <String, WidgetBuilder>{
      SolverPage.routeName: (BuildContext context) =>  SolverPage(title: "LLM AI Solver"),
      ChatPage.routeName:(BuildContext context) => ChatPage(title:"Chat bot for future engineers"),
      ImagePage.routeName:(BuildContext context) => ImagePage(title:"Image recognition"),
    };
    return  MaterialApp(
      title: 'Flutter Demo',
      theme:  ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  MyHomePage(title: 'AI Solver Home Page'),
      routes: routes,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() =>  _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


// functions to go to different pages
  void gotoSolver() {
    Navigator.pushNamed(context, SolverPage.routeName);
  }

  void gotochat() {
    Navigator.pushNamed(context, ChatPage.routeName);
  }
  void gotoimage_extract() {
    Navigator.pushNamed(context, ImagePage.routeName);
  }


  //widget used to build the app
  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      appBar:  AppBar(
        title:  Text(widget.title),
      ),
      body:  Column(
        children: <Widget>[


          Card(
            // clipBehavior is necessary because, without it, the InkWell's animation
            // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
            // This comes with a small performance cost, and you should not set [clipBehavior]
            // unless you need it.
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                gotoSolver();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.android),
                    title: Text('Image Recognition Question solver'),
                    subtitle: Text("Solve Tutorial or Exam questions using Google's Gemini AI by image recognition and LangChain for Question analysis" ),
                  ),


                ],
              ),
            ),
          ),
          Card(
            // clipBehavior is necessary because, without it, the InkWell's animation
            // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
            // This comes with a small performance cost, and you should not set [clipBehavior]
            // unless you need it.
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                gotochat();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.chat_bubble_outline_outlined),
                    title: Text('Chat Bot'),
                    subtitle: Text("Chat to find out more about your topics" ),
                  ),


                ],
              ),
            ),
          ),
          Card(
            // clipBehavior is necessary because, without it, the InkWell's animation
            // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
            // This comes with a small performance cost, and you should not set [clipBehavior]
            // unless you need it.
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                gotoimage_extract();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.image_search_outlined),
                    title: Text('Image intrepreter'),
                    subtitle: Text("Test with the bot to intrepret images. Experimental stage" ),
                  ),


                ],
              ),
            ),
          ),
        ],
      ),

    );
  }


}
