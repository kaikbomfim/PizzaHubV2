import 'package:pizzahub/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:intl/intl.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:toast/toast.dart';
import 'package:pizzahub/apis/api.dart';

class Details extends StatefulWidget {
  const Details({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DetailsState();
  }
}

enum _PizzaStatus { notLoaded, hasPizza, noPizza }

class _DetailsState extends State<Details> {
  _PizzaStatus _pizzaStatus = _PizzaStatus.notLoaded;
  late dynamic _pizza;
  int _ultimoComentario = 1;

  List<dynamic> _comments = [];
  bool _hasComments = false;

  final TextEditingController _newCommentController = TextEditingController();
  final ScrollController _newScrollController = ScrollController();

  late PageController _pageController;
  late int _selectedSlide;

  late ServicoPizzas _servicoPizzas;
  late ServicoComentarios _servicoComentarios;

  @override
  void initState() {
    super.initState();

    ToastContext().init(context);

    _servicoPizzas = ServicoPizzas();
    _servicoComentarios = ServicoComentarios();

    _initializeSlides();
    _carregarPizza();
    _carregarComentarios();
  }

  void _initializeSlides() {
    _selectedSlide = 0;
    _pageController = PageController(initialPage: _selectedSlide);
  }

  void _carregarPizza() {
    _servicoPizzas.findPizza(appState.idPizza).then((pizza) {
      _pizza = pizza;

      _pizzaStatus =
          _pizza != null ? _PizzaStatus.hasPizza : _PizzaStatus.noPizza;
    });
  }

  void _carregarComentarios() {
    _servicoComentarios
        .getComentarios(appState.idPizza, _ultimoComentario, 5)
        .then((comentarios) {
      _hasComments = comentarios.isNotEmpty;

      if (_hasComments) {
        _ultimoComentario = comentarios.last['id'];
      }

      setState(() {
        _comments = comentarios;
      });
    });
  }

  Widget _showPizzaNotFoundMessage() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('PizzaHub', style: TextStyle(color: Colors.orange)),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              appState.showMenu();
            },
          )
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 32, color: Colors.red),
            Text("Pizza não encontrada",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
            Text("Por favor, selecione outra pizza do menu.",
                style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _showNoCommentsMessage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 32, color: Colors.red),
          Text("Nenhum comentário ainda...",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
        ],
      ),
    );
  }

  Widget _showComments() {
    return Expanded(
        child: ListView.builder(
            controller: _newScrollController,
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              final comentario = _comments[index];
              String dataFormatada = DateFormat('dd/MM/yyyy HH:mm')
                  .format(DateTime.parse(comentario["createdAt"]));
              bool usuarioLogadoComentou = appState.user != null &&
                  appState.user!.email == comentario["authorEmail"];

              return SizedBox(
                  height: 90,
                  child: Dismissible(
                    key: Key(comentario["id"].toString()),
                    direction: usuarioLogadoComentou
                        ? DismissDirection.endToStart
                        : DismissDirection.none,
                    background: Container(
                        alignment: Alignment.centerRight,
                        child: const Padding(
                            padding: EdgeInsets.only(right: 12.0),
                            child: Icon(Icons.delete, color: Colors.red))),
                    child: Card(
                        color: usuarioLogadoComentou
                            ? Colors.green[100]
                            : Colors.white,
                        child: Column(children: [
                          Padding(
                              padding: const EdgeInsets.only(top: 6, left: 6),
                              child: Container(
                                  alignment: Alignment.topLeft,
                                  child: Text(comentario["content"],
                                      style: const TextStyle(fontSize: 12)))),
                          const Spacer(),
                          Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10.0, left: 6.0),
                                      child: Text(
                                        dataFormatada,
                                        style: const TextStyle(fontSize: 12),
                                      )),
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(right: 10.0),
                                      child: Text(
                                        comentario["authorName"],
                                        style: const TextStyle(fontSize: 12),
                                      )),
                                ],
                              )),
                        ])),
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        setState(() {
                          _comments.removeAt(index);
                        });

                        showDialog(
                            context: context,
                            builder: (BuildContext contexto) {
                              return AlertDialog(
                                title: const Text(
                                    "Deseja excluir o seu comentário?",
                                    style: TextStyle(fontSize: 14)),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _comments.insert(index, comentario);
                                        });

                                        Navigator.of(contexto).pop();
                                      },
                                      child: const Text("NÃO",
                                          style: TextStyle(fontSize: 14))),
                                  TextButton(
                                      onPressed: () {
                                        _removeComment(comentario["id"]);

                                        Navigator.of(contexto).pop();
                                      },
                                      child: const Text("SIM",
                                          style: TextStyle(fontSize: 14)))
                                ],
                              );
                            });
                      }
                    },
                  ));
            }));
  }

  Future<void> _updateComments() async {
    _comments = [];
    _ultimoComentario = 0;

    _carregarComentarios();
  }

  void _addComment() {
    _servicoComentarios
        .adicionar(appState.idPizza, appState.user!, _newCommentController.text)
        .then((_) {
      Toast.show("Comentário adicionado!",
          duration: Toast.lengthLong, gravity: Toast.bottom);

      _updateComments();
    });
  }

  void _removeComment(int idComentario) {
    _servicoComentarios.remover(idComentario).then((_) {
      Toast.show("Comentário removido!",
          duration: Toast.lengthLong, gravity: Toast.bottom);
    });
  }

  Widget _showPizzaDetails() {
    bool isUserLoggedIn = appState.user != null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Row(children: [
          Row(children: [
            Image.network(formatarImagem("company.png"), width: 38),
            Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
                child: Text(
                  _pizza["company"]["name"],
                  style: const TextStyle(fontSize: 15),
                ))
          ]),
          const Spacer(),
          GestureDetector(
            onTap: () {
              appState.showMenu();
            },
            child: const Icon(Icons.arrow_back, size: 30),
          )
        ]),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 230,
            child: Stack(children: [
              PageView.builder(
                itemCount: 3,
                controller: _pageController,
                onPageChanged: (slide) {
                  setState(() {
                    _selectedSlide = slide;
                  });
                },
                itemBuilder: (context, pagePosition) {
                  return Image.network(
                    formatarImagem(_pizza["image"]),
                    fit: BoxFit.cover,
                  );
                },
              ),
              Align(
                  alignment: Alignment.topRight,
                  child: Column(children: [
                    IconButton(
                        onPressed: () {
                          final texto =
                              '${_pizza["name"]} por R\$ ${_pizza["price"].toString()} disponível na Pizza Hub.';
                          FlutterShare.share(title: "PizzaHub", text: texto);
                        },
                        icon: const Icon(Icons.share),
                        color: Colors.orange,
                        iconSize: 26)
                  ]))
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: PageViewDotIndicator(
              currentItem: _selectedSlide,
              count: 3,
              unselectedColor: Colors.grey,
              selectedColor: Colors.orange,
              duration: const Duration(milliseconds: 200),
              boxShape: BoxShape.circle,
            ),
          ),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      _pizza["name"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    )),
                Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text("Tipo: ${_pizza["description"]}",
                        style: const TextStyle(fontSize: 12))),
                Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(_pizza["type"],
                        style: const TextStyle(fontSize: 12))),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    isUserLoggedIn
                        ? "Ingredientes: ${_pizza["ingredients"].join(", ")}"
                        : "Ingredientes não disponíveis",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                  child: Row(
                    children: [
                      const Text(
                        "Tamanhos disponíveis: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _pizza["sizes"].keys.map<Widget>((size) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "$size: R\$ ${_pizza["sizes"][size].toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const Center(
              child: Text(
            "Comentários",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          )),
          isUserLoggedIn
              ? Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: TextField(
                      controller: _newCommentController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black87, width: 0.0),
                          ),
                          border: const OutlineInputBorder(),
                          hintStyle: const TextStyle(fontSize: 14),
                          hintText: 'Faça um comentário...',
                          suffixIcon: GestureDetector(
                              onTap: () {
                                _addComment();
                              },
                              child: const Icon(Icons.send,
                                  color: Colors.black87)))))
              : const SizedBox.shrink(),
          _hasComments ? _showComments() : _showNoCommentsMessage()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget details = const SizedBox.shrink();

    if (_pizzaStatus == _PizzaStatus.notLoaded) {
      details = const SizedBox.shrink();
    } else if (_pizzaStatus == _PizzaStatus.hasPizza) {
      details = _showPizzaDetails();
    } else {
      details = _showPizzaNotFoundMessage();
    }

    return details;
  }
}
