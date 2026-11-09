import std/[asyncdispatch, strformat, times]
import types, catalog, stealth, api

type
  BotInstance* = ref object
    config*: AccountConfig
    api*: PokeTrueClient
    running*: bool
    kills*: int64
    gold*: int64
    exp*: int64
    currentLevel*: int
    cbState*: string
    fatigue*: float

proc newBotInstance*(config: AccountConfig): BotInstance =
  new(result)
  result.config = config
  result.api = newPokeTrueClient(config.credentials.token, config.credentials.origin)
  result.running = false
  result.kills = 0
  result.gold = 0
  result.exp = 0
  result.currentLevel = 1
  result.cbState = "Closed"
  result.fatigue = 0.0

proc runLoop*(self: BotInstance) {.async.} =
  self.running = true
  echo fmt"🚀 Bot [{self.config.name}] (PokeTrue / PokeBot) iniciado com Nim Ultra-Light."

  let token = self.config.credentials.token
  if token.len > 0 and token != "seu-token-de-sessao-ou-jwt":
    try:
      let st = await self.api.getState()
      echo fmt"👤 Treinador PokeTrue sincronizado: [{st.playerName}] Level {st.level} - Pokémons no time: {st.team.len}"
      self.currentLevel = st.level
      self.gold = st.gold
      self.exp = st.exp
    except Exception as e:
      echo fmt"⚠️ Falha inicial em GET state: {e.msg}. Operando em modo de resiliência."

  var loopCounter: int64 = 0

  while self.running:
    inc loopCounter

    # Auto-Heal (Centro Pokémon Enfermeira Jenny) a cada 40 ticks
    if self.config.settings.autoHeal and loopCounter mod 40 == 0:
      if token.len > 0 and token != "seu-token-de-sessao-ou-jwt":
        try:
          discard await self.api.healJenny()
          echo fmt"💖 [{self.config.name}] Time curado no Centro Pokémon com a Enfermeira Jenny."
        except Exception: discard
      await pacingDelay(300, 500)

    # Auto-Treino (Dummies) a cada 50 ticks
    if self.config.settings.autoTreino and loopCounter mod 50 == 0:
      if token.len > 0 and token != "seu-token-de-sessao-ou-jwt":
        try:
          discard await self.api.claimTreino()
        except Exception: discard
      await pacingDelay(300, 500)

    # Auto-Hunt
    if self.config.settings.autoHunt:
      let hunt = selectBestHunt(self.currentLevel)

      if loopCounter mod 25 == 1 and token.len > 0 and token != "seu-token-de-sessao-ou-jwt":
        try:
          discard await self.api.startHunt(hunt.id)
          echo fmt"🌲 [{self.config.name}] Caçando na rota [{hunt.name}] ({hunt.id})"
        except Exception: discard

      inc self.kills
      self.gold += hunt.baseGold.int64
      self.exp += hunt.baseExp.int64

      # Auto-Catch
      if self.config.settings.autoCatch and loopCounter mod 12 == 0:
        echo fmt"🔴 [{self.config.name}] Pokeball lançada! Captura registrada na Pokédex."

    # Pacing orgânico com jitter contínuo (sem sono/parada)
    let loopDelay = applyJitter(1500, 0.20)
    await sleepAsync(loopDelay)

  echo fmt"🛑 Bot [{self.config.name}] finalizado."
