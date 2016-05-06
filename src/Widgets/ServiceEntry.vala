/*
 * Copyright (c) 2011-2015 elementary Developers (https://launchpad.net/elementary)
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

public class Sharing.Widgets.ServiceEntry : Gtk.ListBoxRow {
    private static string state_to_string (SettingsPage.ServiceState service_state) {
        switch (service_state) {
            case SettingsPage.ServiceState.ENABLED: return _("Enabled");
            case SettingsPage.ServiceState.NOT_AVAILABLE: return _("Not Available");
            case SettingsPage.ServiceState.CONNECTED: return _("Connected");
            default: case SettingsPage.ServiceState.DISABLED: return _("Disabled");
        }
    }

    private static string state_to_icon_name (SettingsPage.ServiceState service_state) {
        switch (service_state) {
            case SettingsPage.ServiceState.ENABLED: return "user-available";
            case SettingsPage.ServiceState.NOT_AVAILABLE: return "user-busy";
            case SettingsPage.ServiceState.CONNECTED: return "mail-unread";
            default: case SettingsPage.ServiceState.DISABLED: return "user-offline";
        }
    }

    public string id { get; construct; }
    public string title { get; construct; }
    public string icon_name { get; construct; }
    public SettingsPage.ServiceState service_state { get; protected set construct; }

    private Gtk.Grid grid;

    private Gtk.Overlay overlay_icon;

    private Gtk.Image primary_icon;
    private Gtk.Image secondary_icon;

    private Gtk.Label title_label;
    private Gtk.Label subtitle_label;

    public ServiceEntry (string id, string title, string icon_name, SettingsPage.ServiceState service_state) {
        Object (id: id, title: title, icon_name: icon_name, service_state: service_state);

        build_ui ();
    }

    public void update_state (SettingsPage.ServiceState state) {
        secondary_icon.set_from_icon_name (state_to_icon_name (state), Gtk.IconSize.MENU);
        subtitle_label.set_label (state_to_string (state));

        service_state = state;
    }

    private void build_ui () {
        grid = new Gtk.Grid ();
        grid.margin = 6;
        grid.column_spacing = 3;

        overlay_icon = new Gtk.Overlay ();

        primary_icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DND);

        secondary_icon = new Gtk.Image.from_icon_name (state_to_icon_name (service_state), Gtk.IconSize.MENU);
        secondary_icon.halign = Gtk.Align.END;
        secondary_icon.valign = Gtk.Align.END;
        ((Gtk.Misc)secondary_icon).xalign = 0.5f;
        ((Gtk.Misc)secondary_icon).yalign = 0.5f;

        overlay_icon.add (primary_icon);
        overlay_icon.add_overlay (secondary_icon);

        title_label = new Gtk.Label (title);
        title_label.get_style_context ().add_class (Granite.StyleClass.H3_TEXT);
        title_label.halign = Gtk.Align.START;
        title_label.ellipsize = Pango.EllipsizeMode.END;

        subtitle_label = new Gtk.Label (state_to_string (service_state));
        subtitle_label.halign = Gtk.Align.START;

        grid.attach (overlay_icon, 0, 0, 1, 2);
        grid.attach (title_label, 1, 0, 1, 1);
        grid.attach (subtitle_label, 1, 1, 1, 1);

        this.add (grid);
    }
}
