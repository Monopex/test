<?php
/*
	@specify_counts
	1	id  Первичный	int(11)
	2	user_id	int(11)
    3	company_code	varchar(100)
    4	company_shortname	varchar(150)
		4 policy_sum
	4	data	longtext
    5	date_add	int(11)
*/
use engine\Model;

class specify_countsModel extends Model{

	public $table = 'specify_counts';

	public $fields = [
		'id','user_id','company_code','company_shortname', 'policy_sum','data','date_add'
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

	public function get_all_limits_pag($Data){
		$result = $this->select_pagination([
			'query'=>$this->fields,
			'where'=>'`id` > 0',
			'order'=>'id',
			'desc'=>1,
			'return'=>['assoc','all'],
			'pagination'=>$Data['pagination'],
		]);
		return($result);
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
      'company_code'=>$Data['company_code'],
			'company_shortname'=>$Data['company_shortname'],
      'policy_sum'=>$Data['policy_sum'],
			'data'=>$Data['data'],
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
