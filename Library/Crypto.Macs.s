*
* Crypto Tool Set Macros
*  by Andrew Roughan
*
* 2002-04-05 AJR - Initial Coding
* 2002-07-03 AJR - desAddParity
* 2002-08-10 AJR - Tool number assigned
*

]cryptotoolnum = $81

_cryptoBootInit MAC
 Tool $0100+]cryptotoolnum
 <<<
~cryptoStartUp MAC
 PHW ]1
_cryptoStartUp MAC
 Tool $0200+]cryptotoolnum
 <<<
_cryptoShutDown MAC
 Tool $0300+]cryptotoolnum
 <<<
~cryptoVersion MAC
 PHA
_cryptoVersion MAC
 Tool $0400+]cryptotoolnum
 <<<
_cryptoReset MAC
 Tool $0500+]cryptotoolnum
 <<<
~cryptoStatus MAC
 PHA
_cryptoStatus MAC
 Tool $0600+]cryptotoolnum
 <<<
~desCipher MAC
 PxL ]1,]2,]3
 PHW ]4
_desCipher MAC
 Tool $0900+]cryptotoolnum
 <<<
~desAddParity MAC
 PxL ]1,]2
_desAddParity MAC
 Tool $0A00+]cryptotoolnum
 <<<
