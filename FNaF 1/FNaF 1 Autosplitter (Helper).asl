state("FiveNightsatFreddys") {}
state("FiveNightsDEMO") {}

startup
{
    vars.Helper = Assembly.Load(File.ReadAllBytes("Components/asl-help-v2")).CreateInstance("ClickteamFusion");
    vars.Helper.Init(
        gameName: "Five Nights at Freddy's",
        generateCode: true);

    vars.Death = false;

    refreshRate = 60;
    settings.Add("fsSplits", true, "Fade Skip Splits");
    settings.Add("resetF2", true, "Reset Timer on F2");
    settings.Add("remLoads", true, "Remove Loads");

    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {        
        var timingMessage = MessageBox.Show (
            "This autosplitter requires Game Time (IGT) to remove loads.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time?",
            "LiveSplit | Five Nights at Freddy's",
            MessageBoxButtons.YesNo, MessageBoxIcon.Question
        );
        
        if (timingMessage == DialogResult.Yes)
            timer.CurrentTimingMethod = TimingMethod.GameTime;
    }
}

init
{
    vars.Helper.LoadCCN();
}

update
{
    vars.Death = timer.Run.CategoryName == "Death%";
    current.Frame = vars.Helper.App.LoadedFrame;
    if (old.Frame != current.Frame)
    {
        // In the if to avoid reading the Frame Name too much
        current.FrameName = vars.Helper.Frame.Name;
        return true;
    }
}

start
{
    if (vars.Helper.IsLoading) return false;

    if (vars.Death                     && // User is running Death%
        current.FrameName == "Frame 1" || // Game Frame is currently 'Frame 1'
        
        !vars.Death                    && // User is not running Death%
        (current.FrameName == "ad"     || // Game Frame is currently 'ad'
        current.FrameName == "what day")) // Game Frame is currently 'what day'
    {
        return true;
    }
}

split
{
    if (vars.Helper.IsLoading) return false;

    if ((vars.Death                      && // User is running Death%
        current.FrameName == "died"      || // Game Frame is currently 'died'
        current.FrameName == "freddy")   || // Game Frame is currently 'freddy'

        !vars.Death                      && // User is not running Death%
        (current.FrameName == "next day" || // Game Frame is currently 'next day'

        settings["fsSplits"]             && // Fade Skips Splits are enabled
        current.FrameName == "Frame 1"   || // Game Frame is currently 'Frame 1'
        current.FrameName == "what day"))   // Game Frame is currently 'what day'
    {
        return true;
    }
}

reset
{
    if (vars.Helper.IsLoading) return false;

    if (settings["resetF2"]             && // Reset on F2 is enabled
        current.FrameName == "Frame 17" || // Game Frame is currently 'Frame 17'

        !vars.Death                     && // User is not running Death%
        current.FrameName == "died")       // Game Frame is currently 'dued'
    {
        return true;
    }
}

isLoading
{
    return (settings["remLoads"]        && // Remove Loads is enabled
            (vars.Helper.IsLoading      || // Game is currently loading
            current.FrameName == "wait")); // Game Frame is currently 'wait'
}
