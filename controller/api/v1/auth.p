<?php
namespace controller\api\v1;

use engine\E;
use engine\myException;
use engine\DBRedis;

Class authController{

    /**
     * Авторизация внутри сервиса АПИ ПКАСКО
     */
    public function POST_signin(){
        /* ПРОВЕРКА АВТОРИЗАЦИИ ПОЛЬЗОВАТЕЛЯ */
        $user_token = \handlers\Authorize::user_info();

        $redis = new DBRedis();

        $API_KEY = $redis->get('kasko_api_key');

        if (!$API_KEY) {
            $Data = file_get_contents('https://pkasko.com/auth/api?login=dmsilin@yandex.ru&password=123456');
            $Data = json_decode($Data, true);
            $API_KEY = $Data['api_key'];
            $redis->set('kasko_api_key', $API_KEY);
        }

	      return [
          'api_key' => $API_KEY
        ];
    }

    /**
     * Сброс ключа API в случае, если он перестал подходить
     */
    public function POST_drop(){
        $redis = new DBRedis();
        $redis->del('kasko_api_key');
        return [
            'type' => 'success'
        ];
    }

    /**
     * Сброс ключа API
     */
    public function GET_test()
    {
        $redis = new DBRedis();
        $redis->set('kasko_api_key', '123');
    }

}
?>
