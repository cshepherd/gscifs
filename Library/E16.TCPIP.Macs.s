********************************************
* Marinetti Equates
*   by Richard Bennett
*
********************************************
* 1998-08-28 RJB Original version
* 2003-05-31 AJR Update to v2.1 of TCP/IP interfaces
********************************************
    
*-------------------------------------------------
* Various numeric equates
*-------------------------------------------------

* Connect methods
conEthernet = 1
conMacIP = 2
conPPPCustom = 3
conSLIP = 4
conTest = 5
conPPP = 6
conDirectConnect = 7
conAppleEthernet = 8


* Protocols
protocolAll = 0
protocolICMP = 1
protocolTCP = 6
protocolUDP = 17

* Tool Error codes
terrOK = 0
terrBADIPID = $3601	;Bad IPID for this request
terrNOCONNECTION = $3602	;Not connected to the network
terrNORECONDATA = $3603	;No reconnect data
terrLINKERROR = $3604	;Problem with the link layer
terrSCRIPTFAILED = $3605	;The script failed / timed out
terrCONNECTED = $3606	;Not while connected to the network
terrSOCKETOPEN = $3607	;Socket still open
terrINITNOTFOUND = $3608	;Init not found in memory
terrVERSIONMISMATCH = $3609	;Different versions of tool, init, cdev
terrBADTUNETABLELEN = $360A	;Bad tune table length
terrIPIDTABLEFULL = $360B	;IPID table full
terrNOICMPQUEUED = $360C	;No ICMP datagrams in the queue
terrLOGINSPENDING = $360D	;There are still IPIDs logged in
terrTCPIPNOTACTIVE =	$360E	;Not active. Probably in P8 mode.
terrNODNSERVERS = $360F	;No servers registered with Marinetti
terrDNRBUSY = $3610	;DNR is current busy. Try again later
terrNOLINKLAYER = $3611	;Unable to load link layer module
terrBADLINKLAYER = $3612	;Not a link layer module
terrENJOYCOKE = $3613	;But not so close to the keyboard
terrNORECONSUPPRT = $3614	;This module doesn't support reconnect
terrUSERABORTED = $3615	;The user aborted the connect/disconnect script
terrBADUSERPASS = $3616	;Invalid username and/or password
terrBADPARAMETER = $3617	;Invalid parameter for this call
terrBADENVIRONMENT = $3618	;No desktop or tools not started
terrNOINCOMING = $3619	;There is no pending incoming request
terrLINKBUSY = $361A		;Modem or interface is busy
terrNOLINKINTERFACE = $361B	;No dial tone or similar
terrNOLINKRESPONSE = $361C	;No modem answer or similar
terrNODNRPENDING = $361D	;No such entry in DNR list
terrBADALIVEMINUTES = $361E	;Minutes value is invalid
terrBUFFERTOOSMALL = $361F	;Buffer is too small
terrNOTSERVER = $3620	;This ipid is not set up as a server
terrBADTRIGGERNUM	=	$3621	;Invalid	trigger	number

terrmask = $00FF

* DNR status codes
DNR_Pending = 0	;Request still being processed
DNR_OK = 1		;Request completed successfully
DNR_Failed = 2		;Network error/timeout
DNR_NoDNSEntry = 3	;Requested domain has no DNS entry
DNR_Cancelled = 4	;Cancelled by user


* TCP logic errors
tcperrOK = 0	;"tcperr" error codes from TCP RFC
tcperrDeafDestPort = 1
tcperrHostReset = 2
tcperrConExists = 3	;"connection already exists"
tcperrConIllegal = 4	;"connection illegal for this process"
tcperrNoResources = 5	;"insuficient resources"
tcperrNoSocket = 6	;"foreign socket unspecified"
tcperrBadPrec = 7	;"precedence not allowed"
tcperrBadSec = 8	;"security/compartment not allowed"
tcperrBadConnection = 9	;"connection does not exist"
tcperrConClosing = 10	;"connection closing"
tcperrClosing = 11	;"closing"
tcperrConReset = 12	;"connection reset"
tcperrUserTimeout = 13	;"connection aborted due to user timeout"
tcperrConRefused = 14	;"connection refused"

* TCP states
TCPSCLOSED = 0
TCPSLISTEN = 1
TCPSSYNSENT = 2
TCPSSYNRCVD = 3
TCPSESTABLISHED = 4
TCPSFINWAIT1 = 5
TCPSFINWAIT2 = 6
TCPSCLOSEWAIT = 7
TCPSLASTACK = 8
TCPSCLOSING = 9
TCPSTIMEWAIT = 10
nTCPSTATES = 11


TCPIPSaysHello = $8101
TCPIPSaysNetworkUp = $8102
TCPIPSaysNetworkDown = $8103

*----------------------------------------------------
* Control/data blocks
*---------------------------------------------------- 
* Error table
tcpDGMSTBLEN = 120	;Length of table including this longword
tcpDGMSTOTAL = 4	;Total datagrams received (good and bad)

tcpDGMSFRAGSIN = 8	;Got a fragment (datagram is queued to frag list)
tcpDGMSFRAGSLOST = 12	;Fragment purged after timeout in queue
tcpDGMSBUILT = 16	;Built a datagram from fragments (is then queued)

tcpDGMSOK = 20	;datagrams queued from link *OR* tcpDGMSBUILT

tcpDGMSBADCHK = 24	;Bad IP checksum (datagram is purged)
tcpDGMSBADHEADLEN = 28 ;Bad IP header lengths (datagram is purged)
tcpDGMSBADPROTO = 32	;Unsupported protocols (added to misc queue)
tcpDGMSBADIP = 36	;Not my or loopback IP (datagram is purged)

tcpDGMSICMP = 40	;ICMP total datagrams in (good and bad)
tcpDGMSICMPUSER = 44	;ICMP user datagrams
tcpDGMSICMPKERNEL	= 48 ;ICMP kernel datagrams
tcpDGMSICMPBAD = 52	;ICMP bad checksum or datagram too short
tcpDGMSICMPBADTYPE = 56	;ICMP bad ic_type
tcpDGMSICMPBADCODE = 60	;ICMP bad ic_code
tcpDGMSICMPECHORQ = 64	;ICMP ECHORQs in
tcpDGMSICMPECHORQOUT = 68	;ICMP ECHORQ replies sent out
tcpDGMSICMPECHORP = 72	;ICMP ECHORPs in
tcpDGMSICMPECHORPBADID = 76	;ICMP ECHORPs unclaimed

tcpDGMSUDP = 80	;UDPs OK (added to UDP queue)
tcpDGMSUDPBAD = 84	;Bad UDP header (datagram is purged)
tcpDGMSUDPNOPORT = 88	;No such logged in port (datagram is purged)

tcpDGMSTCP = 92	;TCPs OK (returned to TCP main logic)
tcpDGMSTCPBAD = 96	;Bad TCP header or checksum (datagram is purged)
tcpDGMSTCPNOPORT = 100	;No such logged in port (datagram is purged)
tcpDGMSTCPQUEUED = 104	;Arrived before required (datagram is queued)
tcpDGMSTCPOLD = 108	;Already received this segment (datagram is purged)

tcpDGMSOFRAGMENTS	= 112	;Fragments transmitted
tcpDGMSFRAGMENTED	= 116	;Datagrams fragmented for transmission

tcpPKTSLEN = 120	;Length of error table in bytes

* TCPIPReadTCP response buffer
rrBuffCount = 0
rrBuffHandle = 4
rrMoreFlag = 8
rrPushFlag = 10
rrUrgentFlag = 12
rrlen = 14

* TCPIPReadLineTCP response buffer
rlrBuffCount = 0
rlrBuffHandle = 4
rlrIsDataFlag = 8
rlrMoreFlag = 10
rlrBuffSize = 12
rlrlen = 16

*TCPIPStatusTCP response buffer
srState = 0
srNetworkError = 2
srSndQueued = 4
srRcvQueued = 8
srDestIP = 12
srDestPort = 16
srConnectType = 18
srAcceptCount = 20
srlen = 22

* TCPIPStatusUDP
uvQueueSize = 0
uvError = 2
uvErrorTick = 4
uvCount = 8
uvTotalCount = 12	;same as tcpDGMSUDP
uvDispatchFlag = 16
uvlen = 18

* TCPIPGetDestination
drUserID = 0
drDestIP = 2
drDestPort = 6
drlen = 8

* TCPIPConvertIPToHex
cvtIPAddress = 0
cvtPort = 4

* Link layer module info
liMethodID = 0		;Ethernet=1, PPP=3, SLIP=4
liName = 2		; length byte + 20 chars = 21 bytes
liVersion = 23
liFlags = 27
liFilename = 29	; length byte + 15 chars
liMenuItem = 45	;rMenuItem template
lilen = 64

* IPC records
inwLength = 0
inwIP = 2
inwMethod = 6
inwMTU = 8
inwLVPtr = 10
inwlen = 14

* Module list record
rmiversion = 0
rmiItemID = 2
rmiChar = 4
rmiAltChar = 5
rmiCheck = 6
rmiFlag = 8
rmiTitleRef = 10

* DNR dsects
DNRstatus = 0
DNRname = 2
DNRIPaddress = 2

*-------------------------------------------------
* Miscellaneous datagram header equates
*-------------------------------------------------
* ICMP types - TCP_TYPE - Comer/Steven, vol II, p128

ICT_ECHORP = 0
ICT_DESTUR = 3
ICT_SRCQ = 4
ICT_REDIRECT = 5
ICT_ECHORQ = 8
ICT_TIMEX = 11
ICT_PARAMP = 12
ICT_TIMERQ = 13
ICT_TIMERP = 14
ICT_INFORQ = 15
ICT_INFORP = 16
ICT_MASKRQ = 17
ICT_MASKRP = 18
ictmax = 19

ICC_NETUR = 0	;p128, Internetworking with TCP/IP Vol 2.
ICC_HOSTUR = 1	;      Design Implementation, and Internals
ICC_PROTOUR = 2	;      Douglas E. Comer / David L. Stevens
ICC_PORTUR = 3
ICC_FNADF = 4
ICC_SRCRT = 5
ICC_NETRD = 0
ICC_HOSTRD = 1
IC_TOSNRD = 2
IC_TOSHRD = 3
ICC_TIMEX = 0
ICC_FTIMEX = 1
IC_HLEN = 8
IC_PADLEN = 3
IC_RDTTL = 300

* UDP standard port numbers
UP_ECHO = 7	;echo server
UP_DISCARD = 9	;discard packet
UP_USERS = 11	;users server
UP_DAYTIME = 13	;day and time server
UP_QOTD = 17	;quote of the day server
UP_CHARGEN = 19	;character generator
UP_TIME = 37	;time server
UP_WHOIS = 43	;who is server (user information)
UP_DNAME = 53	;domain name server
UP_TFTP = 69	;trivial file transfer protocol server
UP_RWHO = 513	;remote who server (ruptime)
UP_RIP = 520	;route information exchange (RIP)

* IP header
ip_verlen = 0
ip_tos = 1
ip_len = 2
ip_id = 4
ip_fragoff = 6
ip_ttl = 8
ip_proto = 9	;protocol*
ip_cksum = 10
ip_src = 12
ip_dst = 16
ip_data = 20

* ICMP header
ic_type = 0	;ICT_*
ic_code = 1	;ICC_*
ic_cksum = 2
ic_data = 4
* Echo Offsets
ic_echo_id = 4
ic_echo_seq = 6

* UDP header
u_source = 0	;source UDP port number - UP_*
u_dst = 2	;destination UDP port number
u_len = 4	;length of UDP data
u_cksum = 6	;UDP checksum (0 = none)
u_data = 8

* TCP header
tcp_sport = 0	;source port - TCP_*
tcp_dport = 2	;destination port
tcp_seq = 4	;sequence number
tcp_ack = 8	;acknowledgement number
tcp_offset = 12	;longword count in header (def=6)
tcp_code = 13	;flags
tcp_window = 14	;window advertisement
tcp_cksum = 16	;checksum
tcp_urgptr = 18	;urgent pointer
tcp_options = 20
tcp_data = 20
