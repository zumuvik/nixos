{ ... }: {
  imports = [
    ./bluetooth.nix
    ./amdgpu.nix
    ./virt.nix
    ./zram.nix
    ./swap.nix
    ./laptop.nix
    ./kernel.nix
    ./v4l2loopback.nix
  ];
}
