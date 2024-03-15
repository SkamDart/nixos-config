# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs
, outputs
, lib
, config
, pkgs
, ...
}:
let
  nvim-plugintree = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: with p;
        [
          ada
          agda
          awk
          bash
          c
          cpp
          cuda
          d
          dart
          devicetree
          dhall
          diff
          ebnf
          elm
          elixir
          elvish
          erlang
          fish
          fortran
          fsh
          git-config
          git-rebase
          gitattributes
          gitcommit
          gitignore
          go
          graphql
          hack
          haskell
          hcl
          java
          javascript
          jq
          jsdoc
          json
          json5
          jsonc
          julia
          kdl
          kotlin
          latex
          llvm
          lua
          make
          markdown
          matlab
          nickel
          ninja
          nix
          ocaml
          ocaml_interface
          odin
          pascal
          proto
          python
          r
          racket
          ron
          rust
          scala
          sql
          typescript
          verilog
          vim
          vimdoc
          vue
          yaml
          zig
        ]);
    treesitter-parsers = pkgs.symlinkJoin {
      name = "treesitter-parsers";
      paths = nvim-plugintree.dependencies;
    };
in
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      outputs.overlays.neovim-nightly-overlay

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })

      # Vim Overlay
      #
      # Move this to overlays/vim.nix when you're not lazy.
      (final: prev: {
        customVim = {
          vim-copilot = final.vimUtils.buildVimPlugin {
            name = "vim-copilot";
            src = inputs.vim-copilot;
          };
          # nvim-treesitter = final.vimUtils.buildVimPlugin {
          #   name = "nvim-treesitter";
          #   src = inputs.nvim-treesitter;
          # };
        };
      })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  xdg.configFile = {
    "i3/config".text = builtins.readFile ./i3;
    "ghci/ghci.conf".text = builtins.readFile ./ghci.conf;
  };

  home = {
    username = "stinky";
    homeDirectory = "/home/stinky";
  };

  home.file.".gdbinit".source = ./gdbinit;

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "nvim +Man!";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs;
    [
      arandr
      bat
      brave
      cachix
      fd
      feh
      fzf
      gh
      gopls
      # haskellPackages.nixdu
      htop
      jq
      lazygit
      man-pages
      man-pages-posix
      # required for telescope-manix
      manix
      nil
      neofetch
      # required for nix language server
      # https://github.com/nix-community/nixd/issues/357
      # nixd
      nix-tree
      pciutils
      ripgrep
      tree
      tree-sitter
      watch
      xclip
      zig
      # 10K Challenge
      gopls
    ];

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      # dirty but we have fish on the path
      shell.program = "fish";
    };
  };

  programs.bash = {
    enable = true;
    shellOptions = [ ];
    historyControl = [ "ignoredups" "ignorespace" ];
    initExtra = builtins.readFile ./bashrc;
    shellAliases = {
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gdiff = "git diff";
      gl = "git prettylog";
      gp = "git push";
      gs = "git status";
      gt = "git tag";
    };
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gdiff = "git diff";
      gl = "git prettylog";
      gp = "git push";
      gs = "git status";
      gt = "git tag";
      pbcopy = "xclip";
      pbpaste = "xclip -o";
    };
  };

  programs.git = {
    enable = true;
    userName = "Cameron Dart";
    userEmail = "cdart2@illinois.edu";
    aliases = {
      cleanup = "!git branch --merged | grep  -v '\\*\\|master\\|develop' | xargs -n 1 -r git branch -d";
      prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      root = "rev-parse --show-toplevel";
    };
    extraConfig = {
      branch.autosetuprebase = "always";
      color.ui = true;
      core.askPass = ""; # needs to be empty to use terminal for ask pass
      credential.helper = "store"; # want to make this more secure
      github.user = "skamdart";
      push.default = "tracking";
      init.defaultBranch = "main";
    };
  };

  # !10kK Challenge
  programs.go = {
    enable = true;
    package = pkgs.go;
  };

  programs.i3status = {
    enable = true;
    general = {
      colors = true;
      color_good = "#8C9440";
      color_bad = "#A54242";
      color_degraded = "#DE935F";
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    coc = {
      enable = true;
      settings = {
        languageserver = {
         bash = {
            command = "${lib.getExe pkgs.nodePackages.bash-language-server}";
            args = [ "start" ];
            filetypes = [ "sh" "bash" "zsh" ];
          };
          dhall = {
            command = "${lib.getExe pkgs.dhall-lsp-server}";
            filetypes = [ "dhall" ];
          };
          go = {
            checkForUpdates = false;
            command = "gopls";
            enable = true;
            rootPatterns = ["go.work" "go.mod"];
            filetypes = ["go"];
            initializationOptions = {
              usePlaceholders = true;
            };
          };
          haskell = {
            command = "haskell-language-server-wrapper";
            args = [ "--lsp" ];
            rootPatterns = [
              "*.cabal"
              "cabal.project"
              "hie.yaml"
              "stack.yml"
            ];
            filetypes = [ "haskell" "lhaskell" ];
            settings = {
              checkParents = "CheckOnSave";
              checkProject = true;
              maxCompletions = 10;
            };
          };
          # we can return to purity when the nixpkgs version is 23.11
          # Just kidding nix itself is never pure and has CVEs
          # https://github.com/nix-community/nixd/issues/357
          #
          # Attempting to use nil via a flake input installed in the profile
          nix = {
            command = "nil";
            filetypes = [ "nix" ];
            rootPatterns = [ "default.nix" "flake.nix" "shell.nix" ];
          };
          rust = {
            command = "rust-analyzer";
            rootPatterns = [
              "*.rs"
              "Cargo.toml"
            ];
          };
          zig = {
            startUpMessage = false;
            zls = {
              enable = true;
            };
            command = "zls";
            filetypes = [ "zig" ];
            rootPatterns = [ "build.zig" ];
          };
        };
      };
    };
    package = pkgs.neovim-nightly;
    extraPackages = with pkgs; [
      # Bash
      shellcheck
      shfmt

      # Nix
      nixpkgs-fmt
      statix

      # Telescope dependencies
      fd
      ripgrep

      # Zig
      zls
    ];
    withNodeJs = true;
    withPython3 = true;
    extraPython3Packages = (p: with p; [ ]);
    plugins = with pkgs; [
      customVim.vim-copilot
      vimPlugins.nvim-comment
      vimPlugins.nvim-lspconfig
      vimPlugins.plenary-nvim # required for telescope
      vimPlugins.telescope-nvim
      vimPlugins.vim-fish
      vimPlugins.vim-fugitive
      vimPlugins.zig-vim
      vimPlugins.vim-eunuch
      vimPlugins.vim-gitgutter
      vimPlugins.vim-markdown
      vimPlugins.lazygit-nvim
      # Haha Nix?
      vimPlugins.telescope-manix
      vimPlugins.vim-nix

      # Editor Specific
      vimPlugins.editorconfig-nvim

      # Haskell
      # vimPlugins.haskell-tools-nvim
      # vimPlugins.telescope_hoogle

      # Rust
      vimPlugins.rust-tools-nvim

      # Dhall
      vimPlugins.dhall-vim

      vimPlugins.coc-nvim
      vimPlugins.coc-sh

      # 10k challenge
      vimPlugins.vim-go
      vimPlugins.coc-go

      # treesitter
      {
        plugin = nvim-plugintree;
        type = "lua";
        config = ''
          -- Add treesitter plugin path
          -- vim.opt.runtimepath:append("${nvim-plugintree}")
          -- Add Treesitter Parsers Path
          -- vim.opt.runtimepath:append("${treesitter-parsers}")
          require("nvim-treesitter.configs").setup({
            ensure_installed = {},
            -- Do not install parsers synchronously
            sync_install = false,
            -- Do not install the parser for the current file
            auto_install = false,
            highlight = {
              enable = true,
            },
            indent = {
              enable = true,
              additional_vim_regex_highlighting = false,
            },
          })
        '';
      }

      # As of 2023-11-13 all of these are borked and give some lua
      # error. I'm not sure why and I am definitely not going to spend
      # my free time debugging lua + nix.
      #
      # Life is too short for that.
      #
      # vimPlugins.nvim-treesitter
      # vimPlugins.nvim-treesitter.withPlugins (p: with p; [])
    ];
    extraConfig = ''
      " Use <Space> as leader key
      let mapleader = "\<Space>"
      " save with space + w
      nmap <leader>w :w<CR>
      " quit with space + q
      nmap <leader>q :q<CR>
      " quit without saving with space + Q
      nmap <leader>Q :q!<CR>
      " save and quit with space + W
      nmap <leader>W :wq<CR>
      " save and quit without saving with space + WQ
      nmap <leader>WQ :wq!<CR>

      " Jump to start/end of line using home row keys
      map H ^
      map L $
      set list
      set listchars=nbsp:¬,extends:»,precedes:«,trail:•,eol:$
      set timeoutlen=1000
      set ttimeoutlen=50
      set expandtab
      set number relativenumber
    '';
  };

  # see https://github.com/nix-community/neovim-nightly-overlay/wiki/Tree-sitter
  # xdg.configFile."nvim/parser/agda.so".source = "${pkgs.tree-sitter-grammars.tree-sitter-agda}/parser";
  # xdg.configFile."nvim/parser/bash.so".source = "${pkgs.tree-sitter-grammars.tree-sitter-bash}/parser";
  # xdg.configFile."nvim/parser/cuda.so".source = "${pkgs.tree-sitter-grammars.tree-sitter-cuda}/parser";
  # xdg.configFile."nvim/parser/dhall.so".source = "${pkgs.tree-sitter-grammars.tree-sitter-dhall}/parser";
  # xdg.configFile."nvim/parser/devicetree.so".source = "${pkgs.tree-sitter-grammars.tree-sitter-devicetree}/parser";
  # xdg.configFile."nvim/parser/fish.so".source = "${pkgs.tree-sitter-grammars.tree-sitter-fish}/parser";
  # xdg.configFile."nvim/parser/go.so".source = "${pkgs.tree-sitter-grammars.tree-sitter-go}/parser";
  # xdg.configFile."nvim/parser/haskell.so".source = "${pkgs.tree-sitter-grammars.tree-sitter-haskell}/parser";
  # xdg.configFile."nvim/parser/llvm.so".source = "${pkgs.tree-sitter-grammars.tree-sitter-llvm}/parser";
  # xdg.configFile."nvim/parser/nickel.so".source = "${pkgs.tree-sitter-grammars.tree-sitter-nickel}/parser";
  # xdg.configFile."nvim/parser/nix.so".source = "${pkgs.tree-sitter-grammars.tree-sitter-nix}/parser";
  # xdg.configFile."nvim/parser/ocaml.so".source = "${pkgs.tree-sitter-grammars.tree-sitter-ocaml}/parser";
  # xdg.configFile."nvim/parser/ocaml-interface.so".source = "${pkgs.tree-sitter-grammars.tree-sitter-ocaml-interface}/parser";
  # xdg.configFile."nvim/parser/rust.so".source = "${pkgs.tree-sitter-grammars.tree-sitter-rust}/parser";
  # xdg.configFile."nvim/parser/verilog.so".source = "${pkgs.tree-sitter-grammars.tree-sitter-verilog}/parser";
  # xdg.configFile."nvim/parser/yaml.so".source = "${pkgs.tree-sitter-grammars.tree-sitter-yaml}/parser";
  # xdg.configFile."nvim/parser/zig.so".source = "${pkgs.tree-sitter-grammars.tree-sitter-zig}/parser";

  programs.nix-index.enable = true;
  programs.ssh.enable = true;

  # home-manager manages home-manager
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
