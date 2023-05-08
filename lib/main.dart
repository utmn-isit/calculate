import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Калькулятор',
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromRGBO(1, 2, 2, 1.0),
          colorScheme: const ColorScheme.dark()),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color buttonBackColor = const Color.fromRGBO(23, 23, 23, 1.0);

  String equation = "";
  String result = "0";

  Map<String, String> config = {
    '+': '+',
    '−': '-',
    '×': '*',
    '÷': '/',
  };

  List<String> getKeysFromMap(Map map) {
    return ["+/-", ".", "÷", "×", "−", "+"];
  }

  calculateResult(equation) {
    try {
      double evalResult = Parser()
          .parse(equation)
          .evaluate(EvaluationType.REAL, ContextModel());
      if (evalResult % 1 == 0) {
        result = evalResult.toInt().toString();
      } else {
        result = evalResult.toString();
      }
      equation = result;
    } catch (e) {
      result = "Error";
    }
    if (result == 'Infinity' || result == 'NaN') {
      result = "Error";
    }
    return [equation, result];
  }

  buttonPressed(String buttonText) {
    setState(() {
      if (result == 'Error') {
        result = "0";
        equation = "";
      }
      if (buttonText == "C") {
        equation = "";
        result = "0";
      } else if (buttonText == "+" ||
          buttonText == "−" ||
          buttonText == "×" ||
          buttonText == "÷") {
        buttonText = config[buttonText]!;
        if (equation.isNotEmpty &&
            isOperator(equation.substring(equation.length - 1))) {
          equation = equation.substring(0, equation.length - 1);
        }
        if (equation != "") {
          var calc = calculateResult(equation);
          equation = calc[0];
          result = calc[1];
          equation += buttonText;
        } else {
          equation = "0$buttonText";
          result = "0";
        }
      } else if (buttonText == "+/-") {
        if (result != "0" &&
            !isOperator(equation.substring(equation.length - 1))) {
          var num = result;
          double number = double.parse(result);
          number = -number;
          if (number % 1 == 0) {
            result = number.toInt().toString();
          } else {
            result = number.toString();
          }
          var lastIndexResult = equation.lastIndexOf(num);
          if (equation.contains("(-")) {
            lastIndexResult -= 1;
          }
          if (number < 0) {
            equation = "${equation.substring(0, lastIndexResult)}(-$num)";
          } else {
            equation = "${equation.substring(0, lastIndexResult)}$result";
          }
        }
      } else if (buttonText == ".") {
        if ((equation != "" &&
                isOperator(equation.substring(equation.length - 1))) ||
            equation == "") {
          result = "0.";
          equation += "0.";
        } else if (!result.contains(".")) {
          result += ".";
          equation += ".";
        }
      } else if (buttonText == "=") {
        if (isOperator(equation.substring(equation.length - 1))) {
          equation = equation.substring(0, equation.length - 1);
        }
        if (equation != "") {
          var calc = calculateResult(equation);
          equation = calc[0];
          result = calc[1];
        }
      } else {
        if (result == "0") {
          result = buttonText;
        } else {
          if (isOperator(equation.substring(equation.length - 1))) {
            result = buttonText;
          } else {
            result += buttonText;
          }
        }
        if (equation == "0") {
          equation = buttonText;
        } else {
          equation += buttonText;
        }
      }
    });
  }

  bool isOperator(String str) {
    return str == "+" || str == "-" || str == "*" || str == "/";
  }

  Widget buildButton(String buttonText, Color buttonColor, {int flex = 1, double fontSize = 32}) {
    if (buttonText == '=') {
      buttonBackColor = const Color.fromRGBO(43, 132, 9, 1.0);
    } else {
      buttonBackColor = const Color.fromRGBO(23, 23, 23, 1.0);
    }

    final radius = BorderRadius.circular(
        MediaQuery.of(context).size.height * 0.1 / 1.8);

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: SizedBox(
          height: radius.bottomLeft.x * 1.8,
          child: Material(
            color: buttonBackColor,
            borderRadius: radius,
            child: InkWell(
              onTap: () => buttonPressed(buttonText),
              borderRadius: radius,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.normal,
                    color: buttonColor,
                  ),
                ),
              ),
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
        title: const Text('Калькулятор'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                alignment: Alignment.bottomRight,
                child: Text(
                  result,
                  style: const TextStyle(fontSize: 56, color: Colors.white),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 3),
            child:
                Divider(thickness: 1.8, color: Color.fromRGBO(45, 45, 45, 1.0)),
          ),
          Row(children: [
            buildButton('C', const Color.fromRGBO(245, 116, 117, 1),
                flex: 3),
            buildButton("÷", const Color.fromRGBO(116, 202, 62, 1.0),
                fontSize: 60),
          ]),
          Row(children: [
            buildButton("7", Colors.white),
            buildButton("8", Colors.white),
            buildButton("9", Colors.white),
            buildButton("×", const Color.fromRGBO(116, 202, 62, 1.0),
                fontSize: 60),
          ]),
          Row(children: [
            buildButton("4", Colors.white),
            buildButton("5", Colors.white),
            buildButton("6", Colors.white),
            buildButton("−", const Color.fromRGBO(116, 202, 62, 1.0),
                fontSize: 60),
          ]),
          Row(children: [
            buildButton("1", Colors.white),
            buildButton("2", Colors.white),
            buildButton("3", Colors.white),
            buildButton("+", const Color.fromRGBO(116, 202, 62, 1.0),
                fontSize: 60),
          ]),
          Row(children: [
            buildButton("+/-", Colors.white),
            buildButton("0", Colors.white),
            buildButton(".", Colors.white, fontSize: 50),
            buildButton("=", Colors.white, fontSize: 60),
          ]),
        ],
      ),
    );
  }
}
