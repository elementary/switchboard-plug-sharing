/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2016-2024 elementary, Inc. (https://elementary.io)
 */

public class Sharing.Backend.HostnameManager : Object {
    public bool is_allowed_permission {
        get {
            return permission != null && permission.allowed;
        }
    }

    private Polkit.Permission? permission = null;
    private Backend.HostnameDBusInterface? hostname_proxy = null;

    private static GLib.Once<HostnameManager> instance;
    public static unowned HostnameManager get_default () {
        return instance.once (() => { return new HostnameManager (); });
    }

    private HostnameManager () {
        try {
            // Asks for permission to execute SetStaticHostname and SetPrettyHostname
            permission = new Polkit.Permission.sync (
                "org.freedesktop.hostname1.set-static-hostname",
                null
            );
        } catch (Error err) {
            critical (err.message);
        }

        try {
            hostname_proxy = Bus.get_proxy_sync (BusType.SYSTEM,
                                      Backend.HostnameDBusInterface.SERVICE_NAME,
                                      Backend.HostnameDBusInterface.OBJECT_PATH
            );
        } catch (IOError err) {
            critical (err.message);
        }
    }

    public string? get_hostname () {
        if (hostname_proxy == null) {
            return null;
        }

        string pretty_hostname = hostname_proxy.pretty_hostname;
        if (pretty_hostname.length > 0) {
            return pretty_hostname;
        }

        // fallback
        return hostname_proxy.static_hostname;
    }

    public async void set_hostname (string hostname) throws Error {
        if (!is_allowed_permission) {
            return;
        }

        if (hostname_proxy == null) {
            return;
        }

        string static_hostname = gen_hostname (hostname);
        try {
            yield hostname_proxy.set_pretty_hostname (hostname, false);
            yield hostname_proxy.set_static_hostname (static_hostname, false);
        } catch (Error err) {
            throw err;
        }
    }

    // Generate static hostname from pretty hostname
    private string gen_hostname (string pretty_hostname) {
        string hostname = "";
        bool met_alpha = false;
        bool whitespace_before = false;

        foreach (char c in pretty_hostname.to_ascii ().to_utf8 ()) {
            if (c.isalpha ()) {
                hostname += c.to_string ();
                met_alpha = true;
                whitespace_before = false;
            } else if ((c.isdigit () || c == '-') && met_alpha) {
                hostname += c.to_string ();
                whitespace_before = false;
            } else if (c.isspace () && !whitespace_before) {
                hostname += "-";
                whitespace_before = true;
            }
        }

        return hostname;
    }
}
