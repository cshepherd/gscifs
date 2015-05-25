*
* Marinetti / SMB1 Test (THIS IS NOT SMB2), Mark II
*
* CHANGELOG
* Thursday, April 30, 2015 - Restarted effort, ported code from ORCA/M to Merlin32 and debugged Merlin32 environment
* Friday, May 1, 2015      - Ported more code to Merlin32, set up Merlin32 equates
* Saturday, May 2, 2015    - Formatting fixes, refactoring, rewritten SMB Negotiation code
* Saturday, May 9, 2015    - Receive and interpret NEG_PROT reply and start login
* Sunday, May 24, 2015     - Some bugfixes, Tool128 and Tool129 requirement for hashing and DES, LM password hashing support
*                            Also introducing successful SMB_Tree_ANDX message. We connect to remote shares now.
*                            Also introducing SMB_Open_ANDX message. We open a file now.
*
* REFERENCES
* smb.c / smb.h from libOGC
* http://www.ubiqx.org/cifs/SMB.html
*

				rel
				dsk smbdemo.l

* Macros (mostly from Merlin32 dist)
				use GsOs.Macs
				use Util.Macs
				use Misc.Macs
				use Locator.Macs
				use Mem.Macs
				use Qd.Macs
				use QdAux.Macs
				use Event.Macs
				use Window.Macs
				use Ctl.Macs
				use Menu.Macs
				use Desk.Macs
				use Sound.Macs
				use Line.Macs
				use Dialog.Macs
				use TCPIP.Macs		; from MOSP CVS

* Equates (ripped off from Merlin 16)		
				use E16.Dialog.Macs
				use E16.GsOs.Macs
* Equates (from MOSP/Tools/Orca.M/e16.tcpip)
				use E16.TCPIP.Macs

*-----------------------------------------------------------------------------
* DP variables and local equates
*-----------------------------------------------------------------------------

* DUM $000000 is broken on merlin32, if you want LDA (DP) $A5 opcode, write one-byte equates instead
* cause merlin32 will always give you $AD (LDAL)
*		dum 0
*AppMMID
*		ds 2,0				; Memory Manager ID
*HndlRef
*		ds 2,0				; For Dereferencing MM Handle
*DPBase
*		ds 1,0				; Deref'd handle
*		dend

* workaround: do this instead for DP variables
AppMMID			= $0
HndlRef			= $2
DPBase			= $4

*-----------------------------------------------------------------------------
* GS/OS Program Entry Point
*-----------------------------------------------------------------------------

Entry			mx %00
				phk
				plb
				brl Main

*
* Check for toolbox errors
* too-simple error handler
*
CheckError		bcs SysDeath
				rts

SysDeath		pha
				PushLong #0000
				_SysFailMgr

*
* StartUpTools - start up the various toolsets
*
StartUpTools 	_TLStartUp
				pha
				_MMStartUp
				jsr CheckError
				PullWord AppMMID
				_MTStartUp

				pha
				pha
				PushLong #$900		; 9 pages of DP space
				PushWord AppMMID
				PushWord #$C005		; Fixed, Page-Aligned, Locked, Unpurgeable
				PushLong #$000000	; in Bank $00, $0000
				_NewHandle
				jsr CheckError
				PullLong HndlRef
				lda [HndlRef]
				sta DPBase

				pha					; save dp pointer for later
				pha
				PushWord #$0080		; Screen Mode ($0000 = 320, $0080 = 640)
				PushWord #$00A0		; Pixel Map Size ($0050 = 320, $00A0 = 640)
				PushWord AppMMID
				_QDStartUp
				jsr CheckError

				pla					; saved dp pointer
				clc
				adc #$300
				pha					; save dp pointer for later
				pha
				PushWord #20		; Event Queue size
				PushWord #0			; Min X clamp
				PushWord #640		; Max X clamp
				PushWord #0			; Min Y clamp
				PushWord #200		; Max Y clamp
				PushWord AppMMID
				_EMStartUp
				jsr CheckError

				PushWord #0
				_SetBackColor

				PushWord #3
				_SetForeColor

				PushWord #50		; X position
				PushWord #85		; Y position
				_MoveTo

				PushLong #OneMoment
				_DrawCString

				PushLong #ToolList
				_LoadTools
				jsr CheckError

				PushWord AppMMID
				_WindStartUp
				jsr CheckError

				pla					; saved dp pointer
				clc
				adc #$100
				pha					; save it for later
				tax					; save dp pointer in x
				PushWord AppMMID
				phx
				_CtlStartUp
				jsr CheckError

				pla
				clc
				adc #$100
				pha
				tax
				PushWord AppMMID
				phx
				_LEStartUp
				jsr CheckError
		
				PushWord AppMMID
				_DialogStartUp
				jsr CheckError

				pla
				clc
				adc #$100
				pha
				tax
				PushWord AppMMID
				phx
				_MenuStartUp
				jsr CheckError

				_DeskStartUp
				jsr CheckError
		
				pla
				clc
				adc #$100
				pha
				pha
				_SoundStartUp
				jsr CheckError

				_TCPIPStartUp
				jsr CheckError
				
				Tool $280			; HashStartUp
				jsr CheckError
				
				pla
				clc
				adc #$100
				pha
				Tool $281			; CryptoStartUp

				rts

*
* ShutDownTools - shut em back down
*
ShutDownTools	lda ToolList
				asl
				asl
				tax
				lda ToolList-2,x
				cmp #$2				; Memory Manager?
				bne ShutDownOne		; Nope, do it normally
				PushWord AppMMID
				_DisposeAll
				PushWord AppMMID
				lda #$2				; set up for toolset #2 (MM)
ShutDownOne		ora #$300			; Call #3 (Shutdown)
				tax
				jsl $E10000
				dec ToolList
				bne ShutDownTools
				rts

*
* Main - main sequence of events
*
Main			jsr StartUpTools
				jsr PrepDeskTop
				sep $20
				ldal $e0c034
				sta ScreenColorByte
				lda #00
				stal $e0c034
				rep $30

* pretty corner rounding
				PushWord #0000
				_SetForeColor
* upper left
				PushWord #0001
				PushWord #0000
				_MoveTo
				PushWord #0001
				PushWord #0002
				_LineTo
				PushWord #0002
				PushWord #0000
				_MoveTo
				PushWord #0002
				PushWord #0001
				_LineTo
				PushWord #0003
				PushWord #0000
				_MoveTo
				PushWord #0003
				PushWord #0000
				_LineTo
* upper right
				PushWord #0638
				PushWord #0000
				_MoveTo
				PushWord #0638
				PushWord #0002
				_LineTo
				PushWord #0637
				PushWord #0000
				_MoveTo
				PushWord #0637
				PushWord #0001
				_LineTo
* lower left
				PushWord #0000
				PushWord #0195
				_MoveTo
				PushWord #0000
				PushWord #0199
				_LineTo
				PushWord #0001
				PushWord #0197
				_MoveTo
				PushWord #0001
				PushWord #0199
				_LineTo
				PushWord #0002
				PushWord #0199
				_MoveTo
				PushWord #0002
				PushWord #0199
				_LineTo
* lower right
				PushWord #0639
				PushWord #0195
				_MoveTo
				PushWord #0639
				PushWord #0199
				_LineTo
				PushWord #0638
				PushWord #0197
				_MoveTo
				PushWord #0638
				PushWord #0199
				_LineTo
				PushWord #0637
				PushWord #0199
				_MoveTo
				PushWord #0637
				PushWord #0199
				_LineTo

EventLoop		pha					; Result Space
				PushWord #$ffff		; Event Mask
				PushLong #EventRec
				_TaskMaster
				pla
				beq EventLoop

				cmp #$11			; wInMenuBar?
				bne EventLoop		; no, so ignore

				jsr MenuDispatch
				bit QuitFlag
				bpl EventLoop

				sep $20
				lda ScreenColorByte
				stal $e0c034
				rep $30

				jsr ShutDownTools
				iGSOS _Quit;QParams;1

*
* Prepare Desktop
*
PrepDeskTop		PushLong #0000
				_RefreshDesktop
				_InitCursor

NextMenu		pha
				pha
				lda MenuTbl
				asl
				tax
				lda MenuTbl,x
				phb
				phb
				pha
				_NewMenu
				PushWord #0000
				_InsertMenu

				dec MenuTbl
				bne NextMenu

				PushWord #1
				_FixAppleMenu

				pha
				_FixMenuBar
				pla

				_DrawMenuBar
				rts

*
* Apple Menu: About
*
About			PushLong #AboutString
				jsr InfoDialog
				rts

*
* File Menu: Quit
*
Quit			dec QuitFlag
				rts

*
* TCP/IP Test
*
TCPIPTest		pha
				PushWord #0000
				_TCPIPGetConnectStatus
				pla
				cmp #$0000
				bne tgood
				PushLong #MarinettiBad
				jsr InfoDialog
				bra tret
tgood			PushLong #MarinettiGood
				jsr InfoDialog
tret			pla
				rts

*
* Connect To Server
*
ConnectToSvr	PushLong #$00000000		; space for result
				PushLong #CTSRect
				_GetNewModalDialog
				PullLong CTSWinPtr

				PushLong CTSWinPtr
				_BeginUpdate

				PushLong CTSWinPtr
				_DrawDialog

				PushLong CTSWinPtr
				_EndUpdate

				PushLong #00000000
				_TCPIPConnect			; make sure marinetti is connected

				PushLong #00000000
				_TCPIPGetMyIPAddress
				plx
				ply
				PushWord #0000
				phy
				phx
				PushLong #ascaddr
				PushWord #0000
				_TCPIPConvertIPToASCII	; convert our address to ASCII
				pla
				PushLong CTSWinPtr
				PushWord #1360
				PushLong #ascaddr
				_SetIText				; show it

CTSLoop1		PushWord #0000			; space for result
				PushLong #00000000		; nil filter
				_ModalDialog
				pla						; get item hit
				cmp #2					; Cancel?
				beq CTSClose
				cmp #1					; Connect?
				bne CTSLoop1
				bra CTSConnect
CTSClose		PushLong CTSWinPtr
				_CloseDialog
				rts
CTSConnect		PushLong #00000000
				PushLong CTSWinPtr
				PushWord #0001
				_GetControlDItem
				plx
				ply
				PushWord #255
				phy
				phx
				_HiliteControl			; dim/disable 'Connect' button
		
				PushLong #00000000
				PushLong CTSWinPtr
				PushWord #1349
				_GetControlDItem
				plx
				ply
				PushWord #255
				phy
				phx
				_HiliteControl			; dim/disable 'Address' text input

				PushLong CTSWinPtr
				PushWord #1349
				PushLong #fqdnptr
				_GetIText
		
				PushWord CTSText4		; preserve old length byte (word)
		
				sep #$30
				mx %11
				lda fqdnptr
				tax
				clc
				adc CTSText4
				sta CTSText4
hostcopy		lda fqdnptr,x
				sta inhost-1,x
				dex
				bne hostcopy
				rep #$30
				mx %00
		
				PushLong CTSWinPtr
				PushWord #1350
				PushLong #CTSText4
				_SetIText				; show 'resolving' status string

				pla
				sta CTSText4
		
				PushWord #0000
				PushWord #$F800
				PushLong #fqdnptr
				_TCPIPMangleDomainName	; mangle entered domain name
				pla						; port number; trash

				PushWord #0000
				PushLong #fqdnptr
				_TCPIPValidateIPString
				pla
				beq resolve				; engage DNS if this wasn't an ip address
				PushLong #ipaddrip
				PushLong #fqdnptr
				_TCPIPConvertIPToHex	; else just convert to long
				bra Connect				; and on with the show

resolve			PushLong #fqdnptr
				PushLong #ipaddr
				_TCPIPDNRNameToIP		; resolve fqdn
ResolvLoop		PushWord #0000			; check for mouse events (cancel)
				PushWord #$0006			; with _EventAvail
				PushLong #EventRec		; because _ModalDialog will block
				_EventAvail
				pla
				beq noevent
				PushWord #0000
				PushLong #00000000
				_ModalDialog
				pla
				cmp #2
				beq CTSClose2
noevent			_TCPIPPoll
				lda ipaddr
				cmp #$0001
				beq Connect				; continue to Connect if resolved okay
				cmp #$0000
				beq ResolvLoop			; pending; stay in 'Resolving' loop
				bra CTSBadDNS
CTSClose2		PushLong CTSWinPtr
				_CloseDialog
				rts
CTSBadDNS		PushLong CTSWinPtr
				PushWord #1350
				PushLong #CTSText5
				_SetIText
				bra CTSClose2

Connect			PushWord #0000
				PushLong ipaddrip
				PushLong #destaddr
				PushWord #0000
				_TCPIPConvertIPToASCII
				pla

				PushWord CTSText6		; preserve old length byte (word)

				sep #$30
				mx %11
				lda destaddr
				tax
				clc
				adc CTSText6
				sta CTSText6
ipcopy			lda destaddr,x
				sta ascdest-1,x
				dex
				bne ipcopy
				rep #$30
				mx %00

				PushLong CTSWinPtr
				PushWord #1350
				PushLong #CTSText6
				_SetIText				; change status to 'Connecting'

				pla
				sta CTSText6			; restore length byte

				PushWord #0000			; space for result
				PushWord AppMMID		; our Memory Manager handle
				PushLong ipaddrip		; ipaddress to connect to
				PushWord #0445			; try port 445 first
				PushWord #0000			; default TOS: 0000
				PushWord #$0040			; default TTL: 64
				_TCPIPLogin
				pla
				sta MyIPID

				PushWord #$0000
				PushWord MyIPID
				_TCPIPOpenTCP
				pla
				beq ConnectLoop

				jmp CTSClose3

ConnectLoop		PushWord #0000
				PushWord #$0006
				PushLong #EventRec
				_EventAvail
				pla
				beq noevent2
				PushWord #0000			; space for result
				PushLong #00000000		; nil filter procedure
				_ModalDialog
				pla
				cmp #2
				bne noevent2
				jmp CTSClose3
noevent2		_TCPIPPoll
				PushWord #0000
				PushWord MyIPID
				PushLong #statbuf
				_TCPIPStatusTCP
				pla
				beq notbroke
				jmp CTSClose3			; something broke
notbroke		lda statbuf
				cmp #$0004
				beq estab
				cmp #$0000
				beq closed_trampoline
				bra ConnectLoop

;
; SMB_Negot_Prot
;

estab			PushLong CTSWinPtr
				PushWord #1350
				PushLong #CTSText9
				_SetIText

				PushLong MyIPID
				jsr SMB_Init			; feed our Marinetti IPID into SMB system
				PullLong MySMBHandle		; get back our SMB handle

				PushLong MySMBHandle		; SMB_Negotiate wants our SMB handle
				jsr SMB_Negotiate		; and hopefully we send a SMB Negotiate Protocol Request and get a response

				bra ct_far
closed_trampoline	jmp closed
ct_far

sendloop2		PushWord #0000
				PushWord #$0006
				PushLong #EventRec
				_EventAvail
				pla
				beq noevent3
				PushWord #0000
				PushLong #00000000
				_ModalDialog
				pla
				cmp #2
				bne noevent3
				jmp CTSClose3

noevent3		PushLong MySMBHandle
				jsr SMB_Negotiate_Poll
				pla						; get negotiation status
				bcc sendloop2

;
; SMB_Setup_ANDX
;

login			PushLong CTSWinPtr
				PushWord #1350
				PushLong #CTSTextB
				_SetIText

				PushLong MySMBHandle
				jsr SMB_SetupAndX

sendloop3		PushWord #0000
				PushWord #$0006
				PushLong #EventRec
				_EventAvail
				pla
				beq noevent4
				PushWord #0000
				PushLong #00000000
				_ModalDialog
				pla
				cmp #2
				bne noevent4
				jmp CTSClose3

noevent4		PushLong MySMBHandle
				jsr SMB_Setup_Poll
				pla						; get negotiation status
				bcc sendloop3
				
;
; SMB_Tree_ANDX
;

; fun fact: change 'treex' to 'tree' to coredump Merlin32 v1.0
; inside a65816_Line.c function CheckForDuplicatedLabel()
treex			PushLong CTSWinPtr
				PushWord #1350
				PushLong #CTSTextC
				_SetIText
				
				PushLong MySMBHandle
				jsr SMB_TreeAndX

sendloop4		PushWord #0000
				PushWord #$0006
				PushLong #EventRec
				_EventAvail
				pla
				beq noevent5
				PushWord #0000
				PushLong #00000000
				_ModalDialog
				pla
				cmp #2
				bne noevent5
				jmp CTSClose3

noevent5		PushLong MySMBHandle
				jsr SMB_TreeX_Poll
				pla
				bcc sendloop4

;
; SMB_OpenFile
;

openf			PushLong CTSWinPtr
				PushWord #1350
				PushLong #CTSTextC
				_SetIText
				
				PushLong MySMBHandle
				PushLong #SMB_target_file
				jsr SMB_OpenFile

sendloop5		PushWord #0000
				PushWord #$0006
				PushLong #EventRec
				_EventAvail
				pla
				beq noevent6
				PushWord #0000
				PushLong #00000000
				_ModalDialog
				pla
				cmp #2
				bne noevent6
				jmp breakndie

noevent6		PushLong MySMBHandle
				jsr SMB_OpenFile_Poll
				bcc sendloop5

breakndie			
				jmp SMB_staging_brk

;
; Closed
;

closed			PushLong CTSWinPtr
				PushWord #1350
				PushLong #CTSTextA
				_SetIText

;
; Kill dialog window and TCPIP connection
;

CTSClose3		PushWord #MyIPID
				_TCPIPLogout			; get rid of our IPID
				PushLong CTSWinPtr		; and close the dialog window
				_CloseDialog
				rts

*
* Menu Dispatcher
*
MenuDispatch	lda TaskData
				and #$00ff
				asl
				tax
				jsr (MenuDispatchTbl,x)

				PushWord #0000
				PushWord TaskData+2
				_HiliteMenu
				rts

*
* Information Dialog
*
InfoDialog		plx					; preserve return address
				PullLong dialogMsg
				phx					; put return back on stack
				pha					; room for result
				PushLong #OurAlert	; pointer to dialog
				PushLong #$0000
				_NoteAlert
				pla					; get the item selected
				rts

*
* Non-DP Variables
*
QuitFlag		dw 00,00
ScreenColorByte	dw 00
MyIPID			dw 00				; Marinetti IPID
MySMBHandle		dw 00,00			; SMB driver handle
CTSWinPtr		dw 00,00			; Connect To Server grafport ptr
fqdnptr			ds 101				; 101 bytes for user-entered hostname
ipaddr			dw 00				; DNS resolution status
ipaddrip		dw 00,00			; Resolved IP address
ascaddr			ds 16				; My IP address, in ASCII
destaddr		ds 16				; Destination IP address, in ASCII
statbuf			ds 2				; TCP state, statbuf+0
				ds 2				; ICMP error code, statbuf+2
				ds 4				; sendq size, statbuf+4
				ds 4				; recvq size, statbuf+8
				ds 4				; dest ip
				ds 2				; dest port
				ds 2				; connection type
				ds 2				; accept count
readbuf			ds 4				; rrBuffCount
				ds 4				; rrBuffHandle
				ds 2				; rrMoreFlag
				ds 2				; rrPushFlag
				ds 2				; rrUrgentFlag

*
* Tool List
*
ToolList     	dw 15				; Tool Count
				dw 01,00			; Tool Locator, any vers
				dw 02,00			; Memory Manager, any vers
				dw 03,00			; Misc Tools, any vers
				dw 04,00			; QuickDraw II, any vers
				dw 06,00			; Event Manager, any vers
				dw 14,00			; Window Manager, any vers
				dw 16,00			; Control Manager, any vers
				dw 15,00			; Menu Manager, any vers
				dw 05,00			; Desk Manager, any vers
				dw 08,00			; Sound Manager, any vers
				dw 20,00			; Line Edit, any vers
				dw 21,00			; Dialog Manager, any vers
				dw 54,00			; Marinetti, any vers
				dw 128,00			; HashTool, any vers (MD2/MD4/MD5/SHA1 hashing for NTLMv2)
				dw 129,00			; Crypto tool, any vers (DES for NTLMv1)
ToolListEnd

*
* Menu Structures
*

MenuDispatchTbl	dw About
				dw Quit
				dw TCPIPTest
				dw ConnectToSvr

MenuTbl			dw 4				; count
				dw Menu1
				dw Menu2
				dw Menu3
				dw Menu4
MenuTblEnd

Menu1			asc '>>@\XN1'00
				asc '--About This Program...\N256*??'00
				asc '---\D'00
				asc '>'

Menu2			asc '>>  File  \N2'00
				asc '--Quit\N257*Qq'00
				asc '>'

Menu3			asc '>>  Edit  \N3D'00
				asc '--Undo\N250V*Zz'00
				asc '--Cut\N251*Xx'00
				asc '--Copy\N252*Cc'00
				asc '--Paste\N253V*Vv'00
				asc '--Clear\N254'00
				asc '>'

Menu4			asc '>>  Test  \N4'00
				asc '--TCP/IP Test\N258*Tt'00
				asc '--Connect to Server\N259*Uu'00
				asc '>'

*
* Event Record
*
EventRec
Event_What   	ds 2
Event_Msg		ds 4
Event_When		ds 4
Event_Where		ds 4
Event_Mods		ds 2
TaskData		ds 4
TaskMask		dw $1fff,$0000

*
* Strings
*
OneMoment		asc 'One Moment Please...'00
MarinettiGood	str 'Marinetti is Up.'
MarinettiBad	str 'Marinetti is Not Up.'
AboutString		str 'TCPIP Test Program'
But1			str 'OK'

*
* Connect To Server Dialog
*
CTSRect			dw 30,120,120,520			; bounds rect
CTSVis			dw 0001						; visible
CTSRef			dw 0000,0000				; refcon
CTSiptr1		adrl CTSItem1				; string 'Host To Connect To'
CTSiptr2		adrl CTSItem2				; edit line
CTSiptr3		adrl CTSItem3				; connect button
CTSiptr4		adrl CTSItem4				; cancel button
CTSiptr5		adrl CTSItem5				; status line
CTSiptr6		adrl CTSItem6				; My IP Address
CTSiptr7		adrl CTSItem7				; "My Ip Address: "
				dw 0000						; end of the line

CTSItem1		dw 1348						; id
				dw 5,10,15,300				; bounds
				dw statText+$8000			; type + disabled
				adrl CTSText1
				dw 00						; item value
				dw 00						; item flag
				adrl 00						; end
CTSText1		str 'Address Of CIFS Server To Connect To:'

CTSItem2		dw 1349						; id
				dw 25,10,38,200				; bounds
				dw editLine
				adrl CTSText2
				dw 100
				dw 00
				adrl 00
CTSText2		str 'example.com'

CTSItem3		dw 1
				dw 50,10,60,100
				dw buttonItem
				adrl But2
				dw 00
				dw 00
				adrl 00
But2			str 'Connect'

CTSItem4		dw 2
				dw 50,111,60,210
				dw buttonItem
				adrl But3
				dw 00
				dw 00
				adrl 00
But3			str 'Cancel'

CTSItem5		dw 1350						; id
				dw 65,10,75,300				; bounds
				dw statText+$8000			; type + disabled
				adrl CTSText3
				dw 00
				dw 00
				adrl 00
CTSText3		str 'Status: Awaiting Input'
CTSText4		str 'Status: Resolving Hostname '
inhost			ds 101
CTSText5		str 'Status: Resolution Failure'
CTSText6		str 'Status: Connecting to '
ascdest			ds 20
CTSText9		str 'Status: Connected, CIFS negotiating'
CTSTextA		str 'Status: Connect Failed'
CTSTextB		str 'Status: Logging In'
CTSTextC		str 'Status: Mounting Share'
CTSTextD		str 'Status: Opening \\testfile'

CTSItem6		dw 1360						; id
				dw 77,120,87,300			; bounds
				dw statText+$8000
				adrl CTSText7
				dw 00
				dw 00
				adrl 00
CTSText7		str '0.0.0.0'

CTSItem7		dw 1361						; id
				dw 77,10,87,120				; bounds
				dw statText+$8000
				adrl CTSText8
				dw 00
				dw 00
				adrl 00
CTSText8		str 'My IP Address:'

*
* TCPIP Test Output Dialog
*
OurAlert		dw 30,120,80,520			; bounds rect
				dw 2374						; id
				db $80
				db $80
				db $80
				db $80
				adrl item1
				adrl item2
				adrl 00

item1			dw 1						; id
				dw 25,320,0,0				; bounds rect for button
				dw buttonItem				; type
				adrl But1					; item descriptor
				dw 00						; item value
				dw 00						; item flag
				adrl 00						; item color

item2			dw 1348						; id
				dw 11,72,200,640			; bounds rect for message
				dw statText+$8000			; type + disabled
dialogMsg		adrl MarinettiGood			; item descriptor
				dw 00						; item value
				dw 00						; item flag
				adrl 00						; item color

*
* GS/OS Quit Params
*
QParams			ds 4
				ds 4

*** CIFS / SMB internals only past this point (will eventually be its own linker segment)

*
* SMB equates (should move into Library/E16.CIFS.Macs.s eventually)
*

* offsets into SMB header
SMB_offset_tcplength	= 1					; tcp length: all dgram length including header
SMB_offset_proto	= 0+4
SMB_offset_cmd		= 4+4
SMB_offset_ntstatus	= 5+4
SMB_offset_eclass	= 5+4
SMB_offset_flags	= 9+4
SMB_offset_flags2	= 10+4
SMB_offset_extra	= 12+4
SMB_offset_tid		= 24+4
SMB_offset_pid		= 26+4
SMB_offset_uid		= 28+4
SMB_offset_mid		= 30+4
SMB_header_size		= 32+4					; SMB headers are always 32 bytes long

* message / commands
NBT_session_msg		= 00
SMB_neg_protocol	= $72
SMB_setup_ANDX		= $73
SMB_treec_ANDX		= $75

* keepalive
NBT_keepalive_msg	= $85
keepalive_size		= 4

* SMBTrans2
SMB_trans2			= $32
SMB_open2			= 0
SMB_find_first2		= 1
SMB_find_next2		= 2
SMB_query_fs_info	= 3
SMB_query_path_info	= 5
SMB_set_path_info	= 6
SMB_query_file_info	= 7
SMB_set_file_info	= 8
SMB_create_dir		= 13
SMB_find_close2		= $34
SMB_query_file_all_info	= $107

* File I/O
SMB_open_ANDX		= $2d
SMB_write_ANDX		= $2f
SMB_read_ANDX		= $2e
SMB_close			= $04

* SMB_COM
SMB_COM_create_directory		= $00
SMB_COM_delete_directory		= $01
SMB_COM_delete					= $06
SMB_COM_rename					= $07
SMB_COM_query_information_disk	= $80

* TRANS2 offsets
T2_word_cnt			= SMB_header_size
T2_prm_cnt			= T2_word_cnt+1
T2_data_cnt			= T2_prm_cnt+2
T2_maxprm_cnt		= T2_data_cnt+2
T2_maxbuffer		= T2_maxprm_cnt+2
T2_setup_cnt		= T2_maxbuffer+2
T2_sprm_cnt			= T2_setup_cnt+10
T2_sprm_ofs			= T2_sprm_cnt+2
T2_sdata_cnt		= T2_sprm_ofs+2
T2_sdata_ofs		= T2_sdata_cnd+2
T2_ssetup_cnt		= T2_sdata_ofs+2
T2_sub_cmd			= T2_ssetup_cnt+2
T2_byte_cnt			= T2_sub_cmd+2

SMB_proto1			= $53ff						; $ff + 'S'
SMB_proto2			= $424d						; 'MB'

SMB_max_net_read_size	= 16384
SMB_max_net_write_size	= 4096
SMB_max_transmit_size	= 16384

CAP_large_files		= $00000008					; 64-bit file sizes and offsets supported
CAP_unicode			= $00000004					; unicode supported

CIFS_flags1			= $08						; paths are caseless
CIFS_flags2_unicode	= $8001						; server may return long components in paths in the response - Unicode supported
CIFS_flags2			= $0001						; server may return long components in paths in the response - ASCII supported

SMB_connhandles_max	= 8
SMB_filehandles_max	= (32*SMB_connhandles_max)

SMB_objtype_handle	= 7

* NBT session service packet type codes
SESS_msg			= $0
SESS_req			= $81
SESS_pos_resp		= $82
SESS_neg_resp		= $83
SESS_retarget		= $84
SESS_keepalive		= $85

SMB_maxpath			= 4096

* SMB error codes
SMB_success			= 0
SMB_error			= $ffff						; -1
SMB_bad_protocol	= $fffe						; -2
SMB_bad_command		= $fffd						; -3
SMB_proto_fail		= $fffc						; -4
SMB_not_user		= $fffb						; -5
SMB_bad_keylen		= $fffa						; -6
SMB_bad_datalen		= $fff9						; -7
SMB_bad_logindata	= $fff8						; -8

* SMB file open function
SMB_of_open			= 1
SMB_of_truncate		= 2
SMB_of_create		= 16

* FileSearch
SMB_srch_readonly	= 1
SMB_srch_hidden		= 2
SMB_srch_system		= 4
SMB_srch_volume		= 8
SMB_srch_directory	= 16
SMB_srch_archive	= 32

* SMB file access modes
SMB_open_reading	= 0
SMB_open_writing	= 1
SMB_open_readwrite	= 2
SMB_open_compatible	= 0
SMB_deny_readwrite	= $10
SMB_deny_write		= $20
SMB_deny_read		= $30
SMB_deny_none		= $40

*
* SMB variable space
*

* SMB DP variables
SMB_sessid			= 8
SMB_tmp1			= 12
SMB_tmp2			= 14
SMB_tmp3			= 16
SMB_tmp4			= 18
SMB_tmp5			= 20

* SMB session information
* TODO dynamically allocate these - see SMB_Init
SMB_sess_begin
SMB_sess_ipid		dw 0					; Marinetti IPID
SMB_sess_tid		dw 0					; SMB TID
SMB_sess_pid		dw $dead				; SMB PID
SMB_sess_uid		dw 0					; SMB UID
SMB_sess_mid		dw $0001				; SMB MID
SMB_sess_skey		dw 0,0					; sKey
SMB_sess_caps		dw 0,0					; capabilities
SMB_sess_maxbuffer	dw 0,0					; max buffer
SMB_sess_seclvl		dw 0					; server security level
SMB_sess_maxmpx		dw 0					; server max pending outstanding requests
SMB_sess_maxvcs		dw 0					; server max virtual circuits
SMB_sess_challenge_used	dw 0					; challenge Used?
SMB_sess_challenge	dw 0,0,0,0				; challenge
SMB_sess_domain		ds 32					; sloppy 32 byte buffer to hold SMB domain

* Strings
SMB_dialect			asc 02'NT LM 0.12'00		; the only dialect we're gonna speak
SMB_os				asc 'GS/OS'00				; native Operating System
SMB_lanman			asc 'Apple IIgs'00			; native LAN Manager
SMB_lm_username		asc 'PI'00,00,00,00,00,00,00,00,00,00,00,00 ; lanman hash login username
SMB_lm_password		asc 'APPLE2'00,00,00,00,00,00,00,00 ; lanman hash login password
SMB_lm_magic		asc 'KGS!@#$%'				; lanman hash magic DES crypt string
SMB_lm_hash			ds 21						; LM Hash, actually 16 bytes but the extra zeroes make response easier to generate
SMB_lm_response		ds 24						; LM Response
SMB_target_tree		asc '\\LIVINGROOM\GSFILES'00	; remote tree to connect to
SMB_target_svc		asc '?????'00					; service type (wildcard)
SMB_target_file		asc '\\TESTFILE'00			; file to download

* SMB packet staging area
* TODO these will probably be dynamically allocated too?
*  also SMB_max_transmit size should go up to 65535 and use an allocated bank like Marinetti does
SMB_staging_brk		brk 00						; jump here to crash somewhere where you can easily inspect the generated SMB datagram
SMB_staging			ds SMB_max_transmit_size+2
SMB_input_brk		brk 00
SMB_input			ds SMB_max_net_read_size	; TODO Memory Manage this eh

*
* SMB Subroutines
*

* SMB_Init - Call me to tell me about your Marinetti IPID and get a session handle returned for future SMB calls
* Arguments:
*    Marinetti IPID (one word, on stack)
* Returns:
*    SMB session handle (two words, on stack)
*    Carry flag set if error
* TODO: make this support multiple sessions in the future
SMB_Init		plx							; return address
				pla
				sta SMB_sess_ipid
				PushLong #SMB_sess_begin
				phx							; saved return address
				clc
				rts

* SMB_Negotiate - Call me when you've opened a TCPIP connection and want to perform Negotiate Protocol Request
* Arguments:
*    SMB session handle (two words, on stack)
* Things I return on stack:
*    Carry flag set if error
SMB_Negotiate	plx							; return address
				PullLong SMB_sessid
				phx							; saved return address

				PushWord #SMB_neg_protocol	; command
				PushWord #CIFS_flags1		; flags1
				PushWord #CIFS_flags2		; flags2
				jsr _InitSMBHeader			; make an SMB header with this information
				
				sep $30
				mx %11
				ldy #0
				ldx #0
dialect_copy	lda SMB_dialect,x			; 8-bit copy of dialect string into SMB staging area
				beq dialect_done
				sta SMB_staging+SMB_header_size+3,x
				inx
				iny
				bra dialect_copy
dialect_done	sta SMB_staging+SMB_header_size+3,x	; do write the trailing zero
				inx
				iny
				rep $30
				mx %00
				
				tya
				sta SMB_staging+SMB_header_size+1		; save byte count
				
				clc
				adc #SMB_header_size+3
				pha							; 'length' parameter for _SMB_Send
				dec
				dec
				dec
				dec
				xba
				sta SMB_staging+SMB_offset_tcplength+1			; save length for naked-TCP dgram
				
				jsr _SMB_Send
				clc
				rts

* SMB_Negotiate_Poll - Call me until I tell you to stop, to receive and complete SMB negotiation
* Arguments:
*   SMB session handle (two words, on stack)
* Things I return on stack:
*   Negotiation status (word)
*     $0000 - Negotiation proceeding
*     $0001 - Negotiation finished
*     $0002 - Negotiation failed
*   Carry flag set means you can stop calling me
SMB_Negotiate_Poll
				plx							; our return address
				PullLong SMB_sessid			; your smb sessid
				phx

				_TCPIPPoll

				PushWord #0000				; space for result
				ldy #SMB_sess_ipid-SMB_sess_begin
				lda [SMB_sessid],y
				pha							; push Marinetti IPID for this SMB_sessid
				PushLong #statbuf
				_TCPIPStatusTCP				; see if marinetti has anything for us
				pla
				cmp #terrNOCONNECTION
				beq nf_trampoline
				cmp #terrBADIPID
				beq nf_trampoline
				lda statbuf+8				; get recvq size, low word
				cmp #0000					; yeah i know. for clarity.
				beq np_trampoline			; poll us again later, marinetti got nothing

				PushWord #0000				; space for result
				ldy #SMB_sess_ipid-SMB_sess_begin
				lda [SMB_sessid],y
				pha							; push Marinetti IPID for this SMB_sessid
				PushWord #0000				; bufftype: static pre-allocated buffer
				PushLong #SMB_input			; where it's all goin
				PushLong #SMB_max_net_read_size
				PushLong #readbuf
				_TCPIPReadTCP

				pla
				cmp #terrNOCONNECTION
				beq nf_trampoline
				cmp #terrBADIPID
				beq nf_trampoline
								
				jsr _SMB_Check				; do basic check to make sure we received SMB data
				bcs np_trampoline			; if not, wait for them to send again i guess
				
`				lda SMB_input+SMB_offset_cmd
				cmp #SMB_neg_protocol
				bne np_trampoline			; punt if not protocol negotiation reply
				
				lda SMB_input+SMB_offset_eclass
				cmp #0000
				bne nf_trampoline				; they returned an error, kbye
				
				lda SMB_input+SMB_header_size
				and #$ff
				cmp #17
				bne nf_trampoline				; they should always return 17 words
				
				lda SMB_input+SMB_header_size
				xba
				and #$ff
				cmp #00
				bne nf_trampoline			; they should always select dialect 0

				bra nft_far
nf_trampoline	jmp nego_failed
np_trampoline	jmp nego_proceeding
nft_far
				
				lda SMB_input+SMB_header_size+3
				and #$01
				ldy #SMB_sess_seclvl-SMB_sess_begin
				sta [SMB_sessid],y			; save session security level (1=user level, 0=share level)

				lda SMB_input+SMB_header_size+4
				and #$ff
				ldy #SMB_sess_maxmpx-SMB_sess_begin
				sta [SMB_sessid],y			; save session MaxMPX
				
				lda SMB_input+SMB_header_size+6
				and #$ff
				ldy #SMB_sess_maxvcs-SMB_sess_begin
				sta [SMB_sessid],y			; save session MaxVCS
				
				lda SMB_input+SMB_header_size+8
				ldy #SMB_sess_maxbuffer-SMB_sess_begin
				sta [SMB_sessid],y			; save session maxbuffer
								
				lda SMB_input+SMB_header_size+16
				ldy #SMB_sess_skey-SMB_sess_begin
				sta [SMB_sessid],y			; save skey
				
				lda SMB_input+SMB_header_size+20
				ldy #SMB_sess_caps-SMB_sess_begin
				sta [SMB_sessid],y
				iny
				iny
				lda SMB_input+SMB_header_size+22
				sta [SMB_sessid],y			; save server capabilities

				; TODO serverTime
				
				lda SMB_input+SMB_header_size+33
				and #$ff
				cmp #8
				bne challenge_used
				cmp #0
				bne nego_failed				; should be either 8 or zero
				lda #$0000
				ldy #SMB_sess_challenge_used
				sta [SMB_sessid],y
				bra getdomain

challenge_used	lda #$0001
				ldy #SMB_sess_challenge_used-SMB_sess_begin
				sta [SMB_sessid],y
				
				lda SMB_input+SMB_header_size+37
				ldy #SMB_sess_challenge-SMB_sess_begin
				sta [SMB_sessid],y
				iny
				iny
				lda SMB_input+SMB_header_size+39
				sta [SMB_sessid],y
				iny
				iny
				lda SMB_input+SMB_header_size+41
				sta [SMB_sessid],y
				iny
				iny
				lda SMB_input+SMB_header_size+43
				sta [SMB_sessid],y			; save 8-byte challenge

getdomain		ldy #SMB_sess_domain-SMB_sess_begin
				ldx #00
gdloop			lda SMB_input+SMB_header_size+45,x
				and #$00ff
				cmp #0000
				beq eod
				sta [SMB_sessid],y			; if this looks off to you, see how
				iny							; the domain name is actually encoded
				inx							; W\00O\00R\00K\00G\00R\00O\00U\00P\00
				inx
				bra gdloop

eod				sta [SMB_sessid],y			; save terminating zero				

nego_finished	plx							; our return address
				PushWord #0001				; finished!
				phx
				sec
				rts

nego_failed		plx							; our return address
				PushWord #0002				; failure
				phx
				sec
				rts

nego_proceeding	plx							; our return address
				PushWord #0000				; in progress
				phx
				clc
				rts

*
* SMB_SetupAndX - Next step after negotiating protocol, includes authentication
* Arguments:
*    SMB session handle (two words, on stack)
* Things I return on stack:
*    Carry flag set if error
SMB_SetupAndX	plx							; return address
				PullLong SMB_sessid
				phx							; saved return address

				PushWord #SMB_setup_ANDX	; command
				PushWord #CIFS_flags1		; flags1
				PushWord #CIFS_flags2		; flags2
				jsr _InitSMBHeader			; make an SMB header with this information

				sep $30
				mx %11
				lda #13
				sta SMB_staging+SMB_header_size	; word count
				
				lda #$ff
				sta SMB_staging+SMB_header_size+1	; next AndX
				
				lda #00
				sta SMB_staging+SMB_header_size+2	; reserved
				rep $30
				mx %00
				
				ldy #SMB_sess_maxbuffer-SMB_sess_begin
				lda [SMB_sessid],y
				sta SMB_staging+SMB_header_size+5	; max buffer size
				
				ldy #SMB_sess_maxmpx-SMB_sess_begin
				lda [SMB_sessid],y
				sta SMB_staging+SMB_header_size+7	; max MPX
				
				ldy #SMB_sess_maxvcs-SMB_sess_begin
				lda [SMB_sessid],y
				sta SMB_staging+SMB_header_size+9	; max VCS
				
				ldy #SMB_sess_skey-SMB_sess_begin
				lda [SMB_sessid],y
				sta SMB_staging+SMB_header_size+11	; session key
				lda #0
				sta SMB_staging+SMB_header_size+13	; session key (upper, should always be zero?)
				
				lda #24
				sta SMB_staging+SMB_header_size+15	; password length (case insensitive)
				
				lda #0
				sta SMB_staging+SMB_header_size+17	; password length (case sensitive/NTLM)
				
				lda #0
				sta SMB_staging+SMB_header_size+19	; reserved
				sta SMB_staging+SMB_header_size+21	; reserved
				
				ldy #SMB_sess_caps-SMB_sess_begin
				lda [SMB_sessid],y
				sta SMB_staging+SMB_header_size+23
				iny
				iny
				lda [SMB_sessid],y
				sta SMB_staging+SMB_header_size+25	; session capabilities
				
				jsr SMB_LM_Hash					; generate NTLMv1 Hash
				jsr SMB_LM_Response				; generate NTLMv1 Response
				
				lda #0
				sta SMB_tmp5					; initialize pointer
				
				; Case Insensitive Password (LM Response)
				PushLong #SMB_lm_response					; source
				pea #^SMB_staging
				lda #SMB_staging+SMB_header_size+29
				clc
				adc SMB_tmp5
				pha
				ldx #24
				jsr _strncpy
				lda #24
				clc
				adc SMB_tmp5
				sta SMB_tmp5
				
				; Case Sensitive Password (NTLM Response)
				clc
				adc #24
				sta SMB_tmp5								; skip it / zero it for now
				
				; Account
				PushLong #SMB_lm_username					; source
				pea #^SMB_staging							; destination
				lda #SMB_staging+SMB_header_size+29
				clc
				adc SMB_tmp5
				pha
				jsr _strcpy
				tya
				clc
				adc SMB_tmp5
				sta SMB_tmp5
				
				; Domain
				PushLong #SMB_sess_domain					; source
				pea #^SMB_staging							; destination
				lda #SMB_staging+SMB_header_size+29
				clc
				adc SMB_tmp5
				pha
				jsr _strcpy
				tya
				clc
				adc SMB_tmp5
				sta SMB_tmp5
				
				; OS
				PushLong #SMB_os							; source
				pea #^SMB_staging							; destination
				lda #SMB_staging+SMB_header_size+29
				clc
				adc SMB_tmp5
				pha
				jsr _strcpy
				tya
				clc
				adc SMB_tmp5
				sta SMB_tmp5
				
				; LanMan
				PushLong #SMB_lanman
				pea #^SMB_staging							; destination
				lda #SMB_staging+SMB_header_size+29
				clc
				adc SMB_tmp5
				pha
				jsr _strcpy
				tya
				clc
				adc SMB_tmp5
				sta SMB_tmp5
				
				sta SMB_staging+SMB_header_size+27		; update byte count
				
				clc
				adc #SMB_header_size+29
				pha							; 'length' parameter for _SMB_Send
				dec
				dec
				dec
				dec
				xba
				sta SMB_staging+SMB_offset_tcplength+1			; save length for naked-TCP dgram

				jsr _SMB_Send							; send our reply!
				clc
				rts

* SMB_LM_Hash - operate on the SMB_lm_username and SMB_lm_password values to produce
* SMB_lm_hash, using V1 DES-based operation. Requires TOOL129 (Crypto Tool)
*
* The password has been uppercased and chopped to 14 bytes, with 0x00 padding
* We take it in two 7-byte pieces, add parity, and use each piece to DES-encrypt the string
* 'KGS!@#$%'. The result is the LM hash.
SMB_LM_Hash		PushLong #SMB_tmp1					; SMB_tmp1 will have our parity-enhanced key
				PushLong #SMB_lm_password			; key to add parity to
				Tool $0A81							; DESAddParity

				PushLong #SMB_lm_hash				; where DES-encrypted data will go
				PushLong #SMB_tmp1					; parity-enhanced key
				PushLong #SMB_lm_magic				; the magic string we're encrypting
				PushWord #0000						; operation: encrypt
				Tool $0981							; DESCipher

				; now do the same thing with the second 7 bytes of the password

				PushLong #SMB_tmp1
				PushLong #SMB_lm_password+7
				Tool $0A81							; DesAddParity

				PushLong #SMB_lm_hash+8
				PushLong #SMB_tmp1
				PushLong #SMB_lm_magic
				PushWord #0000
				Tool $0981

				; SMB_lm_hash should now contain the NTLMv1 hash of the password
				clc
				rts

* SMB_LM_Response - operate on SMB_lm_hash and 8-byte challenge to produce
* SMB_lm_response, using V1 DES-based operation. Requires TOOL129 (Crypto Tool)
*
* LM Hash is padded out to 21 bytes, each of which gets parity added and is
* used to DES encrypt the session challenge. The result is the LM response.
SMB_LM_Response
				PushLong #SMB_tmp1				; SMB_tmp1 will have our parity-enhanced key
				PushLong #SMB_lm_hash			; key to add parity to
				Tool $0A81						; DESAddParity
				
				PushLong #SMB_lm_response		; where the DES-encrypted data will go
				PushLong #SMB_tmp1				; parity-enhanced key
				ldy #SMB_sess_challenge-SMB_sess_begin
				lda [SMB_sessid],y				; PushLong [SMB_sessid],y
				pha
				iny
				iny
				lda [SMB_sessid],y
				pha
				PushWord #0000					; operation: encrypt
				Tool $0981						; DESCipher
				
				; second 7 bytes of hash
				
				PushLong #SMB_tmp1
				PushLong #SMB_lm_hash+7
				Tool $0A81						; DESAddParity
				
				PushLong #SMB_lm_response+8
				PushLong #SMB_tmp1
				ldy #SMB_sess_challenge-SMB_sess_begin
				lda [SMB_sessid],y				; PushLong [SMB_sessid],y
				pha
				iny
				iny
				lda [SMB_sessid],y
				pha
				PushWord #0000
				Tool $0981						; DESCipher
				
				; third 7 bytes of hash
				
				PushLong #SMB_tmp1
				PushLong #SMB_lm_hash+14
				Tool $0A81						; DesAddParity
				
				PushLong #SMB_lm_response+16
				PushLong #SMB_tmp1
				ldy #SMB_sess_challenge-SMB_sess_begin
				lda [SMB_sessid],y
				pha
				iny
				iny
				lda [SMB_sessid],y
				pha
				PushWord #0000
				Tool $0981						; DESCipher
				
				clc
				rts

* SMB_Setup_Poll - Call me until I tell you to stop, to receive and complete SMB setup
* Arguments:
*   SMB session handle (two words, on stack)
* Things I return on stack:
*   Setup status (word)
*     $0000 - Setup proceeding
*     $0001 - Setup finished
*     $0002 - Setup failed
*   Carry flag set means you can stop calling me
SMB_Setup_Poll
				plx							; our return address
				PullLong SMB_sessid			; your smb sessid
				phx

				_TCPIPPoll

				PushWord #0000				; space for result
				ldy #SMB_sess_ipid-SMB_sess_begin
				lda [SMB_sessid],y
				pha							; push Marinetti IPID for this SMB_sessid
				PushLong #statbuf
				_TCPIPStatusTCP				; see if marinetti has anything for us
				pla
				cmp #terrNOCONNECTION
				beq sf_trampoline
				cmp #terrBADIPID
				beq sf_trampoline
				lda statbuf+8				; get recvq size, low word
				cmp #0000					; yeah i know. for clarity.
				beq sp_trampoline			; poll us again later, marinetti got nothing

				PushWord #0000				; space for result
				ldy #SMB_sess_ipid-SMB_sess_begin
				lda [SMB_sessid],y
				pha							; push Marinetti IPID for this SMB_sessid
				PushWord #0000				; bufftype: static pre-allocated buffer
				PushLong #SMB_input			; where it's all goin
				PushLong #SMB_max_net_read_size
				PushLong #readbuf
				_TCPIPReadTCP

				pla
				cmp #terrNOCONNECTION
				beq sf_trampoline
				cmp #terrBADIPID
				beq sf_trampoline
								
				jsr _SMB_Check				; do basic check to make sure we received SMB data
				bcs sp_trampoline			; if not, wait for them to send again i guess

				bra sft_far
sf_trampoline	jmp setup_failed
sp_trampoline	jmp setup_proceeding
sft_far
				lda SMB_input+SMB_offset_cmd
				cmp #SMB_setup_ANDX
				bne sp_trampoline			; punt if not setup_ANDX reply
				
				lda SMB_input+SMB_offset_eclass
				cmp #0000
				bne sf_trampoline			; they returned an error, kbye
				
				lda SMB_input+SMB_offset_uid
				ldy #SMB_sess_uid-SMB_sess_begin
				sta [SMB_sessid],y			; save returned UID

* TODO save far end's OS, Lan Manager, and Workgroup?

setup_finished	plx							; our return address
				PushWord #0001				; finished!
				phx
				sec
				rts

setup_failed	plx							; our return address
				PushWord #0002				; failure
				phx
				sec
				rts

setup_proceeding
				plx							; our return address
				PushWord #0000				; in progress
				phx
				clc
				rts

*
* SMB_TreeAndX - Connect to the remote share
* Arguments:
*    SMB session handle (two words, on stack)
* Things I return on stack:
*    Carry flag set if error
SMB_TreeAndX	plx							; return address
				PullLong SMB_sessid
				phx							; saved return address

				PushWord #SMB_treec_ANDX	; command
				PushWord #CIFS_flags1		; flags1
				PushWord #CIFS_flags2		; flags2
				jsr _InitSMBHeader			; make an SMB header with this information

				sep $30
				mx %11
				lda #4
				sta SMB_staging+SMB_header_size	; word count
				
				lda #$ff
				sta SMB_staging+SMB_header_size+1	; next AndX
				
				rep $30
				mx %00
				
				lda #0000
				sta SMB_staging+SMB_header_size+3	; reserved
				
				lda #0000
				sta SMB_staging+SMB_header_size+5	; flags
				
				lda #1
				sta SMB_staging+SMB_header_size+7	; password length (1 if user-level security)

				lda #0
				sta SMB_tmp5					; initialize pointer
				
				; Share password
				lda #00
				sta SMB_staging+SMB_header_size+11	; 0x00 (nul password, no share level security)
				inc SMB_tmp5
				
				; Target Tree
				PushLong #SMB_target_tree
				pea #^SMB_staging							; destination
				lda #SMB_staging+SMB_header_size+11
				clc
				adc SMB_tmp5
				pha
				jsr _strcpy
				tya
				clc
				adc SMB_tmp5
				sta SMB_tmp5
				
				; Target Service Type
				PushLong #SMB_target_svc
				pea #^SMB_staging							; destination
				lda #SMB_staging+SMB_header_size+11
				clc
				adc SMB_tmp5
				pha
				jsr _strcpy
				tya
				clc
				adc SMB_tmp5
				sta SMB_tmp5
				
				sta SMB_staging+SMB_header_size+9		; update byte count
				
				clc
				adc #SMB_header_size+11
				pha							; 'length' parameter for _SMB_Send
				dec
				dec
				dec
				dec
				xba
				sta SMB_staging+SMB_offset_tcplength+1			; save length for naked-TCP dgram

				jsr _SMB_Send							; send our reply!
				clc
				rts

* SMB_TreeX_Poll - Call me until I tell you to stop, to receive and complete SMB Tree_ANDX
* Arguments:
*   SMB session handle (two words, on stack)
* Things I return on stack:
*   Setup status (word)
*     $0000 - Setup proceeding
*     $0001 - Setup finished
*     $0002 - Setup failed
*   Carry flag set means you can stop calling me
SMB_TreeX_Poll
				plx							; our return address
				PullLong SMB_sessid			; your smb sessid
				phx

				_TCPIPPoll

				PushWord #0000				; space for result
				ldy #SMB_sess_ipid-SMB_sess_begin
				lda [SMB_sessid],y
				pha							; push Marinetti IPID for this SMB_sessid
				PushLong #statbuf
				_TCPIPStatusTCP				; see if marinetti has anything for us
				pla
				cmp #terrNOCONNECTION
				beq tf_trampoline
				cmp #terrBADIPID
				beq tf_trampoline
				lda statbuf+8				; get recvq size, low word
				cmp #0000					; yeah i know. for clarity.
				beq tp_trampoline			; poll us again later, marinetti got nothing

				PushWord #0000				; space for result
				ldy #SMB_sess_ipid-SMB_sess_begin
				lda [SMB_sessid],y
				pha							; push Marinetti IPID for this SMB_sessid
				PushWord #0000				; bufftype: static pre-allocated buffer
				PushLong #SMB_input			; where it's all goin
				PushLong #SMB_max_net_read_size
				PushLong #readbuf
				_TCPIPReadTCP

				pla
				cmp #terrNOCONNECTION
				beq tf_trampoline
				cmp #terrBADIPID
				beq tf_trampoline
								
				jsr _SMB_Check				; do basic check to make sure we received SMB data
				bcs tp_trampoline			; if not, wait for them to send again i guess

				bra tft_far
tf_trampoline	jmp treex_failed
tp_trampoline	jmp treex_proceeding
tft_far
				lda SMB_input+SMB_offset_cmd
				cmp #SMB_treec_ANDX
				bne tp_trampoline			; punt if not setup_ANDX reply
				
				lda SMB_input+SMB_offset_eclass
				cmp #0000
				bne tf_trampoline			; they returned an error, kbye
				
				lda SMB_input+SMB_offset_tid
				ldy #SMB_sess_tid-SMB_sess_begin
				sta [SMB_sessid],y			; save returned TID
				
* TODO save remote servicetype or filesystem type?

treex_finished	plx							; our return address
				PushWord #0001				; finished!
				phx
				sec
				rts

treex_failed	plx							; our return address
				PushWord #0002				; failure
				phx
				sec
				rts

treex_proceeding
				plx							; our return address
				PushWord #0000				; in progress
				phx
				clc
				rts

*
* SMB_OpenFile - Open a file on the remote share
* Arguments:
*    SMB session handle (two words, on stack)
*    Long pointer to filename (two words, on stack)
* Things I return on stack:
*    A = SMB filehandle id
*    Carry flag set if error
SMB_OpenFile	plx							; return address
				PullLong SMB_tmp1			; filename
				PullLong SMB_sessid
				phx							; saved return address

				PushWord #SMB_open_ANDX		; command
				PushWord #CIFS_flags1		; flags1
				PushWord #CIFS_flags2		; flags2
				jsr _InitSMBHeader			; make an SMB header with this information

				sep $30
				mx %11
				lda #15
				sta SMB_staging+SMB_header_size	; word count
				
				lda #$ff
				sta SMB_staging+SMB_header_size+1	; next AndX
				
				lda #$00
				sta SMB_staging+SMB_header_size+2   ; AndX Reserved
				
				rep $30
				mx %00
				
				lda #$0000
				sta SMB_staging+SMB_header_size+3	; AndX Offset
				
				lda #$0000
				sta SMB_staging+SMB_header_size+5	; Flags
				
				lda #SMB_open_reading
				sta SMB_staging+SMB_header_size+7	; Access Mode
				
				lda #0006
				sta SMB_staging+SMB_header_size+9	; ??
				
				lda #0000
				sta SMB_staging+SMB_header_size+11	; type of file
				
				lda #0000
				sta SMB_staging+SMB_header_size+13	; file attributes
				
				lda #0000
				sta SMB_staging+SMB_header_size+15	; file time (don't care, let server decide)
				sta SMB_staging+SMB_header_size+17
				
				lda #0000
				sta SMB_staging+SMB_header_size+19	; creation flags
				
				lda #0000
				sta SMB_staging+SMB_header_size+21	; creation flags2?
				
				lda #0000
				sta SMB_staging+SMB_header_size+23	; allocation size
				sta SMB_staging+SMB_header_size+25	; allocation size
				
				lda #0000
				sta SMB_staging+SMB_header_size+27	; reserved[0] must be zero
				lda #0000
				sta SMB_staging+SMB_header_size+31	; reserved[1] must be zero
				
				lda #0000
				sta SMB_staging+SMB_header_size+35	; byte count
				
				lda #0004
				sta SMB_staging+SMB_header_size+37	; BufferFormat (8-bit)

				lda #0
				sta SMB_tmp5					; initialize pointer
				
				; Target File
				PushLong #SMB_tmp1						; source
				pea #^SMB_staging							; destination
				lda #SMB_staging+SMB_header_size+38
				clc
				adc SMB_tmp5
				pha
				jsr _strcpy
				tya
				clc
				adc SMB_tmp5
				sta SMB_tmp5

				sta SMB_staging+SMB_header_size+35		; update byte count
				
				clc
				adc #SMB_header_size+33
				pha							; 'length' parameter for _SMB_Send
				dec
				dec
				dec
				dec
				xba
				sta SMB_staging+SMB_offset_tcplength+1			; save length for naked-TCP dgram

				jsr _SMB_Send							; send our reply!
				clc
				rts

* SMB_OpenFile_Poll - Call me until I tell you to stop, to receive and complete SMB Tree_ANDX
* Arguments:
*   SMB session handle (two words, on stack)
* Things I return on stack:
*   Setup status (word)
*     $0000 - Setup proceeding
*     $0001 - Setup finished
*     $0002 - Setup failed
*   Carry flag set means you can stop calling me
SMB_OpenFile_Poll
				plx							; our return address
				PullLong SMB_sessid			; your smb sessid
				phx

				_TCPIPPoll

				PushWord #0000				; space for result
				ldy #SMB_sess_ipid-SMB_sess_begin
				lda [SMB_sessid],y
				pha							; push Marinetti IPID for this SMB_sessid
				PushLong #statbuf
				_TCPIPStatusTCP				; see if marinetti has anything for us
				pla
				cmp #terrNOCONNECTION
				beq of_trampoline
				cmp #terrBADIPID
				beq of_trampoline
				lda statbuf+8				; get recvq size, low word
				cmp #0000					; yeah i know. for clarity.
				beq op_trampoline			; poll us again later, marinetti got nothing

				PushWord #0000				; space for result
				ldy #SMB_sess_ipid-SMB_sess_begin
				lda [SMB_sessid],y
				pha							; push Marinetti IPID for this SMB_sessid
				PushWord #0000				; bufftype: static pre-allocated buffer
				PushLong #SMB_input			; where it's all goin
				PushLong #SMB_max_net_read_size
				PushLong #readbuf
				_TCPIPReadTCP

				pla
				cmp #terrNOCONNECTION
				beq of_trampoline
				cmp #terrBADIPID
				beq of_trampoline
								
				jsr _SMB_Check				; do basic check to make sure we received SMB data
				bcs op_trampoline			; if not, wait for them to send again i guess

				bra oft_far
of_trampoline	jmp openx_failed
op_trampoline	jmp openx_proceeding
oft_far
				lda SMB_input+SMB_offset_cmd
				cmp #SMB_open_ANDX
				bne op_trampoline			; punt if not setup_ANDX reply
				
				lda SMB_input+SMB_offset_eclass
				cmp #0000
				bne of_trampoline			; they returned an error, kbye
				
				lda SMB_input+SMB_header_size+5 ; saved returned sfid

openx_finished	plx							; our return address
				PushWord #0001				; finished!
				phx
				sec
				rts

openx_failed	plx							; our return address
				PushWord #0002				; failure
				phx
				sec
				rts

openx_proceeding
				plx							; our return address
				PushWord #0000				; in progress
				phx
				clc
				rts


*
* SMB_CloseFile - Close an open file on the remote share
* Arguments:
*    SMB session handle (two words, on stack)
*    A = SMB filehandle id
* Things I return on stack:
*    Carry flag set if error
SMB_CloseFile	plx							; return address
				PullLong SMB_sessid
				phx							; saved return address

				PushWord #SMB_close			; command
				PushWord #CIFS_flags1		; flags1
				PushWord #CIFS_flags2		; flags2
				jsr _InitSMBHeader			; make an SMB header with this information

* TODO

				rts

*
* SMB_CreateDirectory - Create a directory on the remote share
* Arguments:
*    SMB session handle (two words, on stack)
*    Long pointer to filename (two words, on stack)
* Things I return on stack:
*    Carry flag set if error
SMB_CreateDirectory
				plx							; return address
				PullLong SMB_sessid
				phx							; saved return address

				PushWord #SMB_COM_create_directory	; command
				PushWord #CIFS_flags1		; flags1
				PushWord #CIFS_flags2		; flags2
				jsr _InitSMBHeader			; make an SMB header with this information

* TODO

				rts

*
* SMB_DeleteDirectory - Delete a directory on the remote share
* Arguments:
*    SMB session handle (two words, on stack)
*    Long pointer to filename (two words, on stack)
* Things I return on stack:
*    Carry flag set if error
SMB_DeleteDirectory
				plx							; return address
				PullLong SMB_sessid
				phx							; saved return address

				PushWord #SMB_COM_delete_directory	; command
				PushWord #CIFS_flags1		; flags1
				PushWord #CIFS_flags2		; flags2
				jsr _InitSMBHeader			; make an SMB header with this information

* TODO

				rts

*
* SMB_DeleteFile - Delete a file on the remote share
* Arguments:
*    SMB session handle (two words, on stack)
*    Long pointer to filename (two words, on stack)
* Things I return on stack:
*    Carry flag set if error
SMB_DeleteFile	plx							; return address
				PullLong SMB_sessid
				phx							; saved return address

				PushWord #SMB_COM_delete	; command
				PushWord #CIFS_flags1		; flags1
				PushWord #CIFS_flags2		; flags2
				jsr _InitSMBHeader			; make an SMB header with this information

* TODO

				rts

*
* SMB_RenameFile - Rename a file on the remote share
* Arguments:
*    SMB session handle (two words, on stack)
*    Long pointer to old filename (two words, on stack)
*    Long pointer to new filename (two words, on stack)
* Things I return on stack:
*    Carry flag set if error
SMB_RenameFile	plx							; return address
				PullLong SMB_sessid
				phx							; saved return address

				PushWord #SMB_COM_rename	; command
				PushWord #CIFS_flags1		; flags1
				PushWord #CIFS_flags2		; flags2
				jsr _InitSMBHeader			; make an SMB header with this information

* TODO

				rts

*
* SMB_DiskInformation - Get information about the remote share
* Arguments:
*    SMB session handle (two words, on stack)
*    Long pointer to disk statbuf (two words, on stack)
* Things I return on stack:
*    Carry flag set if error
SMB_DiskInformation
				plx							; return address
				PullLong SMB_sessid
				phx							; saved return address

				PushWord #SMB_COM_query_information_disk	; command
				PushWord #CIFS_flags1		; flags1
				PushWord #CIFS_flags2		; flags2
				jsr _InitSMBHeader			; make an SMB header with this information

* TODO

				rts

*
* SMB_ReadFile - Read an open file from the remote share
* Arguments:
*    SMB session handle (two words, on stack)
*    Long pointer to read buffer (two words, on stack)
*    Size of read buffer (two words, on stack)
*    Offset into file (two words, on stack)
* Things I return on stack:
*    Carry flag set if error
SMB_ReadFile	plx							; return address
				PullLong SMB_sessid
				phx							; saved return address

				PushWord #SMB_read_ANDX		; command
				PushWord #CIFS_flags1		; flags1
				PushWord #CIFS_flags2		; flags2
				jsr _InitSMBHeader			; make an SMB header with this information

* TODO

				rts

*
* SMB_WriteFile - Write to an open file from the remote share
* Arguments:
*    SMB session handle (two words, on stack)
*    Long pointer to data buffer (two words, on stack)
*    Size of data buffer (two words, on stack)
*    Offset into file (two words, on stack)
* Things I return on stack:
*    Carry flag set if error
SMB_WriteFile	plx							; return address
				PullLong SMB_sessid
				phx							; saved return address

				PushWord #SMB_write_ANDX	; command
				PushWord #CIFS_flags1		; flags1
				PushWord #CIFS_flags2		; flags2
				jsr _InitSMBHeader			; make an SMB header with this information

* TODO

				rts

*
* SMB_PathInfo - Get information about a file/path on the remote share
* Arguments:
*    SMB session handle (two words, on stack)
*    Long pointer to pathname (two words, on stack)
*    Long pointer to smb direntry struct buffer (two words, on stack)
* Things I return on stack:
*    Carry flag set if error
SMB_PathInfo	plx							; return address
				PullLong SMB_sessid
				phx							; saved return address

				PushWord #SMB_query_path_info	; command
				PushWord #CIFS_flags1		; flags1
				PushWord #CIFS_flags2		; flags2
				jsr _InitSMBHeader			; make an SMB header with this information

* TODO

				rts

*
* SMB_FindFirst - Find first file in a directory listing
* Arguments:
*    SMB session handle (two words, on stack)
*    Long pointer to pathname (two words, on stack)
*    Flags (one word, on stack)
*    Long pointer to smb direntry struct buffer (two words, on stack)
* Things I return on stack:
*    Carry flag set if error

* TODO TRANS2 call

*
* SMB_FindNext - Find next file in a directory listing
* Arguments:
*    SMB session handle (two words, on stack)
*    Long pointer to smb direntry struct buffer (two words, on stack)
* Things I return on stack:
*    Carry flag set if error

* TODO TRANS2 call

*
* SMB_FindClose - Close a directory listing
* Arguments:
*    SMB session handle (two words, on stack)
*    Long pointer to smb direntry struct buffer (two words, on stack)
* Things I return on stack:
*    Carry flag set if error

* TODO TRANS2 call


*
* Internal subroutines for SMB stuff
*

* _strcpy - Copy a string somewhere...
* Arguments:
*    Pointer to source (two words, on stack)
*    Pointer to destination (two words, on stack)
* returns:
*    Y = number of bytes copied (including terminating zero)
_strcpy			plx
				PullLong SMB_tmp1	; Destination
				PullLong SMB_tmp3	; Source
				phx
				ldy #00
				sep #$30
				mx %11
_sclp			lda [SMB_tmp3],y
				sta [SMB_tmp1],y
				cmp #00
				beq _scrt
				iny
				bra _sclp
_scrt			rep #$30
				mx %00
				iny
				rts				

* _strncpy - Copy a string somewhere, only n bytes
* Arguments:
*    Pointer to source (two words, on stack)
*    Pointer to destination (two words, on stack)
*    X = number of bytes to copy
_strncpy		txy
				plx
				PullLong SMB_tmp1	; Destination
				PullLong SMB_tmp3	; Source
				phx
				tyx
				ldy #00
				sep #$30
				mx %11
_snclp			lda [SMB_tmp3],y
				sta [SMB_tmp1],y
				dex
				cpx #00
				beq _sncrt
				iny
				bra _snclp
_sncrt			rep #$30
				mx %00
				rts	

* _SMB_Check - Check to see if TCP received data is SMB
_SMB_Check		lda SMB_input+SMB_offset_proto
				cmp #SMB_proto1
				bne check_inv
				lda SMB_input+SMB_offset_proto+2
				cmp #SMB_proto2
				bne check_inv					; starts with 'SMB'\ff
				clc
				rts
check_inv		sec
				rts

* _SMB_Send - Send the SMB datagram staging area out to Marinetti
* Arguments:
*    length  (word, pushed on stack first)
_SMB_Send		plx								; save return address
				PullWord SMB_tmp1
				phx								; restore return address
				lda #0
				sta SMB_tmp2
				PushWord #0000
				ldy #SMB_sess_ipid-SMB_sess_begin
				lda [SMB_sessid],y
				pha								; IPID for Marinetti
				PushLong #SMB_staging
				PushLong SMB_tmp1				; length
				PushWord #0001					; Samba sets PSH, so will I
				PushWord #0000
				_TCPIPWriteTCP
				pla
				rts

* _InitSMBHeader - Zero-out old SMB datagram data and start with some fresh header values
* Arguments:
*    Command (word, pushed on stack first)
*    Flags1  (word, pushed on stack second)
*    Flags2  (word, pushed on stack third)
*    Session Handle (already stored in DP SMB_sessid)
* Things I return on stack:
*    Carry flag set if error
_InitSMBHeader	ldx #00
				lda #00
zero_loop		sta SMB_staging,x				; loop to zero-out any old data from SMB header staging place
				inx
				inx
				cpx #SMB_max_transmit_size
				blt zero_loop

				lda #SMB_proto1
				sta SMB_staging+SMB_offset_proto
				lda #SMB_proto2
				sta SMB_staging+SMB_offset_proto+2	; $FF + 'SMB' at start of header
				
				ldy #SMB_sess_tid-SMB_sess_begin
				lda [SMB_sessid],y
				sta SMB_staging+SMB_offset_tid		; set session TID

				ldy #SMB_sess_pid-SMB_sess_begin
				lda [SMB_sessid],y
				sta SMB_staging+SMB_offset_pid		; set session PID
				
				ldy #SMB_sess_uid-SMB_sess_begin
				lda [SMB_sessid],y
				sta SMB_staging+SMB_offset_uid		; set session UID
				
				ldy #SMB_sess_mid-SMB_sess_begin
				lda [SMB_sessid],y
				sta SMB_staging+SMB_offset_mid		; set session MID
				
				plx									; save return address
				pla									; flags2 (word)
				sta SMB_staging+SMB_offset_flags2	; set Flags2
				
				pla									; flags1 (word, but written as byte)
				ora SMB_staging+SMB_offset_flags
				sta SMB_staging+SMB_offset_flags	; write one-byte value where it goes
				
				pla									; command (word, but written as byte)
				ora SMB_staging+SMB_offset_cmd
				sta SMB_staging+SMB_offset_cmd		; write one-byte value where it goes
				
				phx
				rts
