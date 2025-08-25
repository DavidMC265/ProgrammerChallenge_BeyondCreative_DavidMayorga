
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

    # Event keys for various game events, can always be extended/modified

event_key<public> := enum<open>{
    PlayerSpawned,
    PlayerJoinedSession,
    PlayerLeftSession,
    PlayerTakenDamage,
    PlayerDied,
    PlayerEliminatedSelf,
    PlayerEliminatedPlayer,
    PlayerEliminatedCreature,
    PlayerRespawned,
    EnvironmentEliminatedCreature,
    UpdateHUD,
    GameStarted,
    GameEnded,
    ItemCollected,
    AchievementUnlocked,
    GameStartDoorUnlocked,
    WeaponLoadoutSelected,
    NPCReachesTarget,
    BeginStage,
    StageCompleted
}

    # Extension funtion to get the string of all event_key types
EventKeyToString<public>(Value:event_key):string =
    case(Value):
        event_key.PlayerSpawned => "PlayerSpawned"
        event_key.PlayerJoinedSession => "PlayerJoinedSession"
        event_key.PlayerLeftSession => "PlayerLeftSession"
        event_key.PlayerTakenDamage => "PlayerTakenDamage"
        event_key.PlayerDied => "PlayerDied"
        event_key.PlayerEliminatedSelf => "PlayerEliminatedSelf"
        event_key.PlayerEliminatedPlayer => "PlayerEliminatedPlayer"
        event_key.PlayerEliminatedCreature => "PlayerEliminatedCreature"
        event_key.PlayerRespawned => "PlayerRespawned"
        event_key.EnvironmentEliminatedCreature => "EnvironmentEliminatedCreature"
        event_key.GameStarted => "GameStarted"
        event_key.GameEnded => "GameEnded"
        event_key.ItemCollected => "ItemCollected"
        event_key.AchievementUnlocked =>  "AchievementUnlocked"
        event_key.UpdateHUD => "UpdateHUD"
        event_key.GameStartDoorUnlocked => "Game Start Cinematic Completed"
        event_key.WeaponLoadoutSelected => "Weapon Loadout Selected"
        event_key.NPCReachesTarget => "NPC Reached target"
        event_key.StageCompleted => "Stage Completed"
        _=>""