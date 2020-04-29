class EmissionDataService {
  // Extracted mostly from https://ourworldindata.org/food-choice-vs-eating-local
  final Map<String, double> _emissions = {
    "beef": 40.35,
    "bread": 1.40,
    "cheese": 21.20,
    "chicken": 6.10,
    "chocolate": 18.70,
    "coffee": 16.50,
    "eggs": 4.50,
    "fish": 4.05,
    "fruits": 0.53,
    "juice": 0.96,
    "lamb": 24.50,
    "milk": 2.80,
    "olive oil": 6.00,
    "pasta": 1.20,
    "palm oil": 7.60,
    "pork": 7.20,
    "plant-milk": 1.00,
    "plant-meat": 5.25,
    "sunflower oil": 3.50,
    "tea": 1.49,
    "tofu": 3.00,
    "rice": 4.00,
    "vegetables": 0.60,
  };

  final Map<String, String> _suggestions = {
    "beef": "plant-meat",
    // "bread": 1.40,
    // "cheese": 21.20,
    "chicken": "plant-meat",
    // "chocolate": 18.70,
    "coffee": "tea",
    // "eggs": 4.50,
    // "fish": 4.05,
    // "fruits": 0.53,
    // "juice": 0.96,
    "lamb": "plant-meat",
    "milk": "plant-milk",
    // "olive oil": 6.00,
    // "pasta": 1.20,
    // "palm oil": 7.60,
    "pork": "plant-meat",
    // "plant-milk": 1.00,
    // "sunflower oil": 3.50,
    // "tofu": 3.00,
    "rice": "pasta",
    // "vegetables": 0.60,
  };

  String getSuggestionForType(String type) {
    // If suggestion exists, use it.
    if (!_suggestions.containsKey(type)) {
      return null;
    }
    final suggestion =
        _suggestions.entries.firstWhere((entry) => entry.key == type).value;

    return suggestion;
  }

  double getSuggestionEmissionForType(String type) {
    final suggestion = _suggestions[type];
    // If suggestion exists, use it. Otherwise use emission for type
    if (suggestion != null) {
      return getEmissionForType(suggestion);
    }
    return getEmissionForType(type);
  }

  double getEmissionForType(String type) {
    final emissions = _emissions[type];
    if (emissions == null) {
      return null;
    }
    return emissions;
  }
}
