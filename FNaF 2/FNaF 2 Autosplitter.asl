state("FiveNightsatFreddys2") {
  int area : "FiveNightsatFreddys2.exe", 0xB39CC, 0x1F0;
}
start {
  if(current.area == 2 || current.area == 8) {
    return true;
  }
}
split {
  if(old.area == -1 && current.area == 2 || old.area == 1 && current.area == 2 || old.area == -1 && current.area == 3 || old.area == -1 && current.area == 5|| old.area == 3 && current.area == 5) {
    return true;
  }
}
reset {
  if(current.area == 4) {
    return true;
  }
}
isLoading {
  if(current.area == 7 || current.area == -1) {
    return true;
  }
  else {
    return false;
  }
}
