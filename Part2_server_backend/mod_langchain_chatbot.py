import os
from langchain.llms import GooglePalm
import pprint
pp = pprint.pprint
from langchain.chains import LLMMathChain,ConversationalRetrievalChain
from langchain.chains.qa_with_sources.loading import load_qa_with_sources_chain
from langchain_experimental.llm_symbolic_math.base import LLMSymbolicMathChain
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_google_genai import GoogleGenerativeAI

from langchain.memory import ConversationBufferMemory
from langchain.memory.vectorstore import VectorStoreRetrieverMemory
from langchain.chains import LLMChain,SequentialChain
from langchain.prompts import (
    ChatPromptTemplate,
    MessagesPlaceholder,
    SystemMessagePromptTemplate,
    HumanMessagePromptTemplate,
)
from langchain_community.llms import HuggingFaceHub
from langchain.document_loaders import PyPDFDirectoryLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.vectorstores import Chroma
from langchain.embeddings import OpenAIEmbeddings
from langchain.embeddings import GooglePalmEmbeddings
from langchain.retrievers.multi_query import MultiQueryRetriever
from langchain.prompts import PromptTemplate
from langchain_core.runnables import RunnableParallel, RunnablePassthrough
from langchain_community.tools.tavily_search import TavilySearchResults
from langchain_openai import OpenAI
from langchain.agents import Tool
from langchain.agents import load_tools
from langchain.agents import initialize_agent, create_structured_chat_agent
from langchain.agents.agent_types import AgentType
from langchain import hub
from dotenv import load_dotenv, dotenv_values
load_dotenv()  


def init():

    #Setting API keys for OPENAI or GOOGLE
    
    #no longer being used as all API keys are stored in .env files
    #os.environ["GOOGLE_API_KEY"]=API_KEY
    #os.environ["OPENAI_API_KEY"] = OPENAI_API_KEY

    #Load LLMs
    llm = GoogleGenerativeAI(model="gemini-pro", convert_system_message_to_human=True, temperature=0.9)
    # llm = OpenAI()

    #Deprecated use, initially was using a lancghain conversational retrival chain
    ####################################################################################################################
    #Load Vector database for pdf files
    """  print("Loading vector store for pdf...")
    loader = PyPDFDirectoryLoader('pdf')
    text_splitter = RecursiveCharacterTextSplitter(chunk_size = 1000, chunk_overlap = 200)
    splits = text_splitter.split_documents(loader.load())
    vectorstore = Chroma.from_documents(documents=splits,embedding=GooglePalmEmbeddings())
    print("Docs embedded. creating retriever")

    #Load which retriever we are using, in this case vectorstore retriever
    retriever = vectorstore.as_retriever(search_type="similarity", search_kwargs={"k": 2})
    print("retriever loaded")

    #Load the initial prompt and memory
    intro_prompt = ChatPromptTemplate(
        messages=[
            SystemMessagePromptTemplate.from_template(
                "You are a chatbot specialises with electrical engineering topics to teach students. "
            ),
            # The `variable_name` here is what must align with memory
            #MessagesPlaceholder(variable_name="chat_history"),
            HumanMessagePromptTemplate.from_template(r"Summary provided:{summaries}\n  Solve the question based on summary: {question}\n. If No context provided, give your OWN answer:")
        ]
    )




    #prompt for question generator:
    template = (
        "Combine the chat history and follow up question into "
        "a standalone question. Chat History: {chat_history}"
        "Follow up question: {question}"
    )

    CONDENSE_QUESTION_PROMPT = PromptTemplate.from_template(template)
    question_generator = LLMChain(llm=llm, prompt=CONDENSE_QUESTION_PROMPT, verbose=True)
    print("LLM for question generator loaded")
    #enable logging
    import logging

    logging.basicConfig()
    logging.getLogger("langchain.retrievers.multi_query").setLevel(logging.INFO)

    #doc_chain = load_qa_with_sources_chain(llm, chain_type="refine", verbose=True, prompt=intro_prompt)
    doc_chain = load_qa_with_sources_chain(llm, chain_type="refine", verbose=True)
    print("DOC chain loaded")

    intro_conversation=ConversationalRetrievalChain(
        retriever=retriever,
        verbose=True,
        combine_docs_chain=doc_chain,
        rephrase_question=False,
        question_generator=question_generator,
        memory=memory,
        output_key='answer'
    )
    print("Conversational retrieval chain loaded")


    chain_test = {'answer':intro_conversation, 'question': RunnablePassthrough()}"""

    ################################################################################
    #End of deprecation

    #initialising agent
    ###############################################################################

    #tavily api key now in .env file
    #os.environ["TAVILY_API_KEY"] =TAVILY_API_KEY
    tools = [TavilySearchResults(max_results=1)]


    
    #prompt below is no longer being used
    prompt = ChatPromptTemplate.from_messages(
        [
            (
                "system",
                "You are a helpful assistant used for electrical engineering. You may not need to use tools for every query - the user may just want to chat!",
            ),
            MessagesPlaceholder(variable_name="messages"),
            MessagesPlaceholder(variable_name="agent_scratchpad"),
        ]
    )

    #this is the new prompt being used for chatbot
    prompt = hub.pull("hwchase17/structured-chat-agent")
    print("Prompt used:",prompt)
    from langchain.agents import AgentExecutor

    memory = ConversationBufferMemory(memory_key="chat_history", return_messages=True)
    print('memory loaded')

    #initialise againt with Conversational React framework as well as memory with pulled prompt
    agent = initialize_agent(
        agent=AgentType.CONVERSATIONAL_REACT_DESCRIPTION,
        tools=tools,
        llm=llm,
        verbose=True,
        prompt = prompt,
        # max_iterations=5,
        memory=memory

    )

    #agent = create_structured_chat_agent(llm, tools, prompt)

    #creates an executables for agent
    agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)



    return agent#chain_test

#called from fast_api.py 
def call_langchain(chain_test,message):
    response_msg = chain_test.invoke({'input': message})
    print(response_msg['output'])
    return response_msg['output']