/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2016-2023 elementary, Inc. (https://elementary.io)
 */

public class Sharing.Widgets.HostnamePage : Switchboard.SettingsPage {
    private unowned Backend.HostnameManager hostname_manager;

    private Gtk.Entry hostname_entry;

    public HostnamePage () {
        Object (activatable: false);
    }

    construct {
        title = _("Device Name");
        description = _("This name is visible to local devices connected with Bluetooth or network.");
        icon = new ThemedIcon ("network-workgroup");
        show_end_title_buttons = true;

        hostname_manager = Backend.HostnameManager.get_default ();

        hostname_entry = new Gtk.Entry () {
            valign = CENTER,
            text = hostname_manager.get_hostname (),
            sensitive = hostname_manager.is_allowed_permission
        };

        var hostname_label = new Gtk.Label (_("Device name:")) {
            halign = END,
            mnemonic_widget = hostname_entry,
        };

        var box = new Gtk.Box (HORIZONTAL, 12);
        box.append (hostname_label);
        box.append (hostname_entry);

        child = box;

        hostname_entry.activate.connect (() => {
            string hostname = hostname_entry.text;
            hostname_manager.set_hostname.begin (hostname, (obj, res) => {
                try {
                    hostname_manager.set_hostname.end (res);
                } catch (Error err) {
                    var error_dialog = new Granite.MessageDialog (
                        _("Unable to name this device “%s”").printf (hostname),
                        _("Failed to set your hostname."),
                        new ThemedIcon ("dialog-password"),
                        Gtk.ButtonsType.CLOSE
                        ) {
                        badge_icon = new ThemedIcon ("dialog-error"),
                        modal = true,
                        transient_for = (Gtk.Window) get_root ()
                    };
                    error_dialog.show_error_details (err.message);
                    error_dialog.response.connect (error_dialog.destroy);
                    error_dialog.present ();
                }
            });
        });
    }
}
