// lib/core/server_time.dart
import 'dart:async';
import 'dart:io' show HttpClient, HttpClientRequest, HttpClientResponse, HttpHeaders, HttpDate;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:defense_ai/core/session.dart';

/// Sincroniza o horário com um servidor HTTP lendo o header "Date".
/// - Usa um HEAD rápido; se falhar, não quebra o app (apenas ignora).
/// - ✅ Persiste o drift chamando Session.setServerNowAndPersist(...).
///
/// [endpoint] pode ser o seu backend (recomendado). Enquanto isso, usamos o Google.
/// Ex.: Uri.parse('https://seu-backend.exemplo.com/health') – precisa responder com "Date".
Future<void> syncServerTime({Uri? endpoint, Duration timeout = const Duration(seconds: 4)}) async {
  if (kIsWeb) {
    // Em Web, 'dart:io' não é suportado. Exponha o horário via endpoint próprio e use 'http' (package:http).
    return;
  }

  final target = endpoint ?? Uri.parse('https://www.google.com');

  final client = HttpClient()
    ..connectionTimeout = timeout
    ..userAgent = 'DefenseAI-TimeSync/1.0';

  try {
    final HttpClientRequest req = await client.openUrl('HEAD', target);
    req.headers.set(HttpHeaders.acceptHeader, '*/*');

    final HttpClientResponse res = await req.close();
    final dateStr = res.headers.value(HttpHeaders.dateHeader);

    if (dateStr == null || dateStr.isEmpty) {
      // Sem header Date – não há como sincronizar.
      return;
    }

    // Ex.: "Tue, 15 Nov 1994 08:12:31 GMT" -> UTC
    final serverUtc = HttpDate.parse(dateStr).toUtc();

    // ✅ Ajuste: persiste o drift para sobreviver a reinícios do app.
    await Session.setServerNowAndPersist(serverUtc);
  } catch (_) {
    // Falha de rede, DNS, etc. Ignora: app continua com relógio local.
    return;
  } finally {
    client.close(force: true);
  }
}
