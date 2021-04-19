module implementations.appendpath;

import std.conv : to;
import std.exception : enforce;
import std.path : buildPath;
import sdlite;
import common, interfaces, execution, parsing;

final class AppendPathOperation : Operation
{
    override void execute(SDLNode operationNode, ExecutionContext context)
    {
        operationNode.enforceNoChildren();
        operationNode.enforceLooseValueCount(1);
        operationNode.enforceAttributeNames(["into"], null);

        auto dest = context.scopeStack.get(operationNode.getAttribute("into").textValue);
        enforce(dest.value.kind == VariableValue.Kind.string_, "Variable must be a string");
        
        foreach(value; operationNode.values)
        {
            const var = value.sdlToVarValue(context);
            var.foreachString!(str => dest.value.string_Value = dest.value.string_Value.buildPath(str));
        }
    }
}