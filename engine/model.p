<?php
namespace engine;
/*
	@Model - главный класс для создания и наследования моделей
*/

use engine\DB;
// require_once 'dbpdo.p';

Class Model{

	public $table; // Название таблицы
	public $filter_data; // Данные фильтра
	public $query = '*'; // Поля которые потоянно будем запращивать
	public $fields; // Поля которые потоянно будем запращивать
	// Типы данных
	protected function DB(){
		return new DB();
	}

	public function select($Data){
		$Data['table'] = $this->table;
		if (!isset($Data['query']) || (count($Data['query']) == 0)){
			$Data['query'] = $this->query;
		}
		return $this->DB()->select($Data);
	}

	public function select_pagination($Data){
		$Data['table'] = $this->table;
		if (!isset($Data['query']) || (count($Data['query']) == 0)){
			$Data['query'] = $this->query;
		}

		$Data['pagination']['recording'] = $this->DB()->counts([
			'table'=>$Data['table'],
			'where'=>$Data['where'],
			'prepare'=>$Data['prepare'],
		]);

		if ($Data['pagination']['count_field'] > 0){
			$Data['pagination']['count_page'] = ceil($Data['pagination']['recording'] / $Data['pagination']['count_field']);
		}
		else{
			$Data['pagination']['count_page'] = 0;
		}

		if ($Data['pagination']['active_page'] <= 0){
			$Data['pagination']['active_page'] = 1;
		}

		$Data['pagination']['start_position'] = ($Data['pagination']['active_page'] - 1)*$Data['pagination']['count_field']; // Расчитали стартовую запись с которой можно считывать данные.
		$Data['limit'] = $Data['pagination']['start_position'].', '.$Data['pagination']['count_field'];

		if ($Data['pagination']['return_all_in_page']){ // Если нам нужно вернуть все данные до страницы
			$Data['pagination']['start_position'] = 0; // Расчитали стартовую запись с которой можно считывать данные.
			$to_end = $Data['pagination']['count_field'];
			if ($Data['pagination']['active_page'] > 1){
				$to_end = $Data['pagination']['count_field']*$Data['pagination']['active_page'];
			}
			$Data['limit'] = $Data['pagination']['start_position'].', '.$to_end;
		}

		if (isset($_GET['exel'])){ // Если мы вытаскиваем exel документ
			unset($Data['limit']);
		}


		$itog = $this->DB()->select($Data);
		$base = [
			'base'=>$itog,
			'pagination'=>$Data['pagination'],
		];
	//	print_r($base);
		return $base;
	//	return E::$DB->select($Data);
	}

	public function insert($query){
		$Data = [
			'table'=>$this->table,
			'query'=>$query,
		];
		return $this->DB()->insert($Data);
	}

	public function insert_array($query){
		$Data = [
			'table'=>$this->table,
			'query'=>$query,
		];
		return $this->DB()->insert_array($Data);
	}

	public function update($Data){
		$Data['table'] = $this->table;
		return $this->DB()->update($Data);
	}

	public function update_all($Data){
		for ($i=0; $i<count($Data); $i++){
			$Data[$i]['table'] = $this->table;
		}
		return $this->DB()->update_all($Data);
	}

	public function del($Data){
		$Data['table'] = $this->table;
		return $this->DB()->del($Data);
	}

	public function del_array($Data){
		$Data['table'] = $this->table;
		return $this->DB()->del_array($Data);
	}

	public function counts($Data){
		$Data['table'] = $this->table;
		return $this->DB()->counts($Data);
	}

	public function select_join($Data){
		$Data['table'] = $this->table;
		$Data['fields'] = $this->fields;
		if (!isset($Data['query']) || (count($Data['query']) == 0)){
			$Data['query'] = $this->query;
		}
		return $this->DB()->select_join($Data);
	}

	// Нужен последний с условиями
	public function select_last($query=[]){ // Вытаскиваем последний элемент таблицы
		if (!isset($query) || (count($query) == 0)){
			$query = $this->query;
		}
		$Data = [
			'table'=>$this->table,
			'query'=>$query,
			'where'=>'`id`>0',
			'prepare'=>[],
			'order'=>'id',
			'limit'=>'1',
			'desc'=>1,
			'return'=>['assoc'],
		];
		return $this->DB()->select($Data);
	}

	public function select_first($query=[]){ // Вытаскиваем первый элемент таблицы
		if (!isset($query) || (count($query) == 0)){
			$query = $this->query;
		}
		$Data = [
			'table'=>$this->table,
			'query'=>$query,
			'where'=>'`id`>0',
			'prepare'=>[],
			'order'=>'id',
			'limit'=>'1',
			'return'=>['assoc'],
		];
		return $this->DB()->select($Data);
	}

	public function string_to_where($string, $Data=[]){ // Преобразуем строку в условие
		$Array = explode(',',$string);
		for ($i=0; $i<count($Array); $i++){
			$Data['where'].= '`id`=:id'.$i;
			$Data['prepare'][':id'.$i] = $Array[$i];
			if ($i < (count($Array)-1)){
				$Data['where'].= ' OR ';
			}
		}
		return $Data;
	}

	public function array_to_where($Array, $Data=[]){ // Преобразуем массив в условие
		for ($i=0; $i<count($Array); $i++){
			$Data['where'].= '`id`=:id'.$i;
			$Data['prepare'][':id'.$i] = $Array[$i];
			if ($i < (count($Array)-1)){
				$Data['where'].= ' OR ';
			}
		}
		return $Data;
	}

	public function array_to_where_whith_collum($Array, $collum_name, $Data=[]){ // Преобразуем массив в условие
		for ($i=0; $i<count($Array); $i++){
			$Data['where'].= '`'.$collum_name.'`=:'.$collum_name.$i;
			$Data['prepare'][':'.$collum_name.$i] = $Array[$i];
			if ($i < (count($Array)-1)){
				$Data['where'].= ' OR ';
			}
		}
		return $Data;
	}

	/*
		Достаточно указать поле по которому будем искать, значение которое будем искать и в ответ вы получиле полностью весь массив данных.
		$Data['field'] - поле которое ищем
		$Data['value'] - значение которое ищем
		$Data['object'] - объект в котором ищем
	*/
	public function searcher($Data){
		foreach($Data['object'] as $k=>$v){
			if ($v[$Data['field']] == $Data['value']){
				return $v; // Возвращаем массив со значением
			}
		}
		return [];
	}

	public function query($data){
		return $this->DB()->SQL($data['query'], $data['prepare']);
	}

}
?>
