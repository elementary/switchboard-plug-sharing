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
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

public class Sharing.Widgets.Sidebar : Gtk.ScrolledWindow {
    private Gtk.ListBox list_box;

    public signal void selected_service_changed (string service_id);

    public Sidebar () {
        build_ui ();
        connect_signals ();
    }

    public void add_service_entry (ServiceEntry service_entry) {
        list_box.add (service_entry);
    }

    private void build_ui () {
        this.hscrollbar_policy = Gtk.PolicyType.NEVER;
        this.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
        this.set_size_request (200, -1);

        list_box = new Gtk.ListBox ();

        this.add (list_box);
    }

    private void connect_signals () {
        list_box.row_selected.connect ((row) => {
            if (row == null || !(row is ServiceEntry)) {
                return;
            }

            selected_service_changed (((ServiceEntry)row).id);
        });
    }
}