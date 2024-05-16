import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import 'variable_list.dart' as var_list;

// this page is adapted from flutter chat ui package
// for referenece please refer to the following links:
// https://pub.dev/packages/flutter_chat_ui
// https://docs.flyer.chat/flutter/chat-ui/

//create a stateful widget as well as route name for the navigator
class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.title});

  static const String routeName = "/chatbot";

  final String title;


  @override
  State<ChatPage> createState() => _ChatPageState();
}




class _ChatPageState extends State<ChatPage> {


  List<types.Message> _messages = [];


//create 2 Users: the user itself and the bot
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );
  final _bot = const types.User(
    id: 'nil',
  );

//function for load message
  //TODO: create a load message function for the chatbot
  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);

    });
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }




  //function to receive a response from the server
  //takes in the text from the user
  Future<http.Response> updateLLM(String text) async {
    //craft the http body to send to the server
    final response = await http.put(
      Uri.parse('http://'+var_list.ip_address+':8000/chatbot'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'message': text,

      }),
        encoding: Encoding.getByName("utf-8")
    );

    //check response code
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return response;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      String code = response.statusCode.toString();
      String descp = response.reasonPhrase.toString();
      String received_message =  "Netowrk error\nError code: "+code +'\n'+descp;
      throw Exception(received_message);
    }

  }

  //this is the main function that we will modify
  void _handleSendPressed(types.PartialText message) async {


    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);

    //insert here for bot response

    try{
      final response_msg = await updateLLM(message.text);
    print("RESPONSE MESSAGE:");
    print(response_msg.body);
    //modifying bot message here
    String received_message= await json.decode(utf8.decode(response_msg.bodyBytes));
    String ori_m=received_message;

    //craft a message from the bot
    final returnMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      //text: to_remove_item,
      text:ori_m, //Math.tex(r'\frac a b', mathStyle: MathStyle.text),
    );
    _addMessage(returnMessage);}

    //if an error pops up
    catch (e)
    {
      print("Exception caught");
      setState(() {
        String descp = e.toString();
        descp ="Error encounted:\n\n" +descp;
        final snackBar = SnackBar(
          content: Text(descp),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });

    }





    //Note: Below here is deprecated, this is a test to see if latex rendering works
    //variables test_msg and unconverted_msg is not used
    //received_message= jsonDecode(r'{ "data":'+received_message+r'}')['data'];
    //received_message=received_message.replaceAll(r' ', r'\text{ }');
    //received_message=received_message.replaceAll('\n', r' \\ ');
    //received_message=received_message.replaceAll(r'$$', r'');
    //received_message=received_message.replaceAll('align', 'aligned');
    //received_message = r'\begin{}' +received_message +r'\end{}';
    //print(" received message :$received_message" );

    //final test_msg= types.CustomMessage(
      //  author:_bot,
        //id: const Uuid().v4(),
        //metadata:{'type': 'math', 'tex': r'\\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}',"item":'hi'}
       // metadata:{'type': 'math', 'tex': received_message}
    //);


   // final unconverted_msg= types.CustomMessage(
     //   author:_bot,
       // id: const Uuid().v4(),
        //metadata:{'type': 'math', 'tex': r'\\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}',"item":'hi'}
        //metadata:{'type': 'math44', 'tex': received_message}
    //);



    // _addMessage(test_msg);





   // _addMessage(unconverted_msg);
  }

  void _loadMessages() async {
    final response = await rootBundle.loadString('assets/messages.json');
    final messages = (jsonDecode(response) as List)
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      _messages = messages;
    });
  }


  //Note: I tried to create a latex rendering message output under custom message builder. It works but the message strictly needs to be
  // in latex format catered for the custom message in types.CustomMessage in the deprecated function
  // if type 'math' is detected then it will rendering in latex
  Widget myCustomMessageBuilder(types.CustomMessage message, {required int messageWidth}) {

    if (message.metadata?['type'] == 'math') {
      String texString = message.metadata?['tex'];
      return
         Padding(
          padding: EdgeInsets.all(16.0),
          child: SelectableMath.tex(message.metadata?['tex']),
        );
      return SelectableMath.tex(r"i\hbar\frac{\partial}{\partial t}\Psi(\vec x,t) = -\frac{\hbar}{2m}\nabla^2\Psi(\vec x,t)+ V(\vec x)\Psi(\vec x,t)");
      //return MathMessageWidget(texString: texString);
    } else {
      // ... handle other message types
      return  Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(message.metadata?['tex'])
      );
    }
  }



  @override
  Widget build(BuildContext context) => Scaffold(
    appBar:  AppBar(
      title:  Text(widget.title),
    ),
    body: Chat(
      messages: _messages,
      customMessageBuilder:myCustomMessageBuilder,
      onAttachmentPressed: _handleAttachmentPressed,
      onMessageTap: _handleMessageTap,
      onPreviewDataFetched: _handlePreviewDataFetched,
      onSendPressed: _handleSendPressed,
      showUserAvatars: true,
      showUserNames: true,
      user: _user,
    ),
  );


}

class MathMessageWidget extends StatelessWidget {
  final String texString;

  const MathMessageWidget({required this.texString});

  @override
  Widget build(BuildContext context) {
    return Math.tex(texString, textStyle: TextStyle(fontSize: 16));
  }
}
