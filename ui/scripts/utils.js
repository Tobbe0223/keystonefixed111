/**
 * Sends a notification from UI.
 * @param {Object} options - Notification options.
 */
function notify({ type = 'info', message, header = '', duration = 5000 }) {
    $.post(`https://keystone/notify`, JSON.stringify({ type, message, header, duration}));
};

/**
 * Updates specific data within a card element dynamically.
 * @param {number} card_index - The index of the card to update.
 * @param {Object} updates - The updates to apply to the card.
 */
function update_card_data(card_index, updates) {
    const card = $(`.body_card[data-card-index="${card_index}"]`);
    if (!card.length) return console.error(`Card with index ${card_index} not found.`);
    Object.entries(updates).forEach(([key, value]) => {
        if (key === 'description') {
            card.find('.body_card_info p').text(value);
        } else if (key === 'on_hover') {
            const existing_hover = card.data('on-hover') || {};
            const merged_hover = {
                ...existing_hover,
                ...value,
                values: value.values || existing_hover.values || [],
                actions: value.actions || existing_hover.actions || [],
            };
            card.data('on-hover', merged_hover);
        } else {
            card.attr(`data-${key}`, value);
        }
    });
}

/**
 * Dynamically updates header elements based on the provided data.
 * @param {Object} updates - The updates to apply to the header.
 */
function update_header_data(updates) {
    if (updates.header_right) {
        const right_content = updates.header_right.options?.map(option => {
            return `
                <div class="header_right_option" data-id="${option.id}">
                    <i class="${option.icon}"></i>
                    <span>${option.value}</span>
                </div>
            `;
        }).join('');
        $('.header_right_content').html(right_content);
    }
    if (updates.header_left) {
        if (updates.header_left.image) {
            $('.header_left_img img').attr('src', updates.header_left.image);
        }
        if (updates.header_left.info_1) {
            $('.header_left_info_1').text(updates.header_left.info_1);
        }
        if (updates.header_left.info_2) {
            $('.header_left_info_2').text(updates.header_left.info_2);
        }
    }
    if (updates.tabs) {
        const tabs_html = this.build_tabs(updates.tabs);
        $('.header_menu_items').html(tabs_html);
        this.add_events(updates.tabs);
    }
}