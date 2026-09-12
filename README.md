# OneText — Inglês com um único texto por semana

App de iOS (SwiftUI) para estudar inglês seguindo a metodologia da professora
**Vânia Sausen**: um único texto curto, explorado em profundidade ao longo de
7 dias, trabalhando leitura, vocabulário (chunks/collocations), listening,
gramática, escrita, fala e revisão — sem sobrecarregar os estudos.

Por cima da metodologia, o app tem uma camada de gamificação estilo
Duolingo: missão diária, sequência (streak) e XP.

## Duas versões

- **`OneText/`** — app nativo iOS em SwiftUI (veja "Como testar o app" abaixo). Exige um Mac com Xcode para compilar.
- **`web/index.html`** — a mesma metodologia como um app web mobile-first (HTML/CSS/JS puro, sem build), pensado para testar direto no iPhone (Safari) ou no navegador do Windows, sem precisar de Mac nem Xcode. Progresso, XP, streak e cartões de revisão ficam salvos no `localStorage` do navegador (por aparelho — não sincroniza entre iPhone e Windows). **Importante:** teste pelo link do GitHub Pages (veja abaixo), não pela pré-visualização de artifact do Claude — essa pré-visualização roda numa janela embutida cujo armazenamento pode não persistir entre sessões, o que parece "o progresso não salva" mas é uma limitação da pré-visualização, não do app. A geração de texto por IA também só funciona fora dela.

  Este repositório já publica `web/index.html` automaticamente no GitHub Pages a cada push nesta branch (`.github/workflows/deploy-pages.yml`). Só falta um passo único, feito uma vez pela interface do GitHub (não dá para automatizar): em **Settings → Pages**, em "Build and deployment", mude **Source** para **"GitHub Actions"** e salve. Depois disso a URL do Pages (mostrada nessa mesma página, algo como `https://yroshy.github.io/English/`) sempre serve a versão mais recente — e aí sim o progresso persiste normalmente, como em qualquer site.

O foco inicial, conforme pedido, é gerar **textos curtos de rotina do dia a
dia** (manhã, trajeto para o trabalho, dia de trabalho, compras, cozinhar,
fim de semana, academia etc.), calibrados para os 6 níveis do CEFR
(A1, A2, B1, B2, C1, C2), com um pouco mais de detalhamento — não apenas
frases soltas.

## O cronograma semanal (implementado como 7 telas de missão)

| Dia | Foco | Tela |
|---|---|---|
| Segunda | Leitura, interpretação e 5 chunks novos | `MondayReadingView` |
| Terça | Collocations de cada chunk + 1 contexto de aplicação novo por chunk | `TuesdayCollocationsView` |
| Quarta | Listening + Shadowing (frase por frase) | `WednesdayListeningView` |
| Quinta | Gramática em contexto | `ThursdayGrammarView` |
| Sexta | Produção escrita + correção | `FridayWritingView` |
| Sábado | Prática de fala (gravação) | `SaturdaySpeakingView` |
| Domingo | Revisão ativa / reescrita de memória | `SundayReviewView` |

Cada dia concluído dá XP e mantém a sequência (streak), como no Duolingo.
Ao concluir os 7 dias, o app já oferece gerar o texto da próxima semana.

Na Terça, além das ~3 collocations de cada um dos 5 chunks, cada chunk também
traz um **contexto de aplicação**: uma frase nova (não tirada do texto da
semana) que usa uma das collocations em outra situação do dia a dia — é o
reforço extra pedido, para fixar a expressão além da única ocorrência dela no
texto original.

## Revisão espaçada (aba "Revisão")

Uma segunda aba, separada da semana atual, implementa repetição espaçada
(spaced repetition) no estilo Anki/Duolingo:

- Assim que a missão de **Segunda-feira** de uma semana é concluída, os 5
  chunks daquele texto viram **cartões de revisão** (`ReviewCard`) — isso
  acontece toda semana, então o pool de cartões cresce e inclui expressões de
  **todos os textos já estudados**, não só o da semana atual.
- Cada cartão é um "cloze": mostra a frase original do texto **com a
  expressão em branco** (ex.: "She ▁▁▁▁▁ and goes to the kitchen."). O
  aluno tenta lembrar, revela a resposta (expressão, significado,
  collocations e o contexto de aplicação) e se autoavalia com **Não
  lembrei / Bom / Fácil** — como no Anki.
- A autoavaliação reagenda o cartão com um algoritmo simplificado de SM-2
  (`SpacedRepetition.swift`): errar traz o cartão de volta amanhã; acertar
  aumenta o intervalo progressivamente (1 dia → 6 dias → crescente conforme
  o fator de facilidade).
- Cada cartão revisado dá +5 XP e conta para a sequência do dia, então
  revisar textos antigos também é uma "missão diária" válida — dá pra fazer
  isso mesmo estando no meio de uma semana nova.
- A aba mostra quantos cartões estão disponíveis agora, o total acumulado, e
  de quais textos (com nível) eles vêm.

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
    Models/                   # CEFRLevel, StudyDay, WeeklyText, UserProgress, ReviewCard
    Content/                  # geração de conteúdo (local + IA)
    Services/                 # persistência, Keychain, TTS, gravação de áudio
    ViewModels/                # HomeViewModel
    Views/
      Onboarding/              # escolha de nível CEFR
      Home/                    # dashboard semanal + streak/XP
      DayMissions/              # as 7 telas do cronograma
      Review/                   # aba de revisão espaçada (flashcard game)
      Settings/                # chave de API, progresso
      Components/               # peças reutilizáveis de UI
    Resources/                 # Info.plist, Assets.xcassets
```

## Como testar o app

**Importante:** o simulador de iOS só roda em macOS (é o próprio Xcode que
fornece o simulador) — não existe forma de testar em Windows/Linux, nem
dentro desta sessão (ambiente Linux, sem Xcode). Você vai precisar de um
Mac. Não há necessidade de conta paga de desenvolvedor Apple para testar no
Simulador; só é preciso para instalar num iPhone físico (e mesmo assim, uma
Apple ID grátis já basta para rodar por 7 dias num aparelho seu).

### 1. Pré-requisitos (uma vez só)

- Um **Mac** com **Xcode** instalado (grátis, pela App Store; baixe a versão
  mais recente).
- [Homebrew](https://brew.sh) instalado, para instalar o XcodeGen:
  ```bash
  brew install xcodegen
  ```

### 2. Baixar o código

```bash
git clone https://github.com/Yroshy/English.git
cd English
git checkout claude/ios-english-learning-app-b3r39g
```
(Se você já tinha clonado antes, use `git pull origin claude/ios-english-learning-app-b3r39g` para pegar as novidades — collocations com contexto de aplicação e a aba de Revisão.)

### 3. Gerar o projeto Xcode e abrir

```bash
cd OneText
xcodegen generate
open OneText.xcodeproj
```

Isso cria o `OneText.xcodeproj` a partir do `project.yml` (usamos XcodeGen
em vez de versionar o `.pbxproj` direto, que é propenso a conflito de
merge). Nenhuma dependência externa via SPM é necessária — as chamadas à
API da Anthropic usam `URLSession` puro.

### 4. Rodar no Simulador

No Xcode, na barra de topo, selecione um simulador (ex.: "iPhone 15") ao
lado do nome do esquema "OneText", e aperte **Cmd+R** (ou o botão ▶). Na
primeira vez, o Xcode pode pedir para confirmar o "scheme" — aceite o
padrão "OneText".

### 5. (Opcional) Rodar num iPhone físico

1. Conecte o iPhone por cabo (ou configure Wi-Fi debugging).
2. No Xcode, selecione seu iPhone na lista de destinos (em vez do simulador).
3. Vá em **Signing & Capabilities** do target OneText, marque "Automatically
   manage signing" e selecione seu Apple ID pessoal em "Team" (grátis).
4. Cmd+R. No iPhone, na primeira instalação, vá em **Ajustes → Geral →
   VPN e Gerenciamento de Dispositivo** e confie no seu certificado de
   desenvolvedor.

### 6. Roteiro rápido de teste (smoke test)

Sem precisar de nenhuma chave de API — tudo abaixo funciona 100% offline:

1. **Onboarding**: escolha um nível (ex.: B1) — vai direto para a aba
   "Semana" com um texto de rotina já gerado.
2. **Segunda**: leia o texto, veja as 3 perguntas (toque "Ver resposta"),
   marque os 5 chunks como revisados, conclua o dia. Repare que a aba
   "Revisão" ganha um badge com "5" — os cartões desse texto já entraram no
   pool.
3. **Terça**: veja as collocations de cada chunk e o novo bloco "CONTEXTO DE
   APLICAÇÃO" (frase extra usando uma collocation); marque tudo como
   revisado e conclua.
4. **Quarta**: toque o play em cada frase — o app fala em inglês (voz do
   sistema, use fone ou volume alto no simulador) frase por frase, para
   praticar shadowing.
5. **Quinta**: leia os pontos de gramática, marque como revisado, conclua.
6. **Sexta**: escreva algumas frases no campo de texto e conclua (a correção
   por IA só funciona com chave configurada — sem chave, aparece um aviso e
   dá para concluir do mesmo jeito).
7. **Sábado**: toque "Gravar minha fala" (autorize o microfone), grave
   alguns segundos, ouça de volta, conclua.
8. **Domingo**: escreva de memória (opcional) e conclua — isso fecha a
   semana, mostra "🎉 Semana concluída!" e oferece gerar a próxima.
9. **Aba Revisão**: abra a aba, toque "Iniciar revisão" — o app mostra a
   frase com a expressão em branco, você tenta lembrar, toca "Mostrar
   resposta" e se autoavalia (Não lembrei / Bom / Fácil). Ganhe +5 XP por
   cartão e veja o intervalo de repetição mudar (cartões "Fácil" somem por
   mais tempo; "Não lembrei" volta amanhã).
10. Gere uma nova semana (outro texto de rotina aleatório) e confirme que a
    aba Revisão continua mostrando cartões da semana anterior — é o
    comportamento pedido: revisar textos passados mesmo dentro de uma nova
    semana.

### 7. (Opcional) Configurar a IA

1. Na aba "Semana", toque no ícone de engrenagem → **Ajustes**.
2. Cole sua chave de API da Anthropic (formato `sk-ant-...`) — crie uma em
   https://console.anthropic.com se ainda não tiver.
3. A partir daí, "Gerar texto da semana" passa a criar textos novos e
   inéditos (em vez de repetir o banco offline), o botão "Gerar mais
   collocations" na Terça funciona, e a correção de escrita da Sexta passa a
   dar feedback real da IA.

## Status / próximos passos sugeridos

Este é o MVP funcional da metodologia completa com 1 texto por nível já
incluído offline, gamificação básica (streak + XP) e o gerador de IA
plugável. Não foi possível compilar/rodar no simulador iOS neste ambiente
(sessão em container Linux, sem Xcode) — o código foi revisado
cuidadosamente à mão, mas recomenda-se abrir no Xcode e testar antes de
considerar pronto para uso real. Sugestões de evolução:

- Mais tópicos de rotina no banco offline (hoje há 1 por nível; o gerador de
  IA cobre o resto).
- Notificações locais para lembrete da missão diária e dos cartões de
  revisão que ficaram devidos.
- Tela de histórico das semanas concluídas (os dados já são salvos em
  `UserProgress.completedWeeks`, falta só a tela).
- Reconhecimento de fala (Speech framework) para dar feedback automático de
  pronúncia no sábado, hoje é autoavaliação por gravação/playback.
- Cartões de revisão adicionais a partir das perguntas de interpretação e
  dos pontos de gramática (hoje o pool de revisão usa só os 5 chunks de cada
  semana).
