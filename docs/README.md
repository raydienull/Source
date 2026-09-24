# Documentation

Reference material inherited from the SphereServer 0.5x series. It describes the server as upstream
left it. Build and setup instructions are in the top level [README](../README.md).

## Scripting

| File | Contents |
| --- | --- |
| [scripting/manual.txt](scripting/manual.txt) | Script objects and properties added in 0.5x (`FILE`, `DB` and others) |
| [scripting/precompiler.txt](scripting/precompiler.txt) | Experimental compile-time switches and the script tags they enable |
| [scripting/speech-keywords.txt](scripting/speech-keywords.txt) | Speech keyword ids sent by the client, dumped from `speech.mul` |
| [scripting/sounds.txt](scripting/sounds.txt) | Sound ids with descriptions (incomplete) |

## Protocol

| File | Contents |
| --- | --- |
| [protocol/supported_packets.htm](protocol/supported_packets.htm) | Packets the server handles |
| [protocol/detailed_packets.htm](protocol/detailed_packets.htm) | Packet reference with field layouts |
| [protocol/all_packets--ml_update.doc](protocol/all_packets--ml_update.doc) | Packet reference updated for Mondain's Legacy |
| [protocol/JUOPackets.doc](protocol/JUOPackets.doc) | JUO packet reference |
| [protocol/kairpacketguide.zip](protocol/kairpacketguide.zip), [protocol/wphackersguide.zip](protocol/wphackersguide.zip) | Older community packet guides |
| [protocol/df_packet.txt](protocol/df_packet.txt) | Captures of the `0xDF` buff/debuff packet |
| [protocol/tooltips.txt](protocol/tooltips.txt) | How newer clients request tooltips with `0xD6` and `0xDC` |

The packet structures the server actually uses live in `src/network` and
`src/common/grayproto.h`, and take precedence over these documents where they differ.

## History

| File | Contents |
| --- | --- |
| [history/revisions-0.51-0.54.txt](history/revisions-0.51-0.54.txt) | Upstream changelog, 0.51 to 0.54 |
| [history/revisions-0.55.txt](history/revisions-0.55.txt) | Upstream changelog, 0.55 |
| [history/revisions-0.56.txt](history/revisions-0.56.txt) | Upstream changelog, 0.56 up to 0.56b |
| [history/known-bugs.txt](history/known-bugs.txt) | Issues upstream documented as known |
| [history/todo.txt](history/todo.txt) | Upstream's open bug and feature list as of 0.56b |

Changes made in this fork are listed in the [releases](../../../releases) and the git history.
