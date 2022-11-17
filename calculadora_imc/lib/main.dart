import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Home> {
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();

  GlobalKey<FormState> _chaveGlobal = GlobalKey<FormState>();

  String _infoText = "Informe os seus dados";

  void _resetFields() {
    weightController.text = "";
    heightController.text = "";
  setState(() {
    _infoText = "Informe os seus dados";
    _chaveGlobal = GlobalKey<FormState>();
  });
  }

  void _calculate() {
    double weight = double.parse(weightController.text);
    double height = double.parse(heightController.text) / 100;
    double imc = weight / (height * height);
    print(imc);
    setState(() {
      if (imc < 18.6) {
        _infoText = "${imc.toStringAsPrecision(4)} (Abaixo do peso)";
      } else if (imc >= 18.6 && imc <= 24.9) {
        _infoText = "${imc.toStringAsPrecision(4)} (Peso ideal)";
      } else if (imc >= 24.9 && imc <= 29.9) {
        _infoText = "${imc.toStringAsPrecision(4)} (Levemente acima do peso)";
      } else if (imc >= 29.9 && imc <= 34.9) {
        _infoText = "${imc.toStringAsPrecision(4)} (Obesidade grau I)";
      } else if (imc >= 34.9 && imc <= 39.9) {
        _infoText = "${imc.toStringAsPrecision(4)} (Obesidade grau II)";
      } else if (imc >= 40) {
        _infoText = "${imc.toStringAsPrecision(4)} (Obesidade grau III)";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Calculadora de IMC"),
          centerTitle: true,
          backgroundColor: Colors.green,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _resetFields,
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            child: Form(
            key: _chaveGlobal,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(Icons.person_outline, size: 120.0, color: Colors.green),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Peso (kg)",
                    labelStyle: TextStyle(color: Colors.green),
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green, fontSize: 25.0),
                  controller: weightController,
                  validator: (value) {
                    if (value.isEmpty){
                      return "Insira o seu peso!";
                    }
                  }
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Altura (cm)",
                    labelStyle: TextStyle(color: Colors.green),
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green, fontSize: 25.0),
                  controller: heightController,
                  validator: (value){
                    if (value.isEmpty){
                      return "Insira a sua altura!";
                    }
                  }
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Container(
                    height: 50.0,
                    child: RaisedButton(
                      onPressed: () {
                        if (_chaveGlobal.currentState.validate()){
                          _calculate();
                      }},
                      child: Text("Calcular",
                          style:
                              TextStyle(color: Colors.white, fontSize: 25.0)),
                      color: Colors.green,
                    ),
                  ),
                ),
                Text(
                  _infoText,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green, fontSize: 25),
                )
              ],
            ),
            )));
  }
}
