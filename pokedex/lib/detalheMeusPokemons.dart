import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Importa a biblioteca de cache
import 'package:awesome_dialog/awesome_dialog.dart'; // Importa a biblioteca awesome_dialog
import 'database.dart'; // Importe seu arquivo de banco de dados

class Detalhemeuspokemons extends StatelessWidget {
  final int pokemonId;
  const Detalhemeuspokemons({
    Key? key,
    required this.pokemonId,
  }) : super(key: key);

  // Função para buscar o Pokémon pelo ID do banco de dados ou cache
  Future<Map<String, dynamic>> getPokemonDetails(int id) async {
    final dbMeusPokemons = DatabaseGeral();
    final db = await dbMeusPokemons.database;

    // Obter o Pokémon da tabela 'MeusPokemons'
    List<Map<String, dynamic>> pokemonResults = await db.query(
      'MeusPokemons',
      where: 'id = ?',
      whereArgs: [id],
    );

    // Obter as estatísticas do Pokémon da tabela 'StatsMeusPokemons'
    List<Map<String, dynamic>> statsResults = await db.query(
      'StatsMeusPokemons',
      where: 'pokemonId = ?',
      whereArgs: [id],
    );

    if (pokemonResults.isNotEmpty) {
      final pokemon = pokemonResults.first;
      final stats = statsResults.isNotEmpty ? statsResults.first : {};

      // Combine os dados de 'MeusPokemons' e 'StatsMeusPokemons'
      return {
        'id': pokemon['id'],
        'nameEnglish': pokemon['nameEnglish'],
        'types': (pokemon['type'] as String).split(','),
        'imageUrlDetalhes': pokemon['imageUrlDetalhes'],
        'baseStats': {
          'hp': stats['hp'] ?? 'N/A',
          'attack': stats['attack'] ?? 'N/A',
          'defense': stats['defense'] ?? 'N/A',
          'spAttack': stats['spAttack'] ?? 'N/A',
          'spDefense': stats['spDefense'] ?? 'N/A',
          'speed': stats['speed'] ?? 'N/A',
        }
      };
    }

    // Caso o Pokémon não seja encontrado
    return {};
  }

  // Função para remover Pokémon
  Future<void> removePokemon(int id, BuildContext context) async {
    final dbMeusPokemons = DatabaseGeral();
    final db = await dbMeusPokemons.database;

    // Exibe uma caixa de diálogo de confirmação
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.topSlide,
      title: 'Confirmar',
      desc: 'Você tem certeza que deseja soltar este Pokémon?',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        // Remove o Pokémon do banco de dados
        await db.delete(
          'MeusPokemons',
          where: 'id = ?',
          whereArgs: [id],
        );

        // Exibe uma mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pokémon removido com sucesso!')),
        );

        // Retorna para a tela anterior
        Navigator.pop(context);
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Pokémon'),
        backgroundColor: Colors.white, // Fundo branco no AppBar
        elevation: 0, // Remove a sombra do AppBar
        iconTheme: IconThemeData(color: Colors.black), // Ícones pretos no AppBar
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getPokemonDetails(pokemonId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar Pokémon'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Pokémon não encontrado'));
          } else {
            final pokemon = snapshot.data!;

            // Dados do Pokémon
            final name = pokemon['nameEnglish'] ?? 'Nome não disponível';
            final id = pokemon['id'].toString();
            final types = pokemon['types'] != null && pokemon['types'].isNotEmpty
                ? pokemon['types'].join(', ')
                : 'Tipos não disponíveis';

            // Estatísticas base
            final baseStats = pokemon['baseStats'];
            final hp = baseStats['hp'];
            final attack = baseStats['attack'];
            final defense = baseStats['defense'];
            final spAttack = baseStats['spAttack'];
            final spDefense = baseStats['spDefense'];
            final speed = baseStats['speed'];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CachedNetworkImage(
                      imageUrl: pokemon['imageUrlDetalhes'],
                      height: 300,
                      fit: BoxFit.contain,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'ID: $id',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nome: $name',
                    style: TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tipos: $types',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Estatísticas:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Container para Estatísticas com fundo cinza
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Fundo cinza claro
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HP: $hp', style: TextStyle(fontSize: 18)),
                        Text('Ataque: $attack', style: TextStyle(fontSize: 18)),
                        Text('Defesa: $defense', style: TextStyle(fontSize: 18)),
                        Text('Sp. Ataque: $spAttack', style: TextStyle(fontSize: 18)),
                        Text('Sp. Defesa: $spDefense', style: TextStyle(fontSize: 18)),
                        Text('Velocidade: $speed', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      removePokemon(pokemonId, context);
                    },
                    child: Text('Soltar Pokémon'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}