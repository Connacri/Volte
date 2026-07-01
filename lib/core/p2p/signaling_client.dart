import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../utils/logger.dart';

class SignalingClient {
  final String url;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isClosed = false;
  bool _wasConnected = false;

  Function(Map<String, dynamic>)? onMessage;
  Function()? onConnect;
  Function()? onDisconnect;

  SignalingClient(this.url) {
    _connect();
  }

  void _connect() {
    if (_isClosed) return;

    Logger.info("Connecting to signaling server: $url");
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      // `channel.ready` (web_socket_channel >=3.0.0) est un Future qui ne se
      // complète qu'une fois le handshake WebSocket réellement établi (ou
      // lève une erreur s'il échoue). C'est le bon signal de "connecté" —
      // contrairement à l'appel immédiat après WebSocketChannel.connect(),
      // qui ne garantit rien sur l'état réel du socket.
      _channel!.ready.then((_) {
        if (_isClosed) return;
        _wasConnected = true;
        Logger.info("Signaling WebSocket handshake established");
        onConnect?.call();
      }).catchError((e) {
        Logger.error("Signaling WebSocket handshake failed: $e");
        _reconnect();
      });

      _subscription = _channel!.stream.listen(
        (event) {
          try {
            final data = jsonDecode(event);
            onMessage?.call(data);
          } catch (e) {
            Logger.error("Failed to decode signaling message: $e");
          }
        },
        onError: (error) {
          Logger.error("Signaling WebSocket error: $error");
          _reconnect();
        },
        onDone: () {
          Logger.info("Signaling WebSocket connection closed");
          _reconnect();
        },
      );
    } catch (e) {
      Logger.error("Failed to connect to signaling server: $e");
      _reconnect();
    }
  }

  void _reconnect() {
    if (_isClosed) return;

    // On ne déclenche onDisconnect que si on avait effectivement atteint
    // l'état "connecté" au moins une fois — évite un onDisconnect fantôme
    // lors d'une toute première tentative qui échoue avant tout handshake.
    if (_wasConnected) {
      _wasConnected = false;
      onDisconnect?.call();
    }

    _subscription?.cancel();
    _channel?.sink.close();

    Logger.info("Reconnecting to signaling server in 5 seconds...");
    Timer(const Duration(seconds: 5), _connect);
  }

  void send(Map<String, dynamic> msg) {
    if (_channel != null) {
      try {
        _channel!.sink.add(jsonEncode(msg));
      } catch (e) {
        Logger.error("Failed to send signaling message: $e");
      }
    } else {
      Logger.error("Cannot send message: SignalingClient not connected");
    }
  }

  void close() {
    _isClosed = true;
    if (_wasConnected) {
      _wasConnected = false;
      onDisconnect?.call();
    }
    _subscription?.cancel();
    _channel?.sink.close();
  }
}