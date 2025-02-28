class Modal {
    constructor(resource_name) {
        this.resource_name = resource_name;
    }

    /**
     * Creates a modal with a title, description, input fields, and action buttons.
     * 
     * @param {Object} options - Options for configuring the modal.
     * @param {string} options.title - The title of the modal.
     * @param {string} options.description - The description displayed in the modal.
     * @param {Array<Object>} [options.inputs=[]] - Input fields for the modal. Each input includes:
     *   - `id` (string): The unique ID for the input field.
     *   - `type` (string): The input type (e.g., "text", "number").
     *   - `label` (string): The label for the input field.
     *   - `placeholder` (string): Placeholder text for the input field.
     * @param {string|null} [options.additional_content=null] - Additional HTML content to include in the modal.
     * @param {Function} options.on_confirm - Callback executed when the "Confirm" button is clicked.
     */
    create_modal({ title, description, inputs = [], additional_content = null, on_confirm }) {
        const input_fields = (inputs || []).map(input => {
            if (input.type === 'number') {
                return `
                    <label for="${input.id}">${input.label || ''}</label>
                    <div class="input_wrapper">
                        <button class="input_button decrement"><i class="fas fa-minus"></i></button>
                        <input id="${input.id}" class="modal_input" type="number" min="1" value="1" placeholder="${input.placeholder || ''}" />
                        <button class="input_button increment"><i class="fas fa-plus"></i></button>
                    </div>
                `;
            } else {
                return `
                    <label for="${input.id}">${input.label || ''}</label>
                    <div class="input_wrapper">
                        <input id="${input.id}" class="modal_input" type="${input.type || 'text'}" placeholder="${input.placeholder || ''}" />
                    </div>
                `;
            }
        }).join('');
        const modal = $(`
            <div class="modal_overlay">
                <div class="modal">
                    <div class="modal_content">
                        <h2>${title}</h2>
                        <p>${description}</p>
                        ${input_fields || ''}
                        ${additional_content || ''}
                        <div class="button_wrapper">
                            <button id="modal_confirm">Confirm</button>
                            <button id="modal_cancel">Cancel</button>
                        </div>
                    </div>
                </div>
            </div>
        `);
        modal.find('.increment').click((e) => {
            const input_element = $(e.target).closest('.input_wrapper').find('input');
            const value = parseInt(input_element.val()) || 1;
            input_element.val(value + 1);
        });
        modal.find('.decrement').click((e) => {
            const input_element = $(e.target).closest('.input_wrapper').find('input');
            const value = parseInt(input_element.val()) || 1;
            if (value > 1) {
                input_element.val(value - 1);
            }
        });
        modal.find('#modal_confirm').click(() => {
            const input_values = (inputs || []).reduce((acc, input) => {
                acc[input.id] = modal.find(`#${input.id}`).val();
                return acc;
            }, {});
            if (on_confirm) on_confirm(input_values);
            this.close_modal();
        });
        modal.find('#modal_cancel').click(() => this.close_modal());
        $('#ui_layer').append(modal);
    }
    
    /**
     * Closes the modal by removing it from the DOM.
     */
    close_modal() {
        $('.modal_overlay').remove();
    }

    /**
     * Triggers a client-server event by posting data to the invoking resource.
     * 
     * Use caution and validate data on the server for security.
     * 
     * @param {string} event - The name of the event to trigger.
     * @param {Object} data - Data to send with the event.
    */
    trigger_event(event, data) {
        if (!this.resource_name) {
            console.log('Resource name is missing. Cannot send NUI event.');
            return;
        }
        $.post(`https://${this.resource_name}/${event}`, JSON.stringify(data));
    }
}