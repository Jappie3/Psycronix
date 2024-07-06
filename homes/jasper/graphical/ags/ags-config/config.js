import App from 'resource:///com/github/Aylur/ags/app.js';
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import Variable from 'resource:///com/github/Aylur/ags/variable.js';


const { exec, execAsync, CONFIG_DIR } = Utils;
import GLib from 'gi://GLib';

import { BarWindowLeft, BarWindowCenter, BarWindowRight } from './bar.js';

exec(`sassc ${App.configDir}/scss/style.scss ${App.configDir}/style.css`);
App.resetCss();
App.applyCss(`${App.configDir}/style.css`);

let flakedir = GLib.getenv("FLAKE")
Utils.ensureDirectory(flakedir)

export default {
    style: `${App.configDir}/style.css`,
    stackTraceOnError: true,
    windows: [
        BarWindowLeft(),
        BarWindowCenter(),
        BarWindowRight(),
    ],
};
