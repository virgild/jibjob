# coding: utf-8

require 'dm-migrations'
require 'dm-migrations/migration_runner'

module JibJob
  def self.migrate_db
    JibJob::Migrations.migrate_up!
  end
  
  def self.database_adapter
    DataMapper.repository(:default).adapter
  end
  
  module Migrations
    include DataMapper::Types
    
    migration 1, :create_initial_tables, :verbose => true do
      up do
        execute(<<-SQL)
          CREATE TABLE IF NOT EXISTS `users` (
            `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
            `username` VARCHAR(50) NOT NULL,
            `email` VARCHAR(200) NOT NULL,
            `crypted_password` VARCHAR(64) NOT NULL,
            `agreed_terms` VARCHAR(10),
            `created_at` DATETIME,
            `updated_at` DATETIME,
            PRIMARY KEY (`id`),
            UNIQUE KEY `users_username_index` (`username`),
            UNIQUE KEY `users_email_index` (`email`)
          )
          ENGINE = InnoDB
          DEFAULT CHARSET = utf8
          AUTO_INCREMENT = 1;
        SQL
        
        execute(<<-SQL)
          CREATE TABLE IF NOT EXISTS `resumes` (
            `id` VARCHAR(50) NOT NULL,
            `user_id` BIGINT UNSIGNED NOT NULL,
            `name` VARCHAR(50) NOT NULL,
            `content` TEXT,
            `slug` VARCHAR(50) NOT NULL,
            `created_at` DATETIME,
            `updated_at` DATETIME,
            PRIMARY KEY (`id`),
            KEY `resumes_user_id_index` (`user_id`),
            KEY `resumes_name_index` (`name`),
            UNIQUE KEY `resumes_slug_index` (`slug`)
          )
          ENGINE = InnoDB
          DEFAULT CHARSET = utf8;
        SQL
      end
      
      down do
        execute("DROP TABLE `resumes`")
        execute("DROP TABLE `users`")
      end
    end #migration 1
  
    migration 2, :add_resume_access_code, :verbose => true do
      up do
        execute(<<-SQL)
          ALTER TABLE `resumes` ADD `access_code` VARCHAR(64) NULL;
        SQL
      end
    
      down do
        execute(<<-SQL)
          ALTER TABLE `resumes` DROP `access_code`;
        SQL
      end
    end
    
    migration 3, :add_api_keys, :verbose => true do
      up do
        execute(<<-SQL)
          CREATE TABLE IF NOT EXISTS `api_keys` (
            `id` SERIAL,
            `value` VARCHAR(64) NOT NULL,
            `user_id` BIGINT NOT NULL,
            KEY `api_keys_id_index` (`user_id`),
            UNIQUE KEY `api_keys_value_index` (`value`)
          )
          ENGINE = InnoDB
          DEFAULT CHARSET = utf8;
        SQL
      end
      
      down do
        execute("DROP TABLE `api_keys`")
      end
    end
    
    migration 4, :add_messages, :verbose => true do
      up do
        execute(<<-SQL)
          CREATE TABLE IF NOT EXISTS `messages` (
            `id` SERIAL,
            `resume_id` VARCHAR(50) NOT NULL,
            `subject` VARCHAR(128),
            `body` TEXT,
            `from` VARCHAR(512),
            `is_read` TINYINT,
            `created_at` DATETIME,
            KEY `messages_resume_id_index` (`resume_id`)
          )
          ENGINE = InnoDB
          DEFAULT CHARSET = utf8;
        SQL
      end
      
      down do
        execute("DROP TABLE `messages`")
      end
    end
    
    migration 5, :add_email_column_to_messages, :verbose => true do
      up do
        execute(<<-SQL)
          ALTER TABLE `messages` ADD `email` VARCHAR(200) NOT NULL
        SQL
      end
      
      down do
        execute("ALTER TABLE `messages` DROP `email`")
      end
    end
    
    migration 6, :messages_set_is_read_default, :verbose => true do
      up do
        execute(<<-SQL)
          ALTER TABLE `messages` CHANGE `is_read` `is_read` TINYINT(4) NOT NULL DEFAULT '0'
        SQL
      end
    end
    
  end #module Migrations
end #module JibJob