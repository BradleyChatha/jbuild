module implementations.appendoperation;

import std.conv : to;
import std.exception : enforce;
import sdlite;
import common, interfaces, execution, parsing;

final class AppendOperation : Operation
{
    override void execute(SDLNode operationNode, ExecutionContext context)
    {
        operationNode.enforceNoChildren();
        operationNode.enforceLooseValueCount(1);
        operationNode.enforceAttributeNames(["into"], null);

        auto dest = context.scopeStack.get(operationNode.getAttribute("into").textValue);
        switch(dest.value.kind) with(VariableValue.Kind)
        {
            case string_:
                foreach(value; operationNode.values)
                {
                    const varValue = value.sdlToVarValue(context);
                    enforce(varValue.kind == string_, "Cannot append value "~varValue.to!string~" into a string.");
                    dest.value.string_Value ~= varValue.string_Value;
                }
                break;

            default: throw new Exception("Cannot append into variable of type "~dest.value.kind.to!string);
        }
    }
}