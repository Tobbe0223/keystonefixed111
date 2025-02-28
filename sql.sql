CREATE TABLE IF NOT EXISTS `players` (
    `unique_id` VARCHAR(255) NOT NULL,
    `char_id` INT UNSIGNED NOT NULL DEFAULT 1,
    `identifier` VARCHAR(255) NOT NULL,
    `first_name` VARCHAR(50) NOT NULL DEFAULT 'John',
    `middle_name` VARCHAR(50) DEFAULT NULL,
    `last_name` VARCHAR(50) NOT NULL DEFAULT 'Doe',
    `sex` VARCHAR(1) NOT NULL DEFAULT 'm',
    `date_of_birth` VARCHAR(10) NOT NULL DEFAULT '0000-00-00',
    `nationality` VARCHAR(255) NOT NULL DEFAULT 'United Kingdom',
    `profile_picture` TEXT NOT NULL DEFAULT 'assets/images/avatar_placeholder.jpg',
    `last_login` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
    `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (`unique_id`, `char_id`),
    UNIQUE (`identifier`),
    FOREIGN KEY (`unique_id`) REFERENCES `utils_users` (`unique_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_accounts` (
    `identifier` VARCHAR(255) NOT NULL,
    `account_type` VARCHAR(50) NOT NULL DEFAULT 'general',
    `balance` INT NOT NULL DEFAULT 0,
    `metadata` JSON NOT NULL DEFAULT (JSON_OBJECT()),
    PRIMARY KEY (`identifier`, `account_type`),
    FOREIGN KEY (`identifier`) REFERENCES `players` (`identifier`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_transactions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(255) NOT NULL,
    `account_type` VARCHAR(50) NOT NULL,
    `transaction_type` ENUM('deposit', 'withdraw', 'transfer') NOT NULL,
    `amount` INT NOT NULL,
    `balance_before` INT NOT NULL,
    `balance_after` INT NOT NULL,
    `target_or_sender` VARCHAR(255) DEFAULT NULL,
    `created` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `note` TEXT DEFAULT NULL,
    `metadata` JSON DEFAULT (JSON_OBJECT()),
    FOREIGN KEY (`identifier`) REFERENCES `player_accounts` (`identifier`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_alignments` (
    `identifier` VARCHAR(255) NOT NULL,
    `lawfulness` INT NOT NULL DEFAULT 500,
    `morality` INT NOT NULL DEFAULT 500,
    `title` VARCHAR(50) NOT NULL DEFAULT 'True Neutral',
    `lawful_actions` INT UNSIGNED NOT NULL DEFAULT 0,
    `unlawful_actions` INT UNSIGNED NOT NULL DEFAULT 0,
    `moral_actions` INT UNSIGNED NOT NULL DEFAULT 0,
    `immoral_actions` INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`identifier`),
    FOREIGN KEY (`identifier`) REFERENCES `players` (`identifier`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_inventories` (
    `identifier` VARCHAR(255) NOT NULL,
    `grid_columns` INT(2) NOT NULL DEFAULT 10,
    `grid_rows` INT(2) NOT NULL DEFAULT 10,
    `weight` INT NOT NULL DEFAULT 0,
    `max_weight` INT NOT NULL DEFAULT 80000,
    `items` JSON NOT NULL DEFAULT (JSON_OBJECT()),
    PRIMARY KEY (`identifier`),
    FOREIGN KEY (`identifier`) REFERENCES `players` (`identifier`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `other_inventories` (
    `unique_id` VARCHAR(255) NOT NULL,
    `owner` VARCHAR(255) DEFAULT NULL,
    `inventory_type` ENUM('glovebox', 'trunk', 'storage') NOT NULL,
    `grid_columns` INT(2) NOT NULL DEFAULT 5, 
    `grid_rows` INT(2) NOT NULL DEFAULT 5,
    `weight` INT NOT NULL DEFAULT 0,
    `max_weight` INT NOT NULL DEFAULT 80000,
    `items` JSON NOT NULL DEFAULT (JSON_OBJECT()),
    `last_update` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `created` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`unique_id`),
    FOREIGN KEY (`owner`) REFERENCES `players` (`identifier`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_spawns` (
    `identifier` VARCHAR(255) NOT NULL,
    `spawn_id` VARCHAR(50) NOT NULL DEFAULT 'last_location',
    `x` FLOAT NOT NULL DEFAULT -268.47,
    `y` FLOAT NOT NULL DEFAULT -956.98,
    `z` FLOAT NOT NULL DEFAULT 31.22,
    `w` FLOAT NOT NULL DEFAULT 208.54,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`identifier`, `spawn_id`),
    FOREIGN KEY (`identifier`) REFERENCES `players` (`identifier`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_styles` (
    `identifier` VARCHAR(255) NOT NULL,
    `style` JSON NOT NULL DEFAULT (JSON_OBJECT()),
    `outfits` JSON NOT NULL DEFAULT (JSON_OBJECT()),
    `has_customised` TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`identifier`),
    FOREIGN KEY (`identifier`) REFERENCES `players` (`identifier`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_roles` (
    `identifier` VARCHAR(255) NOT NULL,
    `role_id` VARCHAR(50) NOT NULL,
    `role_type` VARCHAR(50) NOT NULL,
    `rank` INT NOT NULL DEFAULT 0,
    `metadata` JSON NOT NULL DEFAULT (JSON_OBJECT()),
    PRIMARY KEY (`identifier`, `role_id`),
    FOREIGN KEY (`identifier`) REFERENCES `players` (`identifier`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_statuses` (
    `identifier` VARCHAR(255) NOT NULL,
    `health` INT NOT NULL DEFAULT 200,
    `armour` INT NOT NULL DEFAULT 0,
    `hunger` INT NOT NULL DEFAULT 100,
    `thirst` INT NOT NULL DEFAULT 100,
    `stress` INT NOT NULL DEFAULT 0,
    `stamina` INT NOT NULL DEFAULT 100,
    `oxygen` INT NOT NULL DEFAULT 100,
    `hygiene` INT NOT NULL DEFAULT 100,
    PRIMARY KEY (`identifier`),
    FOREIGN KEY (`identifier`) REFERENCES `players` (`identifier`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_flags` (
    `identifier` VARCHAR(255) NOT NULL,
    `is_dead` BOOLEAN NOT NULL DEFAULT 0,
    `is_downed` BOOLEAN NOT NULL DEFAULT 0,
    `is_handcuffed` BOOLEAN NOT NULL DEFAULT 0,
    `is_ziptied` BOOLEAN NOT NULL DEFAULT 0,
    `is_wanted` BOOLEAN NOT NULL DEFAULT 0,
    `is_jailed` BOOLEAN NOT NULL DEFAULT 0,
    `is_safezone` BOOLEAN NOT NULL DEFAULT 0,
    `is_grouped` BOOLEAN NOT NULL DEFAULT 0,
    `is_injured` BOOLEAN NOT NULL DEFAULT 0,
    `is_poisoned` BOOLEAN NOT NULL DEFAULT 0,
    `is_bleeding` BOOLEAN NOT NULL DEFAULT 0,
    `is_starving` BOOLEAN NOT NULL DEFAULT 0,
    `is_dehydrated` BOOLEAN NOT NULL DEFAULT 0,
    PRIMARY KEY (`identifier`),
    FOREIGN KEY (`identifier`) REFERENCES `players` (`identifier`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_injuries` (
    `identifier` VARCHAR(255) NOT NULL,
    `head` INT NOT NULL DEFAULT 0,
    `upper_torso` INT NOT NULL DEFAULT 0,
    `lower_torso` INT NOT NULL DEFAULT 0,
    `forearm_right` INT NOT NULL DEFAULT 0,
    `hand_right` INT NOT NULL DEFAULT 0,
    `thigh_right` INT NOT NULL DEFAULT 0,
    `calf_right` INT NOT NULL DEFAULT 0,
    `foot_right` INT NOT NULL DEFAULT 0,
    `forearm_left` INT NOT NULL DEFAULT 0,
    `hand_left` INT NOT NULL DEFAULT 0,
    `thigh_left` INT NOT NULL DEFAULT 0,
    `calf_left` INT NOT NULL DEFAULT 0,
    `foot_left` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`identifier`),
    FOREIGN KEY (`identifier`) REFERENCES `players` (`identifier`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_effects` (
    `identifier` VARCHAR(255) NOT NULL,
    `effect_id` VARCHAR(255) NOT NULL,
    `effect_type` VARCHAR(50) NOT NULL,
    `label` VARCHAR(255) NOT NULL,
    `description` TEXT NOT NULL,
    `icon` VARCHAR(255) DEFAULT NULL,
    `applied` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`identifier`, `effect_id`),
    FOREIGN KEY (`identifier`) REFERENCES `players` (`identifier`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
