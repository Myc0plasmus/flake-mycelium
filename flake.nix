{
  description = "Flake basics described using the module system";

  inputs = {
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    import-tree = {
      url = "github:vic/import-tree";
    };
  };

  outputs = {
    nixpkgs-lib,
    import-tree,
    ... 
  }@inputs:
  let
    lib = import ./lib.nix {
      inherit (nixpkgs-lib) lib;
    };

  in
  lib.mkMycelium

}
