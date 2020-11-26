# Switchboard Sharing Plug
[![Translation status](https://l10n.elementary.io/widgets/switchboard/-/switchboard-plug-sharing/svg-badge.svg)](https://l10n.elementary.io/engage/switchboard/?utm_source=widget)

![Screenshot](data/screenshot.png?raw=true)

## Building and Installation

You'll need the following dependencies:

* libgranite-dev
* libgtk-3-dev
* libswitchboard-2.0-dev
* meson
* valac

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`

    sudo ninja install
