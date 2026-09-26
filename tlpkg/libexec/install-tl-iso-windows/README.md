# TeX Live ISO Installer Launcher

TeX Live ISO Installer Launcher offers an alternative to `install-tl-windows.exe` to install TeX Live on Windows from the official ISO image.

The historic Internet installer `install-tl-windows.exe` sets up and launches the standard TeX Live installer. The latter then proceeds with installation over Internet by downloading many thousands of file one at a time. Although generally reliable, this approach is slow and it may time out for users on standard wifi connections.

TeX Live ISO Installer Launcher differs by relying on the complete TeX Live ISO image. The installation wizard then downloads and mounts the image, and then launches the TeX Live installer. Installation from a local copy of the files is quick and does not require Internet access. The wizard cleans up once the installation is complete. 

## Author

Vincent Goulet, École d'actuariat, Université Laval

## License

TBD

<!-- Local Variables: -->
<!-- eval: (auto-fill-mode -1) -->
<!-- eval: (visual-line-mode) -->
<!-- End: -->
