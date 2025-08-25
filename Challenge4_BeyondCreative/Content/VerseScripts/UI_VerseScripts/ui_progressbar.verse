using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }


    # UI progess bar class used for the barrier power that decrements when the npc reaches its target
ui_progressbar<public> := class():

    var MainCanvas<public> : canvas = canvas{}
    var InitialProgressBarValue<public>: float = 0.0

    ProgressBarBackground : color_block = color_block{ DefaultColor := NamedColors.LightGray, DefaultOpacity := 1.0, DefaultDesiredSize := vector2{ X := 0.0, Y := 32.0 }}
    ProgressBar : color_block = color_block{ DefaultColor := NamedColors.Red, DefaultOpacity := 1.0, DefaultDesiredSize := vector2{ X := 32.0, Y := 32.0} }

    BarrierPowerTextBlock : text_block = text_block{ DefaultTextColor := NamedColors.White }

    StringToMessage<localizes>(String : string): message = "{String}"

    CreateCanvas<public>(): canvas =
        BarrierPowerTextBlock.SetText(StringToMessage("Barrier Power"))

        MainCanvas.AddWidget( 
            canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X:= 0.5, Y:= 0.0 }, Maximum := vector2{ X:= 0.5, Y:= 0.0 } }
                Offsets := margin{ Left := 0.000000, Top := -48.000000, Right := 500.000000, Bottom := 30.000000 }
                Alignment := vector2{ X:= 0.5, Y:= -6.0 }
                ZOrder := 3
                SizeToContent := false
                Widget := MainStackBox()
        )

        MainCanvas.AddWidget( 
            canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X:= 0.5, Y:= 0.0 }, Maximum := vector2{ X:= 0.5, Y:= 0.0 } }
                Offsets := margin{ Left := 0.000000, Top := 0.000000, Right := 0.000000, Bottom := 30.000000 }
                Alignment := vector2{ X:= 0.5, Y:= -2.0 }
                ZOrder := 2
                SizeToContent := true
                Widget := BarrierPowerTextBlock
        )

        return MainCanvas


    MainStackBox(): stack_box =
        ProgressBarBackground.SetDesiredSize(vector2{ X := 0.0, Y := 32.0 })

        StackBox : stack_box = stack_box:
            Orientation := orientation.Horizontal

            Slots := array:
                stack_box_slot:
                    Widget := ProgressBar
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Distribution := option{ 1.0 }
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                stack_box_slot:
                    Widget := ProgressBarBackground
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := margin { Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }

        return StackBox


        # Update the Desired size of the progression bar image 
    UpdateProgressBar<public>(NewValue: float):void =
        set InitialProgressBarValue = Clamp(NewValue, 0.0, 500.0)
        ProgressBarBackground.SetDesiredSize(vector2{ X:= InitialProgressBarValue, Y := 32.0 })

        
    ResetInitialProgressBarValue<public>(): void =
        set InitialProgressBarValue = 0.0



