/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2016-2023 elementary, Inc. (https://elementary.io)
 */

public class Sharing.Widgets.BluetoothPage : Switchboard.SettingsPage {
    private GLib.Settings bluetooth_settings;

    public BluetoothPage () {
        Object (activatable: true);
    }

    construct {
        title = _("Bluetooth");
        icon = new ThemedIcon ("preferences-bluetooth");

        var accept_switch = new Gtk.Switch () {
            valign = CENTER
        };

        var accept_label = new Gtk.Label (_("Ask before accepting files:")) {
            halign = END,
            mnemonic_widget = accept_switch
        };

        var box = new Gtk.Box (HORIZONTAL, 12);
        box.append (accept_label);
        box.append (accept_switch);

        child = box;

        var settings_button = add_button (_("Bluetooth Settings…"));

        bluetooth_settings = new GLib.Settings ("io.elementary.desktop.wingpanel.bluetooth");
        bluetooth_settings.bind ("bluetooth-obex-enabled", status_switch, "active", SettingsBindFlags.NO_SENSITIVITY);
        bluetooth_settings.bind ("bluetooth-confirm-accept-files", accept_switch, "active", SettingsBindFlags.DEFAULT);

        set_service_state ();

        bluetooth_settings.changed ["bluetooth-enabled"].connect (() => {
            set_service_state ();
        });

        status_switch.notify["active"].connect (() => {
            set_service_state ();
        });

        settings_button.clicked.connect (() => {
            var uri_launcher = new Gtk.UriLauncher ("settings://network/bluetooth");
            uri_launcher.launch.begin (((Gtk.Application) Application.get_default ()).active_window, null);
        });
    }

    private void set_service_state () {
        if (bluetooth_settings.get_boolean ("bluetooth-enabled")) {
            if (bluetooth_settings.get_boolean ("bluetooth-obex-enabled")) {
                description = _("While enabled, bluetooth devices can send files to Downloads.");
                status = _("Enabled");
                status_type = SUCCESS;
            } else {
                description = _("While disabled, bluetooth devices can not send files to Downloads.");
                status = _("Disabled");
                status_type = OFFLINE;
            }
        } else {
            description = _("The bluetooth device is either disconnected or disabled. Check bluetooth settings and try again.");
            status_type = ERROR;
            status = _("Not Available");
        }
    }
}
