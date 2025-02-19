import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pizzahub/authenticator.dart';

/* Utilize o seu IP local nas rotas a seguir */
const URL_PIZZA =
    "http://10.0.0.131:3000/pizza"; // Exemplo: http://SEU_IP_AQUI:3000/pizza
const URL_COMENTARIO = "http://10.0.0.131:3000/comment";
const URL_IMAGEM = "http://10.0.0.131:5005"; // Exemplo: http://SEU_IP_AQUI:5005

/* Caso deseje, teste utilizando a API hospedada diretamente na WEB */
// const URL_PIZZA = "https://pizzahub-backend-mx3t.onrender.com/pizza";
// const URL_COMENTARIO = "https://pizzahub-backend-mx3t.onrender.com/comment";
// const URL_IMAGEM = "https://pizzahub-backend-mx3t.onrender.com/public";

class ServicoPizzas {
  Future<List<dynamic>> getPizzas(int ultimoId, int tamanhoPagina) async {
    final resposta = await http
        .get(Uri.parse("$URL_PIZZA?page=$ultimoId&limit=$tamanhoPagina"));

    final pizzas = jsonDecode(resposta.body);

    return pizzas;
  }

  Future<List<dynamic>> findPizzas(
      int ultimaPizza, int tamanhoPagina, String nome) async {
    final resposta = await http.get(Uri.parse(
        "$URL_PIZZA?page=$ultimaPizza&limit=$tamanhoPagina&name=$nome"));

    final pizzas = jsonDecode(resposta.body);

    return pizzas;
  }

  Future<Map<String, dynamic>> findPizza(int idPizza) async {
    final resposta = await http.get(Uri.parse("$URL_PIZZA/$idPizza"));

    final pizza = jsonDecode(resposta.body);

    return pizza;
  }
}

class ServicoComentarios {
  Future<List<dynamic>> getComentarios(
      int idPizza, int ultimoId, int tamanhoPagina) async {
    final resposta = await http.get(Uri.parse(
        "$URL_COMENTARIO?page=$ultimoId&limit=$tamanhoPagina&pizzaId=$idPizza"));

    final comentarios = jsonDecode(resposta.body);

    return comentarios;
  }

  Future<dynamic> adicionar(
      int idPizza, User usuario, String comentario) async {
    final Map<String, dynamic> payload = {
      "pizzaId": idPizza,
      "authorName": usuario.name,
      "authorEmail": usuario.email,
      "content": comentario,
    };

    final resposta = await http.post(
      Uri.parse(URL_COMENTARIO),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    return resposta;
  }

  Future<dynamic> remover(int idComentario) async {
    final resposta =
        await http.delete(Uri.parse("$URL_COMENTARIO/$idComentario"));

    final comentario = jsonDecode(resposta.body);

    return comentario;
  }
}

String formatarImagem(String imagem) {
  return "$URL_IMAGEM/$imagem";
}
