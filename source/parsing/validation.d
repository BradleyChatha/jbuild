module parsing.validation;

import std.algorithm : all, canFind, remove, countUntil;
import std.exception : enforce;
import std.conv : to;
import sdlite;

void enforceNoAttributes(SDLNode node)
{
    enforce(node.attributes.length == 0, "Tag '"~node.qualifiedName~"' should not contain attributes.");
}

void enforceNoValues(SDLNode node)
{
    enforce(node.values.length == 0, "Tag '"~node.qualifiedName~"' should not contain values.");
}

void enforceNoChildren(SDLNode node)
{
    enforce(node.children.length == 0, "Tag '"~node.qualifiedName~"' should not contain children.");
}

void enforceHasChildren(SDLNode node)
{
    enforce(node.children.length > 0, "Tag '"~node.qualifiedName~"' must contain children.");
}

void enforceStrictValueCount(SDLNode node, size_t count)
{
    enforce(node.values.length == count, 
        "Expected Tag '"~node.qualifiedName~"' to contain exactly "~count.to!string~" values, but it has "~node.values.length.to!string
    );
}

void enforceLooseValueCount(SDLNode node, size_t count)
{
    enforce(
        node.values.length >= count,
        "Expected Tag '"~node.qualifiedName~"' to contain at least "~count.to!string~" values, but it has "~node.values.length.to!string
    );
}

void enforceValuesAreOfKind(SDLNode node, SDLValue.Kind kind)
{
    enforce(node.values.all!(v => v.kind == kind), "The values of tag '"~node.qualifiedName~"' should all be of kind "~kind.to!string);
}

void enforceAttributeNames(SDLNode node, string[] mandatory, string[] optional)
{
    foreach(attrib; node.attributes)
    {
        const mandatoryIndex = mandatory.countUntil(attrib.qualifiedName);
        if(mandatoryIndex >= 0)
        {
            mandatory = mandatory.remove(mandatoryIndex);
            continue;
        }
        enforce(optional.canFind(attrib.qualifiedName), "Unknown attribute called '"~attrib.qualifiedName~"' on tag '"~node.qualifiedName~"'");
    }
    enforce(mandatory.length == 0, "The following mandatory attributes were not found on tag '"~node.qualifiedName~"': "~mandatory.to!string);
}