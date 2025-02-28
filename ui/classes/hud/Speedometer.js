class Speedometer {
    constructor() {
        this.speed = 0;
        this.vehicle_health = 100;
        this.engine_health = 100;
        this.fuel = 100;
    }

    /**
     * Builds speedo.
     */
    build() {
        let content = `
            <div class="speedo_container">
                <div class="gear_indicator">3</div>
                <div class="mileage_indicator">
                    <span class="mileage">000000</span>
                </div>
                <div class="speed_indicator">
                    <span class="speed">120</span>
                    <span class="speed_unit">MPH</span>
                </div>
                <div class="indicator_icons">
                    <span class="left_indicator"><i class="fa-solid fa-caret-left"></i></span>
                    <span class="headlights" style="color: #323030"><i class="fa-solid fa-lightbulb"></i></span>
                    <span class="seatbelt" style="color: #323030"><i class="fa-solid fa-user-slash"></i></span>
                    <span class="cruise_control" style="color: #323030"><i class="fa-solid fa-gauge"></i></span>
                    <span class="engine_state" style="color: #323030"><i class="fa-solid fa-car-on"></i></span>
                    <span class="right_indicator"><i class="fa-solid fa-caret-right"></i></span>
                </div>
                <svg class="vehicle_body_bar" width="200" height="100">
                    <path fill="none" stroke="#1f1e1e" stroke-width="3" d="M 100,100 m -87,-3 a 87,87 0 0,0 87,87"/>
                    <path id="vehicle_body_path_bg" fill="none" stroke="#1f1e1e" stroke-width="6" d="M 100,100 m -75,0 a 75,75 0 0,0 75,75"/>
                    <path id="vehicle_body_path" fill="none" stroke="white" stroke-width="6" d="M 100,100 m -75,0 a 75,75 0 0,0 75,75"/>
                </svg>
                <span class="body_health_icon"><i class="fa-solid fa-car"></i></span>
                <svg class="vehicle_engine_bar" width="200" height="100">
                    <path fill="none" stroke="#1f1e1e" stroke-width="3" d="M 100,100 m -87,3 a 87,87 0 0,1 85,-87"/>
                    <path id="vehicle_engine_path_bg" fill="none" stroke="#1f1e1e" stroke-width="6" d="M 100,100 m -75,0 a 75,75 0 0,1 75,-75"/>
                    <path id="vehicle_engine_path" fill="none" stroke="white" stroke-width="6" d="M 100,100 m -75,0 a 75,75 0 0,1 75,-75"/>
                </svg>
                <span class="engine_health_icon"><i class="fa-solid fa-gear"></i></span>
                ${this.fuel_progress()}
            </div>
        `;
        $('#hud_layer').append(content);
        $('.speedo_container').addClass('hidden');
        this.set_dash_arrays();
        this.update_body_health(this.vehicle_health);
        this.update_engine_health(this.engine_health);
    }

    /**
     * Updates speedo indicator.
     * 
     * @param {string} indicator 
     * @param {string} colour 
     * @param {string} animation 
     */
    update_indicator(indicator, colour, animation) {
        $(`.${indicator} i`).css({
            'color': colour || 'white',
            'animation': animation || ''
        });
    }

    /**
     * Handles fuel progress bar.
     */
    fuel_progress() {
        let content = '<div class="fuel_progress">';
        for (let i = 0; i < 10; i++) {
            content += `<div class="fuel_segment" data-segment="${i}"></div>`;
        }
        content += '</div>';
        return content;
    }

    /**
     * Handles dash arrays for body + engine health.
     */
    set_dash_arrays() {
        const body_health_path = document.getElementById('vehicle_body_path');
        const engine_health_path = document.getElementById('vehicle_engine_path');
        const length = Math.PI * 75;
        body_health_path.setAttribute('stroke-dasharray', length);
        body_health_path.setAttribute('stroke-dashoffset', length);
        engine_health_path.setAttribute('stroke-dasharray', length);
        engine_health_path.setAttribute('stroke-dashoffset', length);
    }

    /**
     * Updates gear indicator.
     * 
     * @param {number} gear - Current gear.
     */
    update_gear(gear) {
        $('.gear_indicator').text(gear)
    }
    
    /**
     * Updates vehicle body health progress bar.
     * 
     * @param {number} health - Current health.
     */
    update_body_health(health) {
        const path = document.getElementById('vehicle_body_path');
        const length = path.getTotalLength();
        const offset = length * ((100 - (health / 2)) / 50);
        path.setAttribute('stroke-dashoffset', offset);
    }
    
    /**
     * Updates vehicle engine health progress bar.
     * 
     * @param {number} health - Current health.
     */
    update_engine_health(health) {
        const path = document.getElementById('vehicle_engine_path');
        const length = path.getTotalLength();
        const offset = length * ((100 - (health / 2)) / 50);
        path.setAttribute('stroke-dashoffset', offset);
    }
    
    /**
     * Updates vehicle speed.
     * @param {number} speed_value - Current speed.
     */
    update_speed(speed_value) {
        this.speed = speed_value;
        $('.speed_indicator .speed').text(this.speed + ' MPH');
    }

    /**
     * Updates vehicle fuel level.
     * 
     * @param {number} value - Fuel level.
     */
    update_fuel(value) {
        this.fuel = value;
        $('.fuel_segment').each(function() {
            const segment = parseInt($(this).data('segment'));
            if (segment < value) {
                $(this).addClass('filled');
            } else {
                $(this).removeClass('filled');
            }
        });
    }

    /**
     * Updates vehicle mileage.
     * 
     * @param {number} value - The new mileage value.
     */
    update_mileage(value) {
        $('.mileage').text(value);
    }

    /**
     * Shows the speedo.
     */
    show() {
        $('.speedo_container').removeClass('hidden');
    }

    /**
     * Hides the speedo.
     */
    hide() {
        $('.speedo_container').addClass('hidden');
    }

}

/*
const speedotest = new Speedometer();
speedotest.build();

speedotest.update_body_health(45);
speedotest.update_engine_health(25);

speedotest.show();
speedotest.update_speed(88);
speedotest.update_fuel(5);
speedotest.update_mileage(999999);

speedotest.update_indicator('left_indicator', 'orange', 'flash 1s infinite');
speedotest.update_indicator('right_indicator', 'orange', 'flash 1s infinite');
*/