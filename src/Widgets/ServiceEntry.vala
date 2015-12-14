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

public class Sharing.Widgets.ServiceEntry : Gtk.Grid {
    private static string state_to_string (ServiceState service_state) {
        switch (service_state) {
            case ServiceState.ENABLED: return _("Enabled");
            case ServiceState.NOT_AVAILABLE: return _("NOT_AVAILABLE");
            case ServiceState.CONNECTED: return _("CONNECTED");
            default: case ServiceState.DISABLED: return _("Disabled");
        }
    }

    private static string state_to_icon_name (ServiceState service_state) {
        switch (service_state) {
            case ServiceState.ENABLED: return "user-idle";
            case ServiceState.NOT_AVAILABLE: return "user-offline";
            case ServiceState.CONNECTED: return "user-available";
            default: case ServiceState.DISABLED: return "user-busy";
        }
    }

    public enum ServiceState {
        ENABLED,
        NOT_AVAILABLE,
        CONNECTED,
        DISABLED
    }

    public string title { private get; construct; }
    public string icon_name { private get; construct; }
    public ServiceState service_state { private get; construct; }

    private Gtk.Overlay overlay_icon;

    private Gtk.Image primary_icon;
    private Gtk.Image secondary_icon;

    private Gtk.Label title_label;
    private Gtk.Label subtitle_label;

    public ServiceEntry (string title, string icon_name, ServiceState service_state = ServiceState.DISABLED) {
        Object (title: title, icon_name: icon_name, service_state: service_state);

        build_ui ();
    }

    private void build_ui () {
        this.margin = 6;
        this.column_spacing = 3;

        overlay_icon = new Gtk.Overlay ();

        primary_icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DND);

        secondary_icon = new Gtk.Image.from_icon_name (state_to_icon_name (service_state), Gtk.IconSize.MENU);
        secondary_icon.halign = Gtk.Align.END;
        secondary_icon.valign = Gtk.Align.END;

        overlay_icon.add (primary_icon);
        overlay_icon.add_overlay (secondary_icon);

        title_label = new Gtk.Label (title);
        title_label.get_style_context ().add_class (Granite.StyleClass.H3_TEXT);
        title_label.halign = Gtk.Align.START;
        title_label.ellipsize = Pango.EllipsizeMode.END;

        subtitle_label = new Gtk.Label (state_to_string (service_state));
        subtitle_label.halign = Gtk.Align.START;

        this.attach (overlay_icon, 0, 0, 1, 2);
        this.attach (title_label, 1, 0, 1, 1);
        this.attach (subtitle_label, 1, 1, 1, 1);
    }
}