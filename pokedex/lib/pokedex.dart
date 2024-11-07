import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'database.dart';
import 'Pokemon.dart';
import 'detalhePokemon.dart';
import 'package:cached_network_image/cached_network_image.dart';

const int pageSize = 10; // Responsavel pelo número de itens de cada pagina

// Tela da Pokédex, onde a lista de Pokémons será exibida
class Pokedex extends StatefulWidget {
  const Pokedex({Key? key}) : super(key: key);

  @override
  _PokedexState createState() => _PokedexState();
}

class _PokedexState extends State<Pokedex> {
  final PagingController<int, Pokemon> _pagingController = PagingController(firstPageKey: 0); // Controlador para a paginação
  final DatabaseGeral dbPokemon = DatabaseGeral(); // Instância do banco de dados para gerenciar os Pokémons
  int contadorGlobal = 0; // Contador para gerenciar quantos Pokémons foram carregados até agora

  @override
  void initState() {
    super.initState();
    // Listener para quando uma nova página for requisitada
    _pagingController.addPageRequestListener((pageKey) {
      print('Requisitando página: $pageKey');
      _controladorPage(pageKey); // Chama a função que carrega os Pokémons da página
    });
  }

  // Função para controlar a requisição e carregamento de Pokémons
  Future<void> _controladorPage(int pageKey) async {
    try {
      int start = pageKey * pageSize; // Calcula o "start" para a requisição de acordo com a página
      final newPokemons = await buscarListaPaginada(start, pageSize); // Busca os Pokémons da página
      final isLastPage = newPokemons.length < pageSize; // Verifica se a página é a última

      // Salva os Pokémons exibidos no banco local
      for (var pokemon in newPokemons) {
        await dbPokemon.insertPokemon(pokemon);
      }

      // Se for a última página, adiciona todos os Pokémons e indica que não há mais páginas
      if (isLastPage) {
        _pagingController.appendLastPage(newPokemons);
      } else {
        contadorGlobal += newPokemons.length; // Atualiza o contador de Pokémons carregados
        final nextPageKey = pageKey + 1; // Calcula a próxima página
        _pagingController.appendPage(newPokemons, nextPageKey); // Adiciona a nova página de Pokémons
      }
    } catch (error) {
      print('Erro ao buscar pokémons, carregando do banco local...');
      // Se ocorrer erro, tenta carregar os Pokémons do banco local
      final savedPokemons = await dbPokemon.getAllPokemons(page: pageKey, limit: pageSize);

      if (savedPokemons.isNotEmpty) {
        _pagingController.appendLastPage(savedPokemons); // Adiciona os Pokémons encontrados no banco
      } else {
        _pagingController.error = error; // Se não encontrar Pokémons nem no banco, retorna o erro
      }
    }
  }

  @override
  void dispose() {
    _pagingController.dispose(); // Limpa o controlador de paginação quando a tela for descartada
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Fundo branco para o AppBar
        title: Text(
          'Pokédex',
          style: TextStyle(
            color: Colors.black, // Título preto para contrastar com o fundo branco
          ),
        ),
        elevation: 0, // Remove a sombra para deixar o AppBar mais clean
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('imagem/cdf814735cd82044e8fb47fd44578200.jpg'), // Imagem de fundo
            fit: BoxFit.cover, // Faz a imagem cobrir toda a tela
          ),
        ),
        child: PagedListView<int, Pokemon>( 
          pagingController: _pagingController, // Controlador da lista paginada
          builderDelegate: PagedChildBuilderDelegate<Pokemon>( // Função que constrói os itens da lista
            itemBuilder: (context, pokemon, index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  // Ao clicar no Pokémon, navega para a tela de detalhes
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalhesPokemon(
                        pokemon: pokemon,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 6, // Sombreamento para dar mais destaque ao card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Borda arredondada
                  ),
                  color: Colors.white, // Cor de fundo do card
                  child: Container(
                    padding: const EdgeInsets.all(12.0), // Padding para deixar o card mais espaçoso
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl: pokemon.imageUrl, // Imagem do Pokémon
                          height: 90, // Tamanho da imagem
                          width: 90,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => CircularProgressIndicator(), // Placeholder enquanto carrega
                          errorWidget: (context, url, error) => Icon(Icons.error), // Ícone de erro se a imagem não carregar
                        ),
                        SizedBox(width: 16), // Espaçamento entre a imagem e o texto
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nome: ${pokemon.nameEnglish}', 
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Cor do texto: preto
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tipos: ${pokemon.type.join(', ')}', // Exibe os tipos do Pokémon
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black, // Cor do texto: preto
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Função para buscar Pokémons com suporte a paginação
Future<List<Pokemon>> buscarListaPaginada(int start, int limit) async {
  final DatabaseGeral dbPokemon = DatabaseGeral();

  try {
    final response = await http.get(
      Uri.parse('https://d81c-177-20-136-227.ngrok-free.app/pokemons?_limit=$limit&_start=$start'),
    );

    if (response.statusCode == 200) { //response vai receber o corpo da requisição contendo os pokemons que vão ser decodificados
      List<dynamic> jsonData = json.decode(response.body);

      // vai inserir todos os pokemons dentro do jsonData
      for (var item in jsonData) {
        Pokemon pokemon = Pokemon.fromJson(item);
        await dbPokemon.insertPokemon(pokemon);
      }

      print('Requisição com _start $start: Recebido ${jsonData.length} Pokémon(s)');
      return jsonData.map((item) => Pokemon.fromJson(item)).toList(); // Retorna a lista de Pokémons
    } else {
      throw Exception('Erro ao carregar dados dos Pokémon');
    }
  } catch (e) {
    print('Erro ao buscar pokémons da API, carregando do banco local: $e');
    
    // Se houver erro, carrega os Pokémons do banco local
    final List<Pokemon> cachedPokemons = await dbPokemon.getAllPokemons(
      page: (start ~/ limit) + 1, // Calcula a página para buscar no banco // divisão inteira
      limit: limit, 
    );

    if (cachedPokemons.isNotEmpty) {
      print('Carregando ${cachedPokemons.length} pokémons do cache.');
    }
    
    return cachedPokemons; // Retorna os Pokémons armazenados localmente
  }
}

// Função auxiliar para obter a URL da imagem do Pokémon
String getPokemonImageUrl(int id) {
  return 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/refs/heads/master/sprites/${id.toString().padLeft(3, '0')}MS.png';
}
