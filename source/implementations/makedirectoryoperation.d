module implementations.makedirectoryoperation;

import std.conv : to;
import std.exception : enforce;
import std.file : mkdirRecurse;
import sdlite;
import common, interfaces, execution, parsing;

final class MakeDirectoryOperation : Operation
{
    override void execute(SDLNode operationNode, ExecutionContext context)
    {
        operationNode.enforceNoChildren();
        operationNode.enforceNoAttributes();
        operationNode.enforceStrictValueCount(1);

        const name = operationNode.values[0].sdlToVarValue(context).string_Value;
        mkdirRecurse(name);
    }
}