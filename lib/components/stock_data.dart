import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StockData {
  num value;
  String symbol;
  num high, low;

  static const key = "clftc5hr01qnc0nenlr0clftc5hr01qnc0nenlrg";
  static const action = "quote";

  StockData(
      {required this.value,
      required this.symbol,
      required this.high,
      required this.low});

  static StockData empty() {
    return StockData(value: 0, symbol: "NONE", high: 0, low: 0);
  }

  factory StockData.fromJson(String acronym, Map<String, dynamic> jsonData) =>
      StockData(
          symbol: acronym,
          value: jsonData["c"] as num,
          high: jsonData['h'] as num,
          low: jsonData['l'] as num);

  static Future<StockData> fetchStockData(acronym) async {
    const website = "https://finnhub.io/api/v1/";
    final query =
        "$website/${StockData.action}?symbol=$acronym&token=${StockData.key}";
    final uri = Uri.parse(query);
    final response = await (http.get(uri));
    if (response.statusCode == 200) {
      var x =
          StockData.fromJson(acronym.toUpperCase(), json.decode(response.body));
      return x;
    } else {
      return StockData.empty();
    }
  }
}

class StockDisplay extends StatelessWidget {
  final StockData d;
  // ignore: constant_identifier_names

  const StockDisplay({required this.d, super.key});

  @override
  Widget build(BuildContext context) {
    String acronym = d.symbol;
    String val = "\$${d.value.toStringAsFixed(2)}";
    String high = "\$${d.high.toStringAsFixed(2)}";
    String low = "\$${d.low.toStringAsFixed(2)}";
    return Expanded(
      child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(children: [
                  Text(acronym,
                      key: ValueKey(acronym),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 25)),
                  Text("High: $high\nLow: $low")
                ]),
                Text(val,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 20))
              ])),
    );
  }
}
