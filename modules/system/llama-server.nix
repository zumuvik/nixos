{ config, pkgs, lib, ... }:

{
  # ────────────────────────────────────────────────────────
  # llama-cpp-rocm REST API Server (systemd service)
  # ────────────────────────────────────────────────────────

  options.services.llama-server = with lib; {
    enable = mkEnableOption "llama.cpp REST API server";

    package = mkOption {
      type = types.package;
      default = pkgs.llama-cpp-rocm;
      description = "llama.cpp package with GPU support";
    };

    modelPath = mkOption {
      type = types.str;
      default = "/var/lib/llama-models/DeepSeek-Coder-V2-Lite-Instruct.IQ2_XS.gguf";
      description = "Path to GGUF model file";
    };

    port = mkOption {
      type = types.int;
      default = 8080;
      description = "HTTP server port";
    };

    gpuLayers = mkOption {
      type = types.int;
      default = 32;
      description = "Number of layers to offload to GPU";
    };

    contextSize = mkOption {
      type = types.int;
      default = 4096;
      description = "Context window size (tokens)";
    };

    threads = mkOption {
      type = types.int;
      default = 8;
      description = "CPU threads for inference";
    };
  };

  config = lib.mkIf config.services.llama-server.enable {
    # Ensure model directory exists
    systemd.tmpfiles.rules = [
      "d /var/lib/llama-models 0755 - - -"
    ];

    # Systemd service
    systemd.services.llama-server = {
      description = "llama.cpp REST API Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      path = [ config.services.llama-server.package pkgs.rocmPackages.rocm-core ];

      environment = {
        HIP_VISIBLE_DEVICES = "0";
        LD_LIBRARY_PATH = "${pkgs.rocmPackages.rocm-core}/lib";
        # Vega 56 (gfx900) - override GFX version check
        HSA_OVERRIDE_GFX_VERSION = "9.0.0";
        # Limit VRAM usage to leave buffer for display
        GGML_VULKAN_DEVICE_OVERRIDE = "0";
      };

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 5;
        TimeoutStartSec = 300;

        ExecStart = ''
          ${config.services.llama-server.package}/bin/llama-server \
            --model ${config.services.llama-server.modelPath} \
            --host 127.0.0.1 \
            --port ${toString config.services.llama-server.port} \
            --ctx-size ${toString config.services.llama-server.contextSize} \
            --gpu-layers ${toString config.services.llama-server.gpuLayers} \
            --threads ${toString config.services.llama-server.threads} \
            --n-predict 512 \
            --batch-size 256
        '';

        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "llama-server";
      };
    };
  };
}
