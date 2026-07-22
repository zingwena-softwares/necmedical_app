import 'downloadable_document.dart';

class DocumentListContent {
  final String intro;
  final List<DownloadableDocument> documents;

  const DocumentListContent({required this.intro, this.documents = const []});
}
