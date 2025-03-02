let UI_HEADER = null;
let UI_FOOTER = null;
let UI_CONTENT = null;
let NOTIFY = null;
let PROGRESS_CIRCLE = null;
let HUD = null;
let SPEEDO = null;
let DEATHSCREEN = null;
let INTERACT_DUI = null;

const handlers = {
    // UI Builder
    build: (data) => {
        $('#ui_layer').fadeIn(250);
        const content_keys = Object.keys(data.content).filter(key => data.content[key] !== null && data.content[key] !== undefined);
        data.header.tabs = content_keys.map(key => ({
            id: key,
            label: key.replace(/_/g, ' ').replace(/\b\w/g, char => char.toUpperCase()),
        }));
        UI_CONTENT = new Content(data.resource, data.content);
        UI_HEADER = new Header(data.resource, data.header, UI_CONTENT);
        UI_FOOTER = new Footer(data.resource, data.footer);
    },
    
    close_ui: () => {
        $('#tooltip').remove();
        $('#ui_layer').empty().fadeOut(250);
        UI_HEADER = null;
        UI_FOOTER = null;
        UI_CONTENT = null;
    },
    
    // Utility
    copy_to_clipboard: (data) => {
        const el = document.createElement('textarea');
        el.value = data.content;
        document.body.appendChild(el);
        el.select();
        document.execCommand('copy');
        document.body.removeChild(el);
    },

    // Hud
    init_hud: (data) => {
        HUD = new Hud(data.player_data, data.disabled_statuses);
        SPEEDO = new Speedometer();
        SPEEDO.build();
    },
    update_statuses: (data) => {
        if (HUD) {
            HUD.update_statuses(data.statuses);
        }
    },
    set_injury: (data) => {
        if (HUD) {
            HUD.set_injury(data.area, data.value)
        }
    },
    hud_focus: (data) => {
        if (HUD) {
            HUD.toggle_focus(data.focused);
        }
    },
    toggle_visibility: (data) => {
        if (HUD) {
            HUD.toggle_visibility(data.visibility);
        }
    },
    update_map: (data) => {
        if (HUD) {
            HUD.show_map();
            HUD.update_map(data.direction, data.road_name, data.distance);
        }
    },
    hide_map: () => {
        if (HUD) {
            HUD.hide_map();
            if (SPEEDO) {
                SPEEDO.hide();
            }
        }
    },
    close_hud: () => {
        if (HUD) {
            HUD.close();
        }
    },
    update_speedo: (data) => {
        if (SPEEDO) {
            SPEEDO.show();
            SPEEDO.update_speed(data.speed);
            SPEEDO.update_gear(data.gear);
            SPEEDO.update_fuel(data.fuel);
            SPEEDO.update_body_health(data.engine_health);
            SPEEDO.update_engine_health(data.body_health);
            SPEEDO.update_mileage(data.mileage);
        }
    },
    update_indicator: (data) => {
        if (SPEEDO) {
            SPEEDO.update_indicator(data.indicator, data.colour, data.animation);
        }
    },

    // Death screen
    show_death_screen: (data) => {
        DEATHSCREEN = new Deathscreen(data.data);
    },
    start_respawn: () => {
        if (DEATHSCREEN) {
            DEATHSCREEN.start_respawn_countdown();
        }
    },
    give_up: () => {
        if (DEATHSCREEN) {
            DEATHSCREEN.give_up();
        }
    },
    cancel_respawn: () => {
        if (DEATHSCREEN) {
            DEATHSCREEN.cancel_respawn();
        }
    },
    request_assistance: () => {
        if (DEATHSCREEN) {
            DEATHSCREEN.call_for_assistance();
        }
    },
    hide_death_screen: () => {
        if (DEATHSCREEN) {
            DEATHSCREEN.hide();
        }
    },

    // DUI
    show_dui: (data) => {
        if (INTERACT_DUI) {
            INTERACT_DUI.close();
        }
        INTERACT_DUI = new DUI(data.options);
    },
    close_dui: () => {
        if (INTERACT_DUI) {
            INTERACT_DUI.close();
        }
    },

};

window.addEventListener('message', function (event) {
    const data = event.data;
    const handler = handlers[data.action];
    if (handler) {
        handler(data);
    }
});

const ui_test = {
    /**
     * The resource name associated with the UI.
     * @type {string}
     */
    resource: 'keystone',

    /**
     * Header configuration for the UI.
     * @type {Object}
     */
    header: {
        /**
         * Left section of the header, containing an image and basic info.
         * @type {Object}
         */
        header_left: {
            image: 'https://placehold.co/64x64', // Image URL for the header.
            info_1: 'Placeholder Name', // First line of header info.
            info_2: 'Placeholder ID', // Second line of header info.
        },

        /**
         * Right section of the header, showing a row of options.
         * @type {Object}
         */
        header_right: {
            flex_direction: 'row', // Direction of the options in the header.
            options: [
                { icon: 'fa-solid fa-wallet', value: '0' }, // Wallet icon with a value.
                { icon: 'fa-solid fa-coins', value: '0' }, // Coins icon with a value.
            ],
        },
    },

    /**
     * Footer configuration, specifying actions and hotkeys.
     * @type {Object}
     */
    footer: {
        actions: [
            { id: 'close_ui', key: 'ESCAPE', label: 'Some Action' }, // Action to close the UI.
            { id: 'open_help', key: 'H', label: 'Some Other Action' }, // Action to open help.
        ],
    },

    /**
     * Content displayed in the UI, organized by type.
     * 
     * Content keys are used to add tab titles to the UI Builder header.
     * Some regex is use to allow for snake case key names e.g, player_inventory -> PLAYER INVENTORY.
     * 
     * @type {Object}
     */
    content: {

        cards: {
            type: 'cards', // Specifies this section uses cards.
            title: 'Example Cards', // Title displayed above the cards.
            // You can have as many cards as you like UI will scroll.
            cards: [
                {
                    // **optional** Define image.
                    image: {
                        src: 'https://placehold.co/64x64', // Image URL for the card.
                        size: { width: '64px', height: 'auto', border: '2px solid rgba(0, 0, 0, 0.5);' }, // Image size and border.
                        // **optional** Flag to indicate profile pictures. 
                        // Profile pictures can be changed by clicking on them typically you would only include this on the players header profile picture.
                        is_profile_picture: true,
                    },
                    title: 'Card Title', // Title displayed on the card.
                    description: 'Placeholder description.', // **optional** Card description text.
                    layout: 'row', // Layout for the card. Options: 'row', 'column'.
                    // **optional** On hover data for the card.
                    // If you want players to be able to perform actions this section is no longer optional.
                    // To perform actions on cards you must include the on_hover section and the actions.
                    on_hover: {
                        title: 'Hovered Card', // Tooltip title when hovered.
                        description: ['Detailed description for the card.'], // Tooltip description.
                        // **optional** Tooltip key-value pairs these are loaded into the tooltip below the description.
                        values: [
                            { key: 'Detail', value: 'Example Value' },
                            { key: 'Another Detail', value: 10 } 
                        ],
                        // **optional** Define actions to be performed when pushing the specified key whilst hovering a card.
                        // If you want players to be able to perform actions this section is no longer optional.
                        // id: This defines the function to trigger if added to keystone/public/classes/builder/Functions.js, or the NUI callback to post to.
                        actions: [
                            { id: 'some_function_or_callback_name', key: 'E', label: 'Do Something' }
                        ],
                    },
                },
            ],
        },

        inventory: {
            type: 'inventory', // Specifies this section uses grid-based inventory.
            // Main player inventory
            player: {
                columns: 10, // Total number of columns in the players inventory grid.
                rows: 10, // Total number of rows in the players inventory grid.
                weight: 0, // Current weight of the inventory.
                max_weight: 50000, // Maximum weight capacity.
                // Players items
                // Items are placed on the grid by specifying their x, y, width, and height.
                items: [
                    {
                        id: 'item_1', // Unique ID for the item.
                        rarity: 'common', // Rarity of the item.
                        weight: 100, // Weight of the item.
                        amount: 3, // Amount of the item.
                        stackable: true, // Whether the item can stack.
                        quality: 80, // Quality percentage of the item.
                        x: 0, // X-coordinate on the grid (starting from 0).
                        y: 0, // Y-coordinate on the grid (starting from 0).
                        width: 3, // Width of the item in grid cells.
                        height: 2, // Height of the item in grid cells.
                        image: {
                            src: 'assets/images/items/weapon_advancedrifle.png', // Item image URL.
                            size: { width: 'auto', height: 'auto', border: 'transparent' }, // Image dimensions.
                        },
                        // Optional on-hover data
                        on_hover: {
                            title: 'Example Item', // Tooltip title.
                            description: ['A sample item for inventory display.'], // Tooltip description.
                            values: [
                                { key: 'Amount', value: 3 }, // Tooltip amount.
                                { key: 'Weight', value: '300g' }, // Tooltip weight.
                            ],
                            actions: [
                                { id: 'inventory_use_item', key: 'F', label: 'Use' }, // Use action.
                                { id: 'inventory_place_item', key: 'P', label: 'Place' }, // Place action.
                                { id: 'inventory_drop_item', key: 'D', label: 'Drop' }, // Drop action.
                            ],
                        },
                    },
                    {
                        id: 'item_2',
                        rarity: 'uncommon',
                        weight: 200,
                        amount: 2,
                        stackable: false,
                        quality: 90,
                        x: 4, // X-coordinate on the grid.
                        y: 1, // Y-coordinate on the grid.
                        width: 1, // Width of the item in grid cells.
                        height: 1, // Height of the item in grid cells.
                        image: {
                            src: 'assets/images/items/food_burger.png',
                            size: { width: 'auto', height: 'auto', border: 'transparent' },
                        },
                        on_hover: {
                            title: 'Another Example Item',
                            description: ['Another sample item for inventory display.'],
                            values: [
                                { key: 'Weight', value: '200g' },
                            ],
                        },
                    },
                ],
            },
            // Optional other inventory
            other: {
                title: 'Some Other Inventory', // Title for the other inventory.
                columns: 5, // Number of columns in the other inventory.
                rows: 5, // Number of rows in the other inventory.
                weight: 0, // Current weight of the inventory.
                max_weight: 20000, // Maximum weight capacity.
                items: [
                    {
                        id: 'item_3',
                        rarity: 'rare',
                        weight: 500,
                        amount: 1,
                        stackable: false,
                        quality: 100,
                        x: 1,
                        y: 1,
                        width: 2,
                        height: 2,
                        image: {
                            src: 'assets/images/items/test_item.png',
                            size: { width: 'auto', height: 'auto', border: 'transparent' },
                        },
                        on_hover: {
                            title: 'Rare Item',
                            description: ['A rare item for the other inventory.'],
                            values: [
                                { key: 'Weight', value: '500g' },
                            ],
                        },
                    },
                ],
            },
        },        

        table: {
            type: 'table', // Specifies this section uses a table.
            title: 'Example Table', // Title displayed above the table.
            columns: ['Header 1', 'Header 2', 'Header 3'], // Table column headers.
            rows: [
                ['Data 1', 'Data 2', 'Data 3'], // Table row 1.
                ['Data A', 'Data B', 'Data C'], // Table row 2.
                ['Example X', 'Example Y', 'Example Z'], // Table row 3.
            ],
        },

        list: {
            type: 'list', // Specifies this section uses a list.
            title: 'Example List', // Title displayed above the list.
            items: ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'], // List items.
        },

        inputs: {
            id: 'inputs', // Unique ID for the input groups.
            type: 'input_groups', // Specifies this section uses input groups.
            title: 'Example Inputs', // Title displayed above the input groups.
            groups: [
                {
                    header: 'Example Inputs', // Group header.
                    expandable: true, // Whether the group can expand or collapse.
                    inputs: [
                        { category: 'category1', id: 'value1', label: 'Example 1', type: 'number' }, // Numeric input field.
                        { category: 'category2', id: 'value2', label: 'Example 2', type: 'number' }, // Another numeric input field.
                    ],
                },
            ],
        },
    },
};


/*
window.postMessage({
    action: 'build',
    ...ui_test
}, '*');

$('body').css({
    'background': 'grey'
});
*/
