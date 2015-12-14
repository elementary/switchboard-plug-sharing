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

public class Sharing.Widgets.ServiceEntry : Gtk.Grid {
    public string title { private get; construct; }
    public string icon_name { private get; construct; }

    private Gtk.Image image;
    private Gtk.Label title_label;

    public ServiceEntry (string title, string icon_name) {
        Object (title: title, icon_name: icon_name);

        build_ui ();
    }

    private void build_ui () {
        image = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DIALOG);

        title_label = new Gtk.Label (title);
        title_label.get_style_context ().add_class (Granite.StyleClass.H3_TEXT);

        this.attach (image, 0, 0, 1, 1);
        this.attach (title_label, 1, 0, 1, 1);
    }
}