<?php
namespace engine;
/*
	@DB - полное управление БД.
*/
use \PDO;

class DB{
	private	$PDO;

	public function __construct () {
		$ActiveDB = E::$Config->ActiveDB;
		try {
			$this->PDO = new PDO(
				E::$Config->DB[$ActiveDB]['db_type'].':host='.E::$Config->DB[$ActiveDB]['host'].';dbname='.E::$Config->DB[$ActiveDB]['name'],
				E::$Config->DB[$ActiveDB]['user'],
				E::$Config->DB[$ActiveDB]['password']
			);
			$this->PDO->query("SET NAMES utf8");
		} catch (PDOException $Exception) {
			throw new myException([
					'message'=>$Exception->getMessage(),
					'code'=>701,
					'type'=>'connect',
				]);
		}
		// $this->PDO = new PDO(
		// 	E::$Config->DB[$ActiveDB]['db_type'].':host='.E::$Config->DB[$ActiveDB]['host'].';dbname='.E::$Config->DB[$ActiveDB]['name'],
		// 	E::$Config->DB[$ActiveDB]['user'],
		// 	E::$Config->DB[$ActiveDB]['password']
		// );
		// $this->PDO->query("SET NAMES utf8");
	}

	public function select($Data){
		$Table = E::$Config->DB[E::$Config->ActiveDB]['prefix'].$Data['table'];
		$query = 'SELECT ';

		if (isset($Data['disting']))  $query.=' DISTINCT '; // Только для уникальных значений

		if ($Data['query'] == '*'){
			$query.= ' * ';
		}
		else{
			for ($i=0; $i<count($Data['query']); $i++) {
				$query.='`'.$Data['query'][$i].'`,';
			}
			$query = substr ($query, 0, -1);  //Убираем лишнюю запятую
		}

		if (isset($Data['func'])){ // Функции в PDO SQL Например MIN(`price`) SUM
			$query = 'SELECT '.$Data['func'];
		}
	/*	if (isset($Data['group'])){ // Группы в PDO SQL Например GROUP BY `date`, `operator_id` или GROUP BY `date`
			$query = 'GROUP BY '.$Data['group'];
		}*/

		$query.=" FROM ".$Table;
		if ($Data['where'])  $query.=' WHERE '.$Data['where'];
		if (isset($Data['order']))  $query.=' ORDER BY `'.$Data['order'].'`';
		if (isset($Data['desc']))  $query.=' DESC ';
		if (isset($Data['limit']))  $query.=' LIMIT '.$Data['limit'];
		// echo '<br>'.$query.'<br><br>';
		$result_set = $this->PDO->prepare($query);
		if (!isset($Data['prepare'])) {
			$Data['prepare'] = [];
		}
		$result_set->execute($Data['prepare']);

		if(strlen($result_set->errorInfo()[1] > 0)){
			throw new myException([
					'message'=>$result_set->errorInfo()[2],
					'code'=>701,
					'type'=>'select',
				]);
		}

		$i = 0;
		$datas = [];
		if ($Data['return'][0] == 'assoc'){ // Если мы хотим вытащить асоциативный массив.
			while ($row = $result_set->fetch(PDO::FETCH_ASSOC)){
				$datas[$i] = $row;
				$i++;
			}
		}
		if ($Data['return'][0] == 'object'){ // Если мы хотим вытащить асоциативный массив.
			while ($row = $result_set->fetch(PDO::FETCH_OBJ)) {
				$datas[$i] = $row;
				$i++;
			}
		}
		//echo $query.'<br>';
		//print_r($Data['prepare']);

		$errors = $result_set->errorInfo();
		//echo print_r($result_set->errorInfo());
		if ($errors[1] > 0){ // Если 0 то опирация выполненная успешно
			$errors[] = [
				'type'=>'select',
				'href'=>$_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI'],
				'post'=>$_POST,
				'query'=>$query,
				'prepare'=>$Data['prepare'],
				'data'=>$Data,
			];
			E::$Errors['sql'][] = $errors;
		}
		if (isset($Data['return'][1])){
			if ($Data['return'][1] == 'all'){ // Если массив будет в массиве $Data[0]['login']
				return $datas;
			}
		}
		else{
			if (isset($datas[0])){
				return $datas[0];
			}
		}
	}

	/*
		return $this->select([
			'query'=>[],
			'where'=>'',
			'join'=>[
				'type'=>'left',
				'table'=>'users',
				'query'=>['username'],
				'link'=>['user_id','id'],
			],
			'prepare'=>[],
			'return'=>['assoc','all'],
		]);
	*/
	public function select_join(&$Data){
		$Prefix = E::$Config->DB[E::$Config->ActiveDB]['prefix'];
		$table = $Prefix.$Data['table'];

		$query = 'SELECT ';
		for($i=0; $i<count($Data['query']); $i++){
			$query.= ' '.$table.'.'.$Data['query'][$i];
			if ($i<(count($Data['query'])-1)){
				$query.=',';
			}
		}
		for($i=0;$i<count($Data['join']);$i++){
			$join_table = '';
			$join_table = $Prefix.$Data['join'][$i]['table'];
			for($j=0; $j<count($Data['join'][$i]['query']); $j++){
				if($j == 0){
					$query.= ',';
				}
				$query.= ' '.$join_table.'.'.$Data['join'][$i]['query'][$j];
				if ($j<(count($Data['join'][$i]['query'])-1)){
					$query.=',';
				}
			}
		}

		$query.= ' FROM '.$table.' ';


		for($i=0;$i<count($Data['join']);$i++){
			$join_table = '';
			$join_table = $Prefix.$Data['join'][$i]['table'];
			if ($Data['join'][$i]['type'] == 'left'){
				$query.= ' LEFT ';
			}
			$query.= ' JOIN '.$join_table.' ON ';

			if(empty($Data['join'][$i]['linked_table'])){
				$query.= $table.'.'.$Data['join'][$i]['link'][0];
			}else{
				$query.= $join_table.'.'.$Data['join'][$i]['link'][0];
			}

			$query.= ' = ';

			if(empty($Data['join'][$i]['linked_table'])){
				$query.= $join_table.'.'.$Data['join'][$i]['link'][1];
			}else{
				$query.= $Prefix.$Data['join'][$i]['linked_table'].'.'.$Data['join'][$i]['link'][1];

			}
		}


		for($i=0;$i<count($Data['fields']);$i++){
			$Data['where'] = str_replace('`'.$Data['fields'][$i].'`',
				$table.'.'.$Data['fields'][$i],
				$Data['where']
			);
		}
		if ($Data['where'])  $query.=' WHERE '.$Data['where'];
		if (isset($Data['order']))  $query.=' ORDER BY `'.$Data['order'].'`';
		if (isset($Data['desc']))  $query.=' DESC ';
		if (isset($Data['limit']))  $query.=' LIMIT '.$Data['limit'];

		$query = str_replace('&table&',$table,$query);
		$query = str_replace('&join_table&',$join_table,$query);

		$result_set = $this->PDO->prepare($query);

		$result_set->execute($Data['prepare']);
		$i = 0;
		$datas = [];
		if ($Data['return'][0] == 'assoc'){ // Если мы хотим вытащить асоциативный массив.
			while ($row = $result_set->fetch(PDO::FETCH_ASSOC)){
				$datas[$i] = $row;
				$i++;
			}
		}
		if ($Data['return'][0] == 'object'){ // Если мы хотим вытащить асоциативный массив.
			while ($row = $result_set->fetch(PDO::FETCH_OBJ)) {
				$datas[$i] = $row;
				$i++;
			}
		}


		//echo $query;
		//print_r($Data['prepare']);


		$errors = $result_set->errorInfo();

		//echo print_r($result_set->errorInfo());
		if ($errors[1] > 0){ // Если 0 то опирация выполненная успешно
			$errors[] = [
				'type'=>'select',
				'href'=>$_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI'],
				'post'=>$_POST,
				'query'=>$query,
				'prepare'=>$Data['prepare'],
				'data'=>$Data,
			];
			E::$Errors['sql'][] = $errors;
		}
		if (isset($Data['return'][1])){
			if ($Data['return'][1] == 'all'){ // Если массив будет в массиве $Data[0]['login']
				return $datas;
			}
		}
		else{
			if (isset($datas[0])){
				return $datas[0];
			}
		}
	}

	/*
		$itog[] = [
			'table'=>$this->table,
			'query'=>[
				'armprice'=>$Data['armprice'],
			],
			'where'=>'`complex_id` = '.$Data['complex_id'].' AND `rooms_num` = '.$Data['rooms_num'].' AND `status` != 3 AND `status` != 4 AND `type`= 1',
			'prepare'=>[],
		];
		E::$DB->update_all($itog);
	*/
	public function update_all($Data_all){ // Обновляет массив запросов

		$query_all = '';
		$Prepare = [];
		for ($i=0; $i<count($Data_all); $i++){
			$Data = $Data_all[$i];
			$Table = '`'.E::$Config->DB[E::$Config->ActiveDB]['prefix'].$Data['table'].'`';
			$query = 'UPDATE '.$Table.' SET ';
			foreach ($Data['query'] as $k=>$v){
				$query.= ''.$k.' = '.$v.',';
				//$Prepare[':'.$k] = $v;
			}
		//	if ($Data['prepare']) $Prepare = array_merge($Prepare, $Data['prepare']);
			$query = substr ($query, 0, -1);
			if ($Data['where']) {
				$query.= ' WHERE '.$Data['where'].'; ';
				$query_all.= $query;
			}

		}

		$this->SQL($query_all);

	//	$result_set = $this->PDO->prepare($query);
	//	$result_set->execute($Prepare);
	//	echo print_r($result_set->errorInfo());
	}

	/*
		insert_all([
			'table'=>'yyy',
			'query'=>[
				[
					'title'=>'Привет',
					'count'=>5,
				],
				[
					'title'=>'Привет 1',
					'count'=>7,
				]
			],
		]);
	*/
	public function insert_array($Data){
		$return = [];
		for ($i=0; $i<count($Data['query']); $i++){
			$return[] = $this->insert([
				'table'=>$Data['table'],
				'query'=>$Data['query'][$i],
			]);
		}
		return $return;
	}





	public function insert($Data){
		$Table = E::$Config->DB[E::$Config->ActiveDB]['prefix'].$Data['table'];
		$query = 'INSERT INTO '.$Table.' (';
		$Keys = ''; // Храняться поля к которым обращаемся
		$Value = '';// Храняться значения которые записываем
		foreach ($Data['query'] as $k=>$v){
			$Keys.= '`'.$k.'`,';
			$Value.= ':'.$k.',';
		}
		$Keys = substr ($Keys, 0, -1);
		$Value = substr ($Value, 0, -1);
		$query .= $Keys.') VALUES ('.$Value.')';
		$result_set = $this->PDO->prepare($query);
		$result_set->execute($Data['query']);
		if(strlen($result_set->errorInfo()[1] > 0)){
			throw new myException([
					'message'=>$result_set->errorInfo()[2],
					'code'=>701,
					'type'=>'insert',
				]);
		}

		$lastInsertId = $this->PDO->lastInsertId(); // id вставленной записи
	//	echo print_r($result_set->errorInfo());
		$errors = $result_set->errorInfo();
		if ($errors[1] > 0){ // Если 0 то опирация выполненная успешно
			$errors[] = [
				'type'=>'insert',
				'href'=>$_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI'],
				'post'=>$_POST,
				'query'=>$query,
				'prepare'=>$Data['prepare'],
				'data'=>$Data,
			];
			E::$Errors['sql'][] = $errors;
		}

		return $lastInsertId;
	}

	public function update($Data){
		$Table = E::$Config->DB[E::$Config->ActiveDB]['prefix'].$Data['table'];
		$query = 'UPDATE '.$Table.' SET ';
		$Prepare = [];
		foreach ($Data['query'] as $k=>$v){
			$query.= '`'.$k.'` = :'.$k.',';
			$Prepare[':'.$k] = $v;
		}
		if ($Data['prepare']) $Prepare = array_merge($Prepare, $Data['prepare']);
		$query = substr ($query, 0, -1);
		if ($Data['where']) {
			$query .= ' WHERE '.$Data['where'];
			$result_set = $this->PDO->prepare($query);
			$result_set->execute($Prepare);

			if(strlen($result_set->errorInfo()[1] > 0)){
				throw new myException([
						'message'=>$result_set->errorInfo()[2],
						'code'=>701,
						'type'=>'update',
					]);
			}

			$errors = $result_set->errorInfo();
		if ($errors[1] > 0){ // Если 0 то опирация выполненная успешно
			$errors[] = [
				'type'=>'update',
				'href'=>$_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI'],
				'post'=>$_POST,
				'query'=>$query,
				'prepare'=>$Prepare,
				'data'=>$Data,
			];
			E::$Errors['sql'][] = $errors;
		}
			//echo print_r($result_set->errorInfo());
		}
	}

	/*
		[
			'where'=>'`id`=:id AND `type`=:type',
			'prepare'=>[
				[':id'=>5,':type'=>'mini'],
				[':id'=>7,':type'=>'max']
			],
		]
	*/
	public function del_array($data){
		for ($i=0; $i<count($data['prepare']); $i++){
			$this->del([
				'table'=>$data['table'],
				'where'=>$data['where'],
				'prepare'=>$data['prepare'][$i],
			]);
		}
	}

	public function del($Data){
		$Table = E::$Config->DB[E::$Config->ActiveDB]['prefix'].$Data['table'];
		if ($Data['where']){
			$query = 'DELETE FROM '.$Table.' WHERE '.$Data['where'];
			$result_set = $this->PDO->prepare($query);
			$result_set->execute($Data['prepare']);

			if(strlen($result_set->errorInfo()[1] > 0)){
				throw new myException([
						'message'=>$result_set->errorInfo()[2],
						'code'=>701,
						'type'=>'delete',
					]);
			}

			$errors = $result_set->errorInfo();
			if ($errors[1] > 0){ // Если 0 то опирация выполненная успешно
				$errors[] = [
					'type'=>'del',
					'href'=>$_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI'],
					'post'=>$_POST,
					'query'=>$query,
					'prepare'=>$Data['prepare'],
					'data'=>$Data,
				];
				E::$Errors['sql'][] = $errors;
			}
		}
	}

	public function counts ($Data){
		$Table = E::$Config->DB[E::$Config->ActiveDB]['prefix'].$Data['table'];
		$query = 'SELECT COUNT(`id`) FROM '.$Table;
		if ($Data['where']) $query.=' WHERE '.$Data['where'];
		$result_set = $this->PDO->prepare($query);
		$result_set->execute($Data['prepare']);
		if(strlen($result_set->errorInfo()[1] > 0)){
			throw new myException([
					'message'=>$result_set->errorInfo()[2],
					'code'=>701,
					'type'=>'count',
				]);
		}

 		$row = $result_set->fetch(PDO::FETCH_ASSOC);
		$errors = $result_set->errorInfo();
		if ($errors[1] > 0){ // Если 0 то опирация выполненная успешно
			$errors[] = [
				'type'=>'counts',
				'href'=>$_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI'],
				'post'=>$_POST,
				'query'=>$query,
				'prepare'=>$Data['prepare'],
				'data'=>$Data,
			];
			E::$Errors['sql'][] = $errors;
		}

		$total = $row['COUNT(`id`)']; // всего записей
		return $total;
	}

	public function SQL($query, $prepare = [])
	{
		$result_set = $this->PDO->prepare($query);
		$result_set->execute($prepare);
		$datas = [];
		$i = 0;
		while ($row = $result_set->fetch(PDO::FETCH_OBJ)) {
			$datas[$i] = $row;
			$i++;
		}
		return $datas;
	}

		/* Скорей всего удалить этот метод */
	// public function SQL($query, $prepare=[]){ // Создано чтоб генерировать таблици и БД.
	// 	$result_set = $this->PDO->prepare($query);
	// 	$errors = $result_set->errorInfo();
	// 	if ($errors[1] > 0){ // Если 0 то опирация выполненная успешно
	// 		$errors[] = [
	// 			'type'=>'sql',
	// 			'href'=>$_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI'],
	// 			'post'=>$_POST,
	// 			'query'=>$query,
	// 			'prepare'=>$Data['prepare'],
	// 			'data'=>$Data,
	// 		];
	// 		E::$Errors['sql'][] = $errors;
	// 	}
	// 	return $result_set->execute($prepare);
	// }

	public function __destruct() {
		$this->PDO = null;
	}

}
?>
