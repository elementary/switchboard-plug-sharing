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
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 */

public class Sharing.Backend.RygelConfigFile : Object {
    private string config_filename;
    private KeyFile? config_file = null;

    private string[] media_uris;

    construct {
        config_filename = Path.build_filename (Environment.get_user_config_dir (), "rygel.conf");
        config_file = new KeyFile ();

        if (File.new_for_path (config_filename).query_exists ()) {
            try {
                config_file.load_from_file (config_filename, KeyFileFlags.KEEP_COMMENTS | KeyFileFlags.KEEP_TRANSLATIONS);
            } catch (Error e) {
                warning ("Loading configuration file %s failed: %s", config_filename, e.message);

                config_file = null;

                return;
            }
        } else {
            debug ("Setting up new rygel.conf…");

            setup_config_file ();
        }

        try {
            media_uris = config_file.get_string_list ("MediaExport", "uris");
        } catch (Error e) {
            warning ("Reading configuration file %s failed: %s", config_filename, e.message);

            config_file = null;

            return;
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

    public bool save () {
        if (config_file == null) {
            warning ("The loaded configuration file %s wasn't valid. Saving isn't allowed to prevent overwriting a broken rygel.conf.", config_filename);

            return false;
        }

        try {
            config_file.save_to_file (config_filename);
        } catch (Error e) {
            warning ("Saving configuration file %s failed: %s", config_filename, e.message);

            return false;
        }

        return true;
    }

    private void setup_config_file () {
        config_file.set_boolean ("general", "upnp-enabled", true);
        config_file.set_boolean ("general", "enable-transcoding", true);
        config_file.set_string ("general", "video-upload-folder", "@VIDEOS@");
        config_file.set_string ("general", "music-upload-folder", "@MUSIC@");
        config_file.set_string ("general", "picture-upload-folder", "@PICTURES@");
        config_file.set_string ("general", "media-engine", "librygel-media-engine-gst.so");
        config_file.set_string ("general", "interface", "");
        config_file.set_integer ("general", "port", 0);
        config_file.set_string ("general", "log-level", "*:4");
        config_file.set_boolean ("general", "allow-upload", true);
        config_file.set_boolean ("general", "allow-deletion", true);

        config_file.set_string_list ("GstMediaEngine", "transcoders", { "mp3", "lpcm", "mp2ts", "wmv", "aac", "avc" });

        config_file.set_integer ("Renderer", "image-timeout", 15);

        config_file.set_boolean ("Tracker", "enabled", true);
        config_file.set_boolean ("Tracker", "share-pictures", true);
        config_file.set_boolean ("Tracker", "share-videos", true);
        config_file.set_boolean ("Tracker", "share-music", true);
        config_file.set_boolean ("Tracker", "strict-sharing", false);
        config_file.set_string ("Tracker", "title", "@HOSTNAME@: @REALNAME@");

        config_file.set_boolean ("MediaExport", "enabled", true);
        config_file.set_string ("MediaExport", "title", "@HOSTNAME@: @REALNAME@");
        config_file.set_string_list ("MediaExport", "uris", { "@MUSIC@", "@VIDEOS@", "@PICTURES@" });
        config_file.set_boolean ("MediaExport", "extract-metadata", true);
        config_file.set_boolean ("MediaExport", "monitor-changes", true);
        config_file.set_integer ("MediaExport", "monitor-grace-timeout", 5);
        config_file.set_boolean ("MediaExport", "virtual-folders", true);

        config_file.set_boolean ("Playbin", "enabled", true);
        config_file.set_string ("Playbin", "title", "Audio/Video playback on @HOSTNAME@");
    }
}
