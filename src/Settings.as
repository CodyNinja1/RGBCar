enum EHueType
{
    CarSpeed = 0,
    CarRPM = 1,
    RGB = 3,
    RGBCarSpeed = 4,
    FixedColor = 5,
    PerCarColor = 6,
    Stunt = 7,
#if DEPENDENCY_BONK
    Bonk = 8,
#endif
    Speedometer = 2,
}

enum EDossard
{
    SameAsCarColor = 0,
    OppositeCarColor = 1,
    SeperateDossardColor = 2
}

[Setting name="Change color with StadiumCar" category="Base options"]
bool S_Stupidity = true;

[Setting name="Force trails" category="Base options"]
bool S_FTrails = false;

[Setting name="Set dossard color" category="Base options"]
bool S_Dossard = false;

[Setting name="Dossard type" category="Dossard"]
EDossard S_DossardType = EDossard::SameAsCarColor;

[Setting name="Dossard color" category="Dossard" color]
vec3 S_DossardColor = vec3(1, 0, 0.6);

[Setting name="Automatically set effect type to Stunt on stunt maps" category="Base options"]
bool S_AutoStunt = true;

[Setting name="Use custom gradient" category="Gradient" hidden]
bool S_Gradient = false;

[Setting name="Gradient min." category="Gradient" min=0.0 max=1.0 hidden]
float S_MinG = 0.0;

[Setting name="Gradient max." category="Gradient" min=0.0 max=1.0 hidden]
float S_MaxG = 1.0;

[Setting name="Color effect type" category="Base options"]
EHueType S_HueType = EHueType::RGB;

[Setting name="RGB speed" category="Base options" min=0.01 max=10.0]
float S_Speed = 1.0;

[Setting name="Color" category="Base options" min=0.0 max=1.0 hidden]
float S_Hue = 0.0;

[Setting name="RGBCarSpeed factor" category="Base options" min=-20.0 max=20.0]
float S_Factor = 5.0;

[Setting name="CarSnow color" category="Per-car colors" min=0.0 max=1.0 hidden]
float S_SColor = 0.530;

[Setting name="CarRally color" category="Per-car colors" min=0.0 max=1.0 hidden]
float S_RColor = 0.094;

[Setting name="CarDesert color" category="Per-car colors" min=0.0 max=1.0 hidden]
float S_DColor = 0.141;

[Setting name="Other car color" category="Per-car colors" min=0.0 max=1.0 hidden]
float S_OColor = 0.765;

[Setting name="Master stunt color" category="Stunts" min=0.0 max=1.0 hidden]
float S_MasterColor = 0.3;

[Setting name="Epic stunt color" category="Stunts" min=0.0 max=1.0 hidden]
float S_EpicColor = 0.6;

#if DEPENDENCY_BONK
[Setting name="Bonk color" category="Bonk" min=0.0 max=1.0 hidden]
float S_BonkColor = 0.5;
#endif

bool AddSettingsOptionBool(string name, bool&in ref)
{
    return UI::Checkbox(name, ref);
}

float AddSettingsOptionFloat(string name, float&in ref, float min = 0, float max = 1)
{
    return UI::SliderFloat(name, ref, min, max);
}

void AddColorPreview(float hue)
{
    UI::SameLine();
    UI::ButtonColored("   ", hue, 1, 1);
}

[SettingsTab name="Per-car colors" icon="Car" order="1"]
void RenderPerCarColors()
{
    float scol = AddSettingsOptionFloat("CarSnow Color", S_SColor);
    S_SColor = scol;
    AddColorPreview(S_SColor);

    float rcol = AddSettingsOptionFloat("CarRally Color", S_RColor);
    S_RColor = rcol;
    AddColorPreview(S_RColor);
    
    float dcol = AddSettingsOptionFloat("CarDesert Color", S_DColor);
    S_DColor = dcol;
    AddColorPreview(S_DColor);
    
    float ocol = AddSettingsOptionFloat("OtherCar Color", S_OColor);
    S_OColor = ocol;
    AddColorPreview(S_OColor);
}

[SettingsTab name="Gradient" icon="Flag" order="2"]
void RenderGraident()
{
    bool g = AddSettingsOptionBool("Use custom gradient", S_Gradient);
    S_Gradient = g;

    UI::Separator();

    float ming = AddSettingsOptionFloat("Minimum", S_MinG);
    S_MinG = ming;
    AddColorPreview(S_MinG);

    float maxg = AddSettingsOptionFloat("Maximum", S_MaxG, 0, 1);
    S_MaxG = maxg;
    AddColorPreview(S_MaxG);
}

[SettingsTab name="Credits" icon="Heart" order="0"]
void RenderCredits()
{
    UI::Text("RGBCar v" + Meta::ExecutingPlugin().Version + "");

    UI::Separator();

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

    UI::Separator();

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

[SettingsTab name="Stunts" icon="Random" order="3"]
void RenderStunts()
{
    float MasterColor = AddSettingsOptionFloat("Master stunt color", S_MasterColor, 0, 1);
    S_MasterColor = MasterColor;
    AddColorPreview(MasterColor);

    float EpicColor = AddSettingsOptionFloat("Epic stunt color", S_EpicColor, 0, 1);
    S_EpicColor = EpicColor;
    AddColorPreview(EpicColor);
}
#if DEPENDENCY_BONK
[SettingsTab name="Bonk" icon="Bomb" order="4"]
void RenderBonk()
{
    float BonkColor = AddSettingsOptionFloat("Bonk color", S_BonkColor, 0, 1);
    S_BonkColor = BonkColor;
    AddColorPreview(BonkColor);
}
#endif
