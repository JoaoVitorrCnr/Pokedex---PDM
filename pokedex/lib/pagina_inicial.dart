import 'package:flutter/material.dart';
import 'pokedex.dart';
import 'encontro_diario.dart';
import 'meus_pokemon.dart';

class PaginaInicial extends StatelessWidget {
  const PaginaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Usando um container com decoração para definir o fundo
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('imagem/da232e027d0e7f2d24bc68f27186c2da.jpg'),
            fit: BoxFit.cover, // Faz a imagem cobrir toda a tela
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24), // Espaço inferior maior
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Pokedex()),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 255, 255, 255)), // Cor de fundo
                    foregroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 22, 22, 22)), // Cor da letra
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>( // Define a forma do botão
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Botão mais arredondado
                      ),
                    ),
                    side: MaterialStateProperty.all<BorderSide>( // Responsável pela borda
                      const BorderSide(color: Color.fromARGB(255, 219, 219, 219), width: 2), // Borda mais grossa
                    ),
                  ),
                  child: const SizedBox(
                    width: 200, // Largura maior
                    height: 50, // Altura maior
                    child: Center(
                      child: Text(
                        'Pokédex',
                        style: TextStyle(fontSize: 18), // Tamanho de fonte maior
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24), // Espaço inferior maior
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EncontroDiario()),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 255, 255, 255)), // Cor de fundo
                    foregroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 22, 22, 22)), // Cor da letra
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>( // Define a forma do botão
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Botão mais arredondado
                      ),
                    ),
                    side: MaterialStateProperty.all<BorderSide>( // Responsável pela borda
                      const BorderSide(color: Color.fromARGB(255, 219, 219, 219), width: 2), // Borda mais grossa
                    ),
                  ),
                  child: const SizedBox(
                    width: 200, // Largura maior
                    height: 50, // Altura maior
                    child: Center(
                      child: Text(
                        'Encontro Diário',
                        style: TextStyle(fontSize: 18), // Tamanho de fonte maior
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24), // Espaço inferior maior
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PokemonCardScreen()),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 255, 255, 255)), // Cor de fundo
                    foregroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 22, 22, 22)), // Cor da letra
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>( // Define a forma do botão
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Botão mais arredondado
                      ),
                    ),
                    side: MaterialStateProperty.all<BorderSide>( // Responsável pela borda
                      const BorderSide(color: Color.fromARGB(255, 219, 219, 219), width: 2), // Borda mais grossa
                    ),
                  ),
                  child: const SizedBox(
                    width: 200, // Largura maior
                    height: 50, // Altura maior
                    child: Center(
                      child: Text(
                        'Meus Pokémon',
                        style: TextStyle(fontSize: 18), // Tamanho de fonte maior
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
