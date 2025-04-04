<?php
header("Content-Type: application/json; charset=UTF-8");
require 'config.php';

$conn = new Connect();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $id = isset($_GET['id']) ? intval($_GET['id']) : null;
    
    $sql = "SELECT t.*, d.department_name, e.id AS employees_id, s.status_name AS task_status
            FROM tasks t
            JOIN departments d ON t.department_id = d.id
            JOIN employees e ON t.employee_id = e.id
            JOIN `status` s ON t.status_id = s.id";
    
    if ($id) {
        $sql .= " WHERE t.id = :id ORDER BY t.date_time DESC";
    } else {
        $sql .= " ORDER BY t.date_time DESC";
    }
    
    $stmt = $conn->prepare($sql);
    if ($id) {
        $stmt->execute(['id' => $id]);
    } else {
        $stmt->execute();
    }
    
    $tasks = [];
    while ($task = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $task_id = $task['id'];
        
        $task_image_sql = "SELECT image_id FROM `task_album` WHERE task_id = :task_id";
        $task_image_stmt = $conn->prepare($task_image_sql);
        $task_image_stmt->execute(['task_id' => $task_id]);
        
        $task_images = [];
        while ($timg = $task_image_stmt->fetch(PDO::FETCH_ASSOC)) {
            $task_images[] = "http://26.21.85.254:8080/Reportig/api/image_api.php?id=" . $timg['image_id'];
        }
        
        $tasks[] = [
            "task_id" => $task['id'],
            "task_date_time" => $task['date_time'],
            "task_description" => $task['task_description'],
            "task_status" => $task['task_status'],
            "department" => $task['department_name'],
            "employees_id" => $task['employees_id'],
            "task_image_url" => $task_images
        ];
    }
    
    if ($id) {
        echo json_encode($tasks[0] ?? ["message" => "Task not found"]);
    } else {
        echo json_encode($tasks);
    }
}

elseif ($method === 'POST') {
    $report_id = $_POST['report_id'] ?? 0;
    $department_id = $_POST['department_id'] ?? 1;
    $employee_id = $_POST['employee_id'] ?? 1;
    $task_description = $_POST['task_description'] ?? "";
    $date_time = $_POST['date_time'] ?? date("Y-m-d H:i:s");
    $status_id = $_POST['status_id'] ?? 1;

    $sql = "INSERT INTO tasks (report_id, department_id, employee_id, task_description, date_time, status_id) 
            VALUES (:report_id, :department_id, :employee_id, :task_description, :date_time, :status_id)";
    $stmt = $conn->prepare($sql);
    $stmt->execute([
        ":report_id" => $report_id,
        ":department_id" => $department_id,
        ":employee_id" => $employee_id,
        ":task_description" => $task_description,
        ":date_time" => $date_time,
        ":status_id" => $status_id
    ]);
    
    $task_id = $conn->lastInsertId();
    $image_urls = [];
    
    if (!empty($_FILES['image']['tmp_name'][0])) {
        echo ($_FILES['image']['tmp_name']);
        foreach ($_FILES['image']['tmp_name'] as $index => $tmp_name) {
            if ($tmp_name) {
                $image_data = file_get_contents($tmp_name);
                $image_name = $_FILES['image']['name'][$index];
                
                $image_sql = "INSERT INTO images (image, filename, created_at) VALUES (:image, :filename, NOW())";
                $image_stmt = $conn->prepare($image_sql);
                $image_stmt->execute([
                    ":image" => $image_data,
                    ":filename" => $image_name
                ]);
                
                $image_id = $conn->lastInsertId();
                
                $task_album_sql = "INSERT INTO task_album (task_id, image_id) VALUES (:task_id, :image_id)";
                $task_album_stmt = $conn->prepare($task_album_sql);
                $task_album_stmt->execute([
                    ":task_id" => $task_id,
                    ":image_id" => $image_id
                ]);
                
                $image_urls[] = "http://26.21.85.254:8080/Reportig/api/image_api.php?id=" . $image_id;
            }
        }
    }
    
    echo json_encode([
        "message" => "Task created successfully",
        "task_id" => $task_id,
        "images" => $image_urls
    ]);
}

elseif ($method === 'PUT') {
    $data = json_decode(file_get_contents("php://input"), true);
    $sql = "UPDATE tasks SET task_description = :task_description, date_time = :date_time, status_id = :status_id 
            WHERE id = :id";
    $stmt = $conn->prepare($sql);
    $stmt->execute($data);
    echo json_encode(["message" => "Task updated successfully"]);
}
?>
