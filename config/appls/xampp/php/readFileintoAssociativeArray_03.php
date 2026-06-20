<?php
// https://gist.github.com/benbalter/3173096
$filepath = "questions.csv";

$content = file_get_contents($filepath);
$rows = explode("\n", $content);


$headers = str_getcsv( array_shift( $rows ) );

$output_array = array();

foreach ( $rows as $line ) {
    $row = array();
    foreach ( str_getcsv( $line, "," ) as $key => $field )
        $row[ $headers[ $key ] ] = $field;
    $row = array_filter( $row );
    $output_array[] = $row;
}

print_r($output_array);
?>