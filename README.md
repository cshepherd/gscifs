CIFS / SMB2 navel gazing, in 65816 assembly.

5/24/2015 - Current status: Connects on port 445, completes Protocol Negotiation, successfully sends login (on Setup_ANDX message), obsolete LM (DES) style password. sends successful Tree_ANDX message, thus connecting to a remote share.

Build 'CMD.S' with Merlin32 and the included Library directory.

Whatever, play along, but no apologies for lack of optimization and style yet. You'll see I don't dynamically allocate some things I should. At the moment I'm more interested in digging through tcpdumps and making things act right.

You'll see I'm just trying to copy the 'libtinysmb' portion of libogc from the Nintendo Wii because it's pretty easy to follow. It is in the 'reference' folder for you to check out. Also if you haven't yet, read all of http://www.ubiqx.org/cifs/SMB.html ... There, now you know exactly as much as me (probably more, I'm old and I forget things, I've probably forgotten it already).

Oh and we're only working with port 445 (naked SMB over TCP) at the moment. port 139 NBT is really not much harder, but at the moment is just another thing to do for potentially better compatibility(?)

As you can see, the hope here is to make 'SMBDEMO' S16 program connect to a CIFS server, mount a share, and maybe download a file. Only then do we worry about fancier things (breaking CIFS into its own library, making a FST, figuring out how much federal and state tax we owe on $2500).

I mostly only hack on weekends, but can test and merge all week long.

If this is not your style, fork it or start over, but at least try.

Oh and the .AppleDouble files are because I build to an AppleShare target. Then I boot up the IIGS and double-click to run it. Just think, someday we won't need that.

