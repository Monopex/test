<?php
namespace handlers;

use engine\E;
use engine\myException;

Class Authorize{
	/**
	 * Модуль проверки авторизации пользователя
	 */
	public static function user_info(){
		if (!isset(getallheaders()['TOKEN'])) {
			throw new myException([
				'message'=>'Токен пользователя не является валидным',
				'code'=>403
			]);
		}
		$url = E::$Config->API_GATEWAY.'v1/users/account';

		$ch = curl_init($url);
		curl_setopt($ch, CURLOPT_HTTPHEADER, ['TOKEN: '.getallheaders()['TOKEN']]);
		curl_setopt($ch, CURLOPT_HEADER, 1);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
		$result = curl_exec($ch);
		curl_close($ch);

		$pre_response = $result;
		$startpos = stripos($result, '{');
		$post_response = mb_substr($result, $startpos, strlen($result));
		$server_response = json_decode($post_response, true);

		if (!isset($server_response['id'])) {
			throw new myException([
				'message'=>'Токен пользователя не является валидным',
				'code'=>403
			]);
		}

		return $server_response;
	}

}
?>
