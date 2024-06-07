bool ee = false;

bool randBool()
{
    return Math::Rand(0, 2) == 1;
}

float randFloat(float min = 0, float max = 1)
{
    return Math::Rand(min, max + 0.05);
}

EHueType randType()
{
    return EHueType(Math::Rand(0, 7));
}

void EasterEgg()
{
    if (ee) return;

    print("Randomizing settings");
    UI::ShowNotification("Easter Egg Activated", ":3");

    S_Stupidity = randBool();
    S_Gradient = randBool();
    S_MinG = randFloat();
    S_MaxG = randFloat();
    S_HueType = randType();
    S_Speed = randFloat(0, 10);
    S_Hue = randFloat();
    S_Factor = randFloat(0, 20);
    S_SColor = randFloat();
    S_RColor = randFloat();
    S_DColor = randFloat();
    S_OColor = randFloat();

    ee = true;
}