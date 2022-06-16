<?php
namespace validators;

use engine\myException;

Class Count{
	/**
	 * Валидация базового расчета
	 */
	public static function base_count()
	{
		/* ВАЛИДАЦИЯ ДАННЫХ */
		if (!VALIDATE_STRING($_POST['make'])) {
				throw new myException([
					'message'=>'Производитель автомобиля должен быть заполнен',
					'code'=>400
				]);
		}

		if (!VALIDATE_STRING($_POST['model'])) {
				throw new myException([
					'message'=>'Модель автомобиля должна быть заполнена',
					'code'=>400
				]);
		}

		if (!VALIDATE_STRING($_POST['year'])) {
				throw new myException([
					'message'=>'Год выпуска автомобиля должен быть заполнен',
					'code'=>400
				]);
		}

		if (!VALIDATE_DIGIT($_POST['year'])) {
				throw new myException([
					'message'=>'Год выпуска автомобиля заполнен не правильно',
					'code'=>400
				]);
		}

		if ((int)$_POST['year'] < 1900 || (int)$_POST['year'] > date('Y')) {
			throw new myException([
				'message'=>'Год выпуска автомобиля должен быть от 1900 до '.date('Y').' включительно',
				'code'=>400
			]);
		}

		if (!VALIDATE_STRING($_POST['power'])) {
				throw new myException([
					'message'=>'Количество ЛС автомобиля должно быть заполнено',
					'code'=>400
				]);
		}

		if (!VALIDATE_DIGIT($_POST['power'])) {
				throw new myException([
					'message'=>'Количество ЛС автомобиля заполнено не правильно',
					'code'=>400
				]);
		}

		if (!VALIDATE_STRING($_POST['price'])) {
				throw new myException([
					'message'=>'Стоимость автомобиля должна быть заполнена',
					'code'=>400
				]);
		}

		if (!VALIDATE_DIGIT($_POST['price'])) {
				throw new myException([
					'message'=>'Стоимость автомобиля заполнена не правильно',
					'code'=>400
				]);
		}

		if (!VALIDATE_ARRAY($_POST['drivers'])) {
				throw new myException([
					'message'=>'Водители переданы неверно',
					'code'=>400
				]);
		}

		if(count($_POST['drivers']) == 0) {
				throw new myException([
					'message'=>'Водители переданы неверно',
					'code'=>400
				]);
		}
		if ($_POST['extended']['multidrive'] != 'Без ограничений') {
			for ($i = 0; $i < count($_POST['drivers']); $i++) {
				if (!VALIDATE_STRING($_POST['drivers'][$i]['sex'])) {
						throw new myException([
							'message'=>'Пол водителя №'.($i + 1).' заполнен неверно',
							'code'=>400
						]);
				}

				if (!VALIDATE_STRING($_POST['drivers'][$i]['age'])) {
						throw new myException([
							'message'=>'Возраст водителя №'.($i + 1).' указан неверно',
							'code'=>400
						]);
				}

				if (!VALIDATE_DIGIT($_POST['drivers'][$i]['age'])) {
						throw new myException([
							'message'=>'Возраст водителя №'.($i + 1).' указан неверно',
							'code'=>400
						]);
				}

				if (!VALIDATE_STRING($_POST['drivers'][$i]['experience'])) {
						throw new myException([
							'message'=>'Опыт вождения водителя №'.($i + 1).' указан неверно',
							'code'=>400
						]);
				}

				if (!VALIDATE_DIGIT($_POST['drivers'][$i]['experience'])) {
						throw new myException([
							'message'=>'Опыт вождения водителя №'.($i + 1).' указан неверно',
							'code'=>400
						]);
				}

				if (!isset($_POST['drivers'][$i]['marriage'])) {
						throw new myException([
							'message'=>'Состояние брака водителя №'.($i + 1).' не указано',
							'code'=>400
						]);
				}

				if ((int)$_POST['drivers'][$i]['age'] < 18) {
						throw new myException([
							'message'=>'Возраст водителя №'.($i + 1).' указан неверно',
							'code'=>400
						]);
				}

				if ((int)$_POST['drivers'][$i]['age'] - (int)$_POST['drivers'][$i]['experience'] < 18) {
						throw new myException([
							'message'=>'Опыт вождения водителя №'.($i + 1).' указан неверно',
							'code'=>400
						]);
				}

			}
		}


		if (!VALIDATE_ARRAY($_POST['extended'])) {
				$_POST['extended'] = [];
		}
	}
	/**
	 * Валидация уточняющего расчета
	 */
	public static function specify_count()
	{
		if (!VALIDATE_STRING($_POST['companyCode'])) {
				throw new myException([
					'message'=>'Код компании указан неверно',
					'code'=>400
				]);
		}

		if (!VALIDATE_STRING($_POST['companyShortName'])) {
				throw new myException([
					'message'=>'Русский алиас компании указан неверно',
					'code'=>400
				]);
		}
		if (!VALIDATE_ARRAY($_POST['data'])) {
				throw new myException([
					'message'=>'Данные для страховой переданы неверно',
					'code'=>400
				]);
		}
	}
}
?>
