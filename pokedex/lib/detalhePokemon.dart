import 'package:flutter/material.dart'; 
import 'package:cached_network_image/cached_network_image.dart'; 
import 'Pokemon.dart';  


class DetalhesPokemon extends StatelessWidget {
  final Pokemon pokemon;  

  const DetalhesPokemon({
    Key? key, 
    required this.pokemon, 
  }) : super(key: key);  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          pokemon.nameEnglish, 
          style: TextStyle(color: Colors.black), 
        ),
        elevation: 0, 
      ),
      backgroundColor: Colors.white, 
      body: SingleChildScrollView(  
        padding: const EdgeInsets.all(16.0),  
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,  
          children: [
            Center(
              child: CachedNetworkImage(
                imageUrl: pokemon.imageUrlDetalhes,  
                height: 200,  
                fit: BoxFit.contain,  
                placeholder: (context, url) => CircularProgressIndicator(), 
                errorWidget: (context, url, error) => Icon(Icons.error), 
              ),
            ),
            const SizedBox(height: 24), 
            Text(
              'ID: ${pokemon.id}', 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),  
            Text(
              'Nome: ${pokemon.nameEnglish}', 
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 8),  
            Text(
              'Tipos: ${pokemon.type.join(', ')}', 
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16), 
            Text(
              'Estatísticas',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8), 
            Container(
              padding: const EdgeInsets.all(16),  
              decoration: BoxDecoration(
                color: Colors.grey[200],  
                borderRadius: BorderRadius.circular(8),  
              ),
              child: Column(
                children: [
                  _buildStatRow('HP', pokemon.base.hp), 
                  _buildStatRow('Ataque', pokemon.base.attack), 
                  _buildStatRow('Defesa', pokemon.base.defense),  
                  _buildStatRow('Sp. Ataque', pokemon.base.spAttack),  
                  _buildStatRow('Sp. Defesa', pokemon.base.spDefense),  
                  _buildStatRow('Velocidade', pokemon.base.speed), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),  
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,  
        children: [
          Text(label, style: TextStyle(fontSize: 18)), 
          Text(value.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),  
        ],
      ),
    );
  }
}


String getImagemDetalhes(int id) {
  return 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/refs/heads/master/images/${id.toString().padLeft(3, '0')}.png';
}
