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

public class Sharing.Backend.RygelConfigFile : Object {
    private string config_filename;
    private KeyFile? config_file = null;

    private string[] media_uris;

    construct {
        config_filename = Path.build_filename (Environment.get_user_config_dir (), "rygel.conf");

        try {
            config_file = new KeyFile ();
            config_file.load_from_file (config_filename, KeyFileFlags.KEEP_COMMENTS | KeyFileFlags.KEEP_TRANSLATIONS);

            media_uris = config_file.get_string_list ("MediaExport", "uris");
        } catch (Error e) {
            warning ("Reading configuration file %s failed: %s", config_filename, e.message);

            config_file = null;
        }
    }

    public bool get_media_type_enabled (string media_type_id) {
        if (config_file == null) {
            return false;
        }

        try {
            return config_file.get_boolean ("Tracker", "share-%s".printf (media_type_id));
        } catch (Error e) {
            warning ("Reading configuration file failed: %s", e.message);

            return false;
        }
    }

    public string get_media_type_folder (string media_type_id) {
        switch (media_type_id) {
            case "music" :

                return (media_uris.length > 0 ? media_uris[0] : "");

            case "videos":

                return (media_uris.length > 1 ? media_uris[1] : "");

            case "pictures":

                return (media_uris.length > 2 ? media_uris[2] : "");

            default:

                return "";
        }
    }

    public void set_media_type_enabled (string media_type_id, bool enable) {
        if (config_file == null) {
            return;
        }

        config_file.set_boolean ("Tracker", "share-%s".printf (media_type_id), enable);
    }

    public void set_media_type_folder (string media_type_id, string folder_path) {
        media_uris = {
            media_type_id == "music" ? folder_path : get_media_type_folder ("music"),
            media_type_id == "videos" ? folder_path : get_media_type_folder ("videos"),
            media_type_id == "pictures" ? folder_path : get_media_type_folder ("pictures")
        };

        if (config_file == null) {
            return;
        }

        config_file.set_string_list ("MediaExport", "uris", media_uris);
    }

    public void save () {
        if (config_file == null) {
            warning ("The loaded configuration file %s wasn't valid. Saving isn't allowed to prevent overwriting a broken rygel.conf.", config_filename);

            return;
        }

        try {
            config_file.save_to_file (config_filename);
        } catch (Error e) {
            warning ("Saving configuration file %s failed: %s", config_filename, e.message);
        }
    }
}