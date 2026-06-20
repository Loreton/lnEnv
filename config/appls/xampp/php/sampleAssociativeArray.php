<?php
// $file = fopen("questions.txt", "r", FILE_IGNORE_NEW_LINES || FILE_SKIP_EMPTY_LINES );
// $file = fopen("questions.txt", "r", FILE_SKIP_EMPTY_LINES );
// $lines = array();

// while (!feof($file)) {
//    $lines[] = fgets($file);
// }

// fclose($file);


$quiz = array(
    "In quale linguaggio di programmazione è scritto il sistema operativo Linux?" => "c",
    "Come si chiama il processo di identificare e correggere gli errori nel codice?" => "debugging",
    "Qual è il termine per una funzione che chiama se stessa?" => "ricorsione",
    "Cos'è una variabile che non può essere modificata dopo la sua assegnazione?" => "costante",
    "Qual è il tipo di ciclo che si usa per ripetere un blocco di codice un numero definito di volte?" => "for",
    "Che tipo di dati rappresenta una sequenza di caratteri?" => "stringa",
    "Qual è il termine che descrive una classe che eredita da un'altra classe?" => "sottoclasse",
    "Come si chiama il tipo di dato che rappresenta un numero senza decimali?" => "intero",
    "Quale linguaggio è standardizzato per database basati sul modello relazionale?" => "sql",
    "Qual'è la funzione PHP per terminare uno script?" => "exit"
    );

// var_dump($lines);
var_dump($quiz);
// echo array_rand($quiz, 0);


foreach ($quiz as $key => $value) {
    echo "key: $key - value: $value\n";
}
?>