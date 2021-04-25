module jbuild.registry;

import jbuild;

interface IRegistry
{
    bool isFileOutOfDate(string path);
    void updateFile(string path);
    void onCommandCompleted();

    protected final string currentStageName()
    {
        return g_currentStageName;
    }
}

final class DummyRegistry : IRegistry
{
    override bool isFileOutOfDate(string path)
    {
        return true;
    }

    override void updateFile(string path){}
    override void onCommandCompleted(){}
}

final class SdlRegistry(string file) : IRegistry
{
    import std.algorithm : filter;
    import std.stdio : File;
    import std.file : exists, mkdirRecurse, readText, timeLastModified;
    import std.path : dirName;
    import sdlite;

    private SDLNode _sdl;

    this()
    {
        if(file.exists)
            parseSDLDocument!(node => this._sdl.children ~= node)(file.readText, file);
    }
    
    override bool isFileOutOfDate(string path)
    {
        return true;
    }

    override void updateFile(string path)
    {
        bool isNewNode;
        auto node = this.getOrCreateNode(&this._sdl, this.currentStageName, isNewNode);
        auto fileNode = this.getOrCreateNode(node, path, isNewNode);
        fileNode.values = [SDLValue(path.timeLastModified)];
    }

    override void onCommandCompleted()
    {
        const dir = file.dirName;
        if(!dir.exists)
            mkdirRecurse(dir);

        auto file = File(file, "w+");
        auto func = (char ch) => file.write(ch);
        generateSDLang(func, this._sdl);
    }

    private SDLNode* getOrCreateNode(SDLNode* root, string name, out bool wasCreated)
    {
        SDLNode* node;
        foreach(ref child; root.children)
        {
            if(child.name == name)
            {
                node = &child;
                break;
            }
        }

        if(node is null)
        {
            root.children ~= SDLNode(name);
            node = &root.children[$-1];
            wasCreated = true;
        }

        return node;
    }
}