{
  description = "Flake basics described using the module system";

  inputs = {
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
  };

  outputs = {
    nixpkgs-lib,
    ... 
  }@inputs:
  {
    lib = import ./lib.nix {
      inherit (nixpkgs-lib) lib;
    };
  };

}

