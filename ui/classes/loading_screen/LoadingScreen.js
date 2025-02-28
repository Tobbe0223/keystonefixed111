class LoadScreen {
    constructor() {
        this.images = [
            'gta_bg1.jpg',
            'gta_bg2.jpg',
            'gta_bg3.jpg',
            'gta_bg4.jpg',
            'gta_bg5.jpg'
        ];
        this.image_index = 0;
        this.bg = $('#loading_screen');
        this.audio = null;
        this.init();
    }

    /**
     * Init the loading screen.
     */
    init() {
        this.build_content();
        this.update_background_image();
        this.start_background_cycle();
        this.setup_audio();
    }

    /**
     * Updates background image.
     */
    update_background_image() {
        this.image_index = (this.image_index + 1) % this.images.length;
        this.bg.css('background-image', `url(assets/images/loading_screen/${this.images[this.image_index]})`);
    }

    /**
     * Starts background image cycle.
     */
    start_background_cycle() {
        setInterval(() => this.update_background_image(), 6000);
    }

    /**
     * Builds loading screen.
     */
    build_content() {
        const content = `
            <div id="alpha_loadscreen" class="loadscreen_container">
                <div class="main_header" style="opacity: 0.9;">
                    <div class="header_left">
                        <div class="header_left_img">
                            <img src="assets/images/key_logo100x.jpg" class="header_img">
                        </div>
                        <div class="header_left_info">
                            <div class="header_left_info_1">Keystone</div>
                            <div class="header_left_info_2">Framework Core</div>
                        </div>
                    </div>
                    <div class="loading_center">
                        <p class="loading_message">You are being connected, please wait...</p>
                    </div>
                    <div class="header_right">
                        <div class="header_right_option">
                            <span>DISCORD.GG/KEYSTONE</span>
                        </div>
                    </div>
                </div>
                <div class="loading_footer">
                    <div class="footer_container">
                        &copy; ${new Date().getFullYear()} Keystone. All rights reserved.
                    </div>
                </div>
            </div>
        `;
        this.bg.append(content);
    }

    /**
     * Handles audio setup.
     */
    setup_audio() {
        this.audio = new Audio('assets/audio/loading_screen/loadscreen.mp3');
        this.audio.volume = 0.1;
        this.audio.loop = true;
        this.audio.play().catch((error) => {
            console.warn('Audio autoplay failed:', error.message);
        });
    }
}

$(document).ready(function () {
    new LoadScreen();
});
