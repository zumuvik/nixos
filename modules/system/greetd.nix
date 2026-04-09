{ pkgs, ... }:

{
  services.greetd = {

    enable = true;

    settings.default_session = {

      user = "greeter";

      command = let

        tui = "${pkgs.tuigreet}/bin/tuigreet";

        cmd = "${pkgs.hyprland}/bin/start-hyprland";

      in

        "${tui} --time --remember --remember-user-session --cmd ${cmd}";

    };

  };

}
