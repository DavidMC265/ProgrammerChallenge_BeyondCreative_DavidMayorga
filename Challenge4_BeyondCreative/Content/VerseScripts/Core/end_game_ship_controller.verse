using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { Enums }
using { Interfaces }


EndGameShip_Controller_Configuration<localizes>:message = "Configuration"
EndGameShip_Controller_Devices<localizes>:message = "Devices"

end_game_ship_controller := class(creative_device, event_listener):

        # Devices
    @editable:
        Categories := array{ EndGameShip_Controller_Devices }
    Ship_MapIndicator<private>: map_indicator_device = map_indicator_device{}

    @editable:
        Categories := array{ EndGameShip_Controller_Devices }
    Ship_MutatorZone<private>: mutator_zone_device = mutator_zone_device{}

    @editable:
        Categories := array{ EndGameShip_Controller_Devices }
    Ship_Timer<private>: timer_device = timer_device{}

    @editable:
        Categories := array { EndGameShip_Controller_Devices }
    Ship_Chairs<private>: []chair_device = array{}

    @editable:
        Categories := array{ EndGameShip_Controller_Devices }
    EndGameDevice<private>: end_game_device = end_game_device{}


    OnBegin<override>()<suspends>:void=
        Ship_MutatorZone.AgentEntersEvent.Subscribe(MountPlayerOnShip)

        GlobalBus().Subscribe(event_key.StageCompleted, "EndGame Ship Controller", Self)


    OnEvent<override>(EventName: event_key, Data: event_data): void=
        case(EventName):
            event_key.StageCompleted =>
                    # When the last stage is completed (Stage 4) initiate End Game Behavior
                if (CurrentStage := Data.CurrentStage?, CurrentStage = EStages.Stage4):
                    spawn . BeginShipEscape()
            _=>


    BeginShipEscape()<suspends>: void =
            # Show objective marker for players and start the escape timer
        for (Player : GetPlayspace().GetPlayers()). Ship_MapIndicator.ActivateObjectivePulse(Player)
            Ship_Timer.Start()

                # Wait until either the esapce timer ends or all players have aborded the ship to end the game
            race:
                Ship_Timer.SuccessEvent.Await()
                CheckIfAllPlayersAreSeated()

            if (AllPlayers := GetPlayspace().GetPlayers(), FirstPlayer := AllPlayers[0]). EndGameDevice.Activate(FirstPlayer)


    MountPlayerOnShip(Agent : agent): void =
            # Deactivate objective marker for player and find a chair that is not occupied
        Ship_MapIndicator.DeactivateObjectivePulse(Agent)
        for (Ship_Chair : Ship_Chairs):
            if (not Ship_Chair.IsOccupied[]):
                Ship_Chair.Seat(Agent)
                return

    CheckIfAllPlayersAreSeated()<suspends>: void =
            # Continious loop to check if all chairs are occupied and if so, all players have been seated
        loop:
            Sleep(0.1)
            var AllOccupied : logic = true
            for (Ship_Chair : Ship_Chairs):
                if (not Ship_Chair.IsOccupied[]):
                    set AllOccupied = false
            if (AllOccupied = true):
                break

