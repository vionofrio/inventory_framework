# Tools

`python3 tools/check.py` (run from anywhere; needs only Python 3) verifies declaration order, `static` visibility, call arity,
macro order, the ownership and encapsulation rules, naming, forward declarations and style. See `docs/ARCHITECTURE.md`.

`pawnparse.py` is a small top-level Pawn parser; `pawncheck.py` resolves includes and checks declarations. Both are
approximations of the Pawn compiler for this codebase and do not check tags or types.
