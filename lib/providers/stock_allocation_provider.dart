import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/stock_allocation_model.dart';

class StockAllocationProvider extends ChangeNotifier {
  final List<StockAllocationModel> _allocations = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<StockAllocationModel> get allocations => _allocations;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPendingAllocations({int employeeId = 0}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final endpoint = employeeId > 0
          ? ApiConstants.employeeStockAllocations(employeeId)
          : ApiConstants.pendingStockAllocations;

      final result = await ApiService.get(endpoint);

      if (result['success'] == true) {
        final dynamic raw = result['data'];
        final list = raw is Map<String, dynamic>
            ? ((raw['data'] ?? raw['allocations'] ?? raw['items']) as List?) ?? const []
            : raw is List
                ? raw
                : const [];

        _allocations.clear();
        _allocations.addAll(
          list
              .map((e) => StockAllocationModel.fromJson(e as Map<String, dynamic>))
              .where((item) => item.status.toLowerCase() == 'pending')
              .toList(),
        );
      } else {
        _allocations.clear();
        _errorMessage = result['message'] as String? ??
            'Gagal memuat daftar alokasi stok pending.';
        if ((result['statusCode'] as int?) == 404 ||
            (_errorMessage ?? '').toLowerCase().contains('endpoint')) {
          _errorMessage =
              'Kontrak API daftar alokasi pending belum tersedia di backend. UI siap, tetapi data harus diambil dari endpoint JSON yang akan disediakan nanti.';
        }
      }
    } catch (e) {
      _allocations.clear();
      _errorMessage = 'Error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> reviewAllocation({
    required int allocationId,
    required String decision,
    int employeeId = 0,
    int? confirmedQuantity,
    int? actualReceivedQuantity,
    String? declineReason,
  }) async {
    if (_isSubmitting) {
      return {'success': false, 'message': 'Permintaan sedang diproses.'};
    }

    final normalizedDecision = decision.toLowerCase();
    if (normalizedDecision == 'decline' &&
        (actualReceivedQuantity == null || actualReceivedQuantity < 0)) {
      return {
        'success': false,
        'message': 'Jumlah fisik harus diisi saat melaporkan selisih.',
      };
    }

    if (normalizedDecision == 'decline' &&
        (declineReason == null || declineReason.trim().isEmpty)) {
      return {
        'success': false,
        'message': 'Alasan selisih wajib diisi.',
      };
    }

    if (normalizedDecision == 'accept' && (confirmedQuantity == null || confirmedQuantity <= 0)) {
      return {
        'success': false,
        'message': 'Jumlah fisik yang diterima harus lebih dari 0.',
      };
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final payload = <String, dynamic>{
      'decision': normalizedDecision,
      'confirmed_quantity': normalizedDecision == 'accept'
          ? confirmedQuantity
          : (confirmedQuantity ?? 0),
      'decline_reason': declineReason?.trim(),
      'actual_received_quantity': actualReceivedQuantity,
      'difference_quantity': actualReceivedQuantity != null && confirmedQuantity != null
          ? actualReceivedQuantity - confirmedQuantity
          : null,
    };

    try {
      final endpoints = [
        ApiConstants.reviewStockAllocation(allocationId),
        '${ApiConstants.baseUrl}/stock-allocations/$allocationId/review',
      ];

      for (final endpoint in endpoints) {
        final result = await ApiService.post(endpoint, payload);
        if (result['success'] == true) {
          await fetchPendingAllocations(employeeId: employeeId);
          _isSubmitting = false;
          notifyListeners();
          return result;
        }

        if ((result['statusCode'] as int?) != 404) {
          _isSubmitting = false;
          _errorMessage = result['message'] as String? ?? 'Gagal mengirim keputusan.';
          notifyListeners();
          return result;
        }
      }

      _isSubmitting = false;
      _errorMessage =
          'Endpoint review alokasi belum tersedia di backend. Hubungkan kontrak JSON yang sebenarnya.';
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage,
      };
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return {'success': false, 'message': _errorMessage};
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
