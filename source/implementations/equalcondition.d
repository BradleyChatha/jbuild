module implementations.equalcondition;

import sdlite;
import common, execution, interfaces, parsing;

final class EqualCondition : Condition
{
    override bool execute(SDLNode conditionNode, ExecutionContext context)
    {
        conditionNode.enforceNoAttributes();
        if(conditionNode.namespace != "if")
            conditionNode.enforceNoChildren();
        conditionNode.enforceLooseValueCount(2);

        const firstValue = conditionNode.values[0].sdlToVarValue(context);
        foreach(value; conditionNode.values[1..$])
        {
            const currValue = value.sdlToVarValue(context);
            if(firstValue != currValue)
                return false;
        }

        return true;
    }
}