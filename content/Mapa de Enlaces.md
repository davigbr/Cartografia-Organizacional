O mapa de enlaces é uma ferramenta da cartografia organizacional para visualizar agenciamentos. Seu objetivo é mapear a "física dos encontros" entre os [[Atuantes]]: pessoas, grupos, infraestrutura e códigos organizacionais. As conexões entre os elementos são denominadas [[Enlaces]]

A notação do mapa de encontros envolve os seguintes elementos visuais:

- O formato do mapa é um grafo;
- O [[Agenciamento]] sendo mapeado pode estar no centro do grafo como um grande ponto/círculo. Sugere-se a conexão desse ponto com todos os [[Atuantes]];
- Cada ponto no grafo é um Atuante, podendo-se empregar um código de cores para diferenciar o seu tipo;
- As conexões no grafo são os [[Enlaces]], podendo-se empregar um código de cores para diferenciar os diferentes tipos de conexões. 
- Um mesmo mapa pode conter mais de um[[Agenciamento].

## Exemplo de planilha para Kumu.io
### Aba "elements"

| **Label**          | **Type**     | **Description**                                                                        | **Tags**          |
| ------------------ | ------------ | -------------------------------------------------------------------------------------- | ----------------- |
| Demandas Jurídico  | Agenciamento | O objeto de desejo (os contratos/pedidos urgentes).                                    |                   |
| Sauron (Sócio)     | Pessoa       | Sócio da organização, chefe do Gandalf.                                                | Demandas Jurídico |
| Galadriel          | Pessoa       | Gerente do Jurídico.                                                                   | Demandas Jurídico |
| Gandalf            | Pessoa       | Diretor de Finanças, chefe da Galadriel                                                | Demandas Jurídico |
| Linte (ferramenta) | Instrumento  | Ferramenta desenhada para organizar a fila de demandas do jurídico.                    | Demandas Jurídico |
| WhatsApp/Slack     | Canal        | Ferramentas de comunicação síncrona usadas como atalho no lugar da ferramenta (Linte). | Demandas Jurídico |
| SLA                | Incentivo    | A regra de priorização que está sendo quebrada.                                        | Demandas Jurídico |
| Carteirada         | Costume      | Ato de usar a posição hierárquica para priorizar demandas.                             | Demandas Jurídico |
### Aba "connections"

| **From**       | **To**             | **Type**      | **Direction** | **Label**                                                                                                                              |
| -------------- | ------------------ | ------------- | ------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| Sauron (Sócio) | WhatsApp/Slack     | Linha de Fuga | undirected    | Sauron usa o WhatsApp/Slack como linha de fuga para escapar da codificação do Linte.                                                   |
| WhatsApp/Slack | Galadriel          | Decomposição  | undirected    | Para Galadriel, o "bip" do Slack não é ferramenta, é interrupção. Gera ansiedade e quebra a lógica de priorização do Linte.            |
| Sauron (Sócio) | Linte (ferramenta) | Decomposição  | undirected    | Sauron ignora o ator material que disciplinaria seu pedido. Ele evita o Linte porque o Linte exige completude (o que ele não entrega). |
| Sauron (Sócio) | Gandalf            | Captura       | undirected    | Sauron recorre a Gandalf quando Galadriel "não entrega" para adicionar urgência                                                        |
| Gandalf        | Galadriel          | Captura       | undirected    | Um fluxo de comando que ignora a capacidade produtiva de Galadriel. Gandalf atua como amplificador da fricção sobre Galadriel.         |
| Carteirada     | SLA                | Decomposição  | undirected    | A Carteirada anula o SLA. Torna o SLA uma lei morta.                                                                                   |
| SLA            | Gandalf            |               | undirected    | O ator expressivo "SLA" existe no papel, mas não tem força magnética para afetar o comportamento dos diretores.                        |
| Galadriel      | Linte (ferramenta) | Composição    | undirected    | Galadriel quer usar a ferramenta, pois ela a protege (Script: "organização"), mas é impedida pela urgência externa.                    |
| Sauron (Sócio) | Carteirada         | Composição    | undirected    | Ele se apoia na hierarquia para legitimar sua conduta.                                                                                 |
<iframe src="https://embed.kumu.io/68da019961f09fc4a785df778812a6cb" width="940" height="600" frameborder="0"></iframe>
## Layout para Kumu

```@controls {
  top-right {
    zoom-toolbar {}

    focus-toolbar {}
  }

  left {}

  top {
    showcase {
      target: element;
      by: "element type";
      placeholder: "Showcase";
      as: dropdown;
      color: white;
      font-weight: 600;
      background-color: grey;
      height: 18;
      width: 90;
      text-align: center;
      multiple: true;
      default: show-all;
    }
  }

  bottom {
    filter {
      target: element;
      by: "element type";
      as: buttons;
      multiple: true;
      default: show-all;
    }
  }
}

@settings {
  template: custom;
  layout: force;
  layout-gravity: 0.0009;
  layout-particle-charge: 250;
  connection-length: 50;
  connection-strength: 0.1;
  font-size: 15;
  font-color: white;
  theme: dark;
  cluster: "Tags";
  bridge: 0;
}

/* Agenciamento */
element["element type"="Agenciamento"] {
  size: 100;
  color: #3596c0;
  font-size: 30;
}

/* Pessoa */
element["element type"="Pessoa"] {
  size: 20;
  color: #fdc16f;
  shape: circle;
}

/* Grupo */
element["element type"="Grupo"] {
  size: 20;
  color: #fdc16f;
  shape: circle;
}

/* Infraestrutura */
element["element type"="Infraestrutura"] {
  size: 20;
  color: #f67c49;
  shape: square;
}

/* Código */
element["element type"="Código"] {
  size: 20;
  color: #d93e4a;
  shape: triangle;
}

element {
  popover: "**{{Label}}**  ---  {{Description}}";
  popover-height: 200;
  popover-width: 300;
  popover-padding: 3;
}

/* Composição */
connection["connection type"="Composição"] {
  color: #74c89e;
}

/* Decomposição */
connection["connection type"="Decomposição"] {
  color: #d93e4a;
}

/* Linha de Fuga */
connection["connection type"="Linha de Fuga"] {
  color: #fff1a2;
  style: solid;
}

/* Captura */
connection["connection type"="Captura"] {
  color: #5e4fa2;
  style: solid;
}
```