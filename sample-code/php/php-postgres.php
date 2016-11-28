<?php

$conn = pg_connect("postgresql://localhost");
$result = pg_query($conn, "SELECT * FROM pg_database;");
while ($row = pg_fetch_row($result)) {
  echo "<p>" . htmlspecialchars($row[0]) . "</p>\n";
}

?>