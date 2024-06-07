enum EHueType
{
    CarSpeed,
    CarRPM,
    CarRPMSpeedometer,
    RGB,
    RGBCarSpeed,
    FixedColor,
    PerCarColor
}

[Setting name="Change color with StadiumCar" category="Base options"]
bool S_Stupidity = true;

[Setting name="Use custom gradient" category="Gradient"]
bool S_Gradient = false;

[Setting name="Gradient Miniumum and Maximum" category="Gradient"]
vec2 S_MinMaxGradient = vec2(0, 1);

[Setting name="Color effect type" category="Base options"]
EHueType S_HueType = EHueType::RGB;

[Setting name="RGB speed" category="Base options" min=0.01 max=10.0]
float S_Speed = 1.0;

[Setting name="Color" category="Base options" min=0.0 max=1.0]
float S_Hue = 0.0;

[Setting name="RGBCarSpeed factor" category="Base options" min=1.0 max=20.0]
float S_Factor = 5.0;

[Setting name="CarSnow color" category="Per-car colors" min=0.0 max=1.0]
float S_SColor = 0.0;

[Setting name="CarRally color" category="Per-car colors" min=0.0 max=1.0]
float S_RColor = 0.0;

[Setting name="CarDesert color" category="Per-car colors" min=0.0 max=1.0]
float S_DColor = 0.0;

[Setting name="Other car color" category="Per-car colors" min=0.0 max=1.0]
float S_OColor = 0.0;
