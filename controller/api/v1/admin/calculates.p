<?php
namespace controller\api\v1\admin;

use engine\E;

Class calculatesController{
  /**
   * Выборка всех полисов
   */
  public function POST_list()
  {
    if (!$_POST['count_field']) {
      $_POST['count_field'] = 25;
    }

    $Policies = E::Model('specify_counts')->get_all_limits_pag([
        'pagination'=>[
          'count_field'=>$_POST['count_field'],
          'active_page'=>$_POST['page'],
          'count_pagination_page'=>'5',
    ]]);

    for ($i = 0; $i < count($Policies['base']); $i++) {
      $Policies['base'][$i]['data'] = json_decode($Policies['base'][$i]['data']);
      $Policies['base'][$i]['user_info'] = \handlers\Request::POST(
        E::$Config->API_GATEWAY.'v1/users/admin/agents/info',
        ['id' => $Policies['base'][$i]['user_id']],
        ['token:' . getallheaders()['TOKEN']]
      );

		}

    return $Policies;
  }
}
?>
