#This is the main file that is used to connect to the server. All domain paths are here. 
#from each path, each langchain function will be called


#import relevant libraries
import json
from fastapi import FastAPI
from pydantic import BaseModel
from fastapi import Depends
from fastapi import FastAPI, UploadFile, File, status,Request,Form,Response
from typing import Annotated
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from PIL import Image
from typing import Annotated,Union
from dotenv import load_dotenv, dotenv_values


#import our own files 
import solver_langchain
import mod_image_text_convert as I2T
import mod_langchain_chatbot


#load all env variables. In this case its all API keys
load_dotenv()  




#initialise all Langchain LLMChains first(refer to report on what is LLMchain)
rag_chain,latex_converter,category_checker,working_converter = solver_langchain.solver_init()
chat_chain = mod_langchain_chatbot.init()

#initialise FastAPI web server
app = FastAPI()

#The first two paths are testing paths, to check if a response is sent
########################################################################
@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/query")
async def query():
    item="Hello from my computer now"
    json_compatible_item_data = jsonable_encoder(item)
    return JSONResponse(content=json_compatible_item_data)

########################################################################
#The rest of the code below is actual domain used for FastAPI server

#chatpot domain path
@app.put("/chatbot")
async def receiver(item:dict):
    print("received chat question!",item)
    #goes into chatbot function under mod_langchain_chatbot.py
    updated_chat_reply= chatbot_response(item)
    return updated_chat_reply

#main domain path, used for question answering of engineering problems
@app.put("/send-question-problem")
async def solver_receiver(item:dict):
    print("Beginning solver")
    solved_item = solver_start(item)
    return solved_item

#domain path for image extraction, note that prompt used is a Union as it is unsure what data we receive over the internet
@app.put("/image-extract")
async def image_extract( image: UploadFile,
    prompt: Union[dict,bool,str,int,list]  ):

    print("Prompt:",prompt,type(prompt))
    print("Image extract function called")
    #save the image first as a temp file before passing it over to the image to text function
    file_directory = 'temp.jpeg'
    image_show = Image.open(image.file)
    image_show.save(file_directory)
    response = I2T.image_to_text(file_directory,prompt)

    return response


#the function to call the chatbot and solution generation is separated here
#this is so that we do not interfere with the path allocated


#solution generation function which takes in all of the LLM chains in solver_langchain.solver_init()
#Note that the passing variable 'refine' is set to false, which means that stage 3: solution refining is disabled first. 
#this is because solution refining needs more work 
def solver_start(text):
    answer = solver_langchain.invoke_cmd(rag_chain,latex_converter,category_checker,working_converter,text['message'],False)
    return answer


#function for the response of the chatbot, takes in the LLMchain for chat as well as the message from flutter
def chatbot_response(text):
    answer= mod_langchain_chatbot.call_langchain(chat_chain,text['message'])

    return answer