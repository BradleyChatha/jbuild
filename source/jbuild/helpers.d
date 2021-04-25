module jbuild.helpers;

import jbuild;

string expand(Args...)(Args args)
{
    import std.array : Appender;
    import std.exception : assumeUnique;

    Appender!(char[]) output;

    static foreach(i, ArgT; Args)
    {
        static if(__traits(compiles, output.put(args[i])))
        {
            output.put(args[i]);
        }
        else static if(is(ArgT == string[]))
        {
            foreach(arg; args[i])
            {
                output.put(arg);
                output.put(' ');
            }
        }
        else static assert(false, "Don't know how to expand "~ArgT.stringof);
        output.put(' ');
    }

    return output.data.assumeUnique;
}