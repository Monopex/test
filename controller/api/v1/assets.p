<?php
namespace controller\api\v1;

use engine\E;
use engine\myException;
use engine\DBRedis;

Class assetsController{

    /**
     * Получение списка дополнительных полей
     */
    public function GET_extended($iterator = 0){
        $redis = new DBRedis();

        $EXTENDED_FIELDS = $redis->get('kasko_extended_fields');

        if (!$EXTENDED_FIELDS) {
            /* ПРОВЕРКА АВТОРИЗАЦИИ ПОЛЬЗОВАТЕЛЯ */
            $user_token = \handlers\Authorize::user_info();
            // Получаем список полей по токену
            $url = 'https://pkasko.com/kasko/extended?show=2';

            $ch = curl_init($url);
            curl_setopt($ch, CURLOPT_HTTPHEADER, ['X-Authorization: '.E::Controller('api/v1','auth')->POST_signin()['api_key']]);
            curl_setopt($ch, CURLOPT_HEADER, 1);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
            $result = curl_exec($ch);
            curl_close($ch);

            $pre_response = $result;

            $startpos = stripos($result, '{');

            $post_response = mb_substr($result, $startpos, strlen($result));

            $server_response = json_decode($post_response, true);

            // Если требуется авторизация, значит сбрасываем ключ редиса и повторяем запрос
            if (!isset($server_response['values'])) {
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
                    $server_response = E::Controller('api/v1','assets')->GET_extended($iterator);
                }
            }

            $EXTENDED_FIELDS = $server_response;

            if ($EXTENDED_FIELDS['values']) {
                // Записываем кеш
                $redis->set('kasko_extended_fields', json_encode($EXTENDED_FIELDS, JSON_UNESCAPED_UNICODE));
            }

        } else {
            $EXTENDED_FIELDS = json_decode($EXTENDED_FIELDS, true);
        }

	      return $EXTENDED_FIELDS;
    }

    /**
     * Список всех страховых компаний
     */
    public function GET_companies()
    {
      $redis = new DBRedis();

      $COMPANIES = $redis->get('kasko_companies_all');

      if (!$COMPANIES) {

          /* ПРОВЕРКА АВТОРИЗАЦИИ ПОЛЬЗОВАТЕЛЯ */
          $user_token = \handlers\Authorize::user_info();
          // Получаем список полей по токену
          $url = 'https://pkasko.com/calcservice/companies/all';

          $ch = curl_init($url);
          curl_setopt($ch, CURLOPT_HTTPHEADER, ['X-Authorization: '.E::Controller('api/v1','auth')->POST_signin()['api_key']]);
          curl_setopt($ch, CURLOPT_HEADER, 1);
          curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
          $result = curl_exec($ch);
          curl_close($ch);

          $pre_response = $result;
          $startpos = stripos($result, '[');
          $post_response = mb_substr($result, $startpos, strlen($result));
          $server_response = json_decode($post_response, true);

          // Если требуется авторизация, значит сбрасываем ключ редиса и повторяем запрос
          if (isset($server_response['error'])) {
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
                  $server_response = E::Controller('api/v1','assets')->GET_extended($iterator);
              }
          }

          $COMPANIES = $server_response;

          $redis->set('kasko_companies_all', json_encode($COMPANIES, JSON_UNESCAPED_UNICODE));

      } else {
          $COMPANIES = json_decode($COMPANIES, true);
      }

      return $COMPANIES;
    }

    public function GET_cars()
    {
      $redis = new DBRedis();

      $CARS = $redis->get('kasko_cars_all');

      if (!$CARS) {

          /* ПРОВЕРКА АВТОРИЗАЦИИ ПОЛЬЗОВАТЕЛЯ */
          $user_token = \handlers\Authorize::user_info();
          // Получаем список полей по токену
          $url = 'https://pkasko.com/calcservice/cars';

          $ch = curl_init($url);
          curl_setopt($ch, CURLOPT_HTTPHEADER, ['X-Authorization: '.E::Controller('api/v1','auth')->POST_signin()['api_key']]);
          curl_setopt($ch, CURLOPT_HEADER, 1);
          curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
          $result = curl_exec($ch);
          curl_close($ch);

          $pre_response = $result;
          $startpos = stripos($result, '[');
          $post_response = mb_substr($result, $startpos, strlen($result));
          $server_response = json_decode($post_response, true);
          // Если требуется авторизация, значит сбрасываем ключ редиса и повторяем запрос
          if (isset($server_response['error'])) {
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
                  $server_response = E::Controller('api/v1','assets')->GET_extended($iterator);
              }
          }

          $CARS = $server_response;

          $redis->set('kasko_cars_all', json_encode($CARS, JSON_UNESCAPED_UNICODE));

      } else {
          $CARS = json_decode($CARS, true);
      }

      return $CARS;
    }
    /**
     * Выборка базовых рассчетов пользователя
     * @param page
     */
    public function POST_base_counts(){
        /* ПРОВЕРКА АВТОРИЗАЦИИ ПОЛЬЗОВАТЕЛЯ */
        $user_token = \handlers\Authorize::user_info();

        if (!$_POST['count_field']) {
    			$_POST['count_field'] = 25;
    		}

        $Data = E::Model('base_counts')->get_all_user_id_limit([
            'user_id'=>$user_token['id'],
            'pagination'=>[
                'count_field'=>$_POST['count_field'],
                'active_page'=>$_POST['page'],
                'count_pagination_page'=>'5',
        ]]);
        return $Data;
    }
    /**
     * Выборка уточняющих рассчетов пользователя
     * @param page
     */
    public function POST_specify_counts(){
        /* ПРОВЕРКА АВТОРИЗАЦИИ ПОЛЬЗОВАТЕЛЯ */
        $user_token = \handlers\Authorize::user_info();

        if (!$_POST['count_field']) {
    			$_POST['count_field'] = 25;
    		}

        $Data = E::Model('specify_counts')->get_all_user_id_limit([
            'user_id'=>$user_token['id'],
            'pagination'=>[
                'count_field'=>$_POST['count_field'],
                'active_page'=>$_POST['page'],
                'count_pagination_page'=>'5',
        ]]);

        for ($i = 0; $i < count($Data['base']); $i++) {
    			if ($Data['base'][$i]['data'][0] == '{') {
    				$Data['base'][$i]['data'] = json_decode($Data['base'][$i]['data']);
    			}
    		}

        return $Data;
    }
    /**
     * Удаление списка дополнительных полей из кеша
     */
    public function GET_drop_extended(){
        $redis = new DBRedis();
        $redis->del('extended_fields');
        return [
            'type' => 'success'
        ];
    }

    /**
     * Отправка отчета о подсчете на почту
     */
    public function POST_report(){
        /* ПРОВЕРКА АВТОРИЗАЦИИ ПОЛЬЗОВАТЕЛЯ */
        $user_token = \handlers\Authorize::user_info();

        \validators\Email::report_email();

        // Генерируем тело E-mail
        $content = \handlers\Email::generate_body();

        // Генерация отчета PDF
        \handlers\Files::generate_report_PDF($_POST['companies_headers'],$_POST['companies_report'],$user_token['id']);

        $filename = GLOBAL_DIR.'/files/reports/pdf/'.$user_token['id'].'.pdf';

        // Отправка письма

        $date_send = date('d.m.Y');
        $Mail_result = SendMail_PL($_POST['email'], 'Предварительный расчет КАСКО на '.$date_send, 'Предварительный расчет КАСКО на '.$date_send, [[$filename,'Расчет КАСКО '.$date_send.'.pdf']]);
        // $Mail_result = SendMail_PL($_POST['email'], 'Предварительный расчет КАСКО на '.$date_send, '<strong>Предварительный расчет КАСКО на '.$date_send.'</strong>'.$content, [[$filename,'Расчет КАСКО '.$date_send.'.pdf']]);
        if ($Mail_result) {
          return [
              'type' => 'success'
          ];
        } else {
          throw new myException([
  					'message'=>'Письмо не было отправлено',
  					'code'=>400
  				]);
        }

    }

    /**
     * Генерация PDF отчета
     */
    public function POST_generate_report()
    {
        $user_token = \handlers\Authorize::user_info();
        // Валидация полей
        \validators\Email::report_pdf();

        // Генерация отчета PDF
        \handlers\Files::generate_report_PDF($_POST['companies_headers'],$_POST['companies_report'],$user_token['id']);

        $filename = GLOBAL_DIR.'/files/reports/pdf/'.$user_token['id'].'.pdf';

        \handlers\Files::file_force_download($filename,'report_pdf_'.$user_token['id'].'.pdf');
        return [
            'type' => 'success'
        ];
    }

    public function GET_test()
    {
      $Data = SendMail_PL('moiseyantonov@yandex.kz', 'Отчет по базару страховок', 'Вы сделали много важного');
      return $Data;
    }

}
?>
