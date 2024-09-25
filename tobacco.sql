-- Create the delivery_box_stock table if it doesn't exist
CREATE TABLE IF NOT EXISTS `delivery_box_stock` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `box_name` VARCHAR(255) NOT NULL DEFAULT 'default_box',
    `stock` INT(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `box_name` (`box_name`)
);

-- Insert initial row for the default box
-- If there are multiple boxes, they can be tracked separately if needed
INSERT INTO `delivery_box_stock` (`box_name`, `stock`)
VALUES
    ('default_box', 0)
ON DUPLICATE KEY UPDATE `stock` = VALUES(`stock`);


-- Create a table to log delivery jobs
CREATE TABLE IF NOT EXISTS `delivery_logs` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `player_name` VARCHAR(255) NOT NULL,
    `delivery_time` DATETIME NOT NULL,
    PRIMARY KEY (`id`)
);


-- Create the stock table if it doesn't exist
CREATE TABLE IF NOT EXISTS `shop_stock` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `item_name` VARCHAR(255) NOT NULL,
    `stock` INT(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `item_name` (`item_name`)
);

-- Insert initial stock for different products (tobacco, cigarettes, cigars, vapes)
-- If stock for these items already exists, it will be updated
INSERT INTO `shop_stock` (`item_name`, `stock`)
VALUES
    ('crafting_tobacco', 0),
    ('cigarettes', 0),
    ('cigars', 0),
    ('vapes', 0)
ON DUPLICATE KEY UPDATE `stock` = VALUES(`stock`);



CREATE TABLE IF NOT EXISTS `player_lighters` (
    `player_id` VARCHAR(50) NOT NULL,
    `lighter_id` INT NOT NULL,
    PRIMARY KEY (`player_id`, `lighter_id`)
);
