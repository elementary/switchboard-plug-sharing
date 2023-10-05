export DISPLAY=:0.0
killall io.elementary.switchboard -9
sudo rm -fr build/
sudo meson build --prefix=/usr
cd build/
sudo ninja
sudo ninja install
cd ../
io.elementary.switchboard
