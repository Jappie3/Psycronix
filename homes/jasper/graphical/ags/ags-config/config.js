const exampleWindow = ags.Widget.Window({
    name: 'example-window',
    child: ags.Widget.Label({
        label: 'example-content',
    }),
});

export default {
    closeWindowDelay: {
        'window-name': 500, // milliseconds
    },
    notificationPopupTimeout: 5000, // milliseconds
    maxStreamVolume: 1.5, // float
    style: ags.App.configDir + '/style.css',
    windows: [
        exampleWindow,
    ],
};