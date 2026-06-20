<?php
// https://stackoverflow.com/questions/45995402/reading-from-a-file-into-an-associative-array
$filepath = "questions.csv";

$content = file($filepath);

foreach($content as $pca){
    $p_codes=explode(',',$pca);
    $output_array[$p_codes[0]] = $p_codes[1];
}
print_r($output_array);
?>