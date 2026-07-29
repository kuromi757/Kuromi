import 'package:flutter/material.dart';
import '../providers/audio_provider.dart';

class SleepTimerDialog extends StatelessWidget {
  final AudioProvider audio;
  const SleepTimerDialog({super.key, required this.audio});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final options = [5, 10, 15, 20, 30, 45, 60, 90];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onBackground.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.bedtime_rounded, size: 28),
              const SizedBox(width: 12),
              const Text('Temporizador de sueño',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Spacer(),
              if (audio.hasSleepTimer)
                TextButton(
                  onPressed: () {
                    audio.cancelSleepTimer();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
            ],
          ),
          if (audio.hasSleepTimer) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_rounded),
                  const SizedBox(width: 8),
                  Text(
                    _formatSeconds(audio.sleepTimerRemaining),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: colorScheme.primary),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Detener música después de:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map((min) => ActionChip(
                      label: Text('$min min'),
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      onPressed: () {
                        audio.setSleepTimer(min);
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatSeconds(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
