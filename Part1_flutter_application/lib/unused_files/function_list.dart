import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'to_remove.dart';
import 'package:directed_graph/directed_graph.dart';
import 'package:math_parser/math_parser.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:function_tree/function_tree.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'latex_converter.dart';



void read_file()async {
  String item = await _read();
print(item);

}
Future<String> _read() async {
  String text='' ;
  try {
    print("trying");
    final Directory directory = await getApplicationDocumentsDirectory();
    print('${directory.path}/assets/formula.txt');
    final File file = File('/assets/formula.txt');
    text = await file.readAsString();
  } catch (e) {
    print("Couldn't read file");
  }

  String assetPath = 'assets/formula.txt';

  // Load the text file.
   text = await rootBundle.loadString(assetPath);

  // Return the text.
  return text;



  return text;
}

List list_of(){
  String item=to_remove_item;
  List stuff=item.split('\n');

  return stuff;

}

//this function runs for each formula
Map<String,Set<String>> retrieve_variables(String eqn,Set condition)
{
  bool t=eqn.contains(',');
 // print("$eqn contain: $t");
  if (t==true){
    List checker=eqn.split(',');
    if (!condition.contains(checker[1]))
      return {};

  }
  List<String> check1=eqn.split(',');
  //List<String> split=eqn.split(new RegExp(r'[^\w\s0-]+'));
  List<String> split=check1.first.split(new RegExp(r'[^\w\s0-]+'));
  //print(split);
  List toremove=[];


  split.forEach((element)=>{
    //remove special characters
    if (isNumeric(element))
      {
        toremove.add(element)
      }

  });
  //remove numbers
  split.removeWhere( (e) => toremove.contains(e));
  List<String> noDuplicatesplit = split.toSet().toList();

  //takes out the first variable and convert remaining list to set
  //sublist performs list slicing by removing first variable in list
  Map<String,Set<String>> graph_connector={noDuplicatesplit[0]:noDuplicatesplit.sublist(1).toSet()};


  return graph_connector;


}
bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}



DirectedGraph graph_node(Map<String,Set <String>> graph_data)
{
  int comparator(String s1, String s2) => s1.compareTo(s2);
  int inverseComparator(String s1, String s2) => -comparator(s1, s2);

  // Constructing a graph from vertices.
  final graph = DirectedGraph<String>(
   graph_data,
    comparator: comparator,
  );


  //print(graph.shortestPaths('r'));

  //test with real variables
  //review exercise 18 start: D1=D2=D3,d,r,n=2 GMRcond, rho
  //end variable R,L,C

return graph;
}

List return_all_paths(DirectedGraph graph_node,Set start_var,Set end_var)
{
List path=[];
end_var.forEach((i) {
  start_var.forEach((j) {
    //print("Checking $i and $j");
    List tester=graph_node.shortestPath(i, j);
    if (tester.length>1)
      {
        //print("Path exist for $i and $j");
        path.add(tester);

      }
  });

});//end var iteration

return path;
}

Map<dynamic,Set<dynamic>> organise_step_solver(List paths){
  //this is for per final variable, this function needs to be iterated in order to get all final variables
  int i =0;
  String init="Given variables";
  String step="Step ";
  Map<dynamic,Set<dynamic>> solution={};
  int length=0;

  paths.forEach((element) {
    //iterate for each path
    if (element.length>length)
      {
        length=element.length;
      }

  });//get longest length of the current graph branch

  print(length);

  for (int x=length;x>0;x--)
    {
      Set temp={};


      paths.forEach((element) {
        if (x==length)
          {
            temp.add(element[element.length-1]);
          }
        else{

          if(x<element.length)
            {

              temp.add(element[x-1]);
            }


        }

      });//end of list iteration


      if (x==length)
        {
          solution[init]=temp;

        }
      else
        {
          solution[step+i.toString()]=temp;

        }
      i++;
    }//end of for loop
  //print(solution);
  return solution;
}

Map<dynamic,Set<dynamic>>  solver(Map<dynamic, Set<dynamic>> stepSolver,List dependencies){

  print(stepSolver);
  Map<dynamic,Set<dynamic>>  newStepSolver={};
  stepSolver.forEach((key, value) {
    if (key=='Given variables')
      {
        //sub in the values
        newStepSolver[key]=value;
      }
    else
      {
        //iterate value again as it is a set
        Set temp={};
        value.forEach((element) {

          List item=r_formula(element, dependencies);
          //List item=[element,formula];
          temp.add(item);

        });
        newStepSolver[key]=temp;



      }

  });


  return newStepSolver;

}

List r_formula(String variable,List dependencies){
  String type_return='';
  String var_item;
  List builder=[];
  dependencies.forEach((element) {
    if (!element['variables'].isEmpty)
    {
      //print(element['variables'].keys.toList().first);

      var_item=element['variables'].keys.toList().first;
     // print("Comparing $var_item to $variable");
      if (var_item==variable)
      {
       // print("TRUE FOUND $var_item to $variable");
        //print(element['variables']);
        type_return= element['equation'];
        builder=[variable,element['variables'],type_return];

      }
      }


    });


  return builder;


  }

  Set check_variables_sufficient(List paths, Map<dynamic, Set<dynamic>>  stepSolver)
  {
    //convert paths 2d to 1d list first
    // Convert the multi-dimensional list to a 1D list.
    //print(paths);
    List oneDimList = paths.expand((x) => x).toList();
    // Print the 1D list.
    oneDimList=oneDimList.toSet().toList();
    //print(oneDimList);
    List dependent_var=decompose_step_solver(stepSolver);

    //convert all to set
    Set set1=oneDimList.toSet();
    Set set2=dependent_var.toSet();
    Set diff1=set1.difference(set2);
    Set diff2=set2.difference(set1);
    Set diff=diff1.union(diff2);
    print(diff);

  return diff;

  }

  List decompose_step_solver(Map<dynamic, Set<dynamic>>  stepSolver)
  {
    List temp=[];
    stepSolver.forEach((key, value) {
      if (key=='Given variables')
        {
          temp.addAll(value.toList());

        }
      else{
         //iterate through each set in the step n   
        List temp_2d=[];
       // print(key);
        value.forEach((element) {
        //  print(element);
          Map item=element[1];
          //iterate over the var {main variable: required variables in a set}
          item.forEach((key, value) {
            
            temp_2d.add(key);
            temp_2d.addAll(value.toList());
          });
          temp.addAll(temp_2d);
          
        });
        
      }


    });
  temp=temp.toSet().toList();
  return temp;
  }

 Future<Map<dynamic,Set<dynamic>>> get_answer (Map<dynamic, Set<dynamic>> solver,Map start_variable) async
  {
    Map<String,num> temp_variable={};
    List tempv2=[];
    List var_temp=[];

    //temp_variable.addAll(start_variable);


    //convert the temp variable value from string to item if applicable
    start_variable.forEach((key, value) {
      if (isNumeric(value))
        {

          temp_variable[key]=double.parse(value);
          tempv2.add(key+'='+value);
          var_temp.add(key);


        }

    });
     print(temp_variable);
     print(tempv2);


    //now we iterate through the map solver from given variables to step n
    solver.forEach((key, value) {

      print("currently $key $value");
      if (key!="Given variables")
        {//now we iterate over each value, what variables are needed
          value.forEach((element)  {
            //each element consist of [main variable, variables dependent, formula]
            //in this case we take out index 2 of element which is the formula

            String formula = element[2];
            String main_var = element[0];

            List split_formula = formula.split(RegExp(r'[,]'));
            //reusing variable formula again
            formula = split_formula[0];

            //using math parser to evaluate equation
            print('Evaluating : $main_var');
            print('provided variables: $tempv2');
            print('Formula: $formula');
            //just send everything to mathjs easier
            tempv2.add(formula);
            var_temp.add(main_var);

            List split_equal=formula.split('=');
            //try to convert to latex while they are addinh
            List<String> depend_var=element[1][element[0]].toList();
            print(depend_var);
            print(split_equal[1]);
            String inputter=split_equal[1];
            final f = inputter.toMultiVariableFunction(depend_var);
            //print(f.tex);
            String into=element[2];
            print("Entering convert to latex: $formula");
            String latex_eqn= convert_to_latex(formula,element[1][main_var]);
            element.add(latex_eqn);
            print(element);



            //final f = split_equal[1].toMultiVariableFunction(depend_var);
            //print(f.tex);

          });//end of value iteration
          //print(tempv2);

}

    });

    //try to send to mathjs
    final response= await mathjs_post(tempv2);
    //print(response['result']);
   // print(var_temp);

    Map answer={};
    for (int i=0;i<var_temp.length;i++)
      {
        final converted_response=await imag_expression(response['result'][i]);
        answer[var_temp[i]]=converted_response;


      }
    print(answer);

    //now to add in the results in the solver
    solver.forEach((key, value) {
      if (key!="Given variables"){
        //print(key);
        //pr/int(value);
        value.forEach((element) {

          //print(element[3]);
          String formula = element[2];
          List split_formula = formula.split(RegExp(r'[,]'));
          //reusing variable formula again
          formula = split_formula[0];
          //subsitute the stuff in here
          String sub_eqn_string=sub_eqn(formula, answer,element[1][element[0]]);
          String varia=element[0];
          print("var:$varia $sub_eqn_string");
          element.add(sub_eqn_string);
          element.add(answer[element[0]]);



        });

      }


    });

    //print(solver);
    print('end of function');
   // print(step_organiser(solver));
    return solver;
  }

  List step_organiser( Map<dynamic, Set<dynamic>>  solver)
  {
    List step_sol=[];

    //focus on the steps first
    solver.forEach((key, value) {
      if (key!="Given variables")
        {
          
          int len=value.length;
            int i=0;
            value.forEach((element)
            {
              String title="";
              List temp=[];
              if (len>1)
                {
                  title=key+String.fromCharCode(65+i);
                  i++;
                }
              else{

                title=key;
              }
              String intro=title+ ": Retrieve variable "+element[0];
              temp.add(intro);
              temp.add(element[3]);
              temp.add(element[4]);
              temp.add(element[5]);
            
            step_sol.add(temp);
            });//iterate over set





      

        }//if key is not given variables


    });




    return step_sol;
  }



Future<http.Response> fetchmathjs() async {
  final response = await http.get(Uri.parse('https://api.mathjs.org/v4/?expr=4%2B5i%2F4-5i'));
  print(response.body);
  return response;
}

 mathjs_post(List expr) async  {
  //print("Entering async futur post");
  
  final response = await http.post(Uri.parse('https://api.mathjs.org/v4/'),
  headers: <String,String>{'content-type': 'application/json'},
      body:convert.jsonEncode(<String,dynamic>  {
        "expr":
          expr

        ,
        "precision": 14
      })

  );
  print(response.body);
  
  return convert.jsonDecode(response.body);
}

Future<List> main_function_solver() async
{
  //can try to run setup here
  //String expr='v=i*r';
  //final out=MathNodeExpression.fromString(expr,variableNames:{'i','v','r'});
  List items=list_of();
  List dependencies=[];
  Map<String, Set<String>> graph_linker={};
  Map equations;
  // print(items);

  Set start={'D','d','r','n','GMRcond','rho','pi','ep','l'};
  Map start_variable={'D':'4.00','d':'0.2','r':'7.5e-3','n':'2','GMRcond':'5.841e-3','rho':'1.78e-8','pi':'pi','ep':'8.85e-12','l':'1'};
  //Set end={'A_m','B_m','C_m','D_m'};
  Set end={'R','L','C'};
  //another tutorial set
  //start={'V','S','pf','R','L','C','pi','f','i'};

  Set conditions={'n=2','D1=D2=D3','l=T'};

  //another tutorial set
  start={'D1','D2','D3','GMRcond','r','d','n','ep'};
  start_variable={'D1':'8','D2':'8','D3':'16','GMRcond':'0.0142036','r':'0.0175514','d':'0.45','n':'2','ep':'8.85e-12'};
  end={'L','C'};
  conditions={'n=2','D1!=D2!=D3'};

  //another tutorial set
  start={'V','S','pf','R','L','C','pi','f','i'};
  start_variable={'V':'138000','S':'30e6','pf':'0.85','R':'0.186','L':'2.6e-3','C':'0.012e-6','pi':'pi','f':'50'};
  conditions={'l=pi'};
  end={'A_m','B_m','C_m','D_m'};


  // begin to extract all formula in list
  items.forEach((element)=>
  //code
  dependencies.add({'equation':element,'variables':retrieve_variables(element,conditions)})

  );
  print(items);
  items.forEach((element)=>
  //code

  graph_linker.addAll(retrieve_variables(element,conditions)));

  //print(graph_linker);
  // print(dependencies);
  DirectedGraph graph=graph_node(graph_linker);

  //test with real variables
  //review exercise 18 start: D1=D2=D3,d,r,n=2 GMRcond, rho
  //end variable R,L,C

  List path;
  path=return_all_paths(graph, start, end);
  print("Possible paths:");
  print(path);

  Map<dynamic,Set<dynamic>> solver_data=organise_step_solver(path);
  Map<dynamic,Set<dynamic>>  something=solver(solver_data,dependencies);
  //print(something);
  Set diff=check_variables_sufficient(path, something);
  print("Checking missing variables: $diff ");
  if (diff.length>1)
  {
    //SOP alert to user that variable input not enough

    print("Variables not enough! $diff ");
    print(diff.length);
  }

  print('Now we here $something');



  final Map<dynamic,Set<dynamic>> step_sol = await get_answer(something, start_variable);
  final  final_solution=step_organiser(step_sol);

return final_solution;
}