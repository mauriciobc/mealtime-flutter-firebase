import 'package:flutter/material.dart';
import 'package:mealtime/models/household_model.dart';

class HouseholdProvider with ChangeNotifier {
  Household? _currentHousehold;
  List<Household> _userHouseholds = [];

  Household? get currentHousehold => _currentHousehold;
  List<Household> get userHouseholds => _userHouseholds;

  void setCurrentHousehold(Household? household) {
    _currentHousehold = household;
    notifyListeners();
  }

  void setUserHouseholds(List<Household> households) {
    _userHouseholds = households;
    notifyListeners();
  }

  void addHousehold(Household household) {
    _userHouseholds.add(household);
    notifyListeners();
  }

  void updateHousehold(Household updatedHousehold) {
    final index = _userHouseholds.indexWhere(
      (h) => h.id == updatedHousehold.id,
    );
    if (index != -1) {
      _userHouseholds[index] = updatedHousehold;
      if (_currentHousehold?.id == updatedHousehold.id) {
        _currentHousehold = updatedHousehold;
      }
      notifyListeners();
    }
  }

  void removeHousehold(String householdId) {
    _userHouseholds.removeWhere((h) => h.id == householdId);
    if (_currentHousehold?.id == householdId) {
      _currentHousehold = _userHouseholds.isNotEmpty
          ? _userHouseholds.first
          : null;
    }
    notifyListeners();
  }

  bool isAdmin(String userId) {
    return _currentHousehold?.isAdmin(userId) ?? false;
  }

  bool isMember(String userId) {
    return _currentHousehold?.isMember(userId) ?? false;
  }

  void clear() {
    _currentHousehold = null;
    _userHouseholds = [];
    notifyListeners();
  }
}
