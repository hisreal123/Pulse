abstract final class Env {
  static const useLocalStub = bool.fromEnvironment('USE_LOCAL_STUB');
  static const apiBase = String.fromEnvironment('API_BASE');
  static const bucket = String.fromEnvironment('BUCKET');
}
