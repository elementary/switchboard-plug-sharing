/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2016-2023 elementary, Inc. (https://elementary.io)
 */

public class Sharing.Widgets.DLNAPage : Switchboard.SettingsPage {
    private Backend.RygelStartupManager rygel_startup_manager;
    private Backend.RygelConfigFile rygel_config_file;

    public DLNAPage () {
        Object (activatable: true);
    }

    construct {
        title = _("Media Streaming");
        icon = new ThemedIcon ("applications-multimedia");
        show_end_title_buttons = true;

        rygel_startup_manager = new Backend.RygelStartupManager ();
        rygel_config_file = new Backend.RygelConfigFile ();

        var music_entry = new MediaEntry ("music", _("Music Folder"), rygel_config_file);
        var videos_entry = new MediaEntry ("videos", _("Videos Folder"), rygel_config_file);
        var pictures_entry = new MediaEntry ("pictures", _("Pictures Folder"), rygel_config_file);

        var box = new Gtk.Box (VERTICAL, 24);
        box.append (music_entry);
        box.append (videos_entry);
        box.append (pictures_entry);

        child = box;

        status_switch.active = rygel_startup_manager.get_service_enabled ();
        set_service_state ();

        status_switch.notify["active"].connect (() => {
            /* Make sure the configuration file exists */
            if (rygel_config_file.save ()) {
                rygel_startup_manager.set_service_enabled.begin (status_switch.active);
            }

            set_service_state ();
        });
    }

    private void set_service_state () {
        if (status_switch.active) {
            description = _("The selected libraries are available to stream on compatible DLNA-enabled devices on your local network such as TVs and game consoles.");
            status = _("Enabled");
            status_type = SUCCESS;
        } else {
            description = _("Media libraries are unshared and can't be streamed to other devices.");
            status = _("Disabled");
            status_type = OFFLINE;
        }
    }

    private class MediaEntry : Gtk.Grid {
        public string label { get; construct; }
        public string media_type { get; construct; }
        public unowned Backend.RygelConfigFile config_file { get; construct; }

        private Gtk.Label folder_name;

        public MediaEntry (string media_type, string label, Backend.RygelConfigFile config_file) {
            Object (
                config_file: config_file,
                media_type: media_type,
                label: label
            );
        }

        construct {
            var folder_dir = replace_xdg_folders (config_file.get_media_type_folder (media_type));

            var check = new Gtk.CheckButton () {
                active = config_file.get_media_type_enabled (media_type),
                valign = CENTER
            };

            var icon_name = "";
            switch (media_type) {
                case "music":
                    icon_name = "audio-x-generic";
                    break;
                case "pictures":
                    icon_name = "image-x-generic";
                    break;
                case "videos":
                    icon_name = "video-x-generic";
                    break;
            }

            var image = new Gtk.Image.from_icon_name (icon_name) {
                pixel_size = 32
            };
            image.set_parent (check);

            var header = new Granite.HeaderLabel (label);

            folder_name = new Gtk.Label ("") {
                halign = START,
                hexpand = true
            };

            var arrow = new Gtk.Image.from_icon_name ("view-more-horizontal-symbolic");

            var location_button_box = new Gtk.Box (HORIZONTAL, 3);
            location_button_box.append (folder_name);
            location_button_box.append (arrow);

            var location_button = new Gtk.Button () {
                child = location_button_box
            };

            var location_dialog = new Gtk.FileChooserNative (
                _("Select %s…").printf (label),
                ((Gtk.Application) Application.get_default ()).active_window,
                Gtk.FileChooserAction.SELECT_FOLDER,
                _("Select"),
                null
            );

            try {
                location_dialog.set_current_folder (File.new_for_path (folder_dir));
            } catch (Error e) {
                critical ("Couldn't set filechooser path: %s", e.message);
            }

            column_spacing = 6;
            row_spacing = 3;
            attach (check, 0, 0, 1, 2);
            attach (header, 1, 0);
            attach (location_button, 1, 1);

            check.bind_property ("active", image, "sensitive");

            check.toggled.connect (() => {
                config_file.set_media_type_enabled (media_type, check.active);
                config_file.save ();
            });

            location_button.clicked.connect (() => {
                location_dialog.show ();
            });

            folder_name.label = folder_dir;
            location_dialog.response.connect ((response) => {
                if (response == Gtk.ResponseType.ACCEPT) {
                    var file_path = location_dialog.get_file ().get_path ();
                    folder_name.label = file_path;

                    config_file.set_media_type_folder (media_type, file_path);
                    config_file.save ();
                }
            });
        }

        private string replace_xdg_folders (string folder_path) {
            switch (folder_path) {
                case "@MUSIC@": return Environment.get_user_special_dir (UserDirectory.MUSIC);
                case "@VIDEOS@": return Environment.get_user_special_dir (UserDirectory.VIDEOS);
                case "@PICTURES@": return Environment.get_user_special_dir (UserDirectory.PICTURES);
                default: return folder_path;
            }
        }
    }
}
