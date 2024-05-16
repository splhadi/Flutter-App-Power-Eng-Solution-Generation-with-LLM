import 'dart:math';


class Constructor{
  late String itemName;
  late String formulaExpression;
  late String unit;
  late Function storeFormula;
  late Map parameters;
  double constructorAnswer=0;


  Constructor(Map item){
    this.itemName=item['name'];
    this.parameters=item['parameters'];
    this.storeFormula=item['function'];
    this.formulaExpression=item['formula'];
    this.unit=item['unit'];

    //format of subbing in the Function expression is as follows:
    //double compute_r(Map x)=> x['p']*x['l']/x['a'];

    //on right hand side input in your formula, but in the form of Dart's map so it can take in the values
    //name the function any way you need it to be

  }

  double apply( Function f) {
    return f(this.parameters);
  }

  double apply_formula(){

    return storeFormula(this.parameters);
  }

  String return_formula()
  {
    return this.formulaExpression;

  }

  String return_SubsitutedFormula()
  {
    String formulaLowerCase;
    String itemFinder,itemReplace,value;
    List splittedString;

    splittedString=this.formulaExpression.split("=");
    splittedString[1]=splittedString[1].toLowerCase();

   // formulaLowerCase=this.formulaExpression.toLowerCase();
    formulaLowerCase=splittedString.join(' = ');

    for (MapEntry e in this.parameters.entries) {



      itemFinder ="{"+e.key+'}';
      value=check_scientific_term(1.0*e.value);//quick conversion to double form int with 1.0
      itemReplace="{"+value+'}';


      //find the associated formula and replace the output
      formulaLowerCase= formulaLowerCase.replaceAll(itemFinder,itemReplace);



    }//end of for loop

    return formulaLowerCase;

  }

  String return_answer_output() {
    double answer;
    String latexAnswer;
    answer = this.apply_formula();
    this.constructorAnswer=answer;

    latexAnswer=check_scientific_term(answer);


    return r'= ' + latexAnswer+ this.unit;
  }

  String check_scientific_term(double number){
    String number_string=number.toString();
    String power;
    List split_string;
    String latexFormatNumber;
    double newNo;
    if(number_string.contains('e'))
      {
        //number too big or too small, need to convert
        split_string=number_string.split('e');
        newNo=double.parse(split_string[0]);
        power=split_string[1];
        latexFormatNumber=newNo.toStringAsFixed(3)+r'\times 10^{'+power+'}';

      }

    else
      {
      latexFormatNumber=number.toStringAsFixed(3);

      }
    return latexFormatNumber;
  }

  void adjust_parameters(String key, double item)
  {
    this.parameters[key]=item;

  }

  //in the event that all variables change inside the constructor, call this function
  void modify_attributes(Map item){
    this.itemName=item['name'];
    this.parameters=item['parameters'];
    this.storeFormula=item['function'];
    this.formulaExpression=item['formula'];

    //format of subbing in the Function expression is as follows:
    //double compute_r(Map x)=> x['p']*x['l']/x['a'];

    //on right hand side input in your formula, but in the form of Dart's map so it can take in the values
    //name the function any way you need it to be

  }


}
