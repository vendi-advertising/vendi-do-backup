<?php
namespace Vendi\DigitalOcean\Backup\Commands;

use Aws\S3\S3Client;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;

class BackupCommand extends Command
{
    private $_private_key;

    private $_public_key;

    private $_site_name;

    private $_file;

    private $_name;

    private $_io;

    public function set_io(SymfonyStyle $io)
    {
        $this->_io = $io;
    }

    protected function get_or_create_io(InputInterface $input, OutputInterface $output)
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
            ->addOption( 'public-key',  null, InputOption::VALUE_REQUIRED, 'The public key' )
            ->addOption( 'private-key', null, InputOption::VALUE_REQUIRED, 'The private key' )
            ->addOption( 'site-name',   null, InputOption::VALUE_REQUIRED, 'The site\s name for the folder' )
            ->addOption( 'file',        null, InputOption::VALUE_REQUIRED, 'The file to upload' )
            ->addOption( 'name',        null, InputOption::VALUE_REQUIRED, 'Optiona. The name of the file on Digital Ocean' )
        ;
    }


    protected function initialize( InputInterface $input, OutputInterface $output )
    {
        parent::initialize( $input, $output );

        $this->_private_key = $input->getOption('private-key');
        $this->_public_key  = $input->getOption('public-key');
        $this->_site_name   = $input->getOption('site-name');
        $this->_file        = $input->getOption('file');
        $this->_name        = $input->getOption('name');

        if(!$this->_private_key){
            throw new \Exception('The --private-key option is required');
        }

        if(!$this->_public_key){
            throw new \Exception('The --public-key option is required');
        }

        if(!$this->_site_name){
            throw new \Exception('The --site-name option is required');
        }

        if(!$this->_file){
            throw new \Exception('The --file option is required');
        }

        if(!is_file($this->_file) || ! is_readable($this->_file)){
            throw new \Exception('Could not read file');
        }

        if(!$this->_name){
            $this->_name = sprintf( '%1$s_%2$s', $this->_site_name, $this->_file );
        }
    }



    protected function execute(InputInterface $input, OutputInterface $output)
    {

        // Configure a client using Spaces
        $client = new S3Client([
                'version' => 'latest',
                'region'  => 'nyc3',
                'endpoint' => 'https://nyc3.digitaloceanspaces.com',
                'credentials' => [
                        'key'    => $this->_public_key,
                        'secret' => $this->_private_key,
                    ],
        ]);

        $bucket = 'vendi-backup';

        $file_resource = fopen($this->_file, 'r');
        if(!$file_resource){
            throw new \Exception('Could not open file');
        }

        // Upload a file to the Space
        $insert = $client->putObject(
                                        [
                                            'Bucket' => 'vendi-backup',
                                            'Key'    => $this->_name,
                                            'Body'   => $file_resource,
                                        ]
                                );

    }
}
