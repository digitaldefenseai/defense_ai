import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço singleton para controlar o status Premium com persistência local.
/// - Salva `is_premium` e a data de expiração
/// - Notifica a UI (ChangeNotifier) quando o status muda
class PremiumService extends ChangeNotifier {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  bool _isPremium = false;
  DateTime? _premiumExpiryDate;

  bool get isPremium => _isPremium;
  DateTime? get premiumExpiryDate => _premiumExpiryDate;

  /// Carrega estado salvo e já “derruba” para free se estiver expirado
  Future<void> initialize() async {
    await _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;

    final expiryTimestamp = prefs.getInt('premium_expiry');
    if (expiryTimestamp != null) {
      _premiumExpiryDate =
          DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);

      // Se já expirou, volta para free
      if (_premiumExpiryDate!.isBefore(DateTime.now())) {
        _isPremium = false;
        _premiumExpiryDate = null;
        await _savePremiumStatus();
      }
    }

    notifyListeners();
  }

  Future<void> _savePremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', _isPremium);

    if (_premiumExpiryDate != null) {
      await prefs.setInt(
        'premium_expiry',
        _premiumExpiryDate!.millisecondsSinceEpoch,
      );
    } else {
      await prefs.remove('premium_expiry');
    }
  }

  /// Ativa Premium por uma [duration] (ex.: 24h, 30 dias, 1 ano)
  Future<void> activatePremium({required Duration duration}) async {
    _isPremium = true;
    _premiumExpiryDate = DateTime.now().add(duration);
    await _savePremiumStatus();
    notifyListeners();
  }

  /// Ativa Premium por 24 horas
  Future<void> activatePremiumFor24Hours() async {
    await activatePremium(duration: const Duration(hours: 24));
  }

  /// Ativa Premium por 30 dias
  Future<void> activatePremiumMonthly() async {
    await activatePremium(duration: const Duration(days: 30));
  }

  /// Ativa Premium por 365 dias
  Future<void> activatePremiumYearly() async {
    await activatePremium(duration: const Duration(days: 365));
  }

  /// Desativa Premium imediatamente
  Future<void> deactivatePremium() async {
    _isPremium = false;
    _premiumExpiryDate = null;
    await _savePremiumStatus();
    notifyListeners();
  }

  /// Texto amigável com o tempo restante
  String getRemainingTimeText() {
    if (!_isPremium || _premiumExpiryDate == null) {
      return 'Não ativo';
    }

    final remaining = _premiumExpiryDate!.difference(DateTime.now());

    if (remaining.inDays > 0) {
      return '${remaining.inDays} dias restantes';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours} horas restantes';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes} minutos restantes';
    } else {
      return 'Expirando em breve';
    }
  }
}
