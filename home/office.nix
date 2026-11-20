{ pkgs, ... }:

# LibreOffice for Microsoft Office and OpenDocument files. PDFs are not
# handled here: Firefox's built-in viewer opens them, see ./xdg.nix.
{
  home.packages = [ pkgs.libreoffice ];

  xdg.mimeApps.defaultApplications = {
    # Word documents and templates, Writer.
    "application/msword" = "writer.desktop";
    "application/rtf" = "writer.desktop";
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "writer.desktop";
    "application/vnd.openxmlformats-officedocument.wordprocessingml.template" = "writer.desktop";
    "application/vnd.ms-word.document.macroenabled.12" = "writer.desktop";
    "application/vnd.oasis.opendocument.text" = "writer.desktop";
    "application/vnd.oasis.opendocument.text-template" = "writer.desktop";

    # Excel workbooks and templates, Calc.
    "application/vnd.ms-excel" = "calc.desktop";
    "application/vnd.ms-excel.sheet.binary.macroenabled.12" = "calc.desktop";
    "application/vnd.ms-excel.sheet.macroenabled.12" = "calc.desktop";
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "calc.desktop";
    "application/vnd.openxmlformats-officedocument.spreadsheetml.template" = "calc.desktop";
    "application/vnd.oasis.opendocument.spreadsheet" = "calc.desktop";
    "application/vnd.oasis.opendocument.spreadsheet-template" = "calc.desktop";

    # PowerPoint presentations, slideshows and templates, Impress.
    "application/vnd.ms-powerpoint" = "impress.desktop";
    "application/vnd.ms-powerpoint.presentation.macroenabled.12" = "impress.desktop";
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "impress.desktop";
    "application/vnd.openxmlformats-officedocument.presentationml.slideshow" = "impress.desktop";
    "application/vnd.openxmlformats-officedocument.presentationml.template" = "impress.desktop";
    "application/vnd.oasis.opendocument.presentation" = "impress.desktop";
    "application/vnd.oasis.opendocument.presentation-template" = "impress.desktop";
  };
}
