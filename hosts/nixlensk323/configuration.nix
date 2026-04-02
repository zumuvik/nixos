{ config, pkgs, username, ... }:

{
  # ────────────────────────────────────────────────────────
  # Networking & Hostname
  # ────────────────────────────────────────────────────────
  networking.hostName = "nixlensk323";
  time.timeZone = "Europe/Moscow";

  boot = {
    resumeDevice = "/dev/disk/by-uuid/6703b7a2-d8ba-4f63-8fc0-5d770b59df7f";
    kernelParams = [
      "resume_offset=4988160"
    ];
  };

  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

  networking.networkmanager.enable = true;
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" ];
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  # ────────────────────────────────────────────────────────
  # Remote Builder
  # ────────────────────────────────────────────────────────
  nix.buildMachines = [
    {
      hostName = "nixlensk323";
      system = "x86_64-linux";
      maxJobs = 4;
      supportedFeatures = [ "big-parallel" "kvm" ];
    }
  ];

  # ────────────────────────────────────────────────────────
  # User
  # ────────────────────────────────────────────────────────
  programs.zsh.enable = true;
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" "kvm" "qemu" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEP3GKg44+5QOaTUj7kHMO9x4sMhShdVuK4NR1yMtleQ zumuvik@nixlensk323"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9RWNYncLPCFQm4vcL0Ln3f8CG14g/JtUc42fPBjyJN laptop"
    ];
  };

  # ────────────────────────────────────────────────────────
  # sudo без пароля на nixos-rebuild switch
  # ────────────────────────────────────────────────────────
  security.sudo.extraRules = [
    {
      users = [ "${username}" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild switch";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # ────────────────────────────────────────────────────────
  # Steam + Gaming
  # ────────────────────────────────────────────────────────
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
    extraPackages = with pkgs; [
      mangohud
      gamemode
    ];
  };

  # ────────────────────────────────────────────────────────
  # Tablet Driver & Input Devices
  # ────────────────────────────────────────────────────────
  hardware.opentabletdriver.enable = true;
  hardware.opentabletdriver.daemon.enable = true;
  hardware.uinput.enable = true;
  boot.kernelModules = [ "uinput" "v4l2loopback" ];

  # ────────────────────────────────────────────────────────
  # OBS Virtual Camera
  # ────────────────────────────────────────────────────────
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1
  '';

  # ────────────────────────────────────────────────────────
  # System packages (host-specific)
  # ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    v4l-utils
    osu-lazer-bin
    git
    wget
    gh
    wireguard-tools
    zip
    unzip
    unrar
    xrandr
    brightnessctl
    grim
    slurp
    wl-clipboard
    mako
    swww
    btop
    opencode
    fastfetch
    networkmanagerapplet
    pavucontrol
    nix-search
  ];
}
