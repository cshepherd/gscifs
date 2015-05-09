*
* Linker File for SMBDEMO
*

	dsk smbdemo
	typ $b3
	xpl
	asm SMBDEMO.S
	ds 0
	knd #$1100
	ali None
	lna smbdemo.s16
	sna Main

