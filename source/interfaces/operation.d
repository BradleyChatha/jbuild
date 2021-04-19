module interfaces.operation;

import sdlite;
import execution, interfaces;

abstract class Operation : Instruction
{
    abstract void execute(SDLNode operationNode, ExecutionContext context);
}