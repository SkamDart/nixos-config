{ pkgs, lib, config, ...}:
{
programs.fzf.enable = true;

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
          # in 23.11 this is the nixpkgs under pkgs.nixd
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
    extraPackages = with pkgs; [
      shellcheck
      shfmt
      zls
    ];
    withNodeJs = true;
    withPython3 = true;
    extraPython3Packages = (p: with p; [ ]);
    plugins = with pkgs.vimPlugins; [
      # customVim.vim-copilot
      coc-git
      coc-json
      coc-pyright
      coc-sh
      lazygit-nvim
      {
        plugin = fzf-vim;
        config = ''
        nnoremap <silent> <C-N> :Files<CR>
        vnoremap <silent> <C-N> :Files<CR>
        '';
      }
      {
        plugin = coc-fzf;
        config = ''
        nnoremap <silent> <space><space> :<C-u>CocFzfList<CR>
        nnoremap <silent> <space>a       :<C-u>CocFzfList diagnostics<CR>
        nnoremap <silent> <space>b       :<C-u>CocFzfList diagnostics --current-buf<CR>
        nnoremap <silent> <space>c       :<C-u>CocFzfList commands<CR>
        nnoremap <silent> <space>e       :<C-u>CocFzfList extensions<CR>
        nnoremap <silent> <space>l       :<C-u>CocFzfList location<CR>
        nnoremap <silent> <space>o       :<C-u>CocFzfList outline<CR>
        nnoremap <silent> <space>s       :<C-u>CocFzfList symbols<CR>
        nnoremap <silent> <space>p       :<C-u>CocFzfListResume<CR>
        '';
      }
      dhall-vim
      {
        plugin = nerdcommenter;
        # Use ctrl + / to toggle comments
        config = ''
          nmap <C-_> <Plug>NERDCommenterToggle
          vmap <C-_> <Plug>NERDCommenterToggle<CR>gv
          let g:NERDCreateDefaultMappings = 0
        '';
      }
      {
          plugin = nvim-treesitter.withAllGrammars;
          type = "lua";
          config = ''
          require("nvim-treesitter.configs").setup({
            ensure_installed = {},
            sync_install = false,
            auto_install = false,
            highlight = {
              enable = true,
            },
            indent = {
              enable = true,
            },
          })
          '';
      }
      # treesitter plugins
      # {
      #   plugin = nvim-treesitter.withPlugins (p: [
      #     p.ada
      #     p.agda
      #     p.bash
      #     p.c
      #     p.cpp
      #     p.cuda
      #     p.dart
      #     p.devicetree
      #     p.diff
      #     p.dhall
      #     p.elm
      #     p.erlang
      #     p.fish
      #     p.git_config
      #     p.git_rebase
      #     p.gitignore
      #     p.go
      #     p.gomod
      #     p.gosum
      #     p.gowork
      #     p.haskell
      #     p.javascript
      #     p.json
      #     p.lua
      #     p.llvm
      #     p.make
      #     p.matlab
      #     p.mlir
      #     p.nickel
      #     p.nix
      #     p.ocaml
      #     p.ocaml_interface
      #     p.odin
      #     p.proto
      #     p.python
      #     p.racket
      #     p.rust
      #     p.scala
      #     p.sql
      #     p.starlark
      #     p.toml
      #     p.typescript
      #     p.verilog
      #     p.vim
      #     p.yaml
      #     p.zig
      #   ]);
      #   type = "lua";
      #   config = ''
      #     require("nvim-treesitter.configs").setup({
      #       ensure_installed = { },
      #       sync_install = false,
      #       auto_install = false,
      #       ignore_install = { "all" },
      #       highlight = {
      #         enable = true,
      #       },
      #       indent = {
      #         enable = true,
      #         additional_vim_regex_highlighting = false,
      #       },
      #     })
      #   '';
      # }
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

      set listchars=nbsp:¬,extends:»,precedes:«,trail:•,eol:$
      set timeoutlen=1000
      set ttimeoutlen=50

      set expandtab

      set number relativenumber


    '';
  }; # programs.neovim
}
