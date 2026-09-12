import Foundation

/// Offline, hand-curated content so the app is fully usable without any API key.
/// Ships one richly-detailed "routine" text per CEFR level. `ClaudeContentGenerator`
/// is used on top of this to generate unlimited new texts once the learner adds
/// an Anthropic API key in Settings.
final class LocalContentBank: ContentGenerating {

    func generateWeeklyText(level: CEFRLevel, topic: RoutineTopic, avoiding usedTitles: [String]) async throws -> WeeklyText {
        let candidates = Self.seedTexts.filter { $0.level == level }
        let fresh = candidates.first { !usedTitles.contains($0.title) }
        return fresh ?? candidates.first ?? Self.seedTexts[0]
    }

    func generateCollocations(for expression: String, level: CEFRLevel) async throws -> [String] {
        // Offline fallback: no new collocations beyond the seeded ones.
        return []
    }

    func generateWritingFeedback(userText: String, originalText: String, level: CEFRLevel) async throws -> WritingFeedback {
        throw ContentError.missingAPIKey
    }

    // MARK: - Seed data

    static let seedTexts: [WeeklyText] = [

        // MARK: A1
        WeeklyText(
            level: .a1,
            topic: .morningRoutine,
            title: "Ana's Morning",
            body: """
            Every day, Ana wakes up at six thirty. She gets out of bed and opens the curtains. \
            First, she brushes her teeth and takes a quick shower. Then she gets dressed and \
            goes to the kitchen. She makes a cup of coffee and eats a piece of toast with butter. \
            At seven fifteen, she packs her bag and leaves the house. She walks to the bus stop \
            and waits for the bus. The bus arrives at seven thirty, and Ana goes to work.
            """,
            comprehensionQuestions: [
                ComprehensionQuestion(question: "What time does Ana wake up?", answerHint: "At six thirty."),
                ComprehensionQuestion(question: "What does she eat for breakfast?", answerHint: "Toast with butter."),
                ComprehensionQuestion(question: "How does Ana get to work?", answerHint: "She walks to the bus stop and takes the bus.")
            ],
            keyChunks: [
                KeyChunk(expression: "wake up", meaningPT: "acordar", exampleFromText: "Ana wakes up at six thirty.", collocations: ["wake up early", "wake up late", "wake up tired"], usageExample: "On weekends, I like to wake up late and relax."),
                KeyChunk(expression: "get dressed", meaningPT: "se vestir", exampleFromText: "She gets dressed and goes to the kitchen.", collocations: ["get dressed quickly", "get dressed for work", "get dressed in the morning"], usageExample: "The kids get dressed for school every morning."),
                KeyChunk(expression: "a cup of coffee", meaningPT: "uma xícara de café", exampleFromText: "She makes a cup of coffee.", collocations: ["a cup of tea", "a hot cup of coffee", "a strong cup of coffee"], usageExample: "Can I have a strong cup of coffee, please?"),
                KeyChunk(expression: "pack her bag", meaningPT: "arrumar a bolsa/mochila", exampleFromText: "She packs her bag and leaves the house.", collocations: ["pack a bag quickly", "pack your bag the night before", "pack a school bag"], usageExample: "He always packs his bag the night before a trip."),
                KeyChunk(expression: "go to work", meaningPT: "ir trabalhar", exampleFromText: "The bus arrives, and Ana goes to work.", collocations: ["go to work by bus", "go to work early", "go to work on foot"], usageExample: "My brother goes to work by bus every day.")
            ],
            grammarPoints: [
                GrammarPoint(title: "Simple Present para rotinas", explanationPT: "Usamos o Simple Present para hábitos e rotinas diárias. Na 3ª pessoa (she/he/it), o verbo recebe -s: wakes, gets, makes, goes.", exampleFromText: "Ana wakes up at six thirty."),
                GrammarPoint(title: "Preposições de tempo (at / in)", explanationPT: "Usamos \"at\" com horários exatos (at six thirty) e \"in the\" com partes do dia (in the morning).", exampleFromText: "At seven fifteen, she packs her bag.")
            ],
            writingPrompt: "Escreva de 5 a 10 frases descrevendo a SUA rotina de manhã, usando o Simple Present. Tente usar pelo menos 2 dos chunks estudados.",
            speakingPrompt: "Leia o texto em voz alta 3 vezes. Depois, tente contar sua própria rotina de manhã sem olhar para o papel."
        ),

        // MARK: A2
        WeeklyText(
            level: .a2,
            topic: .commuteToWork,
            title: "Marcos's Commute",
            body: """
            Marcos lives in a small apartment near the city center, but he works on the other \
            side of town. Every morning, he leaves home at seven and walks to the train station. \
            He usually buys a coffee to go before he gets on the train. The train is often \
            crowded, so he doesn't always find a seat. During the trip, he listens to music or \
            checks his phone. The journey takes about forty minutes. When he arrives at the \
            station, he still has to walk ten minutes to his office. On rainy days, the commute \
            takes longer because of the traffic and the crowds.
            """,
            comprehensionQuestions: [
                ComprehensionQuestion(question: "Where does Marcos work compared to where he lives?", answerHint: "On the other side of town."),
                ComprehensionQuestion(question: "What does he usually do during the train trip?", answerHint: "He listens to music or checks his phone."),
                ComprehensionQuestion(question: "Why does the commute take longer on rainy days?", answerHint: "Because of the traffic and the crowds.")
            ],
            keyChunks: [
                KeyChunk(expression: "leave home", meaningPT: "sair de casa", exampleFromText: "He leaves home at seven.", collocations: ["leave home early", "leave home on time", "leave home in a hurry"], usageExample: "We need to leave home early to avoid traffic."),
                KeyChunk(expression: "get on the train", meaningPT: "entrar/embarcar no trem", exampleFromText: "He buys a coffee before he gets on the train.", collocations: ["get on the bus", "get on time", "get off the train"], usageExample: "Hurry up, or we'll miss the chance to get on the bus!"),
                KeyChunk(expression: "find a seat", meaningPT: "achar um lugar para sentar", exampleFromText: "He doesn't always find a seat.", collocations: ["find a seat easily", "find an empty seat", "find a seat by the window"], usageExample: "It's hard to find a seat by the window during rush hour."),
                KeyChunk(expression: "check his phone", meaningPT: "checar o celular", exampleFromText: "He listens to music or checks his phone.", collocations: ["check your phone constantly", "check your messages", "check your email"], usageExample: "She checks her phone constantly, even during meals."),
                KeyChunk(expression: "take (time)", meaningPT: "levar (tempo)", exampleFromText: "The journey takes about forty minutes.", collocations: ["take a long time", "take an hour", "take forever"], usageExample: "The flight to São Paulo takes about an hour.")
            ],
            grammarPoints: [
                GrammarPoint(title: "Advérbios de frequência", explanationPT: "Palavras como usually, often e always ficam antes do verbo principal (mas depois do verbo \"be\"). Indicam frequência de hábitos.", exampleFromText: "He usually buys a coffee to go."),
                GrammarPoint(title: "Comparativo de adjetivos longos", explanationPT: "\"Longer\" é o comparativo de \"long\". Usamos para comparar duração, tamanho, etc.", exampleFromText: "The commute takes longer because of the traffic.")
            ],
            writingPrompt: "Escreva de 5 a 10 frases sobre o SEU trajeto até o trabalho ou escola. Compare um dia normal com um dia de chuva ou trânsito.",
            speakingPrompt: "Grave-se lendo o texto em voz alta. Depois, tente falar sobre o seu próprio trajeto sem ler."
        ),

        // MARK: B1
        WeeklyText(
            level: .b1,
            topic: .workDay,
            title: "A Busy Day at the Office",
            body: """
            Camila has worked at the same marketing company for almost three years. She usually \
            gets to the office around nine, checks her emails, and joins the morning meeting with \
            her team. Yesterday, however, was different. She arrived a bit late because of an \
            accident on the highway, so she had to rush into a meeting that had already started. \
            During the meeting, they discussed a new project for a client, and Camila took notes \
            so she wouldn't forget the details. After lunch, she spent most of the afternoon \
            answering emails and preparing a presentation for Friday. By the time she left the \
            office, she was exhausted, but she felt proud of everything she had managed to finish.
            """,
            comprehensionQuestions: [
                ComprehensionQuestion(question: "Why was Camila's day different from usual?", answerHint: "She arrived late because of an accident on the highway."),
                ComprehensionQuestion(question: "What did she do after lunch?", answerHint: "She spent the afternoon answering emails and preparing a presentation."),
                ComprehensionQuestion(question: "How did Camila feel at the end of the day?", answerHint: "Exhausted, but proud of what she had finished.")
            ],
            keyChunks: [
                KeyChunk(expression: "get to the office", meaningPT: "chegar ao escritório", exampleFromText: "She usually gets to the office around nine.", collocations: ["get to work on time", "get to the airport early", "get to a meeting late"], usageExample: "If there's no traffic, I can get to work on time."),
                KeyChunk(expression: "join a meeting", meaningPT: "participar de uma reunião", exampleFromText: "She joins the morning meeting with her team.", collocations: ["join a call", "join a team", "join a conversation"], usageExample: "Can you join the call in five minutes?"),
                KeyChunk(expression: "take notes", meaningPT: "fazer anotações", exampleFromText: "Camila took notes so she wouldn't forget the details.", collocations: ["take notes carefully", "take detailed notes", "take notes during a meeting"], usageExample: "Students who take detailed notes usually remember more."),
                KeyChunk(expression: "rush into", meaningPT: "entrar às pressas", exampleFromText: "She had to rush into a meeting that had already started.", collocations: ["rush into a decision", "rush into the room", "rush into things"], usageExample: "Try not to rush into a decision you might regret later."),
                KeyChunk(expression: "be proud of", meaningPT: "estar orgulhoso de", exampleFromText: "She felt proud of everything she had managed to finish.", collocations: ["be proud of your work", "be proud of yourself", "be proud of the team"], usageExample: "Her parents are very proud of her for finishing the marathon.")
            ],
            grammarPoints: [
                GrammarPoint(title: "Present Perfect vs Simple Past", explanationPT: "\"Has worked for three years\" (Present Perfect) mostra uma ação que começou no passado e continua até agora. \"Arrived\", \"had to rush\" (Simple Past) descrevem ações pontuais já finalizadas.", exampleFromText: "Camila has worked at the same company for almost three years."),
                GrammarPoint(title: "Past Perfect", explanationPT: "Usamos o Past Perfect (had + particípio) para uma ação que aconteceu ANTES de outra ação passada.", exampleFromText: "A meeting that had already started.")
            ],
            writingPrompt: "Escreva de 5 a 10 frases contando como foi o SEU último dia de trabalho ou estudo, incluindo algo que saiu diferente do planejado.",
            speakingPrompt: "Leia seu texto em voz alta algumas vezes e depois tente contar seu dia de trabalho naturalmente, sem ler."
        ),

        // MARK: B2
        WeeklyText(
            level: .b2,
            topic: .groceryShopping,
            title: "Sunday Grocery Run",
            body: """
            Every Sunday morning, before the supermarket gets too crowded, Rafael makes a quick \
            list of everything the house needs for the week. He used to just wander around the \
            aisles without any plan, but he soon realized that shopping without a list made him \
            buy things he didn't actually need — and skip the ones he did. Nowadays, he sticks to \
            his list as closely as possible, although he still allows himself the occasional \
            treat, like a new type of cheese he hasn't tried before. While he shops, he compares \
            prices between brands and checks the expiration dates carefully, especially for dairy \
            products. By the time he reaches the checkout, the store is usually packed with people \
            who left their shopping until the last minute. Once he's home, he puts everything \
            away and, if he has any energy left, starts planning what to cook for dinner.
            """,
            comprehensionQuestions: [
                ComprehensionQuestion(question: "What mistake did Rafael use to make when shopping without a list?", answerHint: "He bought things he didn't need and skipped things he did."),
                ComprehensionQuestion(question: "Besides following his list, what does he do while shopping?", answerHint: "He compares prices between brands and checks expiration dates."),
                ComprehensionQuestion(question: "What does Rafael sometimes do even though he has a list?", answerHint: "He allows himself an occasional treat.")
            ],
            keyChunks: [
                KeyChunk(expression: "make a list", meaningPT: "fazer uma lista", exampleFromText: "Rafael makes a quick list of everything the house needs.", collocations: ["make a shopping list", "make a mental list", "make a list of priorities"], usageExample: "Before traveling, I always make a list of priorities."),
                KeyChunk(expression: "stick to", meaningPT: "seguir à risca, se ater a", exampleFromText: "He sticks to his list as closely as possible.", collocations: ["stick to a budget", "stick to a plan", "stick to a diet"], usageExample: "It's hard to stick to a diet during the holidays."),
                KeyChunk(expression: "compare prices", meaningPT: "comparar preços", exampleFromText: "He compares prices between brands.", collocations: ["compare prices online", "compare prices between stores", "compare prices carefully"], usageExample: "It's a good idea to compare prices online before buying electronics."),
                KeyChunk(expression: "check the expiration date", meaningPT: "checar a data de validade", exampleFromText: "He checks the expiration dates carefully.", collocations: ["check the expiration date twice", "check the label", "check for freshness"], usageExample: "Always check the label before eating something from the back of the fridge."),
                KeyChunk(expression: "leave (something) until the last minute", meaningPT: "deixar para a última hora", exampleFromText: "People who left their shopping until the last minute.", collocations: ["leave your homework until the last minute", "leave it until the last minute", "leave packing until the last minute"], usageExample: "He always leaves his homework until the last minute and then panics.")
            ],
            grammarPoints: [
                GrammarPoint(title: "\"used to\" para hábitos do passado", explanationPT: "\"Used to + verbo\" descreve um hábito ou estado que era verdade no passado, mas não é mais.", exampleFromText: "He used to just wander around the aisles without any plan."),
                GrammarPoint(title: "\"although\" para concessão", explanationPT: "\"Although\" introduz uma ideia que contrasta com a frase principal, similar a \"embora\" em português.", exampleFromText: "Although he still allows himself the occasional treat.")
            ],
            writingPrompt: "Escreva de 5 a 10 frases sobre como você faz (ou deveria fazer) compras de mercado. Use \"used to\" para comparar como você fazia antes.",
            speakingPrompt: "Grave-se lendo o texto. Depois, fale por 1 minuto sobre a sua própria rotina de compras, sem ler."
        ),

        // MARK: C1
        WeeklyText(
            level: .c1,
            topic: .cookingDinner,
            title: "Cooking Without a Recipe",
            body: """
            After years of religiously following recipes down to the last gram, Beatriz has \
            gradually learned to trust her instincts in the kitchen. It all started one evening \
            when she realized she was missing half the ingredients for the dish she had planned, \
            and rather than giving up, she decided to improvise with whatever she had on hand. To \
            her surprise, the result turned out even better than the original recipe would have. \
            Since then, cooking dinner has become less of a chore and more of a creative outlet. \
            She still consults recipes occasionally, mostly for inspiration or to get the \
            proportions right for baking, which she admits is far less forgiving than sautéing \
            vegetables or throwing together a stew. What she enjoys most, though, is tasting as \
            she goes, adjusting the seasoning bit by bit until the flavors feel balanced. Her \
            partner jokes that dinner is never quite the same dish twice, but he's not complaining \
            — if anything, he looks forward to whatever unexpected combination she comes up with next.
            """,
            comprehensionQuestions: [
                ComprehensionQuestion(question: "What changed Beatriz's approach to cooking?", answerHint: "An evening when she was missing ingredients and had to improvise."),
                ComprehensionQuestion(question: "Why does she still use recipes for baking specifically?", answerHint: "Baking is less forgiving and needs precise proportions."),
                ComprehensionQuestion(question: "How does her partner react to her unpredictable cooking?", answerHint: "He jokes about it but looks forward to it — he isn't complaining.")
            ],
            keyChunks: [
                KeyChunk(expression: "trust your instincts", meaningPT: "confiar no seu instinto", exampleFromText: "Beatriz has gradually learned to trust her instincts in the kitchen.", collocations: ["trust your instincts in the kitchen", "trust your gut", "trust your own judgment"], usageExample: "In a job interview, it often pays to trust your gut."),
                KeyChunk(expression: "have on hand", meaningPT: "ter à mão/disponível", exampleFromText: "She decided to improvise with whatever she had on hand.", collocations: ["whatever you have on hand", "keep ingredients on hand", "have cash on hand"], usageExample: "It's useful to keep extra batteries on hand during a storm."),
                KeyChunk(expression: "a creative outlet", meaningPT: "uma válvula de escape criativa", exampleFromText: "Cooking has become less of a chore and more of a creative outlet.", collocations: ["find a creative outlet", "cooking as a creative outlet", "a healthy outlet for stress"], usageExample: "After a stressful week, painting became her creative outlet."),
                KeyChunk(expression: "get the proportions right", meaningPT: "acertar as proporções", exampleFromText: "She consults recipes to get the proportions right for baking.", collocations: ["get the balance right", "get the timing right", "get the seasoning right"], usageExample: "Baking a cake requires getting the proportions right."),
                KeyChunk(expression: "taste as you go", meaningPT: "provar enquanto cozinha", exampleFromText: "What she enjoys most is tasting as she goes.", collocations: ["adjust the seasoning as you go", "taste and adjust", "season to taste"], usageExample: "Good cooks always taste and adjust the seasoning as they go.")
            ],
            grammarPoints: [
                GrammarPoint(title: "Present Perfect para mudança gradual", explanationPT: "\"Has gradually learned\" mostra uma mudança que aconteceu aos poucos até o presente, diferente do Simple Past usado para eventos pontuais (\"realized\", \"decided\").", exampleFromText: "Beatriz has gradually learned to trust her instincts."),
                GrammarPoint(title: "\"would have\" hipotético", explanationPT: "Usado para especular sobre um resultado alternativo no passado — o que teria acontecido se algo diferente tivesse ocorrido.", exampleFromText: "The result turned out even better than the original recipe would have."),
                GrammarPoint(title: "Oração reduzida com particípio", explanationPT: "\"Adjusting the seasoning bit by bit\" é uma oração reduzida (-ing) que substitui \"while she adjusts\", tornando a frase mais fluida.", exampleFromText: "Tasting as she goes, adjusting the seasoning bit by bit.")
            ],
            writingPrompt: "Escreva de 5 a 10 frases sobre a SUA relação com a cozinha (ou outra atividade do dia a dia): você segue regras à risca ou improvisa? O que mudou com o tempo?",
            speakingPrompt: "Grave-se lendo o texto com atenção à entonação. Depois, fale por 1-2 minutos sobre como sua própria rotina mudou ao longo do tempo."
        ),

        // MARK: C2
        WeeklyText(
            level: .c2,
            topic: .weekendPlans,
            title: "Renegotiating the Weekend",
            body: """
            For most of her adult life, Fernanda treated the weekend as an extension of the \
            working week in disguise — errands piled up on Saturday morning, emails she'd \
            promised herself she wouldn't open crept back in by Sunday afternoon, and by the time \
            Monday arrived, she felt as though she'd barely had a break at all. It wasn't until a \
            particularly exhausting month that she decided something had to give, so she began, \
            almost experimentally, to ring-fence a few hours each weekend that were simply \
            off-limits to anything resembling obligation. At first, the guilt was almost \
            unbearable; she'd catch herself reaching for her laptop out of sheer habit, only to \
            remember, somewhat sheepishly, that she'd sworn off checking it until Monday. Over \
            time, though, the discomfort gave way to something closer to relief, and she found \
            herself looking forward to those protected hours the way she once looked forward to a \
            long-awaited holiday. These days, her weekends still include the inevitable chores — \
            nobody, after all, is exempt from laundry — but she's learned to draw a firmer line \
            between what genuinely needs doing and what she'd simply convinced herself was urgent. \
            Her friends have noticed the difference too, joking that she's finally become someone \
            who can sit still without reaching for her phone every five minutes.
            """,
            comprehensionQuestions: [
                ComprehensionQuestion(question: "What prompted Fernanda to change how she spent her weekends?", answerHint: "A particularly exhausting month made her realize something had to change."),
                ComprehensionQuestion(question: "How does she describe her early attempts to protect her weekend time?", answerHint: "The guilt was almost unbearable; she'd catch herself reaching for her laptop out of habit."),
                ComprehensionQuestion(question: "What has stayed the same about her weekends, even after the change?", answerHint: "The inevitable chores, like laundry, are still there.")
            ],
            keyChunks: [
                KeyChunk(expression: "an extension of", meaningPT: "uma extensão de", exampleFromText: "She treated the weekend as an extension of the working week.", collocations: ["an extension of the working week", "an extension of her personality", "a natural extension of"], usageExample: "For many remote workers, the home office became an extension of the living room."),
                KeyChunk(expression: "ring-fence", meaningPT: "reservar/proteger (tempo ou recursos)", exampleFromText: "She began to ring-fence a few hours each weekend.", collocations: ["ring-fence some time", "ring-fence a budget", "ring-fence resources"], usageExample: "The company decided to ring-fence part of its budget for emergencies."),
                KeyChunk(expression: "give way to", meaningPT: "dar lugar a", exampleFromText: "The discomfort gave way to something closer to relief.", collocations: ["give way to relief", "give way to panic", "guilt gave way to acceptance"], usageExample: "Her initial anger eventually gave way to acceptance."),
                KeyChunk(expression: "out of habit", meaningPT: "por hábito, automaticamente", exampleFromText: "She'd catch herself reaching for her laptop out of sheer habit.", collocations: ["reach for something out of habit", "do it out of habit", "say it out of sheer habit"], usageExample: "He locked the door out of habit, even though no one else lived there."),
                KeyChunk(expression: "draw a line between", meaningPT: "traçar um limite entre", exampleFromText: "She's learned to draw a firmer line between what genuinely needs doing and what doesn't.", collocations: ["draw a line between work and life", "draw a firmer line", "draw the line somewhere"], usageExample: "It's important to draw a line between constructive criticism and personal attacks.")
            ],
            grammarPoints: [
                GrammarPoint(title: "Past Perfect em discurso relatado", explanationPT: "\"She'd promised herself she wouldn't open\" combina Past Perfect com um pensamento relatado, comum para expressar intenções passadas não cumpridas.", exampleFromText: "Emails she'd promised herself she wouldn't open."),
                GrammarPoint(title: "Estrutura enfática \"It wasn't until... that\"", explanationPT: "Essa estrutura de ênfase (cleft sentence) destaca QUANDO algo aconteceu, equivalente a \"só foi... que\" em português.", exampleFromText: "It wasn't until a particularly exhausting month that she decided something had to give."),
                GrammarPoint(title: "Orações participiais", explanationPT: "\"Joking that she's finally become someone who...\" é uma oração reduzida com -ing que acrescenta informação sem precisar de outra oração completa.", exampleFromText: "Her friends have noticed the difference too, joking that she's finally become someone who can sit still.")
            ],
            writingPrompt: "Escreva de 5 a 10 frases refletindo sobre como VOCÊ costuma (ou deveria) separar tempo de descanso da rotina de obrigações. O que você tem feito diferente ultimamente?",
            speakingPrompt: "Grave-se lendo o texto com atenção especial ao ritmo de frases longas. Depois, fale de forma natural por 1-2 minutos sobre sua própria relação com o descanso."
        )
    ]
}
