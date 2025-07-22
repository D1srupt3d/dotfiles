import App from 'resource:///com/github/Aylur/ags/app.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';
import Network from 'resource:///com/github/Aylur/ags/service/network.js';
import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import Battery from 'resource:///com/github/Aylur/ags/service/battery.js';
import SystemTray from 'resource:///com/github/Aylur/ags/service/systemtray.js';
import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js';

// Colors
const colors = {
    background: '#3b0764',
    text: '#ffffff',
    spotify: '#1DB954',
    error: '#ff0000',
};

// Workspace Icons
const workspaceIcons = {
    1: '󰲠',
    2: '󰲢',
    3: '󰲤',
    4: '󰲦',
    5: '󰲨',
    6: '󰲪',
    7: '󰲬',
    8: '󰲮',
    9: '󰲰',
    10: '󰿬',
    active: '',
    default: '',
};

// Workspaces Widget
const Workspaces = () => Widget.Box({
    className: 'workspaces',
    children: Array.from({ length: 10 }, (_, i) => i + 1).map(i => Widget.Button({
        className: 'workspace',
        child: Widget.Label({
            label: workspaceIcons[i],
            className: 'workspace-icon',
        }),
        onClicked: () => Hyprland.message(`dispatch workspace ${i}`),
    })),
});

// Clock Widget
const Clock = () => Widget.Label({
    className: 'clock',
    setup: self => self.poll(1000, label => {
        label.label = `󰅐 ${new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}`;
    }),
});

// Network Widget
const NetworkIndicator = () => Widget.Label({
    className: 'network',
    setup: self => self.poll(2000, label => {
        const network = Network.wifi;
        label.label = network?.enabled
            ? `󰖩 ${network.internet}`
            : '󰖪';
    }),
});

// CPU Widget
const CPU = () => Widget.Label({
    className: 'cpu',
    setup: self => self.poll(1000, label => {
        Utils.execAsync(['top', '-b', '-n', '1'])
            .then(out => {
                const cpu = out.split('\n')[2].split(/\s+/)[1];
                label.label = `󰻠 ${cpu}%`;
            });
    }),
});

// Memory Widget
const Memory = () => Widget.Label({
    className: 'memory',
    setup: self => self.poll(1000, label => {
        Utils.execAsync(['free', '-m'])
            .then(out => {
                const mem = out.split('\n')[1].split(/\s+/)[2];
                const total = out.split('\n')[1].split(/\s+/)[1];
                const percentage = Math.round((mem / total) * 100);
                label.label = `󰍛 ${percentage}%`;
            });
    }),
});

// Audio Widget
const AudioIndicator = () => Widget.Button({
    className: 'audio',
    child: Widget.Label({
        setup: self => self.poll(1000, label => {
            const volume = Audio.speaker?.volume * 100 || 0;
            const icon = Audio.speaker?.is_muted
                ? '󰝟'
                : volume < 30 ? '󰕿' : volume < 70 ? '󰖀' : '󰕾';
            label.label = `${Math.round(volume)}% ${icon}`;
        }),
    }),
    onClicked: () => Utils.execAsync(['pavucontrol']),
});

// Battery Widget
const BatteryIndicator = () => Widget.Label({
    className: 'battery',
    setup: self => self.poll(1000, label => {
        const battery = Battery.primary;
        if (!battery) return;
        
        const icon = battery.charging
            ? '󰂄'
            : battery.percent < 10 ? '󰂎'
            : battery.percent < 20 ? '󰁺'
            : battery.percent < 30 ? '󰁻'
            : battery.percent < 40 ? '󰁼'
            : battery.percent < 50 ? '󰁽'
            : battery.percent < 60 ? '󰁾'
            : battery.percent < 70 ? '󰁿'
            : battery.percent < 80 ? '󰂀'
            : battery.percent < 90 ? '󰂁'
            : '󰂂';
        
        label.label = `${icon} ${Math.round(battery.percent)}%`;
    }),
});

// Spotify Widget
const Spotify = () => Widget.Label({
    className: 'spotify',
    setup: self => self.poll(1000, label => {
        Utils.execAsync(['playerctl', '-p', 'spotify', 'metadata', '--format', '{{artist}} - {{title}}'])
            .then(out => {
                label.label = `󰎈 ${out}`;
            })
            .catch(() => label.label = '');
    }),
});

// Notifications Widget
const NotificationsIndicator = () => Widget.Button({
    className: 'notifications',
    child: Widget.Label({
        setup: self => self.poll(1000, label => {
            const count = Notifications.notifications.length;
            label.label = count > 0 ? `󰂚 ${count}` : '󰂛';
        }),
    }),
    onClicked: () => Utils.execAsync(['swaync-client', '-t', '-sw']),
});

// Power Menu Widget
const PowerMenu = () => Widget.Button({
    className: 'powermenu',
    child: Widget.Label({ label: '󰐥' }),
    onClicked: () => Utils.execAsync(['wlogout', '-p', 'layer-shell']),
});

// Bar
const Bar = () => Widget.Window({
    name: 'bar',
    anchor: ['top', 'left', 'right'],
    exclusivity: 'exclusive',
    child: Widget.CenterBox({
        className: 'bar',
        startWidget: Widget.Box({
            className: 'left',
            children: [
                Clock(),
                Workspaces(),
                Spotify(),
            ],
        }),
        centerWidget: Widget.Label({
            className: 'window',
            setup: self => self.hook(Hyprland.active.client, label => {
                label.label = Hyprland.active.client?.title || '';
            }),
        }),
        endWidget: Widget.Box({
            className: 'right',
            children: [
                NetworkIndicator(),
                CPU(),
                Memory(),
                AudioIndicator(),
                BatteryIndicator(),
                NotificationsIndicator(),
                PowerMenu(),
            ],
        }),
    }),
});

// Export the configuration
export default {
    style: `
        * {
            all: unset;
            font-family: "Hack Nerd Font";
            font-size: 16px;
        }
        
        .bar {
            background: transparent;
            color: ${colors.text};
        }
        
        .workspaces {
            background: ${colors.background};
            border-radius: 30px;
            margin: 8px 6px;
            padding: 6px 12px;
        }
        
        .workspace {
            color: ${colors.text};
            padding: 0 5px;
        }
        
        .workspace.active {
            color: ${colors.text};
            background: ${colors.background};
        }
        
        .clock, .network, .cpu, .memory, .audio, .battery, .notifications, .powermenu, .spotify {
            background: ${colors.background};
            border-radius: 30px;
            margin: 8px 6px;
            padding: 6px 12px;
            color: ${colors.text};
        }
        
        .spotify.playing {
            color: ${colors.spotify};
        }
        
        .notifications.dnd {
            color: ${colors.error};
        }
    `,
    windows: [Bar()],
}; 