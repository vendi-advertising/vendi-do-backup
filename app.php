<?php

define( 'VENDI_DO_BACKUP_FILE', __FILE__ );
define( 'VENDI_DO_BACKUP_PATH', __DIR__ );

require VENDI_DO_BACKUP_PATH . '/includes/autoload.php';

$backup_command = new Vendi\DigitalOcean\Backup\Commands\BackupCommand();

$application = new Symfony\Component\Console\Application( 'Vendi Digital Ocean Backup', '1.0.0' );
$application->add( $backup_command );
$application->run();
