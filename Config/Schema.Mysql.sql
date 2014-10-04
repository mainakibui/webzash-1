CREATE TABLE `%_PREFIX_%groups` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`parent_id` int(11) DEFAULT NULL,
	`name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`affects_gross` int(1) NOT NULL DEFAULT '0',
        PRIMARY KEY(`id`),
	UNIQUE KEY `unique_id` (`id`),
	UNIQUE KEY `name` (`name`),
	KEY `id` (`id`),
	KEY `parent_id` (`parent_id`)
) DEFAULT CHARSET=utf8,
COLLATE=utf8_unicode_ci,
AUTO_INCREMENT=1,
ENGINE=InnoDB;

CREATE TABLE `%_PREFIX_%ledgers` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`group_id` int(11) NOT NULL,
	`name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`op_balance` float(25,2) DEFAULT '0.00' NOT NULL,
	`op_balance_dc` varchar(1) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`type` int(2) DEFAULT 0 NOT NULL,
	`reconciliation` int(1) NOT NULL DEFAULT '0',
	PRIMARY KEY(`id`),
	UNIQUE KEY `unique_id` (`id`),
	UNIQUE KEY `name` (`name`),
	KEY `id` (`id`),
	KEY `group_id` (`group_id`)
) DEFAULT CHARSET=utf8,
COLLATE=utf8_unicode_ci,
AUTO_INCREMENT=1,
ENGINE=InnoDB;

DROP TRIGGER IF EXISTS `check_%_PREFIX_%ledgers`;
DELIMITER //
CREATE TRIGGER `check_%_PREFIX_%ledgers` BEFORE INSERT ON `%_PREFIX_%ledgers`
FOR EACH ROW BEGIN
	SET NEW.op_balance_dc = UPPER(NEW.op_balance_dc);
	IF !(NEW.op_balance_dc <=> 'D' OR NEW.op_balance_dc <=> 'C') THEN
		SIGNAL SQLSTATE '12345' SET MESSAGE_TEXT = 'Invalid value for key op_balance_dc. Allowed values are char D or C';
	END IF;
	IF (NEW.op_balance < 0.0) THEN
		SIGNAL SQLSTATE '12345' SET MESSAGE_TEXT = 'op_balance cannot be less than 0.00.';
	END IF;
END
//
DELIMITER ;

CREATE TABLE `%_PREFIX_%tags` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`title` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`color` varchar(6) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`background` varchar(6) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	PRIMARY KEY(`id`),
	UNIQUE KEY `unique_id` (`id`),
	UNIQUE KEY `title` (`title`),
	KEY `id` (`id`)
) DEFAULT CHARSET=utf8,
COLLATE=utf8_unicode_ci,
AUTO_INCREMENT=1,
ENGINE=InnoDB;

CREATE TABLE `%_PREFIX_%entrytypes` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`label` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`description` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`base_type` int(2) NOT NULL,
	`numbering` int(2) NOT NULL,
	`prefix` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`suffix` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`zero_padding` int(2) DEFAULT 0 NOT NULL,
	`restriction_bankcash` int(2) DEFAULT 1 NOT NULL,
        PRIMARY KEY(`id`),
	UNIQUE KEY `unique_id` (`id`),
	UNIQUE KEY `label` (`label`),
	KEY `id` (`id`)
) DEFAULT CHARSET=utf8,
COLLATE=utf8_unicode_ci,
AUTO_INCREMENT=1,
ENGINE=InnoDB;

CREATE TABLE `%_PREFIX_%entries` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`tag_id` int(11) DEFAULT NULL,
	`entrytype_id` int(11) NOT NULL,
	`number` int(11) DEFAULT NULL,
	`date` datetime NOT NULL,
	`dr_total` float(25,2) DEFAULT '0.00' NOT NULL,
	`cr_total` float(25,2) DEFAULT '0.00' NOT NULL,
	`narration` varchar(500) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
        PRIMARY KEY (`id`),
	UNIQUE KEY `unique_id` (`id`),
	KEY `id` (`id`),
	KEY `tag_id` (`tag_id`),
	KEY `entrytype_id` (`entrytype_id`)
) DEFAULT CHARSET=utf8,
COLLATE=utf8_unicode_ci,
AUTO_INCREMENT=1,
ENGINE=InnoDB;

DROP TRIGGER IF EXISTS `check_%_PREFIX_%entries`;
DELIMITER //
CREATE TRIGGER `check_%_PREFIX_%entries` BEFORE INSERT ON `%_PREFIX_%entries`
FOR EACH ROW BEGIN
	IF (NEW.dr_total < 0.0) THEN
		SIGNAL SQLSTATE '12345' SET MESSAGE_TEXT = 'dr_total cannot be less than 0.00.';
	END IF;
	IF (NEW.cr_total < 0.0) THEN
		SIGNAL SQLSTATE '12345' SET MESSAGE_TEXT = 'cr_total cannot be less than 0.00.';
	END IF;
	IF !(NEW.dr_total <=> NEW.cr_total) THEN
		SIGNAL SQLSTATE '12345' SET MESSAGE_TEXT = 'dr_total is not equal to cr_total.';
	END IF;
END
//
DELIMITER ;

CREATE TABLE `%_PREFIX_%entryitems` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`entry_id` int(11) NOT NULL,
	`ledger_id` int(11) NOT NULL,
	`amount` float(25,2) DEFAULT '0.00' NOT NULL,
	`dc` varchar(1) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`reconciliation_date` datetime DEFAULT NULL,
        PRIMARY KEY (`id`),
	UNIQUE KEY `unique_id` (`id`),
	KEY `id` (`id`),
	KEY `entry_id` (`entry_id`),
	KEY `ledger_id` (`ledger_id`)
) DEFAULT CHARSET=utf8,
COLLATE=utf8_unicode_ci,
AUTO_INCREMENT=1,
ENGINE=InnoDB;

DROP TRIGGER IF EXISTS `check_%_PREFIX_%entryitems`;
DELIMITER //
CREATE TRIGGER `check_%_PREFIX_%entryitems` BEFORE INSERT ON `%_PREFIX_%entryitems`
FOR EACH ROW BEGIN
	SET NEW.dc = UPPER(NEW.dc);
	IF !(NEW.dc <=> 'D' OR NEW.dc <=> 'C') THEN
		SIGNAL SQLSTATE '12345' SET MESSAGE_TEXT = 'Invalid value for key dc. Allowed values are char D or C';
	END IF;
	IF (NEW.amount < 0.0) THEN
		SIGNAL SQLSTATE '12345' SET MESSAGE_TEXT = 'amount cannot be less than 0.00.';
	END IF;
END
//
DELIMITER ;

CREATE TABLE `%_PREFIX_%settings` (
	`id` int(1) NOT NULL,
	`name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`address` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`email` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`fy_start` datetime NOT NULL,
	`fy_end` datetime NOT NULL,
	`currency_symbol` varchar(100) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`date_format` varchar(100) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`timezone` varchar(100) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`manage_inventory` int(1) NOT NULL DEFAULT '0' ,
	`account_locked` int(1) NOT NULL DEFAULT '0',
	`email_use_default` int(1) NOT NULL DEFAULT '0',
	`email_protocol` varchar(9) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`email_host` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`email_port` int(5) NOT NULL,
	`email_tls` int(1) NOT NULL DEFAULT '0',
	`email_username` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`email_password` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`email_from` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`print_paper_height` float NOT NULL,
	`print_paper_width` float NOT NULL,
	`print_margin_top` float NOT NULL,
	`print_margin_bottom` float NOT NULL,
	`print_margin_left` float NOT NULL,
	`print_margin_right` float NOT NULL,
	`print_orientation` varchar(1) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`print_page_format` varchar(1) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`database_version` int(10) NOT NULL,
        PRIMARY KEY(`id`),
	UNIQUE KEY `unique_id` (`id`),
	KEY `id` (`id`)
) DEFAULT CHARSET=utf8,
COLLATE=utf8_unicode_ci,
ENGINE=InnoDB;

DROP TRIGGER IF EXISTS `check_%_PREFIX_%settings`;
DELIMITER //
CREATE TRIGGER `check_%_PREFIX_%settings` BEFORE INSERT ON `%_PREFIX_%settings`
FOR EACH ROW BEGIN
	SET NEW.id = 1;
END
//
DELIMITER ;

CREATE TABLE `%_PREFIX_%logs` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`date` datetime NOT NULL,
	`level` int(1) NOT NULL,
	`host_ip` varchar(25) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`user` varchar(25) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`url` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`user_agent` varchar(100) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
	`message` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
        PRIMARY KEY (`id`),
	UNIQUE KEY `unique_id` (`id`),
	KEY `id` (`id`)
) DEFAULT CHARSET=utf8,
COLLATE=utf8_general_ci,
AUTO_INCREMENT=1,
ENGINE=InnoDB;

ALTER TABLE `%_PREFIX_%groups`
	ADD CONSTRAINT `groups_fk_check_parent_id` FOREIGN KEY (`parent_id`) REFERENCES `groups` (`id`);

ALTER TABLE `%_PREFIX_%ledgers`
	ADD CONSTRAINT `ledgers_fk_check_group_id` FOREIGN KEY (`group_id`) REFERENCES `%_PREFIX_%groups` (`id`);

ALTER TABLE `%_PREFIX_%entries`
	ADD CONSTRAINT `entries_fk_check_entrytype_id` FOREIGN KEY (`entrytype_id`) REFERENCES `%_PREFIX_%entrytypes` (`id`),
	ADD CONSTRAINT `entries_fk_check_tag_id` FOREIGN KEY (`tag_id`) REFERENCES `%_PREFIX_%tags` (`id`);

ALTER TABLE `%_PREFIX_%entryitems`
	ADD CONSTRAINT `entryitems_fk_check_ledger_id` FOREIGN KEY (`ledger_id`) REFERENCES `%_PREFIX_%ledgers` (`id`),
	ADD CONSTRAINT `entryitems_fk_check_entry_id` FOREIGN KEY (`entry_id`) REFERENCES `%_PREFIX_%entries` (`id`);

INSERT INTO `%_PREFIX_%groups` (`id`, `parent_id`, `name`, `affects_gross`) VALUES (1, NULL, 'Assets', 0);
INSERT INTO `%_PREFIX_%groups` (`id`, `parent_id`, `name`, `affects_gross`) VALUES (2, NULL, 'Liabilities and Owners Equity', 0);
INSERT INTO `%_PREFIX_%groups` (`id`, `parent_id`, `name`, `affects_gross`) VALUES (3, NULL, 'Incomes', 0);
INSERT INTO `%_PREFIX_%groups` (`id`, `parent_id`, `name`, `affects_gross`) VALUES (4, NULL, 'Expenses', 0);
INSERT INTO `%_PREFIX_%groups` (`id`, `parent_id`, `name`, `affects_gross`) VALUES (5, 1, 'Fixed Assets', 0);
INSERT INTO `%_PREFIX_%groups` (`id`, `parent_id`, `name`, `affects_gross`) VALUES (6, 1, 'Current Assets', 0);
INSERT INTO `%_PREFIX_%groups` (`id`, `parent_id`, `name`, `affects_gross`) VALUES (7, 1, 'Investments', 0);
INSERT INTO `%_PREFIX_%groups` (`id`, `parent_id`, `name`, `affects_gross`) VALUES (8, 2, 'Capital Account', 0);
INSERT INTO `%_PREFIX_%groups` (`id`, `parent_id`, `name`, `affects_gross`) VALUES (9, 2, 'Current Liabilities', 0);
INSERT INTO `%_PREFIX_%groups` (`id`, `parent_id`, `name`, `affects_gross`) VALUES (10, 2, 'Loans (Liabilities)', 0);
INSERT INTO `%_PREFIX_%groups` (`id`, `parent_id`, `name`, `affects_gross`) VALUES (11, 3, 'Direct Incomes', 1);
INSERT INTO `%_PREFIX_%groups` (`id`, `parent_id`, `name`, `affects_gross`) VALUES (12, 4, 'Direct Expenses', 1);
INSERT INTO `%_PREFIX_%groups` (`id`, `parent_id`, `name`, `affects_gross`) VALUES (13, 3, 'Indirect Incomes', 0);
INSERT INTO `%_PREFIX_%groups` (`id`, `parent_id`, `name`, `affects_gross`) VALUES (14, 4, 'Indirect Expenses', 0);
INSERT INTO `%_PREFIX_%groups` (`id`, `parent_id`, `name`, `affects_gross`) VALUES (15, 3, 'Sales', 1);
INSERT INTO `%_PREFIX_%groups` (`id`, `parent_id`, `name`, `affects_gross`) VALUES (16, 4, 'Purchases', 1);

INSERT INTO `%_PREFIX_%entrytypes` (`id`, `label`, `name`, `description`, `base_type`, `numbering`, `prefix`, `suffix`, `zero_padding`, `restriction_bankcash`) VALUES (1, 'receipt', 'Receipt', 'Received in Bank account or Cash account', 1, 1, '', '', 0, 2);
INSERT INTO `%_PREFIX_%entrytypes` (`id`, `label`, `name`, `description`, `base_type`, `numbering`, `prefix`, `suffix`, `zero_padding`, `restriction_bankcash`) VALUES (2, 'payment', 'Payment', 'Payment made from Bank account or Cash account', 1, 1, '', '', 0, 3);
INSERT INTO `%_PREFIX_%entrytypes` (`id`, `label`, `name`, `description`, `base_type`, `numbering`, `prefix`, `suffix`, `zero_padding`, `restriction_bankcash`) VALUES (3, 'contra', 'Contra', 'Transfer between Bank account and Cash account', 1, 1, '', '', 0, 4);
INSERT INTO `%_PREFIX_%entrytypes` (`id`, `label`, `name`, `description`, `base_type`, `numbering`, `prefix`, `suffix`, `zero_padding`, `restriction_bankcash`) VALUES (4, 'journal', 'Journal', 'Transfer between Non Bank account and Cash account', 1, 1, '', '', 0, 5);
