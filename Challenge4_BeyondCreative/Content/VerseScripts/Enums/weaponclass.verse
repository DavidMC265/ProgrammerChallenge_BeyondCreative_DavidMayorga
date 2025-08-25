
######### Enums ###########

    # Enum that represents all the starting loadout classes for weapon selection UI
EStartingLoadoutClasses<public> := enum<public>{None, Assault, Heavy, Marksman}

    # Enum that represents all stages 
EStages<public> := enum<public>{ None, Stage1, Stage2, Stage3, Stage4 }

    # Extension function to get the stage number int from an EStages enum type
(EStage : EStages).GetStageNumber<public>(): int =
    case (EStage):
        EStages.None   => 0
        EStages.Stage1 => 1
        EStages.Stage2 => 2
        EStages.Stage3 => 3
        EStages.Stage4 => 4


