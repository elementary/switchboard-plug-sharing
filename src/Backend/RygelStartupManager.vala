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

public class Sharing.Backend.RygelStartupManager : Object {
    private string autostart_directory;
    private string autostart_filename;

    construct {
        autostart_directory = Path.build_filename (Environment.get_user_config_dir (), "autostart");

        ensure_directory_exists (autostart_directory);

        autostart_filename = Path.build_filename (autostart_directory, "rygel.desktop");
    }

    public async void set_service_enabled (bool enable) {
        if (enable) {
            Bus.watch_name (BusType.SESSION,
                            RygelDBusInterface.SERVICE_NAME,
                            BusNameWatcherFlags.AUTO_START);
        } else {
            try {
                RygelDBusInterface dbus_interface = Bus.get_proxy_sync (BusType.SESSION,
                                                                        RygelDBusInterface.SERVICE_NAME,
                                                                        RygelDBusInterface.OBJECT_PATH,
                                                                        DBusProxyFlags.DO_NOT_LOAD_PROPERTIES);
                dbus_interface.shutdown ();
            } catch (Error e) {
                warning ("Shutting media server down failed: %s", e.message);
            }
        }

        set_autostart_enabled (enable);
    }

    public bool get_service_enabled () {
        if (File.new_for_path (autostart_filename).query_exists ()) {
            try {
                KeyFile autostart_file = open_autostart_file ();

                return autostart_file.get_boolean ("Desktop Entry", "X-GNOME-Autostart-enabled");
            } catch (Error e) {
                warning ("Reading autostart file %s failed: %s", autostart_filename, e.message);
            }
        }

        return false;
    }

    private void set_autostart_enabled (bool enable) {
        KeyFile autostart_file;

        try {
            if (File.new_for_path (autostart_filename).query_exists ()) {
                autostart_file = open_autostart_file ();
            } else {
                autostart_file = create_autostart_file ();
            }

            autostart_file.set_boolean ("Desktop Entry", "X-GNOME-Autostart-enabled", enable);

            autostart_file.save_to_file (autostart_filename);
        } catch (Error e) {
            warning ("Editing autostart file %s failed: %s", autostart_filename, e.message);
        }
    }

    private void ensure_directory_exists (string path) {
        File directory = File.new_for_path (path);

        try {
            directory.make_directory ();
        } catch (Error e) {
            /* That will most likely happen because the directory already exists. */
            debug ("Directory %s not created: %s", path, e.message);
        }
    }

    private KeyFile open_autostart_file () throws Error {
        KeyFile autostart_file = new KeyFile ();
        autostart_file.load_from_file (autostart_filename, KeyFileFlags.KEEP_COMMENTS | KeyFileFlags.KEEP_TRANSLATIONS);

        return autostart_file;
    }

    private KeyFile create_autostart_file () throws Error {
        KeyFile autostart_file = new KeyFile ();
        autostart_file.set_string ("Desktop Entry", "Name", "Rygel Server");
        autostart_file.set_string ("Desktop Entry", "Comment", "Starts the media server at user login");
        autostart_file.set_string ("Desktop Entry", "Exec", "rygel");
        autostart_file.set_string ("Desktop Entry", "Icon", "applications-multimedia");
        autostart_file.set_string ("Desktop Entry", "Type", "Application");
        autostart_file.set_boolean ("Desktop Entry", "NoDisplay", true);

        return autostart_file;
    }
}
