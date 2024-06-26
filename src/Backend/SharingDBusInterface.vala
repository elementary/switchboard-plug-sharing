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

[DBus (name = "org.gnome.SettingsDaemon.Sharing")]
public interface Sharing.Backend.SharingDBusInterface : Object {
    public struct SharingNetwork {
        string uuid;
        string network_name;
        string carrier_type;
    }

    public const string SERVICE_NAME = "org.gnome.SettingsDaemon.Sharing";
    public const string OBJECT_PATH = "/org/gnome/SettingsDaemon/Sharing";

    public abstract string current_network { owned get; }

    public abstract void enable_service (string service_name) throws Error;
    public abstract void disable_service (string service_name, string network) throws Error;
    public abstract SharingNetwork[] list_networks (string service_name) throws Error;
}
