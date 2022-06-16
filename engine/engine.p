<?php
namespace engine;

include 'engine/function.p';
include 'engine/model.p';
include 'engine/exception.p';
include 'engine/config.p';
include 'engine/redis.p';
include 'engine/dbpdo.p';

use engine\Config;
use engine\Model;
use engine\Exception;

class E{

	public static $CPU;
	public static $Config;

	public static $Errors = []; // Массив ошибок.
	public static $RequiresType = 'GET';
	public static $Models;
	public static $Controllers;


	public function __construct(){
		self::CPU();

		self::$Config = new Config();
		self::getController();
	}

	public static function Controller ($path,$name,$construct=null){	// Метод позволяет делать бесконечное вложение контроллеров. Получаем массив
		//Делаем проверку на отсутствующие ключи массива
		if (!empty(self::$Controllers[$name])){

		}
		else{
			self::$Controllers[$name] = true;
			include 'controller/'.$path.'/'.$name.'.p';


			// $Controller = new $full_name();
			// if (!method_exists(($Controller), $method_name)) {
			// 	self::Error404();
			// }
			// $Result = call_user_func([$Controller, $method_name]);
			// self::ControllerResultDisplay($Result, $method_name);
			//
			//
			// self::$Controllers[$name] = true;
			// require_once 'controller/'.$path.'/'.$name.'.p'; // Путь к контроллеру
		}
		$full_name = 'controller\\'.str_replace('/','\\',$path).'\\'.$name.'Controller';
		// $full_name = $name.'Controller';
		return new $full_name($construct);
	}


	public static function Model($modelName){
		if (self::$Models[$modelName]){
			return self::$Models[$modelName];
		}
		else{
			if (file_exists('model/'.$modelName.'.p')){
				require_once 'model/'.$modelName.'.p';
				$AllModelName = $modelName.'Model';
				self::$Models[$modelName] = new $AllModelName();
				return self::$Models[$modelName]; // Вернули модель для работы.
			}
		}
	}

	public static function CPU (){
		$path = urldecode( $_SERVER['REQUEST_URI']); // Декодируем запросс к серверу
		//addslashes есть в insert и update прямо в обработчике базы данных.
		$path = explode('/',$path);
		$path = array_diff($path, ['']); // Удаляем из массива пустые значения.
		$path = array_values($path); // Пересчитали индексы.
		self::$CPU = $path;// self::Injections($path, 'html'); // Экранировали все спец символы и записали массив.
	}

	public static function Replacement ($Assoc, $Text){	// Принемает ассоциативный массив (ключ=>значение) и заменяет ключи на значения.
		if (is_array($Assoc)){ // Только если Assoc массив.
			$start = array(); // Массив ключей
			$end = array(); // Массив значений
			foreach ($Assoc as $k=>$v){
				$start[] = $k;
				$end[] = $v;
			}
			return str_replace($start, $end, $Text);
		}
	}



	public static function Render($Data, $Key=null, $Klayster=null){
		if (($Key == null) && ($Klayster == null)){ // Если рендерим только определённые данные.
			self::$View = $Data;
		}
		if (($Key != null) && ($Klayster == null)){ // Если заменяем в шаблоне ключевое слово на наш код.
			self::$View = str_replace($Key, $Data, self::$View);
		}
		/*
			Обёртывание - Klayster принимает как будем обёртывать.
			 Klayster = найдем Key в Data и запихаем туда View - Получаеться оборачиваем в пришедшие данные.
		*/
		if (($Key != null) && ($Klayster != null)){
			self::$View = str_replace($Key, self::$View, $Data);
		}
	}

	public static function getController() {

		$phpinput = file_get_contents("php://input");
		if ($phpinput != ''){
			$_POST['phpinput'] = $phpinput;
		}

		if (isset($_SERVER['CONTENT_TYPE'])) {
			if (mb_stristr($_SERVER['CONTENT_TYPE'], 'application/json')) {
				$_POST = json_decode($_POST['phpinput'], true);
			}
		}


		$controller_path = '';
		$controller_name = '';
		$method_name = '';
		$cpu_count = sizeof(self::$CPU);
		if ($cpu_count == 0) {
			$controller_path = 'index';
			$controller_name = 'index';
			$method_name = strtoupper($_SERVER['REQUEST_METHOD']).'_index';
		} else {
			for ($i = 0; $i < $cpu_count - 1; $i++) {
				if ($i == 0) {
					$controller_path.= self::$CPU[$i];
				} else {
					$controller_path.= '/'.self::$CPU[$i];
					$controller_name = self::$CPU[$i];
				}
			}

			$method_name = strtoupper($_SERVER['REQUEST_METHOD']).'_'.self::$CPU[$cpu_count - 1];
		}

		if ($controller_name == '') {
			$controller_path = 'index';
			$controller_name = 'index';
		}

		if (!file_exists('controller/'.$controller_path.'.p')) {
			self::Error404();
		}

		include 'controller/'.$controller_path.'.p';

		$full_name = 'controller\\'.str_replace('/','\\',$controller_path).'Controller';
		$Controller = new $full_name();
		if (!method_exists(($Controller), $method_name)) {
			self::Error404();
		}
		$Result = call_user_func([$Controller, $method_name]);
		self::ControllerResultDisplay($Result, $method_name);

		// $controller_path_new = '\controller\\'.str_replace('/','\\',$controller_path).'Controller';
		// print_r($controller_path_new);
		// $controller_path_new->$method_name();
		// use $controller_path_new;
		// print_r($controller_path_new);
		// exit;
		// $full_name = $controller_name.'Controller';
		// $Controller = new $full_name();
		//
		// if (!method_exists(($Controller), $method_name)) {
		// 	self::Error404();
		// }
		//
		// $Result = call_user_func([$Controller, $method_name]);
		// self::ControllerResultDisplay($Result, $method_name);

	}

	public static function ControllerResultDisplay($FunctionResult, $MethodName){
		if (mb_stristr($MethodName,'Page')) {
			self::Render($FunctionResult);
		}
		if (mb_stristr($MethodName,'POST')) {
			echo json_encode($FunctionResult);
		}
		if (mb_stristr($MethodName,'GET')) {
			echo json_encode($FunctionResult);
		}
	}

	public static function redirect($a){
		header('Location: '.$a);
		exit();
	}

	public static function Error404(){
		self::$Errors[] = '404'; // Отмечаем ошибку страницы.
		throw new myException([
			'message'=>'Такая страница не найдена',
			'code'=>404
		]);
	}
}
?>
