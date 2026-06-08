# Product Requirements Document (PRD)

## Visão Geral

**Produto:** App "Gemini Clone" (Educacional)  
**Plataforma:** Android / iOS (Flutter)  
**Tema UI:** Dark Mode, inspirado no print fornecido  
**Objetivo:** Criar um assistente de IA funcional que servirá como projeto prático contínuo para a disciplina de Desenvolvimento Mobile (1VA).

## 1. Visão Geral da Arquitetura e Fluxo (User Flow)

A navegação da aplicação foi desenhada para ter o menor atrito possível, colocando o utilizador diretamente em contacto com a IA.

```text
[Splash Screen] -> [Ecrã Principal de Chat (Home)]
```

O ecrã principal funciona como o hub central da aplicação, contendo os seguintes elementos arquiteturais:

### App Bar (Topo)

- Ícone de menu que abre o Drawer.
- Dropdown/Selector central para escolher o modelo de IA, por exemplo "Gemini 3.5 Flash" ou "Gemini 3.1 flash lite".
- Botão de ação "Nova Conversa" com ícone de edição ou +.

### Drawer (Menu Lateral Esquerdo)

- Lista de histórico de conversas, agrupadas por sessões.

### Body (Centro)

- Empty State: logótipo estrela animado e saudação "Vamos lá, [Nome]".
- Chat State: ListView contendo o histórico de mensagens, com bolhas do utilizador e bolhas da IA.

### Bottom Bar (Entrada de Texto)

- Botão de anexo para abrir menu de câmara ou galeria.
- Caixa de texto expansível (TextField).
- Botão de envio que muda dinamicamente de ícone de microfone para ícone de "Enviar" quando o utilizador escreve.

## 2. Requisitos Funcionais (Features)

- **F01 - Splash Screen:** ecrã inicial com o logótipo da aplicação. Duração de 2 segundos antes de redirecionar para a Home.
- **F02 - Seleção de Modelo:** o utilizador deve poder alternar entre diferentes modelos de linguagem através do menu no topo. A escolha altera os parâmetros da chamada à API.
- **F03 - Nova Conversa:** o botão "Nova Conversa" na App Bar deve limpar o ecrã atual, guardar a sessão anterior na base de dados e iniciar um contexto limpo.
- **F04 - Envio de Mensagem de Texto:** o utilizador pode digitar e enviar prompts de texto.
- **F05 - Histórico (Drawer):** o menu lateral deve listar os títulos das conversas passadas. Ao clicar numa conversa antiga, o ecrã principal deve carregar esse histórico.
- **F06 - Suporte Multimodal (Imagens):** o utilizador deve poder anexar uma imagem, tirada na hora com a câmara ou escolhida da galeria, junto com o seu texto. A imagem deve aparecer miniaturizada acima da caixa de texto antes do envio.

## 3. Requisitos Não Funcionais (UI/UX e Técnicos)

- **UI/Design:** interface focada no Modo Escuro (Dark Theme), com fundo preto/cinzento muito escuro, utilizando fontes limpas, por exemplo Google Fonts - Roboto ou Inter.
- **Gestão de Estado:** utilização de Provider ou Riverpod para manter o histórico da conversa ativo sem precisar de reconstruir toda a árvore de widgets.
- **Persistência:** utilização de sqflite (SQLite) ou Hive para guardar as conversas localmente no dispositivo. O histórico deve sobreviver ao encerramento da app.
- **Feedback Visual:** implementação de indicadores de carregamento, como shimmer effect ou animação do logótipo, enquanto a IA processa a resposta.

## 4. Mapeamento Pedagógico (O Roteiro das 6 Aulas)

Como monitor, construirá a app completa primeiro. Quando for ensinar a turma, este é o roteiro de construção dividido pelas aulas da ementa:

### Aula 1: Widgets de layout e estilização

- **Objetivo:** construir a "casca" estática do Ecrã Principal.
- **Tarefas:** criar o tema escuro (ThemeData.dark()).
- Montar a AppBar com botões falsos.
- Montar o Empty State que vemos no seu print, com logótipo e "Vamos lá, Alex".
- Montar o design estático do Drawer, ainda vazio.

### Aula 2: Widgets de navegação e entrada de dados

- **Objetivo:** interação do utilizador.
- **Tarefas:** criar a Splash Screen e a navegação (Navigator.pushReplacement) para a Home.
- Construir a Bottom Bar de chat.
- Configurar o TextField, controlar o teclado e gerir o estado visual do botão "Enviar", escondendo o microfone e mostrando a seta de envio quando há texto.
- Implementar o Dropdown na AppBar para escolher o modelo.

### Aula 3: Widgets de comunicação, listagens e outros

- **Objetivo:** o chat ganha estrutura de lista.
- **Tarefas:** criar o design das ChatBubbles, com bolhas de mensagens.
- Implementar o ListView.builder para mostrar as mensagens.
- Ao escrever e clicar em "Enviar", a mensagem entra na lista.
- Implementar o CircularProgressIndicator para simular a IA a escrever, com Future.delayed.

### Aula 4: Gestão de estado e navegação avançada

- **Objetivo:** o cérebro da app. Ligar a API real.
- **Tarefas:** implementar a classe Provider para gerir o Chat.
- Fornecer aos alunos o ia_service.dart, a classe que faz o POST para a API do Gemini.
- Ligar o botão de "Enviar" ao Provider, que chama o serviço e adiciona a resposta real da IA à interface.
- Programar o botão "Nova Conversa", limpando a lista no Provider.

### Aula 5: Persistência de dados

- **Objetivo:** guardar o histórico.
- **Tarefas:** criar as tabelas SQLite: Conversas (ID, Título) e Mensagens (ID, Conversa_ID, Texto, Remetente).
- Salvar as mensagens à medida que chegam.
- Ler as conversas passadas e preencher o Drawer. Ao clicar no Drawer, carregar esse ID na Home.

### Aula 6: Manipulação de data, câmara e galeria

- **Objetivo:** chat multimodal.
- **Tarefas:** adicionar timestamps, com hora de envio, abaixo das mensagens.
- Programar o botão de anexo na caixa de texto. Usar image_picker para capturar fotos da câmara ou da galeria.
- Ajustar a API e a UI para permitirem enviar a foto para a IA analisar.