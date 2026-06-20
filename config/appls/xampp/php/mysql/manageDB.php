<?php

function openDB() {
    static $DBh = NULL;

    $servername = "localhost";
    $username = "root";
    $password = "";


    if ($DBh===NULL) {
        try {
            $DBh = new PDO("mysql:host=$servername;dbname=Loreto_01DB", $username, $password);
            // set the PDO error mode to exception
            // $DBh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            echo "Connected successfully\n";

        } catch(PDOException $e) {
            echo "Connection failed: " . $e->getMessage() . "\n";
        }
    }
    return $DBh;
}




function executeSql($db, $sql_string) {
    $stmth = $db->prepare($sql_string);
    $stmth->execute();
    $result = $stmth->fetchAll(PDO::FETCH_ASSOC);

    // echo "sono nel readData:\n";
    // print_r($result);
    // $conn = null;
    return $result;
}


/*
    Si assume che la colonna username sia univoca..
    pertanto controlliamo solo il primo record sena utilizzare il foreach
*/
function checkLogin($db, $user, $password) {
    $mySelect = "SELECT * from utenti WHERE username = '$user'";
    echo "mySelect: $mySelect\n";
    $result = executeSql($db, $mySelect);
    // print_r($result);
    if (! $result) {
        echo "username $user NOT found\n";
        return false;
    }

    // print_r($result[0]);
    // echo $result[0]["password"] . "\n";
    if ($password === $result[0]["password"]) {
        return true;
    } else  {
        echo "password NOT valid\n";
        return false;
    }


    // foreach($result as $row) {
    //     echo $row['password'];
    // }
    // echo "password: $result->password\n";
    // if ($result["password"]) {
        // code...
    // }
}

function displayData($db) {
    $mySelect = "SELECT * FROM utenti";
    $dati = executeSql($db, $mySelect);
    print_r($dati);
}




// ---  index.html

$conn=openDB();
if ($conn == NULL ) {
    echo "database not present\n";
    die;
}


// displayData($conn);
if (checkLogin($conn, "uloretow", "lolo")) {
    echo "utente autorizzato\n";
} else {
    echo "utente non autorizzato\n";
}


?>