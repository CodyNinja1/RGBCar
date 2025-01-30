namespace RGBCar 
{
    bool SetCarHue(float hue)
    {
        CSmPlayer@ player = VehicleState::GetViewingPlayer();
        if (player is null) return false;

        CSceneVehicleVis@ vis = VehicleState::GetVis(GetApp().GameScene, player);
        CSceneVehicleVisState@ state = vis.AsyncState;

        player.LinearHue = hue;
        HandleCarSport(state);
        
        return true;
    }

    bool ChangeCarHue(float hue)
    {
        CSmPlayer@ player = VehicleState::GetViewingPlayer();
        if (player is null) return false;

        CSceneVehicleVis@ vis = VehicleState::GetVis(GetApp().GameScene, player);
        CSceneVehicleVisState@ state = vis.AsyncState;

        player.LinearHue += hue;
        HandleCarSport(state);

        return true;
    }

    bool IsPlayerInColorableCar()
    {
        return true;
    }

    float GetCarHue(CSmPlayer@ player)
    {
        // Returns -1 when player is null.
        if (player is null) return -1.0;

        return player.LinearHue;
    }

    float GetCarHue()
    {
        // Returns -1 when player is null.
        CSmPlayer@ player = VehicleState::GetViewingPlayer();
        if (player is null) return -1;

        return player.LinearHue;
    }
}