module implementations.makeconstoperation;

import std.conv : to;
import std.exception : enforce;
import sdlite;
import common, interfaces, execution, parsing;

final class MakeConstOperation : Operation
{
    override void execute(SDLNode operationNode, ExecutionContext context)
    {
        operationNode.enforceNoChildren();
        operationNode.enforceNoAttributes();
        operationNode.enforceStrictValueCount(1);

        const name = operationNode.values[0].textValue;
        auto var = context.scopeStack.get(name);
        var.isConst = IsConst.yes;
    }
}