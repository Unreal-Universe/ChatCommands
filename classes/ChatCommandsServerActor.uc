class ChatCommandsServerActor extends Info;

function PreBeginPlay()
{
    Level.Game.AddMutator(string(class'MutChatCommands'), true);
    Destroy();
}