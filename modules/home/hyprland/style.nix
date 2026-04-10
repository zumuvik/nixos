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
       rounding = 10;
       active_opacity = 1.0;
       inactive_opacity = 0.95;

       shadow = {
           enabled = true;
           range = 8;
           render_power = 4;
           color = "rgba(1a1a1aee)";
       };

       blur = {
           enabled = true;
           size = 1;
           passes = 2;
           vibrancy = 0.2;
           vibrancy_darkness = 0.1;
           ignore_opacity = false;
           new_optimizations = true;
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
