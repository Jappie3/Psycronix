import Service from 'resource:///com/github/Aylur/ags/service.js';
import { Utils } from '../imports.js';
const { exec } = Utils;

class BrightnessService extends Service {
    static {
        Service.register(
            this,
            { 'screen-changed': ['float'], },
            { 'screen-value': ['float', 'rw'], },
        );
    }

    _screenValue = 0;

    // the getter has to be in snake_case
    get screen_value() { return this._screenValue; }

    // the setter has to be in snake_case too
    set screen_value(percent) {
        // make sure percent is between 0.02 and 1 (0.02 so screen can't be entirely turned off)
        percent = Math.min(Math.max(percent, 0.02), 1);

        Utils.execAsync(`brightnessctl s ${percent * 100}% -q`)
            .then(() => {
                this._screenValue = percent;

                // signals has to be explicity emitted
                this.emit('screen-changed', percent);
                this.notify('screen-value');

                // or use Service.changed(propName: string) which does the above two
                // this.changed('screen');
            })
            .catch(print);
    }

    constructor() {
        super();
        const current = Number(exec('brightnessctl g'));
        const max = Number(exec('brightnessctl m'));
        this._screenValue = current / max;
    }

    // overwriting connectWidget method, let's you
    // change the default event that widgets connect to
    connectWidget(widget, callback, event = 'screen-changed') {
        super.connectWidget(widget, callback, event);
    }
}

// the singleton instance
const service = new BrightnessService();

// make it global for easy use with cli
globalThis.brightness = service;

// export to use in other modules
export default service;