# Anti-references philosophy

The single biggest reason AI-generated logos look like clip-art is that the prompt **didn't tell the model what to avoid**. Style references alone aren't enough — they push *toward* a vibe, but the model fills the gap with whatever stereotypes its training data associates with the country.

## The two failure modes

### 1. Tourist-shop kitsch
The model defaults to literal cultural clichés: horned helmets for Nordics, berets for France, beer steins for Germany. These never read as "premium brand" — they read as "souvenir keychain."

### 2. Politically loaded symbology
Some abstract geometric shapes carry hidden political baggage:
- **Valknut** (three interlocking triangles) — adopted by Norse-nationalist / far-right groups; avoid in any Nordic mark
- **Black sun / sonnenrad** — Nazi-era symbol still used by far-right groups
- **Othala rune** (ᛟ) — likewise appropriated, even though it's an authentic rune
- **Triskele variants** — some are heritage symbols, some are far-right; safer to avoid
- **Roman fasces** — Mussolini-era Italian fascist iconography
- **Celtic cross** in certain configurations — co-opted by white-supremacist groups
- **Black-and-red color combos with eagles** — Third Reich association

These all need to appear in your anti-reference list for the relevant country, *especially* for ad-driven sites where Facebook will flag and ban ads on brands that look adjacent to extremism.

## How to write strong anti-references

**Bad** (vague):
> No clichéd elements.

**Good** (specific, enumerated, naming the cliché):
> No horned helmets, no axes, no beards, no dragon prows, no shields, no blackletter, no valknut, no black-sun symbology.

The specificity is what makes the model actually avoid them. "Clichéd" is too abstract — the model interprets it as "don't make it too obvious" and still produces a horned helmet.

## How many anti-references is too many?

Past ~12 anti-references in a single prompt, GPT Image 2 starts ignoring the list (the negative weighting gets diluted). Prioritize the 6–10 worst offenders per country.

**Priority order:**
1. **Politically-loaded symbology** (always include — both ethical reason and FB-ads ban risk)
2. **Tourist-keychain icons** (the worst cliché per country)
3. **Literal landmarks** (Eiffel tower, Big Ben, Brandenburg gate, etc.)
4. **Food/drink stereotypes** (croissants, beer steins, pasta)
5. **Decorative artifacts** (blackletter, gothic ornament, shading, gradients)

## Country-by-country quick-reference

| Country | Top-priority anti-references |
|---|---|
| Sweden | horned helmet, axe, blackletter, valknut, black-sun |
| Norway | horned helmet, axe, troll, dragon prow, blackletter |
| Denmark | mermaid statue, Lego, hygge candle, literal Dannebrog cross |
| Finland | sauna, reindeer, Moomin, Santa, Nokia nostalgia |
| Germany | beer stein, lederhosen, swastika-adjacent symbology, Brandenburg gate literal, double-headed eagle (heraldic ambiguity) |
| France | beret, baguette, Eiffel tower, accordion, croissant |
| UK | bowler hat, Big Ben, telephone box, bulldog, Union Jack literal |
| Netherlands | wooden clog, tulip, literal windmill, cannabis leaf, orange football kit |
| Spain | bull, flamenco dancer, sangria, paella, sombrero |
| Italy | Colosseum literal, pizza slice, pasta, Vespa, fasces |
| Belgium | waffle, Tintin, beer, chocolate, French-fry cone |
| Portugal | port wine bottle, fado guitar, rooster of Barcelos, sardine |
| Ireland | shamrock, leprechaun, Guinness, harp literal, obvious tricolor |

## Why this matters for IPTV specifically

IPTV brands run **Facebook ads** as the primary acquisition channel. Facebook's ad review:

1. **Auto-flags imagery associated with extremism** (even loose associations — valknut, sonnenrad, gothic eagles)
2. **Has lower tolerance for "edgy" brand aesthetics** when the underlying product is in a sensitive vertical (IPTV is gray-market in most markets)

A logo that's even adjacent to nationalist symbology can get the ad account banned. The anti-references list isn't just aesthetic — it's a compliance gate.
