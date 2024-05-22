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

uint16 vehicleTypeOffset = 0;

bool enabled = true;
bool online = false;
bool speedometerInstalledAlert = true;

float upShiftHue = 0.0;
int upShiftVal = 10000;

float downShiftHue = 0.0;
int downShiftVal = 6500;

int64 debugFrame = 0;

// STOLEN from https://github.com/ezio416/tm-current-effects/
uint16 GetMemberOffset(const string &in className, const string &in memberName) {
    const Reflection::MwClassInfo@ type = Reflection::GetType(className);

    if (type is null)
        throw("Unable to find reflection info for " + className);

    const Reflection::MwMemberInfo@ member = type.GetMember(memberName);

    return member.Offset;
}

// STOLEN from https://github.com/ezio416/tm-current-effects/
int GetCar(CSceneVehicleVisState@ State) {
    if (vehicleTypeOffset == 0)
        vehicleTypeOffset = GetMemberOffset("CSceneVehicleVisState", "InputSteer") - 8;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);
    if (
        Playground is null
        || Playground.Arena is null
        || Playground.Arena.Resources is null
        || Playground.Arena.Resources.m_AllGameItemModels.Length == 0
    )
        return 0;

    const uint index = Dev::GetOffsetUint8(State, vehicleTypeOffset);

    try {
        CGameItemModel@ Model = Playground.Arena.Resources.m_AllGameItemModels[index];
        if (Model is null)
            return 0;

        if (Model.Name == "CarSport")
            return 0;
        if (Model.Name == "CarSnow")
            return 1;
        if (Model.Name == "CarRally")
            return 2;
        if (Model.Name == "CarDesert")
            return 3;

        return 0;
    } catch {
        return 0;
    }
}

void HandleDisabled()
{
    CGameCtnApp@ app = cast<CGameCtnApp>(GetApp());

    CSmPlayer@ player = VehicleState::GetViewingPlayer();

    if (player is null)
    {
        return;
    }
    player.LinearHue = app.CurrentProfile.User_LightTrailHue;
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
    if (UI::MenuItem("\\$f0f" + Icons::Car + " \\$zRGBCar", "", enabled))
    {
        enabled = !enabled;
    }
}

ESpeedometerStatus getSpeedometerValues()
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
        auto vis = VehicleState::GetVis(GetApp().GameScene, player);
        if (vis is null)
        {
            yield();
            continue;
        }

        auto state = vis.AsyncState;
        if (state is null)
        {
            yield();
            continue;
        }

        float base = 0.0;

        // ice players rejoiced, billions must use Velocity
        // if (S_Velocity) {
        //     base = state.WorldVel.Length() * 3.6f;
        // } else {
        //     base = state.FrontSpeed * 3.6f;
        // }

        base = state.WorldVel.Length() * 3.6f;

        int speed = Math::Abs(int(base));
        int RPM = int(VehicleState::GetRPM(state));

        print(GetCar(state));

        if ((GetCar(state) != 0) or S_Stupidity)
        {
            if (S_HueType == EHueType::RGB)
            {
                player.LinearHue += S_Speed / 100.0;
            } else if (S_HueType == EHueType::CarSpeed)
            {
                player.LinearHue = speed / 1000.0;
            } else if (S_HueType == EHueType::CarRPMSpeedometer)
            {
                if (getSpeedometerValues() == ESpeedometerStatus::Success)
                {
                    if (RPM >= upShiftVal)
                    {
                        player.LinearHue = upShiftHue;
                    }
                    else if (RPM <= downShiftVal)
                    {
                        player.LinearHue = downShiftHue;
                    }
                    else
                    {
                        player.LinearHue = 0;
                    }
                }
                else if (getSpeedometerValues() == ESpeedometerStatus::NotInstalled)
                {
                    UI::ShowNotification("You do not have speedometer installed.", "This option requires you to install Speedometer.", vec4(1, 0, 0, 1));
                    speedometerInstalledAlert = true;
                    S_HueType = EHueType::RGB;
                } else
                {
                    UI::ShowNotification("Current Theme is not supported", "Only Basic and BasicDigital themes are supported", vec4(1, 0, 0, 1), 10000);
                    speedometerInstalledAlert = true;
                    S_HueType = EHueType::RGB;
                }
            } else if (S_HueType == EHueType::RGBCarSpeed)
            {
                if (player.LinearHue >= 0.999)
                {
                    player.LinearHue = 0;
                }
                else
                {
                    player.LinearHue += speed / (S_Factor * 1000.0);
                }
            } else if (S_HueType == EHueType::CarRPM)
            {
                player.LinearHue = RPM / 11000.0;
            
            } else if (S_HueType == EHueType::PerCarColor)
            {
                int car = GetCar(state);
                switch (car)
                {
                    case 1:
                        player.LinearHue = S_SColor;
                        break;
                    case 2:
                        player.LinearHue = S_RColor;
                        break;
                    case 3:
                        player.LinearHue = S_DColor;
                        break;
                    default:
                        player.LinearHue = S_OColor;
                        break;
                }

            } else
            {
                player.LinearHue = S_Hue;
            }
            if (player.LinearHue >= 0.999)
            {
                player.LinearHue = player.LinearHue - 1.0;
            }
        }
        
        yield();
    }
}
