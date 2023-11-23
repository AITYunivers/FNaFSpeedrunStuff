state("FNaF_World")
{
  int dialog    : "FNaF_World.exe", 0xAC9AC, 0x1D8, 0x8D0, 0x28, 0xC, 0x20A;
  int dialog4th : "FNaF_World.exe", 0xAC9AC, 0x1D8, 0x8D0, 0x48, 0xC, 0x20A;
  int frame     : "FNaF_World.exe", 0xAC9AC, 0x1F0;
  int framecnt  : "FNaF_World.exe", 0xAC9AC, 0xC4;
}

startup
{
  refreshRate = 60;
  settings.Add("Normal",   false, "Normal Mode Ending");
  settings.Add("Hard",     false, "Hard Mode Ending");
  settings.Add("4th",      false, "4th Glitch Ending");
  settings.Add("Chip",     false, "Chipper Ending");
  settings.Add("Clock",    false, "Clock Ending");
  settings.Add("Universe", false, "Universe Ending");
  settings.Add("Rainbow",  false, "Rainbow Ending");
  settings.Add("Mini",     false, "Slipt At New Character Screen After Minigames");

  if (timer.CurrentTimingMethod == TimingMethod.RealTime)
  {        
    var timingMessage = MessageBox.Show (
      "This autosplitter requires Game Time (IGT) to remove loads.\n"+
      "LiveSplit is currently set to show Real Time (RTA).\n"+
      "Would you like to set the timing method to Game Time?",
      "LiveSplit | FNaF World",
      MessageBoxButtons.YesNo,MessageBoxIcon.Question
    );
    
    if (timingMessage == DialogResult.Yes)
      timer.CurrentTimingMethod = TimingMethod.GameTime;
  }
}

start 
{  
  vars.offset = current.framecnt == 31 ? 1 : 0;
  return current.frame == 27 - vars.offset && old.frame != 27 - vars.offset;
}

split {
  if (current.frame == 31)
    return false;

  if (settings["Normal"]   && old.dialog == -7 && current.dialog == -8 ||
      settings["Hard"]     && current.dialog == -7 && old.dialog == -8 ||
      settings["4th"]      && old.dialog4th == -3 && current.dialog4th == -4 ||
      settings["Clock"]    && current.frame == 29 - vars.offset && old.frame != 29 - vars.offset ||
      settings["Chip"]     && current.dialog == -7 && old.dialog == -8 ||
      settings["Universe"] && current.frame == 30 - vars.offset && old.frame != 30 - vars.offset ||
      settings["Rainbow"]  && current.frame == 45 && old.frame != 45 ||
      settings["Mini"]     && current.frame == 43 && old.frame != 43)
    return true;
}

reset
{
  // Found this to be stupid, you can re-enable it if ya want though.
  //return current.frame == 6 - vars.offset;
}

isLoading
{
  return current.frame == -1 || current.frame == 9 - vars.offset;
}