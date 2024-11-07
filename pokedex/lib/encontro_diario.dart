import 'dart:convert'; 
import 'dart:math'; 
import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'Pokemon.dart'; 
import 'detalhePokemon.dart';
import 'meus_pokemon.dart';  
import 'database.dart';  


class EncontroDiario extends StatefulWidget {
  @override
  _EncontroDiario createState() => _EncontroDiario();  
}

// Classe que gerencia o estado da tela 
class _EncontroDiario extends State<EncontroDiario> {
  Pokemon? _pokemon;  
  String? _lastDate;  
  bool _alreadyCapturedToday = false;  

  @override
  void initState() {
    super.initState();
    _loadPokemon(); 
  }

  // Função que carrega o Pokémon baseado na data de hoje
  Future<void> _loadPokemon() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  // Obtém as preferências compartilhadas (armazenamento local)
    _lastDate = prefs.getString('lastDate');  // Pega a data do último encontro

    String today = DateTime.now().toIso8601String().split('T')[0];  
    
    // Se a data de hoje for igual à última data registrada, verifica se o Pokémon já foi capturado
    if (_lastDate == today) {
      _alreadyCapturedToday = true; 
      String? savedPokemonId = prefs.getString('lastPokemonId');  // Pega o ID do último Pokémon capturado

      if (savedPokemonId != null) {
        int pokemonId = int.parse(savedPokemonId);  // Converte o ID salvo para inteiro
        await _fetchPokemon(pokemonId); 
        return; 
      }
    } else {
      // Se a data for diferente, gera um ID aleatório para um Pokémon
      int randomId = Random().nextInt(809) + 1;  
      await _fetchPokemon(randomId); 
      await prefs.setString('lastDate', today);
      await prefs.setString('lastPokemonId', randomId.toString());
      _alreadyCapturedToday = false;  
    }
    setState(() {});  
  }

  // Função que busca os dados do Pokémon através de uma requisição HTTP
  Future<void> _fetchPokemon(int pokemonId) async {
    try {
      final response = await http.get(Uri.parse('https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/pokedex.json'));  // Faz a requisição para buscar os dados dos Pokémons

      if (response.statusCode == 200) {  
        List<dynamic> pokedex = json.decode(response.body);  
        var pokemonData = pokedex.firstWhere((pokemon) => pokemon["id"] == pokemonId, orElse: () => null);  // Busca o Pokémon com o ID correspondente

        if (pokemonData != null) {
          Pokemon pokemon = Pokemon.fromJson(pokemonData); 
          setState(() {
            _pokemon = pokemon;  // Atribui o Pokémon encontrado à variável _pokemon
          });
        } else {
          throw Exception('Pokémon com ID $pokemonId não encontrado'); 
        }
      } else {
        throw Exception('Erro ao carregar dados do GitHub'); 
      }
    } catch (e) {
      print('Erro: $e');  
    }
  }

  // Função que lida com a captura do Pokémon
  Future<void> _capturarPokemon() async {
    if (_pokemon != null && !_alreadyCapturedToday) {  // Verifica se há um Pokémon e se ainda não foi capturado hoje
      bool podeNavegar = await DatabaseGeral().insertMeusPokemon(_pokemon!);  // Tenta salvar o Pokémon no banco de dados

      if (podeNavegar) {  // Se o Pokémon foi capturado com sucesso
        SharedPreferences prefs = await SharedPreferences.getInstance();  // Obtém as preferências compartilhadas
        await prefs.setString('lastDate', DateTime.now().toIso8601String().split('T')[0]);  // Atualiza a data do último encontro
        await prefs.setString('lastPokemonId', _pokemon!.id.toString());  // Atualiza o ID do último Pokémon capturado
        
        Navigator.push(  // Navega para a tela do card do Pokémon
          context,
          MaterialPageRoute(
            builder: (context) => PokemonCardScreen(),
          ),
        );
      } else {
        _showDialog('Limite atingido', 'Você já possui 6 Pokémon capturados!');  // Se o limite for atingido, exibe um alerta
      }
    } else if (_alreadyCapturedToday) {
      _showDialog('Captura diária', 'Esse Pokémon já foi capturado hoje!');  // Se o Pokémon já foi capturado hoje, exibe um alerta
    }
  }

  // Função que exibe um diálogo de alerta
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Fecha o diálogo quando o botão "OK" é pressionado
              },
              child: Text("OK", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Encontro Diário'),  
          backgroundColor: Colors.white,   
          automaticallyImplyLeading: false,  
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('imagem/Floresta.jpg'), 
              fit: BoxFit.cover, 
            ),
          ),
          child: Center(
            child: _pokemon != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(  // Exibe a imagem do Pokémon
                        getImagemDetalhes(_pokemon!.id),  
                        height: 200,
                        width: 200,
                      ),
                      SizedBox(height: 20),
                      Text(
                        _pokemon!.nameEnglish,  
                        style: TextStyle(fontSize: 24, color: const Color.fromARGB(255, 99, 99, 99)),  // Estilo do texto
                      ),
                      SizedBox(height: 20),
                      ElevatedButton( 
                        onPressed: _capturarPokemon, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, 
                          foregroundColor: Colors.green, 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),  
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),  
                        ),
                        child: Text(
                          'Capturar',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.green, 
                          ),
                        ),
                      ),
                    ],
                  )
                : Text('Nenhum Pokémon disponível.', style: TextStyle(color: Colors.white)), 
          ),
        ),
      ),
    );
  }
}
