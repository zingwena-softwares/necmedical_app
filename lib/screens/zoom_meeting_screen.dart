import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _zoomBlue = Color(0xFF2D8CFF);

/// Launches a Zoom client URI (zoommtg://...) if the Zoom app is installed;
/// otherwise falls back to the universal https://zoom.us/... web link so it
/// still works (prompts the browser to open Zoom, or joins via web client).
Future<void> _launchZoom(BuildContext context, {required String zoomUri, required String webFallback}) async {
  final zoomLaunched = await canLaunchUrl(Uri.parse(zoomUri)) && await launchUrl(Uri.parse(zoomUri));
  if (zoomLaunched) return;
  if (!context.mounted) return;
  await launchUrl(Uri.parse(webFallback), mode: LaunchMode.externalApplication);
}

class ZoomMeetingScreen extends StatefulWidget {
  const ZoomMeetingScreen({super.key});

  @override
  State<ZoomMeetingScreen> createState() => _ZoomMeetingScreenState();
}

class _ZoomMeetingScreenState extends State<ZoomMeetingScreen> {
  final _meetingIdController = TextEditingController();
  final _passcodeController = TextEditingController();

  @override
  void dispose() {
    _meetingIdController.dispose();
    _passcodeController.dispose();
    super.dispose();
  }

  Future<void> _startMeeting() async {
    // Zoom's own client handles instant-meeting creation once opened — we
    // can't mint a real meeting number ourselves without the Zoom API, so we
    // hand off to the app itself and let the user tap "New Meeting" there.
    await _launchZoom(context, zoomUri: 'zoommtg://zoom.us/', webFallback: 'https://zoom.us/start/videomeeting');
  }

  Future<void> _joinByMeetingId() async {
    final id = _meetingIdController.text.replaceAll(RegExp(r'\s+'), '');
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a meeting ID to join')),
      );
      return;
    }
    final pwd = _passcodeController.text.trim();
    final zoomUri = 'zoommtg://zoom.us/join?action=join&confno=$id${pwd.isNotEmpty ? '&pwd=$pwd' : ''}';
    final webFallback = 'https://zoom.us/j/$id${pwd.isNotEmpty ? '?pwd=$pwd' : ''}';
    await _launchZoom(context, zoomUri: zoomUri, webFallback: webFallback);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Zoom Meetings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_zoomBlue, Color(0xFF1B6FD4)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.videocam_rounded, color: _zoomBlue, size: 28),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'NEC Medical Meetings',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Start a meeting to host, or join one\nsomeone else has shared with you',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ---- Start a meeting ----
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startMeeting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _zoomBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.video_call_rounded, size: 20),
                label: const Text('Start a Meeting', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 20),

            // ---- Join by meeting ID ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Join a Meeting', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text('Enter the Meeting ID someone shared with you',
                      style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _meetingIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Meeting ID',
                      hintText: 'e.g. 123 456 7890',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passcodeController,
                    decoration: const InputDecoration(
                      labelText: 'Passcode (optional)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _joinByMeetingId,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _zoomBlue,
                        side: const BorderSide(color: _zoomBlue),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: const Text('Join Meeting', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
