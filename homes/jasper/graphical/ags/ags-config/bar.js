import App from 'resource:///com/github/Aylur/ags/app.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import Variable from 'resource:///com/github/Aylur/ags/variable.js';

import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';
import SystemTray from 'resource:///com/github/Aylur/ags/service/systemtray.js';
import Battery from 'resource:///com/github/Aylur/ags/service/battery.js';
import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js';

const { exec, execAsync } = Utils;
const { Box, Button, EventBox, Label, Icon, Revealer } = Widget;

const WORKSPACE_COUNT = 10;

const currentTime = new Date().getHours();
// check if current time is between 7AM & 6PM
if (currentTime >= 7 && currentTime < 18) {
    var theme = 'light';
} else {
    var theme = 'dark';
}

//
// ------------
//

const cpu = Variable(0, {
    // every 5s
    poll: [5000, 'top -b -n 1', cpu => (
        cpu.split('\n')
            .find(line => line.includes('Cpu(s)'))
            .split(/\s+/)[1]
            .replace(',', '.')
    )],
});
const ram = Variable(0, {
    // every 20s
    poll: [20000, 'free -m', mem => {
        // values are in MiB
        mem = mem.split('\n')
            .find(line => line.includes('Mem:'))
            .split(/\s+/)
            .slice(2, 3);
        // divide by 100 to go from MiB to GiB & keep the decimal places
        return (mem / 1000.00)
    }],
});

// const SysTrayItem = item => Button({
//     child: Icon({ binds: [['icon', item, 'icon']] }),
//     binds: [['tooltipMarkup', item, 'tooltip-markup']],
//     setup: btn => {
//         const id = item.menu.connect('popped-up', menu => {
//             btn.toggleClassName('active');
//             menu.connect('notify::visible', menu => {
//                 btn.toggleClassName('active', menu.visible);
//             });
//             menu.disconnect(id);
//         });
//     },
//     onPrimaryClick: btn =>
//         item.menu.popup_at_widget(btn, Gdk.Gravity.SOUTH, Gdk.Gravity.NORTH, null),
//     onSecondaryClick: btn =>
//         item.menu.popup_at_widget(btn, Gdk.Gravity.SOUTH, Gdk.Gravity.NORTH, null),
// })

const SysTrayItem = item => Widget.Button({
    child: Icon({ binds: [['icon', item, 'icon']] }),
    binds: [['tooltip-markup', item, 'tooltip-markup']],
    onPrimaryClick: (_, event) => item.activate(event),
    onSecondaryClick: (_, event) => item.openMenu(event),
});

//
// ------------
//

const sep = () => Label({
    className: `material-icon`,
    //  \uf104 nf-fa-angle_left
    // label: ""
    label: 'chevron_left',
    // label: 'arrow_back_ios_new',
});

//
// ------------
//

const BarLeft = () => Box({
    className: 'bar-window-group-outer',
    child: EventBox({
        onScrollUp: () => execAsync('hyprctl dispatch workspace -1'),
        onScrollDown: () => execAsync('hyprctl dispatch workspace +1'),
        //onMiddleClick: () => execAsync(''),
        child: Box({
            className: 'ws-module padding-children-dot5rem',
            children: Array.from({ length: WORKSPACE_COUNT }, (_, i) => i + 1).map(i => Button({
                onClicked: () => execAsync(`hyprctl dispatch workspace ${i}`).catch(print),
                child: Label({
                }),
                connections: [[Hyprland, label => {
                    if (Hyprland.active.workspace.id === i) {
                        // i == current workspace
                        label.label = "";
                    } else if (Hyprland.getWorkspace(i)?.windows > 0) {
                        // i has more than one window
                        label.label = ""
                    } else {
                        // i is free
                        label.label = "";
                    }
                }, "changed"]],
            })),
        }),
    }),
});

const BarCenter = () => Box({
    className: 'bar-window-group-outer padding-children-1rem',
    homogeneous: true,
    children: [
        Label({
            // 720 seconds -> 12 mins
            connections: [[720000, label => label.label = "#" + exec('date +%j')]],
        }),
        Label({
            connections: [[5000, label => label.label = exec('date +%H:%M')]]
        }),
        Label({
            // 720 seconds -> 12 mins
            connections: [[720000, label => label.label = exec('date +%d/%m')]]
        })
    ],
});

const BarRight = () => Box({
    className: 'bar-window-group-outer padding-children-dot5rem',
    children: [
        // mic
        Button({
            onClicked: () => { execAsync(["bash", "-c", "pactl set-source-mute @DEFAULT_SOURCE@ toggle"]).catch(err => print(err)) },
            onScrollUp: () => execAsync('pamixer --default-source --increase 5 --allow-boost'),
            onScrollDown: () => execAsync('pamixer --default-source --decrease 5 --allow-boost'),
            child: Label({
                className: 'material-icon',
                connections: [[Audio, self => {
                    self.label = Audio.microphone?.stream.isMuted ? 'mic_off' : 'mic';
                    self.toggleClassName('red', Audio.microphone?.stream.isMuted == true);
                }, 'microphone-changed']],
            }),
        }),
        // speaker
        Button({
            onClicked: () => { execAsync(["bash", "-c", "pactl set-sink-mute @DEFAULT_SINK@ toggle"]).catch(err => print(err)) },
            onScrollUp: () => execAsync('pamixer --increase 5 --allow-boost'),
            onScrollDown: () => execAsync('pamixer --decrease 5 --allow-boost'),
            child: Label({
                className: 'material-icon',
                connections: [[Audio, self => {
                    self.label = Audio.speaker?.stream.isMuted ? "volume_off" : "volume_up";
                    self.toggleClassName('red', Audio.speaker?.stream.isMuted == true);
                }, 'speaker-changed']]
            }),
        }),
        sep(),
        // TODO wifi & ethernet
        // 
        // sep(),
        // cpu
        Box({
            children: [
                Label({
                    className: 'material-icon',
                    // I know but it looks like a square
                    label: 'memory',
                }),
                Label({
                    // bash -c 'mpstat --dec=1 1 1 | awk "NR == 4 { printf \"%.1f\", 100 - \$NF }"'
                    // exec(`bash -c \'mpstat --dec=1 1 1 | awk \"NR == 4 { printf \\\"%.1f\\\", 100 - \\$NF }\"\'`)
                    connections: [[cpu, label => {
                        label.label = parseFloat(cpu.value).toFixed(1).toString();
                    }]],
                }),
                Label({
                    className: 'bar-left-smalltext',
                    label: "%",
                    valign: "end",
                }),
            ]
        }),
        // memory
        Box({
            children: [
                // Label({
                //     className: 'material-icon',
                //     label: 'memory_alt',
                // }),
                Label({
                    connections: [[ram, label => {
                        label.label = parseFloat(ram.value).toFixed(2).toString();
                    }]],
                }),
                Label({
                    className: 'bar-left-smalltext',
                    label: "GiB",
                    valign: "end",
                })
            ]
        }),
        sep(),
        // battery
        // battery_full battery_6_bar battery_0_bar
        // battery_charging_full battery_charging
        Box({
            connections: [[Battery, box => {
                box.toggleClassName('red', Battery.percent <= 20);
            }]],
            children: [
                Label({
                    className: 'material-icon',
                    label: 'battery_full',
                }),
                Label({
                    label: "b",
                    binds: [['icon', Battery, 'icon-name']],
                    connections: [[Battery, label => {
                        label.label = `${Battery.percent}`;
                    }]],

                    // connections: [[Battery, stack => {
                    //     const { charging, charged } = Battery;
                    //     stack.shown = `${charging || charged}`;
                    //     stack.toggleClassName('charging', Battery.charging);
                    //     stack.toggleClassName('charged', Battery.charged);
                    //     stack.toggleClassName('low', Battery.percent < 30);
                    // }]],

                }),
                Label({
                    className: 'bar-left-smalltext',
                    label: "%",
                    valign: "end",
                })
            ],
        }),
        sep(),
        Box({
            child: Button({
                child: Label({
                    className: 'material-icon',
                    label: 'visibility_off',
                }),
                connections: [['clicked', button => {
                    const pid = exec(`pidof wlroots-idle-inhibit`);
                    if (pid != "") {
                        // no idle inhibit (default) - lock screen after inactivity
                        button.child.label = 'visibility_off';
                        execAsync(`kill ${pid}`).catch(print);
                        // execAsync(['notify-send', 'Idle-inhibit disabled']);
                        //Notifications.Notify('hi');
                    } else {
                        // idle inhibit enabled - no locking
                        button.child.label = 'visibility';
                        execAsync(`hyprctl dispatch exec [workspace special:wlroots-idle-inhibit silent] wlroots-idle-inhibit`).catch(print);
                        // execAsync(['notify-send', 'Idle-inhibit enabled']);
                    };
                }]],
            }),
        }),
        // sep(),
        Box({
            child: Button({
                child: Label({
                    className: 'material-icon',
                    // default to dark mode
                    label: 'dark_mode',
                }),
                connections: [['clicked', self => {
                    if (theme == "dark") {
                        theme = "light";
                        self.child.label = "light_mode";
                        execAsync(`${App.configDir}/scripts/switchtheme.sh light`).catch(err => print(err));
                    }
                    else if (theme == "light") {
                        theme = "dark";
                        self.child.label = "dark_mode";
                        execAsync(`${App.configDir}/scripts/switchtheme.sh dark`).catch(err => print(err));
                    }
                }]],
            }),
        }),
        // tray
        Box({
            children: [
                Button({
                    child: Label({
                        className: 'material-icon',
                        label: 'chevron_left',
                    }),
                    // menus are selectable
                    // > It's missing from the docs but you can reference the corresponding Gtk.Menu from TrayItem.menu - Aylur
                    // TODO background for the menus
                    connections: [['clicked', self => {
                        let revealer = self.parent.children[2];
                        let spacer = self.parent.children[1];
                        // reveal or hide the tray
                        revealer.revealChild = !revealer.revealChild;
                        if (revealer.child.children.length > 0) {
                            // spacing between button & tray items, only if there are items in the tray
                            revealer.revealChild ? spacer.label = ' ' : spacer.label = '';
                        }
                        revealer.revealChild ? self.child.label = 'chevron_right' : self.child.label = 'chevron_left';
                    }]],
                }),
                Label({
                    label: '',
                }),
                Revealer({
                    transition: 'slide_left',
                    transitionDuration: 200,
                    child: Box({
                        binds: [['children', SystemTray, 'items', i => i.map(SysTrayItem)]],
                    }),
                }),
            ],
        }),
        Box({
            css: '* {padding: 0;}',
            child: Button({
                css: '* {min-width: 2rem;}',
                onClicked: () => { execAsync(`${App.configDir}/scripts/setwallpaper.sh`).catch(err => print(err)) },
                // no material fonts NixOS icon :/
                label: ' ',
            })
        }),
    ],
});

//
// ------------
//

export const BarWindowLeft = () => Widget.Window({
    name: 'BarWindowLeft',
    anchor: ['top', 'left'],
    exclusivity: 'ignore',
    child: Box({
        className: 'bar-window bar-window-left',
        child: BarLeft()
    }),
})

export const BarWindowCenter = () => Widget.Window({
    name: 'BarWindowCenter',
    anchor: ['top'],
    exclusivity: 'ignore',
    child: Box({
        className: 'bar-window bar-window-center',
        child: BarCenter()
    }),
})

export const BarWindowRight = () => Widget.Window({
    name: 'BarWindowRight',
    anchor: ['top', 'right'],
    exclusivity: 'ignore',
    child: Box({
        className: 'bar-window bar-window-right',
        child: BarRight()
    }),
});
