module implementations.filedependency;

import common, execution, interfaces;

final class FileDependency : Dependency
{
    private string _file;

    this(string file)
    {
        this._file = file;
    }

    override bool isOutOfDateForStage(string stageName, ExecutionContext context)
    {
        return context.persistantRegistry.isFileOutOfDateForStage(stageName, this._file);
    }

    override void onStageSuccess(string stageName, ExecutionContext context)
    {
        context.persistantRegistry.updateFileForStage(stageName, this._file);
    }
}