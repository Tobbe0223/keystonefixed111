class Deathscreen {
    constructor(data) {
        this.title = data.title || 'YOU DIED';
        this.respawn_enabled = data.respawn_enabled || false;
        this.respawn_key = data.respawn_key || 'E';
        this.give_up_enabled = data.give_up_enabled || false;
        this.give_up_key = data.give_up_key || 'G';
        this.assistance_enabled = data.assistance_enabled || false;
        this.assistance_key = data.assistance_enabled ? data.assistance_key : 'H';
        this.respawn_timer = data.respawn_timer || 10;
        this.assistance_timer = data.assistance_timer || 60;
        this.assistance_requested = false;
        this.countdown_interval = null;
        this.assistance_interval = null;
        this.build();
    }

    /**
     * Builds the death screen.
     */
    build() {
        const content = `
            <div class="bg_layer"></div>
            <div class="death_content">
                <div class="death_screen_title">
                    <h1>${this.title}</h1>
                    <div id="info_text" class="info_text" style="display: none;"></div>
                </div>
                <div id="key_prompts">
                    ${this.respawn_enabled ? `
                        <div class="key_prompt" id="key_${this.respawn_key}">
                            <div class="key">${this.respawn_key}</div>
                            <div class="key_hint">Press ${this.respawn_key} to Respawn</div>
                            <div class="key_overlay" id="respawn_overlay" style="display: none;">Respawning...</div>
                        </div>
                    ` : ''}
                    ${this.give_up_enabled ? `
                        <div class="key_prompt" id="key_${this.give_up_key}">
                            <div class="key">${this.give_up_key}</div>
                            <div class="key_hint">Press ${this.give_up_key} to Give Up</div>
                            <div class="key_overlay" id="give_up_overlay" style="display: none;">Giving up...</div>
                        </div>
                    ` : ''}
                    ${this.assistance_enabled ? `
                        <div class="key_prompt" id="key_${this.assistance_key}">
                            <div class="key">${this.assistance_key}</div>
                            <div class="key_hint">Press ${this.assistance_key} for Assistance</div>
                            <div class="key_overlay" id="assistance_overlay" style="display: none;">Assistance requested</div>
                        </div>
                    ` : ''}
                </div>
            </div>
        `;
        $('#death_screen').empty();
        $('#death_screen').html(content).fadeIn(300);
    }

    /**
     * Hides death screen.
     */
    hide() {
        $('#death_screen').fadeOut(300, function () {
            $(this).empty();
        });

        if (this.countdown_interval) clearInterval(this.countdown_interval);
        if (this.assistance_interval) clearInterval(this.assistance_interval);
    }

    /**
     * Handles triggering respawn.
     */
    respawn() {
        $.post(`https://${GetParentResourceName()}/respawn_player`, JSON.stringify({}));
    }

    /**
     * Handles triggering giveup.
     */
    give_up() {
        $.post(`https://${GetParentResourceName()}/give_up`, JSON.stringify({}));
        $('#give_up_overlay').show();
    }

    /**
     * Handles respawn countdown.
     */
    start_respawn_countdown() {
        let time_left = this.respawn_timer;
        $('#info_text').text(`Respawning in ${time_left} seconds. Press ESCAPE to cancel.`).show();
        $('#respawn_overlay').show();
        this.countdown_interval = setInterval(() => {
            time_left--;
            $('#info_text').text(`Respawning in ${time_left} seconds. Press ESCAPE to cancel.`);

            if (time_left <= 0) {
                clearInterval(this.countdown_interval);
                this.countdown_interval = null;
                this.respawn();
            }
        }, 1000);
    }

    /**
     * Cancels respawn.
     */
    cancel_respawn() {
        if (!this.is_respawn_countdown) return;
        clearInterval(this.countdown_interval);
        this.countdown_interval = null;
        this.is_respawn_countdown = false;
        $('#info_text').text('Respawn cancelled.').fadeOut(3000);
        $('#respawn_overlay').hide();
    }

    /**
     * Handles calling for assistance.
     */
    call_for_assistance() {
        if (this.assistance_requested) return;
        fetch(`https://${GetParentResourceName()}/request_assistance`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                this.assistance_requested = true;
                let time_left = this.assistance_timer;
                $('#info_text').text(`Assistance requested. Please wait ${time_left} seconds.`).show();
                $('#assistance_overlay').show();
                this.assistance_interval = setInterval(() => {
                    time_left--;
                    $('#info_text').text(`Assistance requested. Please wait ${time_left} seconds.`);
                    if (time_left <= 0) {
                        clearInterval(this.assistance_interval);
                        this.assistance_interval = null;
                        this.assistance_requested = false;
                        $('#info_text').text('You can now request assistance again.').fadeOut(3000);
                        $('#assistance_overlay').hide();
                    }
                }, 1000);
            }
        });
    }

}

/*
$(document).ready(() => {
    const test_data = {
        title: 'YOU ARE DOWNED',
        respawn_enabled: true,
        respawn_key: 'E',
        cancel_respawn_key: 'C',
        respawn_timer: 10,
        assistance_enabled: true,
        assistance_key: 'G',
        assistance_timer: 60,
        ko_timer: 30
    };
    const test_deathscreen = new Deathscreen(test_data);
});
*/