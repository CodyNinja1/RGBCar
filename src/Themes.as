void HandleSpeedometerTheme(int RPM)
{
    CGameCtnApp@ app = cast<CGameCtnApp>(GetApp());
    if (GetSpeedometerValues() == ESpeedometerStatus::Success)
    {
        if (RPM >= upShiftVal)
        {
            RGBCar::SetCarHue(upShiftHue);
        }
        else if (RPM <= downShiftVal)
        {
            RGBCar::SetCarHue(downShiftHue);
        }
        else
        {
            RGBCar::SetCarHue(app.CurrentProfile.User_LightTrailHue);
        }
    }
    else if (GetSpeedometerValues() == ESpeedometerStatus::NotInstalled)
    {
        UI::ShowNotification("You do not have Speedometer installed.", "This option requires you to install Speedometer.", vec4(1, 0, 0, 1));
        speedometerInstalledAlert = true;
        S_HueType = EHueType::PerCarColor;
    }
    else
    {
        UI::ShowNotification("Current Speedometer theme is not supported", "Only Basic and BasicDigital themes are supported", vec4(1, 0, 0, 1), 10000);
        speedometerInstalledAlert = true;
        S_HueType = EHueType::PerCarColor;
    }
}

GxLight@ GetLight(CGameCtnApp@ App)
{
	ISceneVis@ GameScene = App.GameScene;
	if (GameScene !is null)
	{
		CScene@ HackScene = GameScene.HackScene;
		if (HackScene !is null)
		{
			CSceneLight@ SceneLight = HackScene.Lights[0];
			if (SceneLight !is null)
			{
				GxLight@ Light = SceneLight.Light;
				if (Light !is null)
				{
					return Light;
				}
			}
		}
	}
	return null;
}

void HandleCarSport(CSceneVehicleVisState@ state)
{
    GxLight@ Light = GetLight(GetApp());
    if (Light !is null)
    {
        Light.Color = (GetCar(state) == VehicleState::VehicleType::CarSport) and S_ExperimentalCarSport ? UI::HSV(RGBCar::GetCarHue() + 0.5, 1, 1).xyz : vec3(1, 1, 1);
    }
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

void HandlePerCarColorTheme(CSceneVehicleVisState@ state)
{
    VehicleState::VehicleType car = GetCar(state);
    switch (car)
    {
        case VehicleState::VehicleType::CarSnow:
            RGBCar::SetCarHue(S_SColor);
            break;
        case VehicleState::VehicleType::CarRally:
            RGBCar::SetCarHue(S_RColor);
            break;
        case VehicleState::VehicleType::CarDesert:
            RGBCar::SetCarHue(S_DColor);
            break;
        default:
            RGBCar::SetCarHue(S_OColor);
            break;
    }

}

void HandleRGBCarSpeedTheme(int speed)
{
    if (RGBCar::GetCarHue() >= 0.999)
    {
        RGBCar::SetCarHue(0);
    }
    else
    {
        if (S_Factor == 0) S_Factor = -0.01;
        RGBCar::ChangeCarHue(Math::Abs(speed / (S_Factor * 1000.0)));
    }
}

void HandleStuntTheme(CSmPlayer@ player, CSceneVehicleVisState@ state)
{
    if (!state.IsGroundContact)
    {
        lastAirTime = Time::Now;
    }
    if (state.IsGroundContact)
    {
        lastGroundTime = Time::Now;
    }  

    AirTime = Time::Now - lastGroundTime;
    GroundTime = Time::Now - lastAirTime;

    RGBCar::SetCarHue(cast<CGameCtnApp>(GetApp()).CurrentProfile.User_LightTrailHue);

    if (AirTime >= 1500 and cast<CSmScriptPlayer>(player.ScriptAPI).IdleDuration >= 1500)
    {
        RGBCar::SetCarHue(S_MasterColor);
    }

    if (AirTime >= 3000 and cast<CSmScriptPlayer>(player.ScriptAPI).IdleDuration >= 3000)
    {
        RGBCar::SetCarHue(S_EpicColor);
    }
}

#if DEPENDENCY_BONK
void HandleBonkTheme()
{
    bool hasBonked = Bonk::lastBonkTime() == Time::Now;
    if (hasBonked)
    {
        RGBCar::SetCarHue(S_BonkColor);
    } else
    {
        RGBCar::SetCarHue(cast<CGameCtnApp>(GetApp()).CurrentProfile.User_LightTrailHue);
    }
}
#endif
