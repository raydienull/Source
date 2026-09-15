# Documentation

Reference material inherited from the SphereServer 0.5x series. Most of it predates this fork and
describes the server as upstream left it; the build and 64-bit notes live in the top level
[README](../README.md).

## Scripting

| File | Contents |
| --- | --- |
| [MANUAL.TXT](MANUAL.TXT) | Script objects and properties added in 0.5x (`FILE`, `DB`, and others) |
| [REVISIONS-51-54-SERIES.TXT](REVISIONS-51-54-SERIES.TXT) | Upstream changelog, 0.51 to 0.54 |
| [REVISIONS-55-SERIES.TXT](REVISIONS-55-SERIES.TXT) | Upstream changelog, 0.55 |
| [REVISIONS-56-SERIES.TXT](REVISIONS-56-SERIES.TXT) | Upstream changelog, 0.56 up to 0.56b |
| [precompiler.txt](precompiler.txt) | Experimental compile-time switches and the script tags they enable |
| [SpeechKeywords.txt](SpeechKeywords.txt) | Speech keyword ids sent by the client, as dumped from `speech.mul` |
| [sounds.txt](sounds.txt) | Sound ids with descriptions (incomplete) |

## Known issues

| File | Contents |
| --- | --- |
| [KNOWNBUGS.txt](KNOWNBUGS.txt) | Issues upstream documented as known and not to be reported |
| [TODO.txt](TODO.txt) | Upstream's open bug, change request and feature list as of 0.56b |

## Protocol

| File | Contents |
| --- | --- |
| [packets/supported_packets.htm](packets/supported_packets.htm) | Packets the server handles |
| [packets/detailed_packets.htm](packets/detailed_packets.htm) | Packet reference with field layouts |
| [packets/all_packets--ml_update.doc](packets/all_packets--ml_update.doc) | Packet reference updated for Mondain's Legacy |
| [packets/JUOPackets.doc](packets/JUOPackets.doc) | JUO packet reference |
| [packets/kairpacketguide.zip](packets/kairpacketguide.zip), [packets/wphackersguide.zip](packets/wphackersguide.zip) | Older community packet guides |
| [packets/df_packet.txt](packets/df_packet.txt) | Captures of the `0xDF` buff/debuff packet |
| [new_tooltips_info.txt](new_tooltips_info.txt) | How newer clients request tooltips with `0xD6` and `0xDC` |

The packet structures the server actually uses are defined in `src/network` and
`src/graysvr/grayproto.h`, which take precedence over these documents where they differ.
