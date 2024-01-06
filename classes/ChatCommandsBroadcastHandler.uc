class ChatCommandsBroadcastHandler extends BroadcastHandler;

var string CommandPrefix;
var string CommandSpectate;
var string CommandPlay;
var string CommandDisconnect;
var string CommandExit;
var string CommandQuit;
var array<MutChatCommands.ICustomCommand> CustomCommands;

function Broadcast(Actor Sender, coerce string Msg, optional name Type)
{
    if(Controller(Sender) != None && PlayerController(Sender) != None && Left(Msg, 1) == CommandPrefix)
        ExecuteCommand(Msg, PlayerController(Sender));

    Super.Broadcast(Sender, Msg, Type);
}

function ExecuteCommand(string Command, PlayerController PC)
{
    Command = Mid(Command, 1);

    if(Len(Command) == 0)
        return;
    
    if(Command ~= CommandSpectate)
        PC.BecomeSpectator();
    else if(Command ~= CommandPlay)
        PC.BecomeActivePlayer();
    else if(Command ~= CommandDisconnect)
        HandleDisconnect(PC);
    else if(Command ~= CommandExit || Command ~= CommandQuit)
        HandleQuit(PC);
    else HandleCustomCommand(Command, PC);
}

function HandleDisconnect(PlayerController PC)
{
    local ChatCommandsClientReplication ClientReplication;

    ClientReplication = class'ChatCommandsUtils'.static.GetReplication(PC);
    if(ClientReplication != None)
        ClientReplication.ExecuteCommand("Disconnect");
}

function HandleQuit(PlayerController PC)
{
    local ChatCommandsClientReplication ClientReplication;

    ClientReplication = class'ChatCommandsUtils'.static.GetReplication(PC);
    if(ClientReplication != None)
        ClientReplication.ExecuteCommand("Quit");
}


function HandleCustomCommand(string Command, PlayerController PC)
{
    local int i;

    PC.ClientMessage("Executing custom command: " $ Command);

    for(i=0; i < CustomCommands.Length; i++)
    {
        PC.ClientMessage("Comparing " $ Command $ " with " $ CustomCommands[i].ChatCommand);

        if(Command ~= CustomCommands[i].ChatCommand)
        {
            PC.ClientMessage("Executing custom command: " $ CustomCommands[i].ChatCommand $ " -> '" $ CustomCommands[i].PlayerCommand $ "'");
            ExecuteCustomCommand(CustomCommands[i], PC);
            return;
        }
    }
}

function ExecuteCustomCommand(MutChatCommands.ICustomCommand Command, PlayerController PC)
{
    local ChatCommandsClientReplication ClientReplication;

    ClientReplication = class'ChatCommandsUtils'.static.GetReplication(PC);
    if(ClientReplication != None)
        ClientReplication.ExecuteCommand(Command.PlayerCommand);
}

defaultproperties {
    CommandPrefix="!"
    CommandSpectate="s"
    CommandPlay="p"
    CommandExit="exit"
    CommandDisconnect="disconnect"
    CommandQuit="quit"
}