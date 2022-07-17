state("FiveNightsatFreddys") {
  int area : "FiveNightsatFreddys.exe", 0xAC9AC, 0x1F0;
}
start {
  if(current.area == 10 || current.area == 2) {
    return true;
  }
}
split {
  if(old.area == -1 && current.area == 6 || old.area == -1 && current.area == 3 || old.area == -1 && current.area == 2 || old.area == 6 && current.area == 2) {
    return true;
  }
}
reset {
  if(current.area == 4 || current.area == 0) {
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
