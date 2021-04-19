module execution.functionexecution;

import std.conv : to;
import std.exception : enforce;
import sdlite, jcli;
import common, execution, interfaces, implementations, parsing.validation;

private enum ExecutionStage
{
    ERROR,
    input,
    normal
}

final class FunctionExecution
{
    private
    {
        Function _function;
        VariableScope _scope;
        Dependency[] _dependencies;
    }

    this(Function func)
    {
        this._function = func;
    }

    void findDependencies(ExecutionContext context)
    {
        UserIO.verboseTracef("Finding dependencies for function %s", this._function.name);
        this.execImpl(this._function.initialInputInstructions, ExecutionStage.input, context);
        UserIO.verboseTracef("Function has %s dependencies", this._dependencies.length);
    }
    
    bool anyDependenciesOutOfDate(ExecutionContext context)
    {
        import std.algorithm : map, any;
        return this._dependencies.map!(dep => dep.isOutOfDateForStage(this._function.name, context)).any!(boolean => boolean);
    }

    void execute(ExecutionContext context)
    {
        UserIO.verboseTracef("Executing function %s", this._function.name);
        this.execImpl(this._function.executionInstructions, ExecutionStage.normal, context);

        foreach(dep; this._dependencies)
            dep.onStageSuccess(this._function.name, context);
    }

    private void execImpl(SDLNode[] instructions, ExecutionStage stage, ExecutionContext context)
    in(stage != ExecutionStage.ERROR)
    {
        this._scope = (this._function.type == FunctionType.data) ? context.scopeStack.peek : new VariableScope();
        
        context.currentFunction = this._function;
        context.scopeStack.push(this._scope);
        scope(exit) context.scopeStack.pop();

        foreach(node; instructions)
        {
            UserIO.verboseTracef("Executing: "~node.qualifiedName);
            switch(node.namespace)
            {
                case "input":
                    enforce(
                        stage == ExecutionStage.input,
                        "For function '"~this._function.name~"': Cannot execute 'input:' instructions outside of the input stage."
                    );
                    this.executeInput(node, context);
                    break;

                case "if":
                    auto ifOp = context.virtualRegistry.getOperation("__if");
                    ifOp.execute(node, context);
                    break;

                default:
                    auto operation = context.virtualRegistry.getOperation(node.qualifiedName);
                    operation.execute(node, context);
                    break;
            }
        }
    }

    private void executeInput(SDLNode node, ExecutionContext context)
    {
        const typeName = node.name;

        switch(typeName)
        {
            case "file_array":
                enforceNoAttributes(node);
                enforceNoChildren(node);
                enforceValuesAreOfKind(node, SDLValue.Kind.text);

                foreach(value; node.values)
                {
                    auto var = value.sdlToVarValue(context);
                    var.foreachString!(str => this._dependencies ~= new FileDependency(str));
                }
                break;

            default: throw new Exception("For function '"~this._function.name~"': Unknown input type '"~typeName~"'");
        }
    }
}