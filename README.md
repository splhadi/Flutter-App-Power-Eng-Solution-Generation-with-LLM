# Development of Flutter Applications for Power Engineering Solution Generation using Large Language Models
The code implementation for this project as part of NTU dissertation requirement.

<p align="center">
<img src="https://github.com/splhadi/NTU_dissertation_Sol_Gen_LLM_with_flutter/blob/main/assets/architecture.png" width ='600'   >
 </p>

The image above shows the sofrware architecture which is divided into 3 Systems:
1. System 1: The front-end flutter application, which will be the main form of communication between the user and the server. This system will contain all output data from the server and process it into user readable format.
2. System 2: The Backend server, which is powered by GCP Compute Engine VM. The VM runs the ASGI server Uvicorn, which holds the web framework FastAPI. 
3. System 3: LangChain/GenAI functions, which is the main backend feature of this project. These functions perform all communication with the LLM API model, extract data from the vector database, and perform solution generation and image recognition.

For code implementation wise, System 1 is under the folder [Part 1: Flutter Application](https://github.com/splhadi/NTU_dissertation_Sol_Gen_LLM_with_flutter/tree/main/Part1_flutter_application). System 2 and 3 are compiled under the folder [Part 2: Server backend](https://github.com/splhadi/NTU_dissertation_Sol_Gen_LLM_with_flutter/tree/main/Part2_server_backend).

This repo is divided into 2 parts, in which each system has been explained above. The two parts are shown below:
## Part 1: Frontend Flutter Application
Contains the front end flutter application of the project. Initially called as 'transmission_app', it is now converted to fit a wider purpose of this project.
## Part 2: Backend Server deployed on GCP compute engine
Contains the main python environment, files and data required for the server to operate. Note that the server runs on FastAPI via Uvicorn ASGI servers.
