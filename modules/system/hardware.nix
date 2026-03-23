{ config, pkgs, ... }: {
  # ────────────────────────────────────────────────────────
  # Graphics (AMD/Intel)
  # ────────────────────────────────────────────────────────
  hardware.graphics = {
    enable = true;
  };

  # ────────────────────────────────────────────────────────
  # Bluetooth Hardware
  # ────────────────────────────────────────────────────────
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # ────────────────────────────────────────────────────────
  # Tablet Driver (OpenTabletDriver)
  # ────────────────────────────────────────────────────────
  hardware.opentabletdriver.enable = true;

  # ────────────────────────────────────────────────────────
  # Input Devices (для аналоговых джойстиков, etc)
  # ────────────────────────────────────────────────────────
  hardware.uinput.enable = true;
  boot.kernelModules = [ "uinput" ];

  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # ────────────────────────────────────────────────────────
  # Real-Time Audio
  # ────────────────────────────────────────────────────────
  security.rtkit.enable = true;
}
