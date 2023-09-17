const { Widget } = ags;
const { Box, Button, EventBox, Label } = ags.Widget;

const Right = () => Box({
    child: Label({
        label: 'hi',
    }),
})

export const SideRight = Widget.Window({
    name: 'SideRight',
    anchor: ['top', 'right', 'bottom'],
    exclusive: false,
    //focusable: true,
    popup: true,
    child: Box({
        style: 'background-color: red;',
        className: 'side-right',
        child: Right()
    }),
});
