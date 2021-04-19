module parsing.moduleparse;

import jcli;
import common, execution, interfaces, parsing;

JBuildModule parseIntoModule(JBuildTopLevelParse topLevel)
{
    UserIO.logTracef("Parsing into module.");

    Function dataFunc;
    Function[string] stagesByName;

    UserIO.verboseTracef("Is data section null: %s", topLevel.dataSection.isNull);
    dataFunc = (topLevel.dataSection.isNull) ? Function.Null : parseFunctionInstructions(topLevel.dataSection.get, "data", FunctionType.data);
    foreach(name, value; topLevel.stagesByName)
        stagesByName[name] = parseFunctionInstructions(value, name, FunctionType.stage);

    return new JBuildModule(dataFunc, stagesByName);
}