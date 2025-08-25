using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation }
using { Core }

    # Main interface that devices have to implment to listen for events
event_listener<public> := interface:
    OnEvent<public>(EventName: event_key, Data: event_data): void


    # Wrapper that cointains the Id and interface of the device implementing the interface
listener_wrapper<public> := class:
    Id<public>: string
    Handler<public>: event_listener