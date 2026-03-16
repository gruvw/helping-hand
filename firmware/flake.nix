{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rustToolchain = pkgs.rust-bin.nightly.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
          targets = [ "riscv32imac-unknown-none-elf" ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            espflash
            ldproxy
            pkg-config
            cmake
            ninja
            python3
            python3Packages.pip
            python3Packages.virtualenv
            libclang
            # Critical libraries for ESP-IDF binaries
            zlib
            openssl
            xz
            flex
            bison
            gperf
            ncurses
          ];

          shellHook = ''
            export LIBCLANG_PATH="${pkgs.libclang.lib}/lib"
            export ESP_IDF_VERSION="v5.2.2"

            # This is the "Magic Sauce" for NixOS.
            # It tells downloaded binaries where to find standard C++ libraries and zlib.
            export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zlib}/lib:${pkgs.openssl}/lib:$LD_LIBRARY_PATH"

            # Helps bindgen find the right headers
            export BINDGEN_EXTRA_CLANG_ARGS="$(< ${pkgs.clang}/nix-support/libc-crt1-cflags) $(< ${pkgs.clang}/nix-support/libc-cflags) $(< ${pkgs.clang}/nix-support/cc-cflags) -idirafter ${pkgs.libclang.lib}/lib/clang/${pkgs.libclang.version}/include"

            echo "🦀 ESP32-C6 Nix Shell Ready"
          '';
        };
      });
}
