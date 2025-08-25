using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation }
using { Enums }
using { Interfaces }

    # Event data class intented for information that can be passed when event is notified
event_data<public>:=class():
    AgentMap<public>: ?[string]agent = false
    Agent<public>: ?agent = false
    FloatValue<public>: ?float = false
    IntValue<public>: ?int = false
    LogicValue<public>: ?logic = false
    Location<public>: ?vector3 = false
    Msg<public>: ?string = false
    Resource<public>: ?string = false
    WeaponClassType<public>: ?EStartingLoadoutClasses = false
    CurrentStage<public>: ?EStages = false
    
    
event_bus<public> := class():
    var Listeners: [event_key][]listener_wrapper = map{}

        # Subscribable funtion that requires the event_key, ID and interface 
    Subscribe<public>(EventName: event_key, Id: string, Listener: event_listener): void =
        Wrapper := listener_wrapper{Id := Id, Handler := Listener}
        if (Current := Listeners[EventName]):
            if(set Listeners[EventName] = Current + array{Wrapper}):
        else:
            if(set Listeners[EventName] = array{Wrapper}):

    Unsubscribe<public>(EventName: event_key, Id: string): void =
        var Remaining:[] listener_wrapper = array{}
        if (Current := Listeners[EventName]):
            for (L : Current):
                if (L.Id <> Id):  # compare by ID string
                    set Remaining = Remaining + array{L}
                else:
                    Print("Unsubscribed listener with Id: {Id} from event: {EventKeyToString(EventName)}")
            if(set Listeners[EventName] = Remaining):

        # Notify funtion that requires the event_key and the data to pass 
    Notify<public>(EventName: event_key, Data: event_data): void =
        Print("Notifying Event: {EventKeyToString(EventName)}")
        if (Handlers := Listeners[EventName]):
            for (L : Handlers):
                L.Handler.OnEvent(EventName,Data)


# ✅ Safe global for shared event bus per match/session
var singleton_map: weak_map(session, event_bus) = map{}

GlobalBus<public>(): event_bus =
    if (Map:= singleton_map[GetSession()]):
        return Map
    else:
        bus := event_bus{}
        if (set singleton_map[GetSession()] = bus):
            return bus
        else:
            return bus