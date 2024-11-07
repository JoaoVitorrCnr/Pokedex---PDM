import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'Pokemon.dart';
import 'detalhePokemon.dart';

class DatabaseGeral {
  static final DatabaseGeral _instance = DatabaseGeral._internal();
  Database? _database;

  factory DatabaseGeral() {
    return _instance;
  }

  DatabaseGeral._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'pokemon_database.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Pokemon (
            id INTEGER PRIMARY KEY,
            nameEnglish TEXT,
            type TEXT,
            imageUrl TEXT,
            imageUrlDetalhes TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE BaseStats (
            pokemonId INTEGER,
            hp INTEGER,
            attack INTEGER,
            defense INTEGER,
            spAttack INTEGER,
            spDefense INTEGER,
            speed INTEGER,
            FOREIGN KEY (pokemonId) REFERENCES Pokemon (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE MeusPokemons ( 
            id INTEGER,  -- Remover PRIMARY KEY
            nameEnglish TEXT, 
            type TEXT, 
            imageUrl TEXT, 
            imageUrlDetalhes TEXT 
          )
      ''');

        await db.execute('''
          CREATE TABLE StatsMeusPokemons (
            pokemonId INTEGER,
            hp INTEGER,
            attack INTEGER,
            defense INTEGER,
            spAttack INTEGER,
            spDefense INTEGER,
            speed INTEGER,
            FOREIGN KEY (pokemonId) REFERENCES MeusPokemons (id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE StatsMeusPokemons (
              pokemonId INTEGER,
              hp INTEGER,
              attack INTEGER,
              defense INTEGER,
              spAttack INTEGER,
              spDefense INTEGER,
              speed INTEGER,
              FOREIGN KEY (pokemonId) REFERENCES MeusPokemons (id)
            )
          ''');
        }
      },
    );
  }

  // Funções para tabela Pokemon e BaseStats
  Future<void> insertPokemon(Pokemon pokemon) async {
    final db = await database;
    String typesAsString = pokemon.type.join(',');
    final existingPokemon =
        await db.query('Pokemon', where: 'id = ?', whereArgs: [pokemon.id]);

    if (existingPokemon.isEmpty) {
      await db.insert('Pokemon', {
        'id': pokemon.id,
        'nameEnglish': pokemon.nameEnglish,
        'type': typesAsString,
        'imageUrl': pokemon.imageUrl,
        'imageUrlDetalhes': getImagemDetalhes(pokemon.id),
      });

      await db.insert('BaseStats', {
        'pokemonId': pokemon.id,
        'hp': pokemon.base.hp,
        'attack': pokemon.base.attack,
        'defense': pokemon.base.defense,
        'spAttack': pokemon.base.spAttack,
        'spDefense': pokemon.base.spDefense,
        'speed': pokemon.base.speed,
      });
    }
  }

  Future<Map<String, dynamic>> getPokemonById(int id) async {
    final db = await database;
    final pokemonData =
        await db.query('Pokemon', where: 'id = ?', whereArgs: [id]);
    final baseStatsData =
        await db.query('BaseStats', where: 'pokemonId = ?', whereArgs: [id]);

    if (pokemonData.isNotEmpty && baseStatsData.isNotEmpty) {
      final String typeString = pokemonData.first['type'] as String;
      final List<String> types = typeString.split(',');

      return {
        'pokemon': {
          'id': pokemonData.first['id'],
          'nameEnglish': pokemonData.first['nameEnglish'],
          'type': types,
          'imageUrl': pokemonData.first['imageUrl'],
          'imageUrlDetalhes': pokemonData.first['imageUrlDetalhes'],
        },
        'baseStats': baseStatsData.first,
      };
    } else {
      return {};
    }
  }

  // Funções para tabela MeusPokemons e StatsMeusPokemons
  Future<bool> insertMeusPokemon(Pokemon pokemon) async {
  final db = await database;

  // Conta quantos pokémons já estão na tabela 'MeusPokemons'
  int pokemonCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM MeusPokemons'),
      ) ?? 0;

  // Verifica se já atingiu o limite de 6 pokémons
  if (pokemonCount >= 6) return false;

  String typesAsString = pokemon.type.join(',');

  // Inserir o Pokémon na tabela 'MeusPokemons'
  int result = await db.insert('MeusPokemons', {
    'id': pokemon.id,
    'nameEnglish': pokemon.nameEnglish,
    'type': typesAsString,
    'imageUrl': pokemon.imageUrl,
    'imageUrlDetalhes': pokemon.imageUrlDetalhes,
  });

  // Imprimir o resultado da inserção
  if (result > 0) {
    print("Pokémon ${pokemon.nameEnglish} com ID ${pokemon.id} foi capturado e inserido.");
  } else {
    print("Falha ao capturar o Pokémon ${pokemon.nameEnglish}. Inserção não foi bem-sucedida.");
  }

  // Inserir as estatísticas do Pokémon na tabela 'StatsMeusPokemons'
  await db.insert('StatsMeusPokemons', {
    'pokemonId': pokemon.id,
    'hp': pokemon.base.hp,
    'attack': pokemon.base.attack,
    'defense': pokemon.base.defense,
    'spAttack': pokemon.base.spAttack,
    'spDefense': pokemon.base.spDefense,
    'speed': pokemon.base.speed,
  });

  return true;
}

  //função para a paginação
  Future<List<Pokemon>> getAllPokemons({required int page, required int limit}) async {
  final db = await database;
  final offset = (page - 1) * limit;

  final List<Map<String, dynamic>> pokemonList = await db.query(
    'Pokemon',
    limit: limit,
    offset: offset,
  );

  if (pokemonList.isEmpty) {
    return [];
  }

  return pokemonList.map((item) {
    final String typeString = item['type'] as String;
    final List<String> types = typeString.split(',');

    return Pokemon(
      id: item['id'],
      nameEnglish: item['nameEnglish'],
      type: types,
      base: const BaseStats(
        hp: 0,
        attack: 0,
        defense: 0,
        spAttack: 0,
        spDefense: 0,
        speed: 0,
      ),
      imageUrl: item['imageUrl'],
      imageUrlDetalhes: item['imageUrlDetalhes'],
    );
  }).toList();
}

  Future<List<int>> getAllMeusPokemonIds() async {
    final db = await database;
    List<Map<String, dynamic>> results =
        await db.query('MeusPokemons', columns: ['id']);
    return results.map((e) => e['id'] as int).toList();
  }

  Future<Map<String, dynamic>> getMeusPokemonById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'MeusPokemons',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : {};
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}