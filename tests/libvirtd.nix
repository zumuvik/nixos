{ pkgs ? import <nixpkgs> {} }:

pkgs.testers.nixosTest {
  name = "libvirtd-test";
  nodes.machine = {
    imports = [ ../modules/nixos/hardware/virt.nix ];
    my.hardware.virtualization.enable = true;
    virtualisation.libvirtd.enable = true;
  };

  testScript = ''
    machine.wait_for_unit("libvirtd.service")
    machine.succeed("systemctl is-active libvirtd.service")
  '';
}
