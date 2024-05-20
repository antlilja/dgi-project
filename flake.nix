{
  description = "Zig compiler development.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    zig-overlay.url = "github:mitchellh/zig-overlay";
    zig-overlay.inputs.nixpkgs.follows = "nixpkgs";

    zls.url = "github:zigtools/zls";
    # zls.inputs.zig-overlay.follows = "zig-overlay";
    zls.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    zig-overlay,
    zls,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        zigpkg = zig-overlay.packages.${system}.master;
        zlspkg = zls.packages.${system}.zls;
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
              zigpkg
              zlspkg
              shaderc
              glfw
              vulkan-loader
              vulkan-validation-layers
              xorg.libxcb
              xcb-util-cursor
          ];

          hardeningDisable = ["all"];
          LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [pkgs.vulkan-loader]}";
          VK_LAYER_PATH="${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";
        };

        devShell = self.devShells.${system}.default;
      }
    );
}
