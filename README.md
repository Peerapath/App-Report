# API Documentation

## :dart: วิธีทดสอบ API

---

###  ทดสอบ `report.php` (ดึงรายงานทั้งหมด หรือระบุ ID)

**:small_blue_diamond: GET Request:**  
```
http://26.21.85.254:8080/Reportig/api/report.php?id=1
```

**:small_blue_diamond: Response (JSON):**
```json
{
    "report_id": 1,
    "employees_id": 3,
    "report_description": "อัพเดท4",
    "location": "ถนนสุขุมวิท 101",
    "date_time": "2024-02-07 14:30:00",
    "problem_type": "สะพาน",
    "report_status": "ส่งต่อ",
    "report_image_url": [
        "http://26.21.85.254:8080/Reportig/api/image_api.php?id=3"
    ],
    "tasks": [
        {
            "task_id": 1,
            "task_date_time": "2024-12-24 18:46:13",
            "task_description": "ทดสอบระบบงาน",
            "task_status": "รอรับเรื่อง",
            "department": "บริหารทั่วไป",
            "employees_id": 1,
            "task_image_url": [
                "http://26.21.85.254:8080/Reportig/api/image_api.php?id=4"
            ]
        },
        {
            "task_id": 2,
            "task_date_time": "2025-02-10 18:36:16",
            "task_description": "เพิ่มงานใหม่-2",
            "task_status": "ดำเนินงาน",
            "department": "บริหารทั่วไป",
            "employees_id": 3,
            "task_image_url": [
                "http://26.21.85.254:8080/Reportig/api/image_api.php?id=8"
            ]
        }
    ]
}
```
---

###  ทดสอบ `report.php` (เพิ่มรายงานใหม่)

**:small_blue_diamond: POST Request:**  
```
http://26.21.85.254:8080/Reportig/api/report.php
```

**:small_blue_diamond: Body (JSON):**
```json
{
    "date_time": "2024-02-07 14:30:00",
    "description": "ไฟถนนดับทั้งซอย",
    "problem_type_id": 2,
    "location": "ถนนสุขุมวิท 101",
    "urgency_id": 1,
    "status_id": 1,
    "f_name": "สมชาย",
    "l_name": "ใจดี",
    "email": "somchai@example.com",
    "report_image_url": [],
}
```

---

###  ทดสอบ `report.php` (แก้ไขรายงาน)

**:small_blue_diamond: PUT Request:**  
```
http://26.21.85.254:8080/Reportig/api/report.php?id=1
```

**:small_blue_diamond: Body (JSON):**
```json
{
    "date_time": "2024-02-07 14:30:00",
    "description": "อัพเดท",
    "problem_type_id": 2,
    "location": "ถนนสุขุมวิท 101",
    "urgency_id": 1,
    "status_id": 1,
    "f_name": "สมชาย",
    "l_name": "ใจดี",
    "email": "somchai@example.com"
}
```

---
```
```
###  ทดสอบ `task.php` (ดึงงานทั้งหมด หรือระบุ ID)

**:small_blue_diamond: GET Request:**  
```
http://26.21.85.254:8080/Reportig/api/task.php?id=1
```

**:small_blue_diamond: Response (JSON):**
```json
{
    "task_id": 1,
    "task_date_time": "2024-12-24 18:46:13",
    "task_description": "ทดสอบระบบงาน",
    "task_status": "รอรับเรื่อง",
    "department": "บริหารทั่วไป",
    "employees_id": 3,
    "task_image_url": [
        "http://26.21.85.254:8080/Reportig/api/image_api.php?id=4"
    ]
}
```

---

###  ทดสอบ `task.php` (เพิ่มงานใหม่)

**:small_blue_diamond: POST Request:**  
```
http://26.21.85.254:8080/Reportig/api/task.php
```

**:small_blue_diamond: Form Data:**
```Form Data:
report_id: 1
department_id: 2
employee_id: 3
task_description: "Check network connectivity"
date_time: "2025-04-04 14:00:00"
status_id: 1
image: (Upload file)
```
:white_check_mark: **Response (หากเพิ่มงานสำเร็จ):**
```json
{
  "message": "Task created successfully",
  "task_id": 10,
  "images": [
    "http://localhost/Reportig/api/image_api.php?id=1"
  ]
}
```

---

###  ทดสอบ `employee_get_task.php` (รับงาน)

**:small_blue_diamond: POST Request:**  
```
http://26.21.85.254:8080/Reportig/api/employee_get_task.php
```

**:small_blue_diamond: Body (JSON):**
```json
{
    "task_id": 1,
    "employees_id": 3,
    "status_id": 2
}
```
:white_check_mark: **Response (หากเพิ่มงานสำเร็จ):**
```json
{
    "message": "Task copied successfully",
    "new_task_id": 12
}
```

---

###  ทดสอบ `task.php` (แก้ไขงาน)

**:small_blue_diamond: PUT Request:**  
```
http://26.21.85.254:8080/Reportig/api/task.php?id=1
```

**:small_blue_diamond: Body (JSON):**
```json
{
  "id": 10,
  "task_description": "Network issue resolved",
  "status_id": 2
}
```
:white_check_mark: **Response (แก้ไขงานสำเร็จ):**
```json
{
  "message": "Task updated successfully"
}
```

---
```
```
###  ทดสอบ `register.php` (สมัครสมาชิก)

**:small_blue_diamond: POST Request:**  
```
http://26.21.85.254:8080/Reportig/api/register.php
```

**:small_blue_diamond: Body (JSON):**
```json
{
    "user_name": "testuser",
    "password": "123456",
    "f_name": "ทดสอบ",
    "l_name": "ยูสเซอร์",
    "email": "testuser@email.com",
    "role_id": "2",
    "department_id": "1"
}
```

:white_check_mark: **Response (หากสมัครสำเร็จ):**
```json
{
    "success": "User registered successfully",
    "employee_id": 5
}
```

:x: **Response (หากสมัครไม่สำเร็จ):**
```json
{
    "error": "Invalid username or password"
}
```

---
```
```
###  ทดสอบ `login.php` (เข้าสู่ระบบ)

**:small_blue_diamond: POST Request:**  
```
http://26.21.85.254:8080/Reportig/api/login.php
```

**:small_blue_diamond: Body (JSON):**
```json
{
    "user_name": "testuser",
    "password": "123456"
}
```

:white_check_mark: **Response (หากเข้าสู่ระบบสำเร็จ):**
```json
{
    "success": "Login successful",
    "user": {
        "employee_id": 3,
        "user_name": "testuser",
        "first_name": "ทดสอบ",
        "last_name": "ยูสเซอร์",
        "role_id": 2,
        "role_name": "พนักงาน",
        "department_id": 1,
        "department_name": "บริหารทั่วไป",
        "organization_id": 1,
        "organization_name": "อ.บ.ต.ทดสอบ"
    }
}
```

:x: **Response (หากเข้าสู่ระบบไม่สำเร็จ):**
```json
{
    "error": "Invalid username or password"
}
```

---
```
```
###  ทดสอบ `image_api.php` (อัปโหลด/อัปเดต/ดึงรูปภาพ)

**:small_blue_diamond: POST Request (อัปโหลดรูปภาพ):**  
```
http://localhost:8080/Reportig/api/image_api.php
```

**:small_blue_diamond: Body (Form-Data):**
- `image`: (ไฟล์รูปภาพ)

:white_check_mark: **Response (สำเร็จ):**
```json
{
    "success": "Image uploaded successfully",
    "id": 1
}
```

---

**:small_blue_diamond: PUT Request (อัปเดตรูปภาพ):**  
```
http://localhost:8080/Reportig/api/image_api.php?id=1
```

**:small_blue_diamond: Body (Form-Data):**
- `image`: (ไฟล์รูปภาพใหม่)

:white_check_mark: **Response (สำเร็จ):**
```json
{
    "success": "Image updated successfully",
    "id": "1"
}
```

---

**:small_blue_diamond: GET Request (ดึงรูปภาพ):**  
```
http://localhost:8080/Reportig/api/image_api.php?id=1
```

:white_check_mark: **Response (หากพบรูปภาพ):**
- แสดงรูปภาพโดยตรง

:x: **Response (หากไม่พบรูปภาพ):**
```json
{
    "error": "Image not found"
}
```

