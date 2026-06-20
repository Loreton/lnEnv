<?php
// https://gist.github.com/benbalter/3173096
$filepath = "questions.csv";

$content = file_get_contents($filepath);
$rows = explode("\n", $content);


// Parsing the data in csv file
$csv = array_map('str_getcsv', file($filepath));

/*At this point you already have an array with the data but
 * the first row is the header row in your csv file */

//remove header row
// array_shift($csv);

$output_array = [];

//Walk the array and add the needed data into some another array
array_walk($csv, function($row) use (&$output_array) {
    $key=trim($row[0]);
    if ( ! str_starts_with($key, "#") ) {
        $output_array[$key] = trim($row[1]);
    } else {
        echo "skipping line: $key\n";
    }
    // $output_array[trim($row[0])] = trim($row[1]);
});

print_r($output_array);
?>