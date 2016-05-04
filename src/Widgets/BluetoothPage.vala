/*
 * Copyright (c) 2011-2016 elementary LLC (https://launchpad.net/switchboard-plug-sharing)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

public class Sharing.Widgets.BluetoothPage : SettingsPage {
    GLib.Settings settings;
    Gtk.Switch notify_switch;
    Gtk.ComboBoxText accept_combo;

    public BluetoothPage () {
        base ("bluetooth",
              _("Bluetooth"),
              "preferences-bluetooth",
              _("While enabled, bluetooth devices can send files to Downloads."),
              _("While disabled, bluetooth devices can not send files to Downloads."));

        settings = new GLib.Settings ("org.gnome.desktop.file-sharing");

        build_ui ();
        read_state ();
        connect_signals ();
    }

    private void build_ui () {
        base.content_grid.set_size_request (500, -1);
        base.content_grid.margin_top = 100;

        var notify_label = new Gtk.Label (_("Notify about newly received files:"));
        notify_label.xalign = 1.0f;

        notify_switch = new Gtk.Switch ();
        notify_switch.halign = Gtk.Align.START;

        var accept_label = new Gtk.Label (_("Accept files from bluetooth devices:"));
        accept_label.xalign = 1.0f;

        accept_combo = new Gtk.ComboBoxText ();
        accept_combo.hexpand = true;
        accept_combo.append ("always", _("Always"));
        accept_combo.append ("bonded", _("When paired"));
        accept_combo.append ("ask", _("Ask me"));

        base.content_grid.attach (notify_label, 0, 0, 1, 1);
        base.content_grid.attach (notify_switch, 1, 0, 1, 1);
        base.content_grid.attach (accept_label, 0, 1, 1, 1);
        base.content_grid.attach (accept_combo, 1, 1, 1, 1);
    }

    private void read_state () {
        update_state (settings.get_boolean ("bluetooth-obexpush-enabled") ? ServiceState.ENABLED : ServiceState.DISABLED);
    }

    private void connect_signals () {
        settings.bind ("bluetooth-obexpush-enabled", base.service_switch, "active", SettingsBindFlags.DEFAULT);

        base.switch_state_changed.connect ((state) => {
            settings.set_boolean ("bluetooth-obexpush-enabled", state);
            update_state (state ? ServiceState.ENABLED : ServiceState.DISABLED);
        });

        settings.bind ("bluetooth-notify", notify_switch, "active", SettingsBindFlags.DEFAULT);
        settings.bind ("bluetooth-accept-files", accept_combo, "active-id", SettingsBindFlags.DEFAULT);
    }

}
