# -*- coding: utf-8 -*-
"""
Created on Fri Nov 21 07:28:09 2025

@author: drwilliamroney
"""

from fastapi import FastAPI
import pachinkoagentic
from fastapi import Request
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse
#from localvllm import LocalVLLM
#from localollama import LocalOllama
from fastmcp import Client
from sse_starlette.sse import EventSourceResponse
from sse_starlette import JSONServerSentEvent
import uuid
import time

logger = pachinkoagentic.get_async_logger(__name__, 'INFO')   

app = FastAPI()
app.mount('/images', StaticFiles(directory='images'), name="images")
app.mount('/scripts', StaticFiles(directory='scripts'), name="scripts")
app.mount('/styles', StaticFiles(directory='styles'), name="styles")
templates=Jinja2Templates(directory='templates')

if False:
    @app.middleware('http')
    async def debugging_middleware(request: Request, call_next):
        print(request.headers)
        print(await request.body())
        response = await call_next(request)
        return response

@app.get("/")
async def chat_interface(request: Request) -> HTMLResponse:
    return templates.TemplateResponse(request=request, name="index.html")

from pydantic import BaseModel
class Ask(BaseModel):
    question: str

@app.post("/agentic/ask")
async def ask(request: Request, question: Ask) -> EventSourceResponse:
    async def answerQuestion(question:str):
        chat_id = uuid.uuid4().hex
        start=time.time()
        await logger.info(f'Chat ID: {chat_id} BEGINS')
        yield JSONServerSentEvent(data={"event":'Beginning.', "chat_id":chat_id, "extra_data":question.lstrip()})
        library = pachinkoagentic.Library()\
                    .add(Client('http://localhost:9001/mcp'))
        workflow = pachinkoagentic.Workflow(agentic_code_generator=None, #LocalOllama('http://localhost:11434','qwen3:4b-thinking'), 
                                                llm=None, #llm=LocalOllama('http://localhost:11434','qwen3:4b-thinking'), 
                                                library=library, 
                                                workflow_id=chat_id)
        async for event in workflow.generate(question):
            await logger.debug(f'Got Generate Event: {event}')
            if event.event_type in [pachinkoagentic.WorkflowEventType.WORKFLOW_GENERATION_START,
                                    pachinkoagentic.WorkflowEventType.WORKFLOW_CODE,
                                    pachinkoagentic.WorkflowEventType.WORKFLOW_IMAGE,
                                    pachinkoagentic.WorkflowEventType.WORKFLOW_GENERATION_FAILED,
                                    pachinkoagentic.WorkflowEventType.WORKFLOW_GENERATION_END]:
                yield JSONServerSentEvent(data={"event":event.event_type, "chat_id": event.workflow_id, "extra_data":event.extra_data})
        async for event in workflow.process():
            await logger.debug(f'Got Process Event: {event}')
            if event.event_type in [pachinkoagentic.WorkflowEventType.WORKFLOW_UPDATE,
                                    pachinkoagentic.WorkflowEventType.ANSWER_UPDATE]:
                yield JSONServerSentEvent(data={"event":event.event_type, "chat_id": event.workflow_id, "extra_data":event.extra_data})
        yield JSONServerSentEvent(data={"event":'Ending.', "chat_id":chat_id, "extra_data":f'Time: {time.time()-start:.2f} seconds.'})
        await logger.info(f'Chat ID: {chat_id} COMPLETED in {time.time() - start:.3f} seconds.')
    return EventSourceResponse(answerQuestion(question.question))
