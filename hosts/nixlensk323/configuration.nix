{ config, pkgs, username, lib', ... }:

{
  my.profiles.desktop.enable = true;
  my.hardware.bluetooth.enable = true;
  my.hardware.amdgpu.enable = true;
  my.hardware.virtualization.enable = true;
  my.hardware.zram.enable = true;
  my.hardware.swap.enable = true;
  my.hardware.kernel-zen.enable = false;
  my.hardware.kernel-cachy.enable = false;
  my.hardware.kernel-cachy-bore.enable = true;
  my.gaming.enable = true;
  my.ui.plymouth.enable = true;
  programs.gamemode.enable = true; 
  # ────────────────────────────────────────────────────────
  # Sops-nix (управление секретами)
  # ────────────────────────────────────────────────────────
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.secrets."git_sync_env" = {};

  # ────────────────────────────────────────────────────────
  # Networking & Hostname
  # ────────────────────────────────────────────────────────
  networking = {
    hostName = "nixlensk323";

    # ────────────────────────────────────────────────────────
    # Network Bridge (for VMs)
    # ────────────────────────────────────────────────────────

    networkmanager.enable = true;

    nameservers = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" ];
    firewall.checkReversePath = "loose";
  };

    # ────────────────────────────────────────────────────────
    # Boot
    # ────────────────────────────────────────────────────────
    system.stateVersion = "25.11";
    boot = {
     consoleLogLevel = 0;
     initrd.verbose = false;
     kernelModules = [ "bridge" "uinput" "v4l2loopback" "hid-playstation" ];
     kernelParams = [
       "net.ipv4.ip_forward=1"
       "resume_offset=4988160"
       "quiet"
       "splash"
       "loglevel=3"
       "systemd.show_status=auto"
       "rd.udev.log_level=3"
       "udev.log_priority=3"
     ];
     resumeDevice = "/dev/disk/by-uuid/6703b7a2-d8ba-4f63-8fc0-5d770b59df7f";
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1
    '';
  };

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
  # User (gaming PC: qemu + SSH keys + ROCm GPU access)
  # ────────────────────────────────────────────────────────
  users.users.${username} = {
    extraGroups = [ "qemu" "render" "video" ];
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
   
   # Gamepad/Joystick support
   services.udev.packages = with pkgs; [ game-devices-udev-rules ];

  # ────────────────────────────────────────────────────────
  # Tablet Driver & Input Devices
  # ────────────────────────────────────────────────────────
  hardware.opentabletdriver.enable = true;
  hardware.opentabletdriver.daemon.enable = true;
  hardware.uinput.enable = true;

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
     nix-search
     ayugram-desktop
     gemini-cli
   ];
}
