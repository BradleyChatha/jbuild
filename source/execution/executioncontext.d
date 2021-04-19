module execution.executioncontext;

import std.path;
import common, execution, interfaces;

final class ExecutionContext
{
    VirtualRegistry virtualRegistry;
    PersistantRegistry persistantRegistry;
    VariableScopeStack scopeStack;
    Function currentFunction;

    this(VirtualRegistry virtual, PersistantRegistry persistant)
    {
        this.virtualRegistry = virtual;
        this.persistantRegistry = persistant;
        this.scopeStack = new VariableScopeStack();
    }

    string resolvePath(string relative)
    {
        if(relative.isAbsolute)
            return relative.buildNormalizedPath;
        else
            return relative.absolutePath.buildNormalizedPath;
    }
}