import 'package:directed_graph/directed_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:math_parser/math_parser.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:equations/equations.dart';
import 'dart:math';
import "testing_only.dart";
//import custom files
import 'formula.dart';
import 'constructor_class.dart';
import 'function_list.dart';
import 'dart:core';


//trying to run setup items here
Map items_r=setup_R();
Constructor resistance=Constructor(items_r);

Map items_l=setup_L();
Constructor inductance=Constructor(items_l);

Map items_c=setup_C();
Constructor capacitance=Constructor(items_c);

Map items_gmd=setup_GMD();
Constructor gmd=Constructor(items_gmd);

Map items_gmr=setup_GMR(1);
Constructor gmr=Constructor(items_gmr);

Map items_rb=setup_rb(1);
Constructor rb=Constructor(items_rb);

Map items_xc=setup_Xc();
Constructor xc=Constructor(items_xc);

Map items_xl=setup_Xl();
Constructor xl=Constructor(items_xl);

const List<String> list = <String>['1', '2', '3', '4'];


void main() {


  //main1();




 // mathjs_post();


  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transmission line calculator',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Transmission line Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List test_step=[['Step 1','a=w+e','a=1+1','2'],['Step 2','a=f/e','a=1+1','2']];
  int _counter = 0;
  double base=1;
  Map r_para={};
  final TextEditingController var1_controller = TextEditingController();
  final TextEditingController var2_controller = TextEditingController();
  final TextEditingController var3_controller = TextEditingController();
  final TextEditingController var4_controller = TextEditingController();
  final TextEditingController var5_controller = TextEditingController();
  final TextEditingController var6_controller = TextEditingController();
  final TextEditingController var7_controller = TextEditingController();
  final TextEditingController var8_controller = TextEditingController();
  //String item_1=string_R();
  String item_1=resistance.formulaExpression;
  String item_2=resistance.return_SubsitutedFormula();
  String item_3=resistance.return_answer_output();
  String item_r='';


  String item_1l=inductance.formulaExpression;
  String item_2l=inductance.return_SubsitutedFormula();
  String item_3l=inductance.return_answer_output();
  String item_l='';

  String item_1c=capacitance.formulaExpression;
  String item_2c=capacitance.return_SubsitutedFormula();
  String item_3c=capacitance.return_answer_output();
  String item_c='';

 // String item_1gmr=gmr.formulaExpression;
  String item_1gmr =gmr.formulaExpression;
  String item_2gmr =gmr.return_SubsitutedFormula();
  String item_3gmr =gmr.return_answer_output();
  String item_gmr  ="";

  String item_1gmd =gmd.formulaExpression;
  String item_2gmd =gmd.return_SubsitutedFormula();
  String item_3gmd =gmd.return_answer_output();
  String item_gmd='';

  String item_1rb =rb.formulaExpression;
  String item_2rb =rb.return_SubsitutedFormula();
  String item_3rb =rb.return_answer_output();
  String item_rb='';

  String item_xc='';
  String item_xl='';
  //test to put classes here
  String nValue = list.first;
  int n=1;




  void dispose() {
    // Clean up the controller when the widget is disposed.
    var1_controller.dispose();
    var2_controller.dispose();
    var3_controller.dispose();
    var4_controller.dispose();
    var5_controller.dispose();
    var6_controller.dispose();
    var7_controller.dispose();
    var8_controller.dispose();
    super.dispose();
  }

  void calculation() {
    setState(() {

      double var1=double.parse(var1_controller.text.toString());
      double var2=double.parse(var2_controller.text.toString());
      double var3=double.parse(var3_controller.text.toString());
      double var4=double.parse(var4_controller.text.toString());
      double var5=double.parse(var5_controller.text.toString());
      double var6=double.parse(var6_controller.text.toString());
      double var7=double.parse(var7_controller.text.toString());
      double var8=double.parse(var8_controller.text.toString());

      n=int.parse(nValue);

      Map items_gmrModified=setup_GMR(n);
      Map items_rbModified=setup_rb(n);


      gmd.adjust_parameters('d_{1}', var1);
      gmd.adjust_parameters('d_{2}', var2);
      gmd.adjust_parameters('d_{3}', var3);

      gmr.modify_attributes(items_gmrModified);
      gmr.adjust_parameters('d',var4 );
      gmr.adjust_parameters('r',var5 );
      gmr.adjust_parameters('gmr_{cond}',var7 );

      rb.modify_attributes(items_rbModified);
      rb.adjust_parameters('d',gmr.parameters['d'] );
      rb.adjust_parameters('r',gmr.parameters['r'] );


      item_2gmd=gmd.return_SubsitutedFormula();
      item_3gmd=gmd.return_answer_output();
      item_gmd =combine_into_Eqn(item_1gmd, item_2gmd, item_3gmd);

      item_1gmr=gmr.return_formula();
      item_2gmr=gmr.return_SubsitutedFormula();
      item_3gmr=gmr.return_answer_output();
      item_gmr =combine_into_Eqn(item_1gmr, item_2gmr, item_3gmr);

      item_1rb=rb.return_formula();
      item_2rb=rb.return_SubsitutedFormula();
      item_3rb=rb.return_answer_output();
      item_rb =combine_into_Eqn(item_1rb, item_2rb, item_3rb);

      base=(_counter^2)/2;
      resistance.adjust_parameters(r'\rho',rho);
      resistance.adjust_parameters('l',var6);
      resistance.adjust_parameters('r',gmr.parameters['r']);
      item_2=resistance.return_SubsitutedFormula();
      item_3=resistance.return_answer_output();
      item_r=combine_into_Eqn(item_1,item_2,item_3);

      inductance.adjust_parameters('gmr', gmr.constructorAnswer);
      inductance.adjust_parameters('gmd', gmd.constructorAnswer);
      item_2l=inductance.return_SubsitutedFormula();
      item_3l=inductance.return_answer_output();
      item_l =combine_into_Eqn(item_1l, item_2l, item_3l);

      capacitance.adjust_parameters('gmd',gmd.constructorAnswer);
      capacitance.adjust_parameters('r',rb.constructorAnswer);
      item_2c=capacitance.return_SubsitutedFormula();
      item_3c=capacitance.return_answer_output();
      item_c=combine_into_Eqn(item_1c, item_2c, item_3c);

      xc.adjust_parameters('f',var8 );
      xc.adjust_parameters('c',capacitance.constructorAnswer);
      item_xc=combine_into_Eqn(xc.formulaExpression, xc.return_SubsitutedFormula(), xc.return_answer_output());

      xl.adjust_parameters('f',var8 );
      xl.adjust_parameters('l',inductance.constructorAnswer);
      item_xl=combine_into_Eqn(xl.formulaExpression, xl.return_SubsitutedFormula(), xl.return_answer_output());
      //item_2=stringCompute_R(double.parse(var1_controller.text.toString()), _counter.toDouble(), 6);
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.

    });
  }

  void step_mod() async
  {
    List temp=await main_function_solver();
    setState(()  {


      //test_step=[['Step 3','a=fvfw+e','a=1+1','2'],['Step 4','a=dvsdsvsdf/e','a=1+1','2']];
      test_step.clear();
      test_step.addAll(temp);
      //test_step=await main_function_solver();
    });

  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child:SingleChildScrollView(
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,

          children: <Widget>[
            const Text(r"First we compute the GMD and GMR:"),
            Row(
              //RegExp('([0-9]+(.[0-9]+)?)')
              children:<Widget>[
                Expanded(
                  child:TextField(
                    controller:var1_controller,
                    decoration: InputDecoration(labelText: 'Enter D1 value:'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+.?[0-9]*'))],
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller:var2_controller,
                    decoration: InputDecoration(labelText: 'Enter D2 value:'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+.?[0-9]*'))],
                  ),
                ),

                Expanded(
                  child: TextField(
                    controller:var3_controller,
                    decoration: InputDecoration(labelText: 'Enter D3 value:'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+.?[0-9]*'))],
                  ),
                ),
              ]

              ,
            ),//row 1
            Row(

              children:<Widget>[
                Expanded(
                  child:TextField(
                    controller:var4_controller,
                    decoration: InputDecoration(labelText: 'Enter d value:'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+.?[0-9]*'))],
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller:var5_controller,
                    decoration: InputDecoration(labelText: 'Enter r(m) value:'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+.?[0-9]*'))],
                  ),
                ),
                Expanded(
                  child:DropdownButton<String>(
                    value: nValue,
                    //icon: const Icon(Icons.arrow_downward),
                    //elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        nValue = value!;
                      });
                    },
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),

                ),

              ]

              ,
            ),//row 2

            Row(

              children:<Widget>[
                Expanded(
                  child:TextField(
                    controller:var6_controller,
                    decoration: InputDecoration(labelText: 'Enter l value:'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+.?[0-9]*'))],
                  ),
                ),
                Expanded(
                  child:TextField(
                    controller:var7_controller,
                    decoration: InputDecoration(labelText: 'Enter GMR value:'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+.?[0-9]*'))],
                  ),
                ),
                Expanded(
                  child:TextField(
                    controller:var8_controller,
                    decoration: InputDecoration(labelText: 'Enter f value:'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+.?[0-9]*'))],
                  ),
                ),
              ]

              ,
            ),


            Text(var1_controller.text.toString()),

            ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              children: test_step
                  .map((entry) =>  Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(entry[0]),
                        subtitle: SelectableText(
                          entry[1],
                         // style: GoogleFonts.robotoMono(),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(1, 5, 1, 5),
                        child: SelectableMath.tex(
                          entry[1],
                          textStyle: TextStyle(fontSize: 22),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(1, 5, 1, 5),
                        child: SelectableMath.tex(
                          entry[2],
                          textStyle: TextStyle(fontSize: 22),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(1, 5, 1, 5),
                        child: SelectableMath.tex(
                          entry[3],
                          textStyle: TextStyle(fontSize: 22),
                        ),
                      )
                    ],
                  ),
                ),
              )
                  .toList(),
            ),


          //list generator for solution


          ],
        ),
        ),

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: step_mod,
        //onPressed: main_function_solver,
        tooltip: 'Calculate!',
        child: const Icon(Icons.calculate),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


