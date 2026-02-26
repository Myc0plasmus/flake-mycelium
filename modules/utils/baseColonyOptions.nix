{ lib}:
let
  inherit (lib)
    mkOption
    types
    ;
in
{ config, name, ... }:
{
  options = {
    system = mkOption {
      type = types.str;
    };
    modules = mkOption {
      type = with types; listOf anything;
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
  };
  config = {
    specialArgs = {
      inherit (config) protoHost;
    };
  };
}
