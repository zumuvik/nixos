{ config, pkgs, ... }:

{
  # Кэширование NSS (nscd)
  services.nscd.enable = true;

  # Audio (PipeWire)
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # VPN - WireGuard
  networking.wireguard.enable = true;

  # Throne (VLESS client) - on all hosts
  programs.throne = {
    enable = true;
    tunMode = {
      enable = true;
      setuid = true;
    };
  };

  # D-Bus
  services.dbus.enable = true;

  # XDG Desktop Portal (для Wayland)
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };
}
