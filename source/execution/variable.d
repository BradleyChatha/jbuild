module execution.variable;

import std.typecons : Flag;
import taggedalgebraic;

alias IsConst = Flag!"isconst";

enum VariableSubType
{
    none,
    file
}

union VariableValueUnion
{
    string string_;
    string[] string_array;
}

alias VariableValue = TaggedUnion!VariableValueUnion;

struct Variable
{
    string name;
    VariableValue value;
    VariableSubType subType;
    IsConst isConst;

    void enforceNotConst()
    {
        if(this.isConst)
            throw new Exception("Variable '"~this.name~"' is const.");
    }
}

VariableValue variableValueInitByType(VariableValue.Kind type)
{
    final switch(type) with(VariableValue.Kind)
    {
        case string_: return VariableValue.string_(string.init);
        case string_array: return VariableValue.string_array(string[].init);
    }
}