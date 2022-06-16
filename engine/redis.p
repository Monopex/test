<?php
namespace engine;

class DBRedis {

    public $client;

    public function __construct(){
        $this->client = new \Predis\Client([
            'scheme' => 'tcp',
            'host'   => '127.0.0.1',
            'port'   => 6379,
        ]);
    }

    public function set($key, $value, $expire = false){
        $this->client->set($key, $value);
        if ($expire !== false) {
            $this->client->expire($key, $expire);
        }
    }

    public function get($key){
        return $this->client->get($key);
    }

    public function ttl($key){
        return $this->client->ttl($key);
    }

    public function del($key){
        return $this->client->del($key);
    }

    public function hset($table, $key, $value){
        return $this->client->hset($table,$key,$value);
    }

    public function hget($table, $key){
        return $this->client->hget($table,$key);
    }

    public function hdel($table, $key){
        return $this->client->hdel($table,$key);
    }
}
?>
