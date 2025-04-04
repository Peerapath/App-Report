<?php
// Allow Cross-Origin Requests (CORS)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

// Handle OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'config.php';
$db = new Connect();

if (isset($_REQUEST['_method'])) {
    $_SERVER['REQUEST_METHOD'] = strtoupper($_REQUEST['_method']);
}

$method = $_SERVER['REQUEST_METHOD'];


if ($method == 'POST') {
    if (!isset($_FILES['image'])) {
        http_response_code(400);
        echo json_encode(["error" => "No image uploaded"]);
        exit();
    }

    $image = file_get_contents($_FILES['image']['tmp_name']);
    $filename = $_FILES['image']['name'];
    echo $image;
    echo json_encode(["filename" => "$filename"]);

    $query = "INSERT INTO images (image, filename) VALUES (:image, :filename)";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':image', $image, PDO::PARAM_LOB);
    $stmt->bindParam(':filename', $filename);
    
    if ($stmt->execute()) {
        echo json_encode(["success" => "Image uploaded successfully", "id" => $db->lastInsertId()]);
    } else {
        http_response_code(500);
        echo json_encode(["error" => "Failed to upload image"]);
    }
}

elseif ($method == 'PUT') {
    parse_str(file_get_contents("php://input"), $_PUT);

    if (!isset($_REQUEST['id']) || !isset($_FILES['image'])) {
        http_response_code(400);
        echo json_encode(["error" => "Missing parameters"]);
        exit();
    }

    $id = intval($_REQUEST['id']);
    $imageData = file_get_contents($_FILES['image']['tmp_name']);

    $stmt = $db->prepare("UPDATE images SET image = ? WHERE id = ?");
    $stmt->bindParam(1, $imageData, PDO::PARAM_LOB);
    $stmt->bindParam(2, $id, PDO::PARAM_INT);

    if ($stmt->execute()) {
        echo json_encode(["success" => "Image updated successfully", "id" => "$id"]);
    } else {
        http_response_code(500);
        echo json_encode(["error" => "Failed to update image"]);
    }

}

elseif ($method == 'GET') {
    if (!isset($_GET['id'])) {
        http_response_code(400);
        echo json_encode(["error" => "ID is required"]);
        exit();
    }

    $id = intval($_GET['id']);
    $stmt = $db->prepare("SELECT image FROM images WHERE id = ?");
    $stmt->bindParam(1, $id, PDO::PARAM_INT);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        header("Content-Type: image/jpeg");
        echo $row['image'];
    } else {
        http_response_code(404);
        echo json_encode(["error" => "Image not found"]);
    }
}

$db = null;
?>
