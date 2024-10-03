{ inputs, config, lib, pkgs, makeDesktopItem, ... }:

let
  makeWebappLib = import ../lib/makeWebapp.nix { inherit pkgs; };
  makeWebapp = makeWebappLib.makeWebapp;

  office = makeWebapp {
    app = "office.com/login?ru=%2Flaunch%2Fonedrive";
    icon = pkgs.fetchurl {
        url = "https://commons.wikimedia.org/wiki/File:Microsoft_Office_OneDrive_(2019%E2%80%93present).svg";
        sha256 = "";
      };
    comment = "Microsoft Office suite - featuring Word, Excel & Powerpoint";
    desktopName = "Microsoft Office";
  };

in
{
  imports = [
    ./hyprland.nix # Hyprland-specific config
  ];

  environment.systemPackages = with pkgs; [
    ags # Widget system for top bar + OSD
    git # Best source control manager
    microsoft-edge # Web browser
    foot # Terminal
    bun # Fast JS runtime
    dart-sass # Desktop dependency
    fd # Desktop dependency
    sassc # Sass compiler
    nix-prefetch-git # For creating Nix packages
    mpd # For the ags music player
    mpc-cli # CLI for ags music player
    glib # Gsettings dependency
    fastfetch # For bragging rights (slow)
    copyq # Clipboard manager (bloated)
    psmisc # Useful cli Linux tools, not a necessary application
    lsof # Useful util for finding items on a port (not necessary application)
    emote # Emoji picker
    cmake # Build tool
    starship # Best ZSH theme
    zip # Allow ziping and unziping of folders
    tmux # Super ultra terminal multiplexing dimensional warper
    swww # Background manager
    hyprlock # Lockscreen
    hypridle # Laptop idle daemon
    brightnessctl # Controls laptop brightness
    wl-screenrec # Fast screen recorder
    ngrok # Tunelling for quick Discord bot development
    grimblast # Screenshot tool
    slurp # Required for recording selection tool to function
    swappy # Quick screenshot editor 
    wl-clipboard # Required for Neovim
    blueman # Bluetooth management
    celluloid # Fast, simple GTK video player using mpv
    gnome-text-editor # Clean, tabbed, GTK text editor
    amberol # Lightweight and beautiful GTK music player
    nemo-with-extensions # Simple file manager
    nemo-fileroller # File manager archive feature
    file-roller # Adds file archive management
    tree-sitter # Neovim dependency
    glfw-wayland-minecraft # Weird dep for minecraft on wayland
    fzf # Fuzzy finder dep
    nodejs_22 # Node.js JavaScript runtime
    gcc13 # Neovim dependency (fixes Neovim errors)
    clamav # Linux virus scanner
    jdk22 # Java JDK version 22
    python3 # Python
    python312Packages.pip # Python pip
    zulu8 # Java 8 for breakdown (maybe can be removed if disable java check)
    steam-run # Annoying that I need this, but its required for Wrangler

    # Normal user apps
    neovide # GUI-based Neovim
    vscodium # Backup IDE (Neovim is main)
    vesktop # Custom discord client
    davinci-resolve # Video editor
    lunar-client # Minecraft client
    blockbench-electron # Minecraft 3D modeler
    jetbrains.idea-community # Jetbrains IDEA
    thunderbird # Best email/IRC client & RSS reader
    
    #firefoxpwa
    #(pkgs.firefox-wayland.override { nativeMessagingHosts = [ pkgs.firefoxpwa ]; })
    office # Custom Office 365 webapp

    #(prismlauncher.override{ withWaylandGLFW=true; }) # Wayland MC
    gimp # GNU image manipulation program
    teams-for-linux # Unoffical Microsoft Teams client
    libreoffice # Backup app for opening Word documents and Excel sheets
    spotdl # Download spotify playlists

    # this needs to be removed after fixed https://github.com/russelltg/wl-screenrec/issues/50
    wf-recorder
    
    (pkgs.makeDesktopItem { # Vesktop Discord client
      comment = "Voice and text chat application for gamers";
      desktopName = "Discord";
      exec =  "${pkgs.vesktop}/bin/vesktop";
      genericName = "Voice and text chat application for gamers";
      icon = "discord";
      name = "discord";
      startupNotify = true;
      startupWMClass = "discord";
      terminal = false;
      type = "Application";
      mimeTypes = [ "x-scheme-handler/discord" ];
    })
  ];

  # Neovim!!!
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
  };

  # Keyboard layout & language (with Chinese support)
  i18n.inputMethod = {
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-chinese-addons
        fcitx5-gtk
      ];
      waylandFrontend = true;
    };
  };

  services = {
    xserver = {
      enable = false; # Remove Xwayland support
      excludePackages = [ pkgs.xterm ]; # Don't include xterm
      xkb.layout = "us";
    };
    printing.enable = true; # Enables CUPS for printing
    logrotate.enable = false; # Don't need this
  };
  
  # Bluetooth & sound support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false; # Auto-enables bluetooth on startup
  };

  # Sound support 
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber = {
      enable = true;

      # Fix unnecessary power drain issue
      extraConfig = {
        "10-disable-camera" = {
          "wireplumber.profiles" = {
            main."monitor.libcamera" = "disabled";
          };
        };
      };
    };
  };
}
