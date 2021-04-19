module execution.variablescope;

import std.array : Appender;
import std.conv : to;
import std.exception : enforce, assumeUnique;
import std.typecons : Nullable;
import jaster.cli.userio;
import execution;

final class VariableScope
{
    private
    {
        Variable[string] _vars;
    }

    Variable* create(string name, VariableValue value, VariableSubType subType, IsConst isConst)
    {
        auto var = Variable(name, value, subType, isConst);
        this._vars[name] = var;
        return this.getOrNull(name);
    }

    Variable* create(string name, VariableValue.Kind type, VariableSubType subType, IsConst isConst)
    {
        return this.create(name, variableValueInitByType(type), subType, isConst);
    }

    Variable* getOrNull(string name)
    {
        auto ptr = (name in this._vars);
        return (ptr is null) ? typeof(return).init : typeof(return)(ptr);
    }
}

final class VariableScopeStack
{
    private
    {
        VariableScope[] _stack;
    }

    void push(VariableScope scope_)
    {
        assert(scope_ !is null);
        this._stack ~= scope_;
        UserIO.verboseTracef("Pushing scope. Count is now %s", this._stack.length);
    }

    void pop()
    {
        assert(this._stack.length > 0, "Stack is already empty.");
        this._stack.length--;
        UserIO.verboseTracef("Popping scope. Count is now %s", this._stack.length);
    }

    VariableScope peek(size_t offset = 0)
    {
        UserIO.verboseTracef("Peeking with offset %s while stack length is %s", offset, this._stack.length);
        return this._stack[$-(1 + offset)];
    }

    void each(alias Func)()
    {
        for(size_t i = this._stack.length; i > 0; i--)
        {
            if(Func(this._stack[i-1]))
                return;
        }
    }

    Variable* getOrNull(string name)
    {
        typeof(return) toReturn;
        this.each!(scope_ => (toReturn = scope_.getOrNull(name)) !is null);
        return toReturn;
    }

    Variable* get(string name)
    {
        auto ptr = this.getOrNull(name);
        enforce(ptr !is null, "Variable '"~name~"' does not exist in any active scopes.");
        return ptr;
    }

    string expandString(const char[] input, ExecutionContext context)
    {
        Appender!(char[]) output;
        size_t colonIndex = size_t.max;

        for(size_t i = 0; i < input.length; i++)
        {
            if(input[i] == '$' && (i + 1) < input.length && input[i+1] == '{')
            {
                i += 2; // Skip '${'
                size_t start = i;
                while(input[i] != '}')
                {
                    if(input[i] == ':')
                        colonIndex = i;

                    enforce(++i < input.length, "Unterminated interpolation. Expected ending '}' in string: "~input);
                }
                if(colonIndex == size_t.max)
                    colonIndex = i;
                
                const varName = input[start..colonIndex].assumeUnique;
                const transformerName = (colonIndex == i) ? "__default" : input[colonIndex+1..i].assumeUnique;
                scope var = this.getOrNull(varName);
                auto transformer = context.virtualRegistry.getTransformer(transformerName);
                enforce(var !is null, "Variable '"~varName~"' could not be found when interpolating string: "~input);

                output.put(transformer.transform(var.value));
                colonIndex = size_t.max;
            }
            else
                output.put(input[i]);
        }

        return output.data.assumeUnique;
    }
}

bool isVariableReference(const char[] str)
{
    return (str.length >= 2) && str[0] == '$' && str[1] != '{';
}

string asVariableReference(string str)
{
    return str[1..$];
}