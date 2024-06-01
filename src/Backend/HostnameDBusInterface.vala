/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2016-2024 elementary, Inc. (https://elementary.io)
 */

[DBus (name = "org.freedesktop.hostname1")]
public interface Sharing.Backend.HostnameDBusInterface : Object {
    public const string SERVICE_NAME = "org.freedesktop.hostname1";
    public const string OBJECT_PATH = "/org/freedesktop/hostname1";

    public abstract string pretty_hostname { owned get; }
    public abstract string static_hostname { owned get; }

    public abstract async void set_pretty_hostname (string hostname, bool interactive) throws GLib.Error;
    public abstract async void set_static_hostname (string hostname, bool interactive) throws GLib.Error;
}
