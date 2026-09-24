# Contributing

## Workflow

1. Branch off `main`.
2. Keep each pull request focused on one change, with commits that explain why.
3. Build before pushing: `make MYSQL=0` on Linux, or `SphereSvr.vcxproj` on Windows.
4. Open a pull request. CI builds Linux and Windows, x86 and x64, and every build must pass.

## Code style

- Match the surrounding code: tabs, the existing naming (`m_` members, Hungarian prefixes), and
  the file's line endings. Do not reformat code you are not changing.
- Code and comments are in English. Keep comments short and only where the code is not obvious.
- New code must not add compiler warnings. Keep third-party code in `third_party/` unmodified
  unless there is no other way, and note any change in `third_party/README.md`.
- Keep behaviour compatible with the Legacy script pack and save files.

## Adding a source file

List it in both `Makefile` (`SRC`) and `SphereSvr.vcxproj` (`ClCompile`).

## Reporting bugs

Open an issue with the server version (shown on startup), the platform, and the steps or script
that reproduce the problem.
