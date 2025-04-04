<?php
require_once 'config.php';

date_default_timezone_set('Asia/Bangkok');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input || !isset($input['user_name'], $input['password'])) {
        http_response_code(400);
        echo json_encode(["error" => "Invalid input data"]);
        exit();
    }


    $db = new Connect();


    // $query = 'SELECT * FROM employees WHERE user_name = :user_name';
    $query = 'SELECT
            e.id "employee_id",
            e.user_name,
            e.password,
            e.f_name "first_name",
            e.l_name "last_name",
            r.id "role_id",
            r.role_name,
            d.id "department_id",
            d.department_name,
            o.id "organization_id",
            o.organization_name
        FROM
            member_department md
        JOIN departments d ON d.id = md.department_id
        JOIN organizations o ON o.id = d.organization_id
        JOIN employees e ON e.id = md.employee_id
        JOIN roles r ON r.id = md.role_id
        WHERE user_name = :user_name';
    $stmt = $db->prepare($query);
    $stmt->bindValue(':user_name', $input['user_name']);
    $stmt->execute();

    
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        http_response_code(401);
        echo json_encode(["error" => "Invalid username or password"]);
        exit();
    }


    if (!password_verify($input['password'], $user['password'])) {
        http_response_code(401);
        echo json_encode(["error" => "Invalid username or password"]);
        exit();
    }

    unset($user['password']);

    // ส่งข้อมูลผู้ใช้กลับ
    http_response_code(200);
    echo json_encode(["success" => "Login successful", "user" => $user]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => $e->getMessage()]);
}
