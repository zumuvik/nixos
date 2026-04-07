{ config, lib, pkgs, ... }:

{
  # ────────────────────────────────────────────────────────
  # Power Management (laptop)
  # ────────────────────────────────────────────────────────
  powerManagement.enable = true;
  services.tlp = {
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

  # ────────────────────────────────────────────────────────
  # Suspend / Hibernate
  # ────────────────────────────────────────────────────────
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "yes";
    AllowHibernation = "yes";
    AllowSuspendThenHibernate = "yes";
    AllowHybridSleep = "yes";
    HibernateDelaySec = "120min";
  };

  # ────────────────────────────────────────────────────────
  # Touchpad (libinput)
  # ────────────────────────────────────────────────────────
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      scrollMethod = "twofinger";
      naturalScrolling = true;
      disableWhileTyping = true;
      clickMethod = "clickfinger";
    };
  };

  # ────────────────────────────────────────────────────────
  # Brightness Control
  # ────────────────────────────────────────────────────────
  hardware.brillo.enable = true;

  # ────────────────────────────────────────────────────────
  # Firmware (required for WiFi, Bluetooth, etc.)
  # ────────────────────────────────────────────────────────
  hardware.enableRedistributableFirmware = true;

  # ────────────────────────────────────────────────────────
  # Thermal Management
  # ────────────────────────────────────────────────────────
  services.thermald.enable = true;

  # ────────────────────────────────────────────────────────
  # Power Button / Lid
  # ────────────────────────────────────────────────────────
  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = lib.mkForce "suspend";
  };
}