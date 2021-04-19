module implementations.shellexecuteoperation;

import jaster.cli.userio;
import std.process : executeShell;
import std.exception : enforce;
import sdlite;
import common, execution, interfaces, parsing;

final class ShellExecuteOperation : Operation
{
    override void execute(SDLNode operationNode, ExecutionContext context)
    {
        operationNode.enforceNoChildren();
        operationNode.enforceNoAttributes();
        operationNode.enforceStrictValueCount(1);
        operationNode.enforceValuesAreOfKind(SDLValue.Kind.text);

        const command = operationNode.values[0].sdlToVarValue(context).string_Value;
        UserIO.verboseWarningf("Executing shell command: %s", command);
        auto result = executeShell(command);
        // For now, always expect 0. This'll change in the future but I'm lazy.
        enforce(result.status == 0, "Command returned non-0\n"~result.output);
    }
}