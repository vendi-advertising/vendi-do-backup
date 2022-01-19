<?php

namespace App\Commands;

use Aws\S3\S3Client;
use RuntimeException;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;

class BackupCommand extends Command
{
    private $_private_key;

    private $_public_key;

    private $_bucket;

    private $_file;

    private $_name;

    private $_region;

    private $_io;

    public function set_io(SymfonyStyle $io)
    {
        $this->_io = $io;
    }

    protected function get_or_create_io(InputInterface $input, OutputInterface $output)
    {
        if (!$this->_io) {
            $this->_io = new SymfonyStyle($input, $output);
        }

        return $this->_io;
    }

    protected function configure()
    {
        $this
            ->setName('app:backup')
            ->setDescription('Backup to Digital Ocean')
            ->addOption('public-key', null, InputOption::VALUE_REQUIRED, 'The public key')
            ->addOption('private-key', null, InputOption::VALUE_REQUIRED, 'The private key')
            ->addOption('file', null, InputOption::VALUE_REQUIRED, 'The file to upload')
            ->addOption('bucket', null, InputOption::VALUE_REQUIRED, 'The bucket to upload to')
            ->addOption('name', null, InputOption::VALUE_REQUIRED, 'The name of the file on Digital Ocean')
            ->addOption('region', null, InputOption::VALUE_REQUIRED, 'Optional. The region to upload to. Default is nyc3');
    }

    protected function initialize(InputInterface $input, OutputInterface $output)
    {
        parent::initialize($input, $output);

        $required = [
            '_private_key' => 'private-key',
            '_public_key' => 'public-key',
            '_bucket' => 'bucket',
            '_file' => 'file',
            '_name' => 'name',
        ];

        $optional = [
            '_region' => 'region',
        ];

        foreach ($required as $prop => $key) {
            $this->$prop = $input->getOption($key);
            if (!$this->$prop) {
                throw new RuntimeException(sprintf('The --%1$s option is required', $key));
            }
        }

        if (!is_file($this->_file) || !is_readable($this->_file)) {
            throw new RuntimeException('Could not read file');
        }

        if (!$this->_name) {
            $this->_name = sprintf('%1$s_%2$s', $this->_site_name, $this->_file);
        }

        if (!$this->_region) {
            $this->_region = 'nyc3';
        }
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {

        // Configure a client using Spaces
        $client = new S3Client([
            'version' => 'latest',
            'region' => $this->_region,
            'endpoint' => sprintf('https://%1$s.digitaloceanspaces.com', $this->_region),
            'credentials' => [
                'key' => $this->_public_key,
                'secret' => $this->_private_key,
            ],
        ]);


        $bucket_found = false;
        $spaces = $client->listBuckets();
        foreach ($spaces['Buckets'] as $space) {
            if ($space['Name'] === $this->_bucket) {
                $bucket_found = true;
                break;
            }
        }

        if (!$bucket_found) {
            throw new RuntimeException('The supplied bucket could not be found');
        }

        $file_resource = fopen($this->_file, 'r');
        if (!$file_resource) {
            throw new RuntimeException('Could not open file');
        }

        // Upload a file to the Space
        $insert = $client->putObject(
            [
                'Bucket' => $this->_bucket,
                'Key' => $this->_name,
                'Body' => $file_resource,
            ]
        );
    }
}
