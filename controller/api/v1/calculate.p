<?php
namespace controller\api\v1;

use engine\E;
use engine\myException;
use engine\DBRedis;

Class calculateController{
    /**
     * Базовый рассчет АПИ ПКАСКО с возможной передачей дополнительных полей
     * @param make
     * @param model
     * @param year
     * @param power
     * @param price
     * @param drivers
     * @param extended
     */
    public function POST_base($iterator = 0){
        /* ПРОВЕРКА АВТОРИЗАЦИИ ПОЛЬЗОВАТЕЛЯ */
        $user_token = \handlers\Authorize::user_info();

        $url = 'https://pkasko.com/kasko/calc?api=1';

        \validators\Count::base_count();
        /* СБОР МАССИВА ДЛЯ ОТПРАВКИ В ПКАСКО */
    		$Data = [
    			'make' => $_POST['make'],
    			'model' => $_POST['model'],
    			'year' => $_POST['year'],
    			'power' => $_POST['power'],
    			'price' => $_POST['price'],
    			// 'drivers' => [
                //     [
                //         'sex' => 'm',
                //         'age' => '27',
                //         'experience' => '5',
                //         'marriage' => true,
                //     ]
                // ],
                'drivers' => $_POST['drivers'],
                'extended' => $_POST['extended'],
                // 'extended' => [
                //     'carNew' => 'Нет',
                //     'carGuarantee' => 'Нет',
                //     'credit' => 'Нет',
                //     'gap' => 'Нет',
                //     'owner' => 'Физическое лицо',
                //     'explDate' => '04.05.2019',
                //     'sto' => 'По выбору страхователя',
                //     'paymentOrder' => 'Единовременно',
                //     'multidrive' => 'Ограниченный список',
                //     'insurancePeriod' => '1 год',
                // ]
    		];
        // Записываем в БД входные данные для расчета
        // E::Model('base_counts')->add([
        //     'user_id'=>$user_token['id'],
      	// 		'make'=>$_POST['make'],
      	// 		'model'=>$_POST['model'],
      	// 		'year'=>$_POST['year'],
      	// 		'power'=>$_POST['power'],
      	// 		'price'=>$_POST['price'],
      	// 		'drivers'=>json_encode($_POST['drivers'],JSON_UNESCAPED_UNICODE),
      	// 		'extended'=>json_encode($_POST['extended'],JSON_UNESCAPED_UNICODE),
        // ]);

        /* ИНИЦИАЛИЗАЦИЯ ЗАПРОСА */
    		$ch = curl_init($url);
    		curl_setopt($ch, CURLOPT_HTTPHEADER, ['X-Authorization: '.E::Controller('api/v1','auth')->POST_signin()['api_key']]);
    		curl_setopt($ch, CURLOPT_HEADER, 1);
    		curl_setopt($ch, CURLOPT_TIMEOUT, 60);
    		curl_setopt($ch, CURLOPT_POST, 1);
    		curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($Data));
    		curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
    		$result = curl_exec($ch);
    		curl_close($ch);

            /* ВЫБОРКА ЗАПРОСА БЕЗ ЗАГОЛОВКОВ */
    		$pre_response = $result;

    		$startpos = stripos($result, '{');

    		$post_response = mb_substr($result, $startpos, strlen($result));

        $server_response = json_decode($post_response, true);

        /* Если требуется авторизация, значит сбрасывает ключ редиса и повторяем запрос */
        if (!isset($server_response['id'])) {
            if (mb_stristr($server_response['error']['message'],'авторизация')) {
                $iterator++;
                if ($iterator > 2) {
                    return [
                        'type' => 'error',
                        'text' => 'Рекурсия ушла слишком глубоко. Этой ошибки не должно было произойти, но если она произошла, уведомите администратора.'
                    ];
                }
                E::Controller('api/v1','auth')->POST_drop();
                // Передаем рекурсивно итератор
                return E::Controller('api/v1','calculate')->POST_base($iterator);
            }
        } else {
            // Переводим ответ сервера в человеко-читаемый формат
            // $company_count = sizeof($server_response['results']);
            // $Company_array = [];
            // for ($i = 0; $i < $company_count; $i++) {
            //     $Company_array[] = [
            //         'companyCode' => $server_response['results'][$i]['info']['code'],
            //         'sum' => $server_response['results'][$i]['result']['total']['premium'],
            //         'rate' => $server_response['results'][$i]['result']['total']['rate'],
            //         'options' => $server_response['results'][$i]['options'],
            //         'values' => $server_response['results'][$i]['values'],
            //         'warnings' => $server_response['results'][$i]['warnings'],
            //     ];
            // }
        }


        /* ВОЗВРАЩЕНИЕ РЕЗУЛЬТАТА ЗАПРОСА */
        return $server_response;
    }
    /**
     * Уточняющий рассчет по компании
     * @param companyCode
     * @param companyShortName
     * @param data
     */
    public function POST_specify($iterator = 0){
        /* ПРОВЕРКА АВТОРИЗАЦИИ ПОЛЬЗОВАТЕЛЯ */
        $user_token = \handlers\Authorize::user_info();

        \validators\Count::specify_count();


        $url = 'https://pkasko.com/kasko/options?code='.$_POST['companyCode'];

        /* ИНИЦИАЛИЗАЦИЯ ЗАПРОСА */
    		$ch = curl_init($url);
    		curl_setopt($ch, CURLOPT_HTTPHEADER, ['X-Authorization: '.E::Controller('api/v1','auth')->POST_signin()['api_key']]);
    		curl_setopt($ch, CURLOPT_HEADER, 1);
    		curl_setopt($ch, CURLOPT_TIMEOUT, 30);
    		curl_setopt($ch, CURLOPT_POST, 1);
    		curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($_POST['data']));
    		curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
    		$result = curl_exec($ch);
    		curl_close($ch);
        /* ВЫБОРКА ЗАПРОСА БЕЗ ЗАГОЛОВКОВ */
    		$pre_response = $result;

    		$startpos = stripos($result, '{');

    		$post_response = mb_substr($result, $startpos, strlen($result));

        $server_response = json_decode($post_response, true);

        // Если требуется авторизация, значит сбрасывает ключ редиса и повторяем запрос
        if (!isset($server_response['result'])) {
            if (mb_stristr($server_response['error']['message'],'авторизация')) {
                $iterator++;
                if ($iterator > 2) {
                    return [
                        'type' => 'error',
                        'text' => 'Рекурсия ушла слишком глубоко. Этой ошибки не должно было произойти, но если она произошла, уведомите администратора.'
                    ];
                }
                E::Controller('api/v1','auth')->POST_drop();
                // Передаем рекурсивно итератор
                $_POST['data'] = json_encode($_POST['data']);
                return E::Controller('api/v1','calculate')->POST_specify($iterator);
            }
        }
        if ($server_response['result']['total']['premium']) {
          /* ЗАПИСЬ В БД РЕЗУЛЬТАТА */
          E::Model('specify_counts')->add([
              'user_id'=>$user_token['id'],
              'company_code'=>$_POST['companyCode'],
              'policy_sum'=>$server_response['result']['total']['premium'],
              'company_shortname'=>$_POST['companyShortName'],
  	          'data'=>json_encode($_POST,JSON_UNESCAPED_UNICODE),
          ]);
        } else {
          /* ЗАПИСЬ В БД РЕЗУЛЬТАТА */
          E::Model('specify_counts')->add([
              'user_id'=>$user_token['id'],
              'company_code'=>$_POST['companyCode'],
              'policy_sum'=>0,
              'company_shortname'=>$_POST['companyShortName'],
  	          'data'=>json_encode($_POST,JSON_UNESCAPED_UNICODE),
          ]);
        }

        /* ВОЗВРАЩЕНИЕ РЕЗУЛЬТАТА ЗАПРОСА */
        return $server_response;
    }
}
?>
