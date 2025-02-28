// Human Body SVG: All credits here .. https://codepen.io/schirrel/pen/qBdVqaG
const human_body = `
    <div class="human_body">
        <svg id="body" data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 198.81 693.96">
            <path class="head" d="M122.33,106.46c-3.19-4.62-1.59-24.7-1.59-24.7,6.21-4.62,6.85-18.17,6.85-18.17s0.48,2.39,2.87.8,3.19-17.69,2.55-19.12-3.35-1-3.35-1,3.82-21-2.71-31.87S105,0,98.9,0s-21.51,1.59-28,12.43S68.15,44.3,68.15,44.3s-2.71-.48-3.35,1S65,62.79,67.35,64.38s2.87-.8,2.87-0.8,0.64,13.55,6.85,18.17c0,0,1.59,20.08-1.59,24.7h46.85Z" transform="translate(0.5 0.5)"/>
            <path class="torso_upper" d="M147.08,247.36c-0.06-7.1.64-14.06,2.71-19.47,5.31-13.86,1.87-35.54,4.26-32.35l-5.58-77s-22.95-7.49-26.13-12.11H75.48c-3.19,4.62-26.13,12.11-26.13,12.11l-5.58,77C46.15,192.36,42.71,214,48,227.9c2.07,5.41,2.78,12.37,2.71,19.47h96.34Z" transform="translate(0.5 0.5)"/>
            <path class="torso_lower" d="M50.73,247.36a136.19,136.19,0,0,1-3.62,28.82c-2.55,10.36-11,68.53-11.79,89.72L97,368.29l1.91-.82,1.91,0.82,61.67-2.39c-0.8-21.2-9.24-79.36-11.79-89.72a136.21,136.21,0,0,1-3.62-28.82H50.73Z" transform="translate(0.5 0.5)"/>
            <path class="forearm_right" d="M43.76,195.54c-2.39,3.19-4.94,16.09-5.1,25.82s-3.19,23.27-5.74,29,2.23,35.22-.32,50.36-10.36,42.55-10.36,47.81L3.76,346.3c1-10.36-5.42-86.06-3.35-90.68s4-15.46,2.71-22.63S0.42,189.49,4.4,179.92s-0.8-27.25,9.88-44.62,35.06-16.73,35.06-16.73Z" transform="translate(0.5 0.5)"/>
            <path class="hand_right" d="M22.25,348.54c0,5.26,2.87,6.53,5.42,11.47S27,375.94,27,375.94c2.23,14.82.48,14.82-2.23,14.66s-6.53-12.75-6.53-12.75l-4-1.91s-3.19,3.51-.8,8.92,16.25,12.75,14.66,14.66-6.37-.16-6.37-0.16,9.56,9.24,8.45,10.36a3.53,3.53,0,0,1-2.87.8s2.71,3.19.48,4.62-8.6-3.19-8.6-3.19C10.46,410.69,2,389.33.74,386.94s2.07-30.28,3-40.64Z" transform="translate(0.5 0.5)"/>
            <path class="thigh_right" d="M35.11,508.33c1.67-14.63,4.15-24,4.67-31.36,0.8-11.31-5.26-89.88-4.46-111.07L97,368.29s0.32,12.43-2.07,21-7.33,19-7.33,33.78-2.23,48.45-6.53,62.31c-3.08,9.94-7,16-7.48,22.91H35.11Z" transform="translate(0.5 0.5)"/>
            <path class="calf_right" d="M52.37,640.8c0.48-6.53-4.14-41.75-8.76-55.3s-10-16.25-10-48.76a248.59,248.59,0,0,1,1.54-28.4H73.57a21.52,21.52,0,0,0,1.27,8.8c4,11.47,4.62,37.45.48,54.5s-1.75,52.27-1.44,55.3Z" transform="translate(0.5 0.5)"/>
            <path class="foot_right" d="M73.88,626.94c0.32,3,3.35,6.05,4.94,12.91s-3.51,9.56-1.75,20.4,2.55,31.56-3.35,32.51S66.39,691,66.39,691c-5.9.48-22.79,0.16-25.66-3.19s6.85-26.93,7.81-30.28,0.8-6.69.91-9.4,2.92-7.33,2.92-7.33Z" transform="translate(0.5 0.5)"/>
            <path class="forearm_left" d="M194,346.3c-1-10.36,5.42-86.06,3.35-90.68s-4-15.46-2.71-22.63,2.71-43.51-1.27-53.07,0.8-27.25-9.88-44.62-35.06-16.73-35.06-16.73l5.58,77c2.39,3.19,4.94,16.09,5.1,25.82s3.19,23.27,5.74,29-2.23,35.22.32,50.36,10.36,42.55,10.36,47.81Z" transform="translate(0.5 0.5)"/>
            <path class="hand_left" d="M175.56,348.54c0,5.26-2.87,6.53-5.42,11.47s0.64,15.94.64,15.94c-2.23,14.82-.48,14.82,2.23,14.66s6.53-12.75,6.53-12.75l4-1.91s3.19,3.51.8,8.92-16.25,12.75-14.66,14.66,6.37-.16,6.37-0.16-9.56,9.24-8.45,10.36a3.53,3.53,0,0,0,2.87.8s-2.71,3.19-.48,4.62,8.61-3.19,8.61-3.19c8.76-1.28,17.21-22.63,18.49-25s-2.07-30.28-3-40.64Z" transform="translate(0.5 0.5)"/>
            <path class="thigh_left" d="M162.7,508.33c-1.67-14.63-4.15-24-4.67-31.36-0.8-11.31,5.26-89.88,4.46-111.07l-61.67,2.39s-0.32,12.43,2.07,21,7.33,19,7.33,33.78,2.23,48.45,6.53,62.31c3.08,9.94,7,16,7.48,22.91H162.7Z" transform="translate(0.5 0.5)"/>
            <path class="calf_left" d="M145.44,640.8c-0.48-6.53,4.14-41.75,8.76-55.3s10-16.25,10-48.76a248.59,248.59,0,0,0-1.54-28.4H124.24a21.52,21.52,0,0,1-1.27,8.8c-4,11.47-4.62,37.45-.48,54.5s1.75,52.27,1.44,55.3Z" transform="translate(0.5 0.5)"/>
            <path class="foot_left" d="M123.93,626.94c-0.32,3-3.35,6.05-4.94,12.91s3.51,9.56,1.75,20.4-2.55,31.56,3.35,32.51,7.33-1.75,7.33-1.75c5.9,0.48,22.79.16,25.66-3.19s-6.85-26.93-7.81-30.28-0.8-6.69-.91-9.4-2.92-7.33-2.92-7.33Z" transform="translate(0.5 0.5)"/>
        </svg>
    </div>
`;

// Injury severity levels.
const INJURY_SEVERITY_MAP = {
    minor: { min: 1, max: 33 },
    major: { min: 34, max: 66 },
    critical: { min: 67, max: 100 }
};

class Hud {
    constructor(player_data, disabled_statuses = []) {
        this.player_data = player_data || {};
        this.is_visible = true;
        this.disabled_statuses = disabled_statuses;
        this.statuses = [
            { id: 'health', icon: 'fas fa-heart', colour: '#ff4d4d', always_visible: true },
            { id: 'armour', icon: 'fas fa-shield-halved', colour: '#4d4dff', always_visible: true },
            { id: 'hunger', icon: 'fas fa-drumstick-bite', colour: '#ffcc00', always_visible: false },
            { id: 'thirst', icon: 'fas fa-tint', colour: '#00ccff', always_visible: false },
            { id: 'stamina', icon: 'fas fa-running', colour: '#00ff00', always_visible: false },
            { id: 'stress', icon: 'fas fa-brain', colour: '#ff66cc', always_visible: false },
            { id: 'hygiene', icon: 'fas fa-soap', colour: 'orange', always_visible: false },
            { id: 'oxygen', icon: 'fas fa-lungs', colour: '#99ccff', always_visible: false }
        ].filter(status => !this.disabled_statuses.includes(status.id));
        this.fade_timers = {};
        this.fade_delay = 3000;
        this.last_status_values = {};
        $(document).ready(() => {
            this.build();
            this.apply_player_data(player_data);
        });
    }

    /**
     * Toggles the visibility of the HUD.
     * @param {boolean} visible - Whether the HUD should be visible or not.
     */
    toggle_visibility(visible) {
        this.is_visible = visible;
        $('#hud_layer').fadeToggle(500, visible);
    }

    /**
     * Closes and removes the HUD from the UI.
     */
    close() {
        $('#hud_layer').fadeOut(500).empty();
    }

    /**
     * Builds the HUD.
     */
    build() {
        const circular_bars = this.statuses.map(bar => this.create_circular_bar(bar.id, bar.icon, bar.colour, bar.always_visible)).join('');
        const map_container = `
            <div class="map_container hidden">
                <div class="distance_indicator">
                    <i class="fa-solid fa-location-crosshairs"></i>
                    <p>3.2 miles</p>
                </div>
                <div class="direction_indicator">
                    <p>NW</p>
                </div>
                <div class="street_name_indicator">
                    <p>San Andreas Ave, Pillbox Hill</p>
                </div>
            </div>
        `;
        const content = `
            ${map_container}
            <div class="statuses_hud">
                ${human_body}
                <div class="circular_bars">${circular_bars}</div>
            </div>
        `;
        $('#hud_layer').append(content);
        this.apply_visibility_settings();
    }

    /**
     * Creates a circular progress bar for a status.
     * @param {string} id - The ID of the status.
     * @param {string} icon - The FontAwesome icon class.
     * @param {string} colour - The color of the bar.
     * @param {boolean} always_visible - Whether the status should always be visible.
     * @returns {string} - The generated HTML for the circular bar.
     */
    create_circular_bar(id, icon, colour, always_visible) {
        return `
            <div class="circular_bar ${always_visible ? '' : 'dynamic_status'}" id="${id}_container">
                <div class="circle_progress" id="${id}">
                    <i class="${icon}" style="color:${colour}"></i>
                </div>
            </div>
        `;
    }

    /**
     * Applies visibility settings for HUD elements.
     */
    apply_visibility_settings() {
        this.statuses.forEach(({ id, always_visible }) => {
            const container = $(`#${id}_container`);
            if (always_visible) {
                container.removeClass('fade').css('opacity', 1);
            } else {
                container.addClass('fade').css('opacity', 0);
            }
        });
        $('.circular_bars').css('display', 'flex');
    }

    /**
     * Updates a specific status bar.
     * @param {string} bar_type - The ID of the status to update.
     * @param {number} value - The new value of the status (0-100).
     */
    update_bar(bar_type, value) {
        value = Math.max(0, Math.min(100, value));
        const status = this.statuses.find(s => s.id === bar_type);
        if (!status) return;
        const degree = (value / 100) * 360;
        $(`#${bar_type}`).css('background', `conic-gradient(${status.colour} ${degree}deg, var(--tertiary_background) ${degree}deg)`);
        if (!status.always_visible) {
            this.update_status(bar_type, value);
        }
    }

    /**
     * Updates a status bar.
     * @param {string} bar_type - The ID of the status.
     * @param {number} new_value - The new value of the status.
     */
    update_status(bar_type, new_value) {
        const container = $(`#${bar_type}_container`);
        if (this.last_status_values[bar_type] !== new_value) {
            container.stop(true, true).fadeIn(200).css('opacity', 1);
        }
        if (this.fade_timers[bar_type]) {
            clearTimeout(this.fade_timers[bar_type]);
        }
        this.fade_timers[bar_type] = setTimeout(() => {
            container.fadeOut(500);
        }, this.fade_delay);
        this.last_status_values[bar_type] = new_value;
    }

    /**
     * Updates multiple statuses.
     * @param {Object} new_statuses - Object containing status keys and values.
     */
    update_statuses(new_statuses) {
        const keys = Object.keys(new_statuses);
        keys.forEach((key, index) => {
            setTimeout(() => {
                let value = new_statuses[key];
                if (key === 'health') {
                    value = value / 2;
                }
                this.update_bar(key, value);
            }, index * 250);
        });
    }
    
    /**
     * Applies new player data to the HUD.
     * @param {Object} new_data - The updated player data.
     */
    apply_player_data(new_data) {
        this.player_data = { ...this.player_data, ...new_data, statuses: new_data?.statuses || {} };
        Object.entries(this.player_data?.statuses || {}).forEach(([key, value]) => {
            this.update_bar(key, value);
        });

        const injuries = this.player_data?.statuses?.injuries || {};
        Object.entries(injuries).forEach(([body_part, severity]) => {
            this.set_injury(body_part, severity);
        });
    }

     /**
     * Updates the injury status of a body part.
     * @param {string} body_part - The body part identifier.
     * @param {number} severity_value - The severity level of the injury.
     */
    set_injury(body_part, severity_value) {
        const severity_class = this.map_severity_to_class(severity_value);
        const body_part_element = $(`.human_body .${body_part}`);

        body_part_element.removeClass('minor_injury major_injury critical_injury');
        if (severity_class) {
            body_part_element.addClass(`${severity_class}_injury`);
        }
    }

    /**
     * Maps injury severity to a CSS class.
     * @param {number} value - The severity level (0-100).
     * @returns {string} - The corresponding CSS class.
     */
    map_severity_to_class(value) {
        if (value >= INJURY_SEVERITY_MAP.critical.min) return 'critical';
        if (value >= INJURY_SEVERITY_MAP.major.min) return 'major';
        if (value >= INJURY_SEVERITY_MAP.minor.min) return 'minor';
        return '';
    }

    /**
     * Updates the minimap display.
     * @param {string} direction - The current direction.
     * @param {string} road_name - The current road name.
     * @param {string} distance - The distance remaining.
     */
    update_map(direction, road_name, distance) {
        $('.street_name_indicator p').text(road_name || '');
        $('.direction_indicator p').text(direction || '');
        $('.distance_indicator p').text(distance || '');
    }

    /**
     * Shows map.
     */
    show_map() {
        $('.map_container').removeClass('hidden');
    }

    /**
     * Hides map.
     */
    hide_map() {
        $('.map_container').addClass('hidden');
    }
}

/*
const test_hud = new Hud({
    statuses: {
        health: 100,
        armour: 50,
        hunger: 80,
        thirst: 90,
        stamina: 60,
        stress: 20,
        hygiene: 100,
        oxygen: 100
    }
});

// Simulate dynamic status changes
setTimeout(() => {
    test_hud.update_statuses({ hunger: 50 }); // Hunger appears
}, 2000);

setTimeout(() => {
    test_hud.update_statuses({ thirst: 40 }); // Thirst appears
}, 4000);

setTimeout(() => {
    test_hud.update_statuses({ hunger: 50 }); // No change = should NOT flash again
}, 6000);

setTimeout(() => {
    test_hud.update_statuses({ stamina: 30 }); // Stamina now appears
}, 8000);
*/
