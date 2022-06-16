<?php
namespace handlers;

Class Request{
    public static function POST($url, $data, $headers = null)
    {
      $ch = curl_init($url);
      if ($headers) {
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
      }
      curl_setopt($ch, CURLOPT_TIMEOUT, 30);
      curl_setopt($ch, CURLOPT_POST, 1);
      curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));
      curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
      $result = curl_exec($ch);
      curl_close($ch);
      return json_decode($result, true);
    }
}
?>
