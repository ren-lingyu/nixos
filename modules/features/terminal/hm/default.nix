{ config, osConfig, pkgs, lib, ... } : let

  cfg = osConfig.modules.features.terminal;

in {

  config = lib.mkIf cfg.enable {

    programs.alacritty = {
      enable = false;
      settings = {
        env.TERM = "xterm-256color";
        font = {
          size = 12;
          draw_bold_text_with_bright_colors = true;
        };
        scrolling.multiplier = 5;
        selection.save_to_clipboard = true;
      };
    };

    programs.kitty = {
      enable = true;
      package = pkgs.kitty;
      settings = {
        scrollback_lines = 10000;
        scrollback_pager_history_size = 10;
        enable_audio_bell = false;
        window_padding_width = 4;
        notify_on_cmd_finish = "invisible 10.0";
      };
    };

    xdg.terminal-exec = {
      enable = true;
      package = pkgs.xdg-terminal-exec;
      settings = {
        default = [
          "kitty.desktop"
        ];
      };
    };

  };

}
