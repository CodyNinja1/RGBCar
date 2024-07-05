uint lastAirTime = 0;
uint lastGroundTime = 0;

uint AirTime = 0;
uint GroundTime = 0;

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

const float MIN_DIFF_GRADIENT = 0.1;

bool enabled = true;
bool online = false;

bool speedometerInstalledAlert = true;
bool fixedColorDeprecationAlert = false;

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

    RGBCar::SetCarHue(app.CurrentProfile.User_LightTrailHue);
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
    string label = opColor + Icons::Car + " RGBCar";
    if (UI::MenuItem(label, tostring(S_HueType), enabled))
    {
        enabled = !enabled;
    }
}

void Render()
{
    if ((S_MaxG - S_MinG) < MIN_DIFF_GRADIENT)
    {
        S_MaxG = MIN_DIFF_GRADIENT + S_MinG;   
    }

    if (hueMenu > 1.0)
    {
        hueMenu = -0.001;
    }

    hueMenu += 0.001;
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

        cast<CSmScriptPlayer>(player.ScriptAPI).ForceLightTrail = S_FTrails;

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

    int speed = int(base);
    int RPM = int(VehicleState::GetRPM(state));

    if ((GetCar(state) != VehicleState::VehicleType::CarSport) or S_Stupidity)
    {
        if (S_AutoStunt and (GetApp().RootMap.MapType.Contains("TM_Stunt")))
        {
            HandleStuntTheme(player, state);
            HandleModifications(player);
            return;
        }

        switch (S_HueType)
        {
            case EHueType::RGB:
                RGBCar::ChangeCarHue(S_Speed / 100.0);
                break;
                
            case EHueType::CarSpeed:
                RGBCar::SetCarHue(speed / 1000.0);
                break;
                
            case EHueType::RGBCarSpeed:
                HandleRGBCarSpeedTheme(speed);
                break;

            case EHueType::CarRPM:
                RGBCar::SetCarHue(RPM / 11000.0);
                break;

            case EHueType::Speedometer:
                HandleSpeedometerTheme(RPM);
                break;

            case EHueType::PerCarColor:
                HandlePerCarColorTheme(state);
                break;

            case EHueType::Stunt:
                HandleStuntTheme(player, state);
                break;
#if DEPENDENCY_BONK
            case EHueType::Bonk:
                HandleBonkTheme();
                break;
#endif

            default:
                S_HueType = EHueType::PerCarColor;
                if (!fixedColorDeprecationAlert)
                {
                    UI::ShowNotification("FixedColor is deprecated.", "Nadeo has removed the ability to make your car grey. Please use PerCarColor instead.");
                    fixedColorDeprecationAlert = true;
                }
                break;
        }
        
        if (RGBCar::GetCarHue(player) >= 0.999)
        {
            RGBCar::ChangeCarHue(-1.0);
        }
    }

    HandleModifications(player);
}

void HandleModifications(CSmPlayer@ player)
{
    if (S_Gradient and (S_HueType == EHueType::CarSpeed or S_HueType == EHueType::CarRPM))
    {
        // This gradient is linear, it would be better if it used a non-linear gradient
        // https://stackoverflow.com/questions/5731863/mapping-a-numeric-range-onto-another
        double slope = (S_MaxG - S_MinG) / (1 - 0);
        float hueGradient = S_MinG + slope * RGBCar::GetCarHue();
        RGBCar::SetCarHue(hueGradient);
    }

    if (S_Dossard)
    {
        if (S_DossardType == EDossard::SameAsCarColor)
        {
            cast<CSmScriptPlayer>(player.ScriptAPI).Dossard_Color = UI::HSV(RGBCar::GetCarHue(), 1, 1).xyz;
        } else if (S_DossardType == EDossard::OppositeCarColor)
        {
            cast<CSmScriptPlayer>(player.ScriptAPI).Dossard_Color = UI::HSV(Math::Abs(RGBCar::GetCarHue() - 0.5), 1, 1).xyz;
        } else
        {
            cast<CSmScriptPlayer>(player.ScriptAPI).Dossard_Color = S_DossardColor;
        }
    }
    else
    {
        cast<CSmScriptPlayer>(player.ScriptAPI).Dossard_Color = vec3(1, 1, 1);
    }
}
