//%attributes = {}
var $params : Object

$params:={secret: "😣."}

$status:=OTP Generate($params)

ASSERT:C1129($status.base32_secret="6CPZRIZO")