{
  lib,
  inputs,
  ...
}:

let
  inherit (lib)
    mkOption
    mkDefault
    types
    ;
in
{ config, ... }:
{
  options = {
    system = mkOption {
      type = types.str;
    };
    modules = mkOption {
      type = with types; listOf deferredModule;
      default = [ ];
    };
    specialArgs = mkOption {
      type = with types; attrsOf anything;
      default = { };
    };
    protoHost = mkOption {
      type = with types; attrsOf anything;
      default = { };
    };
    # pkgs = mkOption {
    #   type = types.pkgs;
    # };
  };
  # config = {
  #   pkgs = mkDefault inputs.nixpkgs.legacyPackages.${config.system};
  # };
}
