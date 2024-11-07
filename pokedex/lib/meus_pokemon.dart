import 'package:flutter/material.dart';
import 'database.dart';
import 'Pokemon.dart'; // Certifique-se de importar a classe Pokemon.
import 'detalheMeusPokemons.dart';

Future<List<Pokemon>> getAllMeusPokemons() async {
  final db = await DatabaseGeral().database;

  // Consulta todos os registros da tabela 'MeusPokemons'
  final List<Map<String, dynamic>> results = await db.query('MeusPokemons');

  // Converte os dados obtidos em uma lista de objetos Pokemon
  List<Pokemon> meusPokemons = results.map((pokemonData) {
    // Descompacta o campo 'type' para transformá-lo em uma lista de strings
    final String typeString = pokemonData['type'] as String;
    final List<String> types = typeString.split(',');

    return Pokemon(
      id: pokemonData['id'],
      nameEnglish: pokemonData['nameEnglish'],
      type: types,
      base: BaseStats(
        hp: 0,
        attack: 0,
        defense: 0,
        spAttack: 0,
        spDefense: 0,
        speed: 0,
      ), // Valor padrão para 'base' (caso não esteja usando esta informação)
      imageUrl: pokemonData['imageUrl'],
      imageUrlDetalhes: pokemonData['imageUrlDetalhes'],
    );
  }).toList();

  // Exibe os Pokémons carregados para depuração
  print("Meus Pokémons carregados: $meusPokemons");

  return meusPokemons;
}

class PokemonCardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Pokémons'),
        centerTitle: true, // Centraliza o título
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Pokemon>>(
          future: getAllMeusPokemons(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar Pokémons'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Nenhum Pokémon encontrado'));
            } else {
              final pokemons = snapshot.data!;
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,  // 2 itens por linha
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75, // Ajuste da proporção do card (largura x altura)
                ),
                itemCount: pokemons.length,
                itemBuilder: (context, index) {
                  final pokemon = pokemons[index];
                  return GestureDetector(
                    onTap: () {
                      // Navega para a tela de detalhes do Pokémon
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Detalhemeuspokemons(
                            pokemonId: pokemon.id, // Passa o ID do Pokémon
                          ),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0), // Bordas arredondadas
                      ),
                      elevation: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Column(
                          children: [
                            // Imagem do Pokémon
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                pokemon.imageUrl,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 8),
                            // Nome do Pokémon
                            Text(
                              pokemon.nameEnglish,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            // Tipos do Pokémon
                            Text(
                              'Tipos: ${pokemon.type.join(', ')}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
