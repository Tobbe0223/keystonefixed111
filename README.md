# Keystone - Framework Core

![keystone_banner](https://github.com/user-attachments/assets/bb974332-ab44-4ff6-9534-9bace315b40c)

## 🌍 Overview

Keystone is a comprehensive and adaptable server framework for FiveM. 
Originally developed as `boii_core` for a personal server howver, as it developed, it began consuming more time than anticipated, diverting attention from other work. 
Due to this the decision was made to transition it into a open-source project.

It's important to clarify that Keystone was not developed to compete with established "roleplay frameworks." 
Instead, it's designed to be modular and flexible, easily adaptable not just for roleplay but also for survival, racing, or any other type of server with minimal tweaks.

The focus here isn't on packing in every possible feature; it's about creating something enjoyable and sharing it with the community.

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

### Inventory  

The core includes a full grid-based inventory system, designed for flexibility and ease of use.  

- **Grid Layout:** Items are placed in a grid based style to create a inventory management system.  
- **Hover Tooltips:** Displays item details when hovered over.  
- **Keypress Actions:** Items can be interacted with using configurable key presses on hover.  
- **Item Metadata:** Supports item quality, rarity, and additional custom data.  
- **Drag & Drop Support:** Allows item movement within the inventory or between inventories.  
- **Split & Stack Items:** Split stacks or merge them as needed.  
- **Weight System:** Items contribute to a total inventory weight..  
- **Multi-Inventory Support:** Handles multiple inventories, such as player, vehicle, or stash storage.  

Tip: If you are not a fan of grid based inventories set all items to `height = 1, width = 1` and it will function like a regular slot based inventory.

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

## 💹 Dependencies

- **[OxMySQL](https://github.com/overextended/oxmysql/releases)**
- **[FiveM Utils](https://github.com/keystonehub/fivem_utils/releases)**
- A database running MySQL 5.7.22 upwards or MariaDB 10.5.0 upwards.

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
