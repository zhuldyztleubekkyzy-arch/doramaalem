import 'package:flutter/foundation.dart';
import '../models/dorama.dart';
import '../services/api_service.dart';

class DoramaProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Dorama> _doramas = [];
  List<Dorama> _favorites = [];
  bool _isLoading = false;
  String? _error;

  List<Dorama> get doramas => _doramas;
  List<Dorama> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDoramas() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _doramas = await _apiService.getDoramas();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchDoramas(String query) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _doramas = await _apiService.searchDoramas(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

