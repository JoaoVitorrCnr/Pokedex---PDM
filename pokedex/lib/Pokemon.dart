import 'pokedex.dart';
import 'detalhePokemon.dart';


class Pokemon {
  final int id;
  final String nameEnglish;
  final List<String> type;
  final BaseStats base;
  final String imageUrl; // URL principal da imagem
  final String imageUrlDetalhes; // URL da imagem de detalhes

  const Pokemon({
    required this.id,
    required this.nameEnglish,
    required this.type,
    required this.base,
    required this.imageUrl,
    required this.imageUrlDetalhes, // Adicione este parâmetro
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    int pokemonId =
        json['id'] is String ? int.parse(json['id']) : json['id'] as int;

    return Pokemon(
      id: pokemonId,
      nameEnglish: json['name']['english'] as String,
      type: List<String>.from(json['type'] as List<dynamic>),
      base: BaseStats.fromJson(json['base'] as Map<String, dynamic>),
      imageUrl: getPokemonImageUrl(pokemonId), 
      imageUrlDetalhes: getImagemDetalhes(pokemonId), 
    );
  }
}

class BaseStats {
  final int hp;
  final int attack;
  final int defense;
  final int spAttack;
  final int spDefense;
  final int speed;

  const BaseStats({
    required this.hp,
    required this.attack,
    required this.defense,
    required this.spAttack,
    required this.spDefense,
    required this.speed,
  });

  factory BaseStats.fromJson(Map<String, dynamic> json) {
    return BaseStats(
      hp: json['HP'] as int,
      attack: json['Attack'] as int,
      defense: json['Defense'] as int,
      spAttack: json['Sp. Attack'] as int,
      spDefense: json['Sp. Defense'] as int,
      speed: json['Speed'] as int,
    );
  }
}
