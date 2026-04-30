{ lib, ... }:

{
  networking.networkmanager.enable = false;
  networking.useDHCP = false;

  networking.interfaces.ens18 = {
    ipv4.addresses = [ {
      address = "0.0.0.0"; # ЗАМЕНИТЬ НА РЕАЛЬНЫЙ IP
      prefixLength = 24;
    } ];
    ipv6.addresses = [ {
      address = "::1"; # ЗАМЕНИТЬ НА РЕАЛЬНЫЙ IPV6
      prefixLength = 64;
    } ];
  };

  networking.defaultGateway = "0.0.0.0"; # ЗАМЕНИТЬ НА РЕАЛЬНЫЙ ШЛЮЗ
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "ens18";
  };
}
