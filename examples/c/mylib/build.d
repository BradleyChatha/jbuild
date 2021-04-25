/+dub.sdl:
    name "build"
    dependency "jbuild" path="../../../"
+/
import jbuild, std;

const CC               = "clang";
const CC_FLAGS         = "-Wall -c";
const CC_FLAGS_RELEASE = CC_FLAGS ~ " -O3";
const CC_LINKER        = "llvm-ar";

const SOURCE_DIR  = "source/";
const OBJECT_DIR  = "obj/";
const INCLUDE_DIR = "include/";
const LIB_PATH    = "my.lib";

void main(string[] args)
{
    stage("gather_data",
    {
        scope sourceFilesVar = getGlobalScope().create("sourceFiles", VariableValue.init);
        sourceFilesVar.value = dirEntries(SOURCE_DIR, "*.c", SpanMode.breadth).filter!(f => f.isFile).map!(f => f.name).array;

        scope objectFilesVar = getGlobalScope().create("objectFiles", VariableValue.init);
        objectFilesVar.value = sourceFilesVar.value.string_arrayValue.map!(f => OBJECT_DIR~f.baseName.setExtension(".o")).array;

        writeln(sourceFilesVar.value);
        writeln(objectFilesVar.value);
    });

    stage("build_object_files",
    {
        auto registry = getRegistry();
        auto sourceFiles = getVar("sourceFiles").value.string_arrayValue;
        auto objectFiles = getVar("objectFiles").value.string_arrayValue;
        const cc_flags = getVar("cc_flags").value.string_Value;

        if(!exists(OBJECT_DIR))
            mkdir(OBJECT_DIR);

        foreach(fileTuple; zip(sourceFiles, objectFiles))
        {
            if(!registry.isFileOutOfDate(fileTuple[0]))
                continue;

            registry.updateFile(fileTuple[0]);
            executeShell(expand(CC, cc_flags, "-I", INCLUDE_DIR, "-o", fileTuple[1], fileTuple[0])).writeln();
        }
    });

    stage("link_object_files",
    {
        auto registry    = getRegistry();
        auto objectFiles = getVar("objectFiles").value.string_arrayValue;

        if(!objectFiles.any!(f => registry.isFileOutOfDate(f)))
            return;

        executeShell(expand(CC_LINKER, "rc", LIB_PATH, objectFiles)).writeln();
    });

    command("default", ["gather_data", "build_object_files", "link_object_files"]);
    initJBuild();

    getGlobalScope().create("cc_flags", VariableValue((args.canFind("release") ? CC_FLAGS_RELEASE : CC_FLAGS)));

    runCommand("default");
}