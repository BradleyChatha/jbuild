module implementations.escapeshelltransform;

import std.array : Appender;
import std.exception : assumeUnique;
import std.process : escapeShellCommand;
import taggedalgebraic;
import common, execution, interfaces;

final class EscapeShellTransform : Transformer
{
    override string transform(VariableValue value)
    {
        Appender!(char[]) output;
        value.foreachString!(str => output ~= escapeShellCommand(str)~' ');
        return output.data.assumeUnique;
    }
}