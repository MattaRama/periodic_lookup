import 'periodic_table.dart'; // periodic table data
import 'dart:convert'; // converts periodic table data to obj

Map<String, dynamic> json = jsonDecode(PERIODIC_TABLE);

bool printSummary = true; // print summary data or print all data
num tolerance = .5; // atomic mass lookup tolerance 

const HELP_MENU_TEXT = 
"""
Usage: pl {command} [arguments]

Commands:
  atomicnumber, number, num
    Finds an element by atomic number
    Ex: `atomicnumber 8`
  symbol, sym
    Finds an element by symbol
    Ex: `symbol O`
  element, el, name
    Finds an element by name
    Ex: `element oxygen`
  summode
    Toggles summary mode
    Ex: `summode`
  tolerance
    Sets the +/- tolerance for mass
    Ex: `tolerance .5`
  mass
    Finds elements based on mass +/- tolerance
    Ex: `mass 16`
  group, family, fam
    Finds elements based on P.T. group
    Ex: `group 16`
  period, per
    Finds elements based on P.T. period
    Ex: `period 2`
  gramformulamass, gfm, molarmass, mm
    Finds the gram formula mass of a substance by formula. CASE SENSITIVE!
    Ex: `gramformulamass O2`
  collapse
    Collapses a condensed structural formula into a molecular formula. CASE SENSITIVE!
    Ex: `collapse Fe(HO)2`
  help
    Displays help page
    Ex: `help`
""";

bool isNumeric(String str) {
  return int.tryParse(str) != null;
}

bool isAlphabetic(String str) {
  for (String i in str.split("")) {
    if (!"qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM".contains(i)) {
      return false;
    }
  }

  return true;
}

bool isCapital(String str) {
  for (String i in str.split('')) {
    if (!"QWERTYUIOPASDFGHJKLZXCVBNM".contains(i)) {
      return false;
    }
  }

  return true;
}

// searches JSON data
List<Map<String, dynamic>> search(String key, dynamic value, List<dynamic> json) {
  List<Map<String, dynamic>> ret = [];
  for (Map<String, dynamic> element in json) {
    if (element[key].toString().toLowerCase() == value.toString().toLowerCase()) {
      ret.add(element);
    }
  }

  return ret;
}

// Collapses a condensed structural formula into a molecular formula, returning a String
String collapseFormula(String formula) {
  var f = _collapseFormula(formula);
  String ret = "";
  num coeff = f.remove('coeff') ?? 1;

  f.forEach((key, value) {
    ret += key + (value * coeff).toString();
  });

  return ret;
}

// Collapses a condensed structural formula into a molecular formula, returning a map of symbols and subscripts
Map<String, num> _collapseFormula(String formula) {
  Map<String, num> el = Map<String, num>();

  // parses coeff, if it exists
  if (isNumeric(formula[0])) {
    String num = '';
    for (int i = 0; isNumeric(formula[i]); i++) {
      num += formula[i];
    }
    el['coeff'] = int.parse(num);
    formula = formula.remLeft(num.length);
  }

  // parses the rest of the equation
  for (int i = 0; i < formula.length; i++) {
    // if paranthesis is there, parse the value
    if (formula[i] == '(') {
      var indent = 1;
      var content = "";

      while (indent != 0) {
        i++;
        if (formula[i] == '(')
          indent++;
        else if (formula[i] == ')')
          indent--;
        
        if (content != 0)
          content += formula[i];
      }

      if (formula.length - 1 > i && isNumeric(formula[i + 1])) {
        String num = '';
        i++;
        for (; i < formula.length && isNumeric(formula[i]); i++) {
          num += formula[i];
        }
        content = num + content;
      }

      // merges into molecular formula (`el`)
      var x = _collapseFormula(content.remRight(1));
      num coeff = x.remove('coeff') ?? 1;
      
      x.forEach((key, value) {
        x[key] = x[key]! * coeff;
      });

      el.merge(x);

    } else if (isAlphabetic(formula[i])) {
      // parses element
      String ele = formula[i++];
      for (; i < formula.length && isAlphabetic(formula[i]); i++) {
        if (isCapital(formula[i]))
          break;
        else
          ele += formula[i];
      }

      // parses subscript (if it exists)
      num sub = 1;
      if (i < formula.length && isNumeric(formula[i])) {
        String num = '';
        for (; i < formula.length && isNumeric(formula[i]); i++) {
          num += formula[i];
        }
        sub = int.parse(num);
      }
      i--;

      el[ele] = sub + (el[ele] ?? 0);
    } else {
      throw Exception("Could not parse '${formula}': Invalid character placement");
    }
  }

  return el;
}

// ONLY ACCEPTS MOLECULAR FORMULAS, NOT CONDENSED STRUCTURAL FORMULAS
num calcGFM(String formula) {
  String buildEl = "";
  num total = 0;

  for (int i = 0; i < formula.length; i++) {
    if (isNumeric(formula[i])) {
      var el = search('symbol', buildEl, json['elements'])[0];
      
      String sub = "";
      for (; i < formula.length && isNumeric(formula[i]); i++) {
        sub += formula[i];
      }
      
      total += el['atomic_mass'] * int.parse(sub);
      i--;
      buildEl = "";
    } else {
      buildEl += formula[i];
    }
  }

  return total;
}

extension StringUtil on String {
  // removes characters from the left side of the string
  String remLeft(int x) {
    return this.substring(x);
  }

  // removes characters from the right side of the string
  String remRight(int x) {
    return this.substring(0, this.length - x);
  }
}

extension Merge on Map<String, num> {
  void merge(Map<String, num> a) {
    a.forEach((key, value) {
      this[key] = value + (this[key] ?? 0);
    });
  }
}