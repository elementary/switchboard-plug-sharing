/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2016-2025 elementary, Inc. (https://elementary.io)
 */

public class Sharing.Widgets.NetworkAlertView : Adw.Bin {
    public NetworkAlertView () {
    }

    construct {
        var network_alert_view = new Granite.Placeholder (
            _("Network Is Not Available")
        ) {
            icon = new ThemedIcon ("network-error"),
            description = _("While disconnected from the network, sharing services are not available."),
            vexpand = true,
            hexpand = true
        };
        network_alert_view.remove_css_class (Granite.STYLE_CLASS_VIEW);

        var link_button = new Gtk.LinkButton.with_label ("settings://network", _("Network settings…")) {
            halign = Gtk.Align.END,
            valign = Gtk.Align.END
        };

        var content_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            margin_top = 12,
            margin_end = 12,
            margin_start = 12,
            margin_bottom = 12
        };
        content_box.append (network_alert_view);
        content_box.append (link_button);

        var headerbar = new Adw.HeaderBar () {
            show_title = false
        };

        var toolbarview = new Adw.ToolbarView () {
            content = content_box,
            top_bar_style = FLAT
        };
        toolbarview.add_top_bar (headerbar);

        child = toolbarview;
    }
}
