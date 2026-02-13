# Pachinko.AI 
Pachinko is a client / orchestration demonstrator that responds to AI Consumer needs to trust the work and output.  

This solution focuses on using an LLM to generate code that utilizes MCP definitions to build python code which the AIRunners then execute.  The generated code is restricted to MCP functions, a handful of built-ins, and python native code constructs to answer the user's task.
The system answers the consumer's trust-in-work by showing the code, showing a flowchart, and providing incremental updates as it proceeds.  This allows the consumer to treat the response in the same paradigm as a human aggregator of the response, being able to see where it went, how much information it retrieved, and the workflow used to compile the answer.  This is an analog to the "show your work" requirements in secondary-school math tests.
