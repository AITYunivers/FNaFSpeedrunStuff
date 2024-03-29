state("FiveNightsatFreddys2") {}
state("FiveNightsatFreddys2_DEMO") {}

startup
{
    vars.PAMU = 0;
    vars.Resetting = false;
    vars.Death = false;
    vars.Split = false;
    vars.Watchers = null;
    
    vars.Frames = new Dictionary<string, int>()
    {
        {"Unloaded",              -1},
        {"Warning",                0},
        {"Title",                  1},
        {"12AM",                   2},
        {"Gameplay",               3},
        {"Death",                  4},
        {"6AM",                    5},
        {"Game Over",              6},
        {"Loading",                7},
        {"Newspaper",              8},
        {"Ending 1",               9},
        {"Ending 2",              10},
        {"Ending 3",              11},
        {"Dream",                 12},
        {"Its Dream End",         13},
        {"Err Dream End",         14},
        {"Freddy Rare",           15},
        {"Bonnie Rare",           16},
        {"Foxy Rare",             17},
        {"8bit Minigame",         18},
        {"Minigame End",          19},
        {"Minigame Load",         20},
        {"You Cant Minigame End", 21},
        {"Take Cake",             22},
        {"Give Gifts",            23},
        {"Foxy Go Go Go",         24},
        {"End of Demo",           25},
    };

    refreshRate = 60;
    settings.Add("fsSplits", true, "Fade Skip Splits");
    settings.Add("f2Splits", true, "F2 Reset Splits");
    settings.Add("remLoads", true, "Remove Loads");
    settings.Add("resetF2", true, "Reset Timer on F2 (Death% only)");

    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {        
        var timingMessage = MessageBox.Show (
            "This autosplitter requires Game Time (IGT) to remove loads.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time?",
            "LiveSplit | Five Nights at Freddy's 2",
            MessageBoxButtons.YesNo, MessageBoxIcon.Question
        );
        
        if (timingMessage == DialogResult.Yes)
            timer.CurrentTimingMethod = TimingMethod.GameTime;
    }
}

init
{
    var mainModule = modules.First();
    while (game.MemoryPages(false).Count() < 30) {}

    string HeaderBytes = "";
    foreach (byte b in Encoding.ASCII.GetBytes("PAMU"))
        HeaderBytes += b.ToString("X2") + " ";

    long Header = 0;
    // scans all of the game's memory pages to search for a successful scan
    foreach (var page in game.MemoryPages(false))
    {
        var scanner = new SignatureScanner(game, page.BaseAddress, (int)(page.RegionSize));

        // initializes a new signature target with the offset (added to the address when found) and the pattern
        var target = new SigScanTarget(0, HeaderBytes.Trim());

        // returns all addresses which matched the target
        var results = scanner.ScanAll(target);
        foreach (var item in results)
        {
            var runtimeVersion = memory.ReadValue<int>(item + 4);
            if (runtimeVersion == 770)
            {
                Header = (long)item;
                break;
            }
        }
    }

    if (Header == 0)
        return;

    HeaderBytes = "";
    foreach (byte b in BitConverter.GetBytes((int)Header))
        HeaderBytes += b.ToString("X2") + " ";
    var HeaderScanner = new SignatureScanner(game, mainModule.BaseAddress, mainModule.ModuleMemorySize);
        
    // initializes a new signature target with the offset (added to the address when found) and the pattern
    var headerTarget = new SigScanTarget(0, HeaderBytes);

    // returns all addresses which matched the target
    var HeaderResults = HeaderScanner.ScanAll(headerTarget);
    foreach (var item in HeaderResults)
    {
        long offset = (long)item - (long)mainModule.BaseAddress;
        string output = memory.ReadString(memory.ReadPointer(item), 4);
        if (output == "PAMU")
        {
            vars.PAMU = (int)item;
            print("Found PAMU!");
            break;
        }
    }

    vars.Watchers = new MemoryWatcherList
    {
        // adds a Watcher to the list; additionally use of vars.Watchers.Add(MemoryWatcher) is possible
        new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.PAMU, 0x1F0))                           { Name = "gameFrame"    },
        new StringWatcher     (new DeepPointer((IntPtr)vars.PAMU + 4, 0x8D0, 0x18, 0x22E, 0x0), 64) { Name = "gameVersion"  },
        new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.PAMU + 4, 0x8D0, 0xF0, 0x20A))          { Name = "gameDemo"     },
        new MemoryWatcher<int>(new DeepPointer((IntPtr)vars.PAMU + 4, 0x8D0, 0x188, 0x20A))         { Name = "gameHour"     }
    };
    
    vars.Watchers.UpdateAll(game);
}

exit
{
    vars.PAMU = 0;
    vars.Resetting = false;
    vars.Death = false;
    vars.Split = false;
    vars.Watchers = null;
}

update
{
    vars.Death = timer.Run.CategoryName == "Death%";
    if (vars.Watchers == null)
        return;
    vars.Watchers.UpdateAll(game);
    return;
    foreach (var watcher in vars.Watchers)
    {
        print(watcher.Name + ": " + watcher.Current);
    }
}   

start
{
    vars.Split = false;
    if (vars.Watchers == null)
            return;

    if (vars.Watchers["gameFrame"].Old     != vars.Frames["Title"] && // Game Frame wasn't Title on the previous frame
        vars.Watchers["gameFrame"].Current == vars.Frames["Title"] && // Game Frame is currently Title
        (vars.Watchers["gameVersion"].Current != ""                && // Game Version has been read
        vars.Watchers["gameVersion"].Current != "v 1.033"          || // Game Version is v 1.033
        vars.Watchers["gameDemo"].Current < -1))                      // Game is a demo
    {
        var timingMessage = MessageBox.Show (
            @"It seems you're using a version of Five Nights at Freddy's 2, not allowed in speedrunning.
            
            Required version: v 1.033
            Current version: " + (vars.Watchers["gameVersion"].Current == "EXT" ? "v 1.0" : vars.Watchers["gameVersion"].Current) + (vars.Watchers["gameDemo"].Current < -1 ? " Demo" : ""),
            "LiveSplit | Five Nights at Freddy's 2",
            MessageBoxButtons.OK, MessageBoxIcon.Warning
        );
    }
    
    if (vars.Death                                                      && // User is running Death%
        vars.Watchers["gameFrame"].Current == vars.Frames["Gameplay"]   || // Game Frame is currently Gameplay%
        
        !vars.Death                                                     && // User is not running Death%
        (vars.Watchers["gameFrame"].Current == vars.Frames["Newspaper"] || // Game Frame is currently Newspaper
        vars.Watchers["gameFrame"].Current == vars.Frames["12AM"]))        // Game Frame is currently 12AM
        return true;
}

split
{
    if (vars.Watchers["gameFrame"].Old     != vars.Frames["Gameplay"]  && // Game Frame wasn't Gameplay on the previous frame
        vars.Watchers["gameFrame"].Current != vars.Frames["6AM"])         // Game Frame is currently not 6AM
        vars.Split = false;

    if (settings["f2Splits"] &&                                   // F2 Splits are enabled
        vars.Watchers["gameFrame"].Current == vars.Frames["6AM"]) // Game Frame is currently 6AM
        vars.Resetting = false;
    else if (settings["f2Splits"] &&                                     // F2 Splits are enabled
             vars.Watchers["gameFrame"].Current == vars.Frames["Title"]) // Game Frame is currently Title
        vars.Resetting = true;

    if (vars.Death                                                     && // User is running Death%
        vars.Watchers["gameFrame"].Old     != vars.Frames["Death"]     && // Game Frame wasn't Death on the previous frame
        vars.Watchers["gameFrame"].Current == vars.Frames["Death"]     || // Game Frame is currently Death

        !vars.Death                                                    && // User is not running Death%
        (!vars.Split                                                   && // 6AM hasn't been split yet
        (vars.Watchers["gameFrame"].Current == vars.Frames["Gameplay"] && // Game Frame is currently Gameplay
        vars.Watchers["gameHour"].Current == -7                        || // Game Hour is currently 6AM
        vars.Watchers["gameFrame"].Old     != vars.Frames["6AM"]       && // Game Frame wasn't 6AM on the previous frame
        vars.Watchers["gameFrame"].Current == vars.Frames["6AM"])      || // Game Frame is currently 6AM

        settings["fsSplits"]                                           && // Fade Skips Splits are enabled
        (vars.Watchers["gameFrame"].Old    != vars.Frames["Gameplay"]  && // Game Frame wasn't Gameplay on the previous frame
        vars.Watchers["gameFrame"].Current == vars.Frames["Gameplay"]  || // Game Frame is currently Gameplay
        vars.Watchers["gameFrame"].Old     != vars.Frames["12AM"]      && // Game Frame wasn't 12AM on the previous frame
        vars.Watchers["gameFrame"].Current == vars.Frames["12AM"]   )) || // Game Frame is currently 12AM
        
        settings["f2Splits"]                                           && // F2 Splits are enabled
        !settings["fsSplits"]                                          && // Fade Skips Splits are disabled
        vars.Resetting                                                 && // User is resetting
        vars.Watchers["gameFrame"].Old     != vars.Frames["Gameplay"]  && // Game Frame wasn't Gameplay on the previous frame
        vars.Watchers["gameFrame"].Current == vars.Frames["Gameplay"])    // Game Frame is currently Gameplay
        {
            vars.Split = true;
            return true;
        }
}

reset
{
    return (settings["resetF2"]                                          && // Reset on F2 is enabled
            vars.Death                                                   && // User is running Death%
            vars.Watchers["gameFrame"].Old     != vars.Frames["Warning"] && // Game Frame wasn't Warning on the previous frame
            vars.Watchers["gameFrame"].Current == vars.Frames["Warning"] || // Game Frame is currently Warning

            !vars.Death                                                  && // User is not running Death%
            vars.Watchers["gameFrame"].Old     != vars.Frames["Death"]   && // Game Frame wasn't Death on the previous frame
            vars.Watchers["gameFrame"].Current == vars.Frames["Death"]);    // Game Frame is currently Death
}

isLoading
{
    return (settings["remLoads"]                                           && // Remove Loads is enabled
            (vars.Watchers["gameFrame"].Current == vars.Frames["Unloaded"] || // Game Frame is currently Unloaded
            vars.Watchers["gameFrame"].Current  == vars.Frames["Loading"]));  // Game Frame is currently Loading
}
