import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final url = Uri.parse('http://localhost:8080/api/alunos');

  final resposta = await http.get(url);

  if (resposta.statusCode == 200) {
    final resultado = jsonDecode(resposta.body);

    final alunos = resultado['dados'];

    print('ID NOME DISCIPLINA MEDIA FALTAS MENSAGEM');

    for (final aluno in alunos) {
      String mensagem;

      if (aluno['faltas'] > 20) {
        mensagem = 'Reprovado por Faltas';
      } else if (aluno['media'] < 6.0) {
        mensagem = 'Reprovado';
      } else {
        mensagem = 'Aprovado';
      }

      print(
        '${aluno['id']} '
        '${aluno['nome']} '
        '${aluno['disciplina']} '
        '${aluno['media']} '
        '${aluno['faltas']} '
        '$mensagem',
      );
    }
  } else {
    print('Erro ao acessar o servidor: ${resposta.statusCode}');
  }
}