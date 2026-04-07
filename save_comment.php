<?php

$conn = new mysqli("localhost","root","","wedding");

if ($conn->connect_error) {
    die("Koneksi gagal: " . $conn->connect_error);
}

$name = $_POST['name'];
$message = $_POST['message'];

$stmt = $conn->prepare("INSERT INTO comments (name, message) VALUES (?, ?)");
$stmt->bind_param("ss", $name, $message);
$stmt->execute();

echo "success";

$conn->close();
?>