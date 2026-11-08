Line width: 120.
Indentation style: spaces.
Indentation width: 4.
Braces: always, and always on a new line.
Always use parentheses with the `sizeof` operator and similar ones. (for example: `size = sizeof output` -> `size = sizeof(output)`)

And, in general, follow exactly this same model:
```
// Constants and macros in "UPPER_CASE", with underscores separating words.
#define MAX_TAXIS (32)

const INVALID_TAXI_ID = -1;

// enums are constants, with `e_` or `E_` prefix depending on tag strength (see pawn-lang.pdf).
enum e_TAXI_FLAGS
{
  e_TAXI_FLAG_OCCUPIED,
  e_TAXI_FLAG_EMPTY,
  e_TAXI_FLAG_BILKED,
}

// Strongly tagged enum.
enum E_TAXI_DATA
// "Allman" braces (always on a new line).
{
  e_TAXI_FLAGS:E_TAXI_DATA_FLAGS,
  // Tags are "Camel Case", with the first letter determined by tag strength rules.  However,
  // since tags are always followed by a colon, this is always unambiguous.
  Float:E_TAXI_DATA_X,
  Float:E_TAXI_DATA_Y,
  Float:E_TAXI_DATA_Z
}

// Globals `static` as much as possible to prevent complex inter-module dependencies.
static
  // Globals `g` prefixed and camel case.
  gTaxiData[MAX_TAXIS][E_TAXI_DATA];

// Functions in "PascalCase" (aka "UpperCamelCase") - all words start with an upper-case letter.
Taxi_HasPassenger(taxi, playerid)
{
  // Tab indentation, set to 4 spaces (pawno intermixes tabs and 4 spaces).

  // Single declaration for multiple variables, with each on a new indented line.
  new
    // Variables/parameters in "lowerCamelCase" - as above, except the first word.
    playerCount = GetMaxPlayers(),

    // Module names come first before an underscore.
    passenger = Taxi_GetCurrentPassenger(taxi);

  if (0 <= playerid < playerCount && passenger == playerid)
  {
    // Braces even for single statements.
    goto found_the_player;
  }

// Pre-processor directives use separate indentation level tracking.
#if MAX_PLAYERS < 100
  #if MAX_TAXIS > 100
    return Taxi_HasPassenger(playerid, taxi);
  #else
    return false;
  #endif
#else
  return false;
#endif

// Labels in `lower_snake_case:`, and at column 0.
found_the_player:

  // `return`s always have a new blank line above them, unless there is a `{` above.
  return true;
}
```

Also keep architectural consistency: if something was done one way before, do the next similar situation the same way.

The architectural rules of this repository (module ownership, naming, ownership writes) are in `ARCHITECTURE.md`;
`tools/check.py` enforces the mechanical ones.
