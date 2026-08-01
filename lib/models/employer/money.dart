/// The API returns numeric amounts as either int or double JSON literals
/// (e.g. `4835` vs `29012.5`) — this normalizes either to a double.
double asDouble(dynamic v) => (v as num?)?.toDouble() ?? 0;
