// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';

Uri requisicao =
    Uri.parse('https://api.hgbrasil.com/finance?format=json-cors&key=4af11e65');

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final realControlador = TextEditingController();
  final dolarControlador = TextEditingController();
  final euroControlador = TextEditingController();
  final bitcoinControlador = TextEditingController();

  double dolar = 0;
  double real = 0;
  double euro = 0;
  double bitcoin = 0;

  

  void _realMudou(String texto) {
    if (texto.isEmpty) {
      _limparSeEstarVazio();
      return;
    }

    double real = double.parse(texto.replaceAll(',', '.'));
    dolarControlador.text = formatarMoeda.format(real / dolar);
    euroControlador.text = formatarMoeda.format(real / euro);
    bitcoinControlador.text = (real / bitcoin).toStringAsFixed(8);
  }

  void _dolarMudou(String texto) {
    if (texto.isEmpty) {
      _limparSeEstarVazio();
      return;
    }

    double dolar = double.parse(texto.replaceAll(',', '.'));
    realControlador.text = formatarMoeda.format(dolar * this.dolar);
    euroControlador.text = formatarMoeda.format(dolar * this.dolar / euro);
    bitcoinControlador.text = (dolar * this.dolar / bitcoin).toStringAsFixed(8);

  }

  void _euroMudou(String texto) {
    if (texto.isEmpty) {
      _limparSeEstarVazio();
      return;
    }

    double euro = double.parse(texto.replaceAll(',', '.'));
    realControlador.text = formatarMoeda.format(1 * this.euro);
    dolarControlador.text = formatarMoeda.format(euro * this.euro / dolar);
    bitcoinControlador.text = (euro * this.euro / bitcoin).toStringAsFixed(8);
  }

  void _bitcoinMudou(String texto) {
    if (texto.isEmpty) {
      _limparSeEstarVazio();
      return;
    }

    double bitcoin = double.parse(texto.replaceAll(',', '.'));
    realControlador.text = formatarMoeda.format(1 * this.bitcoin);
    dolarControlador.text = formatarMoeda.format(bitcoin * this.bitcoin / dolar);
    euroControlador.text = formatarMoeda.format(bitcoin * this.bitcoin / euro);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('\$ Conversor \$'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: pegarDados(),
        builder: (context, instantaneamente) {
          switch (instantaneamente.connectionState) {
            case ConnectionState.active:
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Container(
                  color: Colors.black,
                  child: Text(
                    'Carregando dados...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0,
                    ),
                  ),
                ),
              );
            case ConnectionState.done:
              if (instantaneamente.hasError) {
                return Center(
                  child: Container(
                    color: Colors.black,
                    child: Text(
                      'Erro no carregamento dos dados :(',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                );
              } else {
                dolar = instantaneamente.data!['results']['currencies']['USD']
                    ['buy'];
                euro = instantaneamente.data!['results']['currencies']['EUR']
                    ['buy'];
                bitcoin = instantaneamente.data!['results']['currencies']['BTC']
                    ['buy'];
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 150,
                      ),
                      campoDeTextoMoeda(
                          'R\$ ', 'Reais', realControlador, _realMudou),
                      campoDeTextoMoeda(
                          'U\$ ', 'Dolar', dolarControlador, _dolarMudou),
                      campoDeTextoMoeda(
                          '€   ', 'Euro', euroControlador, _euroMudou),
                      campoDeTextoMoeda(
                          '₿   ', 'Bitcoin', bitcoinControlador, _bitcoinMudou),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }

  void _limparSeEstarVazio() {
    realControlador.text = '';
    dolarControlador.text = '';
    euroControlador.text = '';
    bitcoinControlador.text = '';
  }

  var formatarMoeda = NumberFormat.currency(
    locale: 'pt_br',
    decimalDigits: 2,
    name: '',
  );

}

Widget campoDeTextoMoeda(
    String prefix, String label, TextEditingController c, Function(String) f) {
  return Padding(
    padding: const EdgeInsets.only(
      left: 15.0,
      right: 15.0,
      top: 7.5,
      bottom: 7.5,
    ),
    child: TextField(
      controller: c,
      onChanged: f,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*$'))],
      cursorColor: Colors.white,
      decoration: InputDecoration(
        prefixText: prefix,
        labelText: label,
      ),
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    ),
  );
}

Future<Map> pegarDados() async {
  http.Response resposta = await http.get(requisicao);
  return json.decode(resposta.body);
}