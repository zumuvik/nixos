{
  username = "zumuvik";

  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEP3GKg44+5QOaTUj7kHMO9x4sMhShdVuK4NR1yMtleQ zumuvik@nixlensk323"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9RWNYncLPCFQm4vcL0Ln3f8CG14g/JtUc42fPBjyJN laptop"
  ];

  extraKeys = {
    mascot_valera = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMm4siX5+Ff1G1hYaV7A/sYCgfa1vlA8zXoVeifiqa/C glebs@DESKTOP-O9OOLUI"
    ];
  };
}
