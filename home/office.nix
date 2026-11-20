{ pkgs, ... }:

{
  home.packages = [ pkgs.onlyoffice-desktopeditors ];

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = "onlyoffice-desktopeditors.desktop";

    # Excel workbooks and templates, including macro-enabled formats.
    "application/vnd.ms-excel" = "onlyoffice-desktopeditors.desktop";
    "application/vnd.ms-excel.sheet.binary.macroenabled.12" = "onlyoffice-desktopeditors.desktop";
    "application/vnd.ms-excel.sheet.macroenabled.12" = "onlyoffice-desktopeditors.desktop";
    "application/vnd.ms-excel.template.macroenabled.12" = "onlyoffice-desktopeditors.desktop";
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" =
      "onlyoffice-desktopeditors.desktop";
    "application/vnd.openxmlformats-officedocument.spreadsheetml.template" =
      "onlyoffice-desktopeditors.desktop";

    # PowerPoint presentations, slideshows, and templates.
    "application/vnd.ms-powerpoint" = "onlyoffice-desktopeditors.desktop";
    "application/vnd.ms-powerpoint.presentation.macroenabled.12" = "onlyoffice-desktopeditors.desktop";
    "application/vnd.ms-powerpoint.slideshow.macroenabled.12" = "onlyoffice-desktopeditors.desktop";
    "application/vnd.ms-powerpoint.template.macroenabled.12" = "onlyoffice-desktopeditors.desktop";
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
      "onlyoffice-desktopeditors.desktop";
    "application/vnd.openxmlformats-officedocument.presentationml.slide" =
      "onlyoffice-desktopeditors.desktop";
    "application/vnd.openxmlformats-officedocument.presentationml.slideshow" =
      "onlyoffice-desktopeditors.desktop";
    "application/vnd.openxmlformats-officedocument.presentationml.template" =
      "onlyoffice-desktopeditors.desktop";
  };
}
