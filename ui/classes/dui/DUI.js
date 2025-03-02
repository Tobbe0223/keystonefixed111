class DUI {
    constructor(options) {
        this.keys = options.keys || [];
        this.image = options.image || null;
        this.header = options.header || { primary: '', secondary: '' };
        this.progressbars = options.additional?.progressbars || {};
        this.values = options.additional?.values || {};

        this.build();
    }

    build() {
        const key_hints = this.keys.map(key_obj => 
            `<div class="interaction_key">
                <span class="key"><p>${key_obj.key}</p></span> 
                <span class="key_label">${key_obj.label}</span>
            </div>`).join('');

        const skills_section = Object.keys(this.progressbars).length > 0
            ? `<div class="progress_grid grid">
                ${Object.entries(this.progressbars).map(([key, bar]) => `
                    <div class="progress_item">
                        <h3>${bar.label}</h3>
                        <div class="interact_progress_bar">
                            <div class="interact_progress_bar_fill" style="width: ${bar.value}%;">
                                <div class="interact_progress_header">${bar.value}%</div>
                            </div>
                        </div>
                    </div>
                `).join('')}
               </div>`
            : '';

        const values_section = Object.keys(this.values).length > 0
            ? `<ul class="status_list">
                ${Object.entries(this.values).map(([key, value]) => `
                    <li><strong>${value.label}:</strong> ${value.value}</li>
                `).join('')}
              </ul>`
            : '';

        const content = `
            <div class="interact_ui">
                <div class="interact_header">
                    <div class="left_header">
                        ${this.image ? `<img src="./assets/images/dui/${this.image}" alt="DUI Icon">` : ''}
                    </div>
                    <div class="right_header">
                        ${this.header.secondary ? `<div class="secondary_header">${this.header.secondary}</div>` : ''}
                        ${this.header.primary ? `<div class="primary_header">${this.header.primary}</div>` : ''}
                    </div>
                </div>
                ${skills_section}
                ${values_section}
                <div class="keys_container">
                    ${key_hints}
                </div>
            </div>`;

        $('#ui_layer').html(content);
    }

    update_skills(new_skills) {
        this.skills = new_skills;
        this.build();
    }

    update_values(new_values) {
        this.values = new_values;
        this.build();
    }

    update_keys(new_keys) {
        this.keys = new_keys;
        this.build();
    }

    update_header(new_header) {
        this.header = new_header;
        this.build();
    }

    update_image(new_image) {
        this.image = new_image;
        this.build();
    }

    close() {
        $('#ui_layer').empty();
    }
}

/*
const test_dui = new DUI({
    image: 'key_mascotx100.png',
    header: { primary: 'Main Header', secondary: 'Secondary' },
    keys: [
        { key: 'E', label: 'Interact' },
        { key: 'H', label: 'Toggle HUD' },
    ],
    additional: {
        progressbars: {
            strength: { label: 'Strength', value: 75 },
            agility: { label: 'Agility', value: 50 },
            stamina: { label: 'Stamina', value: 90 }
        },
        values: {
            rank: { label: 'Rank', value: 'Elite' },
            reputation: { label: 'Reputation', value: 'Respected' }
        }
    }
});

$('body').css({ 'background': 'grey' });
*/