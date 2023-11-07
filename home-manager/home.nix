# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs
, outputs
, lib
, config
, pkgs
, ...
}:
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
      outputs.overlays.neovim-nightly-overlay
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
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
  };

  home = {
    username = "stinky";
    homeDirectory = "/home/stinky";
  };
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "nvim +Man!"
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs;
    [
      arandr
      bat
      cachix
      fd
      feh
      firefox
      fzf
      htop
      jq
      man-pages
      man-pages-posix
      nix-tree
      ripgrep
      tree
      watch
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
          dhall = {
            command = "${pkgs.dhall-lsp-server}/bin/dhall-lsp-server";
            filetypes = [ "dhall" ];
          };
          haskell = {
            command = "haskell-language-server";
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
          nix = {
            command = "nixd";
            filetypes = [ "nix" ];
          };
          rust = {
            command = "rust-analyzer";
            rootPatterns = [
              "*.rs"
              "Cargo.toml"
            ];
          };
          # sh = {
          #   enable = true;
          #   command = "";
          #   bashIde.shellcheckPath = [];
          # };
          zig = {
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
    extraPackages = [
      pkgs.shfmt
      pkgs.zls
    ];
    withNodeJs = true;
    withPython3 = true;
    extraPython3Packages = (p: with p; [ ]);
    plugins = with pkgs; [
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
      # Haha Nix?
      vimPlugins.telescope-manix
      vimPlugins.vim-nix

      # Editor Specific
      vimPlugins.editorconfig-nvim

      # Haskell
      vimPlugins.haskell-tools-nvim
      vimPlugins.telescope_hoogle

      # Rust
      vimPlugins.rust-tools-nvim
      # Dhall
      vimPlugins.dhall-vim
      # Dap?
      vimPlugins.nvim-dap
      vimPlugins.coc-nvim
      vimPlugins.coc-sh
      # treesitter
      vimPlugins.nvim-treesitter.withAllGrammars
    ];
    extraConfig = (import ./vim-config.nix) { };
  };
  programs.nix-index.enable = true;
  programs.ssh.enable = true;

  # home-manager manages home-manager
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
