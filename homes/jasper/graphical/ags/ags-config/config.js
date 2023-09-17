const { App } = ags;
const { exec, execAsync, CONFIG_DIR } = ags.Utils;
import { BarWindowLeft, BarWindowCenter, BarWindowRight } from './bar.js';
import { SideRight } from './sideright.js'

exec(`sassc ${App.configDir}/scss/style.scss ${App.configDir}/style.css`);
ags.App.resetCss();
ags.App.applyCss(`${App.configDir}/style.css`);

export default {
    style: `${App.configDir}/style.css`,
    stackTraceOnError: true,
    windows: [
        BarWindowLeft,
        BarWindowCenter,
        BarWindowRight,
        SideRight,
    ],
};
