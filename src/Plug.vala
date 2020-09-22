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
    private Gtk.Paned? main_container = null;

    public Plug () {
        var settings = new Gee.TreeMap<string, string?> (null, null);
        settings.set ("network/share", null);
        Object (category : Category.NETWORK,
                code_name: "io.elementary.switchboard.sharing",
                display_name: _("Sharing"),
                description: _("Configure file and media sharing"),
                icon: "preferences-system-sharing",
                supported_settings: settings);
    }

    public override Gtk.Widget get_widget () {
        if (main_container == null) {
            var sidebar = new Widgets.Sidebar ();
            var settings_view = new Widgets.SettingsView ();

            foreach (Widgets.SettingsPage settings_page in settings_view.get_settings_pages ()) {
                sidebar.add_service_entry (settings_page.get_service_entry ());
            }

            main_container = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            main_container.pack1 (sidebar, false, false);
            main_container.pack2 (settings_view, true, false);
            main_container.show_all ();
            sidebar.selected_service_changed.connect (settings_view.show_service_settings);
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
        var search_results = new Gee.TreeMap<string, string> ((GLib.CompareDataFunc<string>)strcmp, (Gee.EqualDataFunc<string>)str_equal);
        search_results.set ("%s → %s".printf (display_name, _("Media library")), "");
        return search_results;
    }
}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating Sharing plug");

    var plug = new Sharing.Plug ();

    return plug;
}
