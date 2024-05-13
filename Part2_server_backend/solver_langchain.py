#this is the main solution generation python file
#its only dependencies is mod_refine_answer.py which refines the answer from stage 2

#import relevant libraries
from langchain.document_loaders import PyPDFDirectoryLoader
import ast
from langchain import HuggingFacePipeline, PromptTemplate
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.memory import ConversationBufferMemory
import os
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain,SequentialChain
from langchain.vectorstores import Chroma
from langchain.embeddings import OpenAIEmbeddings
from langchain.embeddings import GooglePalmEmbeddings
from langchain.schema.runnable import RunnablePassthrough
import textwrap,inspect
from dotenv import load_dotenv, dotenv_values

#load env keys
load_dotenv()  

#dependent files
import mod_refine_answer


def solver_init():


    # Embed and store splits


    from langchain.llms import GooglePalm
    import google.generativeai
    from langchain_google_genai import GoogleGenerativeAI
    
    #last time we stored api keys under API_KEYS. upon deployment we move it to env files to avoid any compromise
    #os.environ["GOOGLE_API_KEY"]=API_KEY
   
    #load Gemini pro as our main llm
    llm = GoogleGenerativeAI(model="gemini-pro",convert_system_message_to_human=True, temperature=0)
    print('llm loaded')

    #Step 1 to Step 4 initialise RAG to refer to formula.pdf in pdf folder


    #Step 1: Load documents
    print("Loading documents")
    loader = PyPDFDirectoryLoader('pdf')
    print("Document loaded")

    #Step 2: split documents
    text_splitter = RecursiveCharacterTextSplitter(chunk_size = 1000, chunk_overlap = 200)
    splits = text_splitter.split_documents(loader.load())
    print("Document splitted")

    #Step 3: Documents embedding
    print("embeding docs")
    vectorstore = Chroma.from_documents(documents=splits,embedding=GooglePalmEmbeddings())
    print("Docs embedded. creating vector store retriever")

    #Step 4: Create retriever
    retriever = vectorstore.as_retriever(search_type="similarity", search_kwargs={"k": 6})
    print("vector store retriever for pdf created")

    #below is an experimental prompt for RAG. you can have a look if you want to improve retrieval
    # Prompt
    # https://smith.langchain.com/hub/rlm/rag-prompt
    from langchain import hub
    #rag_prompt = hub.pull("rlm/rag-prompt")




    #Below are all prompts and chain required for langchain

    #below are all the prompts for each respective LLMchain

    #prompt for RAG which takes in the context, extracted from RAG and the question provided by flutter
    # this is where the question is sent from flutter, which is from the image to text conversion
    template_v2='''
    Formula given:{context}
    
    Solve questions based on formula or context given.
    Calculate accurately.
    
    Question:{question}
    
    '''
    rag_prompt_custom = PromptTemplate.from_template(template_v2)


    #Deprecated prompt. this was initially used for answer refining but i changed it later on
    workings_text = """
    
    context =""
    {context}
    
    ""

    from context, return ALL VARIABLES with WORKINGS into python dictionary with the following format and in ONE LINE:
    format = {format}
    
    """
    working_template = PromptTemplate(template=workings_text, input_variables=['context','format'])

    #prompt to convert text into latex format used in flutter math latex library
    latex_text='''
    Remove any New lines and DO NOT ADD DATA.
    Add spaces between variables.
    Convert the following equation or text into flutter_math_fork tex format:
    "{text}"
    '''
    latex_template = PromptTemplate(template=latex_text,input_variables=['text'])

    print('rag prompt')

    #prompt used to categorise each text given
    category_text = """
    is the following statement equation, statement or variables:
    {text}
    """

    category_template = PromptTemplate(template=category_text, input_variables=['text'])



    #main LLM chain used to generate a solution
    #refer to report on how this chain is made
    rag_chain = (

        {"context": retriever, "question": RunnablePassthrough()}
        | rag_prompt_custom
        | llm
    )


    #llm chain for text to latex converter
    latex_converter = LLMChain(
        llm=llm,
        prompt=latex_template,
        verbose=True,
        output_key="latex_answer",
    )


    #deprecated chain
    working_converter = LLMChain(
        llm=llm,
        prompt=working_template,
        verbose=True,
        # memory=memory,#<-- causing problem
        output_key="working_dict",
    )

    #categorise LLM chain for latex conversion in stage 4. will be explained later down
    category_checker = LLMChain(
        llm=llm,
        prompt=category_template,
        verbose=True,
        # memory=memory,#<-- causing problem
        output_key="output",
    )
    return rag_chain,latex_converter,category_checker,working_converter


#Deprecated function. Function shifted to mod_refine_answer.py
def correction(working_converter,message):
    received_dict=working_converter.invoke({'context':message,'format':'{variable symbol,variable workings,variable answers}'})
    received_dict= received_dict['working_dict']
    print("received dict before split is:", received_dict)
   # received_dict=received_dict.split('=')[-1]
    print("received dict after split is:",received_dict)
    received_dict = inspect.cleandoc(received_dict)
    conv_dict = ast.literal_eval(received_dict)
    print('workings:',conv_dict)

    return ''

#main function called from fastapi.py for solution generation
def invoke_cmd(rag_chain,latex_converter,category_checker,working_converter,query,refine):
    #first we pass through the question into the RAG chain to generate a solution in stage 1
    message = rag_chain.invoke(query)
    print(message)

    #attempt correction of solutions here

    #if refine is set to true, the solution will be refined to get its math corrected
    #refining is a work in progress, so pls fix it thanks
    if refine:
        #message_corrected = correction(working_converter, message)

        message = mod_refine_answer.answer_refining(message)

    #we split the message from RAG LLMchain into a list, so it can be converted more accuracy
    #previously, passing though the entire solution result in
    #solution is splitted via 2 new lines
    text_version = message
    list_msg = message.split('\n\n')
    ori_msg=list_msg.copy()
    print("Splitted msg:",ori_msg)


    send_back=''
    #cycle through the splitted solution
    for index, item in enumerate(list_msg):
        #this is where the category LLMchain is used
        #this is mainly to distinguish between text and formula, as we want to convert the formulas
        category= category_checker.invoke({'text': item})
        print("category",category)
        text_bool = False
        #if False:
        #if the item in the splitted list is a statement, below is the boolean for checking
        if "Statement" in category['output'] and "Equation" not in category['output'] and "Variable" not in category['output'] :
           
            #in the event we find a statement, we just wrap it in a \text latex comand
            latex_string = r'\text{'+item+'}'
            to_add=latex_string
            to_add = to_add.replace('_', '')
            #a boolean activated when statement is dound
            text_bool= True
            print("Text found: ",item)
        else:
            #if an equation is found, it will be fed into the LLMchain to convert it into latex format

            converted_ans = latex_converter.invoke({'text': item})
            #extract the value from the key from the llm chain
            to_add = converted_ans['latex_answer']

        #this if else chain is to check if the index is the first item
        #if it is it will not put the delimiter
        #this delimiter is used to combine all of the list into a single string and sent back to the flutter app
        #the flutter app will then use this delimiter to split the text into lists
        if index == 0:
            delimiter = ""
        else:
            delimiter = "%-break-%"

        #bug fix for LLM chain to remove all new lines \n into \\ for latex for statement and equation
        if not text_bool:
            to_add=to_add.replace('\n', r' \\ ')
        else:
            to_add = to_add.replace('\n', r' } \\ \text{ ')

        #bug fix for certain symbols, this need revision
        to_add = to_add.replace(r'$', r'')
        to_add = to_add.replace('*', r' \times ')
        to_add = to_add.replace(r'\quad', r' \\ ')
        to_add = to_add.replace(r'\(', r'\ (')
        to_add = to_add.replace(r'\)', r'\ )')
        
        #if item is not a statement, the converted latex will go through this function to align each equal sign
        if not text_bool:
            to_add=modify_equal(to_add)

        send_back += delimiter+r'\begin{aligned} ' +to_add+' \end{aligned}'
        list_msg[index]= to_add

    #remove any unwanted symbols
    send_back=send_back.replace('```', '')

    #combine both the original text as well as the converted latex
    send_back = text_version +delimiter+ send_back
    return send_back  #str(list_msg)



#to make the equal sign rendering for latex nicer and aligned
def modify_equal(string):
   # print("beginning modify_equal")
    if '=' not in string:
        return string

    statement = string.split(r'\\')
    new_statement = []
    for item in statement:
       # print('loopsing:', item)
        item = item.replace('=', '&=')
        if item.count('&=') > 1:
            list_item = item.split('&=')
        #    print('list_item:',list_item)
            first_item = list_item[0]
            rest_item = r' \\ &='.join(list_item[1:])

            return_list = first_item + '&=' + rest_item
         #   print("return list:", return_list)
            item = return_list

        new_statement.append(item)
       # print("new statement:", new_statement, item)
    new_string = r'\\'.join(new_statement)
   # print('end modify equal')
    return new_string