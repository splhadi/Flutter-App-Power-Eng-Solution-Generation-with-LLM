import 'dart:math';
import 'constructor_class.dart';


Map stepDefinition={
  'Step 1':"We need to retrieve the basic 3 parameters: GMR, GMD and radius to determine the next parameters",
  'Step 2':"From here, we compute the basic RLC parameters",
  'Step 3':'Retrieve Reactance and Resistance'
};

Map constants={
  'e0':[r'\varepsilon_{0}',8.85*pow(10,-12)]

};

double rho=1.72*pow(10,(-8));

Map setup_R()
{
  Map mapper;

  double compute_r(Map x)=> x[r'\rho']*x['l']/(pi*pow(x['r'],2));
  String formula=r'R = \frac {{\rho} \times {l}} {\pi \times {r}^2}';
  String name='resistance';
  Map parameters={r'\rho':0,'l':0,'r':1};
  String unit=r'\, \Omega / m';

  mapper={'name':name,'parameters':parameters,'function':compute_r,'formula':formula,'unit':unit};
  return mapper;
}
Map setup_L()
{
  Map mapper;

  double compute_l(Map x)=> 2.0*pow(10,-7)*log(x['gmd']/x['gmr']);
  String formula=r'L = 2 \times 10^{-7} ln (\frac {gmd} {gmr})';
  String name='inductance';
  Map parameters={'gmr':1,'gmd':1};
  String unit=r'\, H / m';


  mapper={'name':name,'parameters':parameters,'function':compute_l,'formula':formula,'unit':unit};


 return mapper;
}

Map setup_C()
{
  Map mapper;

  double compute(Map x)=> 2*pi*constants['e0'][1]/log(x['gmd']/x["r"]);
  String formula=r'C = \frac {2\times \pi\times  {'+constants['e0'][0]+r'}} {ln(\frac {gmd} {r})} ';
  String name='inductance';
  Map parameters={'gmd':25,'r':0.03,constants['e0'][0]:constants['e0'][1]};
  String unit=r'\, F / m';


  mapper={'name':name,'parameters':parameters,'function':compute,'formula':formula,'unit':unit};


  return mapper;
}

Map setup_GMD()
{
  Map mapper;

  double compute_gmd(Map x)=> 1.0*pow((x['d_{1}']*x['d_{2}']*x['d_{3}']),(1/3));
  String formula=r'GMD = \sqrt[3]{{D_{1}} \times {D_{2}} \times {D_{3}}} ';
  String name="Geometric Mean Distance";
  Map parameters={'d_{1}':1,'d_{2}':1,'d_{3}':1};
  String unit=r'\, m';


  mapper={'name':name,'parameters':parameters,'function':compute_gmd,'formula':formula,'unit':unit};


  return mapper;
}

Map setup_GMR(int n)
{

  Map mapper;
  double constant=1.09;
  String formula;
  double Function(Map) yo;
  String unit=r'\, m';
if (n==1){

  double compute(Map x)=> x['r']*exp(-1/4);
  formula= r'GMR = {r}\times e^{ - \frac {1}{4}} ';
  yo=compute;
}

else {
  if (n == 4) {
    double compute(Map x) =>
        constant * pow(x['gmr_{cond}'] * pow(x['d'], (n - 1)) , (1 / n));
    formula = r'GMR_{' + n.toString() + r'} = ' + constant.toString() +
        r' \sqrt[' + n.toString() + r'] {{GMR_{cond}} \times {d}^{' + (n-1).toString() +
        r'}}';

    yo=compute;
  }
  else {
    double compute(Map x) => 1.0 * pow(x['gmr_{cond}'] * pow(x['d'], (n - 1)) , (1 / n));
    formula = r'GMR_{' + n.toString() + r'} =  \sqrt[' + n.toString() +
        r'] {{GMR_{cond}} \times {d}^{' + (n-1).toString() + r'}}';
    yo=compute;
  }
}

  String name="Geometric Mean Ratio";
  Map parameters={'gmr_{cond}':1.20,'r':1.0,'d':1.0};


  mapper={'name':name,'parameters':parameters,'function':yo,'formula':formula,'unit':unit};


  return mapper;
}

Map setup_rb(int n)
{

  Map mapper;
  double constant=1.09;
  String formula;
  String unit=r'\, m';

  double Function(Map) yo;
  if (n==1){

    double compute(Map x)=> x['r'];
    formula= r'r_{'+n.toString()+r'} = {r} ';
    yo=compute;
  }

  else {
    if (n == 4) {
      double compute(Map x) =>
          constant * pow(x['r'] * pow(x['d'], (n - 1)) , (1 / n));
      formula = r'r_{' + n.toString() + r'} = ' + constant.toString() +
          r' \sqrt[' + n.toString() + r'] {{r} \times {d}^{' + (n-1).toString() +
          r'}}';
      yo=compute;
    }
    else {
      double compute(Map x) => 1.0 * pow(x['r'] * pow(x['d'], (n - 1)) , (1 / n));
      formula = r'r_{' + n.toString() + r'} =  \sqrt[' + n.toString() +
          r'] {{r} \times {d}^{' + (n-1).toString() + r'}}';
      yo=compute;
    }
  }

  String name="radius of "+n.toString()+" conductors";
  Map parameters={'r':1.0,'d':1.0};


  mapper={'name':name,'parameters':parameters,'function':yo,'formula':formula,'unit':unit};


  return mapper;
}

Map setup_Xl()
{
  Map mapper;

  double compute(Map x)=> 2.0*pi*x['f']*x['l'];
  String formula=r'X_{L} = 2 \times \pi \times {f} \times{L}';
  String name='Reactance(inductance)';
  Map parameters={'f':1,'l':1};
  String unit=r'\, \Omega /m';


  mapper={'name':name,'parameters':parameters,'function':compute,'formula':formula,'unit':unit};


  return mapper;
}
Map setup_Xc()
{
  Map mapper;

  double compute(Map x)=> 1/(2.0*pi*x['f']*x['c']);
  String formula=r'X_{C} =\frac 1 { 2 \times \pi \times {f} \times{c}}';
  String name='Reactance(capacitance)';
  Map parameters={'f':1,'c':1};
  String unit=r'\, \Omega /m';


  mapper={'name':name,'parameters':parameters,'function':compute,'formula':formula,'unit':unit};


  return mapper;
}

String combine_into_Eqn(String formula,String subFormula,String output){
  formula= formula.replaceAll('=', '&=');
  subFormula=subFormula.replaceAll('=', '&=');
  output=output.replaceAll('=', '&=');
  String statement;
  statement=r'\begin{aligned}'+formula + r' \\ ' + subFormula + r' \\ ' + output +r' \end{aligned}';
  return statement;
}