import 'package:directed_graph/directed_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:math_parser/math_parser.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:equations/equations.dart';
import 'package:fancy_button_flutter/fancy_button_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';
import 'unused_files/testing_only.dart';
import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
//import custom files
import 'unused_files/formula.dart';

import 'package:http/http.dart' as http;
import 'variable_list.dart' as var_list;
import 'dart:core';

class SolverPage extends StatefulWidget {
  const SolverPage({super.key, required this.title});

  static const String routeName = "/MyItemsPage";

  final String title;

  @override
  _SolverPageState createState() =>  _SolverPageState();
}

/// // 1. After the page has been created, register it with the app routes
/// routes: <String, WidgetBuilder>{
///   MyItemsPage.routeName: (BuildContext context) =>  MyItemsPage(title: "MyItemsPage"),
/// },
///
/// // 2. Then this could be used to navigate to the page.
/// Navigator.pushNamed(context, MyItemsPage.routeName);
///

class _SolverPageState extends State<SolverPage> {



  //declaring the variables needed for solver page
  List test_step=[];
  String converted_text='';
  String converted_text_caption='';
  String solution_caption = '';
  String solution_text ='';
  XFile? image;
  bool load_solution=false;
  bool text_only = false;
  bool sol_present=false;
  final ImagePicker picker = ImagePicker();
  List<Widget> solution_selection = <Widget>[
    Text('Text only'),
    Text('Latex rendering')
  ];

  bool vertical = false;
  var selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    //button to go back to main menu
    var button =  IconButton(icon:  Icon(Icons.arrow_back), onPressed: _onButtonPressed);
    Future show_image(ImageSource media) async
    {
      var img = await picker.pickImage(source: media);
      setState(() {
        image = img;
      });


    }

    //main function when the text is sent
    void begin_solving() async
    {
      //first the steps are cleared from the display
      setState(() {
        solution_text ='';
        load_solution = true;
        sol_present = false;
        test_step.clear();
      });
      print("Begin solving function");
      //receive response from server
      final response = await updateLLM(converted_text);
      print("After updateLLM");
      //decode according to utf-8
      String received_message= await json.decode(utf8.decode(response.bodyBytes));
      //split the steps using the delimiter mentioned in server, but this split is only to extract the first step
      List<String> steps_temp = received_message.split('%-break-%');
      //first index contains original solution in normal text
      String sol_step = steps_temp[0];
      print("sol step: $sol_step");

      //bug fix to clear new line
      received_message=received_message.replaceAll('\n', r' \\ ');
      //received_message=received_message.replaceAll(r'$$', r'');
      print("Received string: $received_message");
      //String received_message = '1%-break-%2%-break-%3';
      //List steps = json.decode(received_message);

      //set state to update all variables with new steps
      setState(() {
        //text_1='changed';
        //splits the steps based on the delimiter
        List steps = received_message.split('%-break-%');
        solution_text = sol_step;
        //remove first index as it contains original index
        steps.removeAt(0);
        solution_caption = "Approximate Solution:";
        test_step.clear();
        test_step.addAll(steps);

        load_solution = false;
        sol_present = true;
        print("End function");
      });
      
    };

    return  Scaffold(
      appBar:  AppBar(
        title:  Text(widget.title),
      ),
      body:  Container(
        child:SingleChildScrollView(child:
        Column(


          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30), //apply padding to all four sides
              child: Text("Select any image from your gallery or camera to begin:",style:TextStyle(fontSize: 20 )),
            ),

            //SizedBox(width:10,height:20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [            FancyButton(
                button_icon: Icons.image_search_outlined,
                button_text: "Upload photo \nfrom gallery ",
                button_height: 40,
                button_width: 150,
                button_radius: 0,
                button_color: Colors.blue,
                button_outline_color: Colors.blue,
                button_outline_width: 1,
                button_text_color: Colors.white,
                button_icon_color: Colors.white,
                icon_size: 22,
                button_text_size: 15,
                onClick: () {

                  show_image(ImageSource.gallery);
                }),

              FancyButton(
                  button_icon: Icons.camera_alt_outlined,
                  button_text: "Upload photo \nfrom camera",
                  button_height: 40,
                  button_width: 150,
                  button_radius: 0,
                  button_color: Colors.blue,
                  button_outline_color: Colors.blue,
                  button_outline_width: 1,
                  button_text_color: Colors.white,
                  button_icon_color: Colors.white,
                  icon_size: 22,
                  button_text_size: 15,
                  onClick: () {

                    show_image(ImageSource.camera);
                  }),



            ],),

          SizedBox(width:10,height:10),

            image != null
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  //to show image, you type like this.
                  File(image!.path),
                  fit: BoxFit.fitWidth,
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                ),
              ),
            )
                :Padding(
                padding: EdgeInsets.all(30),
                child: DottedBorder(

                    color: Colors.black,
                    strokeWidth: 2,
                    child:Container(

                        padding: EdgeInsets.all(40),
                        alignment: Alignment.center,
                        color: Colors.grey.shade300,

              child: Column(
              children:[
                Icon(Icons.broken_image_outlined),
                Text("No Image Selected"),

              ]

            )
            ))),

            SizedBox(width:10,height:10),
            FancyButton(
                button_icon: Icons.calculate_outlined,
                button_text: "Extract image and Solve",
                button_height: 40,
                button_width: 200,
                button_radius: 0,
                button_color: Colors.blue,
                button_outline_color: Colors.blue,
                button_outline_width: 1,
                button_text_color: Colors.white,
                button_icon_color: Colors.white,
                icon_size: 22,
                button_text_size: 15,
                onClick: ()async {
                  showDialog(context: context, builder: (context){
                    return Center(child:Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [CircularProgressIndicator(),
                          Text("Generating text from image",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'typography',
                                fontWeight: FontWeight.normal,
                                //fontStyle: FontStyle.normal,
                                decoration: TextDecoration.none,


                          ),)
                        ]),);
                    //,Center(child:)
                  });

                  //first it converts image into text first
                  final response_image= await upload(image);
                  print("Received: $response_image");
                  //removes loading screen for generating iamge
                  Navigator.of(context).pop();
                  //set state from response received
                  //once image converted, setstate will update the page
                  setState(() {
                    String message= response_image['message'].toString();

                    if (response_image['status'] == 'error')
                      {
                       final snackBar = SnackBar(
                          content: Text(message),
                        );
                       ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    else
                      {
                        //the text will be sent back to begin solving
                        converted_text = response_image['message'];
                        converted_text_caption ='Question:';
                        begin_solving();
                      }

                  });

                //
                }),
            SizedBox(width:10,height:10),
           Text(converted_text_caption,style: TextStyle(fontWeight:FontWeight.bold),),
            SizedBox(width:10,height:10),
           Text(converted_text),
            SizedBox(width:10,height:10),

            Text(solution_caption,style: TextStyle(fontWeight:FontWeight.bold),),
            SizedBox(width:10,height:10),

           Visibility(visible:load_solution ,child: Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               CircularProgressIndicator(),
               SizedBox(width:10,height:10),
               Text("Generating solution"),

             ],),),
            Visibility(visible:sol_present ,child:ToggleSwitch(
              initialLabelIndex: selectedIndex,
              minWidth: 150.0,
              totalSwitches: 2,
              labels: ['Text only', 'Latex rendering', ],
              animate: true,
              onToggle: (index) {
                print('switched to: $index');
                int test = index ?? 0;
                setState(() {
                  selectedIndex=index?? 0;

                  if (index ==0)
                    {
                      text_only = true;

                    }
                  else{

                    text_only = false;
                  }
                });
              },
            ),),
            Visibility(visible:text_only ,child: Text(solution_text),),
          Visibility(visible:!text_only,child: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: test_step
                .map((entry) =>  Card(
              child: Column(
                children: [

                  Container(
                    padding: const EdgeInsets.fromLTRB(1, 5, 1, 5),
                    child: Column(children:[
                     SingleChildScrollView(
                       scrollDirection: Axis.horizontal,
                         child:Math.tex(
                        entry,

                      )),

                    ] ),
                  ),
                  //Container(
                    //padding: const EdgeInsets.fromLTRB(1, 5, 1, 5),
                    //child: Column(children:[
                      //Text(
                        //entry,

                      //),

                    //] ),
                  //),
                ],
              ),
            ),
            )
                .toList(),
          ),),







            button
          ],
        ),),
      ),

    );
  }


//function is used to handle send and receive requests to convert image to text
  Future upload(image) async{


    Map msg = {'status':'','message':''};

    //check if any image is uploaded
    if (image == null)
      {
        String error_msg = 'No image uploaded. Please upload an image before doing so!';
        msg['status']='error';
        msg['message']=error_msg;
        return msg;

      }

    final bytes = await image.readAsBytes();
    String received_message = '';

    //create a multipart request
    final uri = Uri.parse('http://'+var_list.ip_address+':8000/image-extract');
    final request = new http.MultipartRequest('PUT', uri);
    final httpImage =await http.MultipartFile.fromPath('image', image.path,contentType: MediaType('image', 'png'));
    request.files.add(httpImage);
    request.fields['prompt']='nil';

    print("Sending response");

    //try catch error to detect any problems
    try
    {final response = await request.send();
    if (response.statusCode == 200) {
      print('Uploaded!');

      var response_received = await http.Response.fromStream(response);
      received_message= await json.decode(utf8.decode(response_received.bodyBytes));
      msg['status']='success' ;
      msg['message']=received_message;
    }
    else
    {
      String code = response.statusCode.toString();
      String descp = response.reasonPhrase.toString();
      received_message = "Error Detected when sending message\n"+ "Error code: "+code +'\n'+descp;
      msg['status']='error' ;
      msg['message']=received_message;

    }

    }
    catch(e)
    {
      String descp =e.toString();
      received_message = "Error Detected when sending message\n"+ "Description: "+descp;
      msg['status']='error' ;
      msg['message']=received_message;
    }
    return msg;
  }


  Future<http.Response> updateLLM(String text) async {
   // String ip_address = "10.91.108.17"; //"192.168.1.14";
    final response = await http.put(
        Uri.parse('http://'+var_list.ip_address+':8000/send-question-problem'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'message': text,
        }),
        encoding: Encoding.getByName("utf-8")
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return response;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to perform updateLLM.');
    }

  }


  void _onButtonPressed() {
    Navigator.pop(context);
  }
}
