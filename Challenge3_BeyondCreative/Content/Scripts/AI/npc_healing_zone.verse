using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }

NPCHealingZone_Configuration<localizes>:message = "Configuration"
NPCHealingZone_Devices<localizes>:message = "Devices"

npc_healing_zone := class(creative_device):

        # Devices
    @editable:
        Categories := array { NPCHealingZone_Devices }
    HealingZone<private>: mutator_zone_device = mutator_zone_device{}


    OnBegin<override>()<suspends>:void=
        HealingZone.AgentEntersEvent.Subscribe(OnAgentEntersHealingZone)


    OnAgentEntersHealingZone(Agent : agent): void =
        if (not player[Agent]):
            spawn. HealAgent(Agent)


    HealAgent(Agent : agent)<suspends>: void =
        loop:
            Sleep(1.0)

            if (not HealingZone.IsInVolume[Agent]). break

            if (FortChar := Agent.GetFortCharacter[]):
                CurrentHealth := FortChar.GetHealth()
                MaxHealth := FortChar.GetMaxHealth()
    
                    # Only heal if not at max health
                if (CurrentHealth < MaxHealth):
                        # Calculate new health, ensuring it doesn't exceed max
                    NewHealth := if (CurrentHealth + 10.0 > MaxHealth) { MaxHealth } else { CurrentHealth + 10.0 }
                    FortChar.SetHealth(NewHealth)
                    UpdatedCurrentHealth := FortChar.GetHealth()


            
