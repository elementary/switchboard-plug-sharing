/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2016-2023 elementary, Inc. (https://elementary.io)
 */

public class Sharing.Widgets.BluetoothPage : Granite.SimpleSettingsPage {
    private GLib.Settings bluetooth_settings;

    public BluetoothPage () {
        Object (
            activatable: true,
            description: ""
        );
    }

    construct {
        title = _("Bluetooth");
        icon_name = "preferences-bluetooth";

        var accept_label = new Gtk.Label (_("Ask before accepting files:")) {
            halign = END
        };

        var accept_switch = new Gtk.Switch ();

        content_area.attach (accept_label, 0, 1);
        content_area.attach (accept_switch, 1, 1);

        var link_button = new Gtk.LinkButton.with_label (
            "settings://network/bluetooth",
            _("Bluetooth settings…")
        );
        link_button.tooltip_text = "";

        action_area.append (link_button);

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
