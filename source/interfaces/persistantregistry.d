module interfaces.persistantregistry;

abstract class PersistantRegistry
{
    abstract bool isFileOutOfDateForStage(string stage, string file);
    abstract void updateFileForStage(string stage, string file);
}