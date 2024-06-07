void HandleSpeedometerTheme(CSmPlayer@ player, int RPM)
{
    if (GetSpeedometerValues() == ESpeedometerStatus::Success)
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

void HandlePerCarColorTheme(CSmPlayer@ player, CSceneVehicleVisState@ state)
{
    VehicleState::VehicleType car = GetCar(state);
    switch (car)
    {
        case VehicleState::VehicleType::CarSnow:
            player.LinearHue = S_SColor;
            break;
        case VehicleState::VehicleType::CarRally:
            player.LinearHue = S_RColor;
            break;
        case VehicleState::VehicleType::CarDesert:
            player.LinearHue = S_DColor;
            break;
        default:
            player.LinearHue = S_OColor;
            break;
    }

}

void HandleRGBCarSpeedTheme(CSmPlayer@ player, int speed)
{
    if (player.LinearHue >= 0.999)
    {
        player.LinearHue = 0;
    }
    else
    {
        player.LinearHue += speed / (S_Factor * 1000.0);
    }
}