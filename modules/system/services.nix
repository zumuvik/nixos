{ pkgs, ... }:

{
  # Кэширование NSS (nscd), Audio (PipeWire), SSH
  services = {
    nscd.enable = true;

    # Audio (PipeWire)
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };

    # SSH
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
      };
    };

    # D-Bus
    dbus.enable = true;
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
