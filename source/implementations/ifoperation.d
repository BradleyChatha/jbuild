module implementations.ifoperation;

import sdlite;
import common, execution, interfaces, parsing;

final class IfOperation : Operation
{
    override void execute(SDLNode operationNode, ExecutionContext context)
    {
        SDLNode conditionNode;
        SDLNode[] bodyNodes;

        // Shorthand
        if(operationNode.namespace.length > 0)
        {
            conditionNode = operationNode;
            bodyNodes = operationNode.children;
        }
        else // Longhand
            assert(false, "Not implemented yet.");

        auto cond = context.virtualRegistry.getCondition(conditionNode.name);
        if(cond.execute(conditionNode, context))
        {
            Function func;
            func.name = "If-statement body";
            func.type = context.currentFunction.type;
            func.executionInstructions = bodyNodes;

            auto execution = new FunctionExecution(func); // If-statement bodies don't have inputs, so we can skip that stage.
            execution.execute(context);
        }
    }
}