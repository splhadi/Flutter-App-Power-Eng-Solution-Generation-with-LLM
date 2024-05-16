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
import 'variable_list.dart' as var_list;
import 'package:http/http.dart' as http;
import 'dart:core';


//extends the Stateful for this page with a route name for the main navigator to access
class ImagePage extends StatefulWidget {
  const ImagePage({super.key, required this.title});

  static const String routeName = "/botImagePrompt";

  final String title;

  @override
  _ImagePageState createState() =>  _ImagePageState();
}

/// // 1. After the page has been created, register it with the app routes
/// routes: <String, WidgetBuilder>{
///   MyItemsPage.routeName: (BuildContext context) =>  MyItemsPage(title: "MyItemsPage"),
/// },
///
/// // 2. Then this could be used to navigate to the page.
/// Navigator.pushNamed(context, MyItemsPage.routeName);
///

class _ImagePageState extends State<ImagePage> {

  //controller for text input
  final TextEditingController var1_controller = TextEditingController();

  //string to store all converted text, note that this the same as solver_page.dart
  String converted_text='';
  String converted_text_caption='';
  String solution_caption = '';
  String solution_text ='';

  //to store the image into a Xfile format first
  XFile? image;
  bool load_solution=false;
  bool text_only = false;
  bool sol_present=false;

  //imagepicker to upload image
  final ImagePicker picker = ImagePicker();

  bool vertical = false;
  var selectedIndex = 1;

  //this is where the widget is built
  @override
  Widget build(BuildContext context) {
    var button =  IconButton(icon:  Icon(Icons.arrow_back), onPressed: _onButtonPressed);
    //function when image is uploaded, it will return the 'image' into the container which displays the image
    Future show_image(ImageSource media) async
    {
      var img = await picker.pickImage(source: media);
      setState(() {
        image = img;
      });


    }

    @override
    void dispose() {
      // Clean up the controller when the widget is disposed.
      var1_controller.dispose();
      super.dispose();
    }

    //scaffold is where all widgets are stored and rendered
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

            //this portion is for image display
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
            TextField(
              controller:var1_controller,
              decoration: InputDecoration(labelText: 'Enter the instructions for the bot to intrepret the image:'),


            ),
            SizedBox(width:10,height:10),
            FancyButton(
                button_icon: Icons.filter_center_focus,
                button_text: "Analyse image",
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
                  // onclick function when the analyse button is pressed

                  //create a dialog window to show the user a loading screen while it sends to the server the image
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

                  //this is the main function which receive a response from the server end
                  final response_image= await upload(image);
                  print("Received: $response_image");

                  //removes loading screen for generating iamge
                  Navigator.of(context).pop();

                  //set state from response received
                  setState(() {
                    String message= response_image['message'].toString();

                    //if error encountered it will display what error it encountered
                    if (response_image['status'] == 'error')
                    {
                      final snackBar = SnackBar(
                        content: Text(message),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                    else
                    {
                      //if no error encountered it will display update the string for the following
                      converted_text = response_image['message'];
                      converted_text_caption ='Response:';

                    }

                  });
                }),
            SizedBox(width:10,height:10),
            Text(converted_text_caption,style: TextStyle(fontWeight:FontWeight.bold),),
            SizedBox(width:10,height:10),
            Text(converted_text),
            SizedBox(width:10,height:10),

            Text(solution_caption,style: TextStyle(fontWeight:FontWeight.bold),),
            SizedBox(width:10,height:10),





            button
          ],
        ),),
      ),

    );
  }

//main function for communication between server and flutter application
  Future upload(image) async{

    // retrieve the string from the text input
    String prompt_text = var1_controller.text.toString();
    print("getting text $prompt_text");
    Map msg = {'status':'','message':''};
    //check if any image is uploaded
    //error handling check
    if (image == null && prompt_text.isEmpty)
    {
      String error_msg = 'No Instruction given and no image uploaded!';
      msg['status']='error';
      msg['message']=error_msg;
      return msg;

    }

    else if (image == null)
    {
      String error_msg = 'No image uploaded. Please upload an image before doing so!';
      msg['status']='error';
      msg['message']=error_msg;
      return msg;

    }
    else if (prompt_text.isEmpty)
      {
        String error_msg = 'No Instruction given. Please input your instructions!';
        msg['status']='error';
        msg['message']=error_msg;
        return msg;


      }

    //end of error handling check

    String received_message = '';

    //multipart request to package image and prompt
    final uri = Uri.parse('http://'+var_list.ip_address+':8000/image-extract');
    final request = new http.MultipartRequest('PUT', uri);
    final httpImage =await http.MultipartFile.fromPath('image', image.path,contentType: MediaType('image', 'png'));
    request.files.add(httpImage);
    //note that for this function we are sending the prompt text over
    request.fields['prompt']=prompt_text;

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

// goes back to main menu
  void _onButtonPressed() {
    Navigator.pop(context);
  }
}


