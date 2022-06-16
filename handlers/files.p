<?php
namespace handlers;

class Files
{
    /**
     * Скачивание файла
     */
    public static function file_force_download($file,$new_file_name = '') {
  		if (file_exists($file)) {
  			$base_name = basename($file);
  			if ($new_file_name != ''){
  				$base_name = $new_file_name;
  			}

  			// сбрасываем буфер вывода PHP, чтобы избежать переполнения памяти выделенной под скрипт
  			// если этого не сделать файл будет читаться в память полностью!
  			if (ob_get_level()) {
  				ob_end_clean();
  			}
  			// заставляем браузер показать окно сохранения файла
  			header('Content-Description: File Transfer');
  			header('Content-Type: application/octet-stream');
  			header('Content-Disposition: attachment; filename=' . $base_name);
  			header('Content-Transfer-Encoding: binary');
  			header('Expires: 0');
  			header('Cache-Control: must-revalidate');
  			header('Pragma: public');
  			header('Content-Length: ' . filesize($file));
  			// читаем файл и отправляем его пользователю
  			if ($fd = fopen($file, 'rb')) {
  				while (!feof($fd)) {
  				print fread($fd, 1024);
  			}
  				fclose($fd);
  			}
  			exit;
  		}
    }
    /**
     * Генерация отчета PDF
     * @param headers_input - Заголовки для таблицы
     * @param content_input - Содержимое для таблицы
     * @param filename_input - Название файла
     * @param nested_data - Содержимое от ввода данных в поля (марка авто, водители)
     */
    public static function generate_report_PDF($headers_input,$content_input,$filename_input,$nested_data = [])
    {
        $pdf = new \PDF('P','mm','A4');
        $headers = [];
        for ($i = 0; $i < count($headers_input); $i++) {
            $headers[] = iconv('UTF-8', 'ISO-8859-5', $headers_input[$i]);
        }
        $body = [];

        foreach ($content_input as $key => $value) {
            $company_data = [];
            for ($i = 0; $i < count($value);$i++) {
                $company_data[] = iconv('UTF-8', 'ISO-8859-5', $value[$i]);
            }
            $body[] = $company_data;
        }
        $pdf->AddFont('roboto','','robotob.php');

        $pdf->SetFont('roboto','B',20);

        $pdf->AddPage();

        $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Предварительный расчет КАСКО на '.date('d.m.Y')),0,1);
        $pdf->SetFillColor(0,0,0);
        $pdf->Image(GLOBAL_DIR.'/files/assets/logo.png',130,35);

        $pdf->SetFont('roboto','B',16);
        $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Данные о транспортном средстве: '),0,1);
        $pdf->SetFont('roboto','',12);
        /*Добавление данных для рассчета*/
        foreach ($_POST as $key => $value) {
    			switch ($key) {
    				case 'make':
              $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Марка автомобиля: '.$value),0,1);
    					break;

    				case 'model':
              $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Модель автомобиля: '.$value),0,1);
    					break;

    				case 'year':
              $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Год выпуска автомобиля: '.$value),0,1);
    					break;

    				case 'power':
              $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Мощность автомобиля, л.с.: '.$value),0,1);
    					break;

    				case 'price':
              $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Стоимость автомобиля: '.$value.' руб.'),0,1);
    					break;

    				case 'drivers':
              $pdf->SetFont('roboto','B',16);
              $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Список водителей: '),0,1);
              $pdf->SetFont('roboto','',12);
    					for ($i = 0; $i < count($value); $i++) {

    						$marriage = 'в браке';
    						if (!$value[$i]['marriage']) {
    							$marriage = 'не в браке';
    						}

    						$sex = 'Женщина';
    						if ($value[$i]['sex'] == 'm') {
    							$sex = 'Мужчина';
    						}
                $driver_info = $sex.', возраст (лет): '.$value[$i]['age'].', стаж вождения (лет): '.$value[$i]['experience'].', '.$marriage;
                $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', $driver_info),0,1);
                // $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', '№ водителя: '.$value[$i]['iterator']),1,1);
                // $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Пол: '.$sex),1,1);
                // $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Возраст: '.$value[$i]['age']),1,1);
                // $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Стаж вождения: '.$value[$i]['experience']),1,1);
                // $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'В браке: '.$marriage),1,1);
    					}
    					break;

    				// case 'extended':
    				// 	if ($value == []) {
    				// 		break;
    				// 	}
            //   $pdf->SetFont('roboto','B',16);
            //   $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Расширенные данные: '),0,1);
            //   $pdf->SetFont('roboto','',12);
    				// 	foreach ($value as $k => $v) {
    				// 		switch ($k) {
    				// 			case 'carNew':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Новое ТС: '.$v),0,1);
    				// 				break;
            //
    				// 			case 'owner':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Собственник: '.$v),0,1);
    				// 				break;
            //
    				// 			case 'explDate':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Дата начала эксплуатации: '.$v),0,1);
    				// 				break;
            //
    				// 			case 'sto':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Способ возмещения убытка: '.$v),0,1);
    				// 				break;
            //
    				// 			case 'guarantee':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'ТС на гарантии: '.$v),0,1);
    				// 				break;
            //
    				// 			case 'paymentOrder':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Порядок оплаты: '.$v),0,1);
    				// 				break;
            //
    				// 			case 'multidrive':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Мультидрайв: '.$v),0,1);
    				// 				break;
            //
    				// 			case 'compensationLimit':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Тип страховой суммы: '.$v),0,1);
    				// 				break;
            //
    				// 			case 'credit':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Кредитное ТС: '.$v),0,1);
    				// 				break;
            //
    				// 			case 'liability':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Риск: '.$v),0,1);
    				// 				break;
            //
    				// 			case 'withoutCertificatesGlass':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Выплата без справок (стеклянные элементы): '.$v),0,1);
    				// 				break;
            //
    				// 			case 'withoutCertificatesBody':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Выплата без справок (кузов): '.$v),0,1);
    				// 				break;
            //
    				// 			case 'transitionFromCompany':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Переход из другой компании: '.$v),0,1);
    				// 				break;
            //
    				// 			case 'gap':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'GAP: '.$v),0,1);
    				// 				break;
            //
    				// 			case 'franchise':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Франшиза: '.$v),0,1);
    				// 				break;
            //
    				// 			case 'insurancePark':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Парк ТС: '.$v),0,1);
    				// 				break;
            //
    				// 			case 'insuranceRegion':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Территория страхования: '.$v),0,1);
    				// 				break;
            //
    				// 			case 'storage':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Условия хранения: '.$v),0,1);
    				// 				break;
            //
    				// 			case 'rightWheel':
            //         $pdf->Cell(0,10,iconv('UTF-8', 'ISO-8859-5', 'Расположение руля: '.$v),0,1);
    				// 				break;
    				// 		}
    				// 	}
    				// 	break;
    			}
    		}

        /*Создание таблицы*/
        $pdf->FancyTable($headers,$body);

        $filename = GLOBAL_DIR.'/files/reports/pdf/'.$filename_input.'.pdf';
        $pdf->Output($filename,'F');
    }
}

?>
