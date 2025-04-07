{
  programs.newsboat = {
    enable = true;
    urls = [{
      tags = [ "news" ];
      url = "https://neovim.io/news.xml";
    }];
  };
}
