module jbuild.globals;

import std.exception : enforce;
import std.stdio : writeln;
import std.format : format;
import jaster.ioc, jansi;
import jbuild;

package ServiceInfo[] g_serviceInfo;
package ServiceProvider g_serviceProvider;
package StageDescription[string] g_stagesByName;
package VariableScope[] g_varScopeStack;
package Command[string] g_commandsByName;
package string g_currentStageName;
package bool g_hasInit;

package void assertNotGlobalInit()
{
    assert(!g_hasInit, "This function cannot be called once JBuild has been initialised.");
}

package void assertGlobalInit()
{
    assert(g_hasInit, "This function cannot be called until JBuild has been initialised.");
}

void addService(ServiceInfo info)
{
    assertNotGlobalInit();
    g_serviceInfo ~= info;
}

T getServiceOrNull(T)()
{
    assertGlobalInit();
    return g_serviceProvider.defaultScope.getServiceOrNull!T;
}

T getService(T)()
{
    auto service = getServiceOrNull!T;
    assert(service !is null, "Service '"~typeid(T).toString~"' does not exist.");
    return service;
}

IRegistry getRegistry()
{
    return getService!IRegistry();
}

void pushScope()
{
    assertGlobalInit();
    g_varScopeStack ~= VariableScope();
}

void popScope()
{
    assertGlobalInit();
    assert(g_varScopeStack.length > 0, "Scope stack is empty, can't pop.");
    g_varScopeStack.length--;
}

VariableScope* getScope(size_t offset = 0)
{
    assertGlobalInit();
    assert(offset < g_varScopeStack.length, "Offset goes out of bounds.");
    return &g_varScopeStack[$-(1 + offset)];
}

VariableScope* getGlobalScope()
{
    assertGlobalInit();
    return &g_varScopeStack[0];
}

Variable* getVarOrNull(string varName)
{
    for(ptrdiff_t i = g_varScopeStack.length - 1; i--; i >= 0)
    {
        auto ptr = g_varScopeStack[i].getOrNull(varName);
        if(ptr !is null)
            return ptr;
    }

    return null;
}

Variable* getVar(string varName)
{
    auto var = getVarOrNull(varName);
    enforce(var !is null, "Variable '"~varName~"' does not exist within any active variable scope.");
    return var;
}

void stage(string name, StageFunc onExecute)
{
    assertNotGlobalInit();
    assert(name !is null, "name must not be null.");
    assert(onExecute !is null, "onExecute must not be null for command: "~name);

    auto stage = StageDescription(name, onExecute);
    enforce((name in g_stagesByName) is null, "Stage called '"~name~"' already exists!");
    g_stagesByName[name] = stage;
}

void command(string name, string[] stages)
{
    assertNotGlobalInit();
    assert(name !is null, "name must not be null.");
    assert(stages.length > 0, "At least one stage must be defined for command: "~name);

    auto command = Command(name, stages);
    enforce((name in g_commandsByName) is null, "Command called '"~name~"' already exists!");
    g_commandsByName[name] = command;
}

void initJBuild()
{
    assertNotGlobalInit();

    g_serviceProvider = new ServiceProvider(g_serviceInfo);

    // Could avoid this if JIOC exposed the type info stuff for ServiceInfo, buuuuut meh, I need to give JIOC another pass through at
    // some point in the future anyway.
    const hasRegistry = !g_serviceProvider.getServiceInfoForBaseType!IRegistry.isNull;
    if(!hasRegistry)
        g_serviceProvider = new ServiceProvider(g_serviceInfo ~ ServiceInfo.asSingleton!(IRegistry, SdlRegistry!"jbuild_registry.sdl"));

    g_hasInit = true;
    pushScope(); // Global scope.
}

void runCommand(string command)
{
    assertGlobalInit();

    scope ptr = (command in g_commandsByName);
    enforce(ptr !is null, "Command '"~command~"' doesn't exist.");

    writeln("Executing command '%s'".format(command).ansi.fg(Ansi4BitColour.yellow));

    // Enforce all stages exist before starting.
    foreach(stage; ptr.stageNamesInOrder)
        enforce((stage in g_stagesByName) !is null, "Command '"~command~"' uses stage '"~stage~"' but that stage does not exist.");
    foreach(stage; ptr.stageNamesInOrder)
        runStage(stage);

    getRegistry().onCommandCompleted();
}

private void runStage(string stage)
{
    assertGlobalInit();

    scope ptr = (stage in g_stagesByName);
    enforce(ptr !is null, "Stage '"~stage~"' doesn't exist.");

    writeln("Executing stage '%s'".format(stage).ansi.fg(Ansi4BitColour.green));
    g_currentStageName = stage;

    pushScope(); // Stage scope
    scope(exit) popScope();
    ptr.onExecute();
}