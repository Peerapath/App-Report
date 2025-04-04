<?php 
header("Content-Type: application/json; charset=UTF-8");
require 'config.php';

$conn = new Connect();

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $id = isset($_GET['id']) ? intval($_GET['id']) : null;
    
    $sql = "SELECT r.*, p.problem_type_name, 
                   (SELECT s.status_name FROM tasks t 
                    JOIN `status` s ON t.status_id = s.id 
                    WHERE t.report_id = r.id 
                    ORDER BY t.date_time DESC LIMIT 1) AS report_status,
                   (SELECT e.id FROM tasks t 
                    JOIN employees e ON t.employee_id = e.id 
                    WHERE t.report_id = r.id 
                    ORDER BY t.date_time DESC LIMIT 1) AS employees_id
            FROM reports r 
            JOIN problem_type p ON r.problem_type_id = p.id";
    if ($id) {
        $sql .= " WHERE r.id = :id";
        $sql .= " ORDER BY r.date_time DESC";
    }else{
        $sql .= " ORDER BY r.date_time DESC";
    }
    
    $stmt = $conn->prepare($sql);
    if ($id) {
        $stmt->execute(['id' => $id]);
    } else {
        $stmt->execute();
    }
    
    $reports = [];
    
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $report_id = $row['id'];
        
        $image_sql = "SELECT image_id FROM `report_album` WHERE report_id = :report_id";
        $image_stmt = $conn->prepare($image_sql);
        $image_stmt->execute(['report_id' => $report_id]);
        $images = [];
        while ($img = $image_stmt->fetch(PDO::FETCH_ASSOC)) {
            $images[] = "http://26.21.85.254:8080/Reportig/api/image_api.php?id=" . $img['image_id'];
        }

        $task_sql = "SELECT t.*, d.department_name, s.status_name AS task_status, e.id AS employees_id
                     FROM tasks t 
                     JOIN departments d ON t.department_id = d.id
                     JOIN `status` s ON t.status_id = s.id
                     JOIN employees e ON t.employee_id = e.id
                     WHERE t.report_id = :report_id
                     ORDER BY t.date_time DESC";
        $task_stmt = $conn->prepare($task_sql);
        $task_stmt->execute(['report_id' => $report_id]);
        $tasks = [];
        
        while ($task = $task_stmt->fetch(PDO::FETCH_ASSOC)) {
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
        
        $reports[] = [
            "report_id" => $row['id'],
            "employees_id" => $row['employees_id'],
            "report_description" => $row['description'],
            "location" => $row['location'],
            "date_time" => $row['date_time'],
            "problem_type" => $row['problem_type_name'],
            "report_status" => $row['report_status'],
            "report_image_url" => $images,
            "tasks" => $tasks
        ];
    }
    
    if ($id) {
        echo json_encode($reports[0] ?? ["message" => "Report not found"]);
    } else {
        echo json_encode($reports);
    }
}

elseif ($method === 'POST') {
    $date_time = $_POST['date_time'] ?? date("Y-m-d H:i:s");
    $description = $_POST['description'] ?? "";
    $problem_type_id = $_POST['problem_type_id'] ?? 1;
    $location = $_POST['location'] ?? "";
    $urgency_id = $_POST['urgency_id'] ?? 1;
    $status_id = $_POST['status_id'] ?? 1;
    $f_name = $_POST['f_name'] ?? "";
    $l_name = $_POST['l_name'] ?? "";
    $email = $_POST['email'] ?? "";

    $sql = "INSERT INTO reports (description, location, date_time, problem_type_id, urgency_id, status_id, f_name, l_name, email) 
            VALUES (:description, :location, :date_time, :problem_type_id, :urgency_id, :status_id, :f_name, :l_name, :email)";
    $stmt = $conn->prepare($sql);
    $stmt->execute([
        ":description" => $description,
        ":location" => $location,
        ":date_time" => $date_time,
        ":problem_type_id" => $problem_type_id,
        ":urgency_id" => $urgency_id,
        ":status_id" => $status_id,
        ":f_name" => $f_name,
        ":l_name" => $l_name,
        ":email" => $email
    ]);

    $report_id = $conn->lastInsertId();
    $image_urls = [];

    if (!empty($_FILES['image']['tmp_name'][0])) {
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
    
                $report_album_sql = "INSERT INTO report_album (report_id, image_id) VALUES (:report_id, :image_id)";
                $report_album_stmt = $conn->prepare($report_album_sql);
                $report_album_stmt->execute([
                    ":report_id" => $report_id,
                    ":image_id" => $image_id
                ]);
    
                $image_urls[] = "http://26.21.85.254:8080/Reportig/api/image_api.php?id=" . $image_id;
            }
        }
    }    
    
    $taskData = [
        "report_id" => $report_id,
        "department_id" => 1,
        "employee_id" => 1,
        "task_description" => "งานที่สร้างขึ้นสำหรับรายงานid: $report_id",
        "date_time" => $date_time,
        "status_id" => 1
    ];

    $taskCreated = InsertTasks($taskData);

    echo json_encode([
        "message" => "Report created successfully",
        "report_id" => $report_id,
        "images" => $image_urls,
        "task_created" => $taskCreated
    ]);
}


elseif ($method === 'PUT') {
    $data = json_decode(file_get_contents("php://input"), true);
    $sql = "UPDATE reports SET description = :description, location = :location, 
            date_time = :date_time, problem_type_id = :problem_type_id, status_id = :status_id 
            WHERE id = :id";
    $stmt = $conn->prepare($sql);
    $stmt->execute($data);
    echo json_encode(["message" => "Report updated successfully"]);
}

function InsertTasks($data) {
    try {
        $db = new Connect();
        $query = "INSERT INTO `tasks` (`report_id`, `department_id`, `employee_id`, `task_description`, `date_time`, `status_id`) 
                  VALUES (:report_id, :department_id, :employee_id, :task_description, :date_time, :status_id)";

        $stmt = $db->prepare($query);
        $stmt->bindValue(':report_id', $data['report_id'], PDO::PARAM_INT);
        $stmt->bindValue(':department_id', $data['department_id'], PDO::PARAM_INT);
        $stmt->bindValue(':employee_id', $data['employee_id'], PDO::PARAM_INT);
        $stmt->bindValue(':task_description', $data['task_description']);
        $stmt->bindValue(':date_time', $data['date_time']);
        $stmt->bindValue(':status_id', $data['status_id'], PDO::PARAM_INT);

        $stmt->execute();

        return ["task_id" => $db->lastInsertId(), "status" => "Task created successfully"];
    } catch (PDOException $e) {
        return ["error" => $e->getMessage()];
    }
}

?>
