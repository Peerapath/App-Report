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
    
    if (!$input || !isset($input['task_id'], $input['employees_id'], $input['status_id'])) {
        http_response_code(400);
        echo json_encode(["error" => "Invalid input data"]);
        exit();
    }

    $db = new Connect();
    
    $query = "SELECT report_id, department_id, task_description, date_time, status_id FROM tasks WHERE id = :task_id";
    $stmt = $db->prepare($query);
    $stmt->bindValue(':task_id', $input['task_id'], PDO::PARAM_INT);
    $stmt->execute();
    $task = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$task) {
        http_response_code(404);
        echo json_encode(["error" => "Task not found"]);
        exit();
    }

    $dateTime = date("Y-m-d H:i:s");

    $insertQuery = "INSERT INTO tasks (report_id, department_id, employee_id, task_description, date_time, status_id) 
                    VALUES (:report_id, :department_id, :employee_id, :task_description, :date_time, :status_id)";
    $insertStmt = $db->prepare($insertQuery);
    $insertStmt->execute([
        ":report_id" => $task['report_id'],
        ":department_id" => $task['department_id'],
        ":employee_id" => $input['employees_id'],
        ":task_description" => "รับงานโดยหน่วยงาน id: " . $task['department_id'], // $task['task_description']
        ":date_time" => $dateTime,
        ":status_id" => $input['status_id']
    ]);

    $newTaskId = $db->lastInsertId();
    
    http_response_code(200);
    echo json_encode(["success" => "Task cloned successfully", "new_task_id" => $newTaskId]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["error" => $e->getMessage()]);
}
?>
