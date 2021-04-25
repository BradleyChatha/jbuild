module jbuild.stagedescription;

package alias StageFunc = void function();

package struct StageDescription
{
    string name;
    StageFunc onExecute;
}