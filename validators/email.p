<?php
namespace validators;

use engine\myException;

Class Email{
	/**
	 * Валидация отправки на E-mail
	 */
	public static function report_email()
	{
		\validators\Count::base_count();

		if (!isset($_POST['companies'])) {
			throw new myException([
				'message'=>'Расчет по компаниям не передан',
				'code'=>400
			]);
		}
		if (count($_POST['companies']) == 0) {
			throw new myException([
				'message'=>'Расчет по компаниям не передан',
				'code'=>400
			]);
		}

		if (!filter_var($_POST['email'],FILTER_VALIDATE_EMAIL)) {
			throw new myException([
				'message'=>'E-mail введен неверно',
				'code'=>400
			]);
		}

	}
	/**
	 * Валидация генерации PDF
	 */
	public static function report_pdf()
	{
		\validators\Count::base_count();

		if (!isset($_POST['companies_report'])) {
			throw new myException([
				'message'=>'Расчет по компаниям не передан',
				'code'=>400
			]);
		}

		if (count($_POST['companies_report']) == 0) {
			throw new myException([
				'message'=>'Расчет по компаниям не передан',
				'code'=>400
			]);
		}

		if (!isset($_POST['companies_headers'])) {
			throw new myException([
				'message'=>'Заголовки для генерации таблицы не переданы',
				'code'=>400
			]);
		}
	}
}
?>
