state("FiveNightsatFreddys3")
{
    int area : "FiveNightsatFreddys3.exe", 0xB39CC, 0x1F0;
    byte minigame1win : "FiveNightsAtFreddys3.exe", 0xB39CC, 0x1D8, 0x8D0, 0x130, 0xC, 0x20a;
    byte minigame2win : "FiveNightsAtFreddys3.exe", 0xB39CC, 0x1D8, 0x8D0, 0x1c8, 0xC, 0x20a;
    byte minigame3win : "FiveNightsAtFreddys3.exe", 0xB39CC, 0x1D8, 0x8D0, 0x110, 0xC, 0x20a;
    byte minigame4and5win : "FiveNightsAtFreddys3.exe", 0xB39CC, 0x1D8, 0x8D0, 0xe8, 0xC, 0x20a;
    byte endcutscene : "FiveNightsAtFreddys3.exe", 0xB39CC, 0x1D8, 0x8D0, 0x0, 0xC, 0x20a;
}
startup
{
    settings.Add("noloads", true, "Remove Loads");
}
start
{
    if (current.area <= 23 && current.area >= 19)
        return true;
}
split
{
    if (current.area == 19 && old.minigame1win != 254 && current.minigame1win == 254 ||
    current.area == 20 && old.minigame2win != 254 && current.minigame2win == 254 ||
    current.area == 21 && old.minigame3win != 254 && current.minigame3win == 254 ||
    current.area == 22 && old.minigame4and5win != 254 && current.minigame4and5win == 254 ||
    current.area == 23 && old.minigame4and5win != 254 && current.minigame4and5win == 254)
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
