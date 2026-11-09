import std/[json, strutils]
import types

const HuntsRaw = staticRead("data/hunts.json")

var gHunts: seq[AreaCandidate]

proc loadCatalog*() =
  if gHunts.len > 0: return
  try:
    let parsed = parseJson(HuntsRaw)
    if parsed.kind == JArray:
      for item in parsed:
        var id = item{"slug"}.getStr("")
        if id.len == 0: id = item{"id"}.getStr("")
        var name = item{"nome"}.getStr(id)
        if name.len == 0: name = item{"name"}.getStr(id)

        var minLvl = 1
        var maxLvl = 100
        if item.hasKey("nivel") and item["nivel"].kind == JArray and item["nivel"].len >= 2:
          minLvl = item["nivel"][0].getInt(1)
          maxLvl = item["nivel"][1].getInt(100)
        else:
          minLvl = item{"minLevel"}.getInt(1)
          maxLvl = item{"maxLevel"}.getInt(100)

        let killsPerHour = item{"killsPorHora"}.getFloat(item{"killsPorHora"}.getInt(100).toFloat)
        let baseGold = item{"baseGold"}.getFloat(item{"baseGold"}.getInt(50).toFloat)

        gHunts.add(AreaCandidate(
          id: id,
          name: name,
          minLevel: minLvl,
          maxLevel: maxLvl,
          baseExp: if killsPerHour > 0: killsPerHour else: 100.0,
          baseGold: if baseGold > 0: baseGold else: 50.0
        ))
  except Exception as e:
    echo "[Catalog] Erro ao carregar hunts.json: ", e.msg

  if gHunts.len == 0:
    gHunts.add(AreaCandidate(
      id: "mata_das_larvas",
      name: "Mata das Larvas",
      minLevel: 1,
      maxLevel: 30,
      baseExp: 250.0,
      baseGold: 120.0
    ))

proc getAllHunts*(): seq[AreaCandidate] =
  if gHunts.len == 0: loadCatalog()
  result = gHunts

proc selectBestHunt*(level: int): AreaCandidate =
  let hunts = getAllHunts()
  for h in hunts:
    if level >= h.minLevel and level <= h.maxLevel:
      return h
  result = hunts[0]
