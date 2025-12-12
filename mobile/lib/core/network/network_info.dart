abstract class NetworkInfo {
  Future<bool> isConnected();
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> isConnected() async {
    return true;
  }
}
