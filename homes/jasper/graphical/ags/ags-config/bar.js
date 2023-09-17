const { Hyprland, Audio, Battery } = ags.Service;
const { Widget } = ags;
const { exec, execAsync } = ags.Utils;
const { Box, Button, EventBox, Label, Icon } = ags.Widget;

const WORKSPACE_COUNT = 10;

//
// ------------
//

const cpu = ags.Variable(0, {
    // every 5s
    poll: [5000, 'top -b -n 1', cpu => (
        cpu.split('\n')
            .find(line => line.includes('Cpu(s)'))
            .split(/\s+/)[1]
            .replace(',', '.')
    )],
});
const ram = ags.Variable(0, {
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
    className: 'bar-window-group-outer',
    child: Box({
        className: 'padding-children-1rem',
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

    }),
});

// 󰍬 \udb80\udf6c f036c nf-md-microphone
// 󰍭 \udb80\udf6d f036d nf-md-microphone_off
// 󰕾 \udb81\udd7e nf-md-volume_high
// 󰖁 \udb81\udd81 nf-md-volume_off

const BarRight = () => Box({
    className: 'bar-window-group-outer',
    child: Box({
        className: 'padding-children-dot5rem',
        children: [
            // mic
            Button({
                onClicked: 'pactl set-source-mute @DEFAULT_SOURCE@ toggle',
                onScrollUp: () => execAsync('pamixer --default-source --increase 5 --allow-boost'),
                onScrollDown: () => execAsync('pamixer --default-source --decrease 5 --allow-boost'),
                child: Label({
                    className: 'material-icon',
                    connections: [[Audio, label => {
                        //label.label = Audio.microphone?.isMuted ? "󰍭" : "󰍬";
                        label.label = Audio.microphone?.isMuted ? 'mic_off' : 'mic';
                        label.toggleClassName('red', Audio.microphone.isMuted == true);
                    }, 'microphone-changed']],
                }),
            }),
            // speaker
            Button({
                onClicked: 'pactl set-sink-mute @DEFAULT_SINK@ toggle',
                onScrollUp: () => execAsync('pamixer --increase 5 --allow-boost'),
                onScrollDown: () => execAsync('pamixer --decrease 5 --allow-boost'),
                child: Label({
                    className: 'material-icon',
                    connections: [[Audio, label => {
                        //label.label = Audio.speaker?.isMuted ? "󰖁" : "󰕾";
                        label.label = Audio.speaker?.isMuted ? "volume_off" : "volume_up";
                        label.toggleClassName('red', Audio.speaker.isMuted == true);
                    }, "speaker-changed"]]
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
                        binds: [['icon', Battery, 'iconName']],
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
            // tray
        ],
    }),
});

//
// ------------
//

export const BarWindowLeft = Widget.Window({
    name: 'BarWindowLeft',
    anchor: ['top', 'left'],
    exclusive: false,
    child: Box({
        className: 'bar-window bar-window-left',
        child: BarLeft()
    }),
})

export const BarWindowCenter = Widget.Window({
    name: 'BarWindowCenter',
    anchor: ['top'],
    exclusive: false,
    child: Box({
        className: 'bar-window bar-window-center',
        child: BarCenter()
    }),
})

export const BarWindowRight = Widget.Window({
    name: 'BarWindowRight',
    anchor: ['top', 'right'],
    exclusive: false,
    child: Box({
        className: 'bar-window bar-window-right',
        child: BarRight()
    }),
});
