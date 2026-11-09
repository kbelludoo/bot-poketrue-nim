import std/[json, options]

type
  GameCredentials* = object
    token*: string
    email*: string
    password*: string
    origin*: string

  GameSettings* = object
    huntTarget*: string
    autoHunt*: bool
    autoSell*: bool
    autoHeal*: bool
    autoDaily*: bool
    autoCatch*: bool
    autoTreino*: bool
    autoEquip*: bool
    autoEvo*: bool
    autoBoss*: bool
    focusBestiary*: bool
    ballType*: Option[string]
    healThreshold*: Option[float]

  AccountConfig* = object
    id*: string
    name*: string
    enabled*: bool
    credentials*: GameCredentials
    settings*: GameSettings
    bindIP*: Option[string]

  Pokemon* = object
    uid*: string
    speciesId*: int
    name*: string
    level*: int
    hp*: int
    maxHp*: int
    heldItem*: Option[string]

  PokeTrueState* = object
    playerName*: string
    level*: int
    exp*: int64
    gold*: int64
    team*: seq[Pokemon]
    currentHunt*: string

  AreaCandidate* = object
    id*: string
    name*: string
    minLevel*: int
    maxLevel*: int
    baseExp*: float
    baseGold*: float

  AccountStatus* = object
    id*: string
    name*: string
    running*: bool
    kills*: int64
    gold*: int64
    exp*: int64
    cbState*: string
    fatigue*: float

proc parseCredentials(node: JsonNode): GameCredentials =
  if node != nil:
    result.token = node{"token"}.getStr("")
    result.email = node{"email"}.getStr("")
    result.password = node{"password"}.getStr("")
    result.origin = node{"origin"}.getStr("")

proc parseSettings(node: JsonNode): GameSettings =
  result.huntTarget = ""
  result.autoHunt = true
  result.autoSell = true
  result.autoHeal = true
  result.autoDaily = true
  result.autoCatch = true
  result.autoTreino = true
  result.autoEquip = true
  result.autoEvo = true
  result.autoBoss = true
  result.focusBestiary = true
  if node != nil:
    if node.hasKey("huntTarget"): result.huntTarget = node["huntTarget"].getStr("")
    elif node.hasKey("hunt_target"): result.huntTarget = node["hunt_target"].getStr("")

    if node.hasKey("autoHunt"): result.autoHunt = node["autoHunt"].getBool(true)
    elif node.hasKey("auto_hunt"): result.autoHunt = node["auto_hunt"].getBool(true)

    if node.hasKey("autoSell"): result.autoSell = node["autoSell"].getBool(true)
    elif node.hasKey("auto_sell"): result.autoSell = node["auto_sell"].getBool(true)

    if node.hasKey("autoHeal"): result.autoHeal = node["autoHeal"].getBool(true)
    elif node.hasKey("auto_heal"): result.autoHeal = node["auto_heal"].getBool(true)

    if node.hasKey("autoDaily"): result.autoDaily = node["autoDaily"].getBool(true)
    elif node.hasKey("auto_daily"): result.autoDaily = node["auto_daily"].getBool(true)

    if node.hasKey("autoCatch"): result.autoCatch = node["autoCatch"].getBool(true)
    elif node.hasKey("auto_catch"): result.autoCatch = node["auto_catch"].getBool(true)

    if node.hasKey("autoTreino"): result.autoTreino = node["autoTreino"].getBool(true)
    elif node.hasKey("auto_treino"): result.autoTreino = node["auto_treino"].getBool(true)

    if node.hasKey("autoEquip"): result.autoEquip = node["autoEquip"].getBool(true)
    elif node.hasKey("auto_equip"): result.autoEquip = node["auto_equip"].getBool(true)

    if node.hasKey("autoEvo"): result.autoEvo = node["autoEvo"].getBool(true)
    elif node.hasKey("auto_evo"): result.autoEvo = node["auto_evo"].getBool(true)

    if node.hasKey("autoBoss"): result.autoBoss = node["autoBoss"].getBool(true)
    elif node.hasKey("auto_boss"): result.autoBoss = node["auto_boss"].getBool(true)

    if node.hasKey("focusBestiary"): result.focusBestiary = node["focusBestiary"].getBool(true)
    elif node.hasKey("focus_bestiary"): result.focusBestiary = node["focus_bestiary"].getBool(true)

proc parseAccountConfig*(node: JsonNode): AccountConfig =
  result.id = node{"id"}.getStr("")
  result.name = node{"name"}.getStr(result.id)
  result.enabled = node{"enabled"}.getBool(true)
  result.credentials = parseCredentials(node{"credentials"})
  result.settings = parseSettings(node{"settings"})
  if node.hasKey("bindIP"):
    result.bindIP = some(node["bindIP"].getStr(""))
