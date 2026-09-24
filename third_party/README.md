# Third-party code

Libraries bundled with the server. They are built as part of it, their warnings are silenced, and
they are kept as shipped apart from the local changes noted below.

| Directory | Library | Version | License |
| --- | --- | --- | --- |
| `zlib` | [zlib](https://zlib.net) | 1.2.5 | zlib |
| `libev` | [libev](http://software.schmorp.de/pkg/libev.html), Linux event loop | 4.1 | BSD-2-Clause |
| `twofish` | Twofish optimized reference implementation, used by the login encryption | 1.00 | See header |
| `deelx` | [DEELX](http://www.regexlab.com/deelx/) regular expression engine | 1.2 | See header |
| `mtrand` | Mersenne Twister random number generator (`MTRand`) | - | BSD-3-Clause |

Local changes:

- `libev` only keeps the backends Linux uses (`epoll`, `poll`, `select`). `wrapper_ev.c` silences
  its warnings and includes `ev.c`.
- `twofish` uses its own fixed width word types, so the 64-bit build produces the same keystream
  as 32-bit.
