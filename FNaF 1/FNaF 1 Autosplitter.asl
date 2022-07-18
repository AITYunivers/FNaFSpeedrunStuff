state("FiveNightsAtFreddys")
{
    int area : "FiveNightsAtFreddys.exe", 0xAC9AC, 0x1F0;
}

startup
{
    settings.Add("fade", true, "Fade Skip Splits");
    settings.Add("f2", true, "Reset Timer on F2");
    settings.Add("noloads", true, "Remove Loads");
    settings.Add("death", false, "Death%");
}

start
{
    if (settings["death"] && current.area == 3 ||
    !settings["death"] && current.area == 10 ||
    !settings["death"] && current.area == 2)
        return true;
}
split
{
    if (settings["death"] && old.area != 4 && current.area == 4 ||
    settings["death"] && old.area != 13 && current.area == 13 ||
    !settings["death"] && old.area != 6 && current.area == 6 ||
    !settings["death"] && settings["fade"] && old.area != 3 && current.area == 3 ||
    !settings["death"] && settings["fade"] && old.area != 2 && current.area == 2)
        return true;
}
reset
{
    if (settings["f2"] && current.area == 0 ||
    !settings["death"] && current.area == 4)
        return true;
}
isLoading
{
    if (settings["noloads"] && current.area == -1 ||
    settings["noloads"] && current.area == 7)
        return true;
    else
        return false;
}