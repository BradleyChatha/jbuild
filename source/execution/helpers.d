module execution.helpers;

import std.conv : to;
import std.exception : enforce;
import sdlite;
import common, interfaces, execution;

void foreachString(alias Func)(VariableValue var, string name = "TEMP")
{
    switch(var.kind) with(VariableValue.Kind)
    {
        case string_:
            Func(var.string_Value);
            break;

        case string_array:
            foreach(file; var.string_arrayValue)
                Func(file);
            break;

        default:
            throw new Exception("Expected variable '"~name~"' to be a string or string_array, not: "~var.kind.to!string);
    }
}

void foreachString(alias Func)(Variable* var)
{
    foreachString!Func(var.value, var.name);
}

VariableValue sdlToVarValue(VariableValue.Kind VarKind, SDLValue.Kind SdlKind)(SDLValue sdlValue)
{
    enforce(sdlValue.kind == SdlKind, "Expected value to be of kind "~SdlKind.to!string~" but it is of kind "~sdlValue.kind.to!string);
    return VariableValue(sdlValue.value!SdlKind);
}

VariableValue sdlToVarValue(SDLValue sdlValue, ExecutionContext context)
{
    switch(sdlValue.kind) with(SDLValue.Kind)
    {
        case text:
            const value = sdlValue.textValue;
            if(value.isVariableReference)
                return context.scopeStack.get(value.asVariableReference).value;
            return VariableValue(context.scopeStack.expandString(value, context));

        default: throw new Exception("Unexpected SDL value of kind "~sdlValue.kind.to!string~" when converting to value");
    }
}