/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2016-2025 elementary, Inc. (https://elementary.io)
 */

public class Sharing.Widgets.NetworkAlertView : Gtk.Box {
    public NetworkAlertView () {
    }

    construct {
        var network_alert_view = new Granite.Placeholder (
            _("Network Is Not Available")
        ) {
            icon = new ThemedIcon ("network-error"),
            description = _("While disconnected from the network, sharing services are not available.")
        };
        network_alert_view.remove_css_class (Granite.STYLE_CLASS_VIEW);

        var link_button = new Gtk.LinkButton.with_label ("settings://network", _("Network settings…"));
        link_button.halign = Gtk.Align.END;
        link_button.valign = Gtk.Align.END;
        link_button.vexpand = true;

        var network_grid_view = new Gtk.Grid () {
            margin_top = 12,
            margin_end = 12,
            margin_start = 12,
            margin_bottom = 12
        };
        network_grid_view.attach (network_alert_view, 0, 0, 1, 1);
        network_grid_view.attach (link_button, 0, 1, 1, 1);

        append (network_grid_view);
    }
}
