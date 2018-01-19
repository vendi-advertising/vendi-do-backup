<?php declare(strict_types=1);
namespace Vendi\DigitalOcean\Backup\Commands;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;

class BackupCommand extends Command
{
    protected $_is_wordpress;
    protected $_is_drupal;

    private $_io;

    public function set_io(SymfonyStyle $io)
    {
        $this->_io = $io;
    }

    protected function get_or_create_io(InputInterface $input, OutputInterface $output) : SymfonyStyle
    {
        if (! $this->_io) {
            $this->_io = new SymfonyStyle($input, $output);
        }
        return $this->_io;
    }

    protected function configure()
    {
        $this
            ->setName('backup')
            ->setDescription('Backup to Digital Ocean')
        ;
    }

    protected function execute(InputInterface $input, OutputInterface $output)
    {
        throw new \Exception('Child classes must handle this themselves.');
    }
}
