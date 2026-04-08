{ config, pkgs, username, hostName, lib', ... }:

{
  # ────────────────────────────────────────────────────────
  # Networking & Hostname
  # ────────────────────────────────────────────────────────
  networking.hostName = "nixlensk323";

  # ────────────────────────────────────────────────────────
  # Network Bridge (for VMs)
  # ────────────────────────────────────────────────────────

  networking.networkmanager.enable = true;

  boot = {
    kernelModules = [ "bridge" "uinput" "v4l2loopback" ];
    kernelParams = [
      "net.ipv4.ip_forward=1"
      "resume_offset=4988160"
    ];
    resumeDevice = "/dev/disk/by-uuid/6703b7a2-d8ba-4f63-8fc0-5d770b59df7f";
  };

  networking.nameservers = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" ];
  networking.firewall.checkReversePath = "loose";
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
  # User (gaming PC: qemu + SSH keys)
  # ────────────────────────────────────────────────────────
  users.users.${username} = {
    extraGroups = [ "qemu" ];
    openssh.authorizedKeys.keys = lib'.sshKeys;
  };

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
    zip
    unzip
    unrar
    xrandr
    opencode
    nix-search
  ];
}
