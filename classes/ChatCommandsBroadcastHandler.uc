class ChatCommandsBroadcastHandler extends BroadcastHandler;

var string CommandPrefix;
var string CommandSpectate;
var string CommandPlay;
var string CommandDisconnect;
var string CommandQuit;
var array<MutChatCommands.ICustomCommand> CustomCommands;

function Broadcast(Actor Sender, coerce string Msg, optional name Type)
{
    if(Controller(Sender) != None && PlayerController(Sender) != None && Left(Msg, 1) == CommandPrefix)
        ExecuteCommand(Msg, PlayerController(Sender));

    Super.Broadcast(Sender, Msg, Type);
}

function ExecuteCommand(string Command, PlayerController Sender)
{
    Command = Mid(Command, 1);

    if(Len(Command) == 0)
        return;
    
    if(Command ~= CommandSpectate)
        Sender.BecomeSpectator();
    else if(Command ~= CommandPlay)
        Sender.BecomeActivePlayer();
}

function HandleQuit()
{

}

defaultproperties {
    CommandPrefix="!"
    CommandSpectate="s"
    CommandPlay="p"
    CommandDisconnect="disconnect"
    CommandQuit="quit"
}