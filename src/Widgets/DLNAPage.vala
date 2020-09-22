/*
 * Copyright (c) 2016 elementary LLC (https://launchpad.net/switchboard-plug-sharing)
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

public class Sharing.Widgets.DLNAPage : SettingsPage {
    private Backend.RygelStartupManager rygel_startup_manager;
    private Backend.RygelConfigFile rygel_config_file;

    private int content_grid_rows = 0;

    public DLNAPage () {
        base ("dlna",
              _("Media Library"),
              "applications-multimedia",
              _("While enabled, the following media libraries are shared to compatible devices in your network."),
              _("While disabled, the selected media libraries are unshared, and it won't stream files from your computer to other devices."));
        switch_state_changed.connect ((state) => {
            /* Make sure the configuration file exists */
            if (rygel_config_file.save ()) {
                rygel_startup_manager.set_service_enabled.begin (state);

                update_state (state ? ServiceState.ENABLED : ServiceState.DISABLED);
            }
        });

        set_service_state ();
    }

    construct {
        rygel_startup_manager = new Backend.RygelStartupManager ();
        rygel_config_file = new Backend.RygelConfigFile ();

        alert_view.title = _("Network Is Not Available");
        alert_view.description = _("While disconnected from the network, sharing services are not available.");
        alert_view.icon_name = "network-error";

        add_media_entry ("music", _("Music"));
        add_media_entry ("videos", _("Videos"));
        add_media_entry ("pictures", _("Photos"));

        link_button.label = _("Network settings…");
        link_button.tooltip_text = _("Open Network settings");
        link_button.uri = "settings://network";
        link_button.no_show_all = true;

        NetworkMonitor.get_default ().network_changed.connect (set_service_state);
    }

    private static string replace_xdg_folders (string folder_path) {
        switch (folder_path) {
            case "@MUSIC@": return Environment.get_user_special_dir (UserDirectory.MUSIC);
            case "@VIDEOS@": return Environment.get_user_special_dir (UserDirectory.VIDEOS);
            case "@PICTURES@": return Environment.get_user_special_dir (UserDirectory.PICTURES);
            default: return folder_path;
        }
    }
    private void add_media_entry (string media_type_id, string media_type_name) {
        bool is_enabled = rygel_config_file.get_media_type_enabled (media_type_id);
        string folder_path = rygel_config_file.get_media_type_folder (media_type_id);

        var entry_label = new Gtk.Label ("%s:".printf (media_type_name));
        entry_label.halign = Gtk.Align.END;

        var entry_file_chooser = new Gtk.FileChooserButton (_("Select the folder containing your %s").printf (media_type_name), Gtk.FileChooserAction.SELECT_FOLDER);
        entry_file_chooser.hexpand = true;
        entry_file_chooser.sensitive = is_enabled;
        entry_file_chooser.file_set.connect (() => {
            rygel_config_file.set_media_type_folder (media_type_id, entry_file_chooser.get_file ().get_path ());
            rygel_config_file.save ();
        });

        try {
            if (folder_path != "") {
                entry_file_chooser.set_file (File.new_for_path (replace_xdg_folders (folder_path)));
            }
        } catch (Error e) {
            warning ("The folder path %s is invalid: %s", folder_path, e.message);
        }

        var entry_switch = new Gtk.Switch ();
        entry_switch.valign = Gtk.Align.CENTER;
        entry_switch.state = is_enabled;
        entry_switch.state_set.connect ((state) => {
            entry_file_chooser.set_sensitive (state);

            rygel_config_file.set_media_type_enabled (media_type_id, state);
            rygel_config_file.save ();

            return false;
        });

        content_grid.attach (entry_label, 0, content_grid_rows, 1, 1);
        content_grid.attach (entry_file_chooser, 1, content_grid_rows, 1, 1);
        content_grid.attach (entry_switch, 2, content_grid_rows, 1, 1);
        content_grid_rows++;
    }

    private void set_service_state () {
        if (NetworkMonitor.get_default ().get_network_available () || NetworkMonitor.get_default ().get_network_metered ()) {
            update_state (rygel_startup_manager.get_service_enabled () ? ServiceState.ENABLED : ServiceState.DISABLED);
            link_button.visible = false;
        } else {
            update_state (ServiceState.NOT_AVAILABLE);
            link_button.visible = true;
        }
    }

}
