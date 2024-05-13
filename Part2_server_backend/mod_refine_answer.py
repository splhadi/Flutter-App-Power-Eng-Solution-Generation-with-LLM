
from langchain.agents import Tool
from langchain.agents import load_tools
from langchain.agents import initialize_agent
from langchain.chains import ConversationChain
from langchain.prompts.prompt import PromptTemplate
from langchain_google_genai import GoogleGenerativeAI
from langchain.schema.runnable import RunnablePassthrough

from langchain_community.utilities.wolfram_alpha import WolframAlphaAPIWrapper
from langchain.chains import LLMMathChain
from langchain_experimental.utilities import PythonREPL
from langchain.chains import LLMChain,SequentialChain
import ast
import textwrap
import os
from dotenv import load_dotenv, dotenv_values
load_dotenv()  


#os.environ["GOOGLE_API_KEY"] = API_KEY
#os.environ["OPENAI_API_KEY"] = OPENAI_API_KEY

#create 2 llms for refining answer
llm_agent = GoogleGenerativeAI(model="gemini-pro", convert_system_message_to_human=True, temperature=0)
llm_prompt = GoogleGenerativeAI(model="gemini-pro", convert_system_message_to_human=True, temperature=0)



#Tools section for LLM Agent

#tool for language model
llm_chain_prompt = PromptTemplate(template = 'Provide the solution via cmath or python code. DO NOT RETURN OUTPUT. Return ONLY python CODE: {text}',input_variables= ['text'])

llm_chain = LLMChain(
    llm= llm_prompt,
    prompt=llm_chain_prompt,
    verbose = True


)

llm_tool_v2 = Tool(
    name="Language Model (LLMChain)",
    func=llm_chain.run,
    description="Use this tool to create a solution "
)

#tool for code output
python_repl = PythonREPL()

repl_tool = Tool(
    name="python_repl",
    description="A Python shell. Use this to execute python commands. Input should be a valid python command. If you want to see the output of a value, you should print it out with `print(...)`.",
    func=python_repl.run,
)

#tool for LLMmaths
llm_math = LLMMathChain.from_llm(llm_prompt, verbose=True)
math_tool = Tool(
    name='Calculator',
    func=llm_math.run,
    description='Useful for when you need to answer questions about math.Convert j into *j before using this function'
)

#tool for wolfram alpha
#os.environ["WOLFRAM_ALPHA_APPID"] = WOLFRAM_ALPHA_APPID
wolfram = WolframAlphaAPIWrapper()

wolfram_tool = Tool(
    name= 'Wolfram alpha',
    func=wolfram.run,
    description="Use when doing complex calculations. Note to remove all units and simplify working first before input."


)

#consolidate all tools
new_tools=[]
new_tools.append(wolfram_tool)
new_tools.append(repl_tool)
new_tools.append(math_tool)

#agent initialisation
conversational_agent = initialize_agent(
#agent="conversational-react-description",
#agent="zero-shot-react-description",
#agent="self-ask-with-search",
tools=new_tools,
llm=llm_agent,
verbose=True,
max_iterations=5,
#memory=memory,
handle_parsing_errors=True,
return_intermediate_steps=True

)


#LLM prompts and chain
dict_prompt = PromptTemplate(
    template="context = '''{context}'''\n\n  from the context given, extract ALL WORKING NUMERICAL EXPRESSIONS into python dictionary with the following format and in ONE LINE:\nformat = \u007bformat\u007d\nFOLLOW THE FORMAT CLOSELY.  "
    , input_variables=['context','format'])

dict_converter = LLMChain(
    llm=llm_prompt,
    prompt=dict_prompt,
    verbose=True,
    # memory=memory,#<-- causing problem
    output_key="dict_answer",

)


#context LLM chain with prompt set to update the answer of solution based on what was calculated by the agent
context_prompt = PromptTemplate(
    template="context= '''{context}'''\n{variable_symbol} = {variable_answer}\nUpdate the context with the new value of {variable_symbol}. DO NOT EDIT ANYTHING ELSE. DO NOT BOLD ANY ANSWER."
    , input_variables=['context','variable_symbol','variable_answer'])

context_updater = LLMChain(
    llm=llm_prompt,
    prompt=context_prompt,
    verbose=True,
    # memory=memory,#<-- causing problem
    output_key="conv_context",

)

#llm chain to check if the item given is a working, so that agent need not perform any calculation
working_prompt = PromptTemplate(
    template="context= {context}\ncheck if context is a working, return answer in yes or no "
    , input_variables=['context',])

working_checker = LLMChain(
    llm=llm_prompt,
    prompt=working_prompt,
    verbose=True,
    # memory=memory,#<-- causing problem
    output_key="working_check",

)

#from the solution given in stage 2, extract out only workings
#by right if the LLM perfectly understands the prompt given, there is no additional check required by working_checker
#however google's llm lack the capability, so we have to implement additional llm chain
working_extract_prompt = PromptTemplate(
    template="context=''' \n{context}\n'''\nFrom context, extract out workings ONLY"
    , input_variables=['context',])

working_extract = LLMChain(
    llm=llm_prompt,
    prompt=working_extract_prompt,
    verbose=True,
    # memory=memory,#<-- causing problem
    output_key="out",

)


combine_prompt = PromptTemplate(
    template="context=''' \n{context}\n'''\n  calculation_workings='''{working}'''Replace all workings in context with calculation_workings.Return new context and end statement."
    , input_variables=['context','working'])

#combine_llm LLMChain not being used
combine_llm = LLMChain(
    llm=llm_prompt,
    prompt=combine_prompt,
    verbose=True,
    # memory=memory,#<-- causing problem
    output_key="out",

)
dict_chain = {'context':working_extract ,"format":RunnablePassthrough()}| dict_converter
context = """Solve the question first with mathematical accuracy. Show step by step method used.

Current conversation:
{history}
Human: {input}
AI Assistant:

"""
template= context
PROMPT = PromptTemplate(input_variables=["history", "input"], template=template)
conversation_chain = ConversationChain(llm=llm_prompt,
    prompt=PROMPT
)
chat_history = conversation_chain.memory

#end of LLM chains annd prompts

#this function is to convert the LLM output steing into a dict
def string_to_dict(string,stage):
    print("Extracting dictionary... Stage:",stage)
    init_dict = string
    init_dict = init_dict.replace('`','')
    init_dict = init_dict.replace('python', '')
    init_dict = init_dict.replace(' ', '')
    init_dict = init_dict.replace('\n', '')
    init_dict = textwrap.dedent(init_dict)

    try:
        init_dict = ast.literal_eval(init_dict)
        print(stage," stage: Successfully extracted out dictionary:", init_dict)
    except:
        print("New dict storage failed")
        print("Problem in context to convert:", init_dict)

        # bug fixing, slicing the string
        print("Attempting string slicng method")
        try:
            separator = init_dict.find('=')
            init_dict = init_dict[separator + 1:]

            print('Stage:',stage,"dict after slicing:", init_dict)
            init_dict = ast.literal_eval(init_dict)
            print('Stage:',stage," stage after slicing: extracted out initial dictionary:", init_dict)


        except Exception as e:
            print("slicing failed. forefeitting dict")
            print("Error:",e)
            init_dict = 'fail'
    return init_dict




def answer_refining(context):
    print("Enter answer_refining")

    format_string = '{ALL VARIABLE SYMBOL, ALL VARIABLE NUMERICAL EXPRESSIONS}'

    #initial conditions, extract out all dictionary
    #working_only = working_extract.invoke({'context':context})
    #working_only = working_only['out']
    #print('workings:',working_only)


    #bypass for testing
    working_only = context

    #use the working_only LLMChain to extract out all workings 
    response=dict_converter.invoke({'context':working_only,'format':format_string})
    init_dict= response['dict_answer']
    context_to_convert= working_only #context

    #remove characters
    init_dict = string_to_dict(init_dict,'Initial')
    print("Stage 1:extracted out initial dictionary:",init_dict)
    final_dict={}

    #store keys into initial conditions
    variables_list = [i for i in init_dict.keys()]
    print(variables_list)
    failed_list =[]


    #loop to update all variables
    #refer to report on what this for loop does under section 7.3.3.2 Algorithm design
    for item in init_dict.keys():
        variables_list.remove(item)
        to_check = init_dict[item]

        #check if variable is a working

        working_check_decision = working_checker.invoke({'context':to_check})
        working_check_decision = working_check_decision['working_check']

        arithmetic_symbols = ['/','*','+','=','-']
        ari_check = any(ele in to_check for ele in arithmetic_symbols)

        print('variable:',item,'checking:',to_check,'\nLLMdecision:',working_check_decision)
        print("Final boolean decision to check:",('yes' in working_check_decision and ari_check) or ari_check)

        if ('yes' in working_check_decision and ari_check) or ari_check:
            #use agent to check

            message = 'check the statement using a calculator and RETURN TOOL OUTPUT ONLY: \n\n' + to_check + '\n\nnote that j is an imaginary unit.'
            tries = 5
            for i in range(tries):
                print(f"Attempting try:{i}/{tries}")
                print('checking:', to_check)

                try:
                    return_msg = conversational_agent(
                        {
                            "chat_history": chat_history,
                            "input": message
                        }
                    )
                    #print('*' * 50, "\nStatement:", statement, 'steps:', '\n\n', return_msg['intermediate_steps'],
                      #    '\n\nactual result:', return_msg['output'], '\n', '*' * 50)
                    #print("checking output for stopped iteration")

                    if 'iteration limit' in return_msg['output'] or 'time limit' in return_msg['output']:
                        print('Detected iteration limit end. Extracting iteration step')
                        retrieved_answer = return_msg['intermediate_steps'][-1][-1]
                        retrieved_answer = retrieved_answer.replace('Answer:','')
                        print("Retrieved answer:", retrieved_answer)
                    else:
                        print("No iteration limit detected")
                        retrieved_answer = return_msg['output']

                    # store the answers
                    final_dict[item] = retrieved_answer

                    # need cycle through each solution to update via function

                    break
                except Exception as e:
                    #forces agent to use pythonREPL tool, which is more reliable
                    print("Exception occured:", e)
                    print('forbidden control characters' in str(e))
                    if 'forbidden control characters' in str(e) or 'invalid syntax' in str(e):
                        message = 'check the statement without using a calculator and use pythonREPL or wolfram tool and RETURN TOOL OUTPUT ONLY: \n\n' + to_check + '\n\nnote that j is an imaginary unit.'
        else:
            continue
            #final_dict[item]=to_check
        #in this section the variables are assumed to be updated, thus we will update in context first.

        print("Current final dict:",final_dict)

        temp_context = context_updater.invoke({'variable_answer':final_dict[item],'variable_symbol':item,'context':context_to_convert})
        
        #sometimes LLMchain forgets its input and result in this answer, create a if else loop to check for this
        if 'The provided context does not contain any information' not in temp_context['conv_context']:
            print("Succefully updated:",item)
            context_to_convert = temp_context['conv_context']

            print("New context after prompt for dict below ","\u2193"*5)#,context_to_convert)
        else:
            failed_list.append(item)
            print("Failed to update:",item,'\ncontext:',temp_context['conv_context'])

        #extract out again variables into dict

       # working_only = working_extract.invoke({'context': context_to_convert})
       # working_only = working_only['context']
        response = dict_converter.invoke(
            {'context': context_to_convert, 'format': format_string})
        loop_dict = response['dict_answer']

        loop_dict = string_to_dict(loop_dict,'Looping')
        if not 'fail'==loop_dict:
            for item_temp in loop_dict.keys():
                if item_temp in variables_list:
                    print(f"Replacing:{item_temp}Variables left{variables_list}")
                    init_dict[item_temp] = loop_dict[item_temp]



    print("Items failed to update:",failed_list)

    
    #context_to_convert= combine_llm.invoke({'context':context,'working':context_to_convert})
    print("Finish answer_refine.returning answer")
    return context_to_convert
    




#Below are strings used for testing


string_test="""
 Given Data:

Voltage (V) = 765 kV
Frequency (f) = 60 Hz
Number of conductors per phase (m) = 4
Conductor diameter (d) = 3.625 cm = 0.03625 m
GMR (GMRb) = 1.439 cm = 0.01439 m
Bundle spacing (D) = 45 cm = 0.45 m
Line length (l) = 400 km = 400000 m
Base voltage (V_base) = 765 kV
Base power (S_base) = 2000 MVA
Per unit impedance (Z_pu) = 0.8 + j0.6
Per unit voltage (V_pu) = 1.0 pu
Per unit current (I_pu) = 1.0 pu
Complex power (S) = 1920 MW + j600 MVar

Calculations:

1. Calculate the characteristic impedance (Z_c) of the transmission line:

Z_c = √(L/C)

Inductance (L) = 2 * 10^(-7) * ln(GMDb/GMRb)
= 2 * 10^(-7) * ln((m * D^3)^(1/3) / GMRb)
= 2 * 10^(-7) * ln(((4 * 0.45^3)^(1/3)) / 0.01439)
= 7.809624364476772e-07 H/km

Capacitance (C) = 2 * π * ε / ln(GMDb/rb)
= 2 * π * 8.85 * 10^(-12) / ln((m * D^3)^(1/3) / rb)
= 2 * π * 8.85 * 10^(-12) / ln(((4 * 0.45^3)^(1/3)) / 0.03625)
= 0.0113 μF/km

Z_c = √(7.809624364476772e-07 / 0.0113 * 10^(-6))
= 836.5 Ω

2. Calculate the sending-end voltage (V_s) and current (I_s):

V_s = V_pu * V_base
= 1.0 * 765 kV
= 765 kV

I_s = S / V_s
= (1920 MW + j600 MVar) / 765 kV
= 2.514 - j0.784 kA

3. Calculate the receiving-end voltage (V_r):

V_r = V_s * exp(-j * Z_c * l / V_base)
= 765 kV * exp(-j * 836.5 Ω * 400000 m / 765 kV)
= 765 kV * exp(-j * 420)
= 765 kV * (cos(-420) + j sin(-420))
= 765 kV * (0.766 - j0.644)
= 587.9 kV - j493.6 kV

4. Calculate the receiving-end current (I_r):

I_r = I_s * exp(-j * Z_c * l / V_base)
= 2.514 kA - j0.784 kA * exp(-j * 420)
= 2.514 kA - j0.784 kA * (cos(-420) + j sin(-420))
= 2.514 kA - j0.784 kA * (0.766 - j0.644)
= 1.928 kA + j1.216 kA

5. Calculate the receiving-end complex power (S_r):

S_r = V_r * I_r*
= (587.9 kV - j493.6 kV) * (1.928 kA + j1.216 kA)
= 1175.8 MW + j756.4 MVar

Therefore, the receiving-end voltage is 587.9 kV - j493.6 kV, the receiving-end current is 1.928 kA + j1.216 kA, and the receiving-end complex power is 1175.8 MW + j756.4 MVar.

"""

string_test2 ='''
Given data:

Voltage (V) = 345 kV
Frequency (f) = 60 Hz
Length of transmission line (l) = 200 km
Per phase series impedance (Z) = (0.032 + j0.35) Ω/km
Per phase shunt admittance (Y) = j4.2 x 10-6 S/km
Load power (P) = 700 MW
Power factor (pf) = 1
Voltage at receiving end (Vr) = 0.95 * 345 kV = 327.75 kV
Base voltage (Vb) = 345 kV
Base power (Sb) = 1,000 MVA

(a) ABCD parameters of the line:

The ABCD parameters for a nominal-π equivalent circuit are given by:

A = (Z*Y)/2 + 1
B = Z
C = Y * ((Z*Y)/4 + 1)
D = (Z*Y)/2 + 1

Substituting the given values:

Z = (0.032 + j0.35) Ω/km * 200 km = 6.4 + j70 Ω
Y = j4.2 x 10-6 S/km * 200 km = j0.00084 S

A = ((6.4 + j70) * j0.00084)/2 + 1 = 0.999 + j0.035
B = 6.4 + j70
C = j0.00084 * ((6.4 + j70) * j0.00084/4 + 1) = j0.000004
D = ((6.4 + j70) * j0.00084)/2 + 1 = 0.999 + j0.035

Therefore, the ABCD parameters of the line are:

A = 0.999 + j0.035
B = 6.4 + j70
C = j0.000004
D = 0.999 + j0.035

'''

#run function here
#final =answer_refining(string_test2)
#print("Loading refine answer done!")
#print("final answer:",final)