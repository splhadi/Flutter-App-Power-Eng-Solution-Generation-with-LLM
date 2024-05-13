
import google.generativeai as genai
import ast
import textwrap
import os

from pathlib import Path

from dotenv import load_dotenv, dotenv_values
load_dotenv()  




#os.environ["GOOGLE_API_KEY"] = API_KEY
#os.environ["OPENAI_API_KEY"] = OPENAI_API_KEY


#function for image to text recognition 
def image_to_text(image_directory,prompt_text):

    #if prompt text is nil it is from the solver image to text. so only image to text converter is needed
    if prompt_text=="nil":
        input_prompt =  "Convert the following image to text ONLY. return ALL symbols in ASCII number format:\n"

    else:
        input_prompt = "Follow the instructions given:\n"+prompt_text

    #extract api key from env and input into genai
    API_KEY = os.environ["GOOGLE_API_KEY"]
    genai.configure(api_key=API_KEY)

    #set temperature to 0 to strictly return logical input
    generation_config = {
        "temperature": 0.0,

    }
    model = genai.GenerativeModel(model_name="gemini-pro-vision",generation_config=generation_config)

    #find image directory
    if not (img := Path(image_directory)).exists():
        raise FileNotFoundError(f"Could not find image: {img}")
    image_parts = [
        {
            "mime_type": "image/jpeg",
            "data": Path(image_directory).read_bytes()
        },
    ]

    prompt_parts = [
        input_prompt,
        image_parts[0],
    ]

    #send a response to genai
    response = model.generate_content(prompt_parts)
    print(response.text)
    text_response = response.text
    return text_response

