/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2016-2025 elementary, Inc. (https://elementary.io)
 */

public class Sharing.Widgets.NetworkAlertView : Gtk.Box {
    public NetworkAlertView () {
    }

    construct {
        margin_top = 12;
        margin_end = 12;
        margin_start = 12;
        margin_bottom = 12;
        orientation = Gtk.Orientation.VERTICAL;

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

        append (network_alert_view);
        append (link_button);
    }
}
