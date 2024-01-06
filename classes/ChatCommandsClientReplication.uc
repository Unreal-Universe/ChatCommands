class ChatCommandsClientReplication extends LinkedReplicationInfo;

replication
{
    reliable if(Role == ROLE_Authority) ExecuteCommand;
}

final simulated function ExecuteCommand(string Command)
{
    local PlayerController PC;

    if((Level.NetMode != NM_Client && Level.NetMode != NM_Standalone) || Command == "")
        return;

    PC = Level.GetLocalPlayerController();
    if(PC != None)
        PC.ConsoleCommand(Command);
}
