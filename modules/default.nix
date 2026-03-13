{lib, inputs, config, ...}:

{
  imports = [
    ./nixosColonies.nix
    ./nixosConfigurations.nix
  ];
}
