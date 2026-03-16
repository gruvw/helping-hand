{
  description = "ESP32-C6 Rust IDF dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";
  };

  outputs = { self, nixpkgs, rust-overlay, nixpkgs-esp-dev }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs-esp-dev.inputs.nixpkgs {
      inherit system;
      # This allows the specific insecure package required by ESP-IDF
      config = {
        permittedInsecurePackages = [
          "python3.13-ecdsa-0.19.1"
        ];
      };
      overlays = [
        rust-overlay.overlays.default
        nixpkgs-esp-dev.overlays.default
      ];
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        (pkgs.rust-bin.nightly.latest.default.override {
          targets = [ "riscv32imac-unknown-none-elf" ];
          extensions = [ "rust-src" ];
        })

        pkgs.esp-idf-full
        pkgs.espflash
        pkgs.ldproxy
        pkgs.pkg-config
        pkgs.cmake
        pkgs.ninja
        pkgs.llvmPackages.libclang.lib
      ];

      shellHook = ''
        export IDF_TOOLS_PATH=$HOME/.espressif
        export MCU=esp32c6
        export ESP_IDF_TOOLS_INSTALL_DIR=fromenv
        export LIBCLANG_PATH="${pkgs.llvmPackages.libclang.lib}/lib"
      '';
    };
  };
}
