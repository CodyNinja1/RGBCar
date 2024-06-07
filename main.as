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

const float MIN_DIFF_GRADIENT = 0.03;

bool enabled = true;
bool online = false;

bool speedometerInstalledAlert = true;
bool rpmDeprecationAlert = false;

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
                RGBCar::ChangeCarHue(S_Speed / 100.0);
                break;
                
            case EHueType::CarSpeed:
                RGBCar::SetCarHue(S_Speed / 1000.0);
                break;
                
            case EHueType::RGBCarSpeed:
                HandleRGBCarSpeedTheme(player, speed);
                break;

            case EHueType::CarRPM:
                if (rpmDeprecationAlert) break;
                S_HueType = EHueType::CarRPMSpeedometer;
                UI::ShowNotification("CarRPM is deprecated", "Please use CarRPMSpeedometer theme instead.");
                rpmDeprecationAlert = true;

            case EHueType::CarRPMSpeedometer:
                HandleSpeedometerTheme(RPM);
                break;

            case EHueType::PerCarColor:
                HandlePerCarHueTheme(player, state);
                break;

            default:
                RGBCar::SetCarHue(S_Hue);
                break;
        }
        
        if (RGBCar::GetCarHue(player) >= 0.999)
        {
            RGBCar::ChangeCarHue(-1.0);
        }
    }

    if (S_Gradient)
    {
        if ((S_MinMaxGradient.x - S_MinMaxGradient.y) < MIN_DIFF_GRADIENT)
        {
            if (S_MinMaxGradient.x > S_MinMaxGradient.y)
            {
                S_MinMaxGradient.x += MIN_DIFF_GRADIENT;
                S_MinMaxGradient.x
            }
            else
            {
                S_MinMaxGradient.y += MIN_DIFF_GRADIENT;
            }
        }

        // This gradient is linear, it would be better if it used a non-linear gradient
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
        RGBCar::SetCarHue(hueGradient);
    }
}