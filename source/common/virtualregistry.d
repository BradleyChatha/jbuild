module common.virtualregistry;

import std.exception : enforce;
import interfaces;

final class VirtualRegistry
{
    private
    {
        Condition[string] _conditions;
        Operation[string] _operations;
        Transformer[string] _transformers;

        VirtualRegistry add(string DebugName, ArrayT, ElementT)(ref ArrayT array, ElementT element, string name)
        {
            enforce((name in array) is null, DebugName~" '"~name~"' already exists.");
            enforce(element !is null, DebugName~" cannot be null.");
            array[name] = element;
            return this;
        }

        auto get(string DebugName, ArrayT)(ArrayT array, string name)
        {
            auto ptr = name in array;
            enforce(ptr !is null, "No "~DebugName~" called '"~name~"'");
            return *ptr;
        }
    }

    VirtualRegistry addCondition(string name, Condition condition)
    {
        return this.add!"Condition"(this._conditions, condition, name);
    }

    Condition getCondition(string name)
    {
        return this.get!"Condition"(this._conditions, name);
    }

    VirtualRegistry addOperation(string name, Operation operation)
    {
        return this.add!"Operation"(this._operations, operation, name);
    }

    Operation getOperation(string name)
    {
        return this.get!"Operation"(this._operations, name);
    }

    VirtualRegistry addTransformer(string name, Transformer trasformer)
    {
        return this.add!"Transformer"(this._transformers, trasformer, name);
    }

    Transformer getTransformer(string name)
    {
        return this.get!"Transformer"(this._transformers, name);
    }
}

VirtualRegistry defaultVirtualRegistry()
{
    import sdlite;
    import implementations, execution;

    auto registry = new VirtualRegistry();
    registry.addOperation("__if", new IfOperation())
            .addOperation("append", new AppendOperation())
            .addOperation("append:glob", new AppendGlobOperation())
            .addOperation("append:path", new AppendPathOperation())
            .addOperation("define:string", new DefineOperation!(VariableValue.Kind.string_, SDLValue.Kind.text))
            .addOperation("define:string_array", new DefineOperation!(VariableValue.Kind.string_array, SDLValue.Kind.null_))
            .addOperation("make:const", new MakeConstOperation())
            .addOperation("make:directory", new MakeDirectoryOperation())
            .addOperation("shell:execute", new ShellExecuteOperation())
            .addOperation("output", new OutputOperation())
            .addCondition("equal", new EqualCondition())
            .addTransformer("__default", new DefaultTransform())
            .addTransformer("escape_shell", new EscapeShellTransform());
    return registry;
}