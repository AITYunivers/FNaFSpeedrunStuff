state("FiveNightsatFreddys") {}
state("FiveNightsDEMO") {}

startup
{
    vars.Helper = Assembly.Load(File.ReadAllBytes("Components/asl-help-v2")).CreateInstance("ClickteamFusion");
    vars.Helper.Init(
        gameName: "Five Nights at Freddy's",
        generateCode: true);

    vars.PreviousFrame = -1;
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
}

start
{
    if (vars.PreviousFrame != vars.Helper.App.CurrentFrame && !vars.Helper.IsLoading)
    {
        if (vars.Death                          && // User is running Death%
            vars.Helper.Frame.Name == "Frame 1" || // Game Frame is currently 'Frame 1'
            
            !vars.Death                         && // User is not running Death%
            (vars.Helper.Frame.Name == "ad"     || // Game Frame is currently 'ad'
            vars.Helper.Frame.Name == "what day")) // Game Frame is currently 'what day'
        {
            vars.PreviousFrame = vars.Helper.App.CurrentFrame;
            return true;
        }
    }
}

split
{
    if (vars.PreviousFrame != vars.Helper.App.CurrentFrame && !vars.Helper.IsLoading)
    {
        if ((vars.Death                           && // User is running Death%
            vars.Helper.Frame.Name == "died"      || // Game Frame is currently 'died'
            vars.Helper.Frame.Name == "freddy")   || // Game Frame is currently 'freddy'

            !vars.Death                           && // User is not running Death%
            (vars.Helper.Frame.Name == "next day" || // Game Frame is currently 'next day'

            settings["fsSplits"]                  && // Fade Skips Splits are enabled
            vars.Helper.Frame.Name == "Frame 1"   || // Game Frame is currently 'Frame 1'
            vars.Helper.Frame.Name == "what day"))   // Game Frame is currently 'what day'
        {
            vars.PreviousFrame = vars.Helper.App.CurrentFrame;
            return true;
        }
    }
}

reset
{
    if (vars.PreviousFrame != vars.Helper.App.CurrentFrame && !vars.Helper.IsLoading)
    {
        if (settings["resetF2"]                  && // Reset on F2 is enabled
            vars.Helper.Frame.Name == "Frame 17" || // Game Frame is currently 'Frame 17'

            !vars.Death                          && // User is not running Death%
            vars.Helper.Frame.Name == "died")       // Game Frame is currently 'dued'
        {
            vars.PreviousFrame = vars.Helper.App.CurrentFrame;
            return true;
        }
    }
}

isLoading
{
    return (settings["remLoads"]             && // Remove Loads is enabled
            (vars.Helper.IsLoading           || // Game is currently loading
            vars.Helper.Frame.Name == "wait")); // Game Frame is currently 'wait'
}
