# ffxiv-ce Documentation

## Constants

- `ffxiv.image_base: number`: constant, `0x140000000`
- `ffxiv.executable: string`: constant, `ffxiv_dx11.exe`
- `ffxiv.rev: number`: the revision number of the game executable
- `ffxiv.cache_file: string`: path to the cache file

## Address

- `ffxiv.addr.addr_to_ce(addr: number): string`: convert an address to a Cheat Engine address string
- `ffxiv.addr.get_modules(): Module`: get a list of modules, modified results of `enumModules` from the cheat engine API
- `ffxiv.addr.get_module_by_name(name: string): Module | nil`: get a module by its name
- `ffxiv.addr.resides_in_range(addr: number, start: number, size: number): boolean`: check if a given address resides in a range, given its address and size
- `ffxiv.addr.scan_text(sig: string): number | nil`: scan for a signature
  - unsure if this is actually scanning `.text` or if i'm stupid
  - resolves `jmp`/`call` signatures

## Assembly

note: `instruction_count` in `pad_nop` and `restore_backup` refers to the amount of assembly instructions (each line in IDA's disassembler view) instead of the amount of bytes they take up.

- `ffxiv.asm.pad_nop(addr: number, instruction_count: number)`: pad an address with NOPs
- `ffxiv.asm.restore_backup(addr: number, instruction_count: number)`: restore an address padded with NOPs to its original contents

## Utils

- `ffxiv.utils.get_alloc_base(): number`: get the address of the executable in memory
- `ffxiv.utils.get_rev(): number`: get the revision number, prefer using the `ffxiv.rev` constant instead

## Cache

- `ffxiv.load_cache()`: load the cache state from `cache.json`
- `ffxiv.save_cache()`: write the cache state to `cache.json`
- `ffxiv.reset_cache()`: reset the cache state and overwrite `cache.json` with empty contents

## Misc

- `ffxiv.json`: a copy of [rxi's json.lua](https://github.com/rxi/json.lua)
- `ffxiv.ce`: internal wrappers around Cheat Engine functions for type hints
- `ffxiv.init()`: called on load to set up some constants

## Types

### Module

A modified version of the type in Cheat Engine's `enumModules()`.

- `name: string`: the name of the module
- `base: number`: the base address of the module
- `size: number`: the size of the module (may be zero for unknown)
