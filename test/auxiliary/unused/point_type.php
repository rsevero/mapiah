<?php

$original = file_get_contents("./scrap_types.txt");
$original = explode("\n", $original);
$modified = "";

foreach($original as $line)
{
    $modified .= "//\tQStringLiteral(\"" . $line . "\"),\n";
}

file_put_contents("./scrap_types-new.txt", $modified);
