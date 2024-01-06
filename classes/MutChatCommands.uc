class MutChatCommands extends Mutator
    config(ChatCommands);

struct ICustomCommand {
    var string ChatCommand;
    var string PlayerCommand;
};

var config array<ICustomCommand> CustomCommands;

function PreBeginPlay()
{
    local ChatCommandsBroadcastHandler NewBroadcastHandler;
    local BroadcastHandler OldBroadcastHandler;

    Log("Initializing ChatCommands mutator...");

    Super.PreBeginPlay();

    NewBroadcastHandler = Spawn(class'ChatCommandsBroadcastHandler');
    NewBroadcastHandler.CustomCommands = CustomCommands;
    OldBroadcastHandler = Level.Game.BroadcastHandler;
    Level.Game.BroadcastHandler = NewBroadcastHandler;
    OldBroadcastHandler.Destroy();

    Log("ChatCommands: Spawned new broadcast handler");
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if(PlayerReplicationInfo(Other) != None && PlayerController(Other.Owner) != None)
        AddClientReplication(Other);

    return true;
}

function AddClientReplication(Actor Other)
{
    local ChatCommandsClientReplication ClientReplication;
    
    ClientReplication = Spawn(class'ChatCommandsClientReplication', Other.Owner);
    ClientReplication.NextReplicationInfo = PlayerReplicationInfo(Other).CustomReplicationInfo;
    PlayerReplicationInfo(Other).CustomReplicationInfo = ClientReplication;
}


defaultproperties {
    GroupName="ChatCommands"
    FriendlyName="Chat Commands"
    Description="Allows players to use commands such as !s to become a spectator, or !p to become a player."
}