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

public class Sharing.Widgets.DLNAPage : SettingsPage {
    private Backend.RygelStartupManager rygel_startup_manager;

    private int content_grid_rows = 0;

    construct {
        rygel_startup_manager = new Backend.RygelStartupManager ();
    }

    public DLNAPage () {
        base ("dlna",
              _("Media Library"),
              "applications-multimedia",
              _("While enabled the following media libraries are shared to compatible devices in your network."),
              _("While disabled the selected media libraries aren't shared and it isn't possible to stream files from your harddrive to other devices."));

        build_ui ();
        read_state ();
        connect_signals ();
    }

    private void build_ui () {
        base.content_grid.set_size_request (500, -1);
        base.content_grid.margin_top = 100;

        add_media_entry ("music", _("Music"));
        add_media_entry ("videos", _("Videos"));
        add_media_entry ("pictures", _("Photos"));
    }

    private void read_state () {
        update_state (rygel_startup_manager.get_service_enabled () ? ServiceState.ENABLED : ServiceState.DISABLED);
    }

    private void connect_signals () {
        base.switch_state_changed.connect ((state) => {
            rygel_startup_manager.set_service_enabled.begin (state);

            update_state (state ? ServiceState.ENABLED : ServiceState.DISABLED);
        });
    }

    private void add_media_entry (string media_type_id, string media_type_name) {
        Gtk.Label entry_label = new Gtk.Label ("%s:".printf (media_type_name));
        entry_label.halign = Gtk.Align.END;

        Gtk.FileChooserButton entry_file_chooser = new Gtk.FileChooserButton (_("Select the folder containing your %s").printf (media_type_name), Gtk.FileChooserAction.SELECT_FOLDER);
        entry_file_chooser.hexpand = true;
        entry_file_chooser.sensitive = false;

        Gtk.Switch entry_switch = new Gtk.Switch ();
        entry_switch.state_set.connect ((state) => {
            entry_file_chooser.set_sensitive (state);

            return false;
        });

        base.content_grid.attach (entry_label, 0, content_grid_rows, 1, 1);
        base.content_grid.attach (entry_file_chooser, 1, content_grid_rows, 1, 1);
        base.content_grid.attach (entry_switch, 2, content_grid_rows, 1, 1);

        content_grid_rows++;
    }
}