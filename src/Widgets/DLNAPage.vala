/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2016-2023 elementary, Inc. (https://elementary.io)
 */

public class Sharing.Widgets.DLNAPage : Granite.SimpleSettingsPage {
    private Backend.RygelStartupManager rygel_startup_manager;
    private Backend.RygelConfigFile rygel_config_file;

    private int content_area_rows = 0;

    public DLNAPage () {
        Object (
            activatable: true,
            description: ""
        );
    }

    construct {
        title = _("Media Library");
        icon_name = "applications-multimedia";

        rygel_startup_manager = new Backend.RygelStartupManager ();
        rygel_config_file = new Backend.RygelConfigFile ();

        add_media_entry ("music", _("Music"));
        add_media_entry ("videos", _("Videos"));
        add_media_entry ("pictures", _("Photos"));

        set_service_state ();

        status_switch.notify["active"].connect (() => {
            set_service_state ();
        });
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

        content_area.attach (entry_label, 0, content_area_rows, 1, 1);
        content_area.attach (entry_file_chooser, 1, content_area_rows, 1, 1);
        content_area.attach (entry_switch, 2, content_area_rows, 1, 1);

        content_area_rows++;
    }

    private void set_service_state () {
        /* Make sure the configuration file exists */
        if (rygel_config_file.save ()) {
            rygel_startup_manager.set_service_enabled.begin (status_switch.active);

        }

        if (status_switch.active) {
            description = _("While enabled, the following media libraries are shared to compatible devices in your network.");
            status = _("Enabled");
            status_type = SUCCESS;
        } else {
            description = _("While disabled, the selected media libraries are unshared, and it won't stream files from your computer to other devices.");
            status = _("Disabled");
            status_type = OFFLINE;
        }
    }
}
