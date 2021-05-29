{
  description = "RATS Testnet (Bolt)";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    cardano-node.url = "github:input-output-hk/cardano-node/1.27.0";
    cardano-db-sync.url = "github:input-output-hk/cardano-db-sync";
    adawallet.url = "github:input-output-hk/adawallet/nix-flake-old-hw-cli";
    cncli.url = "github:AndrewWestberg/cncli";
  };
  outputs = { self, nixpkgs, cardano-node, cardano-db-sync, adawallet, cncli }: {
     nixosConfigurations.pskov = let
         pkgsCardano = import nixpkgs { overlays = [ cardano-node.overlay ]; system = "x86_64-linux"; };
         baseModule = { pkgs, ... }: {
           nixpkgs.overlays = [
             #cncli.overlay
             (prev: final: {
               cardanoEnvironments = cardano-node.environments.x86_64-linux;
               inherit (pkgsCardano) cardano-node cardano-cli bech32;
               cardanoNodeModule = cardano-node.nixosModules.cardano-node;
               cardanoDBSyncModule = cardano-db-sync.nixosModules.cardano-db-sync;
             })
           ];
         };
     in  nixpkgs.lib.nixosSystem {
       system = "x86_64-linux";
       modules = [ baseModule ./configuration.nix cardano-node.nixosModules.cardano-node cardano-db-sync.nixosModules.cardano-db-sync ];
     };
  };
}
