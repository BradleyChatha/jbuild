module parsing.functionparse;

import sdlite, jcli;
import common, interfaces, execution, parsing;

Function parseFunctionInstructions(SDLNode node, string name, FunctionType type)
{
    UserIO.logTracef("Parsing function %s of type %s", name, type);

    Function func;
    func.name = name;
    func.type = type;

    // For now, the "initial data" instructions are just all the input: instructions prior to any non-input: instructions.
    foreach(i, child; node.children)
    {
        if(child.namespace != "input")
        {
            func.initialInputInstructions = node.children[0..i];
            func.executionInstructions = node.children[i..$];
            break;
        }
    }

    UserIO.verboseTracef(
        "Function has %s initial input instructions, and %s execution instructions.",
        func.initialInputInstructions.length, func.executionInstructions.length
    );
    return func;
}