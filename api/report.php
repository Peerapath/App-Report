<?php

require_once __DIR__ . '/config.php';

date_default_timezone_set('Asia/Bangkok');


// CORS headers
header("Access-Control-Allow-Origin: *"); // You can restrict this to specific domains, e.g., http://example.com
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS"); // Allow these methods
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With"); // Allow headers
header("Access-Control-Allow-Credentials: true"); // If using cookies or credentials

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// GET
class API {
    public function Select() {
        try {
            $db = new Connect();
            $id = isset($_GET['id']) ? intval($_GET['id']) : null;

            // Query to fetch reporting along with tasks and images
            $query =
                "
                SELECT
                    r.id AS report_id,
                    r.description AS report_description,
                    r.location,
                    r.`date_time` AS report_date_time,
                    pt.problem_type_name,
                    rs.status_name AS report_status,
                    ri.image_path AS report_image_path,
                    t.id AS task_id,
                    t.`date_time` AS task_date_time,
                    t.task_description,
                    ts.status_name AS task_status,
                    d.department_name,
                    e.id AS employees_id,
                    ti.image_path AS task_image_path
                FROM
                reports r
                LEFT JOIN problem_type pt ON r.problem_type_id = pt.id
                LEFT JOIN `status` rs ON r.status_id = rs.id
                LEFT JOIN report_album ra ON r.id = ra.report_id
                LEFT JOIN images ri ON ra.image_id = ri.id
                LEFT JOIN tasks t ON r.id = t.report_id
                LEFT JOIN `status` ts ON t.status_id = ts.id
                LEFT JOIN departments d ON t.department_id = d.id
                LEFT JOIN employees e ON t.employee_id = e.id
                LEFT JOIN task_album ta ON t.id = ta.task_id
                LEFT JOIN images ti ON ta.task_id = ti.id                
                ";

            // Add condition to fetch data by id
            if ($id) {
                $query .= " WHERE r.id = :id
                            ORDER BY t.date_time DESC";
            }else{
                $query .= " ORDER BY r.date_time DESC";
            }

            // Prepare SQL statement
            $data = $db->prepare($query);

            // Bind id if present
            if ($id) {
                $data->bindValue(':id', $id, PDO::PARAM_INT);
            }

            // Execute the SQL query
            $data->execute();

            // Fetch data from query
            $results = $data->fetchAll(PDO::FETCH_ASSOC);

            // Group data by report
            $reportings = [];
            foreach ($results as $row) {                
                $reportingId = $row['report_id'];

                // Group report
                if (!isset($reportings[$reportingId])) {
                    $reportings[$reportingId] = [
                        'report_id' => $row['report_id'],
                        'report_description' => $row['report_description'],
                        'location' => $row['location'],
                        'date_time' => $row['report_date_time'],
                        'problem_type' => $row['problem_type_name'],
                        'report_status' => $row['report_status'],
                        'report_image_path' => [],
                        'tasks' => []
                    ];
                }

                // Add report images
                if (!empty($row['report_image_path']) && !in_array($row['report_image_path'], $reportings[$reportingId]['report_image_path'])) {
                    $reportings[$reportingId]['report_image_path'][] = $row['report_image_path'];
                }

                // Group tasks
                if (!empty($row['task_id'])) {
                    $taskId = $row['task_id'];

                    if (!isset($reportings[$reportingId]['tasks'][$taskId])) {
                        $reportings[$reportingId]['tasks'][$taskId] = [
                            'task_id' => $row['task_id'],
                            'task_date_time' => $row['task_date_time'],
                            'task_description' => $row['task_description'],
                            'task_status' => $row['task_status'],
                            'department' => $row['department_name'],
                            'employees_id' => $row['employees_id'],
                            'task_image_path' => []
                        ];
                    }

                    // Add task images
                    if (!empty($row['task_image_path']) && !in_array($row['task_image_path'], $reportings[$reportingId]['tasks'][$taskId]['task_image_path'])) {
                        $reportings[$reportingId]['tasks'][$taskId]['task_image_path'][] = $row['task_image_path'];
                    }
                }
            }

            // Reindex results
            $reportings = array_values($reportings);
            foreach ($reportings as &$reporting) {
                $reporting['tasks'] = array_values($reporting['tasks']);
            }

            return json_encode($reportings);
        } catch (PDOException $e) {
            http_response_code(500);
            return json_encode(['error' => $e->getMessage()]);
        }
    }

    // Insert new data POST
    public function Insert() {
        try {
            $input = json_decode(file_get_contents('php://input'), true);

            // Check for required fields
            if (!$input || !isset($input['description'], $input['problem_type_id'], $input['date_time'], $input['location'], 
                                  $input['urgency_id'], $input['status_id'], $input['f_name'], $input['l_name'], $input['email'])) {
                http_response_code(400);
                return json_encode(["error" => "Invalid input data"]);
            }

            $db = new Connect();
            $query = "INSERT INTO `reports` (`date_time`, `description`, `problem_type_id`, `location`, `urgency_id`, `status_id`, `f_name`, `l_name`, `email`) 
                      VALUES (:date_time, :description, :problem_type_id, :location, :urgency_id, :status_id, :f_name, :l_name, :email)";

            $data = $db->prepare($query);

            $dateTime = date("Y-m-d H:i:s");

            // Bind the input data
            // $data->bindValue(':date_time', $input['date_time']);
            $data->bindValue(':date_time', $dateTime);
            $data->bindValue(':description', $input['description']);
            $data->bindValue(':problem_type_id', $input['problem_type_id'], PDO::PARAM_INT);
            $data->bindValue(':location', $input['location']);
            $data->bindValue(':urgency_id', $input['urgency_id'], PDO::PARAM_INT);
            $data->bindValue(':status_id', $input['status_id'], PDO::PARAM_INT);
            $data->bindValue(':f_name', $input['f_name']);
            $data->bindValue(':l_name', $input['l_name']);
            $data->bindValue(':email', $input['email']);

            // Execute SQL query
            $data->execute();

            // Get last inserted ID
            $report_id = $db->lastInsertId();

            // Prepare task data
            $taskData = [
                "report_id" => $report_id,
                "task_description" => "รอรับเรื่องโดย...",
                "date_time" => $dateTime, // เวลาปัจจุบัน
                "status_id" => 1
            ];

            // Insert into tasks
            $this->InsertTasks($taskData);

            http_response_code(201);
            return json_encode(["success" => "Record added successfully"]);
        } catch (PDOException $e) {
            http_response_code(500);
            return json_encode(["error" => $e->getMessage()]);
        }
    }

    public function InsertTasks($data) {
        try {
            $db = new Connect();
            $query = "INSERT INTO `tasks` (`report_id`, `department_id`, `employee_id`, `task_description`, `date_time`, `status_id`) 
                      VALUES (:report_id, NULL, NULL, :task_description, :date_time, :status_id)";
    
            $stmt = $db->prepare($query);
            $stmt->bindValue(':report_id', $data['report_id'], PDO::PARAM_INT);
            $stmt->bindValue(':task_description', $data['task_description']);
            $stmt->bindValue(':date_time', $data['date_time']);
            $stmt->bindValue(':status_id', $data['status_id'], PDO::PARAM_INT);
    
            $stmt->execute();
    
            return true;
        } catch (PDOException $e) {
            return json_encode(["error" => $e->getMessage()]);
        }
    }

    // Update existing data PUT
    public function Update($id) {
        try {
            $input = json_decode(file_get_contents('php://input'), true);

            // Check for required fields
            if (!$input || !isset($input['description'], $input['problem_type_id'], $input['date_time'], $input['location'], 
                                $input['urgency_id'], $input['status_id'], $input['f_name'], $input['l_name'], $input['email'])) {
                http_response_code(400);
                return json_encode(["error" => "Invalid input data"]);
            }

            $db = new Connect();
            $query = "UPDATE `reports` SET `date_time` = :date_time, `description` = :description, `problem_type_id` = :problem_type_id, 
                    `location` = :location, `urgency_id` = :urgency_id, `status_id` = :status_id, `f_name` = :f_name, 
                    `l_name` = :l_name, `email` = :email WHERE `id` = :id";

            $data = $db->prepare($query);

            // Bind the input data
            $data->bindValue(':id', $id, PDO::PARAM_INT);
            $data->bindValue(':date_time', $input['date_time']);
            $data->bindValue(':description', $input['description']);
            $data->bindValue(':problem_type_id', $input['problem_type_id'], PDO::PARAM_INT);
            $data->bindValue(':location', $input['location']);
            $data->bindValue(':urgency_id', $input['urgency_id'], PDO::PARAM_INT);
            $data->bindValue(':status_id', $input['status_id'], PDO::PARAM_INT);
            $data->bindValue(':f_name', $input['f_name']);
            $data->bindValue(':l_name', $input['l_name']);
            $data->bindValue(':email', $input['email']);

            // Execute SQL query
            $data->execute();

            if ($data->rowCount() > 0) {
                http_response_code(200);
                return json_encode(["success" => "Record updated successfully"]);
            } else {
                http_response_code(404);
                return json_encode(["error" => "No record found or no change made"]);
            }
        } catch (PDOException $e) {
            http_response_code(500);
            return json_encode(["error" => $e->getMessage()]);
        }
    }



    // Delete data
    public function Delete() {
        try {
            $input = json_decode(file_get_contents('php://input'), true);

            if (!$input || !isset($input['reporting_id'])) {
                http_response_code(400);
                return json_encode(["error" => "Invalid input data"]);
            }

            $db = new Connect();
            $query = "DELETE FROM reporting WHERE reporting_id = :reporting_id";
            $data = $db->prepare($query);
            $data->bindValue(':reporting_id', $input['reporting_id']);
            $data->execute();

            http_response_code(200);
            return json_encode(["success" => "Record deleted successfully"]);
        } catch (PDOException $e) {
            http_response_code(500);
            return json_encode(["error" => $e->getMessage()]);
        }
    }
}

// Instantiate the API class and process the request
$API = new API();

$id = null;
if (isset($_SERVER['PATH_INFO'])) {
    $path_parts = explode('/', trim($_SERVER['PATH_INFO'], '/'));
    if (isset($path_parts[0]) && is_numeric($path_parts[0])) {
        $id = intval($path_parts[0]);
    }
}

// ตรวจสอบ request method
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        echo $API->Select();
        break;
    case 'POST':
        echo $API->Insert();
        break;
    case 'PUT':
        if ($id) {
            echo $API->Update($id);
        } else {
            http_response_code(400);
            echo json_encode(["error" => "ID is required for update"]);
        }
        break;
    case 'DELETE':
        if ($id) {
            echo $API->Delete($id);
        } else {
            http_response_code(400);
            echo json_encode(["error" => "ID is required for delete"]);
        }
        break;
    case 'OPTIONS':
        http_response_code(200);
        break;
    default:
        http_response_code(405);
        echo json_encode(["error" => "Method not allowed"]);
        break;
}


?>

