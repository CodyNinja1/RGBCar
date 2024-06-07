enum ESpeedometerType
{
    Basic = 0,
    BasicDigital = 1,
    TrackmaniaTurbo = 2,
    Ascension2023 = 3
}

enum ESpeedometerStatus
{
    NotInstalled,
    Success,
    NotSupported
}

bool enabled = true;
bool online = false;
bool speedometerInstalledAlert = true;

float upShiftHue = 0.0;
int upShiftVal = 10000;

float downShiftHue = 0.0;
int downShiftVal = 6500;

float hueMenu = 0;

// thanks ezio
VehicleState::VehicleType GetCar(CSceneVehicleVisState@ State) {
    return VehicleState::GetVehicleType(State);
}

void HandleDisabled()
{
    CGameCtnApp@ app = cast<CGameCtnApp>(GetApp());

    CSmPlayer@ player = VehicleState::GetViewingPlayer();
    if (player is null)
    {
        return;
    }

    RGBCar::SetCarColor(app.CurrentProfile.User_LightTrailHue);
}

void OnDisabled()
{
    HandleDisabled();
}

void OnDestroyed()
{
    HandleDisabled();
}

void RenderMenu()
{
    vec4 rgbaMenu = UI::HSV(hueMenu, 1, 1);
    string opColor = Text::FormatOpenplanetColor(rgbaMenu.xyz);
    string label = opColor + Icons::Car + " \\$zRGBCar";
    if (UI::MenuItem(label, tostring(S_HueType), enabled))
    {
        enabled = !enabled;
    }
}

void Render()
{
    if (hueMenu > 1.0)
    {
        hueMenu = -0.01;
    }

    hueMenu += 0.01;
}

ESpeedometerStatus GetSpeedometerValues()
{
    for (int i = 0; i < Meta::AllPlugins().Length; i++)
    {
        auto plugin = Meta::AllPlugins()[i];

        if (plugin.SiteID == 207) // https://openplanet.dev/plugin/207
        {
            int type = plugin.GetSetting("Theme").ReadEnum();
            string typeStr = tostring(ESpeedometerType(type));

            if (typeStr == "Ascension2023" || typeStr == "TrackmaniaTurbo") return ESpeedometerStatus::NotSupported;

            vec4 UpShift = plugin.GetSetting(typeStr + "GaugeRPMUpshiftColor").ReadVec4();
            upShiftHue = UI::ToHSV(UpShift.x, UpShift.y, UpShift.z).x;

            vec4 DownShift = plugin.GetSetting(typeStr + "GaugeRPMDownshiftColor").ReadVec4();
            downShiftHue = UI::ToHSV(DownShift.x, DownShift.y, DownShift.z).x;

            return ESpeedometerStatus::Success;
        }
    }
    return ESpeedometerStatus::NotInstalled;
}

void Main()
{
    while (true)
    {
        if (S_Speed < 0) S_Speed = 0.01;
        if (!enabled) 
        {
            HandleDisabled();
            yield();
            continue;
        }

        if (GetApp().CurrentPlayground is null)
        {
            yield();
            continue;
        }

        CSmPlayer@ player = VehicleState::GetViewingPlayer();
        if (player is null)
        {
            yield();
            continue;
        }

        CSceneVehicleVis@ vis = VehicleState::GetVis(GetApp().GameScene, player);
        if (vis is null)
        {
            yield();
            continue;
        }

        CSceneVehicleVisState@ state = vis.AsyncState;
        if (state is null)
        {
            yield();
            continue;
        }

        HandleMainLoop(state, player);
        
        yield();
    }
}

void HandleMainLoop(CSceneVehicleVisState@ state, CSmPlayer@ player)
{
    float base = 0.0;

    base = state.WorldVel.Length() * 3.6f;

    int speed = Math::Abs(int(base));
    int RPM = int(VehicleState::GetRPM(state));

    if ((GetCar(state) != VehicleState::VehicleType::CarSport) or S_Stupidity)
    {
        switch (S_HueType)
        {
            case EHueType::RGB:
                RGBCar::ChangeCarColor(S_Speed / 100.0);
                break;
                
            case EHueType::CarSpeed:
                RGBCar::SetCarColor(S_Speed / 1000.0);
                break;
                
            case EHueType::CarRPMSpeedometer:
                HandleSpeedometerTheme(player, RPM);
                break;
                
            case EHueType::RGBCarSpeed:
                HandleRGBCarSpeedTheme(player, speed);
                break;
                
            case EHueType::CarRPM:
                RGBCar::SetCarColor(RPM / 11000.0);
                break;
                
            case EHueType::PerCarColor:
                HandlePerCarColorTheme(player, state);
                break;
                
            default:
                RGBCar::SetCarColor(S_Hue);
                break;
        }
        
        if (player.LinearHue >= 0.999)
        {
            RGBCar::ChangeCarColor(-1.0);
        }
    }

    if (S_Gradient)
    {
        // This gradient is linear, it would be better if it used a
        float min, max;
        if (S_MinMaxGradient.x > S_MinMaxGradient.y)
        {
            max = S_MinMaxGradient.x;
            min = S_MinMaxGradient.y;
        }
        else
        {
            max = S_MinMaxGradient.y;
            min = S_MinMaxGradient.x;
        }

        // https://stackoverflow.com/questions/5731863/mapping-a-numeric-range-onto-another
        float slope = max - min;
        float hueGradient = max + slope * RGBCar::GetCarHue(player);
        RGBCar::SetCarColor(hueGradient);
    }
}