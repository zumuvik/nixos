{ config, lib, pkgs, ... }:

{
  # ────────────────────────────────────────────────────────
  # Power Management (laptop)
  # ────────────────────────────────────────────────────────
  powerManagement.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      # Оптимизация для батареи
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      # Отключение ненужных устройств
      STOP_CHARGE_THRESH_BAT0 = 0;  # Не останавливать зарядку
      DEVICES_TO_DISABLE_ON_STARTUP = [ "bluetooth" "wlan" ];
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
  # Audio (PipeWire)
  # ────────────────────────────────────────────────────────
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  # Disable PulseAudio if it's enabled
  services.pulseaudio.enable = false;
  
  # ────────────────────────────────────────────────────────
  # VGA / GPU (AMD) - уже включено в hardware.nix, но на случай если hardware.nix не импортирован
  # ────────────────────────────────────────────────────────
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelParams = [ "amdgpu.dc=1" "rtw88_pci.disable_aspm=1" ];

  # ────────────────────────────────────────────────────────
  # Power Button / Lid
  # ────────────────────────────────────────────────────────
  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = lib.mkForce "suspend";
  };
}