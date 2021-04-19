module implementations.testpersistantregistry;

import interfaces, execution;

final class TestPersistantRegistry : PersistantRegistry
{
    override bool isFileOutOfDateForStage(string stage, string file)
    {
        return true;
    }

    override void updateFileForStage(string stage, string file)
    {
    }
}