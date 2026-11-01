{ palette }:

# swaync stylesheet, generated from the shared palette like every other
# surface. Imported by services.swaync in ../services.nix.
''
  * {
    font-family: "JetBrainsMono Nerd Font";
    font-size: 13px;
  }

  .control-center {
    background: ${palette.rgba "base" "0.96"};
    border: 2px solid ${palette.rgba "blue" "0.35"};
    border-radius: 14px;
    padding: 14px;
  }

  .control-center-list {
    background: transparent;
  }

  .notification-row {
    outline: none;
    margin: 4px 0;
  }

  .notification {
    background: ${palette.rgba "text" "0.08"};
    border: 1px solid ${palette.rgba "text" "0.12"};
    border-radius: 10px;
    padding: 10px;
  }

  .notification-content {
    padding: 2px;
  }

  .summary {
    color: ${palette.hex "text"};
    font-weight: 700;
  }

  .body {
    color: ${palette.hex "subtext1"};
  }

  .time {
    color: ${palette.hex "overlay1"};
  }

  .widget-title,
  .widget-buttons-grid,
  .widget-dnd,
  .widget-volume,
  .widget-backlight,
  .widget-mpris {
    background: ${palette.rgba "text" "0.06"};
    border-radius: 10px;
    margin: 4px 0 8px;
    padding: 10px;
  }

  .widget-title {
    color: ${palette.hex "blue"};
    font-size: 15px;
    font-weight: 700;
  }

  .widget-buttons-grid {
    padding: 6px;
  }

  .widget-buttons-grid button {
    color: ${palette.hex "text"};
    background: ${palette.rgba "text" "0.07"};
    border: 1px solid ${palette.rgba "text" "0.10"};
    border-radius: 8px;
    margin: 3px;
    padding: 8px 6px;
    min-height: 30px;
  }

  .widget-buttons-grid button:hover {
    color: ${palette.hex "base"};
    background: ${palette.hex "blue"};
    border-color: ${palette.hex "blue"};
  }

  .widget-dnd {
    color: ${palette.hex "yellow"};
  }

  .widget-mpris {
    color: ${palette.hex "text"};
  }

  .widget-mpris-player {
    background: transparent;
    padding: 4px;
  }

  .widget-mpris-album-art {
    border-radius: 8px;
  }

  .widget-mpris-title {
    color: ${palette.hex "mauve"};
    font-weight: 700;
  }

  .widget-mpris-subtitle {
    color: ${palette.hex "subtext0"};
  }

  .widget-mpris button {
    color: ${palette.hex "text"};
    background: ${palette.rgba "blue" "0.12"};
    border: none;
    border-radius: 8px;
    margin: 4px;
    min-width: 32px;
    min-height: 28px;
  }

  .widget-mpris button:hover {
    background: ${palette.rgba "blue" "0.28"};
  }

  scrollbar trough {
    background: transparent;
  }

  scrollbar slider {
    background: ${palette.rgba "blue" "0.45"};
    border-radius: 8px;
    min-width: 6px;
  }
''
