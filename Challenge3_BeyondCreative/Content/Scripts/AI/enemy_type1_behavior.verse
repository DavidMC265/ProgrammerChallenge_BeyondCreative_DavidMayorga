using { /Fortnite.com/AI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/Playspaces }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }

# The custom behavior added for this NPC class involves allowing the NPC to switch weapons depending on the distance to a player via gratners
# and head over to the healing zone if their health drops below 50% and the enemy target is not close to them

    # Enum to represent the current weapon state of the NPC
weapon_state := enum{None, Close, Long}

EnemyBehavior_DistToCloseRange_Description<localizes>:message = "Minimum distance (in cm) at which the NPC switches to a close-range weapon"

enemy_type1_behavior := class(npc_behavior):

    @editable:
        ToolTip := EnemyBehavior_DistToCloseRange_Description
    DetectEnemiesRange : float  = 1000.0

    @editable:
        ToolTip := EnemyBehavior_DistToCloseRange_Description
    DistToCloseRange : float  = 500.0

    @editable CloseRangeWeaponGranter : item_granter_device = item_granter_device{}

    @editable LongRangeWeaponGranter : item_granter_device = item_granter_device{}

    @editable HealingZone : mutator_zone_device = mutator_zone_device{}

        # Track which weapon was last granted to avoid spamming
    var CurrentWeaponState : weapon_state = weapon_state.None


    OnBegin<override>()<suspends>:void=
        Sleep(1.0)

        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]
            
            NPCNav := NPCChar.GetNavigatable[]
            NPCFocus := NPCChar.GetFocusInterface[]
            GuardActions := NPCChar.GetFortGuardActions[]
            GuardPerception := NPCChar.GetFortGuardPerception[]
        then:
            NPCSpawnLocation := NPCChar.GetTransform().Translation

            loop:
                Sleep(0.1)
                    # Check if NPC is Alive
                if (not NPCChar.IsActive[]):
                    break
                
                if (NearestTarget := FindNearestTargetFromPos[NPCChar]):
                    DistanceToTarget := Distance(NPCChar.GetTransform().Translation, NearestTarget.GetTransform().Translation)
                    DistanceToHealingZone := Distance(NPCChar.GetTransform().Translation, HealingZone.GetTransform().Translation)


                    	# Check if NPC should go to healing zone
                    if (NPCChar.GetHealth() < 50.0 and DistanceToTarget > DistToCloseRange):
                        # Navigate to healing zone
                        NavResult := NPCNav.NavigateTo(MakeNavigationTarget(HealingZone.GetTransform().Translation))

                    else:
                            # Check if the distance to the player is valid to switch to Close state and if it is not already to avoid granting the item multiple times
                        if (DistanceToTarget <= DistToCloseRange):
                            if (CurrentWeaponState <> weapon_state.Close):
                                CloseRangeWeaponGranter.GrantItem(NPCAgent)
                                set CurrentWeaponState = weapon_state.Close
                        else:
                            if (CurrentWeaponState <> weapon_state.Long):
                                LongRangeWeaponGranter.GrantItem(NPCAgent)
                                set CurrentWeaponState = weapon_state.Long
 


        # Returns the nearest Enemy that is within the detection range
    FindNearestTargetFromPos(FortChar : fort_character)<decides><transacts> : fort_character =
        var MaybeTarget : ?fort_character = false

        var CheckRange : float = DetectEnemiesRange

        if:
            Entity := GetEntity[]
            Playspace := Entity.GetPlayspaceForEntity[]
        then:
            for (Player : Playspace.GetPlayers(), PlayerFortChar := Player.GetFortCharacter[]):
                DistanceDifference := Distance(FortChar.GetTransform().Translation, PlayerFortChar.GetTransform().Translation)

                if (DistanceDifference < CheckRange and not PlayerFortChar = FortChar):
                    set MaybeTarget = option{ PlayerFortChar }
                    set CheckRange = DistanceDifference

        return MaybeTarget?

