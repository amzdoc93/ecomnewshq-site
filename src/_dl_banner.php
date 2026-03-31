<?php
if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['run'])) {
    $url = 'https://app.proxy-cheap.com/resources/banners/970x90.png';
    $opts = ['http' => ['header' => "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)\r\n"]];
    $data = @file_get_contents($url, false, stream_context_create($opts));
    if ($data && strlen($data) > 1000) {
        @mkdir(__DIR__ . '/banners', 0755, true);
        file_put_contents(__DIR__ . '/banners/proxy-cheap-970x90.png', $data);
        echo 'OK:' . strlen($data);
    } else {
        echo 'FAIL:' . strlen($data ?: '');
    }
    // Self-delete after use
    @unlink(__FILE__);
} else {
    http_response_code(404);
}
