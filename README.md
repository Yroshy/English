# OneText — Inglês com um único texto por semana

App de iOS (SwiftUI) para estudar inglês seguindo a metodologia da professora
**Vânia Sausen**: um único texto curto, explorado em profundidade ao longo de
7 dias, trabalhando leitura, vocabulário (chunks/collocations), listening,
gramática, escrita, fala e revisão — sem sobrecarregar os estudos.

Por cima da metodologia, o app tem uma camada de gamificação estilo
Duolingo: missão diária, sequência (streak) e XP.

O foco inicial, conforme pedido, é gerar **textos curtos de rotina do dia a
dia** (manhã, trajeto para o trabalho, dia de trabalho, compras, cozinhar,
fim de semana, academia etc.), calibrados para os 6 níveis do CEFR
(A1, A2, B1, B2, C1, C2), com um pouco mais de detalhamento — não apenas
frases soltas.

## O cronograma semanal (implementado como 7 telas de missão)

| Dia | Foco | Tela |
|---|---|---|
| Segunda | Leitura, interpretação e 5 chunks novos | `MondayReadingView` |
| Terça | Collocations de cada chunk | `TuesdayCollocationsView` |
| Quarta | Listening + Shadowing (frase por frase) | `WednesdayListeningView` |
| Quinta | Gramática em contexto | `ThursdayGrammarView` |
| Sexta | Produção escrita + correção | `FridayWritingView` |
| Sábado | Prática de fala (gravação) | `SaturdaySpeakingView` |
| Domingo | Revisão ativa / reescrita de memória | `SundayReviewView` |

Cada dia concluído dá XP e mantém a sequência (streak), como no Duolingo.
Ao concluir os 7 dias, o app já oferece gerar o texto da próxima semana.

## Como os textos são gerados

- **Sem chave de API**: o app funciona 100% offline com um banco de textos
  pré-escritos à mão, um por nível CEFR (A1 a C2), cada um já com as 5
  perguntas/chunks/collocations/pontos de gramática necessários para os 7
  dias (`Content/LocalContentBank.swift`).
- **Com chave de API da Anthropic** (configurável em Ajustes → chave fica só
  no Keychain do aparelho): o app gera **textos novos ilimitados** sobre
  rotinas do dia a dia, calibrados ao nível escolhido, além de gerar mais
  collocations sob demanda e corrigir a produção escrita de sexta-feira
  (`Content/ClaudeContentGenerator.swift`). Sem chave configurada, essas
  duas últimas funções mostram um aviso e o app continua funcionando com o
  conteúdo offline.

Essa separação (`ContentGenerating` protocol com duas implementações) foi
proposital: o app já nasce utilizável sem nenhuma configuração, e ganha
geração ilimitada de texto assim que o usuário adicionar sua própria chave.

## Estrutura do projeto

```
OneText/
  project.yml                 # config do XcodeGen (gera o .xcodeproj)
  OneText/
    App/                      # entry point (@main)
    Models/                   # CEFRLevel, StudyDay, WeeklyText, UserProgress
    Content/                  # geração de conteúdo (local + IA)
    Services/                 # persistência, Keychain, TTS, gravação de áudio
    ViewModels/                # HomeViewModel
    Views/
      Onboarding/              # escolha de nível CEFR
      Home/                    # dashboard semanal + streak/XP
      DayMissions/              # as 7 telas do cronograma
      Settings/                # chave de API, progresso
      Components/               # peças reutilizáveis de UI
    Resources/                 # Info.plist, Assets.xcassets
```

## Como abrir e rodar (em um Mac com Xcode)

Este projeto usa [XcodeGen](https://github.com/yonaskolb/XcodeGen) para gerar
o `.xcodeproj` a partir de `project.yml` — evita conflitos de merge no
arquivo `.pbxproj` e mantém o projeto fácil de versionar.

```bash
brew install xcodegen
cd OneText
xcodegen generate
open OneText.xcodeproj
```

No Xcode: selecione um simulador de iPhone (iOS 16+), Cmd+R para rodar.

Nenhuma dependência externa (SPM) é necessária — as chamadas à API da
Anthropic usam `URLSession` diretamente.

### Configurar a IA (opcional)

1. Rode o app, abra **Ajustes** (ícone de engrenagem).
2. Cole sua chave de API da Anthropic (formato `sk-ant-...`).
3. A partir daí, novos textos da semana, collocations extras e correções de
   escrita passam a ser gerados dinamicamente.

## Status / próximos passos sugeridos

Este é o MVP funcional da metodologia completa com 1 texto por nível já
incluído offline, gamificação básica (streak + XP) e o gerador de IA
plugável. Não foi possível compilar/rodar no simulador iOS neste ambiente
(sessão em container Linux, sem Xcode) — o código foi revisado
cuidadosamente à mão, mas recomenda-se abrir no Xcode e testar antes de
considerar pronto para uso real. Sugestões de evolução:

- Mais tópicos de rotina no banco offline (hoje há 1 por nível; o gerador de
  IA cobre o resto).
- Notificações locais para lembrete da missão diária.
- Histórico/revisão das semanas concluídas (os dados já são salvos em
  `UserProgress.completedWeeks`, falta só a tela).
- Reconhecimento de fala (Speech framework) para dar feedback automático de
  pronúncia no sábado, hoje é autoavaliação por gravação/playback.
