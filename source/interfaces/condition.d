module interfaces.condition;

import sdlite;
import execution, interfaces;

abstract class Condition : Instruction
{
    abstract bool execute(SDLNode conditionNode, ExecutionContext context);
}