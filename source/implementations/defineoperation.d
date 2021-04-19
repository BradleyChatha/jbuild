module implementations.defineoperation;

import sdlite;
import common, execution, interfaces, parsing;

final class DefineOperation(VariableValue.Kind VarKind, SDLValue.Kind SdlKind) : Operation
{
    override void execute(SDLNode operationNode, ExecutionContext context)
    {
        operationNode.enforceStrictValueCount(1);
        operationNode.enforceValuesAreOfKind(SDLValue.Kind.text);
        operationNode.enforceAttributeNames(null, ["value", "const"]);

        const name = operationNode.values[0].textValue;
        const isConst = cast(IsConst)operationNode.getAttribute("const", SDLValue(false)).boolValue;

        auto valueNode = operationNode.getAttribute("value");
        VariableValue value;

        static if(SdlKind != SDLValue.Kind.null_)
        {
            if(valueNode.kind == SDLValue.Kind.text)
                value = sdlToVarValue(valueNode, context);
            else if(valueNode != SDLValue.null_)
                value = sdlToVarValue!(VarKind, SdlKind)(valueNode);
            else
                value = variableValueInitByType(VarKind);
        }
        else
            value = variableValueInitByType(VarKind);

        context.scopeStack.peek.create(name, VarKind, VariableSubType.none, isConst).value = value;
    }
}