class Footer {
    constructor(invoking_resource, data) {
        this.resource_name = invoking_resource;
        this.modal = new Modal(invoking_resource);
        this.functions = new Functions(invoking_resource, this.modal);
        $(document).ready(() => {
            this.build_footer(data);
            this.add_events(data.actions);
        });
    }

    /**
     * Builds the footer UI and appends it to the main UI layer.
     *
     * @param {Object} data - Data used to construct the footer.
     * @param {Array} [data.actions=[]] - List of actions to display in the footer, where each action includes:
     *     - `key`: The key that triggers the action.
     *     - `label`: The description of the action.
     */
    build_footer(data) {
        const actions = data.actions || [];
        $('#ui_layer .main_footer').remove();
        const actions_content = actions.map(action => `
            <div class="footer_action">
                <span class="footer_key">${action.key}</span> 
                <span class="footer_label">${action.label}</span>
            </div>
        `).join('');
        const content = `
            <div class="main_footer">
                <div class="footer_container">
                    ${actions_content}
                </div>
            </div>
        `;
        $('#ui_layer').append(content);
    }

    /**
     * Adds event listeners for footer actions.
     *
     * @param {Array} actions - List of actions with the following structure:
     *     - `key`: The key that triggers the action.
     *     - `id`: The unique identifier of the action.
     *     - `params`: Optional parameters to pass to the triggered function.
     *     - `modal`: Optional modal configuration for the triggered function.
     */
    add_events(actions) {
        $('.footer_action').on('click', () => {
            if ($(document.activeElement).is('input, textarea')) return;
        });

        $(document).on('keydown', (e) => {
            if ($(document.activeElement).is('input, textarea')) return;
            const action = actions.find(a => a.key.toLowerCase() === e.key.toLowerCase());
            if (action) {
                this.functions.trigger_function(action.id, action.params || {}, action.modal || {});
            }
        });
    }
}
