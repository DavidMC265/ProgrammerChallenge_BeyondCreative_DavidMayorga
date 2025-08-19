using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }


save_data := class<persistable><final>:
    NPCEliminations : int = 0
    Wave : EWaves = EWaves.None

    # Weak map that associates a player (key) to a save_data class (value)
var SaveDataMap : weak_map(player, save_data) = map{}

    # Constructor Function to create a save_data that allows single variables to become updated 
    #and avoiding having to receive every variable without them beign reset to their default value 
MakeSaveData<constructor>(SD : save_data)<transacts>:=save_data:
    NPCEliminations := SD.NPCEliminations
    Wave := SD.Wave


    # Get Saved Data extension function for player type
(Player : player).GetSaveData(): save_data =
    if (not Player.IsActive[]):
        return save_data{}

        # Check if player had already previous Saved dataand if so, return it
    if (SD := SaveDataMap[Player]):
        return SD;
    else:
            # Create a new Saved data for player and return the new one
        NewSaveData := save_data{}
        if:
            set SaveDataMap[Player] = NewSaveData

        else. Print("Failed to set new save data for player", ?Color := NamedColors.Red, ?Duration := 3.0)

        return NewSaveData


    # Set/Update Saved Data extension function for player type
(Player : player).SetSaveData(NewSaveData : save_data): void =
    if (not Player.IsActive[]). return

        # Replace previous Saved data for player with the received one
    if. set SaveDataMap[Player] = NewSaveData
    else. Print("Failed to set save data for player", ?Color := NamedColors.Red, ?Duration := 3.0)
