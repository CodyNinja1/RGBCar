enum EHueType
{
    CarSpeed = 0,
    CarRPM = 1,
    CarRPMSpeedometer = 2,
    RGB = 3,
    RGBCarSpeed = 4,
    FixedColor = 5,
    PerCarColor = 6
}

[Setting name="Change color with StadiumCar" category="Base options"]
bool S_Stupidity = true;

[Setting name="Use custom gradient" category="Gradient"]
bool S_Gradient = false;

[Setting name="Gradient min." category="Gradient" min=0.0 max=1.0]
float S_MinG = 0.0;

[Setting name="Gradient max." category="Gradient" min=0.0 max=1.0]
float S_MaxG = 1.0;

[Setting name="Color effect type" category="Base options"]
EHueType S_HueType = EHueType::RGB;

[Setting name="RGB speed" category="Base options" min=0.01 max=10.0]
float S_Speed = 1.0;

[Setting name="Color" category="Base options" min=0.0 max=1.0]
float S_Hue = 0.0;

[Setting name="RGBCarSpeed factor" category="Base options" min=1.0 max=20.0]
float S_Factor = 5.0;

[Setting name="CarSnow color" category="Per-car colors" min=0.0 max=1.0 hidden]
float S_SColor = 0.530;

[Setting name="CarRally color" category="Per-car colors" min=0.0 max=1.0 hidden]
float S_RColor = 0.094;

[Setting name="CarDesert color" category="Per-car colors" min=0.0 max=1.0 hidden]
float S_DColor = 0.141;

[Setting name="Other car color" category="Per-car colors" min=0.0 max=1.0 hidden]
float S_OColor = 0.765;

float AddSettingsOptionFloat(string name, float&in ref, float min, float max)
{
    return UI::SliderFloat(name, ref, min, max);
}

void AddColorPreview(float hue)
{
    UI::SameLine();
    UI::ButtonColored("   ", hue, 1, 1);
}

[SettingsTab name="Per-car colors" icon="Tag" order="1"]
void RenderPerCarColors()
{
    float scol = AddSettingsOptionFloat("CarSnow Color  ", S_SColor, 0, 1);
    S_SColor = scol;
    AddColorPreview(S_SColor);

    float rcol = AddSettingsOptionFloat("CarRally Color   ", S_RColor, 0, 1);
    S_RColor = rcol;
    AddColorPreview(S_RColor);
    
    float dcol = AddSettingsOptionFloat("CarDesert Color", S_DColor, 0, 1);
    S_DColor = dcol;
    AddColorPreview(S_DColor);
    
    float ocol = AddSettingsOptionFloat("OtherCar Color ", S_OColor, 0, 1);
    S_OColor = ocol;
    AddColorPreview(S_OColor);
}

[SettingsTab name="Credits" icon="Heart" order="0"]
void RenderCredits()
{
    UI::Text("RGBCar v" + Meta::ExecutingPlugin().Version + "");

    UI::Text("Made with " + (ee ? "\\$0f0" : "\\$f00") + Icons::Heartbeat + "\\$z by");
    if (UI::IsItemHovered())
    {
        if (UI::IsKeyPressed(UI::Key::KeyPadEnter) or UI::IsKeyPressed(UI::Key::Insert))
        {
            EasterEgg();
        }
    }

    UI::SameLine();
    UI::PushStyleColor(UI::Col::Text, vec4(0.101, 0.539, 0.945, 1));
    UI::Text("jailman.");
    if (UI::IsItemClicked())
    {
        auto app = cast<CGameManiaPlanet>(GetApp());
        app.ManiaPlanetScriptAPI.OpenLink("https://github.com/CodyNinja1/", CGameManiaPlanetScriptAPI::ELinkType::ExternalBrowser);
    }
    UI::PopStyleColor();

    UI::Text("If you have theme suggestions or new features, make an issue on");
    UI::SameLine();
    UI::PushStyleColor(UI::Col::Text, vec4(0.101, 0.539, 0.945, 1));
    UI::Text("GitHub!");
    if (UI::IsItemClicked())
    {
        auto app = cast<CGameManiaPlanet>(GetApp());
        app.ManiaPlanetScriptAPI.OpenLink("https://github.com/CodyNinja1/RGBCar/issues/", CGameManiaPlanetScriptAPI::ELinkType::ExternalBrowser);
    }
    UI::PopStyleColor();
}