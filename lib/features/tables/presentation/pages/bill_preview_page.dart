import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:hotel/core/constants/font_constants.dart';
import 'package:hotel/core/services/bank_storage_service.dart';
import 'package:hotel/core/services/bill_cache_service.dart';
import 'package:hotel/features/tables/data/models/bank_model.dart';
import 'package:hotel/features/tables/data/repositories/payment_repository.dart';

class BillPreviewPage extends StatefulWidget {
  final Uint8List pdfBytes;
  final String tableName;
  final int billNo;
  final double netAmount;
  final int tableId;

  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);

  const BillPreviewPage({
    super.key,
    required this.pdfBytes,
    required this.tableName,
    required this.billNo,
    required this.netAmount,
    required this.tableId,
  });

  @override
  State<BillPreviewPage> createState() => _BillPreviewPageState();
}

class _BillPreviewPageState extends State<BillPreviewPage> {
  static const Color _textMuted = Color(0xFF718096);
  static const Color _successColor = Color(0xFF38A169);

  final PaymentRepository _paymentRepository = PaymentRepository();

  List<BankModel> _banks = [];
  BankModel? _selectedBank;
  bool _isLoadingBanks = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    final banks = await BankStorageService.getBanksWithFallback();
    if (mounted) {
      setState(() {
        _banks = banks;
        _isLoadingBanks = false;
      });
    }
  }

  bool get _isCashPayment => _selectedBank?.ifsc == 'CASH';

  Future<void> _submitPayment() async {
    if (_selectedBank == null) {
      _showError('Please select a payment method.');
      return;
    }

    final bankId = _selectedBank!.id;
    final paymode = _isCashPayment ? 'Cash' : 'Bank';

    setState(() => _isSubmitting = true);

    try {
      await _paymentRepository.submitPayment(
        widget.billNo,
        cashReceived: widget.netAmount,
        returnAmount: 0,
        discount: 0,
        paymode: paymode,
        bankId: bankId,
      );

      // Clear cached bill after successful payment
      await BillCacheService.clearCachedBill(widget.tableId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Payment accepted successfully'),
              ],
            ),
            backgroundColor: _successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showError('Payment failed: ${e.toString()}');
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: PdfPreview(
              build: (_) => Future.value(widget.pdfBytes),
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              allowPrinting: false,
              allowSharing: false,
              pdfFileName: 'Bill_${widget.tableName}.pdf',
            ),
          ),
          _buildPaymentSection(),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [BillPreviewPage.primaryGradientStart, BillPreviewPage.primaryGradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: BillPreviewPage.primaryGradientStart.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bill Preview',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Table ${widget.tableName}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Printing.sharePdf(
                  bytes: widget.pdfBytes,
                  filename: 'Bill_${widget.tableName}.pdf',
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Printing.layoutPdf(
                  onLayout: (_) => Future.value(widget.pdfBytes),
                  name: 'Bill_${widget.tableName}',
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.print_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBankDropdown(),
            const SizedBox(height: 12),
            _buildAcceptPaymentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDropdown() {
    if (_isLoadingBanks) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(BillPreviewPage.primaryGradientStart),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading banks...',
              style: TextStyle(color: _textMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BillPreviewPage.primaryGradientStart.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BankModel>(
          isExpanded: true,
          value: _selectedBank,
          hint: Text(
            'baaMk inavaDa',
            style: AppFonts.kiranText(
              fontSize: 20,
              color: _textMuted,
            ),
          ),
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: BillPreviewPage.primaryGradientStart,
            size: 28,
          ),
          items: _banks.map((bank) {
            return DropdownMenuItem<BankModel>(
              value: bank,
              child: Text(
                bank.displayName,
                style: AppFonts.kiranText(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A202C),
                ),
              ),
            );
          }).toList(),
          onChanged: (bank) {
            setState(() {
              _selectedBank = bank;
            });
          },
        ),
      ),
    );
  }

  Widget _buildAcceptPaymentButton() {
    final bool canSubmit = _selectedBank != null;

    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: canSubmit && !_isSubmitting
                ? [_successColor, _successColor.withValues(alpha: 0.85)]
                : [Colors.grey.shade400, Colors.grey.shade300],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: canSubmit && !_isSubmitting
              ? [
                  BoxShadow(
                    color: _successColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: canSubmit && !_isSubmitting ? _submitPayment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Accept Payment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
