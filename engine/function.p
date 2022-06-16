<?php
/*
	@function - функциии которые нужны везде и используються повсюду.
	@p - функция которая проверяет привилегии пользователя.
	@t - функция которая переводит тест.
*/
	// Если Absolute не равен нулю то все переданные в массиве привилегии доложны быть у пользователя. Допустим Администратор и режим редактирования.

	function p($Privilegi, $Absolute=null){ // Проверяем привилегии.
	//	return true;//ВРЕМЕНО
		$Error = 1;
		if (is_array($Privilegi)){ // Если передали массив привилегий.
			if ($Absolute == null){ // Если доложна существовать одна из посланных привилегий.
				for ($i=0; $i<count($Privilegi); $i++){
					if (in_array($Privilegi[$i], $_SESSION['powers'])){ // Если совпала хоть одна привилегия. // E::$Privileges
						$Error = 0;
					}
				}
			}
			else{
				$CountSov = 0; // Количество совпадений.
				for ($i=0; $i<count($Privilegi); $i++){
					if (in_array($Privilegi[$i], $_SESSION['powers'])){ // Если совпала хоть одна привилегия.
						$CountSov++;
					}
				}
				if ($CountSov == count($Privilegi)){ // Если совпали все переданные данные то ошибки нет.
					$Error = 0;
				}
			}
		}
		else{ // Если передали одно значение
			if (in_array($Privilegi, $_SESSION['powers'])){ // Если совпала хоть одна привилегия.
				$Error = 0;
			}
		}
		if ($Error == 0){ // если все условия выполнены
			return true;
		}
		else{
			return false;
		}
	}

	function pretty_print($in,$opened = true){
		if($opened)
			$opened = ' open';
		if(is_object($in) or is_array($in)){
			echo '<div>';
				echo '<details'.$opened.'>';
					echo '<summary>';
						echo (is_object($in)) ? 'Object {'.count((array)$in).'}':'Array ['.count($in).']';
					echo '</summary>';
					pretty_print_rec($in, $opened);
				echo '</details>';
			echo '</div>';
		}
	}

	function pretty_print_rec($in, $opened, $margin = 10){
		if(!is_object($in) && !is_array($in))
			return;

		foreach($in as $key => $value){
			if(is_object($value) or is_array($value)){
				echo '<details style="margin-left:'.$margin.'px" '.$opened.'>';
					echo '<summary>';
						echo (is_object($value)) ? $key.' {'.count((array)$value).'}':$key.' ['.count($value).']';
					echo '</summary>';
					pretty_print_rec($value, $opened, $margin+10);
				echo '</details>';
			}
			else{
				switch(gettype($value)){
					case 'string':
						$bgc = 'red';
					break;
					case 'integer':
						$bgc = 'green';
					break;
				}
				echo '<div style="margin-left:'.$margin.'px">'.$key . ' : <span style="color:'.$bgc.'">' . $value .'</span> ('.gettype($value).')</div>';
			}
		}
	}

	//Json Web-token
	function base64url_encode($data) {
		return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
	}

	function encode_JWT($payload, $key){ // $payload ассоциативный массив с любыми данными
		$headers = ['alg'=>'HS256','typ'=>'JWT'];
		$headers_encoded = base64url_encode(json_encode($headers));
		$payload_encoded = base64url_encode(json_encode($payload));

		//$key = 'secret';
		$signature = hash_hmac('SHA256',$headers_encoded.'.'.$payload_encoded,$key,true);
		$signature_encoded = base64url_encode($signature);
		$token = $headers_encoded.'.'.$payload_encoded.'.'.$signature_encoded;
		return $token;
	}

	function decode_JWT($token, $key){
		$headers = ['alg'=>'HS256','typ'=>'JWT'];
		$headers_encoded = base64url_encode(json_encode($headers));
		//$key = 'secret';
		//var_dump($token);
		$data = explode('.',$token);
		if ($headers_encoded != $data[0]){
			return false;
		}

		$signature = hash_hmac('SHA256',$headers_encoded.'.'.$data[1],$key,true);
		$signature_encoded = base64url_encode($signature);

		if ($signature_encoded == $data[2]){
			return json_decode(base64_decode($data[1]),true);
		}

		return false;
	}

	function SendMail_PL($to, $title, $content, $files = []){

		$mail = new PHPMailer(true);

		try {

		  	$from = 'noreply@bazarstrahovok.ru';

		    // $mail->SMTPDebug = 2; // режим отладки, уберите эту сточку после отладки
		    $mail->isSMTP();
				$mail->CharSet = 'UTF-8';
		    $mail->Host = 'smtp.yandex.com';
		    $mail->SMTPAuth = true;
		    $mail->Username = $from; // имя пользователя yandex
		    $mail->Password = 'baza7521@&L'; // пароль на yandex
		    $mail->SMTPSecure = 'ssl';
		    $mail->Port = 465;

		    $mail->setFrom($from, 'Базар Страховок');

		    $mail->addAddress($to, 'Получатель');

				for ($i = 0; $i < count($files); $i++) {
					$mail->AddAttachment($files[$i][0], $files[$i][1]);
				}


		    $mail->Subject = $title;
		    $mail->Body    = $content;

		    $mail->send();

		    return true;

		} catch (Exception $e) {
		    return false;
		}

		// require_once 'engine/class.smtp_pl.p';
		// $mailSMTP = new SendMailSmtpClass('bazar.strahovok@yandex.kz', '12345Qwerty', 'smtp.yandex.ru', 587, "UTF-8");
		// от кого
		// $from = array(
		// 	"Базар страховок", // Имя отправителя
		// 	"bazar.strahovok@yandex.kz" // почта отправителя
		// );
		//
		// if(!empty($files)) { // загрузка файлов если есть (закрепление в сообщении на почту)
		// 	foreach ($files as $file) {
		// 		if (file_exists($file)) {
		// 			$mailSMTP->addFile($file);
		// 		}
		// 	}
		// }
		// $result =  $mailSMTP->send($to, $title, $content, $from);

	}

	function VALIDATE_STRING($data) {
		if (
			empty($data)
			|| $data == ''
			|| str_replace(' ', '', $data) == ''
			|| !$data
		) {
			return false;
		}
		return true;
	}

	function VALIDATE_ARRAY($data) {
		if (
			!is_array($data)
		) {
			return false;
		}
		return true;
	}

	function VALIDATE_DIGIT($digit){
		return is_numeric($digit);
	}

?>
