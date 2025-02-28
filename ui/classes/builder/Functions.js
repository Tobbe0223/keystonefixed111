/*
    Builder primarily runs through nui callbacks.
    *(make sure your code is secure)*

    You can use this section for internal functions if required.
*/

class Functions {
    constructor(resource_name, modal) {
        this.resource_name = resource_name;
        this.modal = modal;
    }

    /**
     * Dynamically triggers a function based on its action ID.
     * 
     * If the function doesn't exist in the class, send a post request to the resource name.
     * If modal data is provided in the action, use it dynamically.
     * 
     * @param {string} action_id - The ID of the function to call.
     * @param {Object} data - Data passed to the function.
     */
    trigger_function(action_id, data = {}) {
        const action = data.actions?.find(a => a.id === action_id);
        const modal_config = action?.modal;
        if (modal_config) {
            this.modal.create_modal({
                title: modal_config.title || 'Confirm Action',
                description: modal_config.description || 'Are you sure you want to perform this action?',
                inputs: modal_config.inputs || [],
                on_confirm: (inputs) => {
                    const request_data = { ...data, ...modal_config.on_confirm?.data, ...inputs };
                    const post_action = modal_config.on_confirm?.action || action_id;
                    $.post(`https://${this.resource_name}/${post_action}`, JSON.stringify(request_data)).done((response) => {
                        if (response.success) {
                            if (data.card_index !== undefined) {
                                update_card_data(data.card_index, response);
                            }
                            if (response.header) {
                                update_header_data(response.header);
                            }
                            notify({ type: 'success', header: 'Action Successful', message: 'Action completed successfully.', duration: 3000 });
                        } else {
                            notify({ type: 'error', header: 'Action Failed', message: response.error || 'An error occurred.', duration: 3000 });
                        }
                    });
                },
                on_cancel: modal_config.on_cancel ? () => notify(modal_config.on_cancel) : () => console.log('Action cancelled.'),
            });
        } else {
            this.execute_action(action_id, data);
        }
    }
    
    /**
     * Executes the specified action by calling the function or sending a POST request.
     * 
     * @param {string} action_id - The ID of the function to call.
     * @param {Object} data - Data passed to the function.
     */
    execute_action(action_id, data) {
        if (typeof this[action_id] === 'function') {
            this[action_id](data);
        } else {
            $.post(`https://${this.resource_name}/${action_id}`, JSON.stringify(data));
        }
    }

    /**
     * Opens a modal to allow the user to change their character's profile picture.
     */
    change_character_profile_picture() {
        this.modal.create_modal({
            title: 'Change Profile Picture',
            description: 'Enter the URL of your new profile picture:',
            inputs: [
                {
                    id: 'img_src',
                    type: 'text',
                    label: 'Image URL',
                    placeholder: 'Enter image URL here...',
                    required: true
                }
            ],
            on_confirm: (inputs) => {
                $.post(`https://${this.resource_name}/change_character_profile_picture`, JSON.stringify({ img_src: inputs.img_src })).done((response) => {
                    if (response.success) {
                        notify({
                            type: 'success',
                            header: 'Profile Picture Updated',
                            message: 'Your profile picture has been updated successfully.',
                            duration: 3000
                        });
                    } else {
                        notify({
                            type: 'error',
                            header: 'Update Failed',
                            message: response.message || 'Failed to update profile picture.',
                            duration: 3000
                        });
                    }
                });
            },
            on_cancel: () => {
                notify({
                    type: 'info',
                    header: 'Action Cancelled',
                    message: 'Profile picture update was cancelled.',
                    duration: 3000
                });
            }
        });
    }

    /**
     * Opens a modal to confirm saving character customization.
     */
    save_character_customisation(data) {
        this.modal.create_modal({
            title: 'Save Customisation',
            description: 'Are you sure you have finished customising?',
            on_confirm: () => {
                $.post(`https://${this.resource_name}/save_character_customisation`, JSON.stringify({ should_exit: data.should_exit })).done((response) => {
                    if (response.success) {
                        notify({
                            type: 'success',
                            header: 'Customisation Saved',
                            message: 'Your character customisation has been saved successfully.',
                            duration: 3000
                        });
                        $.post(`https://${this.resource_name}/close_ui`, JSON.stringify({}));
                    } else {
                        notify({
                            type: 'error',
                            header: 'Save Failed',
                            message: response.message || 'Failed to save customisation.',
                            duration: 3000
                        });
                    }
                });
            },
            on_cancel: () => {
                notify({
                    type: 'info',
                    header: 'Action Cancelled',
                    message: 'Customisation save was cancelled.',
                    duration: 3000
                });
            }
        });
    }

    /**
     * Handles UI closure.
     */
    close_ui() {
        $('.bg_layer').hide();
        $('#ui_layer').empty().fadeOut(500);
        $('#tooltip').fadeOut(500).remove();
        $.post(`https://keystone/close_ui`, JSON.stringify({}));
    }
}
