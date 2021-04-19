module commands;

import std.meta : AliasSeq;

public import commands.test;

alias ALL_COMMANDS = AliasSeq!(
    commands.test
);