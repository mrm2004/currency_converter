import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json-cors&key=19307b4a";


void main() async { // função asincrona, temos que esperar o retorno do get por isso await
  runApp(MaterialApp(
    home: new Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white
    ),
  ));
}



class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;


  void _realChanged(String text) {
    double real = double.parse(text); // converte o text para double
    dolarController.text = (real/dolar).toStringAsFixed(2); // duas casas decimasi
    euroController.text = (real/euro).toStringAsFixed(2); // duas casas decimasi
  }
  
  void _dolarChanged(String text) {
    double dolar = double.parse(text); // converte o text para double
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: new AppBar(
        title: Text("\$ Conversor \$", style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.amber,
      ),
      body: new FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: new Text("Carregando dados...", 
                  style: TextStyle(color: Colors.amber, fontSize: 25.0), 
                  textAlign: TextAlign.center,),
              );
            default: 
              if (snapshot.hasError) {
                return Center(
                child: new Text("Erro ao carregar dados...", 
                  style: TextStyle(color: Colors.amber, fontSize: 25.0), 
                  textAlign: TextAlign.center));
              } else {

                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(15.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      new Icon(Icons.monetization_on, size: 150.0, color: Colors.amber,),
                      Divider(),
                      buildTextField("Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField("Dólares", "US\$", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField("Euros", "€", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        }
      )
    );
  }

}


Future<Map> getData() async {
  http.Response response = await http.get(request);
  //print(response.body);
  return json.decode(response.body);
}


Widget buildTextField(String label, String prefix, TextEditingController textController, Function funcChanged) {
  return new TextField(
    controller: textController,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix
    ),
    style: TextStyle(fontSize: 25.0),
    onChanged: funcChanged,
    keyboardType: TextInputType.number,
  );
}