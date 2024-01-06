class ChatCommandsBroadcastHandler extends BroadcastHandler;

var string CommandPrefix;
var string CommandSpectate, CommandSpectateLong;
var string CommandPlay, CommandPlayLong;
var string CommandRedTeam, CommandRedTeamLong;
var string CommandBlueTeam, CommandBlueTeamLong;
var string CommandDisconnect;
var string CommandExit;
var string CommandQuit;
var bool bTeamGame;
var array<MutChatCommands.ICustomCommand> CustomCommands;

function PreBeginPlay()
{
    Super.PreBeginPlay();
    bTeamGame = TeamGame(Level.Game) != None;
}

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
    
    if((Command ~= CommandSpectate || Command ~= CommandSpectateLong) && !PC.PlayerReplicationInfo.bOnlySpectator)
        PC.BecomeSpectator();
    else if(Command ~= CommandPlay || Command ~= CommandPlayLong)
        PC.BecomeActivePlayer();
    else if(Command ~= CommandRedTeam || Command ~= CommandRedTeamLong)
        HandleSwichRed(PC);
    else if(Command ~= CommandBlueTeam || Command ~= CommandBlueTeamLong)
        HandleSwitchBlue(PC);
    else if(Command ~= CommandDisconnect)
        HandleDisconnect(PC);
    else if(Command ~= CommandExit || Command ~= CommandQuit)
        HandleQuit(PC);
    else
        HandleCustomCommand(Command, PC);
}

function HandleSwichRed(PlayerController PC)
{
    if(!bTeamGame)
        return;

    if(PC.PlayerReplicationInfo.bOnlySpectator)
        PC.BecomeActivePlayer();
    PC.ChangeTeam(0);
}

function HandleSwitchBlue(PlayerController PC)
{
    if(!bTeamGame)
        return;

    if(PC.PlayerReplicationInfo.bOnlySpectator)
        PC.BecomeActivePlayer();
    PC.ChangeTeam(1);
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

    for(i=0; i < CustomCommands.Length; i++)
    {
        if(Command ~= CustomCommands[i].ChatCommand)
        {
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
    CommandRedTeam="r"
    CommandBlueTeam="b"
    CommandExit="exit"

    // Long commands
    CommandSpectateLong="spec"
    CommandPlayLong="play"
    CommandRedTeamLong="red"
    CommandBlueTeamLong="blue"
    CommandDisconnect="disconnect"
    CommandQuit="quit"
}