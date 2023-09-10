{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.schizofox.homeManagerModule
  ];
  programs.schizofox = {
    enable = true;
    theme = {
      # options: font, background-darker, background, foreground, extraCss
      simplefox.enable = true;
      darkreader.enable = true;
    };
    # bookmarks = {};
    search = {
      defaultSearchEngine = "Startpage";
      removeEngines = ["Bing" "Amazon.com" "eBay" "Twitter" "Wikipedia" "LibRedirect" "DuckDuckGo"];
      addEngines = [
        {
          Name = "Startpage";
          Description = "The world's most private search engine.";
          Alias = "sp";
          Method = "POST";
          URLTemplate = "https://www.startpage.com/do/dsearch?query={searchTerms}&cat=web&pl=ext-ff&language=english";
        }
      ];
    };
    security = {
      # userAgent = "";
      sanitizeOnShutdown = false;
      sandbox = true;
    };
    misc = {
      drmFix = true;
      disableWebgl = false;
      #startPageURL = "";
    };
    # Installed by default:
    #     uBlock Origin           content blocker
    #     export-cookies-txt      export cookies to cookies.txt
    #     ClearURLs               remove tracking elements from URLs
    #     Decentraleyes           free, centralized content delivery to combat tracking
    #     Don't fuck with paste   no copy & paste for password & other input fields
    #     Single-file             save an entire page as a single HTML file
    #     Temporary containers    open links in disposable containers
    #     Skip-redirect           tries to extract final URL from intermediary URL & skips it
    #     Smart-referer           limits referer information leakage
    #     Libredirect             redirect youtube, twitter, tiktok, etc. to privace friendly frontends
    #extraExtensions = {};
  };
}
