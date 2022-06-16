<?php
/*
	@base_counts
	1	id	Первичный	int(11)
	2	user_id	int(11)
	3	make	varchar(255)
	4	model	varchar(255)
	5	year	varchar(5)
	6	power	varchar(5)
	7	price	varchar(10)
	8	drivers	text
	9	extended	longtext
	10	date_add	int(11)

*/
use engine\Model;

class base_countsModel extends Model{

	public $table = 'base_counts';

	public $fields = [
		'id','user_id','make','model','year','power','price','drivers','extended','date_add'
	];

	public function get_all(){
		return $this->select([
			'query'=>$this->fields,
			'where'=>'`id`>0',
			'order'=>'id',
			'return'=>['assoc','all'],
		]);
	}

	public function get_id($id){
		return $this->select([
			'query'=>$this->fields,
			'where'=>'`id`=:id',
			'prepare'=>[':id'=>$id],
			'return'=>['assoc'],
		]);
	}

	public function get_all_user_id($user_id)
	{
		return $this->select([
			'query'=>$this->fields,
			'where'=>'`user_id`=:user_id',
			'prepare'=>[':user_id'=>$user_id],
			'order'=>'id',
			'desc'=>true,
			'return'=>['assoc','all'],
		]);
	}

	public function get_all_user_id_limit($Data)
	{
		return $this->select_pagination([
			'query'=>$this->fields,
			'where'=>'`user_id`=:user_id',
			'order'=>'id',
			'desc'=>1,
			'prepare'=>[':user_id'=>$Data['user_id']],
			'return'=>['assoc','all'],
			'pagination'=>$Data['pagination'],
		]);
	}

	public function filter($field,$value){
		return $this->select([
			'query'=>[$fields],
			'where'=>'`'.$field.'`=:'.$field.'1 OR `'.$field.'` LIKE :'.$field.'2',
			'prepare'=>[':'.$field.'1'=>''.$value.'',':'.$field.'2'=>'%'.$value.'%'],
			'return'=>['assoc','all'],
		]);
	}

	public function add($Data){
		return $this->insert([
			'user_id'=>$Data['user_id'],
			'make'=>$Data['make'],
			'model'=>$Data['model'],
			'year'=>$Data['year'],
			'power'=>$Data['power'],
			'price'=>$Data['price'],
			'drivers'=>$Data['drivers'],
			'extended'=>$Data['extended'],
			'date_add'=>time(),
		]);
	}

	public function update_status_activation_key($Data){
		return $this->update([
			'query'=>[
				'status'=>$Data['status'],
				'activation_key'=>$Data['activation_key']
			],
			'where'=>'`id`=:id',
			'prepare'=>[':id'=>$Data['id']],
		]);
	}

	public function dell($id){
		$this->del([
			'where'=>'`id`=:id',
			'prepare'=>[':id'=>$id]
		]);
	}
}
?>
