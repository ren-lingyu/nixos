{ config, lib, pkgs, osConfig, ... } : {

  config = {

    accounts.email.accounts = {
      
      "Ren_Lingyu@outlook.com" = {
        # https://support.microsoft.com/office/pop-imap-and-smtp-settings-for-outlook-com-d088b986-291d-42b8-9564-9c414e2aa040
        
        enable = true;
        primary = true;
        address = "Ren_Lingyu@outlook.com";
        flavor = "outlook.office365.com";
        realName = "Lingyu Ren";
        userName = "Ren_Lingyu@outlook.com";
        
        aliases = [
          "aRen_Coco@outlook.com"
        ];
        
        imap = lib.mkForce {
          host = "outlook.office365.com";
          tls = {
            enable = true;
            useStartTls = false;
          };
          port = 993;
          authentication = "xoauth2";
        };
        
        smtp = lib.mkForce {
          host = "smtp-mail.outlook.com"; # "smtp.outlook.com";
          tls = {
            enable = true;
            useStartTls = true;
          };
          port = 587;
          authentication = "xoauth2";
        };
        
        signature = {
          showSignature = "append";
          command = null;
          text = builtins.concatStringsSep "\n" [
            "Lingyu"
          ];
          delimiter = builtins.concatStringsSep "\n" [
            "--"
          ];
        };
        
        thunderbird = {
          # https://support.microsoft.com/en-us/topic/set-up-email-in-mozilla-thunderbird-8-0-f4726a9e-64d3-4494-9260-5762597fd1a6
          enable = config.programs.thunderbird.enable;
          profiles = [
            "${config.home.username}"
          ];
        };
        
      };      

      "lingyurenmail@gmail.com" = {

        enable = true;
        primary = false;
        address = "lingyurenmail@gmail.com";
        flavor = "gmail.com";
        realName = "Lingyu Ren";
        userName = "lingyurenmail@gmail.com";

        aliases = [];
        
        imap = {
          host = "imap.gmail.com";
          tls = {
            enable = true;
            useStartTls = false;
          };
          port = 993;
          authentication = "xoauth2";
        };
        
        smtp = {
          host = "smtp.gmail.com";
          tls = {
            enable = true;
            useStartTls = false;
          };
          port = 465;
          authentication = "xoauth2";
        };
        
        signature = {
          showSignature = "append";
          command = null;
          text = builtins.concatStringsSep "\n" [
            "Lingyu"
          ];
          delimiter = builtins.concatStringsSep "\n" [
            "--"
          ];
        };

        thunderbird = {
          enable = config.programs.thunderbird.enable;
          profiles = [
            "${config.home.username}"
          ];
        };
        
      };

      "ah.renn.coco@gmail.com" = {

        enable = true;
        primary = false;
        address = "ah.renn.coco@gmail.com";
        flavor = "gmail.com";
        realName = "Coco Ren";
        userName = "ah.renn.coco@gmail.com";

        aliases = [];
        
        imap = {
          host = "imap.gmail.com";
          tls = {
            enable = true;
            useStartTls = false;
          };
          port = 993;
          authentication = "xoauth2";
        };
        
        smtp = {
          host = "smtp.gmail.com";
          tls = {
            enable = true;
            useStartTls = false;
          };
          port = 465;
          authentication = "xoauth2";
        };
        
        signature = {
          showSignature = "append";
          command = null;
          text = builtins.concatStringsSep "\n" [
            "aRenCoco"
          ];
          delimiter = builtins.concatStringsSep "\n" [
            "--"
          ];
        };

        thunderbird = {
          enable = config.programs.thunderbird.enable;
          profiles = [
            "${config.home.username}"
          ];
        };
        
      };
      
    };
    
    programs.thunderbird = {
      
      enable = osConfig.programs.thunderbird.enable;
      package = pkgs.thunderbird;
      nativeMessagingHosts = [];
      languagePacks = [
        "zh-CN"
        "en-US"
        "en-GB"
      ];
      
      settings = {
        "mail.shell.checkDefaultClient" = false;
      };
      
      profiles = let
        
        fromList = list : builtins.listToAttrs (
          builtins.map (x : {
            name = builtins.toString x;
            value = {};
          }) list
        );
        
      in {
        
        "${config.home.username}" = rec {
          isDefault = true;
          withExternalGnupg = true;
          feedAccounts = fromList [
            "Blog"
            "arXiv"
            "Git"
          ];
          accountsOrder = builtins.attrNames config.accounts.email.accounts;
          calendarAccountsOrder = accountsOrder;
          search = {
            force = true;
            default = "bing";
            privateDefault = "ddg";
            order = builtins.attrNames search.engines;
            engines = {
              bing = {
                name = "Bing";
                urls = [
                  {
                    template = "https://www.bing.com/search?q={searchTerms}";
                  }
                ];
                definedAliases = [ "@b" ];
              };
              google = {
                name = "Google";
                urls = [
                  {
                    template = "https://www.google.com/search?q={searchTerms}";
                  }
                ];
                definedAliases = [ "@g" ];
              };
              ddg = {
                name = "DuckDuckGo";
                urls = [
                  {
                    template = "https://duckduckgo.com/?q={searchTerms}";
                  }
                ];
                definedAliases = [ "@d" ];
              };
            };
          };
          extensions = [];
          settings = {
            "extensions.autoDisableScopes" = 0;
            "mail.ui.display.dateformat.thisweek" = 0;
            "mail.openMessageBehavior" = 2;
            "general.useragent.locale" = "zh-CN";
          };
          extraConfig = "";
          userChrome = "";
          userContent = "";
        };
        
      };
      
    };
    
  };

}
