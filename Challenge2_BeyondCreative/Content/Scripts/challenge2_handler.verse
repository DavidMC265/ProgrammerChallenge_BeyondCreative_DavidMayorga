using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Random }
using { /Verse.org/Simulation }


Challenge2_Handler_Configuration<localizes>:message = "Configuration"
Challenge2_Handler_Devices<localizes>:message = "Devices"
Challenge2_Handler_ShootingCube<localizes>:message = "Shooting Cube"
Challenge2_Handler_SphereProjectile<localizes>:message = "Sphere Projectile"

ShootingProp_MaxHitCount_Description<localizes>:message = "Amount of times that the Shooting Prop should receive damage to stop attacking"
SphereProjectile_Lifetime_Description<localizes>:message = "Time that will be counted (in seconds) before sphere projectile is destroyed automatically after being launched"
SphereProjectile_DamageRadius_Description<localizes>:message = "Total Max Distance (in cm) between the Sphere Projectile and the target to apply damage"


challenge2_handler := class(creative_device):
        # Devices
    @editable:
        Categories := array { Challenge2_Handler_Devices }
    StartOrStopAttack_Button<private>: button_device = button_device{}

    @editable:
        Categories := array { Challenge2_Handler_Devices }
    InitialWeapon_Granter<private>: item_granter_device = item_granter_device{}

        # Shooting Cube
    @editable:
        Categories := array { Challenge2_Handler_ShootingCube }
    ShootingCubeProp_PropManipulator<private> : prop_manipulator_device = prop_manipulator_device{}

    @editable:
        Categories := array { Challenge2_Handler_ShootingCube }
    ShootingCubeProp<private>: creative_prop = creative_prop{}

    @editable:
        Categories := array { Challenge2_Handler_ShootingCube }
    ShootingCubePropMaterial<private>: ?material = false

    @editable:
        Categories := array { Challenge2_Handler_ShootingCube }
        ToolTip := ShootingProp_MaxHitCount_Description
    MaxShootingCubeProp_HitCount<private>: int = 5

        # Sphere Projectile
    @editable:
        Categories := array { Challenge2_Handler_SphereProjectile }
    SphereProjectileProp<private>: creative_prop_asset = DefaultCreativePropAsset

    @editable:
        Categories := array { Challenge2_Handler_SphereProjectile }
    SphereProjectileMaterial<private>: ?material = false

    @editable:
        Categories := array { Challenge2_Handler_SphereProjectile }
        ToolTip := SphereProjectile_Lifetime_Description
    SphereProjectileLifetimeDuration<private>: float = 10.0

    @editable:
        Categories := array { Challenge2_Handler_SphereProjectile }
        ToolTip := SphereProjectile_DamageRadius_Description
    DamageRadius<private>: float = 200.0 # in cm
 
    @editable:
        Categories := array { Challenge2_Handler_SphereProjectile }
    DamageAmount<private>: float = 10.0

    @editable:
        Categories := array { Challenge2_Handler_SphereProjectile }
    SpawnRate<private>: float = 3.0 # Spheres per second
 
    @editable:
        Categories := array { Challenge2_Handler_SphereProjectile }
    SpeedKmh<private>: float = 500.0 # Speed in km/h

 
    var CanAttack<private>: logic = false
    var MaybeCurrentCubeTarget<private>: ?player = false
    var CubePropHitCount<private>: int = 0

    StringToMessage<localizes>(String : string): message = "{String}"


    OnBegin<override>()<suspends>:void=
            # Grant Initial Weapon to all players
        AllPlayers := GetPlayspace().GetPlayers()
        for (Player : AllPlayers):
            InitialWeapon_Granter.GrantItem(Player)

        if (MaterialToAssign := ShootingCubePropMaterial?):
            ShootingCubeProp.SetMaterial(MaterialToAssign)

        ShootingCubeProp_PropManipulator.DamagedEvent.Subscribe(OnCubePropDamaged)
        StartOrStopAttack_Button.InteractedWithEvent.Subscribe(OnStartOrStopAttackButtonPressed)


    OnStartOrStopAttackButtonPressed(Agent : agent): void =
        if (CanAttack = false):
            set CanAttack = true
            StartOrStopAttack_Button.SetInteractionText(StringToMessage("Stop Cube Attack"))
                
                # Run both async funtions separately to avoid interruptions between either
            spawn{ LookAtPlayerTargetLoop() }
            spawn{ SpawnSpheresLoop() }
        else:
            set CanAttack = false
            StartOrStopAttack_Button.SetInteractionText(StringToMessage("Start Cube Attack"))
 

    LookAtPlayerTargetLoop()<suspends>:void =
        loop:
            if (CanAttack = false):
                break

                # If no valid target, or current target's character is not valid (or eliminated), choose a new random player
            if (not MaybeCurrentCubeTarget? or not MaybeCurrentCubeTarget?.GetFortCharacter[]):
                Players := GetPlayspace().GetPlayers()
                if (Players.Length > 0):
                    RandomIndex := GetRandomInt(0, Players.Length - 1)
                    if (NewTarget := Players[RandomIndex]):
                        set MaybeCurrentCubeTarget = option{NewTarget}
    
                # Rotate the ShootingCubeProp's LookAtRotation towards the current player target
            if (Target := MaybeCurrentCubeTarget?, Character := Target.GetFortCharacter[]):
                    CubePos := ShootingCubeProp.GetTransform().Translation
                    PlayerPos := Character.GetTransform().Translation
    
                        # Only yaw direction
                    Direction := vector3{
                        X := PlayerPos.X - CubePos.X,
                        Y := PlayerPos.Y - CubePos.Y,
                        Z := 0.0
                    }
    
                    if (Direction.Length() > 0.0):
                        YawAngle := ArcTan(Direction.Y, Direction.X)
                        NewRotation := MakeRotation(vector3{X := 0.0, Y := 0.0, Z := 1.0}, YawAngle)
                        if (ShootingCubeProp.TeleportTo[CubePos, NewRotation]):

            Sleep(0.1) 
    

    SpawnSpheresLoop()<suspends>:void =
        loop:
            if (CanAttack = false):
                break
    
            CubePos := ShootingCubeProp.GetTransform().Translation
            CubeRotation := ShootingCubeProp.GetTransform().Rotation
            SpawnAndLaunchSphere(CubePos, CubeRotation)

            Sleep(SpawnRate) # Wait SpawnRate seconds between each sphere
    

    SpawnAndLaunchSphere(CubePos : vector3, CubeRotation : rotation)<suspends>:void =
            # Convert the Speed km/h to m/s
        SpeedMps := SpeedKmh * 1000.0 / 3600.0
            # Spawn Sphere Projectile facing the forward vector of the ShootingCubeProp
        Forward := CubeRotation.GetLocalForward()
        SpawnResult := SpawnProp(SphereProjectileProp, CubePos, rotation{})
        if (SphereProp := SpawnResult(0)?, MaterialToAssign := SphereProjectileMaterial?):
            SphereProp.SetMaterial(MaterialToAssign)
            Velocity := Forward * SpeedMps
            spawn{ MoveSphere(SphereProp, Velocity) }
    

    MoveSphere(SphereProp : creative_prop, Velocity : vector3)<suspends>:void =
            # Race between Moving towards the target and appying damage to it if hit,
            # Self destruct if the lifetime is exceeded
            # and In case the ShootingCubeProp stops attacking, it will self destruct as well
        race:
            loop:
                if (not SphereProp.IsValid[]):
                    break
                CurrentPos := SphereProp.GetTransform().Translation

                if (CurrentTarget := MaybeCurrentCubeTarget?, CharacterTarget := CurrentTarget.GetFortCharacter[]):
                    PlayerPos := CharacterTarget.GetTransform().Translation
                    if (Distance(CurrentPos, PlayerPos) <= DamageRadius):
                        CharacterTarget.Damage(DamageAmount)
                        SphereProp.Dispose()
                        break

                NewPos := CurrentPos + Velocity * 0.1
                if (SphereProp.TeleportTo[NewPos, rotation{}]):
                    Sleep(0.01)
                else:
                    break
                
            DisposeAfterDuration(SphereProp)

            loop:
                Sleep(0.1)
                if (CanAttack = false):
                    SphereProp.Dispose()
                    break


        # Dispose the Projectile if it exceeds the lifetime value after being launched
    DisposeAfterDuration(SphereProp : creative_prop)<suspends>: void =
        var CurrentCounter : float = 0.0

        loop:
            Sleep(1.0)
            set CurrentCounter += 1.0

            if (CurrentCounter >= SphereProjectileLifetimeDuration):
                SphereProp.Dispose()
                break


    OnCubePropDamaged(Agent : agent): void =
        if (CanAttack = true):
                # Increase the hit count when the ShootingCubeProp is damaged and attacking
            set CubePropHitCount += 1

                # Once the hit count is greater or equal to the max hit count, count resets and attacking behavior is disabled
            if (CubePropHitCount >= MaxShootingCubeProp_HitCount):
                set CubePropHitCount = 0

                set CanAttack = false
                StartOrStopAttack_Button.SetInteractionText(StringToMessage("Start Cube Attack"))



            
