module interfaces.dependency;

import execution;

abstract class Dependency
{
    abstract bool isOutOfDateForStage(string stageName, ExecutionContext context);
    abstract void onStageSuccess(string stageName, ExecutionContext context);
}