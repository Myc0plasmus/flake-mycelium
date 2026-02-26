{
  lib,
  inputs,
  ...
}:

{
  baseColonyModule = import ./baseColonyOptions.nix { inherit lib; inherit inputs;};
}
