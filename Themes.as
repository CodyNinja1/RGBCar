void HandleSpeedometerTheme(int RPM)
{
    CGameCtnApp@ app = cast<CGameCtnApp>(GetApp());
    if (GetSpeedometerValues() == ESpeedometerStatus::Success)
    {
        if (RPM >= upShiftVal)
        {
            RGBCar::SetCarColor(upShiftHue);
        }
        else if (RPM <= downShiftVal)
        {
            RGBCar::SetCarColor(downShiftHue);
        }
        else
        {
            RGBCar::SetCarColor(app.CurrentProfile.User_LightTrailHue);
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

void HandlePerCarColorTheme(CSmPlayer@ player, CSceneVehicleVisState@ state)
{
    VehicleState::VehicleType car = GetCar(state);
    switch (car)
    {
        case VehicleState::VehicleType::CarSnow:
            RGBCar::SetCarColor(S_SColor);
            break;
        case VehicleState::VehicleType::CarRally:
            RGBCar::SetCarColor(S_RColor);
            break;
        case VehicleState::VehicleType::CarDesert:
            RGBCar::SetCarColor(S_DColor);
            break;
        default:
            RGBCar::SetCarColor(S_OColor);
            break;
    }

}

void HandleRGBCarSpeedTheme(CSmPlayer@ player, int speed)
{
    if (RGBCar::GetCarHue() >= 0.999)
    {
        RGBCar::SetCarColor(0);
    }
    else
    {
        player.LinearHue += speed / (S_Factor * 1000.0);
    }
}