module commands.test;

import jcli, sdlite;
import common, execution, parsing, interfaces, implementations;

const TEST = import("test1.sdl");

@Command("test")
struct TestCommand
{
    void onExecute()
    {
        UserIO.configure().useVerboseLogging();

        SDLNode root;
        parseSDLDocument!(n => root.children ~= n)(TEST, null);
        auto topLevel = parseTopLevelBuildDocument(root);
        auto mod = parseIntoModule(topLevel);
        auto exec = new FunctionExecution(mod.dataFunc);
        auto context = new ExecutionContext(defaultVirtualRegistry, new TestPersistantRegistry());
        context.scopeStack.push(new VariableScope());
        context.scopeStack.peek.create("build_type", VariableValue.Kind.string_, VariableSubType.none, IsConst.yes).value = "release";
        exec.findDependencies(context);
        exec.execute(context);
        exec = new FunctionExecution(mod.getStage("build_and_link"));
        exec.findDependencies(context);
        UserIO.logWarningf("Deps out of date: %s", exec.anyDependenciesOutOfDate(context));
        exec.execute(context);
    }
}