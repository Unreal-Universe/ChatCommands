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

    switch(Command)
    {
        case CommandSpectate:
        case CommandSpectateLong:
            HandleSpectate(PC);
            break;
        case CommandPlay:
        case CommandPlayLong:
            HandlePlay(PC);
            break;
        case CommandRedTeam:
        case CommandRedTeamLong:
            HandleSwichRed(PC);
            break;
        case CommandBlueTeam:
        case CommandBlueTeamLong:
            HandleSwitchBlue(PC);
            break;
        case CommandDisconnect:
            HandleDisconnect(PC);
            break;
        case CommandExit:
        case CommandQuit:
            HandleQuit(PC);
            break;
        default:
            HandleCustomCommand(Command, PC);
            break;
    }
}

function HandleSpectate(PlayerController PC)
{
    if(PC.PlayerReplicationInfo.bOnlySpectator)
        return;

    PC.BecomeSpectator();
}

function HandlePlay(PlayerController PC)
{
    if(!PC.PlayerReplicationInfo.bOnlySpectator)
        return;

    PC.BecomeActivePlayer();
}

function HandleSwichRed(PlayerController PC)
{
    if(!bTeamGame || PC.PlayerReplicationInfo.Team.TeamIndex == 0)
        return;

    if(PC.PlayerReplicationInfo.bOnlySpectator)
        PC.BecomeActivePlayer();
    PC.ChangeTeam(0);
}

function HandleSwitchBlue(PlayerController PC)
{
    if(!bTeamGame || PC.PlayerReplicationInfo.Team.TeamIndex == 1)
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