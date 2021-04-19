module execution.function_;

import sdlite;
import execution, interfaces;

enum FunctionType
{
    ERROR,
    data,
    stage
}

struct Function
{
    enum Null = Function.init;

    string name;
    FunctionType type;
    SDLNode[] initialInputInstructions; // Instructions that determine the initial inputs to a function.
    SDLNode[] executionInstructions; // Instructions that perform any actual logic.
}