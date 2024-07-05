bool ee = false;

bool randBool()
{
    return Math::Rand(0, 2) == 1;
}

float randFloat(float min = 0, float max = 1)
{
    return Math::Rand(min, max);
}

vec3 randVec3()
{
    return vec3(randFloat(), randFloat(), randFloat());
}

EHueType randHueType()
{
    return EHueType(Math::Rand(0, 8));
}

EDossard randDossard()
{
    return EDossard(Math::Rand(0, 3));
}

void EasterEgg()
{
    if (ee) return;
    
    UI::ShowNotification("Easter Egg Activated", ":3");

    S_Stupidity = randBool();
    S_Gradient = randBool();
    S_MinG = randFloat();
    S_MaxG = randFloat();
    S_HueType = randHueType();
    S_Speed = randFloat(0, 10);
    S_Hue = randFloat();
    S_Factor = randFloat(0, 20);
    S_SColor = randFloat();
    S_RColor = randFloat();
    S_DColor = randFloat();
    S_OColor = randFloat();
    S_EpicColor = randFloat();
    S_MasterColor = randFloat();
    S_Dossard = randBool();
    S_DossardType = randDossard();
    S_AutoStunt = randBool();
    S_FTrails = randBool();
    S_DossardColor = randVec3();

    ee = true;
}
