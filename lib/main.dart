import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Map _dados;
List _features;

void main() async {
  _dados = await getTerremotos();

  _features = _dados['features'];

  runApp(new MaterialApp(
    title: 'Terremotos',
    home: new Terremotos(),
  ));
}

class Terremotos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Terromotos'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: new Center(
        child: new ListView.builder(
          itemCount: _features.length,
          padding: const EdgeInsets.all(15.0),
          itemBuilder: retornaItemBuilder,
        ),
      ),
    );
  }

  Widget retornaItemBuilder(BuildContext contexto, int posicao) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Padding(
          padding: new EdgeInsets.all(5.0),
          child: retornaListTile(contexto, posicao),
        ),
        new Divider(
          height: 5.0,
        ),
      ],
    );
  }

  retornaListTile(BuildContext contexto, int posicao) {
    var _diaDateTime = retornaDia(posicao);

    var _formato = new DateFormat("dd/MM/yyyy HH:mm");
    var _dia = _formato.format(_diaDateTime);

    return new ListTile(
        title: new Text(
          "Em: $_dia",
          style: new TextStyle(
            fontSize: 19.5,
            color: Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: new Text(
          " ${_features[posicao]['properties']['place']}",
          style: new TextStyle(
            fontSize: 14.5,
            color: Colors.grey,
            fontWeight: FontWeight.normal,
            fontStyle: FontStyle.italic,
          ),
        ),
        leading: new CircleAvatar(
          backgroundColor: Colors.green,
          child: new Text(
            "${_features[posicao]['properties']['mag']}",
            style: new TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
      onTap: (){
          _mostraMensagemAlerta(contexto, "${_features[posicao]['properties']['title']}");
      },


    );
  }

  //https://pub.dartlang.org/packages/intl
  DateTime retornaDia(int posicao) =>
      new DateTime.fromMicrosecondsSinceEpoch(
          _features[posicao]['properties']['time'] * 1000,
          isUtc: true);

  _mostraMensagemAlerta(BuildContext contexto, String mensagem) {
    var alerta = new AlertDialog(
      title: new Text(
          "Terremotos"
      ),
      content: new Text(mensagem),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              Navigator.pop(contexto);
            },
            child: new Text("Ok"))
      ],
    );
    showDialog(context: contexto, builder: (contexto) => alerta);
  }
}

Future<Map> getTerremotos() async {
  String url =
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson';

  http.Response response = await http.get(url);

  return json.decode(response.body);
}
