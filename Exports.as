namespace RGBCar 
{
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

        CSceneVehicleVis@ vis = VehicleState::GetVis(GetApp().GameScene, player);
        CSceneVehicleVisState@ state = vis.AsyncState;

        return GetCar(state) != 0;
    }

    float GetCarHue(CSmPlayer@ player)
    {
        if (player is null) return -1.0;

        return player.LinearHue;
    }
}