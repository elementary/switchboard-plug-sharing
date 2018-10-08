/*
 * Copyright (c) 2011-2017 elementary LLC. (https://elementary.io)
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
 * Boston, MA 02110-1301 USA
 */

public class Sharing.Plug : Switchboard.Plug {
    private Gtk.Stack? content = null;

    public Plug () {
        var settings = new Gee.TreeMap<string, string?> (null, null);
        settings.set ("network/share", null);
        Object (category : Category.NETWORK,
                code_name: "pantheon-sharing",
                display_name: _("Sharing"),
                description: _("Configure file and media sharing"),
                icon: "preferences-system-sharing",
                supported_settings: settings);
    }

    public override Gtk.Widget get_widget () {
        if (content == null) {
            build_ui ();
            update_content_view ();
        }

        return content;
    }

    public override void shown () {
    }

    public override void hidden () {
    }

    public override void search_callback (string location) {
    }

    /* 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior") */
    public override async Gee.TreeMap<string, string> search (string search) {
        var search_results = new Gee.TreeMap<string, string> ((GLib.CompareDataFunc<string>)strcmp, (Gee.EqualDataFunc<string>)str_equal);
        search_results.set ("%s → %s".printf (display_name, _("Media library")), "");
        return search_results;
    }

    private void build_ui () {
        var network_alert_view = new Granite.Widgets.AlertView (_("Network Is Not Available"),
                                                                _("While disconnected from the network, sharing services are not available."),
                                                                "network-error");
        network_alert_view.get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);

        var link_button = new Gtk.LinkButton (_("Network settings…"));
        link_button.halign = Gtk.Align.END;
        link_button.valign = Gtk.Align.END;
        link_button.vexpand = true;

        var network_grid_view = new Gtk.Grid ();
        network_grid_view.margin = 24;
        network_grid_view.attach (network_alert_view, 0, 0, 1, 1);
        network_grid_view.attach (link_button, 0, 1, 1, 1);

        var sidebar = new Widgets.Sidebar ();
        var settings_view = new Widgets.SettingsView ();

        foreach (Widgets.SettingsPage settings_page in settings_view.get_settings_pages ()) {
            sidebar.add_service_entry (settings_page.get_service_entry ());
        }

        var main_container = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        main_container.pack1 (sidebar, false, false);
        main_container.pack2 (settings_view, true, false);

        content = new Gtk.Stack ();
        content.add_named (main_container, "main-container");
        content.add_named (network_grid_view, "network-alert-view");
        content.show_all ();

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
        if (NetworkMonitor.get_default ().get_network_available () || NetworkMonitor.get_default ().get_network_metered ()) {
            content.visible_child_name = "main-container";
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
