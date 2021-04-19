module implementations.defaultransform;

import std.conv : to;
import taggedalgebraic;
import common, execution, interfaces;

final class DefaultTransform : Transformer
{
    override string transform(VariableValue value)
    {
        string output;
        value.visit!(
            (string string_) { output = string_; },
            (string[] string_array) { foreach(str; string_array) output ~= str~" "; }
        );

        return output;
    }
}