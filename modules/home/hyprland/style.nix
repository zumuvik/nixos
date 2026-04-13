{...}: {
  wayland.windowManager.hyprland.settings = {
   general = {
       gaps_in = 5;
       gaps_out = 20;
       border_size = 2;
       "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
       "col.inactive_border" = "rgba(595959aa)";
       layout = "dwindle";
       resize_on_border = false;
   };

   decoration = {
       rounding = 12;
       active_opacity = 0.85;
       inactive_opacity = 0.75;
       fullscreen_opacity = 1.0;

       shadow = {
           enabled = true;
           range = 15;
           render_power = 3;
           color = "rgba(1a1a1aee)";
       };

       blur = {
           enabled = true;
           size = 1;
           passes = 1;
           vibrancy = 0.5;
           vibrancy_darkness = 0.5;
           ignore_opacity = true;
           new_optimizations = true;
           noise = 0.02;
           contrast = 1.0;
           brightness = 1.0;
       };
   };

   animations = {
       enabled = true;
       bezier = [
        "easeOutQuint, 0.23, 1, 0.32, 1"
        "quick, 0.15, 0, 0.1, 1"
       ];
       animation = [
        "windows, 1, 4.79, easeOutQuint"
        "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
        "windowsOut, 1, 1.49, quick, popin 87%"
        "fadeIn, 1, 1.73, default"
        "fadeOut, 1, 1.46, default"
        "workspaces, 1, 1.94, default, slide"
       ];
   };
 };
}
