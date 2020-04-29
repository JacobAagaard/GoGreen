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
    "sunflower oil": 3.50,
    "tofu": 3.00,
    "rice": 4.00,
    "vegetables": 0.60,
  };

  double getEmissionForType(String type) {
    final emissions = _emissions[type];
    if (emissions == null) {
      return null;
    }
    return _emissions[type];
  }
}
