using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { Enums }
using { Interfaces }
using { UI }
using { UI_VerseScripts }



GameFlow_Manager_Configuration<localizes>:message = "Configuration"
GameFlow_Manager_Devices<localizes>:message = "Devices"
GameFlow_Manager_Stage1<localizes>:message = "Stage 1"
GameFlow_Manager_Stage2<localizes>:message = "Stage 2"
GameFlow_Manager_Stage3<localizes>:message = "Stage 3"
GameFlow_Manager_Stage4<localizes>:message = "Stage 4"


game_flow_manager := class(creative_device, event_listener):

        # Configuration
    @editable:
        Categories := array{ GameFlow_Manager_Configuration }
    NPCSpawnDelay<private>: float = 5.0

        # Devices
    @editable:
        Categories := array{ GameFlow_Manager_Stage1 }
    Stage1_Barrier<private>: barrier_device = barrier_device{}

    @editable:
        Categories := array{ GameFlow_Manager_Stage2 }
    Stage2_Barrier<private>: barrier_device = barrier_device{}

    @editable:
        Categories := array{ GameFlow_Manager_Stage3 }
    Stage3_Barrier<private>: barrier_device = barrier_device{}

    @editable:
        Categories := array{ GameFlow_Manager_Stage4 }
    Stage4_Barrier<private>: barrier_device = barrier_device{}

    @editable:
        Categories := array{ GameFlow_Manager_Stage1 }
    Stage1_NPCSpawners<private>: []npc_spawner_device = array{}

    @editable:
        Categories := array{ GameFlow_Manager_Stage2 }
    Stage2_NPCSpawners<private>: []npc_spawner_device = array{}

    @editable:
        Categories := array{ GameFlow_Manager_Stage3 }
    Stage3_NPCSpawners<private>: []npc_spawner_device = array{}

    @editable:
        Categories := array{ GameFlow_Manager_Stage4 }
    Stage4_NPCSpawners<private>: []npc_spawner_device = array{}

    @editable:
        Categories := array{ GameFlow_Manager_Stage1 }
    Stage1_PlayerSpawners<private>: []player_spawner_device = array{}

    @editable:
        Categories := array{ GameFlow_Manager_Stage2 }
    Stage2_PlayerSpawners<private>: []player_spawner_device = array{}

    @editable:
        Categories := array{ GameFlow_Manager_Stage3 }
    Stage3_PlayerSpawners<private>: []player_spawner_device = array{}

    @editable:
        Categories := array{ GameFlow_Manager_Stage4 }
    Stage4_PlayerSpawners<private>: []player_spawner_device = array{}

    @editable:
        Categories := array{ GameFlow_Manager_Devices }
    StageCleared_HUDMessage<private>: hud_message_device = hud_message_device{}

    @editable:
        Categories := array{ GameFlow_Manager_Devices }
    EndGameDevice<private>: end_game_device = end_game_device{}

    @editable:
        Categories := array{ GameFlow_Manager_Devices }
    GuideNPC_Spawner<private>: npc_spawner_device = npc_spawner_device{}

    var UIProgressBarPlayerMap : [agent]ui_progressbar = map{} #Map used to assign UI progress bar (barrier power) to each player

    var StartingStage : EStages = EStages.Stage1 #Default starting stage is 1 
    var CurrentStage : EStages = EStages.None

    var EmptyAgent : ?agent = false

    OnBegin<override>()<suspends>:void=
        set CurrentStage = StartingStage

            # Disable all stage 2,3 & 4 player spawners 
        for(Stage2_PlayerSpawner : Stage2_PlayerSpawners). Stage2_PlayerSpawner.Disable()
        for(Stage3_PlayerSpawner : Stage3_PlayerSpawners). Stage3_PlayerSpawner.Disable()
        for(Stage4_PlayerSpawner : Stage3_PlayerSpawners). Stage4_PlayerSpawner.Disable()


        GuideNPC_Spawner.EliminatedEvent.Subscribe(OnGuideNPCEliminated)

            #Event bus subscriptions
        GlobalBus().Subscribe(event_key.PlayerSpawned, "GameFlowManager", Self)
        GlobalBus().Subscribe(event_key.GameStartDoorUnlocked, "GameFlowManager", Self)
        GlobalBus().Subscribe(event_key.NPCReachesTarget, "GameFlowManager", Self)


    OnEvent<override>(EventName: event_key, Data: event_data): void=
        case(EventName):
            event_key.PlayerSpawned =>
                    # When player is spawned, initialize their progress bar UI value in the map
                ProgressBarUI : ui_progressbar = ui_progressbar{}

                if (set UIProgressBarPlayerMap[Data.Agent?] = ProgressBarUI){}

            event_key.GameStartDoorUnlocked =>
                    # When GameStart doors are unlocked, notify event with the current stage and spawn the current stage npcs
                GlobalBus().Notify(event_key.BeginStage, event_data{CurrentStage := option{ CurrentStage }})
                SpawnStageNPCs(CurrentStage)


            event_key.NPCReachesTarget =>
                    # When the Guide NPC reaches a barrier button destination, show ui for all players and start progress bar UI movement behavior
                for (Player : GetPlayspace().GetPlayers()):
                    if (PlayerUI := GetPlayerUI[Player], UIProgressBarPlayer := UIProgressBarPlayerMap[Player]):
                        PlayerUI.AddWidget(UIProgressBarPlayer.CreateCanvas())

                        spawn { UpdateProgressBar(Player) }
            _=>
                
                Print("Unhandled event: {EventKeyToString(EventName)} in player_event_bus_device")


        # Every 3 seconds, update the barrier UI progression and once reaches max value (500.0) complete the stage and reset values
    UpdateProgressBar(Player : player)<suspends>: void =
        if (PlayerUI := GetPlayerUI[Player], UIProgressBarPlayer := UIProgressBarPlayerMap[Player]):
            loop:
                Sleep(3.0)
                var CurrentProgressBarValue : float = UIProgressBarPlayer.InitialProgressBarValue
                set CurrentProgressBarValue += 50.0

                UIProgressBarPlayer.UpdateProgressBar(CurrentProgressBarValue)

                if (CurrentProgressBarValue >= 500.0):
                    OnStageCompleted(CurrentStage)
                    UIProgressBarPlayer.ResetInitialProgressBarValue()
                    break


    OnStageCompleted(StageCompleted : EStages): void =
        StageCleared_HUDMessage.Show()
            # Remove UI for players
        for (Player : GetPlayspace().GetPlayers()):
            if (PlayerUI := GetPlayerUI[Player], UIProgressBarPlayer := UIProgressBarPlayerMap[Player]):
                PlayerUI.RemoveWidget(UIProgressBarPlayer.MainCanvas)

        # For the stage completed, disable the next stage barrier, despawn all stage completed npcs, update the current stage and spawn the next stage NPCs

        case (StageCompleted):
            EStages.None =>
            EStages.Stage1 => 
                Stage1_Barrier.Disable()
                for (Stage1_NPCSpawner : Stage1_NPCSpawners):
                        Stage1_NPCSpawner.DespawnAll(EmptyAgent)
                        Stage1_NPCSpawner.Disable()

                GlobalBus().Notify(event_key.StageCompleted, event_data{CurrentStage := option{ CurrentStage }})
                set CurrentStage = EStages.Stage2
                SpawnStageNPCs(CurrentStage)

            EStages.Stage2 =>
                Stage2_Barrier.Disable()
                    for (Stage2_NPCSpawner : Stage2_NPCSpawners):
                        Stage2_NPCSpawner.DespawnAll(EmptyAgent)
                        Stage2_NPCSpawner.Disable()

                GlobalBus().Notify(event_key.StageCompleted, event_data{CurrentStage := option{ CurrentStage }})
                set CurrentStage = EStages.Stage3
                SpawnStageNPCs(CurrentStage)

            EStages.Stage3 =>
                Stage3_Barrier.Disable()
                    for (Stage3_NPCSpawner : Stage3_NPCSpawners):
                        Stage3_NPCSpawner.DespawnAll(EmptyAgent)
                        Stage3_NPCSpawner.Disable()

                GlobalBus().Notify(event_key.StageCompleted, event_data{CurrentStage := option{ CurrentStage }})
                set CurrentStage = EStages.Stage4
                SpawnStageNPCs(CurrentStage)

            EStages.Stage4 =>
                Stage4_Barrier.Disable()
                    for (Stage4_NPCSpawner : Stage4_NPCSpawners):
                        Stage4_NPCSpawner.DespawnAll(EmptyAgent)
                        Stage4_NPCSpawner.Disable()

                GlobalBus().Notify(event_key.StageCompleted, event_data{CurrentStage := option{ CurrentStage }})
                set CurrentStage = EStages.None

            # Notify stage begun event
        GlobalBus().Notify(event_key.BeginStage, event_data{CurrentStage := option{ CurrentStage }})

        
        # Spawn Stage NPCs via Enable() so it uses the editor's device configurations set
    SpawnStageNPCs(Stage : EStages): void =
        case (Stage):
            EStages.None =>
            EStages.Stage1 => 
                for (Stage1_NPCSpawner : Stage1_NPCSpawners):
                    Stage1_NPCSpawner.Enable()
            EStages.Stage2 => 
                for (Stage2_NPCSpawner : Stage2_NPCSpawners):
                    Stage2_NPCSpawner.Enable()
            EStages.Stage3 => 
                for (Stage3_NPCSpawner : Stage3_NPCSpawners):
                    Stage3_NPCSpawner.Enable()
            EStages.Stage4 => 
                for (Stage4_NPCSpawner : Stage4_NPCSpawners):
                    Stage4_NPCSpawner.Enable()


        # When the guide NPC is eliminated end the game for players
    OnGuideNPCEliminated(Result : device_ai_interaction_result): void =
        if (Source := Result.Source?):
            EndGameDevice.Activate(Source)
