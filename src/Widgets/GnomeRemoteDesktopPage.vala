/*
 * Copyright (c) 2023 elementary LLC (https://launchpad.net/switchboard-plug-sharing)
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
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 */

public class Sharing.Widgets.GnomeRemoteDesktopPage : SettingsPage {
    public NM.Client client { get; construct; }
    GLib.Settings vnc_settings;
    GLib.Settings rdp_settings;

    Gtk.Switch useLegacyVNCMode_switch;
    Gtk.Switch remoteControl_switch;
    Gtk.Entry deviceName_entry;
    Gtk.Label vnc_url_label;
    Gtk.Entry rdp_url_entry;
    Gtk.Entry vnc_url_entry;
    Gtk.Entry password_entry;

    public GnomeRemoteDesktopPage () {
        base ("Remote Desktop",
          _("Remote Desktop"),
          "preferences-desktop-remote-desktop",
          _("While enabled this machine will be viable on the network allowing other computer find, connect or control this machine remotely with or with out a password"),
          _("While disabled this machine will be hidden from other computer on the network & can not connected to or controlled remotely by other computer even if the IPaddress is know"));

        vnc_settings = new GLib.Settings ("org.gnome.desktop.remote-desktop.vnc");
        rdp_settings = new GLib.Settings ("org.gnome.desktop.remote-desktop.rdp");

        vnc_settings.bind ("enable", useLegacyVNCMode_switch, "active", SettingsBindFlags.NO_SENSITIVITY);
        vnc_settings.bind ("view-only", remoteControl_switch, "active", SettingsBindFlags.NO_SENSITIVITY|SettingsBindFlags.INVERT_BOOLEAN);
        vnc_settings.set_boolean("view-only", remoteControl_switch.state);
        
        rdp_settings.bind ("enable", service_switch, "active", SettingsBindFlags.NO_SENSITIVITY);
        rdp_settings.bind ("view-only", remoteControl_switch, "active", SettingsBindFlags.NO_SENSITIVITY|SettingsBindFlags.INVERT_BOOLEAN);
        rdp_settings.set_boolean("view-only", remoteControl_switch.state);

        service_switch.notify ["active"].connect (() => {
            set_service_state ();
        });

        vnc_settings.changed ["enable"].connect ((state) => {
            bool is_visible = vnc_settings.get_boolean(state)
            vnc_url_label.visible = is_visible;
            vnc_url_entry.visible = is_visible;
        });

        set_service_state ();
    }

    construct {

        try {
            client = new NM.Client ();
        } catch (Error e) {
            critical (e.message);
        }

        var useLegacyVNCMode_label = new Gtk.Label (_("Use Legacy VNC Mode"));
        ((Gtk.Misc) useLegacyVNCMode_label).xalign = 1.0f;

        var viewOnly_label = new Gtk.Label (_("Remote Control"));
        ((Gtk.Misc) viewOnly_label).xalign = 1.0f;

        var deviceName_label = new Gtk.Label (_("Device Name"));
        ((Gtk.Misc) deviceName_label).xalign = 1.0f;

        var rdp_url_label = new Gtk.Label (_("RDP URL"));
        ((Gtk.Misc) rdp_url_label).xalign = 1.0f;

        vnc_url_label = new Gtk.Label (_("VNC URL"));
        ((Gtk.Misc) vnc_url_label).xalign = 1.0f;

        var password_label = new Gtk.Label (_("Password"));
        ((Gtk.Misc) password_label).xalign = 1.0f;

        useLegacyVNCMode_switch = new Gtk.Switch();
        useLegacyVNCMode_switch.halign = Gtk.Align.START;
        useLegacyVNCMode_switch.state_set.connect ((state) => {
            vnc_url_label.visible = state;
            vnc_url_entry.visible = state;
            return false;
        });

        remoteControl_switch = new Gtk.Switch();
        remoteControl_switch.halign = Gtk.Align.START;

        deviceName_entry = new Gtk.Entry();
        deviceName_entry.halign = Gtk.Align.START;
        deviceName_entry.text = "rdp://"+client.hostname;

        vnc_url_entry = new Gtk.Entry();
        vnc_url_entry.halign = Gtk.Align.START;
        vnc_url_entry.text = "vnc://"+client.hostname+".local";
        vnc_url_entry.editable = false;


        rdp_url_entry = new Gtk.Entry();
        rdp_url_entry.halign = Gtk.Align.START;
        rdp_url_entry.text = "rdp://"+client.hostname+".local";
        rdp_url_entry.editable = false;

        password_entry = new Gtk.Entry();
        password_entry.halign = Gtk.Align.START;
        password_entry.text = client.hostname;
        password_entry.set_visibility (false);

        content_grid.attach (useLegacyVNCMode_label, 0, 0, 1, 1);
        content_grid.attach (useLegacyVNCMode_switch, 1, 0, 1, 1);
        content_grid.attach (viewOnly_label, 0, 1, 1, 1);
        content_grid.attach (remoteControl_switch, 1, 1, 1, 1);
        content_grid.attach (deviceName_label, 0, 2, 1, 1);
        content_grid.attach (deviceName_entry, 1, 2, 1, 1);
        content_grid.attach (vnc_url_label, 0, 3, 1, 1);
        content_grid.attach (vnc_url_entry, 1, 3, 1, 1);
        content_grid.attach (rdp_url_label, 0, 4, 1, 1);
        content_grid.attach (rdp_url_entry, 1, 4, 1, 1);
        content_grid.attach (password_label, 0, 5, 1, 1);
        content_grid.attach (password_entry, 1, 5, 1, 1);

        link_button.label = _("Network settings…");
        link_button.tooltip_text = _("Open Network settings");
        link_button.uri = "settings://network/network";
        link_button.no_show_all = false;
    }

    private void set_service_state () {
        if (rdp_settings.get_boolean ("enable")) {
            update_state (ServiceState.ENABLED);
        } else {
            update_state (ServiceState.DISABLED);
        }
    }
}
