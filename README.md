# Keystone - Framework Core

## 🌍 Overview

Keystone is a comprehensive and adaptable server framework for FiveM. Originally developed as `boii_core` and released as an alpha, however I have recently begun to move all boii dev free resources over to a new open source location Keystone Hub to help create a clear separation between paid resources, and free open source. With this move, comes the planned BETA release of `boii_core` now `keystone`.

It's important to clarify that Keystone was not developed to compete with established "roleplay frameworks." Instead, it's designed to be modular, flexible, and easily adaptable for any other type of server with minimal tweaks. *(My personal plan is for a survival server in the future)*

Again, the focus here isn't on packing in every possible feature; it's just about creating something enjoyable and sharing it with the community.

---

## 🌐 Features 

- **Player Management:** Class-based player objects with a wide range of useful functions.  
- **Integrated Resources:** Includes a built-in loading screen, HUD, multi-character system, character customization, and grid-based inventory.  
- **UI Builder:** A simple and flexible tool for creating uniform UIs, both internally and externally.  
- **Player Roles:** Uses a role-based system instead of jobs or groups, with role types allowing for broader functionality.  
- **Usable Items:** Built-in support for consumables, weapons, and more, with integrated animations, props, and interaction handling.
- **Status System:** A complete system for tracking player flags, effects, and injuries.
- **Grid Based Inventory:** A fully integrated grid-based inventory system with hover tooltips and keypress actions for item interactions.
- **Additional Systems:** Integrated with `fivem_utils`, our open-source library, providing access to additional features such as player skills and reputation.

### Player Classes

Keystone uses the following player object classes:

- **Player:** Handles core player functions, e.g., `save_player`, `get_player_data`, `set_player_data`.  
- **Accounts:** Handles player account functions, e.g., `add_money`, `remove_money`, `get_account`.  
- **Effects:** Handles player effect functions, e.g., `get_effects`, `set_effects`, `clear_effects`.  
- **Flags:** Handles player flag functions, e.g., `get_flag`, `set_flag`, `reset_flags`.  
- **Identity:** Handles player identity functions, e.g., `get_identifier`, `get_full_name`, `change_name`.  
- **Injuries:** Handles player injury functions, e.g., `get_injuries`, `set_injury`, `clear_injury`.  
- **Inventory:** Handles player inventory functions, e.g., `get_inventory`, `add_item`, `remove_item`.  
- **Roles:** Handles player role functions, e.g., `get_role`, `has_role`, `add_role`, `remove_role`.  
- **Spawns:** Handles player spawn functions, e.g., `get_spawns`, `set_spawn`, `clear_spawns`.  
- **Statuses:** Handles player status functions, e.g., `get_status`, `set_status`, `reset_statuses`.  
- **Styles:** Handles player customization functions, e.g., `get_styles`, `set_style`, `add_outfit`, `remove_outfit`.  

### Modules

Modules extend player classes:

- **Characters:** Handles character functions, e.g., `get_characters`, `create_character`, `delete_character`.
- **Accounts:** Handles additional accounts functions, e.g., `log_transaction`.
- **Player:** Handles additional player functions, e.g., `save_all_players`.

### UI Builder

The UI Builder allows for easy creation of user interfaces across the server. 
It can be used interally or externally to create a variety of different UI's, this has been showcased in a few places throughout the core.
The intention here is to try and keep everything uniform. 

What you can do with it:

- **UI Elements:** Create cards, tables, lists, and input groups. Customize the element layouts, content, and actions.
- **Header:** Divided into three sections—left for server/player data, center for navigation tabs, and right for displaying information like cash or ID.
- **Footer:** Footer holds a key container lower right that can be used for key press actions e.g, disconnect, exit.
- **Inventory:** Use a grid-based inventory system, complete with item images, descriptions, and interactive tooltips.
- **Cards:** Use cards for displaying items with details on hover, providing information and action options.
- **Tables:** Display structured data clearly with headers and multiple rows.
- **Lists:** Display items in a straightforward list format.
- **Input Groups:** Collect input through fields grouped by type, with customizable labels and settings.

The cores multi-character, clothing, and inventory have all been created through the builder.

### Internal Resources

The core includes a small amount of server essential resources; 

- **Multi-Character:** The multi-character was created using the the cores UI builder, it has support for character limits and optional middle names.
- **Grid-Based Inventory:** Full grid based inventory system with support for other inventories, created using the cores ui builder.
- **Character Customisation:** Forced customisation location for first logins, this again is created using the UI builder.
- **Player HUD:** A status hud, speedometer and map container including streetnames and distance markers.
- **Player Statuses:** Full status system with support for hygiene, injuries, and detailed flag tracking. 
- **Death Screen:** Simple death screen works in tandem with the cores status system to allow players to give up, call for assistance, or respawn.

The core also gains access to some additional resources through `fivem_utils` our open source library, this covers things like progressbars, skill systems, notifications etc.

---

## 🚀 Why Choose Keystone?

### Pros:  
- **Structured & Scalable:** Uses a class-oriented approach to keep code organized and easy to expand.  
- **Lightweight:** Designed with a simple and easy-to-use API, featuring full export support.  
- **Uniform UI System:** The built-in UI builder ensures a consistent design across all core elements.  
- **Customizable:** Ideal for those wanting to "do their own thing" instead of relying on widely adopted frameworks.  

### Cons:  
- **Steep Learning Curve:** The class-based structure may be unfamiliar to developers used to procedural Lua.  
- **Limited Support:** Primarily a one-person project, with support limited to provided documentation.  
- **Not Trying to Reinvent the Wheel:** Covers essential features but isn’t aiming to introduce completely new mechanics.  
- **Well-Supported Alternatives Exist:** Other frameworks like Ox Core have larger communities and more built-in support.  

### Final Thoughts

If you’re looking for a fresh alternative to mainstream frameworks or want a lightweight, modular foundation for your server, Keystone is worth exploring. 
It’s not for everyone, but it offers a different approach for those ready to experiment.

---

## 💹 Dependencies

- **[OxMySQL](https://github.com/overextended/oxmysql/releases)**
- **[FiveM Utils](https://github.com/keystonehub/fivem_utils/releases)**

## 📦 Getting Started

### txAdminRecipe

The easiest way to get setup is by installing from the `recipe.yaml`

To do this follow the txAdmin setup process until your can choose your template.
From here select "Remote URL Template" and paste the following link.

```
https://raw.githubusercontent.com/keystonehub/txAdminRecipe/main/recipe.yaml
```

**Dont forget to customise the data sections and config to your liking.**

### Manual Install

Prior to manual installation make sure you have all of the dependencies listed above in your server.

1. Add the `fivem_utils` `REQUIRED.sql` into your database.
2. Add the `keystone` `sql.sql` into your database.
3. Then go back to `fivem_utils` and add the `keystone.sql` into your database.
4. Customise keystone core data and configs to suite your needs.
5. Add keystone and dependancies into your server resources.
6. Add `ensure keystone` into your server.cfg ensuring it is after any dependencies.
7. Restart the server and you should be up and running.

## 📝 Notes

- The core is currently in an early BETA state, bugs are to be expected.
- The core is just that, its a core, it is not a full server build, do not install expected more than what it is.
- Documenation is only partially completled right not, please be aware of this before trying to make a full server with this.
- UI elements are subject to change, mainly the hud, this is a hash together of two old unfinished hud projects, it could be a lot better.

## 🤝 Contributions

Contributions are more than welcome! 
If you would like to contribute to the core, or any other Keystone resource, please fork the repository and submit a pull request or contact through discord.

## 📝 Documentation

Documentation for the core is partially complete, it will be finished as soon as possible. 

**[Documentation](https://keystonehub.gitbook.io/keystone/keystone)**

## 📩 Support

Support for Keystone resources is primarily handled by the community.
Please do not join the discord expecting instant support. 

This is a **free** and **open source** resource after all. 

**[Discord](https://discord.gg/SjNhQV2YeN)**
