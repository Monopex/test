<?php
namespace engine;
use \Exception;

Class myException extends Exception{

	public $data;

	public function __construct($data){
		$this->data = $data;
		parent::__construct($data['message'], $data['code']);
		$method = 'code_'.$data['code'];
		$message = json_encode([
			'exception'=>true,
			'exception_data'=>$this->$method(),
		],JSON_UNESCAPED_UNICODE);
		die($message);
	}

	public function add_log($data){
		echo 'Логирую: "'.$data.'"';
	}

	public function code_404(){
		http_response_code(404);
		$message = json_encode([
			'exception'=>true,
			'exception_data'=>[
				'message'=>$this->data['message'],
				'reason'=>'Неактуальная конфигурация сервера',
			],
		],JSON_UNESCAPED_UNICODE);
		die($message);
	}

	public function code_400(){
		http_response_code(400);
		$message = json_encode([
			'exception'=>true,
			'exception_data'=>[
				'message'=>$this->data['message'],
				'reason'=>'Неверный запрос',
			],
		],JSON_UNESCAPED_UNICODE);
		die($message);
	}

	public function code_401(){
		http_response_code(401);
		$message = json_encode([
			'exception'=>true,
			'exception_data'=>[
				'message'=>$this->data['message'],
				'reason'=>'В доступе отказано',
			],
		],JSON_UNESCAPED_UNICODE);
		die($message);
	}

	public function code_403(){
		http_response_code(403);
		$message = json_encode([
			'exception'=>true,
			'exception_data'=>[
				'message'=>$this->data['message'],
				'reason'=>'В доступе отказано',
			],
		],JSON_UNESCAPED_UNICODE);
		die($message);
	}

	public function code_500(){
		header("HTTP/1.0 500 Internal Server Error");
		$message = json_encode([
			'exception'=>true,
			'exception_data'=>[
				'message'=>$this->data['message'],
				'reason'=>'Неактуальная конфигурация сервера',
			],
		],JSON_UNESCAPED_UNICODE);
		die($message);
	}

	public function code_701(){ // Работа с базой данных
		http_response_code(423);
		$message = '';
		switch($this->data['type']){
			case 'connect':
				$message = 'Ошибка подключения';
			break;
			case 'insert':
				$message = 'Ошибка добавления данных';
			break;
			case 'update':
				$message = 'Ошибка обновления данных';
			break;
			case 'select':
				$message = 'Ошибка выборки данных';
			break;
			case 'count':
				$message = 'Ошибка подсчета данных';
			break;
			case 'delete':
				$message = 'Ошибка удаления данных';
			break;
		}
		return [
			'message'=>$message,
			'reason'=>$this->data['message'],
		];
	}

}
?>
