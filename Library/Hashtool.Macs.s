* HashTool Macros
*  by Andrew Roughan
*
* 5/3/2002
* 1/8/2002 - Added md4 calls

_hashBootInit MAC
 Tool $0180
 <<<
_hashStartUp MAC
 Tool $0280
 <<<
_hashShutDown MAC
 Tool $0380
 <<<
~hashVersion MAC
 PHA
_hashVersion MAC
 Tool $0480
 <<<
_hashReset MAC
 Tool $0580
 <<<
~hashStatus MAC
 PHA
_hashStatus MAC
 Tool $0680
 <<<
~md5init MAC
 PHL ]1
_md5init MAC
 Tool $0980
 <<<
~md5append MAC
 PxL ]1;]2;]3
_md5append MAC
 Tool $0A80
 <<<
~md5finish MAC
 PxL ]1;]2
_md5finish MAC
 Tool $0B80
 <<<
~md4init MAC
 PHL ]1
_md4init MAC
 Tool $0C80
 <<<
~md4append MAC
 PxL ]1;]2;]3
_md4append MAC
 Tool $0D80
 <<<
~md4finish MAC
 PxL ]1;]2
_md4finish MAC
 Tool $0E80
 <<<

mdDigestLen EQU 16
 DUM 0
mdWorkBlk
msglength DS 8
digest DS mdDigestLen
accumulate DS 64
mdWorkBlkLen EQU *-mdWorkBlk
 DEND
