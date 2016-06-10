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

public class Sharing.Plug : Switchboard.Plug {
    private Gtk.Paned? main_container = null;

    private Widgets.Sidebar sidebar;
    private Widgets.SettingsView settings_view;
    private Gtk.Stack content;
    private Gtk.LinkButton link_button;

    public Plug () {
        Object (category : Category.NETWORK,
                code_name: "pantheon-sharing",
                display_name: _("Sharing"),
                description: _("Configure file and media sharing"),
                icon: "preferences-system-sharing");
    }

    public override Gtk.Widget get_widget () {
        if (main_container == null) {
            build_ui ();
            connect_signals ();
            update_content_view ();
        }

        return main_container;
    }

    public override void shown () {
    }

    public override void hidden () {
    }

    public override void search_callback (string location) {
    }

    /* 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior") */
    public override async Gee.TreeMap<string, string> search (string search) {
        return new Gee.TreeMap<string, string> (null, null);
    }

    private void build_ui () {
        main_container = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);

        sidebar = new Widgets.Sidebar ();
        settings_view = new Widgets.SettingsView ();

        var network_alert_view = new Granite.Widgets.AlertView (_("Network Is Not Available"),
                                                                _("While network is not available you cannot use any sharing services."),
                                                                "network-error");
        network_alert_view.get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);

        link_button = new Gtk.LinkButton (_("Network settings…"));
        link_button.halign = Gtk.Align.END;
        link_button.valign = Gtk.Align.END;
        link_button.vexpand = true;

        var network_grid_view = new Gtk.Grid ();
        network_grid_view.margin = 24;
        network_grid_view.attach (network_alert_view, 0, 0, 1, 1);
        network_grid_view.attach (link_button, 0, 1, 1, 1);

        content = new Gtk.Stack ();
        content.add_named (settings_view, "settings-view");
        content.add_named (network_grid_view, "network-alert-view");

        foreach (Widgets.SettingsPage settings_page in settings_view.get_settings_pages ()) {
            sidebar.add_service_entry (settings_page.get_service_entry ());
        }

        main_container.pack1 (sidebar, false, false);
        main_container.pack2 (content, true, false);
        main_container.show_all ();
    }

    private void connect_signals () {
        NetworkMonitor.get_default ().network_changed.connect (() => update_content_view ());
        sidebar.selected_service_changed.connect (settings_view.show_service_settings);

        link_button.activate_link.connect (() => {
            var list = new List<string> ();
            list.append ("network");

            try {
                var appinfo = AppInfo.create_from_commandline ("switchboard", null, AppInfoCreateFlags.SUPPORTS_URIS);
                appinfo.launch_uris (list, null);
            } catch (Error e) {
                warning (e.message);
            }

            return true;
        });        
    }

    private void update_content_view () {
        if (NetworkMonitor.get_default ().get_network_available ()) {
            content.visible_child_name = "settings-view";
        } else {
            content.visible_child_name = "network-alert-view";
        }
    }
}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating Sharing plug");

    var plug = new Sharing.Plug ();

    return plug;
}
