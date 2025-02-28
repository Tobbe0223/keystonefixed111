/*
    Main content class for the UI builder.

    Since the builder covers a few different things.. and an inventory... 
    This section is a bit of a spaghetti highway. 

    It will be improved over time. 

    Some things are not yet implementend, mainly the item actions.
*/

class Content {
    constructor(invoking_resource, data) {
        this.resource_name = invoking_resource;
        this.data = data;
        this.modal = new Modal(invoking_resource);
        this.functions = new Functions(invoking_resource, this.modal);
        if (!$('#body_content').length) {
            this.create_body_content();
            $('body').append('<div id="tooltip" class="tooltip"></div>');
        }
        this.inventory_handlers = this.setup_inventory_handlers();
        this.active_item_ui = null;
        this.active_item_inventory = null;
        this.drag_image = null;
        this.hotbar_slots = 6;
    }

    /**
     * Creates the main content layer and background vignette for the UI.
     * Appends these elements to the `#ui_layer` container.
     */
    create_body_content() {
        const content = $('<div id="body_content"></div>');
        const bg_layer = $('<div class="bg_layer"></div>');
        $('#ui_layer').append(bg_layer);
        $('#ui_layer').append(content);
    }

    /**
     * Updates the content of the body based on the provided tab data or tab ID.
     * Handles event bindings and drag-and-drop functionality for slot inventories.
     *
     * @param {string|Object} tab_id_or_data - The ID of the tab or the tab data object.
     */
    async update_body_content(tab_id_or_data) {
        const tab_data = typeof tab_id_or_data === 'string' ? this.data[tab_id_or_data] : tab_id_or_data;
        $('#body_content').html(tab_data ? await this.build_content(tab_data) : '<p>No data available for this tab.</p>');
        if (tab_data) {
            const tab_type_map = { inventory: () => this.add_inventory_drag(tab_data) };
            (tab_type_map[tab_data.type] || (() => this.add_events(tab_data)))();
        }
    }

    /**
     * Builds the HTML content for a given tab's data.
     * Determines the content type and creates the appropriate content structure.
     *
     * @param {Object} tab_data - The data for the tab to build content for.
     * @returns {Promise<string>} - The HTML string representing the built content.
     */
    async build_content(tab_data) {
        if (!tab_data) {
            return '<p>No data available for this tab.</p>';
        }
        if (tab_data.hotbar_slots) {
            this.hotbar_slots = tab_data.hotbar_slots;
        }
        const content = await this.render_content(tab_data);
        const class_map = { inventory: 'inv_content' }
        const content_class = class_map[tab_data.type] || 'content';
        return `<div class="${content_class}">${content}</div>`;
    }

    /**
     * Renders the content based on the type specified in the data object.
     * Uses a mapping of content types to rendering functions.
     *
     * @param {Object} data - The data object containing the type and content for rendering.
     * @returns {Promise<string>} - The rendered HTML string for the content.
     */
    async render_content(data) {
        const self = this
        const render_map = {
            form: () => this.build_form(data),
            list: () => this.build_list(data),
            table: () => this.build_table(data),
            cards: () => this.build_cards(data),
            input_groups: () => this.build_input_groups(data),
            inventory: () => this.build_inventory({ player: data.player, other: data.other }),
        };
        return render_map[data.type]?.() || '<p>Unknown content type.</p>';
    }

    // Inventory Functions

    /**
     * Builds a grid-based inventory layout.
     * Items are positioned based on their x and y coordinates within the grid.
     *
     * @param {Object} player - Data for the players inventory.
     * @param {Object} other - Data for the secondary inventory.
     * @returns {string} - The combined HTML for the player and other inventory sections.
     */
    build_inventory({ player, other }) {
        return [player && this.build_single_inventory({ title: 'Backpack', ...player, key: 'player', has_hotbar: true }), other && this.build_single_inventory({ title: other.title || 'Other', ...other, key: 'other' })].filter(Boolean).join('');
    }

    /**
     * Builds a single grid-based inventory section with hotbar and quality/durability support.
     *
     * @param {Object} params - Configuration object for the inventory section.
     * @param {string} params.title - The title of the inventory section.
     * @param {number} params.columns - The number of columns in the grid.
     * @param {number} params.rows - The number of rows in the grid.
     * @param {Array} [params.items=[]] - The items in the inventory section.
     * @param {string} params.key - A key identifying the inventory (e.g., "player" or "other").
     * @param {number} params.weight - The current weight of the inventory.
     * @param {number} params.max_weight - The maximum weight capacity of the inventory.
     * @returns {string} - The HTML for the inventory section.
     */
    build_single_inventory({ title, columns, rows, items = [], key, weight, max_weight }) {
        const weight_info = `${weight || 0}/${max_weight || 0}g`;
        const grid_style = `
            display: grid;
            grid-template-columns: repeat(${columns}, 64px);
            grid-template-rows: repeat(${rows}, 64px);
            width: ${columns * 64}px;
            height: ${rows * 64}px;
            box-sizing: border-box;
        `;
        const grid = Array.from({ length: rows }, () => Array(columns).fill(null));
        items.forEach(item => {
            const { x, y, width = 1, height = 1 } = item;
            for (let i = 0; i < height; i++) {
                for (let j = 0; j < width; j++) {
                    if (x + j < columns && y + i < rows) {
                        grid[y + i][x + j] = item;
                    }
                }
            }
        });
        const grid_cells = grid.flat().map((item, index) => {
            if (item) {
                const rarity = item?.rarity ? `var(--rarity_${item.rarity.toLowerCase()})` : 'transparent';
                const position_style = `grid-column: ${item.x + 1} / span ${item.width}; grid-row: ${item.y + 1} / span ${item.height};`;

                return `
                    <div class="inventory_grid_item ${item.is_hotbar ? 'hotbar_item' : ''}"
                        style="${position_style} background: linear-gradient(0deg, ${rarity} 0%, var(--secondary_background) 40%, var(--background) 80%); border: 1px solid ${rarity};"
                        data-inventory="${key}" 
                        data-x="${item.x}" 
                        data-y="${item.y}"
                        draggable="true">
                        <img src="${item.image.src}" alt="${item.id}" style="width: ${item.image.size.width}; height: ${item.image.size.height}; border: ${item.image.size.border};" />
                        
                        ${item.amount > 1 ? `<span class="item_quantity">${item.amount}x</span>` : ''}
                        
                        ${item.is_hotbar ? `<span class="hotbar_slot">${item.hotbar_slot}</span>` : ''}

                        ${item.quality ?? item.durability ? `
                            <div class="rarity_progress_bar">
                                <div style="width: ${item.quality ?? item.durability}%; height: 100%; background: ${rarity};"></div>
                            </div>
                        ` : ''}
                    </div>`;
            }
            return `<div class="inventory_grid_cell"></div>`;
        });
        return `        
            <div class="inventory_grid ${key}_inventory">
                <h3 class="inv_header">${title} <span>${weight_info}</span></h3>
                <div class="inventory_grid_container" style="${grid_style}">
                    ${grid_cells.join('')}
                </div>
            </div>`;
    }

    /**
     * Handles drag-and-drop functionality for inventory items within a grid system.
     *
     * - Supports moving items within and between inventories.
     * - Ensures valid placement based on grid constraints.
     * - Updates UI elements and tooltip behavior dynamically.
     *
     * @param {Object} tab_data - The inventory data containing items and grid info.
     */
    add_inventory_drag(tab_data) {
        const self = this;
        let is_dragging = false, original_item = null, floating_item = null, grid_size = null;

        const start_drag = (e, $item) => {
            const inventory_key = $item.data('inventory');
            const x = parseInt($item.attr('data-x'), 10);
            const y = parseInt($item.attr('data-y'), 10);
            const inventory_items = tab_data[inventory_key]?.items;
            grid_size = tab_data[inventory_key] ? { columns: tab_data[inventory_key].columns, rows: tab_data[inventory_key].rows } : null;
            const item_data = inventory_items?.find(itm => itm.x === x && itm.y === y);
            if (!item_data) return console.warn(`[Grid Drag Start] No item found at (${x}, ${y})`);
            original_item = { inventory_key, item_data, x, y };
            is_dragging = true;
            floating_item = create_floating_item(item_data, e.pageX, e.pageY);
            $item.addClass('dragging');
            self.active_item_inventory = item_data;
            $('#tooltip').hide();
            e.preventDefault();
        };

        const update_drag = (e) => {
            if (!is_dragging || !floating_item) return;
            floating_item.css({ left: `${e.pageX - 32}px`, top: `${e.pageY - 32}px` });
            $('#tooltip:visible').css({ left: `${e.pageX + 15}px`, top: `${e.pageY + 15}px` });
        };

        const stop_drag = (e) => {
            if (!is_dragging || !original_item || !floating_item) return;
            const inventory = ['player', 'other'].find(inv => is_mouse_inside_grid(e, $(`.inventory_grid.${inv}_inventory`)));
            if (!inventory) return console.warn('[Stop Drag] Dropped outside inventory, reverting.'), revert_drag();
            const grid_offset = $(`.inventory_grid.${inventory}_inventory`).offset();
            const target_x = Math.floor((e.pageX - grid_offset.left) / 64);
            const target_y = Math.floor((e.pageY - grid_offset.top) / 64);
            if (check_valid_position(original_item.item_data, target_x, target_y, tab_data[inventory]?.items || [], grid_size)) {
                self.move_item(tab_data, original_item.inventory_key, original_item.x, original_item.y, inventory, target_x, target_y);
            } else {
                console.warn('[Stop Drag] Move Invalid, Reverting Position');
                self.move_item(tab_data, original_item.inventory_key, original_item.x, original_item.y, original_item.inventory_key, original_item.x, original_item.y);
            }
            self.active_item_inventory = null;
            revert_drag();
        };

        const is_mouse_inside_grid = (e, $grid) => {
            if (!$grid.length) return false;
            const offset = $grid.offset();
            return (e.pageX >= offset.left && e.pageX <= offset.left + $grid.width() &&
                    e.pageY >= offset.top && e.pageY <= offset.top + $grid.height());
        };

        const revert_drag = () => {
            floating_item?.remove();
            floating_item = null;
            original_item = null;
            is_dragging = false;
            $('.inventory_grid_item').removeClass('dragging');
            $('#tooltip').hide();
        };

        const check_valid_position = (item, target_x, target_y, grid_items, grid_size) => {
            if (target_x < 0 || target_y < 0 || target_x + item.width > grid_size.columns || target_y + item.height > grid_size.rows) return false;
            return !grid_items.some(other_item => {
                if (other_item === item) return false;
                return (target_x < other_item.x + other_item.width && target_x + item.width > other_item.x &&
                        target_y < other_item.y + other_item.height && target_y + item.height > other_item.y);
            });
        };

        const create_floating_item = (item, mouse_x, mouse_y) => {
            return $('<div class="floating-item"></div>').css({
                position: 'absolute',
                width: `${item.width * 64}px`,
                height: `${item.height * 64}px`,
                background: 'rgba(255, 255, 255, 0.5)',
                border: '1px solid #fff',
                zIndex: 1000,
                left: `${mouse_x - (item.width * 64) / 2}px`,
                top: `${mouse_y - (item.height * 64) / 2}px`,
            }).appendTo('body');
        };

        const hover_item = ($item) => {
            if (is_dragging) return;
            const inventory_key = $item.data('inventory');
            const x = parseInt($item.attr('data-x'), 10);
            const y = parseInt($item.attr('data-y'), 10);
            const item_data = tab_data[inventory_key]?.items.find(itm => itm.x === x && itm.y === y);
            const is_other_inventory = inventory_key === 'other';
            $item.toggleClass('hovered', !!item_data);
            if (item_data) {
                self.active_item_inventory = item_data;
                $('#tooltip').html(self.update_tooltip(item_data, is_other_inventory)).show();
                $(document).on('mousemove.tooltip', (e) => {
                    const tooltip = $('#tooltip');
                    let tooltip_x = e.pageX + 15, tooltip_y = e.pageY + 15;
                    if (tooltip_x + tooltip.outerWidth() > $(window).width()) tooltip_x = e.pageX - 15 - tooltip.outerWidth();
                    if (tooltip_y + tooltip.outerHeight() > $(window).height()) tooltip_y = e.pageY - 15 - tooltip.outerHeight();
                    tooltip.css({ left: `${tooltip_x}px`, top: `${tooltip_y}px` });
                });
            } else {
                self.active_item_inventory = null;
                $('#tooltip').hide();
                $(document).off('mousemove.tooltip');
            }
        };

        $(document).off('mousedown mousemove mouseup')
            .on('mousedown', '.inventory_grid_item', (e) => start_drag(e, $(e.currentTarget)))
            .on('mousemove', update_drag)
            .on('mouseup', stop_drag)
            .on('mouseenter', '.inventory_grid_item', (e) => hover_item($(e.currentTarget)))
            .on('mouseleave', '.inventory_grid_item', () => $('#tooltip').hide());
    }

    /**
     * Moves an item between inventory grid positions or between different inventories.
     * 
     * This function updates item positions within an inventory system that uses a grid-based layout.
     * It ensures items are correctly moved, stacked (if applicable), or swapped between inventories.
     *
     * @param {Object} tab_data - The inventory data containing all items for different inventories.
     * @param {string} source_inventory - The key of the source inventory (e.g., "player", "other").
     * @param {number} source_x - The X coordinate of the item in the source inventory.
     * @param {number} source_y - The Y coordinate of the item in the source inventory.
     * @param {string} target_inventory - The key of the target inventory.
     * @param {number} target_x - The X coordinate of the new item position.
     * @param {number} target_y - The Y coordinate of the new item position.
     */
    move_item(tab_data, source_inventory, source_x, source_y, target_inventory, target_x, target_y) {
        const self = this;
        const src_items = tab_data[source_inventory]?.items || [];
        const tgt_items = tab_data[target_inventory]?.items || [];
        const src_idx = src_items.findIndex(itm => itm.x === source_x && itm.y === source_y);
        if (src_idx === -1) return console.warn(`[Move Item] No item found at (${source_x}, ${source_y}) in "${source_inventory}".`);
        function update_inventory() {
            tab_data[source_inventory].items = src_items;
            tab_data[target_inventory].items = tgt_items;
            $(`.inventory_grid_item[data-x="${source_x}"][data-y="${source_y}"][data-inventory="${source_inventory}"]`).attr("data-x", target_x).attr("data-y", target_y);
            tab_data[source_inventory].weight = self.calculate_inventory_weight(src_items);
            tab_data[target_inventory].weight = self.calculate_inventory_weight(tgt_items);
            self.update_body_content(tab_data);
        }
        const item_to_move = src_items.splice(src_idx, 1)[0];
        const tgt_idx = tgt_items.findIndex(itm => itm.x === target_x && itm.y === target_y);
        if (tgt_idx === -1) {
            item_to_move.x = target_x;
            item_to_move.y = target_y;
            tgt_items.push(item_to_move);
            update_inventory();
            return;
        }
        const target_item = tgt_items[tgt_idx];
        if (item_to_move.id === target_item.id && target_item.stackable !== false) {
            const max_stack = target_item.stackable === true ? Infinity : target_item.stackable;
            const total_qty = target_item.amount + item_to_move.amount;
            target_item.amount = Math.min(total_qty, max_stack);
            if (total_qty > max_stack) {
                item_to_move.amount = total_qty - max_stack;
                tgt_items.push(item_to_move);
            }
            update_inventory();
            return;
        }
        [item_to_move.x, item_to_move.y, target_item.x, target_item.y] = [target_x, target_y, source_x, source_y];
        src_items.push(target_item);
        tgt_items[tgt_idx] = item_to_move;
        update_inventory();
        $.post(`https://${GetParentResourceName()}/inventory_move_item`, JSON.stringify({ source_inventory, source_x, source_y, target_inventory, target_x, target_y }));
    }
    
    /**
     * Calculates the total weight of items in an inventory.
     *
     * @param {Array<Object>} items - The array of items in the inventory.
     * @returns {number} - The total weight of all items in the inventory.
     */
    calculate_inventory_weight(items) {
        return items.reduce((total, item) => total + ((item.weight || 0) * (item.amount || 1)), 0);
    }

    /**
     * Sets up inventory action handlers.
     *
     * @returns {Object} - An object containing the handlers for various inventory actions.
     */
    setup_inventory_handlers() {
        const self = this;
        return {
            inventory_destroy_item: (data, tab_data) => {
                const { x, y } = data;
                const source_inventory = 'player';
                if (!source_inventory || x == null || y == null) {
                    console.warn(`[Handler] Invalid data provided. Source Inventory: ${source_inventory}, Position: (${x}, ${y})`);
                    return;
                }
                const items = tab_data[source_inventory]?.items;
                if (!items) {
                    console.warn(`[Handler] Invalid source inventory: ${source_inventory}`);
                    return;
                }
                this.modal.create_modal({
                    title: 'Confirm Destroy',
                    description: `Are you sure you want to destroy ${data.amount}x ${data.on_hover.title}?`,
                    on_confirm: () => {
                        const index = items.findIndex(itm => itm.x === x && itm.y === y);
                        if (index !== -1) {
                            items.splice(index, 1);
                            const $cell = $(`.inventory_grid_item[data-inventory="${source_inventory}"][data-x="${x}"][data-y="${y}"]`);
                            $cell.empty().removeAttr('draggable').css('background', '');
                        } else {
                            console.warn(`[Handler] No item found at (${x}, ${y}) for inventory ${source_inventory}.`);
                        }
                        self.update_body_content(tab_data);
                    },
                    on_cancel: () => {
                        notify({
                            type: 'info',
                            header: 'Delete Cancelled',
                            message: 'Character delete was cancelled.',
                            duration: 3000,
                        });
                    },
                });
            },

            inventory_inspect_item: (data) => {
                console.log(`[Handler] Inspect item triggered for position (${data.x}, ${data.y}). Placeholder logic.`);
            },

            inventory_modify_item: (data) => {
                console.log(`[Handler] Modify item triggered for position (${data.x}, ${data.y}). Placeholder logic.`);
            },
        };
    }
    
    /**
     * Triggers a specific inventory action handler.
     *
     * Executes the corresponding handler based on the provided action ID. 
     * If no handler is found, it logs a warning.
     *
     * @param {string} action_id - The unique identifier for the inventory action.
     * @param {Object} data - The data related to the action being triggered (e.g., item info).
     * @param {Object} tab_data - The inventory data for updating UI or processing changes.
     */
    trigger_inventory_action(action_id, data, tab_data) {
        const handler = this.inventory_handlers[action_id];
        if (handler) handler(data, tab_data);
        else console.warn(`[Handler] No handler found for action: ${action_id}`);
    }
    
    // Form Functions

    /**
     * Fetches a list of nationalities.
     *
     * Retrieves nationalities from a JSON file located at `/ui/data/nationalities.json`.
     * Ensures error handling for failed requests or invalid data formats.
     *
     * @returns {Promise<string[]>} - A promise resolving to an array of nationality names.
     */
    async fetch_nationalities() {
        try {
            const response = await fetch('/ui/data/nationalities.json');
            if (!response.ok) throw new Error('Failed to load nationalities data');
            const data = await response.json();
            return data.map(nat => nat.name);
        } catch (error) {
            console.error(error);
            return [];
        }
    }

    /**
     * Builds a dynamic HTML form based on the provided data.
     *
     * Generates a form using a given structure that defines fields, types, and attributes.
     * 
     * Special Handling:
     * - Automatically populating options for nationality selection fields.
     * - Handling various input types (e.g., text, select, checkbox, textarea, date).
     *
     * @param {Object} data - The configuration object for the form, including fields and attributes.
     * @param {Array} data.fields - An array of field definitions with `id`, `type`, `label`, and other attributes.
     * @param {string} [data.title] - The title of the form.
     * @param {string} [data.id] - The ID for the form element.
     * @returns {Promise<string>} - A promise resolving to the HTML content of the form.
     */
    async build_form(data) {
        if (!data.fields || !Array.isArray(data.fields)) {
            return '<p>Invalid form data format</p>';
        }
        const nationalities_fields = data.fields.find(field => field.id === 'nationality');
        if (nationalities_fields && nationalities_fields.type === 'select') {
            nationalities_fields.options = await this.fetch_nationalities();
        }
        const content = data.fields.map(field => {
            const required = field.required ? 'required' : '';
            const label = field.type !== 'checkbox' ? `<label for="${field.id}">${field.label || ''}${field.required ? ' *' : ''}</label>` : '';
            let input;
            switch (field.type) {
                case 'select':
                    if (field.options) {
                        const select_options = field.options.map(option =>
                            `<div class="custom_option" data-value="${option.toLowerCase()}">${option}</div>`
                        ).join('');
                        input = `
                            <div id="${field.id}" class="custom_select" data-options='${JSON.stringify(field.options)}'>
                                <div class="custom_selected">Select ${field.label || ''}</div>
                            </div>
                            <div class="custom_dropdown hidden">
                                ${select_options}
                            </div>
                        `;
                    }
                    break;
                case 'textarea':
                    input = `<textarea id="${field.id}" class="form_input" placeholder="${field.placeholder}" ${required}></textarea>`;
                    break;
                case 'checkbox':
                    input = `
                        <input id="${field.id}" type="checkbox" class="form_checkbox" ${required} />
                        <label for="${field.id}">${field.label || ''}${field.required ? ' *' : ''}</label>
                    `;
                    break;
                case 'date':
                    input = `
                        <div class="date_input">
                            <input id="${field.id}_dd" class="form_input date_part" type="text" maxlength="2" placeholder="DD" ${required} />
                            <span class="date_separator">/</span>
                            <input id="${field.id}_mm" class="form_input date_part" type="text" maxlength="2" placeholder="MM" ${required} />
                            <span class="date_separator">/</span>
                            <input id="${field.id}_yyyy" class="form_input date_part" type="text" maxlength="4" placeholder="YYYY" ${required} />
                        </div>
                    `;
                    break;
                default:
                    input = `<input id="${field.id}" class="form_input" type="${field.type}" placeholder="${field.placeholder}" ${required} />`;
            }
            return `<div class="form_field">${label}${input}</div>`;
        }).join('');
        return `
            <h3>${data.title || 'Form'}</h3>
            <form id="${data.id || 'ui_form'}" class="ui_form">
                ${content}
                <div class="form_actions">
                    <button type="button" id="submit_form">Submit</button>
                    <button type="button" id="reset_form">Reset</button>
                </div>
            </form>
        `;
    }

    // List Functions
    
    /**
     * Builds a list of data items.
     *
     * Generates an HTML unordered list (`<ul>`) containing items from the provided data.
     * Ensures that the data structure is valid before rendering.
     *
     * @param {Object} data - The configuration object for the list.
     * @param {Array} data.items - An array of items to display in the list.
     * @param {string} [data.title] - The title to display above the list.
     * @returns {string} - The generated HTML content for the list.
     */
    build_list(data) {
        if (!data.items || !Array.isArray(data.items)) {
            return '<p>Invalid data format</p>';
        }
        return `
            <h3>${data.title || 'Untitled'}</h3>
            <div class="content_container">
                <ul>
                    ${data.items.map(item => `<li>${item}</li>`).join('')}
                </ul>
            </div>
        `;
    }

    // Table Functions

    /**
     * Builds a table of data.
     *
     * Creates an HTML table with a header row (`<thead>`) and body rows (`<tbody>`) using the provided columns and rows from the data object.
     * Ensures that the data structure is valid before rendering.
     *
     * @param {Object} data - The configuration object for the table.
     * @param {Array} data.columns - An array of column names to be used as headers.
     * @param {Array} data.rows - A 2D array where each inner array represents a table row.
     * @param {string} [data.title] - The title to display above the table.
     * @returns {string} - The generated HTML content for the table.
     */
    build_table(data) {
        if (!data.columns || !Array.isArray(data.columns) || !data.rows || !Array.isArray(data.rows)) {
            return '<p>Invalid table data format</p>';
        }
        const table_header = data.columns.map(col => `<th>${col}</th>`).join('');
        const table_rows = data.rows.map(row => {
            return `<tr>${row.map(cell => `<td>${cell}</td>`).join('')}</tr>`;
        }).join('');
        return `
            <h3>${data.title || 'Untitled Table'}</h3>
            <div class="content_container">
                <table>
                    <thead><tr>${table_header}</tr></thead>
                    <tbody>${table_rows}</tbody>
                </table>
            </div>
        `;
    }

    // Cards Functions

    /**
     * Builds a display of cards.
     *
     * Generates an HTML layout for displaying multiple cards in a grid or list format. 
     * Includes an optional title and search bar for filtering cards dynamically.
     *
     * @param {Object} data - The configuration object for the cards display.
     * @param {Array} data.cards - An array of card objects to display.
     * @param {string} [data.title] - The title to display above the cards.
     * @param {Object} [data.search] - Configuration for the search bar, including a placeholder.
     * @returns {string} - The generated HTML content for the cards display.
     */
    build_cards(data) {
        if (!data.cards || !Array.isArray(data.cards)) {
            return '<p>Invalid card data format</p>';
        }
        const title_section = data.title ? `<h3>${data.title}</h3>` : '';
        const search_section = data.search ? `
            <div class="search_section">
                <input id="card_search_input" class="search_input" type="text" placeholder="${data.search.placeholder || 'Search...'}" />
            </div>
        ` : '';
        return `
            ${title_section}
            ${search_section}
            <div class="content_container" id="card_list">
                ${data.cards.map((card, index) => this.create_card(card, index)).join('')}
            </div>
        `;
    }

    /**
     * Creates a single card.
     *
     * Builds the HTML for a single card with optional elements like title, description, category, and image. 
     * Cards can also include hover data for performing actions.
     *
     * @param {Object} card - The card object containing its data.
     * @param {number} index - The index of the card in the array.
     * @param {string} [card.title] - The title of the card.
     * @param {string} [card.description] - The description text for the card.
     * @param {Object} [card.image] - Image configuration for the card, including source, size, and border.
     * @param {string} [card.category] - The category the card belongs to.
     * @param {Object} [card.on_hover] - Data to display in a tooltip on hover.
     * @returns {string} - The generated HTML content for the card.
     */
    create_card(card, index) {
        const title_section = card.title ? `<h4>${card.title}</h4>` : '';
        const category = card.category || 'Uncategorized';
        const image_border = card.image?.border || '2px solid transparent';
        const is_profile_picture = card.image?.is_profile_picture ? 'true' : 'false';
        const on_hover_data = card.on_hover && Object.keys(card.on_hover).length > 0 ? `data-on-hover='${JSON.stringify(card.on_hover)}'` : '';
        return `
            <div class="body_card ${card.layout || 'row'}" 
                data-card-index="${index}" 
                data-category="${category.toLowerCase()}" 
                ${on_hover_data}>
                <div class="body_card_image">
                    <img src="${card.image?.src || 'assets/images/avatar_placeholder.jpg'}" 
                        alt="cardimg" 
                        style="width: ${card.image?.size?.width || '3vw'}; height: ${card.image?.size?.height || '3vw'}; border: ${image_border}; ${is_profile_picture ? 'cursor: pointer' : ''}" 
                        data-is-profile-picture="${is_profile_picture}">
                </div>
                <div class="body_card_info">
                    ${title_section}
                    ${card.description ? `<p>${card.description}</p>` : ''}
                </div>
            </div>
        `;
    }

    /**
     * Filters cards when searching.
     *
     * Dynamically hides or shows cards based on the provided search query. 
     * Matches are determined by comparing the search query to the card's title or category.
     *
     * @param {string} query - The search query entered by the user.
     */
    filter_cards(query) {
        const search_query = query.toLowerCase();
        $('.body_card').each(function () {
            const title = $(this).data('title');
            const category = $(this).data('category');
            const matches = title.includes(search_query) || category.includes(search_query);
            $(this).toggle(matches);
        });
    }

    // Input Group Functions

    /**
     * Builds input groups section.
     *
     * Generates a dynamic input group based on the provided configuration. 
     * Each group can include various input types (e.g., number, text) and optional buttons for actions.
     * Supports expandable groups for better organization.
     *
     * @param {Object} data - The configuration object for the input groups section.
     * @param {Array} data.groups - An array of group objects, each defining a collection of inputs.
     * @param {string} [data.title] - The title displayed above the input groups section.
     * @param {Array} [data.buttons] - An optional array of button configurations for actions.
     * @param {string} [data.buttons[].label] - The label displayed on the button.
     * @param {string} [data.buttons[].action] - The action identifier for the button.
     * @returns {string} - The generated HTML content for the input groups section.
     */
    build_input_groups(data) {
        if (!data.groups || !Array.isArray(data.groups)) {
            return '<p>Invalid input groups format</p>';
        }
        this.input_groups_data = data;
        const buttons = data.buttons
            ? `<div class="buttons_section">
                ${data.buttons.map((button, index) => `
                    <button class="input_group_button" data-action-index="${index}">
                        ${button.label}
                    </button>
                `).join('')}
            </div>`
            : '';
        const content = data.groups.map((group, index) => {
            const inputs = group.inputs.map((input) => {
                if (input.type === 'number') {
                    return `
                        <div class="input_group_wrapper">
                            <label for="${input.id}">${input.label || ''}</label>
                            <div class="input_controls">
                                <button class="input_button decrement" ${input.category ? `data-action-category="${input.category}"` : ''} data-action-id="${data.id}" data-target="${input.id}">
                                    <i class="fas fa-minus"></i>
                                </button>
                                <input id="${input.id}" class="group_input" type="number" min="-1" value="-1" />
                                <button class="input_button increment" ${input.category ? `data-action-category="${input.category}"` : ''} data-action-id="${data.id}" data-target="${input.id}">
                                    <i class="fas fa-plus"></i>
                                </button>
                            </div>
                        </div>
                    `;
                } else if (input.type === 'text') {
                    return `
                        <div class="input_group_wrapper">
                            <label for="${input.id}">${input.label || ''}</label>
                            <input id="${input.id}" class="group_input" type="text" value="${input.default || ''}" placeholder="${input.placeholder || ''}" />
                        </div>
                    `;
                } else {
                    return `<p>Unsupported input type: ${input.type}</p>`;
                }
            }).join('');
            const expand_button = group.expandable ? `<button class="expand_button" data-group-index="${index}"><i class="fa-solid fa-plus"></i></button>` : '';
            return `
                <div class="input_group">
                    <h4>${group.header || 'Group'} ${expand_button}</h4>
                    <div class="group_inputs ${group.expandable ? 'hidden' : ''}" data-group-index="${index}">
                        ${inputs}
                    </div>
                </div>
            `;
        }).join('');
        return `
            <h3>${data.title || 'Input Groups'}</h3>
            <div class="input_groups_section">
                ${content}
            </div>
            ${buttons}
        `;
    }
    
    // On Hover Tooltip

    /**
     * Updates the tooltip content and appearance.
     *
     * Dynamically generates and returns the HTML for the tooltip based on the provided data.
     * This includes title, description, values, actions, and rarity.
     *
     * @param {Object} options - The data for the tooltip.
     * @param {Object} options.on_hover - Hover data containing title, description, values, and actions.
     * @param {string} [options.rarity] - The rarity level of the item, used for styling.
     * @param {boolean} is_other_inventory - Indicates if the tooltip is for the "other" inventory.
     * @returns {string} - The generated HTML content for the tooltip.
     */
    update_tooltip({ on_hover = {}, rarity }, is_other_inventory) {
        const { title, description = [], values = [], actions = [] } = on_hover;
        const desc_content = description.length ? `<div class="tooltip_description">${description.map(line => `<p>${line}</p>`).join('')}</div>` : '';
        const value_list = values.length ? `<div class="tooltip_values"><ul>${values.map(v => `<li><strong>${v.key}:</strong> <span>${v.value}</span></li>`).join('')}</ul></div>` : '';
        const action_keys = actions.length && !is_other_inventory ? `<div class="tooltip_actions">${actions.map(a => `<div class="tooltip_key_hint" data-action-id="${a.id}"><span class="tooltip_key">${a.key}</span> ${a.label}</div>`).join('')}</div>` : '';
        const rarity_badge = rarity ? `<div class="tooltip_rarity">${rarity}</div>` : '';
        return `<div class="tooltip_title" ${rarity ? `style="background: var(--rarity_${rarity.toLowerCase()})"` : ''}>${title || 'Details'}${rarity_badge}</div>${desc_content}${value_list}${action_keys}`;
    }
    
    // Event Listeners

    /**
     * Adds event listeners for UI interactions.
     *
     * Sets up various interactions for cards, inventory slots, forms, and tooltips.
     * Includes functionality for handling hover, drag-and-drop, keyboard shortcuts, and form submission/reset behaviors.
     *
     * @param {Object} tab_data - The data associated with the currently active tab.
     */
    add_events(tab_data) {
        const self = this;
        $(document).off('.custom_event');
        if (!$('#tooltip').length) $('body').append('<div id="tooltip" class="tooltip"></div>');

        self.active_item_ui = null;

        const reset_active_items = () => {
            $('#tooltip').hide();
            self.active_item_ui = null;
        };

        $('#body_content').off('mouseenter.custom_event mouseleave.custom_event', '.body_card').on('mouseenter.custom_event', '.body_card', function () {
            const on_hover_data = $(this).data('on-hover');
            if (on_hover_data) {
                self.active_item_ui = on_hover_data;
                $('#tooltip').html(self.update_tooltip({ on_hover: on_hover_data }, false)).show();
            }
        }).on('mouseleave.custom_event', '.body_card', reset_active_items);

        $(document).on('mousemove.custom_event', (e) => {
            $('#tooltip:visible').css({ top: e.pageY + 10, left: e.pageX + 10 });
        });

        $(document).off('keydown.custom_event').on('keydown.custom_event', e => {
            if (!$('#tooltip').is(':visible')) return;
            const active_item = self.active_item_inventory || self.active_item_ui;
            if (!active_item) return;
            const action = (active_item.actions || active_item.on_hover?.actions)?.find(a => a.key.toLowerCase() === e.key.toLowerCase());
            if (!action) return;
            e.preventDefault();
            if (tab_data.type === 'inventory') return self.trigger_inventory_action(action.id, active_item, tab_data);
            try {
                self.functions.trigger_function(action.id, active_item);
            } catch (error) {
                console.error(`[Keydown] Error triggering function: ${action.id}`, error);
            }
        });
        
        const handle_form_submission = () => {
            const form_id = $('.ui_form').attr('id');
            const missing_fields = [];
            const form_data = {};
            $('.ui_form .form_input, .ui_form .custom_select').each(function () {
                const $input = $(this);
                const field_id = $input.attr('id');
                const value = $input.val() || $input.find('.custom_selected').text();
                if ($input.is('[required]') && (!value || value.trim() === '')) {
                    missing_fields.push(field_id);
                }
                form_data[field_id] = value;
            });
            if (missing_fields.length > 0) {
                return;
            }
            self.functions.trigger_function(form_id, form_data);
        };
        $(document).off('click.custom_event', '#submit_form')
            .on('click.custom_event', '#submit_form', handle_form_submission)
            .off('click.custom_event', '#reset_form')
            .on('click.custom_event', '#reset_form', () => $('.ui_form')[0].reset());

        $(document).on('input', '.color_slider', function () {
            const [color_type] = $(this).attr('id').split('_');
            const color = ['red', 'green', 'blue'].map(c => $(`#${color_type}_${c}`).val());
            $(`#${color_type}_color_preview`).css('background', `rgb(${color.join(',')})`);
        });

        $(document).on('input.custom_event', '#card_search_input', function () {
            self.filter_cards($(this).val() || '');
        });

        $(document).on('click.custom_event', '.custom_select', function (event) {
            event.stopPropagation();
            const $current_select = $(this);
            const $current_dropdown = $current_select.next('.custom_dropdown');
            const is_open = !$current_dropdown.hasClass('hidden');
            $('.custom_dropdown').addClass('hidden');
            if (!is_open) {
                $current_dropdown.removeClass('hidden');
                $(document).one('click', () => {
                    $('.custom_dropdown').addClass('hidden');
                });
            }
        }).on('click.custom_event', '.custom_option', function (event) {
            event.stopPropagation();
            const $option = $(this);
            const $parent_dropdown = $option.closest('.custom_dropdown');
            const $parent_select = $parent_dropdown.prev('.custom_select');
            $parent_select.find('.custom_selected').text($option.text());
            $parent_select.attr('data-selected', $option.data('value'));
            $parent_dropdown.addClass('hidden');
        });

        $(document).on('click.custom_event', '.expand_button', function () {
            const group_index = $(this).data('group-index');
            const $inputs = $(`.group_inputs[data-group-index="${group_index}"]`);
            $inputs.toggleClass('hidden');
            $(this).html($inputs.hasClass('hidden') ? '<i class="fa-solid fa-plus"></i>' : '<i class="fa-solid fa-minus"></i>');
        });

        $(document).on('input.custom_event', '.group_input[type="number"]', function () {
            const id = $(this).attr('id');
            const action_id = $(this).closest('.input_controls').find('.increment').data('action-id');
            const category = $(this).closest('.input_controls').find('.increment').data('action-category') || null;
            const value = parseInt($(this).val(), 10);
            if (action_id) {
                self.functions.trigger_function(action_id, { category, id, value });
            }
        });
        
        $(document).on('click.custom_event', '.decrement, .increment', function () {
            const is_increment = $(this).hasClass('increment');
            const category = $(this).data('action-category') || null;
            const action_id = $(this).data('action-id');
            const id = $(this).data('target');
            const $input = $(`#${id}`);
            let value = parseInt($input.val(), 10);
            value = isNaN(value) ? (is_increment ? -1 : parseInt($input.attr('min'), 10) || -1) : value + (is_increment ? 1 : -1);
            const min = parseInt($input.attr('min'), 10) || -1;
            if (!is_increment && value < min) value = min;
            $input.val(value);
            if (action_id) self.functions.trigger_function(action_id, { category, id, value });
        });        

        $(document).off('click', 'img[data-is-profile-picture="true"]').on('click', 'img[data-is-profile-picture="true"]', function (e) {
            e.stopPropagation();
            const card_index = $(this).closest('.body_card').data('card-index');
            self.functions.trigger_function('change_character_profile_picture', { card_id: card_index });
        });
    }
}