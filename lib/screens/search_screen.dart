import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_result.dart';
import '../providers/wordpress_providers.dart';
import '../widgets/skeleton_loaders.dart';
import 'blog_detail_screen.dart';
import 'content_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = _query.isEmpty
        ? const AsyncValue<List<SearchResult>>.data([])
        : ref.watch(searchResultsProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          decoration: const InputDecoration(
            hintText: 'Search notices, blog...',
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? const Center(child: Text('Type to search NEC Medical content.'))
          : results.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 6,
                separatorBuilder: (_, __) => const Divider(height: 24),
                itemBuilder: (_, __) => const RowSkeleton(),
              ),
              error: (e, __) => Center(child: Text('$e')),
              data: (items) {
                if (items.isEmpty) return const Center(child: Text('No results found.'));
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (context, i) => _ResultRow(result: items[i]),
                );
              },
            ),
    );
  }
}

class _ResultRow extends ConsumerWidget {
  final SearchResult result;
  const _ResultRow({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () async {
        showDialog(context: context, barrierDismissible: false, builder: (_) => const ShimmerDialogLoader());
        try {
          if (result.type == SearchResultType.post) {
            final item = await ref.read(postByIdProvider(result.id).future);
            if (!context.mounted) return;
            Navigator.pop(context);
            if (item != null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => BlogDetailScreen(item: item)));
            }
          } else {
            final data = await ref.read(wordpressApiServiceProvider).fetchAllPages(perPage: 100);
            final match = data.where((p) => p.id == result.id).toList();
            if (!context.mounted) return;
            Navigator.pop(context);
            if (match.isNotEmpty) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ContentDetailScreen(item: match.first)));
            }
          }
        } catch (e) {
          if (!context.mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
        }
      },
      child: Row(
        children: [
          Icon(
            result.type == SearchResultType.post ? Icons.article_outlined : Icons.description_outlined,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(result.title, style: TextStyle(fontSize: 14, color: colorScheme.onSurface)),
          ),
          Icon(Icons.chevron_right_rounded, size: 18, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
