//%attributes = {}
var $params : Object
$params:={base32_secret: "JDDK4U6G3BJLEZ7Y"; \
type: OTP Type totp; \
algorithm: OTP Algorithm SHA1; \
t0: 0; \
timestamp: 1773657357; \
Period: 30; \
digits: 6}

$status:=OTP Generate($params)
// $status.otp does NOT match Google Authenticator
//743565