<?php
require_once 'config.php';

date_default_timezone_set('Asia/Bangkok');

// Allow Cross-Origin Requests (CORS)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

// Handle OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input || !isset($input['user_name'], $input['password'], $input['f_name'], $input['l_name'], $input['email'], $input['role_id'], $input['department_id'])) {
        http_response_code(400);
        echo json_encode(["error" => "Invalid input data"]);
        exit();
    }

    $db = new Connect();
    $db->beginTransaction();

    $hashed_password = password_hash($input['password'], PASSWORD_BCRYPT);

    $query = "INSERT INTO employees (user_name, password, f_name, l_name, email) VALUES (:user_name, :password, :f_name, :l_name, :email)";
    $stmt = $db->prepare($query);
    $stmt->bindValue(':user_name', $input['user_name']);
    $stmt->bindValue(':password', $hashed_password);
    $stmt->bindValue(':f_name', $input['f_name']);
    $stmt->bindValue(':l_name', $input['l_name']);
    $stmt->bindValue(':email', $input['email']);
    
    if (!$stmt->execute()) {
        throw new Exception("Failed to register user");
    }

    $employee_id = $db->lastInsertId();

    $query2 = "INSERT INTO member_department (department_id, employee_id, role_id) VALUES (:department_id, :employee_id, :role_id)";
    $stmt2 = $db->prepare($query2);
    $stmt2->bindValue(':department_id', $input['department_id'], PDO::PARAM_INT);
    $stmt2->bindValue(':employee_id', $employee_id, PDO::PARAM_INT);
    $stmt2->bindValue(':role_id', $input['role_id'], PDO::PARAM_INT);

    if (!$stmt2->execute()) {
        throw new Exception("Failed to assign user to department");
    }

    $db->commit();
    
    http_response_code(201);
    echo json_encode(["success" => "User registered successfully", "employee_id" => $employee_id]);
} catch (Exception $e) {
    $db->rollBack();
    http_response_code(500);
    echo json_encode(["error" => $e->getMessage()]);
}
?>
