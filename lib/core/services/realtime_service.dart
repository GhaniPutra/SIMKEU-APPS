import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import 'api_service.dart';

class StoreChange {
  const StoreChange(this.id, this.resource);

  final String id;
  final String resource;
}

class RealtimeService {
  static const _permissionsByResource = <String, List<String>>{
    'sales': [
      'sales.view',
      'sales.mobile.view',
      'dashboard.view',
      'dashboard.mobile.view'
    ],
    'expenses': [
      'expenses.view',
      'expenses.mobile.view',
      'dashboard.view',
      'dashboard.mobile.view'
    ],
    'inventory': [
      'products.view',
      'products.mobile.view',
      'products.stock.add',
      'products.stock.update',
      'products.stock.adjust',
      'pos.mobile.use',
      'stock_allocations.view',
      'stock_allocations.create',
      'stock_allocations.confirm',
      'stock_allocations.review',
      'stock_allocations.transfer',
    ],
    'stock-allocations': [
      'stock_allocations.view',
      'stock_allocations.create',
      'stock_allocations.confirm',
      'stock_allocations.review',
      'stock_allocations.transfer',
    ],
    'employees': [
      'employees.view',
      'employees.create',
      'employees.update',
      'employees.delete'
    ],
  };

  final _changes = StreamController<StoreChange>.broadcast();
  final _connectionChanges = StreamController<bool>.broadcast();
  final _seenEventIds = <String>{};

  WebSocket? _socket;
  Timer? _reconnectTimer;
  Timer? _handshakeTimer;
  int _reconnectAttempt = 0;
  int _storeId = 0;
  String? _token;
  Set<String> _resources = {};
  bool _connecting = false;
  bool _connected = false;
  bool _disposed = false;

  Stream<StoreChange> get changes => _changes.stream;
  Stream<bool> get connectionChanges => _connectionChanges.stream;
  bool get isConnected => _connected;
  Set<String> get resources => _resources;

  Future<void> connect({
    required int storeId,
    required String token,
    required List<String> permissions,
  }) async {
    _storeId = storeId;
    _token = token;
    _resources = _permissionsByResource.entries
        .where((entry) => entry.value.any(permissions.contains))
        .map((entry) => entry.key)
        .toSet();
    await reconnect();
  }

  Future<void> reconnect() async {
    if (_disposed ||
        _connected ||
        _connecting ||
        _storeId <= 0 ||
        _token == null ||
        _resources.isEmpty ||
        ApiConstants.reverbAppKey.isEmpty) {
      return;
    }

    _connecting = true;
    final secure = ApiConstants.reverbScheme == 'https';
    final uri = Uri(
      scheme: secure ? 'wss' : 'ws',
      host: ApiConstants.reverbHost,
      port: ApiConstants.reverbPort,
      path: '/app/${ApiConstants.reverbAppKey}',
      queryParameters: const {
        'protocol': '7',
        'client': 'js',
        'version': '8.4.0',
        'flash': 'false',
      },
    );

    try {
      final socket = await WebSocket.connect(uri.toString())
          .timeout(const Duration(seconds: 10));
      if (_disposed) {
        await socket.close(WebSocketStatus.normalClosure);
        return;
      }

      _socket = socket;
      _handshakeTimer = Timer(const Duration(seconds: 10), () {
        _connectionLost(StateError('Realtime handshake timed out.'));
      });
      socket.listen(
        _handleMessage,
        onError: (Object error) => _connectionLost(error),
        onDone: _connectionLost,
        cancelOnError: true,
      );
    } catch (error) {
      _connectionLost(error);
    } finally {
      _connecting = false;
    }
  }

  Future<void> _subscribe(String socketId) async {
    final socket = _socket;
    if (socket == null) return;

    for (final resource in _resources) {
      final channel = 'private-store.$_storeId.$resource';
      final response = await ApiService.post(ApiConstants.broadcastAuth, {
        'socket_id': socketId,
        'channel_name': channel,
      });
      final auth = response['auth'];
      if (response['success'] == false || auth is! String || auth.isEmpty) {
        debugPrint(
            'Realtime channel authorization failed for $resource: ${response['message'] ?? 'invalid auth response'}');
        _connectionLost(
            StateError('Realtime channel authorization failed for $resource.'));
        return;
      }

      if (_socket != socket) return;
      socket.add(jsonEncode({
        'event': 'pusher:subscribe',
        'data': {'auth': auth, 'channel': channel},
      }));
    }
  }

  void _handleMessage(dynamic raw) {
    try {
      if (raw is! String) {
        throw const FormatException('Realtime message was not text.');
      }
      _processMessage(raw);
    } on FormatException catch (error) {
      _connectionLost(error);
    } on TypeError catch (error) {
      _connectionLost(error);
    }
  }

  void _processMessage(String raw) {
    final message = jsonDecode(raw) as Map<String, dynamic>;
    final event = message['event'];
    if (event == 'pusher:ping') {
      _socket?.add(jsonEncode({'event': 'pusher:pong', 'data': {}}));
      return;
    }

    if (event == 'pusher:connection_established') {
      final connection =
          jsonDecode(message['data'] as String) as Map<String, dynamic>;
      final socketId = connection['socket_id'] as String?;
      if (socketId == null) {
        _connectionLost(StateError('Realtime server omitted the socket ID.'));
        return;
      }
      _connected = true;
      _handshakeTimer?.cancel();
      _handshakeTimer = null;
      _reconnectAttempt = 0;
      _connectionChanges.add(true);
      unawaited(_subscribe(socketId));
      return;
    }

    if (event == 'store.data.changed') {
      final payload = message['data'] is String
          ? jsonDecode(message['data'] as String) as Map<String, dynamic>
          : message['data'] as Map<String, dynamic>;
      final id = payload['id']?.toString();
      final channel = message['channel']?.toString() ?? '';
      final resource = _resources.firstWhere(
        (candidate) => channel.endsWith('.$candidate'),
        orElse: () => '',
      );
      if (id == null || resource.isEmpty || !_seenEventIds.add('$id:$resource'))
        return;
      if (_seenEventIds.length > 200) _seenEventIds.remove(_seenEventIds.first);
      _changes.add(StoreChange(id, resource));
    }
  }

  void _connectionLost([Object? error]) {
    if (_disposed) return;
    _handshakeTimer?.cancel();
    _handshakeTimer = null;
    final socket = _socket;
    _socket = null;
    if (socket != null) unawaited(socket.close(WebSocketStatus.goingAway));
    final wasConnected = _connected;
    _connected = false;
    if (wasConnected) _connectionChanges.add(false);
    if (error != null) debugPrint('Realtime connection lost: $error');
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnectTimer != null) return;
    final delaySeconds = 1 << _reconnectAttempt.clamp(0, 5).toInt();
    _reconnectAttempt++;
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      _reconnectTimer = null;
      unawaited(reconnect());
    });
  }

  Future<void> dispose() async {
    _disposed = true;
    _reconnectTimer?.cancel();
    _handshakeTimer?.cancel();
    await _socket?.close(WebSocketStatus.normalClosure);
    await _changes.close();
    await _connectionChanges.close();
  }
}
