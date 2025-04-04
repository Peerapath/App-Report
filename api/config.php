<?php

class Connect extends PDO
{
    public function __construct()
    {
        // Allow Cross-Origin Requests (CORS)
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
        header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

        // Handle OPTIONS request (for preflight)
        if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
            http_response_code(200);
            exit();
        }

        // Connect to the database
        parent::__construct("mysql:host=localhost;dbname=report_system", "root", "", [
            PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8"
        ]);

        // Set PDO attributes
        $this->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $this->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
    }
}
?>
