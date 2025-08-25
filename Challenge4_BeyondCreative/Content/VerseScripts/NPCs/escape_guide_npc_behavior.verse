using { /Fortnite.com/AI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { Core }
using { Enums }
using { Interfaces }

 
escape_guide_npc_behavior := class(npc_behavior, event_listener):

    @editable   Stage1_Button<private>: button_device = button_device{}

    @editable   Stage2_Button<private>: button_device = button_device{}

    @editable   Stage3_Button<private>: button_device = button_device{}

    @editable   Stage4_Button<private>: button_device = button_device{}

    @editable   Stage1_Teleporter<private>: teleporter_device = teleporter_device{}

    @editable   Stage2_Teleporter<private>: teleporter_device = teleporter_device{}

    @editable   Stage3_Teleporter<private>: teleporter_device = teleporter_device{}

    @editable   Stage4_Teleporter<private>: teleporter_device = teleporter_device{}

    @editable   DoorsOpen_VoiceLine<private>: audio_player_device = audio_player_device{}

    @editable   Stage1Completed_VoiceLine<private>: audio_player_device = audio_player_device{}

    @editable   Stage2Completed_VoiceLine<private>: audio_player_device = audio_player_device{}

    @editable   Stage3Completed_VoiceLine<private>: audio_player_device = audio_player_device{}

    @editable   Stage4Completed_VoiceLine<private>: audio_player_device = audio_player_device{}


    OnBegin<override>()<suspends>:void=
        GlobalBus().Subscribe(event_key.BeginStage, "Escape Guide NPC", Self)
        GlobalBus().Subscribe(event_key.StageCompleted, "Escape Guide NPC", Self)


    OnEvent<override>(EventName: event_key, Data: event_data): void=
        case(EventName):
            event_key.BeginStage =>
                    # On stage begins, execute the behavior for that stage
                if (Stage := Data.CurrentStage?):
                    spawn { FollowStageBarrierDeactivator(Stage) }

            event_key.StageCompleted =>
                if (CurrentStage := Data.CurrentStage?, CurrentStage = EStages.Stage4):
                    Stage4Completed_VoiceLine.Play()
            _=>
                
                Print("Unhandled event: {EventKeyToString(EventName)} in player_event_bus_device")


    FollowStageBarrierDeactivator(Stage : EStages)<suspends>: void =
        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]
            NPCNav := NPCChar.GetNavigatable[]
        then:
            var MaybeButtonToFollow : ?button_device = false
                # On New stage begun, teleport the player to the starting point of the new stage, play voiceline and update button destination
            case (Stage):
                EStages.None => 
                EStages.Stage1 => 
                    set MaybeButtonToFollow = option{ Stage1_Button }
                    DoorsOpen_VoiceLine.Play()
                    Stage1_Teleporter.Teleport(NPCAgent)
                EStages.Stage2 => 
                    set MaybeButtonToFollow = option { Stage2_Button }
                    Stage1Completed_VoiceLine.Play()
                    Stage2_Teleporter.Teleport(NPCAgent)
                EStages.Stage3 => 
                    set MaybeButtonToFollow = option{ Stage3_Button }
                    Stage2Completed_VoiceLine.Play()
                    Stage3_Teleporter.Teleport(NPCAgent)
                EStages.Stage4 => 
                    set MaybeButtonToFollow = option{ Stage4_Button }
                    Stage3Completed_VoiceLine.Play()
                    Stage4_Teleporter.Teleport(NPCAgent)


            if (not MaybeButtonToFollow?). return

            loop:
                # Check if NPC is still active
                if (not NPCChar.IsActive[]):
                    break
 
                # Get current device to follow
                if (ButtonToFollow := MaybeButtonToFollow?):
                    TargetLocation := ButtonToFollow.GetTransform().Translation
                    NavResult := NPCNav.NavigateTo(MakeNavigationTarget(TargetLocation), ?ReachRadius := 25.0)
 
                    # When navigation target is reached notify event
                    if (NavResult = navigation_result.Reached):
                        GlobalBus().Notify(event_key.NPCReachesTarget, event_data{})
                        break;
