import 'dart:convert';
import 'dart:io';

import 'package:bitcoin_ticker/coin_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String apiKey = 'C9DF97EC-8D3F-40BE-B5D5-546B8A66EF0F';

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String selectedCurrency = currenciesList[0];
  Map<String, String> currencyMap = {};

  DropdownButton androidDropDown() {
    List<DropdownMenuItem<String>> items = [];
    for (String currency in currenciesList) {
      items.add(DropdownMenuItem(
        child: Text(currency),
        value: currency,
      ));
    }

    return DropdownButton(
      value: selectedCurrency,
      items: items,
      onChanged: (value) {
        selectedCurrency = value;
        getPrice('BTC', selectedCurrency);
        getPrice('ETH', selectedCurrency);
        getPrice('LTC', selectedCurrency);
        setState(() {});
      },
    );
  }

  CupertinoPicker iOSPicker() {
    List<Text> items = [];
    for (String currency in currenciesList) {
      items.add(Text(currency));
    }

    return CupertinoPicker(
      backgroundColor: Colors.lightBlue,
      itemExtent: 32.0,
      children: items,
      onSelectedItemChanged: (int value) {
        selectedCurrency = currenciesList[value];
        getPrice('BTC', selectedCurrency);
        getPrice('ETH', selectedCurrency);
        getPrice('LTC', selectedCurrency);
        setState(() {});
      },
    );
  }

  void getPrice(String crypID, String currencyID) async {
    var decodedResponse;
    var url =
        Uri.https('rest.coinapi.io', '/v1/exchangerate/$crypID/$currencyID');
    var headers = {'X-CoinAPI-Key': apiKey};
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      decodedResponse =
          await jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    } else {
      print('$url --> Response status: ${response.statusCode},'
          ' Response body: ${response.body}');
    }
    currencyMap[crypID] = decodedResponse["rate"].round().toString();
  }

  Padding getCard(String crypID) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
      child: Card(
        color: Colors.lightBlueAccent,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
          child: Text(
            '1 $crypID = ${currencyMap[crypID]} $selectedCurrency',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          getCard('BTC'),
          getCard('LTC'),
          getCard('ETH'),
          Container(
              height: 150.0,
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 30.0),
              color: Colors.lightBlue,
              child: Platform.isIOS ? iOSPicker() : androidDropDown()),
        ],
      ),
    );
  }
}
