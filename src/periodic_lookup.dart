import 'dart:io';
import 'constants.dart';

void main(List<String> args) {
  // retrieve periodic table data (NOW HARD CODED BECAUSE HAHAHA)
  //String content = File('../PeriodicTableJSON.json').readAsStringSync();
  //json = jsonDecode(content);
  
  // processes commands from cli args
  if (args.length != 0) {
    String t = '';
    args.forEach((e) {t += e + ' ';});

    processCmd(t);
    return;
  }

  // processes commands from stdin
  if (stdout.hasTerminal) {
    while (true) {
      stdout.write("> ");
      processCmd(stdin.readLineSync()!);
    }
  } else {
    String? s;
    while ((s = stdin.readLineSync()) != null) {
      processCmd(s!);
    }
  }
}

void processCmd(String input) {
  List<String> inputSplit = input.split(" ");

  switch (inputSplit[0]) {
    case "num":
    case "number":
    case "atomicNumber":
      printElements(search("number", int.parse(inputSplit[1]), json['elements'] as List<dynamic>));
      break;
    
    case 'symbol':
    case 'sym':
      printElements(search("symbol", inputSplit[1], json['elements'] as List<dynamic>));
      break;
    
    case "name":
    case "element":
    case "el":
      printElements(search("name", inputSplit[1].toLowerCase(), json['elements'] as List<dynamic>));
      break;
    
    case 'summode':
      printSummary = !printSummary;
      print('Summary Mode: ${printSummary ? 'On' : 'Off'}');
      break;
    
    case 'tolerance':
      if (inputSplit.length < 1 || num.tryParse(inputSplit[1]) == null) {
        print('failed.');
      } else {
        tolerance = num.tryParse(inputSplit[1])!;
        print('Tolerance: $tolerance');
      }
      break;
    
    case 'mass':
      num mass = num.parse(inputSplit[1]);
      for (var el in json['elements']) {
        if (el['atomic_mass'] >= mass - tolerance && el['atomic_mass'] <= mass + tolerance) {
          printElement(el);
        }
      }
      break;
    
    case 'group':
    case 'family':
    case 'fam':
      printElements(search("xpos", inputSplit[1], json['elements'] as List<dynamic>));
      break;
    
    case 'period':
    case 'per':
      printElements(search("period", inputSplit[1], json['elements'] as List<dynamic>));
      break;
    
    case 'gfm':
    case 'gramformulamass':
    case 'molarmass':
    case 'mm':
      print('Gram Formula Mass of ${inputSplit[1]}: ${calcGFM(collapseFormula(inputSplit[1]))}');
      break;
    
    case 'collapse':
      print('${inputSplit[1]} = ${collapseFormula(inputSplit[1])}');
      break;

    case 'help':
      print(HELP_MENU_TEXT);
      break;

    default:
      print("failed.");
  }
}

void printElements(List<Map<String, dynamic>> elements, {bool? summary}) {
  for (var el in elements)
    printElement(el);
}

void printElement(Map<String, dynamic> element, {bool? summary}) {
  if (summary == null)
    summary = printSummary;
  if (summary) {
    print(
'''Name: ${element['name']}
Symbol: ${element['symbol']}
Atomic Number: ${element['number']}
Atomic Mass: ${element['atomic_mass']} amu
Period: ${element['period']}
Group: ${element['xpos']}
Phase: ${element['phase']}
Category: ${element['category']}
Shells: ${element['shells']}
Oxidation States: ${element['oxidation_states']}
'''
      );
  } else {
    element.forEach((key, value) {
      print('$key: $value');
    });
  }
}