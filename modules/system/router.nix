{ config, pkgs, ... }:

{
  # ────────────────────────────────────────────────────────
  # Kernel modules for routing/NAT
  # ────────────────────────────────────────────────────────
  boot.kernelModules = [ 
    "iptable_nat" 
    "iptable_filter" 
    "ip_tables" 
    "nf_nat" 
    "nf_conntrack" 
    "nf_defrag_ipv4" 
    "tun" 
  ];
  
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  
  boot.extraModprobeConfig = ''
    alias char-major-10-200 tun
  '';

  # ────────────────────────────────────────────────────────
  # Bridge br0 + NAT
  # ────────────────────────────────────────────────────────
  networking.bridges = {
    br0.interfaces = [ "enp8s0" ];
  };

  networking.interfaces = {
    enp8s0.ipv4.addresses = [ ];
    br0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.3.1";
        prefixLength = 24;
      }];
    };
  };

  # NAT configuration
  networking.nat = {
    enable = true;
    externalInterface = "enp6s0";
    internalInterfaces = [ "br0" ];
  };

  # ────────────────────────────────────────────────────────
  # dnsmasq — DHCP + DNS для LAN
  # ────────────────────────────────────────────────────────
  services.dnsmasq = {
    enable = true;

    settings = {
      interface = "br0";
      except-interface = "enp6s0 lo";

      listen-address = "192.168.3.1";

      bind-interfaces = true;
      dhcp-authoritative = true;

      dhcp-range = "192.168.3.100,192.168.3.200,12h";

      dhcp-option = [
        "3,192.168.3.1"
        "6,1.1.1.1,8.8.8.8"
      ];

      domain = "local";
      expand-hosts = true;

      server = [ "1.1.1.1" "8.8.8.8" ];
      no-resolv = false;

      log-dhcp = true;
      log-queries = true;
    };
  };

  # ────────────────────────────────────────────────────────
  # Firewall
  # ────────────────────────────────────────────────────────
  networking.firewall = {
    enable = true;

    trustedInterfaces = [ "br0" "tun0" "docker0" ];

    allowedTCPPorts = [
      22      # ssh
      25      # smtp
      80 443  # http/https
      2017 8000 8123 8443
      25565   # minecraft
    ];

    allowedUDPPorts = [
      67 68           # DHCP
      51820           # wireguard
      24454           # ?
    ];

    extraInputRules = ''
      iifname "br0" udp dport { 67, 68 } accept comment "DHCP server incoming"
      iifname "br0" udp sport { 67, 68 } accept comment "DHCP client replies"
    '';

    extraForwardRules = ''
      iifname "br0" oifname "enp6s0" accept comment "LAN -> WAN"
      iifname "enp6s0" oifname "br0" ct state { established, related } accept comment "WAN -> LAN return"
    '';
  };

  # ────────────────────────────────────────────────────────
  # Docker
  # ────────────────────────────────────────────────────────
  virtualisation.docker.enable = true;
}
