import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gal/gal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../logic/blocs/home/home_bloc.dart';
import '../../../logic/blocs/plan/plan_bloc.dart';

/// The whole trip encoded into a QR code, so it works offline.
class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  final GlobalKey _qrBoundaryKey = GlobalKey();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Normally loaded by the Plan tab already; make sure regardless.
    final planBloc = context.read<PlanBloc>();
    if (planBloc.state.status == PlanStatus.initial) {
      planBloc.add(const PlanStarted());
    }
  }

  String _qrPayload(PlanState plan, HomeState home) {
    return jsonEncode({
      'app': 'RwandaGo',
      'v': 1,
      'trip': home.trip?.name ?? 'Rwanda Trip',
      'days': plan.days.map((d) => d.toJson()).toList(),
    });
  }

  String _shareText(PlanState plan, HomeState home) {
    final buffer = StringBuffer()
      ..writeln('${home.trip?.name ?? 'Rwanda Trip'} — RwandaGo itinerary')
      ..writeln();
    for (final day in plan.days) {
      buffer.writeln('Day ${day.day}: ${day.title}');
      for (final activity in day.activities) {
        buffer.writeln('  ${activity.time} — ${activity.title}');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  Future<void> _saveToPhotos() async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final boundary =
          _qrBoundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      await Gal.putImageBytes(
        byteData!.buffer.asUint8List(),
        name: 'rwandago_itinerary',
      );
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Saved to Photos'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Could not save — check photo permissions'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: BlocBuilder<PlanBloc, PlanState>(
        builder: (context, planState) {
          final homeState = context.watch<HomeBloc>().state;

          if (planState.status != PlanStatus.ready) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Your Offline Itinerary',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Scan this code to share your trip',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: RepaintBoundary(
                            key: _qrBoundaryKey,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              child: QrImageView(
                                data: _qrPayload(planState, homeState),
                                version: QrVersions.auto,
                                size: 260,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: AppColors.primary,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'No internet required',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                        ),
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share Itinerary'),
                        onPressed: () {
                          SharePlus.instance.share(
                            ShareParams(
                              text: _shareText(planState, homeState),
                              subject: 'My RwandaGo itinerary',
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                          minimumSize: const Size.fromHeight(52),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary,
                                ),
                              )
                            : const Icon(Icons.download_outlined),
                        label: const Text('Save to Photos'),
                        onPressed: _saving ? null : _saveToPhotos,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
