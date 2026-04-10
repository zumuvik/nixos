{ pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings.default_session = {
      user = "greeter"; # или твой юзер, если хочешь автологин
      command = let
        tui = "${pkgs.tuigreet}/bin/tuigreet";
        cmd = "${pkgs.hyprland}/bin/Hyprland";
      in
        "${tui} --time --remember --remember-user-session --cmd ${cmd}";
    };
  };
}
