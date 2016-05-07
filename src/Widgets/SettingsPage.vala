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
    protected Granite.Widgets.AlertView alert_view;
    protected Gtk.Grid options_grid;

    private ServiceEntry? service_entry = null;

    private Gtk.Image service_icon;
    private Gtk.Label title_label;
    private Gtk.Label subtitle_label;
    public Gtk.LinkButton link_button;
    private Gtk.Stack service_stack;
    public Gtk.Switch service_switch;

    protected signal void switch_state_changed (bool state);

    public SettingsPage (string id, string title, string icon_name, string enabled_description, string disabled_description) {
        Object (id : id,
                title: title,
                icon_name: icon_name,
                enabled_description: enabled_description,
                disabled_description: disabled_description);

        service_switch.state_set.connect ((state) => {
            switch_state_changed (state);
            return false;
        });
    }

    construct {
        margin = 24;

        service_icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DIALOG);
        service_icon.valign = Gtk.Align.START;

        title_label = new Gtk.Label (title);
        title_label.get_style_context ().add_class (Granite.StyleClass.H2_TEXT);
        title_label.halign = Gtk.Align.START;
        title_label.hexpand = true;

        subtitle_label = new Gtk.Label (disabled_description);
        subtitle_label.justify = Gtk.Justification.LEFT;
        ((Gtk.Misc)subtitle_label).xalign = 0;
        subtitle_label.wrap = true;

        service_switch = new Gtk.Switch ();
        service_switch.halign = Gtk.Align.END;
        service_switch.valign = Gtk.Align.CENTER;

        content_grid = new Gtk.Grid ();
        content_grid.column_spacing = 12;
        content_grid.row_spacing = 12;
        content_grid.halign = Gtk.Align.CENTER;
        content_grid.sensitive = false;
        content_grid.set_size_request (500, -1);
        content_grid.margin_top = 100;

        alert_view = new Granite.Widgets.AlertView ("", "", "");
        alert_view.get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);
        alert_view.show_all ();

        link_button = new Gtk.LinkButton ("");
        link_button.halign = Gtk.Align.END;
        link_button.valign = Gtk.Align.END;
        link_button.vexpand = true;
        link_button.no_show_all = true;

        options_grid = new Gtk.Grid ();
        options_grid.column_spacing = 12;
        options_grid.row_spacing = 6;
        options_grid.attach (service_icon, 0, 0, 1, 2);
        options_grid.attach (title_label, 1, 0, 1, 1);
        options_grid.attach (subtitle_label, 1, 1, 1, 1);
        options_grid.attach (service_switch, 2, 0, 1, 2);
        options_grid.attach (content_grid, 0, 2, 3, 1);
        options_grid.show_all ();

        service_stack = new Gtk.Stack ();
        service_stack.add (alert_view);
        service_stack.add (options_grid);

        attach (service_stack, 0, 0, 1, 1);
        attach (link_button, 0, 1, 1, 1);
    }

    public ServiceEntry get_service_entry () {
        if (service_entry == null) {
            service_entry = new ServiceEntry (id, title, icon_name, service_state);
        }

        return service_entry;
    }

    protected void update_state (ServiceState state) {
        if (state == ServiceState.NOT_AVAILABLE) {
            service_stack.visible_child = alert_view;
        } else {
            service_stack.visible_child = options_grid;
            subtitle_label.set_label (state == ServiceState.DISABLED ? disabled_description : enabled_description);
            service_switch.set_active (state != ServiceState.DISABLED);
            content_grid.set_sensitive (state != ServiceState.DISABLED);
        }

        if (service_entry != null) {
            service_entry.update_state (state);
        }

        service_state = state;
    }
}
