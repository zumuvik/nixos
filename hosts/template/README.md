# NixOS Host Template

Use this as a template for new hosts.

## To add a new host:

1. Copy this directory:
   ```bash
   cp -r hosts/template hosts/new-host
   ```

2. Edit `hosts/new-host/config.nix`:
   - Set `hostName`
   - Run `nixos-generate-config --dir hosts/new-host` to generate hardware.nix
   - Copy UUIDs from hardware.nix to config.nix

3. Add to `flake.nix`:
   ```nix
   new-host = makeNixosHost {
     hostName = "new-host";
     enableSteam = false;
     enableBluetooth = false;
     enableRouter = false;
   };
   ```

4. Build:
   ```bash
   sudo nixos-rebuild switch --flake .#new-host
   ```
