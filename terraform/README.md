# Terraform of Pachinko demonstrator

```mermaid
flowchart TB
    UIServicePlan
    UIApp
    ConversationContainer[ai conversations]
    StatesContainer[ai states]
    QueueContainer[ai queue]
    FaaSContainer[ai faas]
    AIServicePlan
    AIRunner
    MCPServicePlan
    MCPApp
    UIApp --o UIServicePlan
    UIApp --> QueueContainer
    AIRunner --o AIServicePlan
    AIRunner --o FaaSContainer
    QueueContainer --> AIRunner
    UIApp <--> ConversationContainer
    AIRunner <--> ConversationContainer
    AIRunner <--> StatesContainer
    AIRunner --> MCPApp
    MCPApp --o MCPServicePlan
```