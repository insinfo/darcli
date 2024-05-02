import 'dart:math';

class InvalidCPFError extends Error {
  String toString() => 'The given CPF is not valid';
}

/// utilitarios para gerar e validar CPF
class CpfUtil {
  final random = Random();

  String format(String cpf) {
    if (cpf.length != 11) throw InvalidCPFError();

    final elements = cpf.split('');

    elements.insert(3, '.');
    elements.insert(7, '.');
    elements.insert(11, '-');

    return elements.reduce((a, b) => a += b);
  }

  String generate({int? state}) {
    var cpf = List<int>.generate(
      9,
      (index) => index == 8 ? state ?? random.nextInt(9) : random.nextInt(9),
      growable: true,
    );

    cpf.insert(9, _calculateVerifyingDigit(cpf));
    cpf.insert(10, _calculateVerifyingDigit(cpf));

    return format(cpf
        .map<String>((elements) => elements.toString())
        .reduce((a, b) => a += b));
  }

  String generateFrom(List<int> numbers) {
    if (numbers.isEmpty) return generate();

    late List<int> cpf;

    if (numbers.length >= 9) {
      cpf = numbers.sublist(0, 9).toList();
    } else {
      cpf = numbers.toList();
      cpf.addAll(
        List<int>.generate(
          9 - numbers.length,
          (index) => random.nextInt(9),
          growable: true,
        ),
      );
    }

    cpf.insert(9, _calculateVerifyingDigit(cpf));
    cpf.insert(10, _calculateVerifyingDigit(cpf));

    return format(cpf
        .map<String>((elements) => elements.toString())
        .reduce((a, b) => a += b));
  }

  int _calculateVerifyingDigit(List<int> cpf) {
    var sum = 0;
    var index = cpf.length + 1;

    cpf.forEach((element) {
      sum += element * index;
      index -= 1;
    });

    return ((sum % 11) < 2) ? 0 : 11 - (sum % 11);
  }

  /// corrigido por isaque em 09.02.2024
  bool validate(String cpf, {int? state}) {
    var valueCpf = cpf;
    if (valueCpf.length < 11) return false;

    valueCpf = valueCpf.replaceAll(RegExp(r'\D'), '');

    if (valueCpf.length < 11) return false;

    final invalidCombinations = List.generate(10, (index) => "$index" * 11);

    if (invalidCombinations.contains(valueCpf)) return false;

    var parsedCPF =
        valueCpf.split('').map<int>((element) => int.parse(element)).toList();

    return (state != null ? parsedCPF[8] == state : true) &&
        _calculateVerifyingDigit(parsedCPF.sublist(0, 9)) == parsedCPF[9] &&
        _calculateVerifyingDigit(parsedCPF.sublist(0, 10)) == parsedCPF[10];
  }
}
