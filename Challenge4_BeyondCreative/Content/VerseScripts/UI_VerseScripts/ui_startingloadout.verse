using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { Core }
using { Enums }
using { Textures.Weapons }


# UI starting loadout class used for weapon selection 

ui_startingloadout<public> := class():

    AssaultRifleIcon : texture_block = texture_block { DefaultImage := AssaultRifleIconImg, DefaultDesiredSize := vector2{ X := 150.0, Y := 150.0} }
    PumpShotgunIcon : texture_block = texture_block { DefaultImage := PumpShotgunIconImg, DefaultDesiredSize := vector2{ X := 150.0, Y := 150.0} }
    LightMachineGunIcon : texture_block = texture_block { DefaultImage := LightMachineGunIconImg, DefaultDesiredSize := vector2{ X := 150.0, Y := 150.0} }
    PistolGunIcon : texture_block = texture_block { DefaultImage := PistolGunIconImg, DefaultDesiredSize := vector2{ X := 150.0, Y := 150.0} }
    SemiAutoIcon : texture_block = texture_block { DefaultImage := SemiAutoIconImg, DefaultDesiredSize := vector2{ X := 150.0, Y := 150.0} }
    SupressedPistolIcon : texture_block = texture_block { DefaultImage := SupressedPistolIconImg, DefaultDesiredSize := vector2{ X := 150.0, Y := 150.0} }

    BackgroundImgSlot1 : color_block = color_block{ DefaultColor := NamedColors.Red, DefaultOpacity := 0.4, DefaultDesiredSize := vector2{ X := 32.0, Y := 32.0} }
    BackgroundImgSlot2 : color_block = color_block{ DefaultColor := NamedColors.Blue, DefaultOpacity := 0.4, DefaultDesiredSize := vector2{ X := 32.0, Y := 32.0} }
    BackgroundImgSlot3 : color_block = color_block{ DefaultColor := NamedColors.Yellow, DefaultOpacity := 0.4, DefaultDesiredSize := vector2{ X := 32.0, Y := 32.0} }

    AssaultText : text_block = text_block { DefaultTextColor := NamedColors.White }
    AssaultButton : button_loud = button_loud{}

    HeavyText : text_block = text_block { DefaultTextColor := NamedColors.White }
    HeavyButton : button_loud = button_loud{}

    MarksmanText : text_block = text_block { DefaultTextColor := NamedColors.White }
    MarksmanButton : button_loud = button_loud{}

    StringToMessage<localizes>(String : string): message = "{String}"

    var MainCanvas<public> : canvas = canvas{}

    CreateCanvas<public>(): canvas =
        MainCanvas.AddWidget( canvas_slot:
            Anchors := anchors{ Minimum := vector2{ X:= 0.5, Y:= 0.5 }, Maximum := vector2{ X:= 0.5, Y:= 0.5 } }
            Offsets := margin{ Left := 0.0, Top := 0.0, Right := 1000.000000, Bottom := 500.000000 }
            Alignment := vector2{ X:= 0.5, Y:= 0.5 }
            ZOrder := 0
            SizeToContent := false
            Widget := MainOverlay()
        )

        return MainCanvas


    MainOverlay(): overlay =
        MyOverlay : overlay = overlay:
            Slots := array:
                overlay_slot:
                    Widget := MainStackBox()
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{ Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0 }

        return MyOverlay


    MainStackBox(): stack_box =
        StackBox : stack_box = stack_box:
            Orientation := orientation.Horizontal

            Slots := array:
                stack_box_slot:
                    Widget := FirstSubOverlay()
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                stack_box_slot:
                    Widget := SecondSubOverlay()
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                stack_box_slot:
                    Widget := ThirdSubOverlay()
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
        
        return StackBox


    FirstSubOverlay(): overlay =
        MyOverlay : overlay = overlay:
            Slots := array:
                overlay_slot:
                    Widget := BackgroundImgSlot1
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                overlay_slot:
                    Widget := FirstSubStackBox()
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 40.0, Bottom := 0.0 }


    SecondSubOverlay(): overlay =
        MyOverlay : overlay = overlay:
            Slots := array:
                overlay_slot:
                    Widget := BackgroundImgSlot2
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                overlay_slot:
                    Widget := SecondSubStackBox()
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 40.0, Bottom := 0.0 }


    ThirdSubOverlay(): overlay =
        MyOverlay : overlay = overlay:
            Slots := array:
                overlay_slot:
                    Widget := BackgroundImgSlot3
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                overlay_slot:
                    Widget := ThirdSubStackBox()
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 40.0, Bottom := 0.0 }


    FirstSubStackBox(): stack_box =
        AssaultText.SetText(StringToMessage("Assault"))
        AssaultButton.SetText(StringToMessage("SELECT"))
        AssaultButton.OnClick().Subscribe(OnAssaultWeaponsSelected)

        StackBox : stack_box = stack_box:
            Orientation := orientation.Vertical

            Slots := array:
                stack_box_slot:
                    Widget := AssaultText
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                stack_box_slot:
                    Widget := FirstWeaponsStackBox()
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin { Top := 20.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                stack_box_slot:
                    Widget := AssaultButton
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 50.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }


    SecondSubStackBox(): stack_box =
        HeavyText.SetText(StringToMessage("Heavy"))
        HeavyButton.SetText(StringToMessage("SELECT"))
        HeavyButton.OnClick().Subscribe(OnHeavyWeaponsSelected)

        StackBox : stack_box = stack_box:
            Orientation := orientation.Vertical

            Slots := array:
                stack_box_slot:
                    Widget := HeavyText
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                stack_box_slot:
                    Widget := SecondWeaponsStackBox()
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin { Top := 20.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                stack_box_slot:
                    Widget := HeavyButton
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 50.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }


    ThirdSubStackBox(): stack_box =
        MarksmanText.SetText(StringToMessage("Marksman"))
        MarksmanButton.SetText(StringToMessage("SELECT"))
        MarksmanButton.OnClick().Subscribe(OnMarksmanWeaponsSelected)

        StackBox : stack_box = stack_box:
            Orientation := orientation.Vertical

            Slots := array:
                stack_box_slot:
                    Widget := MarksmanText
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                stack_box_slot:
                    Widget := ThirdWeaponsStackBox()
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin { Top := 20.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                stack_box_slot:
                    Widget := MarksmanButton
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 50.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }



    FirstWeaponsStackBox(): stack_box =
        StackBox : stack_box = stack_box:
            Orientation := orientation.Horizontal

            Slots := array:
                stack_box_slot:
                    Widget := AssaultRifleIcon
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                stack_box_slot:
                    Widget := PumpShotgunIcon
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 20.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }


    SecondWeaponsStackBox(): stack_box =
        StackBox : stack_box = stack_box:
            Orientation := orientation.Horizontal

            Slots := array:
                stack_box_slot:
                    Widget := LightMachineGunIcon
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                stack_box_slot:
                    Widget := PistolGunIcon
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 20.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }


    ThirdWeaponsStackBox(): stack_box =
        StackBox : stack_box = stack_box:
            Orientation := orientation.Horizontal

            Slots := array:
                stack_box_slot:
                    Widget := SemiAutoIcon
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                stack_box_slot:
                    Widget := SupressedPistolIcon
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 20.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }

            
        # On UI buttons pressed, notify event with the according class information for the player

    OnAssaultWeaponsSelected(Message : widget_message): void =
        Player := Message.Player
        GlobalBus().Notify(event_key.WeaponLoadoutSelected, event_data{Agent := option{Player}, WeaponClassType := option{EStartingLoadoutClasses.Assault}})


    OnHeavyWeaponsSelected(Message : widget_message): void =
        Player := Message.Player
        GlobalBus().Notify(event_key.WeaponLoadoutSelected, event_data{Agent := option{Player}, WeaponClassType := option{EStartingLoadoutClasses.Heavy}})


    OnMarksmanWeaponsSelected(Message : widget_message): void =
        Player := Message.Player
        GlobalBus().Notify(event_key.WeaponLoadoutSelected, event_data{Agent := option{Player}, WeaponClassType := option{EStartingLoadoutClasses.Marksman}})
