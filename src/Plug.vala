/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2011-2023 elementary, Inc. (https://elementary.io)
 */

public class Sharing.Plug : Switchboard.Plug {
    private Gtk.Stack? content = null;

    public Plug () {
        GLib.Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        GLib.Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");

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
        if (content == null) {
            var network_alert_view = new Granite.Widgets.AlertView (
                _("Network Is Not Available"),
                _("While disconnected from the network, sharing services are not available."),
                "network-error"
            );
            network_alert_view.get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);

            var link_button = new Gtk.LinkButton.with_label ("settings://network", _("Network settings…"));
            link_button.halign = Gtk.Align.END;
            link_button.valign = Gtk.Align.END;
            link_button.vexpand = true;

            var network_grid_view = new Gtk.Grid ();
            network_grid_view.margin = 24;
            network_grid_view.attach (network_alert_view, 0, 0, 1, 1);
            network_grid_view.attach (link_button, 0, 1, 1, 1);

            var dlna_page = new Widgets.DLNAPage ();
            var bluetooth_page = new Widgets.BluetoothPage ();

            var settings_view = new Gtk.Stack ();
            settings_view.add (dlna_page);
            settings_view.add (bluetooth_page);

            var sidebar = new Granite.SettingsSidebar (settings_view);

            var main_container = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            main_container.pack1 (sidebar, false, false);
            main_container.pack2 (settings_view, true, false);

            content = new Gtk.Stack ();
            content.add_named (main_container, "main-container");
            content.add_named (network_grid_view, "network-alert-view");
            content.show_all ();

            NetworkMonitor.get_default ().network_changed.connect (() => update_content_view ());

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
