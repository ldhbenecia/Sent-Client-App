import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/models/ledger_entry.dart';
import '../../domain/models/ledger_enums.dart';
import '../../domain/models/ledger_summary.dart';
import '../models/ledger_entry_dto.dart';

class LedgerEntryRepository {
  const LedgerEntryRepository(this._dio);

  final Dio _dio;

  // GET /api/v1/ledger?year=&month=
  Future<List<LedgerEntry>> fetchByMonth(int year, int month) async {
    try {
      final res = await _dio.get(
        '/api/v1/ledger',
        queryParameters: {'year': year, 'month': month},
      );
      final list = res.data['data'] as List;
      return list
          .map((e) =>
              LedgerEntryDto.fromJson(e as Map<String, dynamic>).toDomain())
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // GET /api/v1/ledger/summary?year=&month=
  Future<LedgerSummary> fetchSummary(int year, int month) async {
    try {
      final res = await _dio.get(
        '/api/v1/ledger/summary',
        queryParameters: {'year': year, 'month': month},
      );
      return LedgerSummary.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // POST /api/v1/ledger
  Future<LedgerEntry> create({
    required LedgerType type,
    required int amount,
    required PaymentMethod paymentMethod,
    String? categoryId,
    String? memo,
    required DateTime transactionDate,
  }) async {
    try {
      final res = await _dio.post(
        '/api/v1/ledger',
        data: {
          'type': type.toJson(),
          'amount': amount,
          'paymentMethod': paymentMethod.toJson(),
          if (categoryId != null) 'categoryId': int.parse(categoryId),
          if (memo != null && memo.isNotEmpty) 'memo': memo,
          'transactionDate':
              '${transactionDate.year.toString().padLeft(4, '0')}-'
              '${transactionDate.month.toString().padLeft(2, '0')}-'
              '${transactionDate.day.toString().padLeft(2, '0')}',
        },
      );
      final id = (res.data['data'] as num).toInt().toString();
      return LedgerEntry(
        id: id,
        type: type,
        amount: amount,
        paymentMethod: paymentMethod,
        categoryId: categoryId,
        memo: memo,
        transactionDate: transactionDate,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // PATCH /api/v1/ledger/{id}
  Future<LedgerEntry> update(LedgerEntry entry) async {
    try {
      await _dio.patch(
        '/api/v1/ledger/${entry.id}',
        data: {
          'type': entry.type.toJson(),
          'amount': entry.amount,
          'paymentMethod': entry.paymentMethod.toJson(),
          if (entry.categoryId != null)
            'categoryId': int.parse(entry.categoryId!),
          if (entry.memo != null && entry.memo!.isNotEmpty) 'memo': entry.memo,
          'transactionDate':
              '${entry.transactionDate.year.toString().padLeft(4, '0')}-'
              '${entry.transactionDate.month.toString().padLeft(2, '0')}-'
              '${entry.transactionDate.day.toString().padLeft(2, '0')}',
        },
      );
      return entry;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // DELETE /api/v1/ledger/{id}
  Future<void> delete(String id) async {
    try {
      await _dio.delete('/api/v1/ledger/$id');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
