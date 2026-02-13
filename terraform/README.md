# Terraform of Pachinko demonstrator

```mermaid
flowchart TB
    subgraph UI
        UIServicePlan
        UIApp
    end
    subgraph StorageAccount
        ai-conversations
        ai-states
        ai-queue
        ai-faas
    end
    subgraph AI
        AIServicePlan
        AIRunner
    end
    subgraph MCP
        MCPServicePlan
        MCPApp
    end
    UIApp --o UIServicePlan
    MCPApp --o MCPServicePlan
    AIRunner --o AIServicePlan
    AIRunner --o ai-faas
    UIApp --> ai-queue
    ai-queue --> AIRunner
    UIApp <--> ai-conversations
    AIRunner <--> ai-conversations
    AIRunner <--> ai-states
    AIRunner --> MCPApp
```