<?php
$config = array();
$config['db_dsnw'] = 'mysql://roundcube:roundcube_password@localhost/roundcube';
$config['default_host'] = 'localhost';
$config['default_port'] = 143;
$config['smtp_server'] = 'localhost';
$config['smtp_port'] = 587;
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';
$config['support_url'] = '';
$config['product_name'] = 'Mail Samolensk';
$config['plugins'] = array('archive', 'zipdownload');
$config['skin'] = 'elastic';
$config['language'] = 'ru_RU';
$config['imap_conn_options'] = array(
    'ssl' => array(
        'verify_peer' => false,
        'verify_peer_name' => false,
    ),
);
$config['smtp_conn_options'] = array(
    'ssl' => array(
        'verify_peer' => false,
        'verify_peer_name' => false,
    ),
);
