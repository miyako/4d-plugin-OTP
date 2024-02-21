//%attributes = {}
/*
RAND_bytes() generates num random bytes 
using a cryptographically secure pseudo random generator (CSPRNG) 
*/

$random:=OTP Random()  //default length=20
$random:=OTP Random(100)