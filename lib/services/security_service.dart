// lib/services/security_service.dart
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Novo enum para nível de risco (compatível com o campo string existente)
enum RiskLevel { low, medium, high }

/// Helpers de conversão (mantêm compat com o campo 'riskLevel' string)
RiskLevel _riskFromString(String s) {
  switch (s) {
    case 'high':
      return RiskLevel.high;
    case 'medium':
      return RiskLevel.medium;
    case 'low':
    default:
      return RiskLevel.low;
  }
}

String _riskToString(RiskLevel r) {
  switch (r) {
    case RiskLevel.high:
      return 'high';
    case RiskLevel.medium:
      return 'medium';
    case RiskLevel.low:
      return 'low';
  }
}

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  // Base simulada de golpes conhecidos
  final List<Map<String, dynamic>> _knownScams = [
    {
      'type': 'Pix',
      'description': 'Mensagens urgentes solicitando transferência Pix',
      'keywords': ['pix', 'urgente', 'transferir', 'emergência'],
      'riskLevel': 'high',
    },
    {
      'type': 'WhatsApp Premium',
      'description': 'Ofertas falsas de WhatsApp Premium',
      'keywords': ['whatsapp premium', 'grátis', 'ativar'],
      'riskLevel': 'medium',
    },
    {
      'type': 'Consignação',
      'description': 'Empréstimos consignados fraudulentos',
      'keywords': ['empréstimo', 'consignado', 'aprovado'],
      'riskLevel': 'high',
    },
  ];

  /// Analisa uma URL e retorna um mapa com nível de risco (simulado)
  Future<Map<String, dynamic>> analyzeUrl(String url) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final suspiciousDomains = <String>[
      'bit.ly',
      'tinyurl.com',
      'short.link',
      'suspicious-bank.com',
      'fake-gov.br',
    ];

    final raw = url.trim();
    final uri = Uri.tryParse(raw);
    final host = (uri?.host.isNotEmpty == true ? uri!.host : raw).toLowerCase();

    final isSuspicious = suspiciousDomains.any((d) => host.contains(d));
    final isSecure = (uri?.scheme ?? '').toLowerCase() == 'https';

    // novo enum
    final riskEnum =
    isSuspicious ? RiskLevel.high : (isSecure ? RiskLevel.low : RiskLevel.medium);

    return {
      'url': raw,
      'host': host,
      'isSuspicious': isSuspicious,
      'isSecure': isSecure,

      // ✅ compat: mantém a string antiga
      'riskLevel': _riskToString(riskEnum),

      // ✅ novo campo: enum exposto como string ('low'|'medium'|'high') para não quebrar UI/JSON
      'riskLevelEnum': riskEnum.name,

      'analysis': isSuspicious
          ? 'URL suspeita detectada. Pode ser um golpe.'
          : isSecure
          ? 'URL parece segura.'
          : 'URL não usa HTTPS. Tenha cuidado.',
    };
  }

  /// Procura padrões de golpe em um texto livre (simulado)
  Map<String, dynamic> analyzeText(String text) {
    final lower = text.toLowerCase();

    for (final scam in _knownScams) {
      final keywords = List<String>.from(scam['keywords']);
      final matches = keywords.where((k) => lower.contains(k)).length;

      if (matches >= 2) {
        final currentRiskStr = (scam['riskLevel'] ?? 'low') as String;
        final riskEnum = _riskFromString(currentRiskStr);

        return {
          'isScam': true,
          'scamType': scam['type'],
          'description': scam['description'],

          // compat
          'riskLevel': _riskToString(riskEnum),
          // novo
          'riskLevelEnum': riskEnum.name,

          'confidence': (matches / keywords.length * 100).round(),
        };
      }
    }

    return {
      'isScam': false,
      'riskLevel': 'low',               // compat
      'riskLevelEnum': RiskLevel.low.name, // novo
      'confidence': 0,
    };
  }

  /// Verifica nome de rede Wi-Fi (simulado)
  Future<Map<String, dynamic>> analyzeWiFi(String ssid) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final suspiciousNetworks = <String>['free wifi', 'public', 'guest', 'open', 'wifi gratis'];
    final isSuspicious = suspiciousNetworks.any(
          (p) => ssid.toLowerCase().contains(p),
    );

    final riskEnum = isSuspicious ? RiskLevel.high : RiskLevel.low;

    return {
      'networkName': ssid,
      'isSuspicious': isSuspicious,
      'isSecure': !isSuspicious && ssid.isNotEmpty,

      // compat
      'riskLevel': _riskToString(riskEnum),
      // novo
      'riskLevelEnum': riskEnum.name,

      'recommendation': isSuspicious
          ? 'Evite usar esta rede para transações bancárias.'
          : 'Rede parece ok. Prefira usar VPN quando possível.',
    };
  }

  /// Gera hash SHA-256 (ex.: integridade)
  String generateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Código numérico curto (ex.: verificação/2FA simulado)
  /// Usa Random.secure() quando possível; no Web cai para Random() para evitar UnsupportedError.
  String generateVerificationCode({int length = 6}) {
    const chars = '0123456789';
    final rand = kIsWeb ? Random() : Random.secure();

    return String.fromCharCodes(
      Iterable.generate(
        length,
            (_) => chars.codeUnitAt(rand.nextInt(chars.length)),
      ),
    );
  }

  /// Simula envio de alerta de emergência
  Future<bool> sendEmergencyAlert(String message, String contactInfo) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (kDebugMode) {
      print('[EMERGENCY] $message | contato: $contactInfo | ${DateTime.now()}');
    }
    return true;
  }

  /// Leitura/adição da base de golpes (simulada)
  List<Map<String, dynamic>> getKnownScams() => List.from(_knownScams);

  void reportNewScam(String type, String description, List<String> keywords) {
    _knownScams.add({
      'type': type,
      'description': description,
      'keywords': keywords,
      'riskLevel': 'medium',
      'reportedAt': DateTime.now().toIso8601String(),
    });
  }
}
