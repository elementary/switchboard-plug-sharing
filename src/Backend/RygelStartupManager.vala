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
    private SharingDBusInterface? sharing = null;
    private const string RYGEL_SERVICE_NAME = "rygel";

    construct {
        try {
            sharing = Bus.get_proxy_sync (BusType.SESSION,
                                          SharingDBusInterface.SERVICE_NAME,
                                          SharingDBusInterface.OBJECT_PATH);
        } catch (Error e) {
            warning ("Getting Sharing proxy failed: %s", e.message);
        }
    }

    public async void set_service_enabled (bool enable) {
        if (enable) {
            try {
                sharing.enable_service (RYGEL_SERVICE_NAME);
            } catch (Error e) {
                warning ("Enabling media server failed: %s", e.message);
            }
        } else {
            try {
                sharing.disable_service (RYGEL_SERVICE_NAME, sharing.current_network);
            } catch (Error e) {
                warning ("Disabling media server failed: %s", e.message);
            }
        }
    }

    public bool get_service_enabled () {
        SharingDBusInterface.SharingNetwork[] networks;
        try {
            networks = sharing.list_networks (RYGEL_SERVICE_NAME);
        } catch (Error e) {
            warning ("Getting media server status failed: %s", e.message);
            return false;
        }

        string current_network = sharing.current_network;
        foreach (var network in networks) {
            if (network.uuid == current_network) {
                return true;
            }
        }

        return false;
    }
}
