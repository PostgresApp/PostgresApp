<?php

$db = new PDO('pgsql:host=localhost');
$statement = $db->prepare("SELECT datname FROM pg_database");
$statement->execute();
while ($row = $statement->fetch()) {
    echo "<p>" . htmlspecialchars($row["datname"]) . "</p>\n";
}

?>