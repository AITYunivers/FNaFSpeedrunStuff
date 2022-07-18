state("FiveNightsatFreddys2")
{
    int area : "FiveNightsatFreddys2.exe", 0xB39CC, 0x1F0;
}
startup
{
    settings.Add("fade", true, "Fade Skip Splits");
    settings.Add("resets", true, "F2 Reset Splits");
    settings.Add("noloads", true, "Remove Loads");
    settings.Add("f2", false, "Reset Timer on F2");
    settings.Add("death", false, "Death%");
}
start
{
    if (settings["death"] && current.area == 3 ||
    !settings["death"] && current.area == 8 ||
    !settings["death"] && current.area == 2)
        return true;
}
update
{
    if (settings["resets"] && current.area == 5)
        vars.resetting = 0;
    else if (settings["resets"] && current.area == 1)
        vars.resetting = 1;
}
split
{
    if (settings["death"] && old.area == -1 && current.area == 4 ||
    !settings["death"] && old.area == -1 && current.area == 5 ||
    !settings["death"] && settings["fade"] && old.area != 3 && current.area == 3 ||
    !settings["death"] && settings["fade"] && old.area != 2 && current.area == 2 ||
    !settings["death"] && settings["resets"] && !settings["fade"] && old.area != 2 && vars.resetting == 1 && current.area == 2)
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