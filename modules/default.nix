{lib, inputs, config, ...}:

{
  imports = [
    ./nixosColonies.nix
    ./moduleSpores.nix
    ./nixosConfigurations.nix
  ];
}
