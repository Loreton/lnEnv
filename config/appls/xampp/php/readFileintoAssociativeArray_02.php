<?php
// https://stackoverflow.com/questions/45995402/reading-from-a-file-into-an-associative-array
$filepath = "questions.csv";
$content = file_get_contents($filepath);

$rows = explode("\n", $content);

$output_array = [];
foreach ($rows as $row) {
    $columns = explode(',', $row);

    $key=trim($columns[0]);
    if ( ! str_starts_with($key, "#") ) {
        $output_array[$key] = trim($columns[1]);
    } else {
        echo "skipping line: $key\n";
    }
}

print_r($output_array);
foreach ($output_array as $key => $value) {
    echo "\n\tkey: $key\n\tvalue: $value\n";
}
?>