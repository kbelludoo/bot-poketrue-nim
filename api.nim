import std/[asyncdispatch, httpclient, json, strutils, times, random]
import types

type
  PokeTrueClient* = ref object
    baseUrl*: string
    token*: string
    windowId*: string

proc generateWindowId(): string =
  let nowMs = (epochTime() * 1000).int64
  let r = rand(int.high)
  result = toHex(r, 8).toLowerAscii & toHex(nowMs, 12).toLowerAscii

proc newPokeTrueClient*(token: string, origin: string = ""): PokeTrueClient =
  new(result)
  var base = if origin.len > 0: origin else: "https://poketrue.net/api/"
  base = base.strip(chars = {'/'}) & "/api/"
  if not base.endsWith("/api/"):
    base = base & "api/"
  result.baseUrl = base
  result.token = token
  result.windowId = generateWindowId()

proc createHeaders(self: PokeTrueClient): HttpHeaders =
  result = newHttpHeaders([
    ("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"),
    ("Accept", "application/json"),
    ("Content-Type", "application/json"),
    ("sec-ch-ua", "\"Chromium\";v=\"128\", \"Not;A=Brand\";v=\"24\", \"Google Chrome\";v=\"128\""),
    ("sec-ch-ua-mobile", "?0"),
    ("sec-ch-ua-platform", "\"Windows\""),
    ("x-janela", self.windowId)
  ])
  if self.token.len > 0:
    result.add("Authorization", "Bearer " & self.token)

proc getState*(self: PokeTrueClient): Future[PokeTrueState] {.async.} =
  let client = newAsyncHttpClient()
  client.headers = self.createHeaders()
  defer: client.close()

  let url = self.baseUrl & "state"
  let resp = await client.get(url)
  if resp.code == Http200:
    let body = await resp.body
    let parsed = parseJson(body)
    var estado = parsed
    if parsed.hasKey("estado"): estado = parsed["estado"]

    result.playerName = estado{"nome"}.getStr(estado{"name"}.getStr("Treinador"))
    result.level = estado{"level"}.getInt(estado{"lvl"}.getInt(1))
    result.exp = estado{"exp"}.getBiggestInt(estado{"xp"}.getBiggestInt(0))
    result.gold = estado{"gold"}.getBiggestInt(0)
    result.currentHunt = estado{"currentHunt"}.getStr(estado{"hunt"}.getStr(""))

    if estado.hasKey("time") and estado["time"].kind == JArray:
      for poke in estado["time"]:
        result.team.add(Pokemon(
          uid: poke{"uid"}.getStr(""),
          speciesId: poke{"id"}.getInt(1),
          name: poke{"name"}.getStr(poke{"nome"}.getStr("Pokemon")),
          level: poke{"level"}.getInt(poke{"lvl"}.getInt(1)),
          hp: poke{"hp"}.getInt(100),
          maxHp: poke{"maxHp"}.getInt(poke{"totalHp"}.getInt(100))
        ))
  else:
    raise newException(IOError, "GET state failed with " & $resp.code)

proc startHunt*(self: PokeTrueClient, huntId: string): Future[bool] {.async.} =
  let client = newAsyncHttpClient()
  client.headers = self.createHeaders()
  defer: client.close()

  let url = self.baseUrl & "hunt/start"
  let payload = %*{"huntId": huntId}
  let resp = await client.post(url, $payload)
  result = (resp.code == Http200)

proc stopHunt*(self: PokeTrueClient): Future[bool] {.async.} =
  let client = newAsyncHttpClient()
  client.headers = self.createHeaders()
  defer: client.close()

  let url = self.baseUrl & "hunt/stop"
  let resp = await client.post(url, "{}")
  result = (resp.code == Http200)

proc healJenny*(self: PokeTrueClient): Future[bool] {.async.} =
  let client = newAsyncHttpClient()
  client.headers = self.createHeaders()
  defer: client.close()

  let url = self.baseUrl & "jenny/heal"
  let resp = await client.post(url, "{}")
  result = (resp.code == Http200)

proc claimTreino*(self: PokeTrueClient): Future[bool] {.async.} =
  let client = newAsyncHttpClient()
  client.headers = self.createHeaders()
  defer: client.close()

  let url = self.baseUrl & "treino/claim"
  let resp = await client.post(url, "{}")
  result = (resp.code == Http200)
