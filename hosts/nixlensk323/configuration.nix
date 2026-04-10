{ config, pkgs, username, lib', ... }:

{
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
  boot = {
    kernelModules = [ "bridge" "uinput" "v4l2loopback" ];
    kernelParams = [
      "net.ipv4.ip_forward=1"
      "resume_offset=4988160"
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

  # ────────────────────────────────────────────────────────
  # Tablet Driver & Input Devices
  # ────────────────────────────────────────────────────────
  hardware.opentabletdriver.enable = true;
  hardware.opentabletdriver.daemon.enable = true;
  hardware.uinput.enable = true;

  # ────────────────────────────────────────────────────────
  # llama.cpp REST API Server (DeepSeek-Coder-V2-Lite)
  # ────────────────────────────────────────────────────────
  services.llama-server = {
    enable = true;
    package = pkgs.llama-cpp-rocm;
    modelPath = "/var/lib/llama-models/DeepSeek-Coder-V2-Lite-Instruct.IQ2_XS.gguf";
    port = 8080;
    gpuLayers = 32;
    contextSize = 4096;
    threads = 8;
  };

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

    # ROCm tools & LLM inference
    rocmPackages.rocm-core
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
    llama-cpp-rocm
  ];
}
