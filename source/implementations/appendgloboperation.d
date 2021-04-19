module implementations.appendgloboperation;

import std.conv : to;
import std.file : dirEntries, SpanMode, exists;
import std.exception : enforce;
import sdlite;
import common, interfaces, execution, parsing;

final class AppendGlobOperation : Operation
{
    override void execute(SDLNode operationNode, ExecutionContext context)
    {
        operationNode.enforceNoValues();
        operationNode.enforceNoChildren();
        operationNode.enforceAttributeNames(["into", "dir", "pattern"], null);

        auto intoVar = context.scopeStack.get(operationNode.getAttribute("into").textValue);
        const dir = operationNode.getAttribute("dir").sdlToVarValue(context).string_Value;
        const pattern = operationNode.getAttribute("pattern").sdlToVarValue(context).string_Value;

        enforce(intoVar.value.kind == VariableValue.Kind.string_array, "Variable must be a string_array.");

        const path = context.resolvePath(dir);
        if(!path.exists)
            return;

        foreach(string entry; dirEntries(path, pattern, SpanMode.breadth))
            intoVar.value.string_arrayValue ~= entry;
    }
}