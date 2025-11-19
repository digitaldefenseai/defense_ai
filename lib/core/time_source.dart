// lib/core/time_source.dart

/// Abstração de origem de tempo.
/// Por padrão usamos o relógio do dispositivo (SystemTimeSource).
/// Quando o backend estiver pronto, você poderá injetar uma fonte “servidor”.
abstract class TimeSource {
  DateTime now();
}

/// Usa o relógio local do dispositivo.
class SystemTimeSource implements TimeSource {
  @override
  DateTime now() => DateTime.now();
}

/// Usa um horário de servidor + um desvio (drift) calculado.
/// Ex.: serverNow - clientNow => drift; depois, now() = DateTime.now() + drift.
/// Isso tolera pequenos atrasos sem precisar “sincronizar” sempre.
class DriftedServerTimeSource implements TimeSource {
  DriftedServerTimeSource({required this.drift});
  final Duration drift;

  @override
  DateTime now() => DateTime.now().add(drift);

  /// Utilitário para construir a partir de um carimbo do servidor.
  /// Ex.: `fromServerNow(serverNowUtc)` calcula o drift automaticamente.
  factory DriftedServerTimeSource.fromServerNow(DateTime serverNowUtc) {
    // Garante UTC para comparação justa
    final clientNowUtc = DateTime.now().toUtc();
    final drift = serverNowUtc.difference(clientNowUtc);
    return DriftedServerTimeSource(drift: drift);
  }
}
