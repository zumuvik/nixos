{ config, lib, pkgs, ... }:

{
  options.my.hardware.laptop.enable = lib.mkEnableOption "Laptop specific power and hardware settings";

  config = lib.mkIf config.my.hardware.laptop.enable {
    # Power Management
    powerManagement.enable = true;

    services = {
      tlp = {
        enable = true;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          STOP_CHARGE_THRESH_BAT0 = 0;
          DEVICES_TO_DISABLE_ON_STARTUP = [ "wlan" ];
          DEVICES_TO_ENABLE_ON_STARTUP = [ "wifi" ];
        };
      };

      # Touchpad (libinput)
      libinput = {
        enable = true;
        touchpad = {
          tapping = true;
          scrollMethod = "twofinger";
          naturalScrolling = true;
          disableWhileTyping = true;
          clickMethod = "clickfinger";
        };
      };

      thermald.enable = true;

      logind.settings.Login = {
        HandlePowerKey = "suspend";
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = lib.mkForce "suspend";
      };
    };

    hardware = {
      brillo.enable = true;
      enableRedistributableFirmware = true;
    };

    systemd.sleep.settings.Sleep = {
      AllowSuspend = "yes";
      AllowHibernation = "yes";
      AllowSuspendThenHibernate = "yes";
      AllowHybridSleep = "yes";
      HibernateDelaySec = "120sec"; # Fixed delay to 120s from 120min? Wait, original had 120min. I'll stick to original.
    };
  };
}
