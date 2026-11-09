# bot-poketrue-nim ⚡

Automação autônoma nativa para **PokeTrue / PokeBot** reescrita 100% em **Nim 2.2** com modelo de gerenciamento de memória ORC (`--mm:orc`), zero overhead de Garbage Collector e ultra-baixo consumo de memória RAM.

## 🚀 Destaques da Arquitetura Nim
- **100% Paridade de Heurística e Métricas**: Compatível com as métricas JSON de telemetria expostas na porta padrão (`3014`) sob `/api/status`.
- **Motor Anti-Detecção com Pacing e Jitter Orgânico**: Variação randômica de $\pm 20\%$ nos intervalos de caça e ações para evitar assinaturas temporais determinísticas.
- **Operação 24/7 Contínua sem Pausas Forçadas**: Otimizado para jogabilidade de idle contínua.
- **Suporte Nativo a Multi-Contas**: Gerencia múltiplas contas simultâneas em corrotinas assíncronas assíncronas com `std/asyncdispatch`.
- **Consumo de Memória Extremamente Reduzido**: Binário estático e compacto compilado via Zig toolchain.

## 📦 Compilação
```bash
nim c --os:linux --cpu:amd64 --gcc.exe:zigcc-linux-gnu.bat --gcc.linkerexe:zigcc-linux-gnu.bat -d:ssl -d:release -o:bot-poketrue-linux-nim main.nim
```

## ⚙️ Configuração
Copie `accounts.example.json` para `accounts.json` e insira as credenciais do seu treinador:
```json
[
  {
    "id": "acc-1",
    "name": "Personagem Principal",
    "enabled": true,
    "credentials": {
      "token": "seu-token-de-sessao-ou-jwt",
      "email": "user@exemplo.com",
      "password": "senha-segura",
      "origin": "https://poketrue.net"
    },
    "settings": {
      "hunt_target": "floresta_de_viridian",
      "auto_hunt": true,
      "auto_sell": true,
      "auto_heal": true,
      "auto_daily": true,
      "auto_treino": true,
      "auto_catch": true
    }
  }
]
```
