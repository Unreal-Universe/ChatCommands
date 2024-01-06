class ChatCommandsUtils extends Actor
    abstract;

static function ChatCommandsClientReplication GetReplication(Controller C)
{
    local LinkedReplicationInfo LRI;

    for (LRI = C.PlayerReplicationInfo.CustomReplicationInfo; LRI != None; LRI = LRI.NextReplicationInfo)
    {
        if(ChatCommandsClientReplication(LRI) != None)
            return ChatCommandsClientReplication(LRI);
    }

    return None;
}