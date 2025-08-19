using { /Fortnite.com/Devices }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }

    # Tag for movable Cube Props
movable_cube_tag := class(tag):

Challenge1_Handler_Configuration<localizes>:message = "Configuration"
Challenge1_Handler_Devices<localizes>:message = "Devices"

CubeProp_MoveDistance_Description<localizes>:message = "Distance that the Cube Prop will move to in each direction (in cm)"
CubeProp_MoveDuration_Description<localizes>:message = "Time that the Cube Prop will move to each side of the square (in seconds)"

    # Struct used to store Cube Prop information
CubeForPlayerStruct := struct:
    MaybeCubeProp : ?creative_prop = false
    MaybeCubePropIndex : ?int = false


challenge1_handler := class(creative_device):

        # Configuration
    @editable:
        Categories := array { Challenge1_Handler_Configuration }
        ToolTip := CubeProp_MoveDistance_Description
    CubeProp_MoveDistance<private>: float = 100.0  # Distance to move in each direction (in cm)
 
    @editable:
        Categories := array { Challenge1_Handler_Configuration }
        ToolTip := CubeProp_MoveDuration_Description
    CubeProp_MoveDuration<private>: float = 3.0    # Time to move each side of the square (in seconds)

        # Devices
    @editable:
        Categories := array { Challenge1_Handler_Devices }
    InputTrigger<private>: input_trigger_device = input_trigger_device{}

    @editable:
        Categories := array { Challenge1_Handler_Devices }
    CubeAnimationAlreadyPlaying_HUDMessage<private>: hud_message_device = hud_message_device{}


    var CubeAnimationsKeyframes<private>: []keyframe_delta = array{} #Stores the CubeAnimation Keyframes

    var MovableCubesPlayerMap<private>: [agent]CubeForPlayerStruct = map{} # used to assign a CubeInfo Struct to a player to keep associated data for each individual player

    var MovableCubesArray<private>: []creative_prop = array{} #stores all the Cube creative_props into an array

    var MovableCubeIndexOccupiedMap<private>: [int] logic = map{} # used to assign a logic to each Cube prop index. True means it is occupied and false means it is not


    OnBegin<override>()<suspends>:void =
            # Getting all the Items with the movable_cube_tag and adding them to the MovableCubesArray if they are of type creative_prop
        TaggedItems := FindCreativeObjectsWithTag(movable_cube_tag{})
        for (TaggedItem : TaggedItems):
            if (MovableCube := creative_prop[TaggedItem]):
                set MovableCubesArray += array { MovableCube }
            else:
                Print(
                    "This tagged item is not a creative_object type!", 
                    ?Duration := 5.0, ?Color := NamedColors.Red
                )

            # Setting the value for all Cube Indexes to false inside of the MovableCubeIndexOccupiedMap
        for (CubeIndex -> MovableCubesArra : MovableCubesArray):
            if (set MovableCubeIndexOccupiedMap[CubeIndex] = false){}


            # Assign a cube to all players at the start of the game
        AllPlayers := GetPlayspace().GetPlayers()
        for (Player : AllPlayers):
            AssignCubeToPlayer(Player)

            # Assign a cube to Joined Players
        GetPlayspace().PlayerAddedEvent().Subscribe(AssignCubeToPlayer) 

        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeavesGame)


        set CubeAnimationsKeyframes = SetupCubeAnimation()
        InputTrigger.PressedEvent.Subscribe(OnPlayerPressesCubeTrigger)


    SetupCubeAnimation(): []keyframe_delta =
        Keyframes : []keyframe_delta = array{
            # Move up
            keyframe_delta{
                DeltaLocation := vector3{X := 0.0, Y := 0.0, Z := CubeProp_MoveDistance},
                DeltaRotation := IdentityRotation(),
                Time := CubeProp_MoveDuration
            },
            # Move right
            keyframe_delta{
                DeltaLocation := vector3{X := CubeProp_MoveDistance, Y := 0.0, Z := 0.0},
                DeltaRotation := IdentityRotation(),
                Time := CubeProp_MoveDuration
            },
            # Move down
            keyframe_delta{
                DeltaLocation := vector3{X := 0.0, Y := 0.0, Z := -CubeProp_MoveDistance},
                DeltaRotation := IdentityRotation(),
                Time := CubeProp_MoveDuration
            },
            # Move left (back to start)
            keyframe_delta{
                DeltaLocation := vector3{X := -CubeProp_MoveDistance, Y := 0.0, Z := 0.0},
                DeltaRotation := IdentityRotation(),
                Time := CubeProp_MoveDuration
            }
        }

        return Keyframes
 

    AssignCubeToPlayer(Player : player): void =
        if (MovableCubesArray.Length > 0):
            for (CubeIndex -> MovableCube : MovableCubesArray):
                if (MovableCubeIndexOccupiedMap[CubeIndex] = false):
                    if:
                        set MovableCubesPlayerMap[Player] =  CubeForPlayerStruct{ MaybeCubeProp := option{ MovableCube}, MaybeCubePropIndex := option {CubeIndex} }
                        set MovableCubeIndexOccupiedMap[CubeIndex] = true
                    then:
                        return
                else:
                    Print("The Movable Cube with this index is not available to be assigned to the player!!")


    OnPlayerLeavesGame(Player : player): void =
            # Remove the Cube from the player
        if (MovableCubeForPlayerInfo := MovableCubesPlayerMap[Player]):
            if:
                CubePropIndexForPlayer := MovableCubeForPlayerInfo.MaybeCubePropIndex?
                set MovableCubesPlayerMap[Player] =  CubeForPlayerStruct{ MaybeCubeProp := false, MaybeCubePropIndex := false } 
                set MovableCubeIndexOccupiedMap[CubePropIndexForPlayer] = false
            then:
                # do nothing, the Cube prop has been removed from the player and added back to the pool


    OnPlayerPressesCubeTrigger(Agent : agent): void =
        if:
            Player := player[Agent]
            MovableCubePlayer := MovableCubesPlayerMap[Player]
            CubeProp := MovableCubePlayer.MaybeCubeProp?
            CubePropIndex := MovableCubePlayer.MaybeCubePropIndex?
        then:
            if (AnimationController := CubeProp.GetAnimationController[]):
                if (CurrentAnimationState := AnimationController.GetState(), CurrentAnimationState = animation_controller_state.Playing):

                    CubeAnimationAlreadyPlaying_HUDMessage.Show(Agent)
                    return
                else:
                    AnimationController.SetAnimation(CubeAnimationsKeyframes, ?Mode := animation_mode.OneShot)
                    AnimationController.Play()


                

            