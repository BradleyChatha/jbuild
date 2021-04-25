module jbuild.variable;

import std.exception : enforce;
import std.typecons : Flag;
import taggedalgebraic;

union VariableValueUnion
{
    string string_;
    string[] string_array;
}

alias VariableValue = TaggedUnion!VariableValueUnion;
alias Overwrite = Flag!"overwrite";

struct Variable
{
    string name;
    VariableValue value;
}

struct VariableScope
{
    private
    {
        Variable*[string] _varsByName;
    }

    Variable* create(string name, VariableValue value, Overwrite overwrite = Overwrite.no)
    {
        enforce(overwrite || (name in this._varsByName) is null, "Variable '"~name~"' already exists, and overwrite is set to false.");

        auto var = new Variable(name, value);
        this._varsByName[name] = var;
        return var;
    }

    Variable* get(string name)
    {
        scope ptr = (name in this._varsByName);
        enforce(ptr !is null, "Variable '"~name~"' does not exist.");
        return *ptr;
    }

    Variable* getOrNull(string name)
    {
        scope ptr = (name in this._varsByName);
        return (ptr is null) ? null : *ptr;
    }
}