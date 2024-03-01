bool SetCarColor(float hue)
{
    CSmPlayer@ player = VehicleState::GetViewingPlayer();
    if (player is null) return false;

    player.LinearHue = hue;
    
    return true;
}

bool ChangeCarColor(float hue)
{
    CSmPlayer@ player = VehicleState::GetViewingPlayer();
    if (player is null) return false;

    player.LinearHue += hue;

    return true;
}

bool IsPlayerInColorableCar()
{
    CSmPlayer@ player = VehicleState::GetViewingPlayer();
    if (player is null) return false;

    auto vis = VehicleState::GetVis(GetApp().GameScene, player);
    auto state = vis.AsyncState;

    return GetCar(state) != 0;
}

float GetCarHue(CSmPlayer@ player)
{
    CSmPlayer@ player = VehicleState::GetViewingPlayer();
    if (player is null) return -1.0;

    return player.LinearHue;
}