<?php
namespace handlers;

Class Email{
	/**
	 * Генерация тела сообщения
	 */
	public static function generate_body()
	{
		$content = '';
		foreach ($_POST as $key => $value) {
			switch ($key) {
				case 'make':
					$content.= '<p>Марка автомобиля: '.$value.'</p>';
					break;

				case 'model':
					$content.= '<p>Модель автомобиля: '.$value.'</p>';
					break;

				case 'year':
					$content.= '<p>Год выпуска автомобиля: '.$value.'</p>';
					break;

				case 'power':
					$content.= '<p>Количество ЛС автомобиля: '.$value.'</p>';
					break;

				case 'price':
					$content.= '<p>Стоимость автомобиля: '.$value.'</p>';
					break;

				case 'drivers':
					$content.= '<strong><p>Список водителей: </p></strong>';
					for ($i = 0; $i < count($value); $i++) {

						$marriage = 'Да';
						if (!$value[$i]['marriage']) {
							$marriage = 'Нет';
						}

						$sex = 'Ж';
						if ($value[$i]['sex'] == 'm') {
							$sex = 'М';
						}

						$content.= '<p>№ водителя: '.$value[$i]['iterator'].'</p>';
						$content.= '<p>Пол: '.$sex.'</p>';
						$content.= '<p>Возраст: '.$value[$i]['age'].'</p>';
						$content.= '<p>Стаж вождения: '.$value[$i]['experience'].'</p>';
						$content.= '<p>В браке: '.$marriage.'</p>';
					}
					break;

				case 'extended':
					if ($value == []) {
						break;
					}
					$content.= '<strong><p>Расширенные данные: </p></strong>';

					foreach ($value as $k => $v) {
						switch ($k) {
							case 'carNew':
								$content.= '<p>Новое ТС: '.$v.'</p>';
								break;

							case 'owner':
								$content.= '<p>Собственник: '.$v.'</p>';
								break;

							case 'explDate':
								$content.= '<p>Дата начала эксплуатации: '.$v.'</p>';
								break;

							case 'sto':
								$content.= '<p>Способ возмещения убытка: '.$v.'</p>';
								break;

							case 'guarantee':
								$content.= '<p>ТС на гарантии: '.$v.'</p>';
								break;

							case 'paymentOrder':
								$content.= '<p>Порядок оплаты: '.$v.'</p>';
								break;

							case 'multidrive':
								$content.= '<p>Мультидрайв: '.$v.'</p>';
								break;

							case 'compensationLimit':
								$content.= '<p>Тип страховой суммы: '.$v.'</p>';
								break;

							case 'credit':
								$content.= '<p>Кредитное ТС: '.$v.'</p>';
								break;

							case 'liability':
								$content.= '<p>Риск: '.$v.'</p>';
								break;

							case 'withoutCertificatesGlass':
								$content.= '<p>Выплата без справок (стеклянные элементы): '.$v.'</p>';
								break;

							case 'withoutCertificatesBody':
								$content.= '<p>Выплата без справок (кузов): '.$v.'</p>';
								break;

							case 'transitionFromCompany':
								$content.= '<p>Переход из другой компании: '.$v.'</p>';
								break;

							case 'gap':
								$content.= '<p>GAP: '.$v.'</p>';
								break;

							case 'franchise':
								$content.= '<p>Франшиза: '.$v.'</p>';
								break;

							case 'insurancePark':
								$content.= '<p>Парк ТС: '.$v.'</p>';
								break;

							case 'insuranceRegion':
								$content.= '<p>Территория страхования: '.$v.'</p>';
								break;

							case 'storage':
								$content.= '<p>Условия хранения: '.$v.'</p>';
								break;

							case 'rightWheel':
								$content.= '<p>Расположение руля: '.$v.'</p>';
								break;
						}
					}
					break;

				// case 'companies':
				//
				// 	$content.= '
				// 	<table border="0" cellpadding="0" cellspacing="0" height="100%" width="100%">
        //     <tr>
        //         <td align="center" valign="top">
				// 					Страховая компания
        //         </td>
				//
				// 				<td align="center" valign="top">
				// 					Ставка %
        //         </td>
				//
				// 				<td align="center" valign="top">
				// 					Премия руб.
        //         </td>
        //     </tr>
				// ';
				// 	for ($i = 0; $i < count($value); $i++) {
				// 		$content.= '
				// 		<tr>
				// 				<td align="center" valign="top">
				// 					'.$value[$i]['nameshort'].'
				// 				</td>
				//
				// 				<td align="center" valign="top">
				// 					'.$value[$i]['rate'].'
				// 				</td>
				//
				// 				<td align="center" valign="top">
				// 					'.$value[$i]['premium'].'
				// 				</td>
				// 		</tr>
				// 		';
				// 	}
				// 	$content.= '</table>';
				// 	break;
			}
		}

		return $content;
	}

}
?>
