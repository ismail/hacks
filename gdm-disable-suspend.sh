# https://gitlab.gnome.org/GNOME/gnome-control-center/issues/22
sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'nothing'
sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
sudo -u gdm dbus-launch gsettings list-recursively org.gnome.settings-daemon.plugins.power
