<div align="center">
    <a href="https://github.com/kaikbomfim/PizzaHubV2" target="_blank">
        <img src="./assets/banner.png" 
        alt="Logo" width="300" height="300">
    </a>
</div>

<div align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=50&duration=3000&pause=200&color=F7B062FF&center=true&vCenter=true&multiline=true&random=false&width=435&height=100&lines=PizzaHub"> 
</div>

<h2 align="center">Experimente o sabor irresistível da perfeição, com pizzas artesanais que conquistam corações e paladares.</h2>

## **Visão Geral**

O **PizzaHubV2** é um aplicativo mobile voltado para a listagem e exibição de informações detalhadas sobre pizzas. Seu objetivo é centralizar essas informações, permitindo que o usuário explore as opções de pizzas disponíveis, visualize ingredientes e tamanhos, e conheça as características de cada produto. Desenvolvida com Flutter, a aplicação é **responsiva**, **prática** e foca em proporcionar uma experiência agradável para seus usuários.

## **Instruções de Uso**

Para rodar o **PizzaHubV2** localmente, siga os passos abaixo:

1. Clone este repositório:

   ```bash
   git clone https://github.com/kaikbomfim/PizzaHubV2.git
   ```

2. Acesse o diretório do projeto:

   ```bash
   cd ./PizzaHubV2
   ```

3. Configure o arquivo api.dart com o seu IP:

   ```bash
   const URL_PIZZA = "http://SEU_IP_AQUI:3000/pizza"
   const URL_COMENTARIO = "http://SEU_IP_AQUI:3000/comment"
   const URL_IMAGEM = "http://SEU_IP_AQUI:5005"
   ```

   Obs.: _Se preferir, descomente as linhas que acionam o servidor remoto._

4. Instale as dependências do projeto:

   ```bash
   flutter pub get
   ```

5. Inicie o servidor local:

   ```bash
   flutter run
   ```

6. Acesse a aplicação em seu **emulador Android** ou **dispositivo móvel.**

## Tecnologias Utilizadas

- **Front-end:** Flutter e Dart.
- **Back-end:** NestJS e Docker.
- **Controle de versão:** Git e GitHub.
