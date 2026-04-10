_:

{
  # Graphics (AMD/Intel)
  hardware.graphics.enable = true;

  # AMD GPU
  services.xserver.videoDrivers = [ "amdgpu" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelParams = [ "amdgpu.dc=1" ];

  # ROCm support (AMD GPU compute)
  # Required for llama.cpp, PyTorch, etc. on AMD GPUs (Vega, RDNA series)
  # Note: /dev/kfd created automatically by amdgpu driver

  # Virtualization
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Real-Time Audio
  security.rtkit.enable = true;
}
