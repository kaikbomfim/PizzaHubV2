import 'package:pizzahub/authenticator.dart';
import 'package:pizzahub/components/pizzacard.dart';
import 'package:pizzahub/state.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:pizzahub/apis/api.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MenuState();
  }
}

const int pageSize = 20;

class _MenuState extends State<Menu> {
  List<dynamic> _pizzas = [];

  final ScrollController _pizzasController = ScrollController();
  final TextEditingController _filterController = TextEditingController();

  late DragStartDetails startVerticalDragDetails;
  late DragUpdateDetails updateVerticalDragDetails;

  String _filter = "";

  late ServicoPizzas _servicoPizzas;
  int _lastPizza = 0;

  @override
  void initState() {
    super.initState();

    ToastContext().init(context);
    _servicoPizzas = ServicoPizzas();

    _pizzasController.addListener(() {
      if (_pizzasController.position.pixels ==
          _pizzasController.position.maxScrollExtent) {
        _loadPizzas();
      }
    });

    _loadPizzas();
    _loadUser();
  }

  void _loadUser() {
    Authenticator.recoverUser().then((user) {
      if (user != null) {
        appState.onLogin(user);
      } else {
        appState.onLogout();
      }
    });
  }

  void _loadPizzas() {
    if (_filter.isEmpty) {
      _servicoPizzas.getPizzas(_lastPizza, pageSize).then((pizzas) {
        setState(() {
          if (pizzas.isNotEmpty) {
            _lastPizza = pizzas.last["id"];
          }
          _pizzas.addAll(pizzas);
        });
      });
    } else {
      _servicoPizzas.findPizzas(_lastPizza, pageSize, _filter).then((pizzas) {
        setState(() {
          if (pizzas.isNotEmpty) {
            _lastPizza = pizzas.last["id"];
          }
          _pizzas.addAll(pizzas);
        });
      });
    }
  }

  Future<void> _refreshPizzas() async {
    _pizzas = [];
    _lastPizza = 0;

    _filterController.text = "";
    _filter = "";

    _loadPizzas();
  }

  void _applyFilter(String filter) {
    setState(() {
      _filter = filter;
      _pizzas = [];
      _lastPizza = 0;
    });
    _loadPizzas();
  }

  @override
  Widget build(BuildContext context) {
    bool loggedUser = appState.user != null;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, left: 60, right: 20),
                child: TextField(
                  controller: _filterController,
                  onSubmitted: (filter) {
                    _applyFilter(filter);
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
            loggedUser
                ? IconButton(
                    onPressed: () {
                      Authenticator.logout().then((_) {
                        setState(() {
                          appState.onLogout();
                        });
                        Toast.show("Você saiu da sua conta.",
                            duration: Toast.lengthLong, gravity: Toast.bottom);
                      });
                    },
                    icon: const Icon(Icons.logout),
                  )
                : IconButton(
                    onPressed: () {
                      Authenticator.login().then((user) {
                        setState(() {
                          appState.onLogin(user);
                        });
                        Toast.show("Login realizado com sucesso.",
                            duration: Toast.lengthLong, gravity: Toast.bottom);
                      });
                    },
                    icon: const Icon(Icons.login),
                  ),
          ],
        ),
        body: RefreshIndicator(
            color: Colors.grey,
            onRefresh: () => _refreshPizzas(),
            child: GridView.builder(
                controller: _pizzasController,
                scrollDirection: Axis.vertical,
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 2,
                  childAspectRatio: 0.5,
                ),
                itemCount: _pizzas.length,
                itemBuilder: (context, index) {
                  return PizzaCard(pizza: _pizzas[index]);
                })));
  }
}
