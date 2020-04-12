class EmissionDataService {
  double _personalGoal = 580.0;
  // Extracted mostly from https://ourworldindata.org/food-choice-vs-eating-local
  final Map<String, double> _emissions = {
    "Beef": 40.35,
    "Bread": 1.40,
    "Cheese": 21.20,
    "Chicken": 6.10,
    "Chocolate": 18.70,
    "Coffee": 16.50,
    "Eggs": 4.50,
    "Fish": 4.05,
    "Fruit": 0.53,
    "Juice": 0.96,
    "Milk": 2.80,
    "Olive Oil": 6.00,
    "Pasta": 1.20,
    "Palm Oil": 7.60,
    "Pig": 7.20,
    "Soymilk": 1.00,
    "Sunflower Oil": 3.50,
    "Tofu": 3.00,
    "Rice": 4.00,
    "Vegetables": 0.60,
  };

  double getEmissionForType(String type) {
    final emissions = _emissions[type];
    if (emissions == null) {
      return null;
    }
    return _emissions[type];
  }

  double getPersonalGoal() {
    return _personalGoal;
  }

  void setPersonalGoal(double value) {
    if (value != null && value > 0.0) {
      _personalGoal = value;
    }
  }
}
