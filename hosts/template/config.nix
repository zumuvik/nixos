{
  # Hostname for this machine
  hostName = "CHANGE_ME";

  # Timezone
  timeZone = "Europe/Moscow";

  # Boot settings (from hardware-configuration.nix)
  boot = {
    resumeDevice = "/dev/disk/by-uuid/CHANGE_ME";
    resumeOffset = 0;
  };
}
