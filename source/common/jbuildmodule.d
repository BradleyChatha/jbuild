module common.jbuildmodule;

import execution, interfaces;

final class JBuildModule
{
    private
    {
        Function _dataFunc;
        Function[string] _stagesByName;
    }

    this(Function dataFunc, Function[string] stagesByName)
    {
        this._dataFunc = dataFunc;
        this._stagesByName = stagesByName;
    }

    Function getStage(string name)
    {
        return this._stagesByName[name];
    }

    @property
    Function dataFunc()
    {
        return this._dataFunc;
    }
}