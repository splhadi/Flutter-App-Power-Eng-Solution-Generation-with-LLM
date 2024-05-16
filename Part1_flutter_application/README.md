# transmission_app

A flutter based application that was initially used to compute transmission lines parameters. The scope of this project has been widened and now serve 3 main purposes:
1. Solution generation
2. Chatbot
3. Image recognition

## Main menu

<p align="center">
<img src="https://github.com/splhadi/NTU_dissertation_Sol_Gen_LLM_with_flutter/blob/main/assets/4_main_menu.png" width ='200'   >
 </p>
 
The main menu to access the subpages mentioned above. The dart file is called [main.dart](https://github.com/splhadi/NTU_dissertation_Sol_Gen_LLM_with_flutter/blob/main/Part1_flutter_application/lib/main.dart/).

## Solution generator

<p align="center">
<img src="https://github.com/splhadi/NTU_dissertation_Sol_Gen_LLM_with_flutter/blob/main/assets/1_sol_gen.png" width ='600'   >
 </p>
 
The subpage that performs image to text, followed by solution generation. The image recognition component carefully processes the query or question supplied in the image. Afterwards, a thorough solution is created, providing users with a resolution to their query. This approach offers customers the ability to customise the presentation according to their tastes, allowing them to choose between LaTeX or text format. The dart file is called [solver_page.dart](https://github.com/splhadi/NTU_dissertation_Sol_Gen_LLM_with_flutter/blob/main/Part1_flutter_application/lib/solver_page.dart).
 
## Chatbot
<p align="center">
<img src="https://github.com/splhadi/NTU_dissertation_Sol_Gen_LLM_with_flutter/blob/main/assets/2_chatbot.png" width ='600'   >
 </p>
 
A Subpage allows users to have conversations with a Language Model
(LLM) that covers a wide range of academic disciplines. This interactive tool enables users to start conversations, ask questions, and seek clarification on certain academic topics of interest. The dart file is called [chatbot.dart](https://github.com/splhadi/NTU_dissertation_Sol_Gen_LLM_with_flutter/blob/main/Part1_flutter_application/lib/chatbot.dart).

## Image Recognition
<p align="center">
<img src="https://github.com/splhadi/NTU_dissertation_Sol_Gen_LLM_with_flutter/blob/main/assets/3_img_recogn.png" width ='600'   >
 </p>
 
Based on the image to text in the Solution Generation subpage, it is expanded to allow prompts to be fed to the LLM. This allows users to utilise this feature to upload photographs for extensive evaluation. Based on the query submitted by the user, the system conducts a complex analysis of the visual content and produces a logical output that corresponds to the subject matter depicted. The dart file is called [bot_image_prompt.dart](https://github.com/splhadi/NTU_dissertation_Sol_Gen_LLM_with_flutter/blob/main/Part1_flutter_application/lib/bot_image_prompt.dart).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
