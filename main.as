enum EHueType
{
    CarSpeed,
    CarRPM,
    RGB,
    RGBCarSpeed,
    FixedColor
}

uint16 snowCarOffset = 0;

bool enabled = true;

// STOLEN from https://github.com/ezio416/tm-current-effects/blob/465faccb580b4883eb0ec5502885dc0f2b2dfb1f/src/Effects.as#L247
int GetCar(CSceneVehicleVisState@ State) {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CGameCtnChallenge@ Map = App.RootMap;

    if (Map.VehicleName.GetName() == "CarSnow" || Map.VehicleName.GetName() == "CarRally") {
        return 1;
    }

    if (snowCarOffset == 0) {
        const Reflection::MwClassInfo@ type = Reflection::GetType("CSceneVehicleVisState");

        if (type is null) {
            error("Unable to find reflection info for CSceneVehicleVisState!");
            return 0;
        }

        snowCarOffset = type.GetMember("InputSteer").Offset - 8;
    }

    return Dev::GetOffsetUint8(State, snowCarOffset);
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
        auto state = vis.AsyncState;

        if (state is null)
        {
            yield();
            continue;
        }

        int speed = Math::Abs(int(state.FrontSpeed * 3.6f));
        int RPM = int(VehicleState::GetRPM(state));

        if ((GetCar(state) != 0) or S_Stupidity)
        {
            if (S_HueType == EHueType::RGB)
            {
                if (player.LinearHue >= 0.999)
                {
                    player.LinearHue = 0;
                }
                else
                {
                    player.LinearHue += S_Speed / 100.0;
                }
            } else if (S_HueType == EHueType::CarSpeed)
            {
                player.LinearHue = speed / 1000.0;
            } else if (S_HueType == EHueType::CarRPM)
            {
                player.LinearHue = RPM / 11000.0;
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
            } else 
            {
                player.LinearHue = S_Hue;
            }
        }
        
        yield();
    }
}
