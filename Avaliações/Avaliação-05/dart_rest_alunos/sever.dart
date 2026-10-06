import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class Aluno {
  final int id;
  final String nome;
  final String disciplina;
  final double media;
  final int faltas;

  const Aluno({
    required this.id,
    required this.nome,
    required this.disciplina,
    required this.media,
    required this.faltas,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'disciplina': disciplina,
        'media': media,
        'faltas': faltas,
      };

  static Aluno fromJson(Map<String, dynamic> json) => Aluno(
        id: json['id'] as int,
        nome: json['nome'] as String,
        disciplina: json['disciplina'] as String,
        media: (json['media'] as num).toDouble(),
        faltas: json['faltas'] as int,
      );
}

final List<Aluno> alunos = [
  const Aluno(
    id: 1,
    nome: 'Ana Souza',
    disciplina: 'Programacao',
    media: 8.7,
    faltas: 5,
  ),
  const Aluno(
    id: 2,
    nome: 'Bruno Lima',
    disciplina: 'Banco de Dados',
    media: 5.5,
    faltas: 8,
  ),
  const Aluno(
    id: 3,
    nome: 'Carla Mendes',
    disciplina: 'Desenvolvimento Web',
    media: 9.2,
    faltas: 12,
  ),
  const Aluno(
    id: 4,
    nome: 'Diego Alves',
    disciplina: 'Programacao',
    media: 7.0,
    faltas: 25,
  ),
];

Response jsonResponse(
  Object body, {
  int status = 200,
}) {
  return Response(
    status,
    body: jsonEncode(body),
    headers: {
      'content-type': 'application/json; charset=utf-8',
    },
  );
}

Response _listarAlunos(Request request) {
  final query = request.url.queryParameters;

  var resultado = alunos;

  final nome = query['nome']?.toLowerCase();

  if (nome != null) {
    resultado = resultado
        .where(
          (aluno) => aluno.nome.toLowerCase().contains(nome),
        )
        .toList();
  }

  return jsonResponse({
    'total': resultado.length,
    'dados': resultado
        .map((aluno) => aluno.toJson())
        .toList(),
  });
}

Response _buscarAluno(Request request, String id) {
  final idNumerico = int.tryParse(id);

  if (idNumerico == null) {
    return jsonResponse(
      {'erro': 'O id deve ser um número inteiro.'},
      status: 400,
    );
  }

  final aluno = alunos
      .where((item) => item.id == idNumerico)
      .firstOrNull;

  if (aluno == null) {
    return jsonResponse(
      {'erro': 'Aluno não encontrado.'},
      status: 404,
    );
  }

  return jsonResponse(aluno.toJson());
}

Response _health(Request request) => jsonResponse({
      'status': 'ok',
      'servico': 'api-alunos',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });

Router createRouter() {
  final router = Router()
    ..get('/health', _health)
    ..get('/api/alunos', _listarAlunos)
    ..get('/api/alunos/<id>', _buscarAluno);

  return router;
}

Future<void> main() async {
  final port =
      int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;

  final address = InternetAddress.anyIPv4;

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(createRouter().call);

  final server = await shelf_io.serve(
    handler,
    address,
    port,
  );

  server.autoCompress = true;

  print(
    'Servidor iniciado em http://${server.address.host}:${server.port}',
  );
}