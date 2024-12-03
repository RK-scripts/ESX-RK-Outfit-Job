CREATE TABLE IF NOT EXISTS `player_outfits` (
    `identifier` VARCHAR(50) NOT NULL,
    `components` LONGTEXT NOT NULL,
    `props` LONGTEXT NOT NULL,
    PRIMARY KEY (`identifier`)
);

CREATE TABLE IF NOT EXISTS `job_outfits` (
    `id` INT AUTO_INCREMENT,
    `job` VARCHAR(50) NOT NULL,
    `label` VARCHAR(50) NOT NULL,
    `grade` INT NOT NULL,
    `components` LONGTEXT NOT NULL,
    `props` LONGTEXT NOT NULL,
    PRIMARY KEY (`id`)
);
