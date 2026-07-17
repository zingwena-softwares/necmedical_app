import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/gallery_image.dart';

class GalleryDetailScreen extends StatefulWidget {
  final List<GalleryImage> images;
  final int initialIndex;
  const GalleryDetailScreen({super.key, required this.images, required this.initialIndex});

  @override
  State<GalleryDetailScreen> createState() => _GalleryDetailScreenState();
}

class _GalleryDetailScreenState extends State<GalleryDetailScreen> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final next = (_index + delta).clamp(0, widget.images.length - 1);
    _controller.animateToPage(next, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_index + 1} of ${widget.images.length}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => InteractiveViewer(
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.images[i].url,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54, size: 48),
                  ),
                ),
              ),
            ),
          ),
          if (widget.images[_index].title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(widget.images[_index].title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _index > 0 ? () => _go(-1) : null,
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white30)),
                    icon: const Icon(Icons.chevron_left_rounded, size: 18),
                    label: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _index < widget.images.length - 1 ? () => _go(1) : null,
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white30)),
                    icon: const Icon(Icons.chevron_right_rounded, size: 18),
                    label: const Text('Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
