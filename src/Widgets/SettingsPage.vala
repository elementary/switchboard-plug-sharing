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

public abstract class Sharing.Widgets.SettingsPage : Gtk.Grid {
    public enum ServiceState {
        ENABLED,
        NOT_AVAILABLE,
        CONNECTED,
        DISABLED
    }

    public string id { get; construct; }
    public string title { get; construct; }
    public string icon_name { get; construct; }
    public ServiceState service_state { get; private set; default = ServiceState.DISABLED; }

    private ServiceEntry? service_entry = null;

    private Gtk.Image service_icon;
    private Gtk.Label title_label;

    public SettingsPage (string id, string title, string icon_name) {
        Object (id : id, title: title, icon_name: icon_name);

        build_ui ();
    }

    public ServiceEntry get_service_entry () {
        if (service_entry == null) {
            service_entry = new ServiceEntry (id, title, icon_name, service_state);
        }

        return service_entry;
    }

    protected void update_state (ServiceState state) {
        service_state = state;

        if (service_entry != null) {
            service_entry.update_state (state);
        }
    }

    private void build_ui () {
        this.margin = 24;
        this.column_spacing = 12;
        this.row_spacing = 12;

        service_icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DIALOG);

        title_label = new Gtk.Label (title);
        title_label.get_style_context ().add_class (Granite.StyleClass.H2_TEXT);
        title_label.halign = Gtk.Align.START;

        this.attach (service_icon, 0, 0, 1, 1);
        this.attach (title_label, 1, 0, 1, 1);
    }
}