<?php

class Connect extends PDO {
    public function __construct() {
        // Set CORS headers
        header("Access-Control-Allow-Origin: *");  // Allow all origins, you can restrict this to a specific domain
        header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");  // Allow specific HTTP methods
        header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");  // Allow specific headers
        header("Access-Control-Allow-Credentials: true");  // Allow credentials if needed

        // Handle preflight OPTIONS request
        if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
            http_response_code(200);
            exit();
        }

        // Connect to database
        parent::__construct("mysql:host=localhost;dbname=report_system", "root", "");
        array(PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8");

        $this->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $this->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
    }
}
?>
