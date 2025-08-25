using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { Enums }
using { Interfaces }
using { UI }
using { UI_VerseScripts }



GameStart_Handler_Configuration<localizes>:message = "Configuration"
GameStart_Handler_Devices<localizes>:message = "Devices"


game_start_handler := class(creative_device, event_listener):

        # Devices
    @editable:
        Categories := array { GameStart_Handler_Devices }
    PlayerSpawners<private>: []player_spawner_device = array{}

    @editable:
        Categories := array { GameStart_Handler_Devices }
    GameStartCinematic<private>: cinematic_sequence_device = cinematic_sequence_device{}

    @editable:
        Categories := array { GameStart_Handler_Devices }
    GameStartAudio<private>: audio_player_device = audio_player_device{}

    @editable:
        Categories := array { GameStart_Handler_Devices }
    GameStartDoorLocks<private>: []lock_device = array{}

    @editable:
        Categories := array { GameStart_Handler_Devices }
    OpenDoorTimer<private>: timer_device = timer_device{}

    @editable:
        Categories := array { GameStart_Handler_Devices }
    AssaultLoadout_ItemGranter<private>: item_granter_device = item_granter_device{}

    @editable:
        Categories := array { GameStart_Handler_Devices }
    HeavyLoadout_ItemGranter<private>: item_granter_device = item_granter_device{}

    @editable:
        Categories := array { GameStart_Handler_Devices }
    MarksmanLoadout_ItemGranter<private>: item_granter_device = item_granter_device{}

    @editable   DebugProgressBarButton : button_device = button_device{}

    var UIStartingLoadoutPlayerMap : [agent]ui_startingloadout = map{} #Map used to assign UI to each player



    OnBegin<override>()<suspends>:void=
        for (PlayerSpawner : PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

        GlobalBus().Subscribe(event_key.WeaponLoadoutSelected, "GameStartHandler", Self)

        Sleep(1.0)

            # Play cinematic for all players and freeze them
        for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[]). FortCharacter.PutInStasis(stasis_args{})
        GameStartCinematic.Play()

        GameStartCinematic.StoppedEvent.Await() #Wait until starting cinematic has stopped

            # Show Weapon Selection UI to all players
        for (Player : GetPlayspace().GetPlayers()):
            if (PlayerUI := GetPlayerUI[Player], UIStartingLoadoutPlayer := UIStartingLoadoutPlayerMap[Player]):
                PlayerUI.AddWidget(UIStartingLoadoutPlayer.CreateCanvas(), player_ui_slot{ InputMode := ui_input_mode.All})

            # Start the Doors open timer and unfreeze players
        OpenDoorTimer.Start()
        for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[]). FortCharacter.ReleaseFromStasis()

        OpenDoorTimer.SuccessEvent.Await() #Wait for open doors timer to complete

        AllPlayers := GetPlayspace().GetPlayers()
        if (FirstPlayer := AllPlayers[0]): # Get the first player in the world since .Unlock() and Open() require an Agent
            for (GameStartDoorLock : GameStartDoorLocks):
                GameStartDoorLock.Unlock(FirstPlayer)
                GameStartDoorLock.Open(FirstPlayer)

        Sleep(2.0)

        GlobalBus().Notify(event_key.GameStartDoorUnlocked, event_data{})



    OnPlayerSpawned(Agent : agent): void =
        if (Player := player[Agent]):
                # When player spawns, initiate their UI starting loadout and notify player spawned event
            StartingLoadoutUI : ui_startingloadout = ui_startingloadout{}

            if (set UIStartingLoadoutPlayerMap[Player] = StartingLoadoutUI):

            GlobalBus().Notify(event_key.PlayerSpawned, event_data{Agent := option{Player}})



    OnEvent<override>(EventName: event_key, Data: event_data): void=
        case(EventName):
            event_key.WeaponLoadoutSelected =>
                    # Once weapon is selected in the UI by the player, remove the UI and grant them the according weapon class weapons
                if:
                    Agent := Data.Agent?
                    Player := player[Agent]
                    PlayerUI := GetPlayerUI[Player]
                    UIStartingLoadoutPlayer := UIStartingLoadoutPlayerMap[Player]
                    WeaponLoadout := Data.WeaponClassType?
                then:
                    PlayerUI.RemoveWidget(UIStartingLoadoutPlayer.MainCanvas)

                    case (WeaponLoadout):
                        EStartingLoadoutClasses.Assault => AssaultLoadout_ItemGranter.GrantItem(Agent)  
                        EStartingLoadoutClasses.Heavy => HeavyLoadout_ItemGranter.GrantItem(Agent)
                        EStartingLoadoutClasses.Marksman => MarksmanLoadout_ItemGranter.GrantItem(Agent)
                        _=>
            _=>
                
                Print("Unhandled event: {EventKeyToString(EventName)} in player_event_bus_device")

            
