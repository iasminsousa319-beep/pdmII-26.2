import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;

  Database? db;

  try {
    String pathBanco = join(Directory.current.path, 'alunos.db');
    print('Caminho do banco de dados: $pathBanco');

    db = await databaseFactory.openDatabase(
      pathBanco,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (Database db, int version) async {
          try {
            await db.execute('''
              CREATE TABLE tb_alunos (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                nome TEXT NOT NULL,
                idade INTEGER NOT NULL
              )
            ''');
            print('Sucesso: Tabela "tb_alunos" criada na raiz do projeto.');
          } catch (e) {
            print('Erro ao criar a tabela: $e');
            rethrow;
          }
        },
      ),
    );

    try {
      await db.delete('tb_alunos');

      List<Map<String, dynamic>> alunosParaInserir = [
        {'nome': 'Ana Silva', 'idade': 20},
        {'nome': 'Carlos Oliveira', 'idade': 22},
        {'nome': 'Beatriz Souza', 'idade': 19},
      ];

      for (var aluno in alunosParaInserir) {
        int idInserido = await db.insert('tb_alunos', aluno);
        print('Sucesso: Inserido ${aluno['nome']} (ID: $idInserido)');
      }
    } catch (e) {
      print('Erro ao inserir alunos: $e');
    }
    try {
      print('\n--- Lista de Alunos no Banco (tb_alunos) ---');
      List<Map<String, dynamic>> alunos = await db.query('tb_alunos');

      if (alunos.isEmpty) {
        print('Nenhum aluno encontrado.');
      } else {
        for (var aluno in alunos) {
          print('ID: ${aluno['id']} | Nome: ${aluno['nome']} | Idade: ${aluno['idade']}');
        }
      }
    } catch (e) {
      print('Erro ao listar alunos: $e');
    }

  } catch (e, stackTrace) {
    print('Erro geral na conexão/operação do banco de dados: $e');
    print('Detalhes: $stackTrace');
  } finally {
    if (db != null && db.isOpen) {
      await db.close();
      print('\nConexão com o banco de dados encerrada.');
    }
  }
}