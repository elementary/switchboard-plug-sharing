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
    public string enabled_description { get; construct; }
    public string disabled_description { get; construct; }
    public ServiceState service_state { get; private set; default = ServiceState.DISABLED; }

    protected Gtk.Grid content_grid;

    private ServiceEntry? service_entry = null;

    private Gtk.Image service_icon;
    private Gtk.Label title_label;
    private Gtk.Label subtitle_label;
    private Gtk.Switch service_switch;

    protected signal void switch_state_changed (bool state);

    public SettingsPage (string id, string title, string icon_name, string enabled_description, string disabled_description) {
        Object (id : id,
                title: title,
                icon_name: icon_name,
                enabled_description: enabled_description,
                disabled_description: disabled_description);

        build_ui ();
        connect_signals ();
    }

    public ServiceEntry get_service_entry () {
        if (service_entry == null) {
            service_entry = new ServiceEntry (id, title, icon_name, service_state);
        }

        return service_entry;
    }

    protected void update_state (ServiceState state) {
        subtitle_label.set_label (state == ServiceState.DISABLED ? disabled_description : enabled_description);
        service_switch.set_active (state != ServiceState.DISABLED);
        content_grid.set_sensitive (state != ServiceState.DISABLED);

        if (service_entry != null) {
            service_entry.update_state (state);
        }

        service_state = state;
    }

    private void build_ui () {
        this.margin = 24;
        this.column_spacing = 12;
        this.row_spacing = 6;

        service_icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DIALOG);

        title_label = new Gtk.Label (title);
        title_label.get_style_context ().add_class (Granite.StyleClass.H2_TEXT);
        title_label.halign = Gtk.Align.START;
        title_label.hexpand = true;

        subtitle_label = new Gtk.Label (disabled_description);
        subtitle_label.justify = Gtk.Justification.FILL;
        subtitle_label.halign = Gtk.Align.START;
        subtitle_label.wrap = true;

        service_switch = new Gtk.Switch ();
        service_switch.halign = Gtk.Align.END;
        service_switch.valign = Gtk.Align.CENTER;

        content_grid = new Gtk.Grid ();
        content_grid.column_spacing = 12;
        content_grid.row_spacing = 12;
        content_grid.halign = Gtk.Align.CENTER;
        content_grid.sensitive = false;

        this.attach (service_icon, 0, 0, 1, 2);
        this.attach (title_label, 1, 0, 1, 1);
        this.attach (subtitle_label, 1, 1, 1, 1);
        this.attach (service_switch, 2, 0, 1, 2);
        this.attach (content_grid, 0, 2, 3, 1);
    }

    private void connect_signals () {
        service_switch.state_set.connect ((state) => {
            switch_state_changed (state);

            return false;
        });
    }
}