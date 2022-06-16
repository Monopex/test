<?php
header('Content-Type: text/html; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: *');
header('Access-Control-Allow-Headers: Origin, Content-Type, jwt');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');

// $start = microtime(true);
// $server_start = memory_get_usage(); // Нагрузка на сервер
ini_set('display_errors','Of');

if (strtoupper($_SERVER['REQUEST_METHOD']) == 'OPTIONS'){
	echo ' ';
	exit;
}
//Нужно проверять на наличие сессии, на симуляции выдает warning
if(!isset($_SESSION)){
	 session_start();
}
define("GLOBAL_DIR", __DIR__);

require 'vendor/predis/predis/src/Autoloader.php';
require 'vendor/fpdf/PDFgenerator.php';
require 'vendor/phpmailer/phpmailer/src/PHPMailer.php';
require 'vendor/phpmailer/phpmailer/src/SMTP.php';
Predis\Autoloader::register();

include 'handlers/index.p';
include 'validators/index.p';

include 'engine/engine.p';
new engine\E();


function FBytes($bytes, $precision = 2) {
    $units = array('B', 'KB', 'MB', 'GB', 'TB');
    $bytes = max($bytes, 0);
    $pow = floor(($bytes?log($bytes):0)/log(1024));
    $pow = min($pow, count($units)-1);
    $bytes /= pow(1024, $pow);
    return round($bytes, $precision).' '.$units[$pow];
}

//print_r(E::$Errors);
// echo 'Памяти '.FBytes(memory_get_usage() - $server_start).'<br>'; // Нагрузка на сервер
// echo "Время выполнения скрипта: ".(microtime(true) - $start).'<br>';
?>
