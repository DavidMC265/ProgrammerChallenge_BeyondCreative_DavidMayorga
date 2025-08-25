using { /Fortnite.com/Devices }
using { /invaliddomain/Challenge4_BeyondCreative/VerseScripts/Enums }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation }
using { Interfaces }

Quest_Controller_Configuration<localizes>:message = "Configuration"
Quest_Controller_Devices<localizes>:message = "Devices"

quest_controller := class(creative_device, event_listener):
        # Devices
    @editable:
        Categories := array { Quest_Controller_Devices }
    Quest_Tracker<private>: tracker_device = tracker_device{}

        # Description message converters for Quest tracker 
    QuestDescriptionMessage<localizes>(Value : int) : message = "Protect Jonas whilst he disables the barriers. Stage {Value}/4"
    StringToMessage<localizes>(String : string):message = "{String}"


    OnBegin<override>()<suspends>:void=
        GlobalBus().Subscribe(event_key.GameStartDoorUnlocked, "Quest Controller", Self)
        GlobalBus().Subscribe(event_key.BeginStage, "Quest Controller", Self)
        GlobalBus().Subscribe(event_key.StageCompleted, "Quest Controller", Self)


    OnEvent<override>(EventName: event_key, Data: event_data): void=
        case(EventName):
                # When the game start doors are opened, assign the quest tracker to all players 
            event_key.GameStartDoorUnlocked => Quest_Tracker.AssignToAll()
            
                # When the current stage is updated, update the quest tracker description with the stage number
            event_key.BeginStage =>
                if (NewStage := Data.CurrentStage?):
                    StageNumber := NewStage.GetStageNumber()
                    Quest_Tracker.SetDescriptionText(QuestDescriptionMessage(StageNumber))

                # After the last stage is completed (Stage 4), Update the tracker description to the End game text
            event_key.StageCompleted =>
                if (CurrentStage := Data.CurrentStage?, CurrentStage = EStages.Stage4):
                    Quest_Tracker.SetDescriptionText(StringToMessage("Get to the Ship close to shore before it departs"))
            _=>
            