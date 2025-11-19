// lib/ui/widgets/ad_banner.dart
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:defense_ai/core/session.dart';
import 'package:defense_ai/services/ad_service.dart';
import 'package:defense_ai/ui/theme/responsive.dart';

/// Banner de anúncio com:
/// - Placeholder elegante enquanto carrega ou se falhar
/// - Retentativa com backoff exponencial (1s, 3s, 10s)
/// - Respeita Premium (não mostra nada se for premium)
/// - Seguro para Web/desktop (não renderiza fora de Android/iOS)
class AdBanner extends StatefulWidget {
  const AdBanner({
    super.key,
    this.size = AdSize.banner, // pode trocar depois por adaptativo se quiser
  });

  final AdSize size;

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _ad;
  bool _isLoaded = false;
  bool _hasFailed = false;
  String? _lastError;

  int _attempt = 0;
  static const int _maxAttempts = 3;
  Timer? _retryTimer;

  bool get _isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS;

  double get _placeholderHeight => BR.isSmall(context) ? 48 : 50;

  @override
  void initState() {
    super.initState();
    // Premium não vê anúncios
    if (!Session.isPremium && _isMobile && !kIsWeb) {
      _load();
    }
    // Se premium mudar em runtime, reagimos
    Session.premiumVersion.addListener(_onPremiumChanged);
  }

  void _onPremiumChanged() {
    if (!mounted) return;
    if (Session.isPremium) {
      _disposeAd();
      setState(() {
        _isLoaded = false;
        _hasFailed = false;
        _lastError = null;
      });
    } else {
      if (_ad == null && !_isLoaded && _isMobile && !kIsWeb) {
        _attempt = 0;
        _hasFailed = false;
        _lastError = null;
        _load();
      }
    }
  }

  void _load() {
    _disposeAd();
    _ad = AdService.createBannerAd(
      size: widget.size,
      onLoaded: (ad) {
        if (!mounted) return;
        setState(() {
          _isLoaded = true;
          _hasFailed = false;
          _lastError = null;
        });
      },
      onFailedToLoad: (ad, error) {
        if (!mounted) return;
        setState(() {
          _isLoaded = false;
          _hasFailed = true;
          _lastError = '${error.code} - ${error.message}';
        });
        _scheduleRetry();
      },
    );

    _ad!.load();
  }

  void _scheduleRetry() {
    if (_attempt >= _maxAttempts) return;
    _attempt++;

    // Backoff: 1s, 3s, 10s
    final delays = <Duration>[
      const Duration(seconds: 1),
      const Duration(seconds: 3),
      const Duration(seconds: 10),
    ];
    final delay = delays[_attempt - 1];

    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      if (!mounted || Session.isPremium) return;
      setState(() {
        _hasFailed = false;
        _lastError = null;
      });
      _load();
    });
  }

  void _disposeAd() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _ad?.dispose();
    _ad = null;
  }

  @override
  void dispose() {
    Session.premiumVersion.removeListener(_onPremiumChanged);
    _disposeAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Web/desktop: não renderiza
    if (kIsWeb || !_isMobile) return const SizedBox.shrink();

    // Premium: não renderiza
    if (Session.isPremium) return const SizedBox.shrink();

    // Ad carregado
    if (_isLoaded && _ad != null) {
      return SizedBox(
        width: _ad!.size.width.toDouble(),
        height: _ad!.size.height.toDouble(),
        child: AdWidget(ad: _ad!),
      );
    }

    // Placeholder (carregando ou falhou)
    final cs = Theme.of(context).colorScheme;
    final isError = _hasFailed;

    return Semantics(
      label: isError ? 'Espaço de anúncio indisponível' : 'Carregando anúncio',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isError
            ? () {
          if (Session.isPremium) return;
          setState(() {
            _attempt = 0;
            _hasFailed = false;
            _lastError = null;
          });
          _load();
        }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: _placeholderHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isError
                ? cs.error.withOpacity(0.08)
                : cs.surfaceVariant.withOpacity(0.45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isError ? cs.error : cs.outline).withOpacity(0.35),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isError ? Icons.block : Icons.ad_units,
                size: 18,
                color: isError ? cs.error : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  isError
                      ? 'Anúncio não disponível. Toque para tentar novamente.'
                      : 'Carregando anúncio…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isError ? cs.error : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isError && _lastError != null) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: _lastError!,
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
