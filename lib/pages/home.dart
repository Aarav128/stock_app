import 'package:flutter/material.dart';
import 'package:stock_app/components/stock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<StockData> stocks = List.empty(growable: true);
  Future<StockData>? req;
  late List<StockData> data;
  late TextEditingController _controller;
  late String symbol;
  List<String>? stocksIncluded;

  @override
  void initState() {
    super.initState();
    data = List.empty(growable: true);
    req = StockData.fetchStockData("");
    retrieveList();
    symbol = "";
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          title: const Text('Stock Market'),
          flexibleSpace: clearButton(),
        ),
        body: Column(
          children: [
            Expanded(child: Column(children: [searchBar(), stocksOutput()])),
          ],
        ));
  }

  FutureBuilder<StockData> stocksOutput() {
    return FutureBuilder(
        future: req,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            if (snapshot.data!.value != StockData.empty().value) {
              data.add(snapshot.data!);
              if (!stocksIncluded!.contains(snapshot.data!.symbol)) {
                stocksIncluded!.add(snapshot.data!.symbol);
                saveList();
              }
            }
            return displayData();
          } else {
            return displayData();
          }
        });
  }

  Align clearButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: ElevatedButton(
          onPressed: () {
            data.clear();
            stocksIncluded!.clear();
            symbol = "";
            req = StockData.fetchStockData(symbol);
            saveList();
            setState(() {});
          },
          child: const Icon(Icons.delete, color: Colors.red, size: 20)),
    );
  }

  ElevatedButton deleteButton(int index) {
    return ElevatedButton(
        onPressed: () {
          data.removeAt(index);
          stocksIncluded!.removeAt(index);
          symbol = "";
          req = StockData.fetchStockData(symbol);
          saveList();
          setState(() {});
        },
        child: const Icon(Icons.remove, color: Colors.red, size: 24));
  }

  Expanded displayData() {
    return Expanded(
        child: ReorderableListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: data.length,
            itemBuilder: (context, index) {
              return ListTile(
                  tileColor: Colors.grey,
                  contentPadding: const EdgeInsets.all(5),
                  key: ValueKey(index),
                  subtitle: Container(
                    color: Colors.grey,
                    child: Flex(direction: Axis.horizontal, children: [
                      Expanded(
                        child: Row(children: [
                          deleteButton(index),
                          StockDisplay(d: data[index]),
                        ]),
                      ),
                    ]),
                  ));
            },
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex--;
              }
              final StockData d = data.removeAt(oldIndex);
              final String n = stocksIncluded!.removeAt(oldIndex);

              data.insert(newIndex, d);
              stocksIncluded!.insert(newIndex, n);
              symbol = "";
              req = StockData.fetchStockData(symbol);
              saveList();
              setState(() {});
            }));
  }

  Container searchBar() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: TextField(
        
        key: const ValueKey("searchBar"),
        onEditingComplete: sendSearch,
        controller: _controller,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(15),
            suffixIcon: TextButton(
                key: const ValueKey("searchButton"), // for ui test
                onPressed: sendSearch,
                child: const Text('Add', style: TextStyle(fontSize: 20)))),
      ),
    );
  }

  void sendSearch() {
    symbol = _controller.text.toUpperCase();
    if (!stocksIncluded!.contains(symbol)) {
      req = StockData.fetchStockData(symbol);

      // To close on screen keyboard on enter:
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {});
    }

    _controller.clear();
  }

  Future<void> saveList() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setStringList('data', stocksIncluded!);
  }

  Future<void> retrieveList() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    stocksIncluded = pref.getStringList('data');
    stocksIncluded ??= List.empty(growable: true);
    stocksIncluded = stocksIncluded!.toSet().toList();
    for (int i = 0; i < stocksIncluded!.length; i++) {
      symbol = stocksIncluded![i];
      data.add(await StockData.fetchStockData(symbol));
    }
    setState(() {});
  }
}
