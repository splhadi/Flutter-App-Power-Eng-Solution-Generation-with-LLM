# Development of Flutter Applications for Power Engineering Solution Generation using Large Language Models
## Server side implementation for the project 
This is the server implementation for this project. All files in this project is python based. Note that you will have to setup all required API KEYS into an `.env` file in order for this project to work.

The server backend currently is deployed in Google Cloud Platform (GCP) Compute Engine servers. All files in this repository are the same as the files in the server.

The hierachy of the python files are shown below:
```
Main files:
|--fast_api.py
   |--solver_langchain.py
  	   |--mod_refine_answer.py
   |--mod_image_text_convert.py
   |--mod_langchain_chatbot.py
```
In this project, `fast_api.py` is the main python file used to initialise the ASGI server in GCP. The folder `pdf` contains any pdf related data files that you wish to store for the LLM model to read and store into an Embedded Vector Database.

## To run the server from GCP Compute Engine
### Step 1: Activate conda environment
A conda environment has already been created inside the server.

```
(base) ntudissertationhadi@main-server:~$ conda info --envs
# conda environments:
#
base                  *  /home/ntudissertationhadi/anaconda3
lc_server                /home/ntudissertationhadi/anaconda3/envs/lc_server

(base) ntudissertationhadi@main-server:~$ 
```

To activate, enter the following command:
```
conda activate lc_server
```

### Step 2: Enter project directory
The folder is under `project_file_v1`. Simply enter the project directory via `cd project_file_v1`.
### Step 3: Run server with nohup command
To run the server with nohup, enter the following command line:
```
nohup uvicorn fast_api:app --host 0.0.0.0 --port 8000 > output.out &
```
This will allow the server to run in the background, even if you have exited out from the ssh terminal. To observe the output from the server end, run the following command:
```
tail -f output.out
```

## To setup up your own environment

Ensure that you have created a virtual environment before proceeding.
Please ensure that you have the following python version:
```
python==3.9.18
```
To install all required libraries, `requirements.txt` contains all necessary libraries that project is dependent below. You can install it using the following command:
```
pip install -r requirements.txt
```

Once all packages are installed, you can simply run the server by entering the following command:

```
uvicorn fast_api:app --host 0.0.0.0 --port 8000
```

Note: Please place `.env` file containing all API KEYS in the main directory before running this command.