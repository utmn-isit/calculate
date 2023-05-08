import 'dart:ffi';

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
  // String result = "0";
  String expression = "";
  Color buttonBackColor = const Color.fromRGBO(23, 23, 23, 1.0);

  String equation = ""; // строка для хранения уравнения
  String result = ""; // строка для хранения результата

  Map<String,String> config = {
    '+' : '+',
    '−' : '-',
    '×' : '*',
    '÷' : '/',
  };

  List<String> getKeysFromMap(Map map) {
    return ["+/-", ".", "÷", "×", "−", "+"];
  }

  calculateResult(equation) {
    try {
      if (equation.contains('/0')) {
        result = "Error";
      }
      double evalResult = Parser().parse(equation).evaluate(EvaluationType.REAL, ContextModel());
      if (evalResult % 1 == 0) {
        result = evalResult.toInt().toString();
      } else {
        result = evalResult.toString();
      }
      equation = result;
    } catch (e) {
      result = "Error";
    }
    return [equation, result];
  }

  buttonPressed(String buttonText) {
    setState(() {
      // нельзя писать если есть 0 в equat
      if (buttonText == "C") {
        equation = "";
        result = "0";
      } else if (buttonText == "+" || buttonText == "−" || buttonText == "×" || buttonText == "÷") {
        buttonText = config[buttonText]!;
        if (isOperator(equation.substring(equation.length - 1))) {
          equation = equation.substring(0, equation.length - 1);
        }
        if (equation != "") {
          var calc = calculateResult(equation);
          equation = calc[0];
          result = calc[1];
          equation += buttonText;
        } else if (equation == "") {
          equation = "0$buttonText";
          result = "0";
        }
      } else if (buttonText == "+/-") {
        if (result != "0" && !isOperator(equation.substring(equation.length - 1))) {
          var num = result;
          double number = double.parse(result);
          number = -number;
          if (number % 1 == 0) {
            result = number.toInt().toString();
          } else {
            result = number.toString();
          }
          // result = number.toString(); //-1 -> 1
          //можно добавлять result тока когда оператор нажали
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
        if ((equation != "" && isOperator(equation.substring(equation.length - 1))) || equation == "") {
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
    // setState(() {
    //   if (buttonText == "C") {
    //     expression = "";
    //     result = "0";
    //   } else if (buttonText == "=") {
    //     try {
    //       Parser p = Parser();
    //       Expression exp = p.parse(expression);
    //       ContextModel cm = ContextModel();
    //       result = '${exp.evaluate(EvaluationType.REAL, cm)}';
    //     } catch (e) {
    //       result = "Error";
    //     }
    //   } else {
    //     expression = expression + buttonText;
    //     if (!["+/-", ".", "÷", "×", "−", "+"].contains(buttonText)) {
    //       result = expression;
    //     }
    //   }
    // });
  }

  bool isOperator(String str) {
    return str == "+" || str == "-" || str == "*" || str == "/";
  }

  Widget buildButton(
      String buttonText, double buttonHeight, Color buttonColor, [double fontSize = 32]) {
    if (buttonText == '=') {
      buttonBackColor = const Color.fromRGBO(43, 132, 9, 1.0);
    } else {
      buttonBackColor = const Color.fromRGBO(23, 23, 23, 1.0);
    }
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: CircleAvatar(
        backgroundColor: buttonBackColor,
        radius: MediaQuery.of(context).size.height * 0.1 * buttonHeight / 1.8,
        child: TextButton(
          onPressed: () => buttonPressed(buttonText),
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
                  "$result\n$equation",
                  style: const TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(
                thickness: 1.8,
                color: Color.fromRGBO(45, 45, 45, 1.0)),
          ),
          Row(children: [
            Padding(
              padding: const EdgeInsets.all(7.0),
              child: Container(
                color: Colors.transparent,
                child: Container(
                    width: MediaQuery.of(context).size.height * 0.1 * 2.2 * 1.5 + 29,
                    height: MediaQuery.of(context).size.height * 0.1,
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(23, 23, 23, 1.0),
                        borderRadius:
                        BorderRadius.all(Radius.circular(99))),
                    child: Center(
                      child: TextButton(
                        onPressed: () => buttonPressed("C"),
                        child: const Text(
                          "C", style: TextStyle(
                            fontSize: 40,
                            color: Color.fromRGBO(245, 116, 117, 1)
                            // color: Colors.white
                          ),
                        ),
                      ),
                    )),
              ),
            ),
            buildButton(
                "÷", 1, const Color.fromRGBO(116, 202, 62, 1.0), 60),
          ]),
          Row(children: [
            buildButton("7", 1, Colors.white),
            buildButton("8", 1, Colors.white),
            buildButton("9", 1, Colors.white),
            buildButton("×", 1, const Color.fromRGBO(116, 202, 62, 1.0), 60),
          ]),
          Row(children: [
            buildButton("4", 1, Colors.white),
            buildButton("5", 1, Colors.white),
            buildButton("6", 1, Colors.white),
            buildButton("−", 1, const Color.fromRGBO(116, 202, 62, 1.0), 60),
          ]),
          Row(children: [
            buildButton("1", 1, Colors.white),
            buildButton("2", 1, Colors.white),
            buildButton("3", 1, Colors.white),
            buildButton("+", 1, const Color.fromRGBO(116, 202, 62, 1.0), 60),
          ]),
          Row(children: [
            buildButton("+/-", 1, Colors.white),
            buildButton("0", 1, Colors.white),
            buildButton(".", 1, Colors.white, 50),
            buildButton("=", 1, Colors.white, 60),
          ]),
        ],
      ),
    );
  }
}
