import "package:math_parser/math_parser.dart";
import 'dart:math';
import 'function_list.dart';

String convert_to_latex(String equation, Set variables)
{
  //check variables within equation

  print("Inside convert to latex function  $equation $variables");


  //replace * with \times
  equation=equation.replaceAll('*',r' \times ');
  equation=equation.replaceAll('(', r'{\left(');
  equation=equation.replaceAll(')', r'\right)}');
  String latex_eqn=equation;
  //check for fraction
  if (equation.contains('/'))
    {
      for (int i=0;i<equation.length;i++)
        {
        //print("inside loop equation $i $equation");
          if (equation[i]=='/')
            {
              int back_bracket_counter='}'.allMatches(equation).length;
              int front_bracket_counter='{'.allMatches(equation).length;
              int diff_bracket_counter=front_bracket_counter-back_bracket_counter;
              String sliced_equation=equation.substring(0,i);

              //case no back_bracket counter
              if (back_bracket_counter==0)
                {
                  //no bracket case, just check the last variable in the string item
                  //cycle through each variable to get the biggest position
                  int temp_position=0;
                  variables.forEach((element) {
                    int check=sliced_equation.indexOf(element);
                    if (check>temp_position)
                    {
                      temp_position=check;

                    }
                    //now last position of variable is retrieved, put the fraction latex command at the last variable

                  });
                  latex_eqn=equation.replaceRange(temp_position,temp_position,r'\frac ');

                }
              else
              {
                //bracket case
                int index= determine_bracket_index(sliced_equation);
                latex_eqn=equation.replaceRange(index,index,r'\frac ');


              }



            }


        }





      }

//end of checking fraction '/' section, replace it with space
 latex_eqn= latex_eqn.replaceAll('/', ' ');



  print('returning $latex_eqn');
  return latex_eqn;
}

int determine_bracket_index(String sliced_eqn)
{
  int pos=0;
  int index=0;
  for (int i=sliced_eqn.length-1;i>=0;i--)
    {
      //print("inside loop sliced equation $i");
      if (sliced_eqn[i]=='}')
        pos++;
      else if (sliced_eqn[i]=='{')
        pos--;

      if (pos<=0)
        {
          index=i;
          break;
        }


    }


  return index;
}

String sub_eqn(String equation,Map answer,Set variables)
{
  List split=equation.split('=');
  equation=split[1];
  answer.forEach((key, value) {
    if (value.contains('i'))
    equation=equation.replaceAll(key,'{('+ value+")}");
    else
      equation=equation.replaceAll(key,'{'+ value+"}");


  });

  return '= '+ convert_to_latex(equation, variables);
}

String power_converter(String number){
  //assume number given is a real number

  double c_num=double.parse(number);
  double power=log(c_num)/log(10);
  print("number received: $number $power");
  double c_num_conv;
  int power_rounded;
  String power_st;
  String converted_number;

  String c_num_str=c_num.toString();
  if(c_num is int || c_num==c_num.roundToDouble())
    {
      //check for int
      converted_number=number;


    }


  //check if number is too big or small

 else  if (c_num_str.contains('e'))
    {

      //number too big or too small, need to convert
     List split_string=c_num_str.split('e');
     double newNo=double.parse(split_string[0]);
     power_st=split_string[1];
     converted_number=newNo.toStringAsFixed(3)+r'\times 10^{'+power_st+'}';



    }
  else if(power>3 || power<-3)
    {
      //perform conversion
      print("Rounding :$power");
      power_rounded=power.round();
      power_st=power_rounded.toString();
      print('num is $c_num power $power_rounded power_pure:$power');
      c_num_conv=c_num/(pow(10, power_rounded));
      converted_number = c_num_conv.toStringAsFixed(3) + r'\times 10^{'+power_st+'}';


      

    }
  else
    {

      converted_number=c_num.toStringAsFixed(3);
    }

  return converted_number;
}
Future<String> imag_expression  (String number) async
{
  String converted_number;
  if (number.contains('i'))
    {
      //imaginary no
      List send=['re('+number+')','im('+number+')'];
      final lt_receive= await mathjs_post(send);

      String real_no=lt_receive['result'][0];
      String imag_no=lt_receive['result'][1];

      if (real_no=='0')
        {

          imag_no=power_converter(imag_no);
          converted_number=imag_no+'i';



        }
      else
        {
          real_no=power_converter(real_no);
          imag_no=power_converter(imag_no);

          if (imag_no[0]=='-')
            converted_number=real_no+'-'+imag_no+'i';
          else
            converted_number=real_no+'+'+imag_no+'i';



        }


    }

  else{
    //real no
    converted_number=power_converter(number);

  }

  return converted_number;
}