import jcli;
import commands;

int main(string[] args)
{
    auto cli = new CommandLineInterface!ALL_COMMANDS();
    return cli.parseAndExecute(args);
}
