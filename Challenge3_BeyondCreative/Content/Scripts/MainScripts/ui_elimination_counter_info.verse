using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { Textures }



ui_elimination_counter_info := class():

    BackgroundImg : color_block = color_block{ DefaultColor := NamedColors.Black, DefaultOpacity := 0.3, DefaultDesiredSize := vector2{ X := 32.0, Y := 32.0} }

    NPCIconImg : texture_block = texture_block { DefaultImage := NPC_Icon_Img, DefaultDesiredSize := vector2{ X := 70.0, Y := 70.0} }

    CurrentWaveText : text_block = text_block { DefaultTextColor := NamedColors.White }
    CurrentWaveValueText : text_block = text_block { DefaultTextColor := NamedColors.White }

    EliminationsText : text_block = text_block { DefaultTextColor := NamedColors.White }
    EliminationsValueText : text_block = text_block { DefaultTextColor := NamedColors.White }

    StringToMessage<localizes>(String : string): message = "{String}"


    CreateCanvas(): canvas =
        MainCanvas : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X:= 0.0, Y:= 0.5 }, Maximum := vector2{ X:= 0.0, Y:= 0.5 } }
                    Offsets := margin{ Left := 18.0, Top := -175.0, Right := 350.0, Bottom := 120.0 }
                    Alignment := vector2{ X:= 0.0, Y:= 0.5 }
                    ZOrder := 0
                    SizeToContent := false
                    Widget := MainOverlay()

        return MainCanvas


    MainOverlay(): overlay =
        MyOverlay : overlay = overlay:
            Slots := array:
                overlay_slot:
                    Widget := BackgroundImg
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin{ Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0 }
                overlay_slot:
                    Widget := MainStackBox()
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin{ Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0 }

        return MyOverlay


    MainStackBox(): stack_box =
        StackBox : stack_box = stack_box:
            Orientation := orientation.Vertical

            Slots := array:
                stack_box_slot:
                    Widget := FirstSubStackBox()
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                stack_box_slot:
                    Widget := SecondSubStackBox()
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
        
        return StackBox


    FirstSubStackBox(): stack_box =
        CurrentWaveText.SetText(StringToMessage("Current Wave:"))

        StackBox : stack_box = stack_box:
            Orientation := orientation.Horizontal

            Slots := array:
                stack_box_slot:
                    Widget := CurrentWaveText
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 20.0, Bottom := 0.0 }
                stack_box_slot:
                    Widget := CurrentWaveValueText
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin { Top := 0.0, Left := 10.0, Right := 0.0, Bottom := 0.0 }


    SecondSubStackBox(): stack_box =
        EliminationsText.SetText(StringToMessage("Eliminations:"))

        StackBox : stack_box = stack_box:
            Orientation := orientation.Horizontal

            Slots := array:
                stack_box_slot:
                    Widget := NPCIconImg
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                stack_box_slot:
                    Widget := EliminationsText
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                stack_box_slot:
                    Widget := EliminationsValueText
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin { Top := 0.0, Left := 10.0, Right := 0.0, Bottom := 0.0 }


    UpdateWaveText<public>(NewWave : EWaves): void =
        case (NewWave):
            EWaves.None => CurrentWaveValueText.SetText(StringToMessage("None"))
            EWaves.Wave1 => CurrentWaveValueText.SetText(StringToMessage("1"))
            EWaves.Wave2 => CurrentWaveValueText.SetText(StringToMessage("2"))
            EWaves.Wave3 => CurrentWaveValueText.SetText(StringToMessage("3"))


    UpdateEliminationsText<public>(Eliminations : int): void =
        EliminationsValueText.SetText(StringToMessage("{Eliminations}"))


        