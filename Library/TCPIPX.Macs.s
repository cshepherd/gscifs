* Marinetti 2.0 internal tool macros
*   by Richard Bennett - 5th August 1998

]tcpiptoolnum = $36

~TCPIPSetMyIPAddress MAC
 PHL ]1
_TCPIPSetMyIPAddress MAC
 LDX #$3800+]tcpiptoolnum
 JSL $E10000
 <<<
~TCPIPGetDP MAC
 PHA
_TCPIPGetDP MAC
 LDX #$3900+]tcpiptoolnum
 JSL $E10000
 <<<
~TCPIPGetDebugHex MAC
 PHA
_TCPIPGetDebugHex MAC
 LDX #$3A00+]tcpiptoolnum
 JSL $E10000
 <<<
~TCPIPSetDebugHex MAC
 PHW ]1
_TCPIPSetDebugHex MAC
 LDX #$3B00+]tcpiptoolnum
 JSL $E10000
 <<<
~TCPIPGetDebugTCP MAC
 PHA
_TCPIPGetDebugTCP MAC
 LDX #$3C00+]tcpiptoolnum
 JSL $E10000
 <<<
~TCPIPSetDebugTCP MAC
 PHW ]1
_TCPIPSetDebugTCP MAC
 LDX #$3D00+]tcpiptoolnum
 JSL $E10000
 <<<
~TCPIPGetUserRecord MAC
 P2SW ]1
_TCPIPGetUserRecord MAC
 LDX #$3E00+]tcpiptoolnum
 JSL $E10000
 <<<
~TCPIPReloadModuleList MAC
_TCPIPReloadModuleList MAC
 LDX #$4D00+]tcpiptoolnum
 JSL $E10000
 <<<
