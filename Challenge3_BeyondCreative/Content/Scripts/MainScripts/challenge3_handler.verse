using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }


Challenge3_Handler_Configuration<localizes>:message = "Configuration"
Challenge3_Handler_Devices<localizes>:message = "Devices"

    # Enum that represents all waves and is set to persistable so it can be stored within the Saved data of the player
EWaves := enum<public><persistable>{None, Wave1, Wave2, Wave3}

    # Class used to store Wave information
    # NPC Spawner is part of the Wave Info class because in case a different NPC spawner is to be used for each wave,
    # it can be assigned to that wave
WaveInfo := class():
    @editable   NPCSpawner : npc_spawner_device = npc_spawner_device{}
    @editable   NPCsToDefeatAmount : int = 0


challenge3_handler := class(creative_device):

        # Configuration
    @editable:
        Categories := array { Challenge3_Handler_Configuration }
    Waves_Info<private>: []WaveInfo = array{}

        # Devices
    @editable:
        Categories := array{ Challenge3_Handler_Devices }
    StartButton<private>: button_device = button_device{}

    @editable:
        Categories := array { Challenge3_Handler_Devices }
    NextWave_TimerDevice<private>: timer_device = timer_device{}

    @editable:
        Categories := array{ Challenge3_Handler_Devices }
    StartingPlayerWeaponGranter<private>: item_granter_device = item_granter_device{}

    @editable:
        Categories := array { Challenge3_Handler_Devices }
    CurrentWave_EnemiesToDefeat_HUDMessage<private>: hud_message_device = hud_message_device{}

    var CurrentWaveEliminations : int = 0

    var MaybeCurrentWaveInfo : ?WaveInfo = false

    var UIEliminationsPlayerMap : [agent]ui_elimination_counter_info = map{} #Map used to assign UI to each player

    EnemiesToDefeatMessage<localizes>(Amount : int) :message = "Wave Enemies To Defeat: {Amount}" 


    OnBegin<override>()<suspends>:void=
        # Starting Weapon is only given to players at start since for this project, 
        # the Island settings Eliminated Player's Items option ise set to "Keep"
        StartingPlayerWeaponGranter.GrantItemToAll()

        StartButton.InteractedWithEvent.Subscribe(StartGame)

        for (Wave_Info : Waves_Info):
            Wave_Info.NPCSpawner.EliminatedEvent.Subscribe(OnNCPEliminated)

        NextWave_TimerDevice.SuccessEvent.Subscribe(StartNextWave)

            # Initiate UI for all players using their Saved data to set the UI's values 
        Sleep(1.0)
        AllPlayers := GetPlayspace().GetPlayers()
        for (Player : AllPlayers):
            SD := Player.GetSaveData()
            if (PlayerUI := GetPlayerUI[Player]):
                EliminationCounterInfoUI : ui_elimination_counter_info = ui_elimination_counter_info{}
                EliminationCounterInfoUI.UpdateWaveText(SD.Wave)
                EliminationCounterInfoUI.UpdateEliminationsText(SD.NPCEliminations)

                if (set UIEliminationsPlayerMap[Player] = EliminationCounterInfoUI):
                    PlayerUI.AddWidget(EliminationCounterInfoUI.CreateCanvas())
            

        # Start the game based on the Saved data from the player, update the corresponding information and initiate UI
    StartGame(Agent : agent): void =
        if (Player := player[Agent]):
            if (Waves_Info.Length <= 0):
                Print("No Waves have been configured for this device to begin the game!!", ?Color := NamedColors.Red) 
                return
            
            StartButton.Disable()
            SD := Player.GetSaveData()
            
            case (SD.Wave):
                EWaves.None => 
                        # The first wave is element 0 in the Waves_Info array 
                    if (Waves_Info.Length >= 1, FirstWaveInfo := Waves_Info[0]):
                        NewSD := save_data:
                            MakeSaveData<constructor>(SD)
                            Wave := EWaves.Wave1

                        Player.SetSaveData(NewSD)
                        
                        UpdatedSD := Player.GetSaveData()

                        set MaybeCurrentWaveInfo = option{ FirstWaveInfo }

                        if (CurrentWaveInfo := MaybeCurrentWaveInfo?, UIEliminations := UIEliminationsPlayerMap[Player]):
                            spawn { SpawnWaveNPCs(CurrentWaveInfo) }
                                #Update All UI
                            UIEliminations.UpdateWaveText(UpdatedSD.Wave)
                            CurrentWave_EnemiesToDefeat_HUDMessage.SetText(EnemiesToDefeatMessage(CurrentWaveInfo.NPCsToDefeatAmount))
                            CurrentWave_EnemiesToDefeat_HUDMessage.Show()

                EWaves.Wave1 =>
                        # The first wave is element 0 in the Waves_Info array 
                    if (Waves_Info.Length >= 1, FirstWaveInfo := Waves_Info[0]):
                        UpdatedSD := Player.GetSaveData()

                        set MaybeCurrentWaveInfo = option{ FirstWaveInfo }
                        if (CurrentWaveInfo := MaybeCurrentWaveInfo?, UIEliminations := UIEliminationsPlayerMap[Player]):
                            spawn { SpawnWaveNPCs(CurrentWaveInfo) }
                            UIEliminations.UpdateWaveText(UpdatedSD.Wave)
                            CurrentWave_EnemiesToDefeat_HUDMessage.SetText(EnemiesToDefeatMessage(CurrentWaveInfo.NPCsToDefeatAmount))
                            CurrentWave_EnemiesToDefeat_HUDMessage.Show()

                EWaves.Wave2 =>
                        # The second wave is element 0 in the Waves_Info array 
                    if (Waves_Info.Length >= 2, SecondWaveInfo := Waves_Info[1]):
                        NewSD := save_data:
                            MakeSaveData<constructor>(SD)
                            Wave := EWaves.Wave2

                        Player.SetSaveData(NewSD)

                        UpdatedSD := Player.GetSaveData()

                        set MaybeCurrentWaveInfo = option{ SecondWaveInfo }
                        if (CurrentWaveInfo := MaybeCurrentWaveInfo?, UIEliminations := UIEliminationsPlayerMap[Player]):
                            spawn { SpawnWaveNPCs(CurrentWaveInfo) }
                            UIEliminations.UpdateWaveText(UpdatedSD.Wave)
                            CurrentWave_EnemiesToDefeat_HUDMessage.SetText(EnemiesToDefeatMessage(CurrentWaveInfo.NPCsToDefeatAmount))
                            CurrentWave_EnemiesToDefeat_HUDMessage.Show()

                    # The third wave is element 0 in the Waves_Info array 
                EWaves.Wave3 =>
                    if (Waves_Info.Length >= 3, ThirdWaveInfo := Waves_Info[2]):
                        NewSD := save_data:
                            MakeSaveData<constructor>(SD)
                            Wave := EWaves.Wave3

                        Player.SetSaveData(NewSD)

                        UpdatedSD := Player.GetSaveData()

                        set MaybeCurrentWaveInfo = option{ ThirdWaveInfo }
                        if (CurrentWaveInfo := MaybeCurrentWaveInfo?, UIEliminations := UIEliminationsPlayerMap[Player]):
                            spawn { SpawnWaveNPCs(CurrentWaveInfo) }
                            UIEliminations.UpdateWaveText(UpdatedSD.Wave)
                            CurrentWave_EnemiesToDefeat_HUDMessage.SetText(EnemiesToDefeatMessage(CurrentWaveInfo.NPCsToDefeatAmount))
                            CurrentWave_EnemiesToDefeat_HUDMessage.Show()


        # Spawn amount of NPCs specified using a loop rather than Enable() function from npc_spawner_device
        # Note that the amount of NPCs to spawn has to be equal to the Spawn Count setting amount that has 
        # to be set in the editor inisde of the npc_spawner_device
    SpawnWaveNPCs(NewWaveInfo : WaveInfo)<suspends>: void =
        var SpawnCount : int = 0
        loop:
            Sleep(1.0)
            if (SpawnCount >= NewWaveInfo.NPCsToDefeatAmount):
                break

                # Spawns only a single NPC and not the amount specified in the npc_spawner_device
            NewWaveInfo.NPCSpawner.Spawn()
            set SpawnCount += 1
            

    OnNCPEliminated(Result : device_ai_interaction_result): void =
        if (ResultAgent := Result.Source?, Player := player[ResultAgent]):
            set CurrentWaveEliminations += 1
            SD := Player.GetSaveData()
            NewSD := save_data:
                MakeSaveData<constructor>(SD)

                NPCEliminations := SD.NPCEliminations + 1

            Player.SetSaveData(NewSD)

            UpdatedSD := Player.GetSaveData()
            if (UIEliminations := UIEliminationsPlayerMap[ResultAgent]):
                UIEliminations.UpdateEliminationsText(UpdatedSD.NPCEliminations)

                # Check if all wave enemies have been defeated, If so Reset the WaveElimination Counter, Eliminate all remaining NPCs and start the next wave countdown
            if (CurrentWaveInfo := MaybeCurrentWaveInfo?, CurrentWaveEliminations >= CurrentWaveInfo.NPCsToDefeatAmount):

                set CurrentWaveEliminations = 0
                CurrentWaveInfo.NPCSpawner.DespawnAll(option {Player})
                CurrentWave_EnemiesToDefeat_HUDMessage.Hide()

                NextWave_TimerDevice.StartForAll()


    # Updates the new wave, assings it to the saved data for the player and then starts the game once again
    StartNextWave(MaybeAgent : ?agent): void =
        NextWave_TimerDevice.Reset()
        if (Agent := MaybeAgent?, Player := player[Agent]):
            SD := Player.GetSaveData()

            var NewWave : EWaves = EWaves.None

            case (SD.Wave):
                EWaves.None => set NewWave = EWaves.Wave1
                EWaves.Wave1 => set NewWave = EWaves.Wave2
                EWaves.Wave2 => set NewWave = EWaves.Wave3
                EWaves.Wave3 => set NewWave = EWaves.None

            NewSD := save_data:
                MakeSaveData<constructor>(SD)

                Wave := NewWave

            Player.SetSaveData(NewSD)

            StartGame(Player)

