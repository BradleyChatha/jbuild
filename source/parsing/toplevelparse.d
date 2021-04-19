// Parses the top-level tag of a jbuild file.
// Doesn't perform any validation inside of any child tags.
module parsing.toplevelparse;

import std.exception : enforce;
import std.typecons : Nullable;
import sdlite;
import jaster.cli.userio;
import parsing.validation;

struct JBuildTopLevelParse
{
    Nullable!SDLNode buildTypes;
    Nullable!SDLNode dataSection;
    Nullable!SDLNode exportSection;
    SDLNode[string]  stagesByName;
    SDLNode[string]  commandsByName;
}

JBuildTopLevelParse parseTopLevelBuildDocument(SDLNode root)
{
    JBuildTopLevelParse result;
    UserIO.logTracef("Top-level parse");

    foreach(child; root.children)
    {
        UserIO.verboseTracef("Found %s", child.qualifiedName);
        switch(child.qualifiedName)
        {
            case "build_types":
                child.enforceAttributeNames(["default"], null);
                child.enforceNoChildren();
                child.enforceValuesAreOfKind(SDLValue.Kind.text);
                result.buildTypes = child;
                break;

            case "export":
            case "data":
                child.enforceNoAttributes();
                child.enforceNoValues();
                child.enforceHasChildren();
                if(child.qualifiedName == "export")
                    result.exportSection = child;
                else
                    result.dataSection = child;
                break;

            case "stage":
            case "command":
                child.enforceNoAttributes();
                child.enforceStrictValueCount(1);
                child.enforceValuesAreOfKind(SDLValue.Kind.text);
                child.enforceHasChildren();
                
                SDLNode[string]* array;
                if(child.qualifiedName == "stage")
                    array = &result.stagesByName;
                else
                    array = &result.commandsByName;
                
                const name = child.values[0].textValue;
                enforce((name in *array) is null, child.qualifiedName~" called '"~name~"' is already defined.");
                (*array)[name] = child;
                break;

            default: throw new Exception("Unexpected top-level node inside of jbuild file. Name: "~child.qualifiedName);
        }
    }

    return result;
}