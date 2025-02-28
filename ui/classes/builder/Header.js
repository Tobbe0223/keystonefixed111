class Header {
    constructor(invoking_resource, header_data, content) {
        this.resource_name = invoking_resource;
        this.content = content;
        this.header_data = header_data;
        $(document).ready(() => {
            this.clean_up();
            this.build_header(header_data);
        });
    }

    /**
     * Clear any existing header elements and listeners.
     */
    clean_up() {
        $('.main_header').remove();
        $(document).off('keydown');
        $('.header_menu_item').off('click');
    }

    /**
     * Build the header and default to the first tab if available.
     * 
     * @param {Object} header_data - Header data containing tabs, left, and right sections.
     */
    build_header(header_data) {
        const left_section = this.build_left(header_data);
        const tabs = this.build_tabs(header_data.tabs || []);
        const right_section = this.build_right(header_data);
        const show_navigation_keys = header_data.tabs?.length > 1;
        const content_html = `
            <div class="main_header">
                <div class="header_left">${left_section}</div>
                <div class="header_menu">
                    ${show_navigation_keys ? `<div class="header_key left_key">A</div>` : ''}
                    <div class="header_menu_items">${tabs}</div>
                    ${show_navigation_keys ? `<div class="header_key right_key">D</div>` : ''}
                </div>
                <div class="header_right">${right_section}</div>
            </div>
        `;
        $('#ui_layer').append(content_html);
        const first_tab = header_data.tabs?.[0]?.id;
        if (first_tab) {
            this.set_active_tab(first_tab);
        } else {
            console.log('No valid tabs found in header.');
        }
        this.add_events(header_data.tabs || []);
    }

    /**
     * Build header tabs.
     * 
     * @param {Array} tabs - Array of tab objects.
     * @returns {string} HTML for the tabs.
     */
    build_tabs(tabs) {
        return tabs.map((tab, index) => {
            const active_class = index === 0 ? 'active' : '';
            return `<div id="menu_${tab.id}" class="header_menu_item ${active_class}" data-id="${tab.id}">${tab.label}</div>`;
        }).join('');
    }

    /**
     * Build the left side of the header for player/server info.
     * 
     * @param {Object} header_data - Header data containing the left section details.
     * @returns {string} HTML for the left section.
     */
    build_left(header_data) {
        const left_data = header_data.header_left || {};
        return `
            <div class="header_left_img">
                <img src="${left_data.image || 'assets/images/default_logo.jpg'}" class="header_img">
            </div>
            <div class="header_left_info">
                <div class="header_left_info_1">${left_data.info_1 || 'Default Info 1'}</div>
                <div class="header_left_info_2">${left_data.info_2 || 'Default Info 2'}</div>
            </div>
        `;
    }

    /**
     * Build the right side of the header for player values like cash or ID.
     * 
     * @param {Object} header_data - Header data containing the right section details.
     * @returns {string} HTML for the right section.
     */
    build_right(header_data) {
        const right_data = header_data.header_right || {};
        const flex_direction = right_data.flex_direction || 'row';
        const options = right_data.options || [];
        const options_content = options
            .map(option => {
                return `
                    <div class="header_right_option">
                        <i class="${option.icon}"></i>
                        <span>${option.value}</span>
                    </div>
                `;
            })
            .join('');
        return `
            <div class="header_right_content" style="flex-direction: ${flex_direction};">
                ${options_content}
            </div>
        `;
    }

    /**
     * Set a tab as active and update content.
     * 
     * @param {string} tab_id - Tab ID to activate.
     */
    set_active_tab(tab_id) {
        if (!this.content.data[tab_id]) {
            console.error(`Tab ID "${tab_id}" does not exist in content data.`, this.content.data);
            return;
        }
        const tab_elements = $('.header_menu_item');
        tab_elements.removeClass('active');
        $(`#menu_${tab_id}`).addClass('active');
        this.content.update_body_content(tab_id);
    }

    /**
     * Add navigation events for tabs using keys or clicks.
     * 
     * @param {Array} tabs - List of tab objects.
     */
    add_events(tabs) {
        if (!Array.isArray(tabs) || tabs.length === 0) {
            console.warn('No tabs available for navigation.');
            return;
        }
        const tab_elements = $('.header_menu_item');
        let active_id = tabs[0].id;

        const update_active_tab = (new_id) => {
            this.set_active_tab(new_id);
            active_id = new_id;
        };

        $(document).on('keydown', (e) => {
            if ($(document.activeElement).is('input, textarea')) return;
            const is_tooltip_visible = $('#tooltip').is(':visible');
            if (is_tooltip_visible) return;
            if (e.key === 'a' || e.key === 'A') {
                const current_index = tabs.findIndex(tab => tab.id === active_id);
                const new_index = (current_index - 1 + tabs.length) % tabs.length;
                update_active_tab(tabs[new_index].id);
            } else if (e.key === 'd' || e.key === 'D') {
                const current_index = tabs.findIndex(tab => tab.id === active_id);
                const new_index = (current_index + 1) % tabs.length;
                update_active_tab(tabs[new_index].id);
            }
        });
        
        $(tab_elements).on('click', (e) => {
            const id = $(e.currentTarget).data('id');
            update_active_tab(id);
        });
    }
}
