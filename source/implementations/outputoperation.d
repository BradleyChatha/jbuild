module implementations.outputoperation;

import jaster.cli.userio;
import sdlite;
import common, interfaces, execution, parsing;

final class OutputOperation : Operation
{
    override void execute(SDLNode operationNode, ExecutionContext context)
    {
        operationNode.enforceNoChildren();
        operationNode.enforceStrictValueCount(1);
        operationNode.enforceValuesAreOfKind(SDLValue.Kind.text);
        operationNode.enforceAttributeNames(null, ["as"]);

        const name = operationNode.getAttribute("as", SDLValue("output")).textValue;
        const var  = context.scopeStack.get(operationNode.values[0].textValue);

        const finalName = context.currentFunction.name~"@"~name;
        UserIO.verboseWarningf("Setting var '%s' as output '%s'", operationNode.values[0].textValue, finalName);
        context.scopeStack.peek(1).create(finalName, var.value.kind, var.subType, var.isConst).value = var.value;
    }
}